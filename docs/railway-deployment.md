# Railway Deployment Guide

This monorepo is optimized for Railway deployment where each MCP server can be deployed as a separate service.

## Deployment Options

### Option 1: Individual Server Deployment (Recommended)

Deploy each MCP server as a separate Railway service:

```bash
# Deploy a specific server
./scripts/deploy-railway.sh server-name [project-name]
```

### Option 2: Manual Railway Setup

1. **Create Railway Project**:
   ```bash
   railway create --name mcp-server-name
   ```

2. **Set Build Variables**:
   ```bash
   railway variables set SERVER_NAME=your-server-name
   ```

3. **Deploy**:
   ```bash
   railway up --dockerfile Dockerfile.railway
   ```

## How It Works

### Multi-Stage Dockerfile
The root `Dockerfile.railway` uses build arguments to deploy specific servers:
- Copies shared utilities
- Copies only the specified server code
- Builds and deploys that single server

### Build Arguments
- `SERVER_NAME`: Specifies which server to build (e.g., "weaviate", "openai")

## Creating New Servers

### Quick Start
```bash
# Create a new Go-based MCP server
./scripts/create-server.sh my-server go

# Deploy to Railway
./scripts/deploy-railway.sh my-server
```

### Manual Creation
1. Create directory: `servers/my-server/`
2. Add `Dockerfile`, `railway.json`, and server code
3. Use shared utilities from `servers/shared/`

## Server Structure

Each server should have:
```
servers/my-server/
├── Dockerfile          # Individual deployment
├── railway.json        # Railway configuration
├── main.go            # Server implementation
├── go.mod             # Dependencies
├── .env.example       # Environment template
└── README.md          # Server documentation
```

## Environment Variables

### Per-Server Variables
Set in Railway dashboard for each service:
- `MCP_TRANSPORT=http` (for Railway)
- `LOG_LEVEL=info`
- Server-specific API keys and configuration

### Railway Auto-Variables
- `PORT` - Automatically set by Railway
- `RAILWAY_ENVIRONMENT` - Environment name

## Best Practices

1. **Separate Services**: Deploy each MCP server as its own Railway service
2. **Shared Code**: Use `servers/shared/` for common utilities
3. **Environment Config**: Use environment variables for all configuration
4. **Health Checks**: Implement health endpoints for Railway
5. **Logging**: Use structured logging from shared utilities

## Deployment Commands

```bash
# List available servers
ls servers/ | grep -v shared

# Create new server
./scripts/create-server.sh server-name go

# Deploy to Railway
./scripts/deploy-railway.sh server-name

# Build all servers locally
./scripts/build-all.sh

# Test all servers
./scripts/test-all.sh
```

## Railway Project Organization

Recommended naming convention:
- Project: `mcp-server-name`
- Service: `server-name-mcp`
- URL: `server-name-mcp.railway.app`

## Monitoring

Each deployed service will have:
- Individual Railway dashboard
- Separate logs and metrics
- Independent scaling and configuration
- Unique deployment URLs

## Troubleshooting

### Build Failures
- Check `SERVER_NAME` environment variable is set
- Verify server directory exists in `servers/`
- Ensure Dockerfile and railway.json are present

### Runtime Issues
- Check Railway logs for the specific service
- Verify environment variables are set correctly
- Ensure PORT environment variable is used for HTTP binding
