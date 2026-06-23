/// Handles Inter-Process Communication (IPC) via stdio using JSON-RPC 2.0.
/// Reads incoming JSON commands from Flutter (stdin) and sends responses/events (stdout).

use serde::{Deserialize, Serialize};
use serde_json::Value;
use tokio::io::{self, AsyncBufReadExt, BufReader, AsyncWriteExt};

#[derive(Deserialize, Debug, PartialEq)]
pub struct JsonRpcRequest {
    pub jsonrpc: String,
    pub method: String,
    #[serde(default)]
    pub params: Option<Value>,
    #[serde(default)]
    pub id: Option<Value>,
}

#[derive(Serialize, Debug, PartialEq)]
pub struct JsonRpcResponse {
    pub jsonrpc: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<JsonRpcError>,
    pub id: Value,
}

#[derive(Serialize, Debug, PartialEq)]
pub struct JsonRpcError {
    pub code: i32,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<Value>,
}

impl JsonRpcResponse {
    pub fn success(id: Value, result: Value) -> Self {
        JsonRpcResponse {
            jsonrpc: "2.0".to_string(),
            result: Some(result),
            error: None,
            id,
        }
    }

    pub fn error(id: Value, code: i32, message: &str, data: Option<Value>) -> Self {
        JsonRpcResponse {
            jsonrpc: "2.0".to_string(),
            result: None,
            error: Some(JsonRpcError {
                code,
                message: message.to_string(),
                data,
            }),
            id,
        }
    }
}

pub const PARSE_ERROR: i32 = -32700;
pub const INVALID_REQUEST: i32 = -32600;
pub const METHOD_NOT_FOUND: i32 = -32601;
pub const INVALID_PARAMS: i32 = -32602;
pub const INTERNAL_ERROR: i32 = -32603;

pub fn validate_and_parse_request(input: &str) -> Result<JsonRpcRequest, JsonRpcResponse> {
    let parsed: Value = match serde_json::from_str(input) {
        Ok(v) => v,
        Err(_) => return Err(JsonRpcResponse::error(Value::Null, PARSE_ERROR, "Parse error", None)),
    };

    if !parsed.is_object() {
        return Err(JsonRpcResponse::error(Value::Null, INVALID_REQUEST, "Invalid Request", None));
    }

    let req: JsonRpcRequest = match serde_json::from_value(parsed.clone()) {
        Ok(r) => r,
        Err(_) => {
            let id = parsed.get("id").cloned().unwrap_or(Value::Null);
            return Err(JsonRpcResponse::error(id, INVALID_REQUEST, "Invalid Request", None));
        }
    };

    if req.jsonrpc != "2.0" {
        let id = req.id.clone().unwrap_or(Value::Null);
        return Err(JsonRpcResponse::error(id, INVALID_REQUEST, "Invalid Request", None));
    }

    Ok(req)
}

/// Start the listener loop
pub async fn start_listener() {
    let stdin = io::stdin();
    let reader = BufReader::new(stdin);
    let mut lines = reader.lines();

    while let Ok(Some(line)) = lines.next_line().await {
        if line.trim().is_empty() {
            continue;
        }

        let response = match validate_and_parse_request(&line) {
            Ok(req) => {
                let id = req.id.clone().unwrap_or(Value::Null);
                match req.method.as_str() {
                    "send_task" => {
                        let params = req.params.unwrap_or(Value::Null);
                        let prompt = params.get("prompt").and_then(|v| v.as_str()).unwrap_or("").to_string();
                        let repo = params.get("repo").and_then(|v| v.as_str()).unwrap_or("").to_string();
                        let branch = params.get("branch").and_then(|v| v.as_str()).unwrap_or("").to_string();

                        if prompt.is_empty() || repo.is_empty() || branch.is_empty() {
                            JsonRpcResponse::error(id, INVALID_PARAMS, "Invalid params", None)
                        } else {
                            let task_id = handle_send_task(prompt, repo, branch).await;
                            JsonRpcResponse::success(id, Value::String(task_id))
                        }
                    }
                    _ => {
                        JsonRpcResponse::error(id, METHOD_NOT_FOUND, "Method not found", None)
                    }
                }
            }
            Err(err_response) => err_response,
        };

        if let Ok(mut json) = serde_json::to_string(&response) {
            json.push('\n');
            let mut stdout = io::stdout();
            let _ = stdout.write_all(json.as_bytes()).await;
            let _ = stdout.flush().await;
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
    use serde_json::json;

    #[test]
    fn test_valid_request() {
        let input = r#"{"jsonrpc": "2.0", "method": "send_task", "params": {"prompt": "p", "repo": "r", "branch": "b"}, "id": 1}"#;
        let req = validate_and_parse_request(input).unwrap();
        assert_eq!(req.jsonrpc, "2.0");
        assert_eq!(req.method, "send_task");
        assert_eq!(req.id, Some(json!(1)));
    }

    #[test]
    fn test_malformed_json() {
        let input = r#"{"jsonrpc": "2.0", "method": "s"#;
        let err = validate_and_parse_request(input).unwrap_err();
        assert_eq!(err.error.unwrap().code, PARSE_ERROR);
        assert_eq!(err.id, Value::Null);
    }

    #[test]
    fn test_missing_jsonrpc_version() {
        let input = r#"{"method": "send_task", "id": 1}"#;
        let err = validate_and_parse_request(input).unwrap_err();
        assert_eq!(err.error.unwrap().code, INVALID_REQUEST);
        assert_eq!(err.id, json!(1));
    }

    #[test]
    fn test_invalid_jsonrpc_version() {
        let input = r#"{"jsonrpc": "1.0", "method": "send_task", "id": 1}"#;
        let err = validate_and_parse_request(input).unwrap_err();
        assert_eq!(err.error.unwrap().code, INVALID_REQUEST);
        assert_eq!(err.id, json!(1));
    }

    #[test]
    fn test_not_an_object() {
        let input = r#"[1, 2, 3]"#;
        let err = validate_and_parse_request(input).unwrap_err();
        assert_eq!(err.error.unwrap().code, INVALID_REQUEST);
        assert_eq!(err.id, Value::Null);
    }
}
