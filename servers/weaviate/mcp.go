package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

type MCPServer struct {
	server            *server.MCPServer
	weaviateConn      *WeaviateConnection
	defaultCollection string
}

func NewMCPServer() (*MCPServer, error) {
	conn, err := NewWeaviateConnection()
	if err != nil {
		return nil, err
	}
	
	// Get default collection from environment
	defaultCollection := os.Getenv("DEFAULT_COLLECTION")
	if defaultCollection == "" {
		defaultCollection = "DefaultCollection"
	}
	
	s := &MCPServer{
		server: server.NewMCPServer(
			"Weaviate MCP Server",
			"0.1.0",
			server.WithToolCapabilities(true),
			server.WithPromptCapabilities(true),
			server.WithResourceCapabilities(true, true),
			server.WithRecovery(),
		),
		weaviateConn:      conn,
		defaultCollection: defaultCollection,
	}
	s.registerTools()
	return s, nil
}

func (s *MCPServer) Serve() {
	// Check if we should serve over HTTP (for Railway) or stdio (for local MCP)
	transport := os.Getenv("MCP_TRANSPORT")
	port := os.Getenv("PORT")
	
	if transport == "http" && port != "" {
		// HTTP transport for Railway deployment
		log.Printf("Starting MCP server on HTTP port %s", port)
		http.HandleFunc("/mcp", func(w http.ResponseWriter, r *http.Request) {
			// Handle MCP over HTTP here
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			fmt.Fprintf(w, `{"status": "MCP Server Running", "version": "0.1.0"}`)
		})
		log.Fatal(http.ListenAndServe(":"+port, nil))
	} else {
		// Default stdio transport for local MCP usage
		server.ServeStdio(s.server)
	}
}

func (s *MCPServer) registerTools() {
	insertOne := mcp.NewTool(
		"weaviate-insert-one",
		mcp.WithString(
			"collection",
			mcp.Description("Name of the target collection"),
		),
		mcp.WithObject(
			"properties",
			mcp.Description("Object properties to insert"),
			mcp.Required(),
		),
	)
	query := mcp.NewTool(
		"weaviate-query",
		mcp.WithString(
			"query",
			mcp.Description("Query data within Weaviate"),
			mcp.Required(),
		),
		mcp.WithArray(
			"targetProperties",
			mcp.Description("Properties to return with the query"),
			mcp.Required(),
		),
	)

	s.server.AddTools(
		server.ServerTool{Tool: insertOne, Handler: s.weaviateInsertOne},
		server.ServerTool{Tool: query, Handler: s.weaviateQuery},
	)
}

func (s *MCPServer) weaviateInsertOne(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	targetCol := s.parseTargetCollection(req)
	props := req.Params.Arguments["properties"].(map[string]interface{})

	res, err := s.weaviateConn.InsertOne(context.Background(), targetCol, props)
	if err != nil {
		return mcp.NewToolResultErrorFromErr("failed to insert object", err), nil
	}
	return mcp.NewToolResultText(res.ID.String()), nil
}

func (s *MCPServer) weaviateQuery(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	targetCol := s.parseTargetCollection(req)
	query := req.Params.Arguments["query"].(string)
	// TODO: how to enforce `Required` within the sdk so we don't have to validate here
	props := req.Params.Arguments["targetProperties"].([]interface{})
	var targetProps []string
	{
		for _, prop := range props {
			typed, ok := prop.(string)
			if !ok {
				return mcp.NewToolResultError("targetProperties must contain only strings"), nil
			}
			targetProps = append(targetProps, typed)
		}
	}
	res, err := s.weaviateConn.Query(context.Background(), targetCol, query, targetProps)
	if err != nil {
		return mcp.NewToolResultErrorFromErr("failed to process query", err), nil
	}
	return mcp.NewToolResultText(res), nil
}

func (s *MCPServer) parseTargetCollection(req mcp.CallToolRequest) string {
	var (
		targetCol = s.defaultCollection
	)
	col, ok := req.Params.Arguments["collection"].(string)
	if ok {
		targetCol = col
	}
	return targetCol
}
