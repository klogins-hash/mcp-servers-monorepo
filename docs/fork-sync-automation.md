# Fork Sync Automation for MCP Servers

This monorepo includes automation to keep your forked MCP servers in sync with their official upstream repositories.

## Overview

When you fork official MCP servers and add them as subtrees, this automation helps you:
- **Automatically sync forks** with upstream official repositories
- **Create pull requests** with upstream changes
- **Check for updates** across all servers
- **Maintain Railway deployment** compatibility

## Automation Components

### 1. Manual Fork Sync Script

Sync a specific fork with its upstream:

```bash
./scripts/sync-fork-upstream.sh railway-mcp-server https://github.com/railwayapp/railway-mcp-server.git
```

This script:
1. Clones your fork to a temporary directory
2. Adds the official repo as upstream remote
3. Fetches and merges upstream changes
4. Pushes updated fork to your GitHub
5. Updates the subtree in your monorepo

### 2. Update Checker Script

Check all servers for available upstream updates:

```bash
./scripts/check-upstream-updates.sh
```

Shows which servers have updates available and how many commits they're behind.

### 3. GitHub Actions Automation

**File:** `.github/workflows/sync-upstream.yml`

**Triggers:**
- **Daily at 2 AM UTC** (automatic)
- **Manual dispatch** (on-demand)

**What it does:**
1. Checks all servers for upstream updates
2. Syncs forks with their official repositories
3. Updates subtrees in the monorepo
4. Creates pull requests for review

## Setup Instructions

### 1. Configure GitHub Token

For the automation to work, you need a Personal Access Token:

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create a token with `repo` and `workflow` permissions
3. Add it as a repository secret named `PAT_TOKEN`

### 2. Configure Server Mappings

Edit `.github/workflows/sync-upstream.yml` to add your server mappings:

```yaml
case "$server" in
  "your-server-name")
    echo "upstream_url=https://github.com/official/repo.git" >> $GITHUB_OUTPUT
    ;;
  # Add more mappings here
esac
```

### 3. Enable GitHub Actions

1. Go to your repository → Actions tab
2. Enable workflows if they're disabled
3. The sync workflow will run automatically

## Workflow Examples

### Adding a Fork as Subtree

```bash
# 1. Fork the official repository on GitHub
# 2. Add your fork as subtree
./scripts/add-subtree.sh https://github.com/yourusername/forked-mcp-server.git my-server

# 3. Configure upstream mapping in GitHub Actions workflow
# 4. Automation will keep it synced
```

### Manual Sync Process

```bash
# Check for updates
./scripts/check-upstream-updates.sh

# Sync specific server with upstream
./scripts/sync-fork-upstream.sh my-server https://github.com/official/mcp-server.git

# Deploy updated server
./scripts/deploy-railway.sh my-server
```

### Automated Sync Process

1. **Daily Check:** GitHub Actions runs automatically
2. **Update Detection:** Finds servers behind upstream
3. **Fork Sync:** Updates your forks with upstream changes
4. **Subtree Update:** Updates subtrees in monorepo
5. **Pull Request:** Creates PR for review
6. **Review & Merge:** You review and merge the PR
7. **Deploy:** Use Railway deployment as normal

## Supported Official Repositories

The automation includes built-in support for:

- **Railway MCP Server:** `railwayapp/railway-mcp-server`
- **VAPI MCP Server:** `VapiAI/mcp-server`
- **Weaviate MCP Server:** `weaviate/mcp-server-weaviate`
- **Filesystem MCP Server:** `modelcontextprotocol/servers`

Add more mappings in the GitHub Actions workflow as needed.

## Benefits

### For Fork Management
- **Stay Current:** Always have latest upstream features
- **Conflict Resolution:** Automated merge with conflict detection
- **History Preservation:** Maintains full Git history

### For Monorepo
- **Centralized Updates:** All servers updated from one place
- **Review Process:** Pull requests for all changes
- **Railway Ready:** Maintains deployment compatibility

### For Development
- **Contribute Back:** Easy to contribute improvements upstream
- **Track Changes:** See exactly what changed in each update
- **Rollback Capability:** Git history allows easy rollbacks

## Troubleshooting

### Merge Conflicts

If the automation encounters merge conflicts:

1. Check the failed GitHub Action
2. Run manual sync: `./scripts/sync-fork-upstream.sh server-name upstream-url`
3. Resolve conflicts in the temporary directory
4. Complete the merge and push

### Missing Upstream Mapping

Add your server to the GitHub Actions workflow:

```yaml
"your-server-name")
  echo "upstream_url=https://github.com/official/repo.git" >> $GITHUB_OUTPUT
  ;;
```

### Permission Issues

Ensure your `PAT_TOKEN` has sufficient permissions:
- `repo` - Full repository access
- `workflow` - Update GitHub Actions workflows

## Manual Commands Reference

```bash
# Check all servers for updates
./scripts/check-upstream-updates.sh

# Sync specific fork with upstream
./scripts/sync-fork-upstream.sh <server-name> <upstream-url>

# Update subtree from your fork
./scripts/update-subtree.sh <server-name>

# Deploy updated server
./scripts/deploy-railway.sh <server-name>

# Add new fork as subtree
./scripts/add-subtree.sh <your-fork-url> <server-name>
```

This automation ensures your MCP servers stay current with official developments while maintaining your customizations and Railway deployment setup.
