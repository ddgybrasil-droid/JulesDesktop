use tokio::fs::{self, File, OpenOptions};
use tokio::io::AsyncWriteExt;
use std::path::{Path, PathBuf};
use std::io;

pub struct TaskLogger {
    task_id: String,
    log_dir: PathBuf,
    max_size: u64,
    max_files: usize,
    current_size: u64,
    file: Option<File>,
}

impl TaskLogger {
    pub async fn new(task_id: &str, log_dir: impl AsRef<Path>, max_size: u64, max_files: usize) -> io::Result<Self> {
        let log_dir = log_dir.as_ref().to_path_buf();
        fs::create_dir_all(&log_dir).await?;

        let mut logger = Self {
            task_id: task_id.to_string(),
            log_dir,
            max_size,
            max_files,
            current_size: 0,
            file: None,
        };
        logger.init().await?;
        Ok(logger)
    }

    async fn init(&mut self) -> io::Result<()> {
        let log_file = self.log_dir.join(format!("{}.log", self.task_id));
        if let Ok(metadata) = fs::metadata(&log_file).await {
            self.current_size = metadata.len();
        }

        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&log_file)
            .await?;

        self.file = Some(file);
        Ok(())
    }

    pub async fn log(&mut self, message: &str) -> io::Result<()> {
        let message_bytes = message.as_bytes();
        let message_len = message_bytes.len() as u64;

        if self.current_size + message_len + 1 > self.max_size {
            self.rotate().await?;
        }

        if let Some(file) = &mut self.file {
            file.write_all(message_bytes).await?;
            file.write_all(b"\n").await?;
            file.flush().await?;
            self.current_size += message_len + 1;
        }

        Ok(())
    }

    async fn rotate(&mut self) -> io::Result<()> {
        // Close current file
        self.file = None;

        if self.max_files == 0 {
            let current = self.log_dir.join(format!("{}.log", self.task_id));
            if fs::metadata(&current).await.is_ok() {
                fs::remove_file(&current).await?;
            }
            self.current_size = 0;
            self.init().await?;
            return Ok(());
        }

        // Shift existing rotated files
        for i in (1..self.max_files).rev() {
            let old = self.log_dir.join(format!("{}.{}.log", self.task_id, i));
            let new = self.log_dir.join(format!("{}.{}.log", self.task_id, i + 1));
            if fs::metadata(&old).await.is_ok() {
                if i + 1 >= self.max_files {
                    // remove if it exceeds max files
                    fs::remove_file(&old).await?;
                } else {
                    fs::rename(&old, &new).await?;
                }
            }
        }

        // Rotate the main log file
        let current = self.log_dir.join(format!("{}.log", self.task_id));
        if self.max_files > 1 {
            let rotated = self.log_dir.join(format!("{}.1.log", self.task_id));
            if fs::metadata(&current).await.is_ok() {
                fs::rename(&current, &rotated).await?;
            }
        } else {
            // max_files == 1, just delete the current log
            if fs::metadata(&current).await.is_ok() {
                fs::remove_file(&current).await?;
            }
        }

        self.current_size = 0;

        // Re-open new log file
        self.init().await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::fs;
    use tempfile::tempdir;

    #[tokio::test]
    async fn test_logger_rotation() {
        let dir = tempdir().unwrap();
        let task_id = "test_task";
        let max_size = 20; // very small size to trigger rotation quickly
        let max_files = 3;

        let mut logger = TaskLogger::new(task_id, dir.path(), max_size, max_files)
            .await
            .unwrap();

        // Write first message
        logger.log("1234567890").await.unwrap(); // 10 bytes + newline = 11 bytes

        let current_log = dir.path().join("test_task.log");
        assert!(fs::metadata(&current_log).await.is_ok());

        // Write second message, should trigger rotation (11 + 11 = 22 > 20)
        logger.log("0987654321").await.unwrap();

        let rotated_log = dir.path().join("test_task.1.log");
        assert!(fs::metadata(&rotated_log).await.is_ok());
        assert!(fs::metadata(&current_log).await.is_ok());

        // Write third message, should trigger rotation again
        logger.log("abcdefghij").await.unwrap();

        let rotated_log_2 = dir.path().join("test_task.2.log");
        assert!(fs::metadata(&rotated_log_2).await.is_ok());
    }
}
