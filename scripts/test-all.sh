#!/bin/bash

# Test all MCP servers in the monorepo

set -e

echo "Testing all MCP servers..."

# Test all servers in the servers directory
for server_dir in servers/*/; do
    if [ -d "$server_dir" ] && [ "$(basename "$server_dir")" != "shared" ]; then
        server_name=$(basename "$server_dir")
        echo "Testing $server_name MCP Server..."
        cd "$server_dir"
        
        if [ -f "go.mod" ]; then
            go test ./...
            echo "✓ $server_name MCP Server tests passed"
        elif [ -f "package.json" ]; then
            npm test
            echo "✓ $server_name MCP Server tests passed"
        elif [ -f "requirements.txt" ]; then
            python -m pytest
            echo "✓ $server_name MCP Server tests passed"
        else
            echo "⚠ No test configuration found for $server_name"
        fi
        cd ../..
    fi
done

echo "All tests completed!"
