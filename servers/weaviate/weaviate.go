package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/weaviate/weaviate-go-client/v4/weaviate"
	"github.com/weaviate/weaviate-go-client/v4/weaviate/auth"
	"github.com/weaviate/weaviate-go-client/v4/weaviate/graphql"
	"github.com/weaviate/weaviate/entities/models"
)

type WeaviateConnection struct {
	client *weaviate.Client
}

func NewWeaviateConnection() (*WeaviateConnection, error) {
	// Get configuration from environment variables
	host := os.Getenv("WEAVIATE_HOST")
	if host == "" {
		host = "localhost:8080" // fallback for local development
	}
	
	scheme := os.Getenv("WEAVIATE_SCHEME")
	if scheme == "" {
		scheme = "http"
	}
	
	config := weaviate.Config{
		Host:           host,
		Scheme:         scheme,
		StartupTimeout: 30 * time.Second,
	}
	
	// Add API key authentication if provided
	apiKey := os.Getenv("WEAVIATE_API_KEY")
	if apiKey != "" {
		config.AuthConfig = auth.ApiKey{Value: apiKey}
	}
	
	client, err := weaviate.NewClient(config)
	if err != nil {
		return nil, fmt.Errorf("connect to weaviate: %w", err)
	}
	return &WeaviateConnection{client}, nil
}

func (conn *WeaviateConnection) InsertOne(ctx context.Context,
	collection string, props interface{},
) (*models.Object, error) {
	obj := models.Object{
		Class:      collection,
		Properties: props,
	}
	// Use batch to leverage autoschema and gRPC
	resp, err := conn.batchInsert(ctx, &obj)
	if err != nil {
		return nil, fmt.Errorf("insert one object: %w", err)
	}

	return &resp[0].Object, err
}

func (conn *WeaviateConnection) Query(ctx context.Context, collection,
	query string, targetProps []string,
) (string, error) {
	hybrid := graphql.HybridArgumentBuilder{}
	hybrid.WithQuery(query)
	res, err := conn.client.GraphQL().Get().
		WithClassName(collection).WithHybrid(&hybrid).
		WithFields(func() []graphql.Field {
			fields := make([]graphql.Field, len(targetProps))
			for i, prop := range targetProps {
				fields[i] = graphql.Field{Name: prop}
			}
			return fields
		}()...).
		Do(context.Background())
	if err != nil {
		return "", err
	}
	b, err := json.Marshal(res)
	if err != nil {
		return "", fmt.Errorf("unmarshal query response: %w", err)
	}
	return string(b), nil
}

func (conn *WeaviateConnection) batchInsert(ctx context.Context, objs ...*models.Object) ([]models.ObjectsGetResponse, error) {
	resp, err := conn.client.Batch().ObjectsBatcher().WithObjects(objs...).Do(ctx)
	if err != nil {
		return nil, fmt.Errorf("make insertion request: %w", err)
	}
	for _, res := range resp {
		if res.Result != nil && res.Result.Errors != nil && res.Result.Errors.Error != nil {
			for _, nestedErr := range res.Result.Errors.Error {
				err = errors.Join(err, errors.New(nestedErr.Message))
			}
		}
	}

	return resp, err
}
