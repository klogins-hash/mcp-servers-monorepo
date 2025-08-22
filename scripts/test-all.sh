#!/bin/bash

# Test all MCP servers in the monorepo

set -e

echo "Testing all MCP servers..."

# Test Weaviate MCP Server
echo "Testing Weaviate MCP Server..."
cd servers/weaviate
if [ -f "go.mod" ]; then
    go test ./...
    echo "✓ Weaviate MCP Server tests passed"
else
    echo "⚠ No go.mod found in weaviate server"
fi
cd ../..

# Add tests for other servers here
# Example:
# echo "Testing Example MCP Server..."
# cd servers/example
# npm test
# cd ../..

echo "All tests completed!"
