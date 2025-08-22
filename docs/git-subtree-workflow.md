# Git Subtree Workflow for MCP Servers

The monorepo now uses **Git Subtrees** to manage MCP server repositories. This is much better than copy-paste because it maintains the connection to original repositories.

## Benefits of Git Subtrees

- **Maintains Git history** from original repositories
- **Easy updates** - pull latest changes from upstream
- **No extra metadata files** (unlike Git submodules)
- **Simple for users** - just clone one repo and get everything
- **Can contribute back** to original repositories
- **Railway deployment** works exactly the same

## Adding MCP Servers

### Method 1: Add as Subtree (Recommended)
```bash
./scripts/add-subtree.sh https://github.com/user/mcp-server-example my-server
```

This automatically:
- Adds the repository as a Git subtree
- Creates a remote for easy updates
- Adds Railway deployment configuration
- Maintains connection to original repo

### Method 2: Quick Add
```bash
git subtree add --prefix servers/my-server https://github.com/user/mcp-server-example.git main --squash
git remote add my-server https://github.com/user/mcp-server-example.git
```

## Updating MCP Servers

When the original repository has updates:

```bash
./scripts/update-subtree.sh my-server
```

Or manually:
```bash
git fetch my-server main
git subtree pull --prefix servers/my-server my-server main --squash
```

## Railway Deployment

Deployment works exactly the same:
```bash
./scripts/deploy-railway.sh my-server
```

Each subtree gets auto-configured with:
- `railway.json` - Railway deployment config
- `.env.example` - Environment template
- `DEPLOY.md` - Deployment instructions

## Contributing Back Upstream

If you make improvements to a server, you can contribute back:

```bash
git subtree push --prefix servers/my-server my-server feature-branch
```

Then create a pull request in the original repository.

## Directory Structure

```
mcp-servers-monorepo/
├── servers/
│   ├── my-server/           # Git subtree from original repo
│   │   ├── [original files] # All files from original repository
│   │   ├── railway.json     # Added: Railway config
│   │   ├── .env.example     # Added: Environment template
│   │   └── DEPLOY.md        # Added: Deploy instructions
│   └── shared/              # Shared utilities
├── scripts/
│   ├── add-subtree.sh       # Add new subtree
│   ├── update-subtree.sh    # Update existing subtree
│   └── deploy-railway.sh    # Deploy to Railway
└── docs/
```

## Git Subtree vs Copy-Paste

| Feature | Copy-Paste | Git Subtree |
|---------|------------|-------------|
| Git history | ❌ Lost | ✅ Preserved |
| Updates | ❌ Manual | ✅ `git subtree pull` |
| Contribute back | ❌ Difficult | ✅ `git subtree push` |
| Repository size | ✅ Smaller | ⚠️ Larger (includes history) |
| Complexity | ✅ Simple | ⚠️ Learn subtree commands |

## Common Commands

### List all subtrees
```bash
git log --grep="git-subtree-dir" --pretty=format:"%s" | grep -o "servers/[^']*"
```

### Check subtree status
```bash
git remote -v | grep -v origin
```

### Remove a subtree
```bash
git rm -r servers/my-server
git remote remove my-server
git commit -m "Remove my-server subtree"
```

## Best Practices

1. **Always use `--squash`** to avoid cluttering history
2. **Add remotes** for easier update commands
3. **Keep working tree clean** before subtree operations
4. **Use descriptive commit messages** for subtree operations
5. **Test locally** before deploying subtree updates

## Migration from Copy-Paste

If you have existing copy-paste servers, convert them:

1. Remove the copied directory
2. Add as subtree: `./scripts/add-subtree.sh <original-repo-url> <server-name>`
3. The Railway configuration will be preserved/recreated

## Examples

### Add Official MCP Server
```bash
./scripts/add-subtree.sh https://github.com/modelcontextprotocol/servers.git official-servers
```

### Add Your Custom Server
```bash
./scripts/add-subtree.sh https://github.com/yourusername/my-mcp-server.git my-server
```

### Update All Servers
```bash
for server in $(ls servers/ | grep -v shared); do
    ./scripts/update-subtree.sh "$server"
done
```

### Deploy Multiple Servers
```bash
for server in $(ls servers/ | grep -v shared); do
    ./scripts/deploy-railway.sh "$server"
done
```

Git subtrees provide the perfect balance of simplicity and power for managing multiple MCP server repositories in a single monorepo.
