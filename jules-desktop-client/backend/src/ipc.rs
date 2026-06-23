/// Stub: Handles Inter-Process Communication (IPC) via stdio.
/// Reads incoming JSON commands from Flutter (stdin) and sends responses/events (stdout).

use serde::{Deserialize, Serialize};

#[derive(Deserialize, Debug)]
pub struct IpcRequest {
    pub id: String,
    pub command: String,
    pub payload: serde_json::Value,
}

#[derive(Serialize, Debug)]
pub struct IpcResponse {
    pub id: String,
    pub success: bool,
    pub data: Option<serde_json::Value>,
    pub error: Option<String>,
}

/// Stub function to start the listener loop
pub async fn start_listener() {
    // Loop over std::io::stdin().lines()
    // Parse JSON into IpcRequest
    // Dispatch to appropriate handler (proxy_client or cli)
    // Write IpcResponse as JSON line to std::io::stdout()
}

/// Stub handler for sending a task
pub async fn handle_send_task(prompt: String, repo: String, branch: String) -> String {
    // Call proxy_client::post_task
    "stub-task-id-123".to_string()
}
