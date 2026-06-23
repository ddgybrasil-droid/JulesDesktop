use tokio::io::{AsyncBufReadExt, BufReader};
use std::process::Stdio;
use crate::logger::TaskLogger;

/// Stub: Handles spawning and managing the Jules CLI process.

/// Stub function to start the CLI and stream its stdout back to Flutter
pub async fn stream_logs(task_id: &str) {
    let mut logger = TaskLogger::new(
        task_id,
        "logs",
        1024 * 1024, // 1MB max file size
        5,           // keep up to 5 log files
    ).await.expect("Failed to initialize logger");

    // Spawn the Jules CLI process
    let mut child = tokio::process::Command::new("jules")
        .arg("run")
        .arg(task_id)
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit()) // Inherit stderr instead of ignoring piped output
        .spawn()
        .expect("Failed to spawn CLI");

    let stdout = child.stdout.take().expect("Failed to open stdout");
    let mut reader = BufReader::new(stdout).lines();

    // Stream lines back to flutter (stdout) and log to file
    while let Ok(Some(line)) = reader.next_line().await {
        println!("{}", line);
        if let Err(e) = logger.log(&line).await {
            eprintln!("Failed to write log to file: {}", e);
        }
    }

    if let Err(e) = child.wait().await {
        eprintln!("Failed to wait on child process: {}", e);
    }
}
