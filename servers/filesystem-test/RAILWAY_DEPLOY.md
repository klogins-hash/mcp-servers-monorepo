# Railway Deployment for filesystem-test

## Quick Deploy
```bash
# From the monorepo root directory
./scripts/deploy-railway.sh filesystem-test
```

## Server Details
- **Type**: node
- **Location**: `servers/filesystem-test`
- **Railway Config**: `railway.json`

## Environment Setup
1. Copy `.env.example` to `.env` for local development
2. Set environment variables in Railway dashboard for production
3. Ensure `MCP_TRANSPORT=http` for Railway deployment

## Local Testing
```bash
cd servers/filesystem-test
npm install && npm start
```
