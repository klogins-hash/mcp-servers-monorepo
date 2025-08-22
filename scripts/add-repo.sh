#!/bin/bash

# Add an existing MCP server repository to the monorepo
# Usage: ./scripts/add-repo.sh <repo-url> [server-name]

set -e

REPO_URL=$1
SERVER_NAME=$2

if [ -z "$REPO_URL" ]; then
    echo "Usage: $0 <repo-url> [server-name]"
    echo "Examples:"
    echo "  $0 https://github.com/user/mcp-server-example"
    echo "  $0 https://github.com/user/mcp-server-example my-server"
    exit 1
fi

# Extract server name from repo URL if not provided
if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME=$(basename "$REPO_URL" .git)
    SERVER_NAME=${SERVER_NAME#mcp-server-}  # Remove mcp-server- prefix if present
    SERVER_NAME=${SERVER_NAME#mcp-}         # Remove mcp- prefix if present
fi

SERVER_DIR="servers/$SERVER_NAME"

if [ -d "$SERVER_DIR" ]; then
    echo "Error: Server '$SERVER_NAME' already exists in $SERVER_DIR"
    exit 1
fi

echo "Adding MCP server repository..."
echo "Repository: $REPO_URL"
echo "Server name: $SERVER_NAME"
echo "Destination: $SERVER_DIR"

# Clone the repository into the servers directory
echo "Cloning repository..."
git clone "$REPO_URL" "$SERVER_DIR"

# Remove the .git directory to integrate it into our monorepo
echo "Integrating into monorepo..."
rm -rf "$SERVER_DIR/.git"

# Check what type of server it is
echo "Detecting server type..."
if [ -f "$SERVER_DIR/go.mod" ]; then
    echo "✓ Go-based MCP server detected"
    SERVER_TYPE="go"
elif [ -f "$SERVER_DIR/package.json" ]; then
    echo "✓ Node.js-based MCP server detected"
    SERVER_TYPE="node"
elif [ -f "$SERVER_DIR/requirements.txt" ] || [ -f "$SERVER_DIR/main.py" ]; then
    echo "✓ Python-based MCP server detected"
    SERVER_TYPE="python"
else
    echo "⚠ Unknown server type - will attempt universal deployment"
    SERVER_TYPE="unknown"
fi

# Add Railway deployment files if they don't exist
if [ ! -f "$SERVER_DIR/railway.json" ]; then
    echo "Adding railway.json..."
    cat > "$SERVER_DIR/railway.json" << EOF
{
  "\$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "../Dockerfile.railway"
  },
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
EOF
fi

# Add .env.example if it doesn't exist
if [ ! -f "$SERVER_DIR/.env.example" ]; then
    echo "Adding .env.example template..."
    cat > "$SERVER_DIR/.env.example" << EOF
# $SERVER_NAME MCP Server Configuration
LOG_LEVEL=info
MCP_TRANSPORT=stdio

# Railway deployment (set MCP_TRANSPORT=http for Railway)
# MCP_TRANSPORT=http
# PORT will be set automatically by Railway

# Add your server-specific environment variables here
EOF
fi

# Create a simple deployment README
cat > "$SERVER_DIR/DEPLOY.md" << EOF
# Deploying $SERVER_NAME to Railway

## Quick Deploy
\`\`\`bash
# From the monorepo root
./scripts/deploy-railway.sh $SERVER_NAME
\`\`\`

## Manual Deploy
1. Create Railway project: \`railway create --name mcp-$SERVER_NAME\`
2. Set server name: \`railway variables set SERVER_NAME=$SERVER_NAME\`
3. Deploy: \`railway up --dockerfile ../Dockerfile.railway\`

## Environment Variables
Copy \`.env.example\` to \`.env\` and configure for local development.
Set environment variables in Railway dashboard for production.

## Server Type
Detected as: $SERVER_TYPE
EOF

echo ""
echo "✅ Successfully added $SERVER_NAME MCP server!"
echo ""
echo "Next steps:"
echo "1. Review the server in: $SERVER_DIR"
echo "2. Configure environment variables in $SERVER_DIR/.env.example"
echo "3. Test locally: cd $SERVER_DIR && [run command based on server type]"
echo "4. Deploy to Railway: ./scripts/deploy-railway.sh $SERVER_NAME"
echo ""
echo "The server is now part of your monorepo and ready for Railway deployment!"
