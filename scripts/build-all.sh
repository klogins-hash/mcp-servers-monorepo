#!/bin/bash

# Build all MCP servers in the monorepo

set -e

echo "Building all MCP servers..."

# Build Weaviate MCP Server
echo "Building Weaviate MCP Server..."
cd servers/weaviate
if [ -f "go.mod" ]; then
    go build -o ../../bin/weaviate-mcp .
    echo "✓ Weaviate MCP Server built successfully"
else
    echo "⚠ No go.mod found in weaviate server"
fi
cd ../..

# Add builds for other servers here
# Example:
# echo "Building Example MCP Server..."
# cd servers/example
# npm run build
# cd ../..

echo "All servers built successfully!"
echo "Binaries available in ./bin/"
