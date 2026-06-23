# Jules.ai Desktop Client

This is a cross-platform desktop application serving as a GUI client for Jules.ai.

## Architecture
The application is structured into two main components:
- **Frontend (`/frontend`)**: A Flutter application providing the UI.
- **Backend (`/backend`)**: A Rust binary handling communication with the Jules.ai proxy and CLI.
- **Shared (`/shared`)**: Shared data models representing the data contract between frontend and backend.

Please see `ARCHITECTURE.md` for full architectural details.

## Development

Currently, this repository is a skeleton scaffold.
- Implement Flutter UI in `/frontend`
- Implement backend logic in `/backend`
