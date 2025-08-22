#!/bin/bash

# Simple script to prepare a copied/pasted MCP server repository
# Usage: ./scripts/copy-paste-repo.sh <server-directory-name>

set -e

SERVER_NAME=$1

if [ -z "$SERVER_NAME" ]; then
    echo "Usage: $0 <server-directory-name>"
    echo ""
    echo "After copying/pasting a repo into servers/, run:"
    echo "  $0 my-server-name"
    exit 1
fi

SERVER_DIR="servers/$SERVER_NAME"

if [ ! -d "$SERVER_DIR" ]; then
    echo "Error: Directory '$SERVER_DIR' not found"
    echo "Make sure you've copied your MCP server repo into the servers/ directory"
    exit 1
fi

echo "Setting up copied MCP server: $SERVER_NAME"

# Remove any existing .git directory
if [ -d "$SERVER_DIR/.git" ]; then
    echo "Removing .git directory..."
    rm -rf "$SERVER_DIR/.git"
fi

# Detect server type
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

# Add Railway configuration if missing
if [ ! -f "$SERVER_DIR/railway.json" ]; then
    echo "Adding Railway configuration..."
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

# Add environment template if missing
if [ ! -f "$SERVER_DIR/.env.example" ]; then
    echo "Adding environment template..."
    cat > "$SERVER_DIR/.env.example" << EOF
# $SERVER_NAME MCP Server Configuration
LOG_LEVEL=info
MCP_TRANSPORT=stdio

# For Railway deployment, set:
# MCP_TRANSPORT=http
# PORT will be set automatically by Railway

# Add your server-specific environment variables below:
EOF
fi

# Add deployment instructions
cat > "$SERVER_DIR/RAILWAY_DEPLOY.md" << EOF
# Railway Deployment for $SERVER_NAME

## Quick Deploy
\`\`\`bash
# From the monorepo root directory
./scripts/deploy-railway.sh $SERVER_NAME
\`\`\`

## Server Details
- **Type**: $SERVER_TYPE
- **Location**: \`$SERVER_DIR\`
- **Railway Config**: \`railway.json\`

## Environment Setup
1. Copy \`.env.example\` to \`.env\` for local development
2. Set environment variables in Railway dashboard for production
3. Ensure \`MCP_TRANSPORT=http\` for Railway deployment

## Local Testing
\`\`\`bash
cd $SERVER_DIR
EOF

# Add language-specific run instructions
case $SERVER_TYPE in
    go)
        echo "go run ." >> "$SERVER_DIR/RAILWAY_DEPLOY.md"
        ;;
    node)
        echo "npm install && npm start" >> "$SERVER_DIR/RAILWAY_DEPLOY.md"
        ;;
    python)
        echo "pip install -r requirements.txt && python main.py" >> "$SERVER_DIR/RAILWAY_DEPLOY.md"
        ;;
    *)
        echo "# Check the original README for run instructions" >> "$SERVER_DIR/RAILWAY_DEPLOY.md"
        ;;
esac

echo "\`\`\`" >> "$SERVER_DIR/RAILWAY_DEPLOY.md"

echo ""
echo "✅ $SERVER_NAME is now ready for Railway deployment!"
echo ""
echo "What was added:"
echo "- railway.json (Railway configuration)"
echo "- .env.example (Environment template)"
echo "- RAILWAY_DEPLOY.md (Deployment instructions)"
echo ""
echo "Next steps:"
echo "1. Review configuration in $SERVER_DIR"
echo "2. Test locally if needed"
echo "3. Deploy: ./scripts/deploy-railway.sh $SERVER_NAME"
