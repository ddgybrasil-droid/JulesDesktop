use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Debug)]
pub enum ProxyError {
    RequestError(reqwest::Error),
    ApiError(String),
}

impl std::fmt::Display for ProxyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ProxyError::RequestError(err) => write!(f, "Request error: {}", err),
            ProxyError::ApiError(msg) => write!(f, "API error: {}", msg),
        }
    }
}

impl std::error::Error for ProxyError {}

impl From<reqwest::Error> for ProxyError {
    fn from(error: reqwest::Error) -> Self {
        ProxyError::RequestError(error)
    }
}

#[derive(Serialize, Deserialize, Debug)]
pub struct TaskRequest {
    pub prompt: String,
    pub repo: String,
    pub branch: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct TaskResponse {
    pub task_id: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct StatusResponse {
    pub status: String,
    pub details: Option<Value>,
}

pub struct ProxyClient {
    client: reqwest::Client,
    base_url: String,
}

impl ProxyClient {
    pub fn new(base_url: String) -> Self {
        Self {
            client: reqwest::Client::new(),
            base_url,
        }
    }

    pub async fn post_task(&self, payload: TaskRequest) -> Result<String, ProxyError> {
        let url = format!("{}/task", self.base_url);
        let response = self.client.post(&url).json(&payload).send().await?;

        if response.status().is_success() {
            let task_res: TaskResponse = response.json().await?;
            Ok(task_res.task_id)
        } else {
            Err(ProxyError::ApiError(format!("Failed to post task. Status code: {}", response.status())))
        }
    }

    pub async fn get_status(&self, task_id: &str) -> Result<StatusResponse, ProxyError> {
        let url = format!("{}/status/{}", self.base_url, task_id);
        let response = self.client.get(&url).send().await?;

        if response.status().is_success() {
            let status_res: StatusResponse = response.json().await?;
            Ok(status_res)
        } else {
            Err(ProxyError::ApiError(format!("Failed to get status. Status code: {}", response.status())))
        }
    }
}

// Temporary stubs for ipc.rs to not break
pub async fn post_task(_payload: Value) -> Result<String, String> {
    Ok("dummy-task-id-456".to_string())
}

pub async fn get_status(_task_id: &str) -> Result<Value, String> {
    Ok(serde_json::json!({
        "status": "In Testing"
    }))
}

#[cfg(test)]
mod tests {
    use super::*;
    use wiremock::{MockServer, Mock, ResponseTemplate};
    use wiremock::matchers::{method, path};
    use serde_json::json;

    #[tokio::test]
    async fn test_post_task_success() {
        let mock_server = MockServer::start().await;
        let mock_task_id = "test-task-123";

        Mock::given(method("POST"))
            .and(path("/task"))
            .respond_with(ResponseTemplate::new(200).set_body_json(json!({
                "task_id": mock_task_id
            })))
            .mount(&mock_server)
            .await;

        let client = ProxyClient::new(mock_server.uri());
        let request = TaskRequest {
            prompt: "Fix bug".to_string(),
            repo: "org/repo".to_string(),
            branch: "main".to_string(),
        };

        let result = client.post_task(request).await.unwrap();
        assert_eq!(result, mock_task_id);
    }

    #[tokio::test]
    async fn test_post_task_failure() {
        let mock_server = MockServer::start().await;

        Mock::given(method("POST"))
            .and(path("/task"))
            .respond_with(ResponseTemplate::new(500))
            .mount(&mock_server)
            .await;

        let client = ProxyClient::new(mock_server.uri());
        let request = TaskRequest {
            prompt: "Fix bug".to_string(),
            repo: "org/repo".to_string(),
            branch: "main".to_string(),
        };

        let result = client.post_task(request).await;
        assert!(result.is_err());
        match result.unwrap_err() {
            ProxyError::ApiError(msg) => assert!(msg.contains("Status code: 500")),
            _ => panic!("Expected ApiError"),
        }
    }

    #[tokio::test]
    async fn test_get_status_success() {
        let mock_server = MockServer::start().await;
        let mock_task_id = "test-task-123";

        Mock::given(method("GET"))
            .and(path(format!("/status/{}", mock_task_id)))
            .respond_with(ResponseTemplate::new(200).set_body_json(json!({
                "status": "In Progress",
                "details": null
            })))
            .mount(&mock_server)
            .await;

        let client = ProxyClient::new(mock_server.uri());

        let result = client.get_status(mock_task_id).await.unwrap();
        assert_eq!(result.status, "In Progress");
    }

    #[tokio::test]
    async fn test_get_status_failure() {
        let mock_server = MockServer::start().await;
        let mock_task_id = "test-task-123";

        Mock::given(method("GET"))
            .and(path(format!("/status/{}", mock_task_id)))
            .respond_with(ResponseTemplate::new(404))
            .mount(&mock_server)
            .await;

        let client = ProxyClient::new(mock_server.uri());

        let result = client.get_status(mock_task_id).await;
        assert!(result.is_err());
        match result.unwrap_err() {
            ProxyError::ApiError(msg) => assert!(msg.contains("Status code: 404")),
            _ => panic!("Expected ApiError"),
        }
    }
}
