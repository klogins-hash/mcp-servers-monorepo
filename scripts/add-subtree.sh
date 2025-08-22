#!/bin/bash

# Add MCP server repository as Git subtree
# Usage: ./scripts/add-subtree.sh <repository-url> [server-name]

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <repository-url> [server-name]"
    echo "Example: $0 https://github.com/user/mcp-server-example my-server"
    exit 1
fi

REPO_URL="$1"
SERVER_NAME="$2"

# Extract server name from URL if not provided
if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME=$(basename "$REPO_URL" .git)
fi

echo "Adding MCP server as Git subtree..."
echo "Repository: $REPO_URL"
echo "Server name: $SERVER_NAME"
echo "Destination: servers/$SERVER_NAME"

# Check if working tree is clean
if ! git diff-index --quiet HEAD --; then
    echo "❌ Working tree has modifications. Please commit or stash changes first."
    exit 1
fi

# Add as subtree
echo "Adding subtree..."
git subtree add --prefix "servers/$SERVER_NAME" "$REPO_URL" main --squash

# Add as remote for easier updates
REMOTE_NAME="$SERVER_NAME"
echo "Adding remote: $REMOTE_NAME"
git remote add "$REMOTE_NAME" "$REPO_URL" 2>/dev/null || echo "Remote $REMOTE_NAME already exists"

# Auto-configure for Railway deployment
echo "Auto-configuring for Railway deployment..."

# Detect server type
SERVER_TYPE="unknown"
if [ -f "servers/$SERVER_NAME/package.json" ]; then
    SERVER_TYPE="nodejs"
elif [ -f "servers/$SERVER_NAME/go.mod" ]; then
    SERVER_TYPE="go"
elif [ -f "servers/$SERVER_NAME/requirements.txt" ] || [ -f "servers/$SERVER_NAME/main.py" ]; then
    SERVER_TYPE="python"
fi

echo "✓ $SERVER_TYPE-based MCP server detected"

# Add railway.json if it doesn't exist
if [ ! -f "servers/$SERVER_NAME/railway.json" ]; then
    cat > "servers/$SERVER_NAME/railway.json" << 'EOF'
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
EOF
    echo "Added railway.json"
fi

# Add .env.example if it doesn't exist
if [ ! -f "servers/$SERVER_NAME/.env.example" ]; then
    cat > "servers/$SERVER_NAME/.env.example" << EOF
# $SERVER_NAME MCP Server Configuration
LOG_LEVEL=info
MCP_TRANSPORT=stdio

# For Railway deployment, set:
# MCP_TRANSPORT=http
# PORT will be set automatically by Railway

# Add your server-specific environment variables below:
EOF
    echo "Added .env.example template"
fi

# Add deployment instructions
cat > "servers/$SERVER_NAME/DEPLOY.md" << EOF
# Deploy $SERVER_NAME to Railway

This MCP server is configured for Railway deployment.

## Quick Deploy

\`\`\`bash
./scripts/deploy-railway.sh $SERVER_NAME
\`\`\`

## Manual Deploy

1. Install Railway CLI: \`npm install -g @railway/cli\`
2. Login: \`railway login\`
3. Deploy: \`cd servers/$SERVER_NAME && railway up\`

## Environment Variables

Copy \`.env.example\` to \`.env\` and configure:
- Set \`MCP_TRANSPORT=http\` for Railway
- Add any server-specific variables

## Updates

To pull latest changes from upstream:
\`\`\`bash
./scripts/update-subtree.sh $SERVER_NAME
\`\`\`
EOF

echo ""
echo "✅ Successfully added $SERVER_NAME MCP server as Git subtree!"
echo ""
echo "What was added:"
echo "- Git subtree with full history from $REPO_URL"
echo "- Remote '$REMOTE_NAME' for easy updates"
echo "- railway.json (Railway configuration)"
echo "- .env.example (Environment template)"
echo "- DEPLOY.md (Deployment instructions)"
echo ""
echo "Next steps:"
echo "1. Review the server in: servers/$SERVER_NAME"
echo "2. Configure environment variables in servers/$SERVER_NAME/.env.example"
echo "3. Deploy: ./scripts/deploy-railway.sh $SERVER_NAME"
echo "4. Update later: ./scripts/update-subtree.sh $SERVER_NAME"
echo ""
echo "The server maintains its connection to the original repository!"
