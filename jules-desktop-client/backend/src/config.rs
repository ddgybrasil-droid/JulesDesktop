use std::env;
use std::fmt;

/// Configuration management for the backend.
/// Reads from environment variables or a local .env file.
pub struct Config {
    pub proxy_url: String,
    pub proxy_token: String,
    pub port: u16,
    pub execution_timeout: u64,
}

impl fmt::Debug for Config {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("Config")
            .field("proxy_url", &self.proxy_url)
            .field("proxy_token", &"***REDACTED***")
            .field("port", &self.port)
            .field("execution_timeout", &self.execution_timeout)
            .finish()
    }
}

/// Loads configuration from environment variables or .env file.
pub fn load_config() -> Result<Config, String> {
    // Gracefully try to load .env file; it's okay if it doesn't exist
    // as variables might be provided via the system environment.
    let _ = dotenvy::dotenv();

    let proxy_url = env::var("PROXY_URL")
        .map_err(|_| "Missing required environment variable: PROXY_URL".to_string())?;

    let proxy_token = env::var("PROXY_TOKEN")
        .map_err(|_| "Missing required environment variable: PROXY_TOKEN".to_string())?;

    let port_str = env::var("PORT")
        .map_err(|_| "Missing required environment variable: PORT".to_string())?;
    let port: u16 = port_str
        .parse()
        .map_err(|_| format!("Invalid PORT value: {}", port_str))?;

    let timeout_str = env::var("EXECUTION_TIMEOUT")
        .map_err(|_| "Missing required environment variable: EXECUTION_TIMEOUT".to_string())?;
    let execution_timeout: u64 = timeout_str
        .parse()
        .map_err(|_| format!("Invalid EXECUTION_TIMEOUT value: {}", timeout_str))?;

    Ok(Config {
        proxy_url,
        proxy_token,
        port,
        execution_timeout,
    })
}
