#!/bin/bash

# Build all MCP servers in the monorepo

set -e

echo "Building all MCP servers..."

# Create bin directory if it doesn't exist
mkdir -p bin

# Build all servers in the servers directory
for server_dir in servers/*/; do
    if [ -d "$server_dir" ] && [ "$(basename "$server_dir")" != "shared" ]; then
        server_name=$(basename "$server_dir")
        echo "Building $server_name MCP Server..."
        cd "$server_dir"
        
        if [ -f "go.mod" ]; then
            go build -o "../../bin/$server_name-mcp" .
            echo "✓ $server_name MCP Server built successfully"
        elif [ -f "package.json" ]; then
            npm run build
            echo "✓ $server_name MCP Server built successfully"
        elif [ -f "requirements.txt" ]; then
            echo "⚠ Python server $server_name - manual build required"
        else
            echo "⚠ No build configuration found for $server_name"
        fi
        cd ../..
    fi
done

echo "All servers built successfully!"
echo "Binaries available in ./bin/"
