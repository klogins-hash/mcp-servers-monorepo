# MCP Servers Monorepo

A centralized repository for managing multiple Model Context Protocol (MCP) servers.

## Structure

```
mcp-servers-monorepo/
├── servers/
│   ├── shared/            # Shared utilities and libraries
│   └── [your-servers]/    # Your MCP servers go here
├── scripts/               # Build and deployment scripts
├── docs/                  # Documentation
├── docker-compose.yml     # Multi-server orchestration
└── README.md
```

## Available Servers

- **[Railway MCP Server](servers/railway-mcp-server/)** - Custom Railway MCP server for deployment management
- **[Filesystem Test](servers/filesystem-test/)** - Example filesystem MCP server for testing

## Quick Start - Add Any MCP Repository as Git Subtree

```bash
# Add MCP server as Git subtree (recommended)
./scripts/add-subtree.sh https://github.com/user/mcp-server-example my-server
./scripts/deploy-railway.sh my-server

# Update server from upstream later
./scripts/update-subtree.sh my-server
```

### Why Git Subtrees?
- **Maintains Git history** from original repositories
- **Easy updates** - pull latest changes from upstream
- **Can contribute back** to original repositories  
- **No extra files** - works like normal Git
- **Railway deployment** works exactly the same
- **Automated fork sync** - keeps your forks updated with official repos

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
