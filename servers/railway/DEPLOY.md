# Deploying railway to Railway

## Quick Deploy
```bash
# From the monorepo root
./scripts/deploy-railway.sh railway
```

## Manual Deploy
1. Create Railway project: `railway create --name mcp-railway`
2. Set server name: `railway variables set SERVER_NAME=railway`
3. Deploy: `railway up --dockerfile ../Dockerfile.railway`

## Environment Variables
Copy `.env.example` to `.env` and configure for local development.
Set environment variables in Railway dashboard for production.

## Server Type
Detected as: node
