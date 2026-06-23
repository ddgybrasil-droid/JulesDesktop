/// Stub: Shared task model for Rust
/// Represents a task that is synchronized between frontend and backend.

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Task {
    pub id: String,
    pub prompt: String,
    pub repo: String,
    pub branch: String,
    pub status: TaskStatus,
}

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub enum TaskStatus {
    Queued,
    InTesting,
    ReadyForPr,
    Completed,
    Failed,
}
