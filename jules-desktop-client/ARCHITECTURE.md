# Jules.ai Desktop Client Architecture

## High-Level Component Diagram

```text
+-----------------------------------------------------------+
|                      Jules Desktop App                    |
|                                                           |
|  +-----------------------+     +-----------------------+  |
|  |     Flutter Frontend  |     |      Rust Backend     |  |
|  |                       |     |                       |  |
|  |  +-----------------+  |     |  +-----------------+  |  |
|  |  |    UI Layer     |  |     |  |   IPC Listener  |  |  |
|  |  |  (Widgets/App)  |  |     |  |   (stdio json)  |  |  |
|  |  +--------+--------+  |     |  +--------+--------+  |  |
|  |           |           |     |           |           |  |
|  |  +--------v--------+  | IPC |  +--------v--------+  |  |
|  |  | State Providers |  |<--->|  |  Proxy Client   |  |  |
|  |  | (Task/Log Blocs)|  |     |  |  CLI Manager    |  |  |
|  |  +-----------------+  |     |  +-----------------+  |  |
|  +-----------------------+     +-----------------------+  |
+---------------------------------------------+-------------+
                                              | HTTPS / CLI Exec
                                              v
+-----------------------+             +-----------------------+
|  Cloudflare Workers   |             |   Local Jules CLI     |
|       Proxy           |             |    (Subprocess)       |
|                       |             |                       |
|   +---------------+   |             |   +---------------+   |
|   | Routing & Auth|   |             |   | stdout stream |   |
|   +-------+-------+   |             |   +---------------+   |
|           |           |             +-----------------------+
|           v           |
|    Jules.ai API       |
+-----------------------+
```

## Data Flow

1. **Frontend to API (Task Creation):**
   - User inputs task details in the Flutter UI.
   - Flutter `TaskProvider` sends a JSON-formatted command over `stdio` to the Rust process.
   - Rust `ipc.rs` parses the command and delegates it to `proxy_client.rs`.
   - `proxy_client.rs` formats an HTTP POST request (using `reqwest`) and sends it to the Cloudflare Worker proxy.
   - The Proxy handles regional bypassing and forwards the request to the Jules.ai API.
   - The response travels back: Proxy -> Rust `proxy_client` -> Rust `ipc` -> `stdio` -> Flutter `TaskProvider`.

2. **Backend to Frontend (CLI Execution Logs):**
   - Flutter requests to view logs for a task.
   - Rust `cli.rs` spawns the `jules run <task_id>` process.
   - The `stdout` stream of the CLI is read asynchronously line-by-line by Rust.
   - Each line is wrapped in a JSON IPC event and pushed over `stdout` back to Flutter.
   - Flutter `LogProvider` receives the event and appends it to the terminal UI (`ExecutionLog` widget).

## Error Handling Strategy

- **Flutter Frontend:** Will display user-friendly toast notifications or inline error messages. It expects a standard `error` field in the IPC response JSON.
- **Rust Backend:** Will utilize standard Rust `Result<T, E>` patterns. Errors communicating with the proxy or spawning the CLI will be logged and serialized into IPC error responses.
- **Proxy Client:** Network timeouts and non-200 HTTP status codes will be mapped to domain-specific Rust error types.

## IPC Protocol Definition

Communication occurs over standard input/output (`stdio`), with each message being a single-line JSON string (JSON-RPC style).

**Request Format (Flutter -> Rust):**
```json
{
  "id": "req-1234",
  "command": "send_task",
  "payload": {
    "prompt": "Fix bug #42",
    "repo": "user/repo",
    "branch": "main"
  }
}
```

**Response Format (Rust -> Flutter):**
```json
{
  "id": "req-1234",
  "success": true,
  "data": {
    "task_id": "dummy-task-id-456"
  },
  "error": null
}
```

**Event Format (Rust -> Flutter, e.g., Log Streaming):**
```json
{
  "event": "log_stream",
  "payload": {
    "task_id": "dummy-task-id-456",
    "line": "[INFO] Executing step 1..."
  }
}
```

## Deployment Considerations

- **Packaging:** The final artifact will bundle the compiled Rust binary alongside the Flutter desktop executable.
- **Platforms:**
  - **Windows:** Rust compiled to `.exe`, Flutter as a Win32 app.
  - **macOS:** Rust compiled as a universal binary (or architecture-specific), Flutter as a `.app` bundle.
  - **Linux:** Rust compiled as an ELF binary, Flutter utilizing GTK.
- **Process Management:** The Flutter desktop application is responsible for spawning the Rust backend binary as a child process upon startup and ensuring it is cleanly terminated when the app closes.
