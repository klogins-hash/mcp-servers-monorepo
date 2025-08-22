# MCP Server Weaviate - Railway Deployment

This is a Railway-optimized version of the MCP Server for Weaviate that connects to Weaviate Cloud instances.

## Railway Deployment

### Environment Variables

Set these in your Railway project:

```bash
# Weaviate Cloud Configuration
WEAVIATE_HOST=your-cluster-id.weaviate.network
WEAVIATE_SCHEME=https
WEAVIATE_API_KEY=your-weaviate-api-key

# MCP Server Configuration
DEFAULT_COLLECTION=DefaultCollection
MCP_TRANSPORT=http

# Railway automatically sets PORT
```

### Quick Deploy

1. **Fork this repository**
2. **Connect to Railway**:
   - Link your GitHub repository to Railway
   - Railway will automatically detect the `railway.json` configuration

3. **Set Environment Variables**:
   - Go to your Railway project settings
   - Add the Weaviate Cloud credentials
   - Set `MCP_TRANSPORT=http` for Railway deployment

4. **Deploy**:
   - Push to your repository
   - Railway will automatically build and deploy

## Weaviate Cloud Setup

1. **Create a Weaviate Cloud cluster** at https://console.weaviate.cloud
2. **Get your credentials**:
   - Cluster URL (e.g., `https://your-cluster-id.weaviate.network`)
   - API Key from the cluster dashboard
3. **Set environment variables** in Railway with these values

## Local Development

For local MCP usage (without Railway):

```bash
# Don't set MCP_TRANSPORT or PORT - uses stdio by default
export WEAVIATE_HOST=your-cluster-id.weaviate.network
export WEAVIATE_SCHEME=https
export WEAVIATE_API_KEY=your-api-key

go run .
```

## API Endpoints

When deployed on Railway with `MCP_TRANSPORT=http`:

- `GET /mcp` - Health check and server info
- Server runs on Railway's assigned PORT

## Tools Available

- `weaviate-insert-one` - Insert objects into Weaviate collections
- `weaviate-query` - Query data using hybrid search

## Configuration

The server automatically configures itself based on environment variables:
- Uses Weaviate Cloud when `WEAVIATE_HOST` and `WEAVIATE_API_KEY` are set
- Falls back to localhost for local development
- Switches between HTTP (Railway) and stdio (local MCP) transport modes
