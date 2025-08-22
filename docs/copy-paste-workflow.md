# Copy-Paste Workflow for MCP Servers

The easiest way to add existing MCP server repositories to this monorepo.

## Method 1: Copy-Paste Existing Repository

### Step 1: Copy Repository
1. Download or clone your existing MCP server repository
2. Copy the entire folder into the `servers/` directory
3. Rename the folder to your desired server name

```bash
# Example: copying a downloaded repo
cp -r ~/Downloads/mcp-server-example servers/my-server

# Or clone directly into servers/
git clone https://github.com/user/mcp-server-example servers/my-server
```

### Step 2: Prepare for Monorepo
```bash
# Run the setup script
./scripts/copy-paste-repo.sh my-server
```

This automatically:
- Removes `.git` directory 
- Detects server type (Go/Node.js/Python)
- Adds `railway.json` for Railway deployment
- Creates `.env.example` template
- Generates deployment instructions

### Step 3: Deploy to Railway
```bash
./scripts/deploy-railway.sh my-server
```

## Method 2: Clone Repository Directly

### One Command Setup
```bash
# Clone and setup in one step
./scripts/add-repo.sh https://github.com/user/mcp-server-example [server-name]
```

This automatically:
- Clones the repository
- Removes `.git` directory
- Sets up Railway configuration
- Detects server type
- Creates deployment files

## What Gets Added

When you add a repository, these files are created if they don't exist:

### `railway.json`
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE", 
    "dockerfilePath": "../Dockerfile.railway"
  },
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
```

### `.env.example`
```bash
# Server Configuration
LOG_LEVEL=info
MCP_TRANSPORT=stdio

# For Railway deployment:
# MCP_TRANSPORT=http
# PORT will be set automatically by Railway
```

### `RAILWAY_DEPLOY.md`
Deployment instructions specific to your server.

## Supported Server Types

The monorepo automatically detects and supports:

- **Go servers**: Detected by `go.mod`
- **Node.js servers**: Detected by `package.json`  
- **Python servers**: Detected by `requirements.txt` or `main.py`
- **Universal**: Works with any structure

## Directory Structure After Adding

```
servers/
├── my-server/           # Your copied repository
│   ├── [original files] # All original server files
│   ├── railway.json     # Added: Railway config
│   ├── .env.example     # Added: Environment template
│   └── RAILWAY_DEPLOY.md # Added: Deploy instructions
└── shared/              # Shared utilities (optional to use)
```

## Railway Deployment

Each server deploys as a separate Railway service:

1. **Individual Projects**: Each server gets its own Railway project
2. **Isolated Deployment**: Servers deploy independently
3. **Universal Dockerfile**: One Dockerfile handles all server types
4. **Auto-Detection**: Automatically detects and runs Go/Node.js/Python servers

## Examples

### Adding Weaviate MCP Server
```bash
# Copy-paste method
cp -r ~/mcp-server-weaviate servers/weaviate
./scripts/copy-paste-repo.sh weaviate
./scripts/deploy-railway.sh weaviate

# Or clone method  
./scripts/add-repo.sh https://github.com/user/mcp-server-weaviate weaviate
./scripts/deploy-railway.sh weaviate
```

### Adding Multiple Servers
```bash
# Add several servers quickly
./scripts/add-repo.sh https://github.com/user/mcp-openai openai
./scripts/add-repo.sh https://github.com/user/mcp-postgres postgres  
./scripts/add-repo.sh https://github.com/user/mcp-redis redis

# Deploy them all
./scripts/deploy-railway.sh openai
./scripts/deploy-railway.sh postgres
./scripts/deploy-railway.sh redis
```

## Benefits

- **Zero Modification**: Original repositories work as-is
- **Railway Ready**: Automatic Railway deployment configuration
- **Type Detection**: Supports Go, Node.js, Python automatically
- **Independent Deployment**: Each server deploys separately
- **One Repository**: All servers organized in one place
- **Simple Workflow**: Copy, setup, deploy
