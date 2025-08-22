# Railway-optimized Dockerfile for MCP Server Weaviate
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git ca-certificates

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o mcp-server-weaviate .

# Final stage
FROM alpine:3.19

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/mcp-server-weaviate .

# Expose port for Railway
EXPOSE $PORT

# Run the binary
CMD ["./mcp-server-weaviate"]
