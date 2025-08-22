package shared

import (
	"fmt"
	"os"
)

// AuthConfig holds authentication configuration
type AuthConfig struct {
	APIKey string
	Token  string
	Host   string
	Scheme string
}

// NewAuthConfig creates a new auth configuration from environment variables
func NewAuthConfig(prefix string) *AuthConfig {
	return &AuthConfig{
		APIKey: os.Getenv(prefix + "_API_KEY"),
		Token:  os.Getenv(prefix + "_TOKEN"),
		Host:   os.Getenv(prefix + "_HOST"),
		Scheme: getEnvOrDefault(prefix+"_SCHEME", "https"),
	}
}

// IsValid checks if the auth configuration is valid
func (a *AuthConfig) IsValid() bool {
	return a.APIKey != "" || a.Token != ""
}

// GetAuthHeader returns the appropriate authorization header
func (a *AuthConfig) GetAuthHeader() (string, string) {
	if a.APIKey != "" {
		return "Authorization", fmt.Sprintf("Bearer %s", a.APIKey)
	}
	if a.Token != "" {
		return "Authorization", fmt.Sprintf("Token %s", a.Token)
	}
	return "", ""
}

// GetBaseURL returns the base URL for API calls
func (a *AuthConfig) GetBaseURL() string {
	if a.Host == "" {
		return ""
	}
	return fmt.Sprintf("%s://%s", a.Scheme, a.Host)
}

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
