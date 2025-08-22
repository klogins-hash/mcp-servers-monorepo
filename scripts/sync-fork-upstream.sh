#!/bin/bash

# Sync fork with upstream official MCP server repository
# Usage: ./scripts/sync-fork-upstream.sh <server-name> <upstream-repo-url>

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <server-name> <upstream-repo-url>"
    echo "Example: $0 railway-mcp-server https://github.com/railwayapp/railway-mcp-server.git"
    echo ""
    echo "This script:"
    echo "1. Adds upstream remote to your fork"
    echo "2. Fetches latest changes from upstream"
    echo "3. Merges upstream changes into your fork"
    echo "4. Pushes updated fork to your GitHub"
    echo "5. Updates the subtree in this monorepo"
    exit 1
fi

SERVER_NAME="$1"
UPSTREAM_URL="$2"
SERVER_PATH="servers/$SERVER_NAME"

echo "🔄 Syncing fork with upstream for: $SERVER_NAME"
echo "Upstream: $UPSTREAM_URL"

# Check if server exists in monorepo
if [ ! -d "$SERVER_PATH" ]; then
    echo "❌ Server not found: $SERVER_PATH"
    echo "Available servers:"
    ls -1 servers/ | grep -v shared | sed 's/^/  - /'
    exit 1
fi

# Check if remote exists for the server
if ! git remote get-url "$SERVER_NAME" >/dev/null 2>&1; then
    echo "❌ Remote '$SERVER_NAME' not found."
    echo "Available remotes:"
    git remote -v | grep -v origin | sed 's/^/  - /'
    exit 1
fi

# Get the fork URL from existing remote
FORK_URL=$(git remote get-url "$SERVER_NAME")
echo "Fork: $FORK_URL"

# Create temporary directory to work with the fork
TEMP_DIR="/tmp/mcp-fork-sync-$SERVER_NAME-$$"
echo "📁 Creating temporary workspace: $TEMP_DIR"

git clone "$FORK_URL" "$TEMP_DIR"
cd "$TEMP_DIR"

# Add upstream remote if it doesn't exist
if ! git remote get-url upstream >/dev/null 2>&1; then
    echo "➕ Adding upstream remote: $UPSTREAM_URL"
    git remote add upstream "$UPSTREAM_URL"
else
    echo "✓ Upstream remote already exists"
fi

# Fetch from upstream
echo "📥 Fetching from upstream..."
git fetch upstream

# Get current branch (usually main or master)
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Check if upstream has the same branch
if git ls-remote --heads upstream | grep -q "refs/heads/$CURRENT_BRANCH"; then
    UPSTREAM_BRANCH="$CURRENT_BRANCH"
else
    # Try common alternatives
    if git ls-remote --heads upstream | grep -q "refs/heads/main"; then
        UPSTREAM_BRANCH="main"
    elif git ls-remote --heads upstream | grep -q "refs/heads/master"; then
        UPSTREAM_BRANCH="master"
    else
        echo "❌ Could not determine upstream branch"
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

echo "🔀 Merging upstream/$UPSTREAM_BRANCH into $CURRENT_BRANCH"

# Check if there are any changes to merge
BEHIND_COUNT=$(git rev-list --count HEAD..upstream/$UPSTREAM_BRANCH 2>/dev/null || echo "0")

if [ "$BEHIND_COUNT" = "0" ]; then
    echo "✅ Fork is already up to date with upstream"
else
    echo "📊 Fork is $BEHIND_COUNT commits behind upstream"
    
    # Merge upstream changes
    if git merge upstream/$UPSTREAM_BRANCH --no-edit; then
        echo "✅ Successfully merged upstream changes"
        
        # Push to fork
        echo "📤 Pushing updated fork to GitHub..."
        git push origin "$CURRENT_BRANCH"
        echo "✅ Fork updated on GitHub"
    else
        echo "❌ Merge conflicts detected. Please resolve manually:"
        echo "1. cd $TEMP_DIR"
        echo "2. Resolve conflicts"
        echo "3. git add . && git commit"
        echo "4. git push origin $CURRENT_BRANCH"
        echo "5. Run this script again"
        exit 1
    fi
fi

# Return to monorepo directory
cd - > /dev/null

# Update subtree in monorepo
echo "🔄 Updating subtree in monorepo..."
git fetch "$SERVER_NAME" "$CURRENT_BRANCH"
git subtree pull --prefix "$SERVER_PATH" "$SERVER_NAME" "$CURRENT_BRANCH" --squash

# Clean up
echo "🧹 Cleaning up temporary directory..."
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Successfully synced $SERVER_NAME with upstream!"
echo ""
echo "Summary:"
echo "- Fork synced with upstream: $UPSTREAM_URL"
echo "- Subtree updated in monorepo: $SERVER_PATH"
echo "- Ready for Railway deployment: ./scripts/deploy-railway.sh $SERVER_NAME"
