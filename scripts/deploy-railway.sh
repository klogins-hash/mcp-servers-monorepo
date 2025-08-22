#!/bin/bash

# Deploy individual MCP servers to Railway
# Usage: ./scripts/deploy-railway.sh [server-name] [project-name]

set -e

SERVER_NAME=$1
PROJECT_NAME=$2

if [ -z "$SERVER_NAME" ]; then
    echo "Usage: $0 <server-name> [project-name]"
    echo "Available servers:"
    ls -1 servers/ | grep -v shared
    exit 1
fi

if [ ! -d "servers/$SERVER_NAME" ]; then
    echo "Error: Server '$SERVER_NAME' not found in servers/ directory"
    exit 1
fi

echo "Deploying $SERVER_NAME MCP Server to Railway..."

# Set project name (default to server name)
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="mcp-$SERVER_NAME"
fi

# Create Railway project if it doesn't exist
echo "Creating/connecting to Railway project: $PROJECT_NAME"
railway login
railway link --project "$PROJECT_NAME" || railway create --name "$PROJECT_NAME"

# Set build arguments for the specific server
echo "Setting build configuration for $SERVER_NAME..."
railway variables set SERVER_NAME="$SERVER_NAME"

# Deploy using the Railway Dockerfile
echo "Deploying to Railway..."
railway up --dockerfile Dockerfile.railway

echo "✓ $SERVER_NAME MCP Server deployed successfully!"
echo "Project: $PROJECT_NAME"
echo "Check Railway dashboard for deployment status and URL"
