# Adding a New MCP Server

This guide explains how to add a new MCP server to the monorepo.

## Step 1: Create Server Directory

```bash
mkdir servers/your-server-name
cd servers/your-server-name
```

## Step 2: Initialize Your Server

### For Go Servers
```bash
go mod init github.com/klogins-hash/mcp-servers-monorepo/servers/your-server-name
```

### For Node.js Servers
```bash
npm init -y
```

### For Python Servers
```bash
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

## Step 3: Add Server Implementation

Create your MCP server implementation following the MCP protocol specification.

### Required Files
- `main.go` / `index.js` / `main.py` - Entry point
- `Dockerfile` - For containerization
- `railway.json` - For Railway deployment (optional)
- `README.md` - Server-specific documentation

## Step 4: Use Shared Utilities

Import shared utilities from the `servers/shared` package:

```go
import "github.com/klogins-hash/mcp-servers-monorepo/servers/shared"

// Use shared authentication
auth := shared.NewAuthConfig("YOUR_SERVER")

// Use shared logging
logger := shared.NewLoggerFromEnv("LOG_LEVEL")
```

## Step 5: Add Docker Configuration

Create a `Dockerfile` in your server directory:

```dockerfile
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o server .

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE $PORT
CMD ["./server"]
```

## Step 6: Update Root Configuration

### Add to docker-compose.yml
```yaml
your-server-mcp:
  build:
    context: ./servers/your-server-name
    dockerfile: Dockerfile
  ports:
    - "8082:8082"
  environment:
    - YOUR_SERVER_API_KEY=${YOUR_SERVER_API_KEY}
    - PORT=8082
  restart: unless-stopped
  networks:
    - mcp-network
```

### Add to .env.example
```bash
# Your Server Configuration
YOUR_SERVER_API_KEY=your-api-key
YOUR_SERVER_HOST=your-host.com
```

## Step 7: Update Build Scripts

Add your server to `scripts/build-all.sh`:

```bash
# Build Your Server
echo "Building Your Server..."
cd servers/your-server-name
go build -o ../../bin/your-server .
echo "✓ Your Server built successfully"
cd ../..
```

## Step 8: Add Documentation

Create `servers/your-server-name/README.md` with:
- Server description
- Installation instructions
- Configuration options
- Usage examples
- API endpoints

## Step 9: Test Your Server

```bash
# Test locally
cd servers/your-server-name
go run .

# Test with Docker
docker build -t your-server .
docker run -p 8082:8082 your-server

# Test with docker-compose
docker-compose up your-server-mcp
```

## Step 10: Update Root README

Add your server to the main README.md in the "Available Servers" section.

## Best Practices

1. **Use shared utilities** for common functionality
2. **Follow consistent naming** conventions
3. **Include comprehensive tests**
4. **Document environment variables**
5. **Support both stdio and HTTP transports**
6. **Include health check endpoints**
7. **Use structured logging**
8. **Handle graceful shutdowns**
