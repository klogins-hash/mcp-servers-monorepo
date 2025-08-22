#!/bin/bash

# Check for upstream updates across all MCP server subtrees
# Usage: ./scripts/check-upstream-updates.sh

set -e

echo "🔍 Checking for upstream updates across all MCP servers..."
echo ""

# Function to check if a server has upstream updates
check_server_updates() {
    local server_name="$1"
    local server_path="servers/$server_name"
    
    # Skip if not a directory or if it's shared
    if [ ! -d "$server_path" ] || [ "$server_name" = "shared" ]; then
        return
    fi
    
    # Check if remote exists
    if ! git remote get-url "$server_name" >/dev/null 2>&1; then
        echo "⚠️  $server_name: No remote configured"
        return
    fi
    
    echo "📡 Checking $server_name..."
    
    # Fetch latest from remote
    git fetch "$server_name" main 2>/dev/null || git fetch "$server_name" master 2>/dev/null || {
        echo "❌ $server_name: Failed to fetch from remote"
        return
    }
    
    # Get the current commit in subtree
    local current_commit=$(git log --grep="git-subtree-dir: $server_path" --pretty=format:"%H" -1 2>/dev/null)
    if [ -z "$current_commit" ]; then
        echo "⚠️  $server_name: Not a subtree or no subtree history found"
        return
    fi
    
    # Get the commit that was last pulled
    local last_subtree_commit=$(git log "$current_commit" --grep="git-subtree-split" --pretty=format:"%s" -1 2>/dev/null | grep -o '[a-f0-9]\{40\}' | head -1)
    
    if [ -z "$last_subtree_commit" ]; then
        echo "⚠️  $server_name: Could not determine last subtree commit"
        return
    fi
    
    # Check if remote has newer commits
    local remote_commit=$(git rev-parse "$server_name/main" 2>/dev/null || git rev-parse "$server_name/master" 2>/dev/null)
    
    if [ "$last_subtree_commit" = "$remote_commit" ]; then
        echo "✅ $server_name: Up to date"
    else
        # Count commits behind
        local behind_count=$(git rev-list --count "$last_subtree_commit..$remote_commit" 2>/dev/null || echo "unknown")
        echo "🔄 $server_name: $behind_count commits behind upstream"
        echo "   Update with: ./scripts/update-subtree.sh $server_name"
    fi
}

# Check all servers
for server in $(ls servers/ 2>/dev/null | grep -v shared || true); do
    check_server_updates "$server"
done

echo ""
echo "📋 Summary:"
echo "- Run './scripts/update-subtree.sh <server-name>' to update specific servers"
echo "- Run './scripts/sync-fork-upstream.sh <server-name> <upstream-url>' to sync forks with official repos"
echo "- Use GitHub Actions for automated updates (see .github/workflows/)"
