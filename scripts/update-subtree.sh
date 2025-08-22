#!/bin/bash

# Update MCP server subtree from upstream repository
# Usage: ./scripts/update-subtree.sh <server-name>

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <server-name>"
    echo "Example: $0 railway-mcp-server"
    exit 1
fi

SERVER_NAME="$1"
SERVER_PATH="servers/$SERVER_NAME"

echo "Updating MCP server subtree: $SERVER_NAME"

# Check if server exists
if [ ! -d "$SERVER_PATH" ]; then
    echo "❌ Server not found: $SERVER_PATH"
    echo "Available servers:"
    ls -1 servers/ | grep -v shared | sed 's/^/  - /'
    exit 1
fi

# Check if working tree is clean
if ! git diff-index --quiet HEAD --; then
    echo "❌ Working tree has modifications. Please commit or stash changes first."
    exit 1
fi

# Check if remote exists
if ! git remote get-url "$SERVER_NAME" >/dev/null 2>&1; then
    echo "❌ Remote '$SERVER_NAME' not found."
    echo "Available remotes:"
    git remote -v | grep -v origin | sed 's/^/  - /'
    exit 1
fi

echo "Fetching latest changes from upstream..."
git fetch "$SERVER_NAME" main

echo "Updating subtree..."
git subtree pull --prefix "$SERVER_PATH" "$SERVER_NAME" main --squash

echo ""
echo "✅ Successfully updated $SERVER_NAME subtree!"
echo ""
echo "Changes pulled from upstream repository."
echo "The server maintains its connection to the original repository."
