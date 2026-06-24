/// Stub: Handles Inter-Process Communication (IPC) via stdio.
/// Reads incoming JSON commands from Flutter (stdin) and sends responses/events (stdout).

use serde::{Deserialize, Serialize};
use std::io::{BufRead, BufReader, Read, Write};

#[derive(Deserialize, Debug)]
pub struct IpcRequest {
    pub id: String,
    pub command: String,
    pub payload: serde_json::Value,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct IpcResponse {
    pub id: String,
    pub success: bool,
    pub data: Option<serde_json::Value>,
    pub error: Option<String>,
}

/// Starts the listener loop, blocking a thread
pub async fn start_listener() {
    tokio::task::spawn_blocking(|| {
        let stdin = std::io::stdin();
        let stdout = std::io::stdout();
        run_listener(stdin.lock(), stdout.lock());
    })
    .await
    .unwrap();
}

/// Main IPC listener loop abstracted over Read/Write traits
pub fn run_listener<R: Read, W: Write>(reader: R, mut writer: W) {
    let buf_reader = BufReader::new(reader);
    let handle = tokio::runtime::Handle::try_current().ok();

    for line_result in buf_reader.lines() {
        let line = match line_result {
            Ok(l) => l,
            Err(_) => break,
        };

        if line.trim().is_empty() {
            continue;
        }

        let request: Result<IpcRequest, _> = serde_json::from_str(&line);
        let response = match request {
            Ok(req) => {
                let (success, data, error) = if req.command == "send_task" {
                    if let (Some(prompt), Some(repo), Some(branch)) = (
                        req.payload.get("prompt").and_then(|v| v.as_str()),
                        req.payload.get("repo").and_then(|v| v.as_str()),
                        req.payload.get("branch").and_then(|v| v.as_str()),
                    ) {
                        let prompt = prompt.to_string();
                        let repo = repo.to_string();
                        let branch = branch.to_string();

                        let task_id = if let Some(h) = &handle {
                            h.block_on(async {
                                handle_send_task(prompt, repo, branch).await
                            })
                        } else {
                            // Fallback for tests if no tokio runtime is present
                            "stub-task-id-123".to_string()
                        };

                        (true, Some(serde_json::json!({ "task_id": task_id })), None)
                    } else {
                        (false, None, Some("Invalid payload for send_task".to_string()))
                    }
                } else {
                    (false, None, Some(format!("Unknown command: {}", req.command)))
                };

                IpcResponse {
                    id: req.id,
                    success,
                    data,
                    error,
                }
            }
            Err(e) => IpcResponse {
                id: "".to_string(),
                success: false,
                data: None,
                error: Some(format!("Parse error: {}", e)),
            },
        };

        if let Ok(mut res_str) = serde_json::to_string(&response) {
            res_str.push('\n');
            if writer.write_all(res_str.as_bytes()).is_err() {
                break;
            }
            if writer.flush().is_err() {
                break;
            }
        }
    }
}

/// Stub handler for sending a task
pub async fn handle_send_task(_prompt: String, _repo: String, _branch: String) -> String {
    // Call proxy_client::post_task
    "stub-task-id-123".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Cursor;

    #[test]
    fn test_valid_send_task() {
        let req_json = serde_json::json!({
            "id": "1",
            "command": "send_task",
            "payload": {
                "prompt": "fix login bug",
                "repo": "user/repo",
                "branch": "main"
            }
        });

        let input = format!("{}\n", req_json.to_string());
        let reader = Cursor::new(input);
        let mut writer = Cursor::new(Vec::new());

        run_listener(reader, &mut writer);

        let output = String::from_utf8(writer.into_inner()).unwrap();
        let res: IpcResponse = serde_json::from_str(output.trim()).unwrap();

        assert_eq!(res.id, "1");
        assert!(res.success);
        assert!(res.error.is_none());

        let data = res.data.unwrap();
        assert_eq!(data.get("task_id").unwrap().as_str().unwrap(), "stub-task-id-123");
    }

    #[test]
    fn test_invalid_command() {
        let req_json = serde_json::json!({
            "id": "2",
            "command": "unknown_cmd",
            "payload": {}
        });

        let input = format!("{}\n", req_json.to_string());
        let reader = Cursor::new(input);
        let mut writer = Cursor::new(Vec::new());

        run_listener(reader, &mut writer);

        let output = String::from_utf8(writer.into_inner()).unwrap();
        let res: IpcResponse = serde_json::from_str(output.trim()).unwrap();

        assert_eq!(res.id, "2");
        assert!(!res.success);
        assert!(res.data.is_none());
        assert_eq!(res.error.unwrap(), "Unknown command: unknown_cmd");
    }

    #[test]
    fn test_invalid_json() {
        let input = "{ invalid json \n";
        let reader = Cursor::new(input);
        let mut writer = Cursor::new(Vec::new());

        run_listener(reader, &mut writer);

        let output = String::from_utf8(writer.into_inner()).unwrap();
        let res: IpcResponse = serde_json::from_str(output.trim()).unwrap();

        assert_eq!(res.id, "");
        assert!(!res.success);
        assert!(res.data.is_none());
        assert!(res.error.unwrap().starts_with("Parse error:"));
    }
}
