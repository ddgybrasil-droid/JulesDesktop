mod cli;
mod config;
mod ipc;
mod proxy_client;

use std::process;

#[tokio::main]
async fn main() {
    // Initialize configuration, gracefully exiting if there's an error
    let config = match config::load_config() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Failed to load configuration: {}", e);
            process::exit(1);
        }
    };

    // Stub: Start the stdio IPC listener loop
    // This will read messages from Flutter over stdin,
    // process them, and write responses/events to stdout.
    eprintln!("Starting Jules backend IPC listener with config: {:?}", config);

    // Example: ipc::start_listener(config).await;
}
