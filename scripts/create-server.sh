#!/bin/bash

# Create a new MCP server with Railway deployment ready
# Usage: ./scripts/create-server.sh <server-name> [language]

set -e

SERVER_NAME=$1
LANGUAGE=${2:-go}

if [ -z "$SERVER_NAME" ]; then
    echo "Usage: $0 <server-name> [language]"
    echo "Languages: go, node, python"
    exit 1
fi

SERVER_DIR="servers/$SERVER_NAME"

if [ -d "$SERVER_DIR" ]; then
    echo "Error: Server '$SERVER_NAME' already exists"
    exit 1
fi

echo "Creating $SERVER_NAME MCP Server ($LANGUAGE)..."

# Create server directory
mkdir -p "$SERVER_DIR"

# Copy templates based on language
case $LANGUAGE in
    go)
        cp servers/shared/templates/Dockerfile.template "$SERVER_DIR/Dockerfile"
        cp servers/shared/templates/railway.json.template "$SERVER_DIR/railway.json"
        
        # Create basic Go files
        cat > "$SERVER_DIR/go.mod" << EOF
module github.com/klogins-hash/mcp-servers-monorepo/servers/$SERVER_NAME

go 1.23

require (
    github.com/mark3labs/mcp-go v0.1.0
    github.com/klogins-hash/mcp-servers-monorepo/servers/shared v0.0.0
)

replace github.com/klogins-hash/mcp-servers-monorepo/servers/shared => ../shared
EOF

        cat > "$SERVER_DIR/main.go" << EOF
package main

import (
    "context"
    "log"
    "os"

    "github.com/mark3labs/mcp-go/mcp"
    "github.com/mark3labs/mcp-go/server"
    "github.com/klogins-hash/mcp-servers-monorepo/servers/shared"
)

func main() {
    logger := shared.NewLoggerFromEnv("LOG_LEVEL")
    logger.Info("Starting $SERVER_NAME MCP Server...")

    mcpServer := server.NewMCPServer(
        "$SERVER_NAME MCP Server",
        "1.0.0",
        server.WithToolCapabilities(true),
        server.WithRecovery(),
    )

    // Add your tools here
    // mcpServer.AddTools(...)

    // Check transport mode
    transport := os.Getenv("MCP_TRANSPORT")
    port := os.Getenv("PORT")

    if transport == "http" && port != "" {
        logger.Info("Starting HTTP server on port", port)
        // Add HTTP server implementation
        select {} // Keep running
    } else {
        logger.Info("Starting stdio server")
        server.ServeStdio(mcpServer)
    }
}
EOF

        cat > "$SERVER_DIR/.env.example" << EOF
# $SERVER_NAME MCP Server Configuration
LOG_LEVEL=info
MCP_TRANSPORT=stdio

# Add your server-specific environment variables here
# API_KEY=your-api-key
# HOST=your-host.com
EOF
        ;;
    
    node)
        echo "Node.js template not implemented yet"
        exit 1
        ;;
    
    python)
        echo "Python template not implemented yet"
        exit 1
        ;;
    
    *)
        echo "Unsupported language: $LANGUAGE"
        exit 1
        ;;
esac

# Create README
cat > "$SERVER_DIR/README.md" << EOF
# $SERVER_NAME MCP Server

Description of your MCP server.

## Features

- Feature 1
- Feature 2

## Configuration

Copy \`.env.example\` to \`.env\` and configure:

\`\`\`bash
cp .env.example .env
\`\`\`

## Local Development

\`\`\`bash
go run .
\`\`\`

## Railway Deployment

\`\`\`bash
# From the monorepo root
./scripts/deploy-railway.sh $SERVER_NAME
\`\`\`

## Tools

- \`tool-name\` - Tool description
EOF

echo "✓ $SERVER_NAME MCP Server created successfully!"
echo "Location: $SERVER_DIR"
echo ""
echo "Next steps:"
echo "1. cd $SERVER_DIR"
echo "2. Implement your MCP tools in main.go"
echo "3. Test locally: go run ."
echo "4. Deploy to Railway: ../scripts/deploy-railway.sh $SERVER_NAME"
