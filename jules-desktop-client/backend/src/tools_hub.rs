use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct JsonRpcRequest {
    pub jsonrpc: String,
    pub id: String,
    pub method: String,
    pub params: Option<serde_json::Value>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct JsonRpcResponse {
    pub jsonrpc: String,
    pub id: String,
    pub result: Option<serde_json::Value>,
    pub error: Option<JsonRpcError>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct JsonRpcError {
    pub code: i32,
    pub message: String,
    pub data: Option<serde_json::Value>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct FileAttachment {
    pub path: String,
    pub status: String, // e.g., "new", "modified"
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SlashCommandPayload {
    pub command: String,
    pub arguments: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ToolAction {
    LocalTestRunner,
    TokenOptimizer,
    MultiAgentRouteMap,
    SecureEnvMasker,
    UiVisualPrototyper,
    DependencyConflictResolver,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ToolActivationPayload {
    pub tool: ToolAction,
    pub enabled: bool,
    pub options: Option<serde_json::Value>,
}

pub async fn dispatch_tool_command(request: JsonRpcRequest) -> JsonRpcResponse {
    // Mock dispatcher logic
    let result = match request.method.as_str() {
        "tool.activate" => {
            serde_json::json!({
                "status": "success",
                "message": "Tool activated successfully"
            })
        },
        "slash.execute" => {
            serde_json::json!({
                "status": "success",
                "message": "Slash command executed"
            })
        },
        _ => {
            return JsonRpcResponse {
                jsonrpc: "2.0".to_string(),
                id: request.id,
                result: None,
                error: Some(JsonRpcError {
                    code: -32601,
                    message: "Method not found".to_string(),
                    data: None,
                }),
            };
        }
    };

    JsonRpcResponse {
        jsonrpc: "2.0".to_string(),
        id: request.id,
        result: Some(result),
        error: None,
    }
}
