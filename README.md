# MCP Servers Monorepo

A centralized repository for managing multiple Model Context Protocol (MCP) servers.

## Structure

```
mcp-servers-monorepo/
├── servers/
│   ├── weaviate/          # Weaviate MCP Server
│   ├── shared/            # Shared utilities and libraries
│   └── [future-servers]/  # Additional MCP servers
├── scripts/               # Build and deployment scripts
├── docs/                  # Documentation
├── docker-compose.yml     # Multi-server orchestration
└── README.md
```

## Available Servers

### Weaviate MCP Server
- **Location**: `servers/weaviate/`
- **Description**: MCP server for Weaviate vector database operations
- **Features**: Insert objects, query data, hybrid search
- **Deployment**: Railway-ready with Docker configuration

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Go 1.23+ (for Go-based servers)
- Node.js 18+ (for Node.js-based servers)
- Python 3.8+ (for Python-based servers)

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/klogins-hash/mcp-servers-monorepo.git
   cd mcp-servers-monorepo
   ```

2. **Run all servers**:
   ```bash
   docker-compose up
   ```

3. **Run individual server**:
   ```bash
   cd servers/weaviate
   go run .
   ```

## Development

### Adding a New MCP Server

1. Create a new directory in `servers/`:
   ```bash
   mkdir servers/your-server-name
   ```

2. Add your server implementation
3. Update the root `docker-compose.yml`
4. Add documentation to `docs/`

### Shared Components

Common utilities and libraries are stored in `servers/shared/`:
- Authentication helpers
- Configuration management
- Logging utilities
- Common MCP protocol handlers

## Deployment

### Individual Server Deployment
Each server can be deployed independently using its own configuration files.

### Multi-Server Deployment
Use the root `docker-compose.yml` to deploy multiple servers together.

### Railway Deployment
Servers with Railway configuration can be deployed individually to Railway platform.

## Scripts

- `scripts/build-all.sh` - Build all servers
- `scripts/test-all.sh` - Run tests for all servers
- `scripts/deploy.sh` - Deploy servers to various platforms

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your MCP server in the `servers/` directory
4. Update documentation
5. Submit a pull request

## License

MIT License
