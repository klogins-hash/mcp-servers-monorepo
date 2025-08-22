package shared

import (
	"log"
	"os"
)

// Logger provides a shared logging interface for all MCP servers
type Logger struct {
	*log.Logger
	level LogLevel
}

// LogLevel represents different logging levels
type LogLevel int

const (
	DEBUG LogLevel = iota
	INFO
	WARN
	ERROR
)

// NewLogger creates a new logger with the specified level
func NewLogger(level LogLevel) *Logger {
	return &Logger{
		Logger: log.New(os.Stdout, "", log.LstdFlags),
		level:  level,
	}
}

// NewLoggerFromEnv creates a logger with level from environment variable
func NewLoggerFromEnv(envVar string) *Logger {
	levelStr := getEnvOrDefault(envVar, "INFO")
	level := parseLogLevel(levelStr)
	return NewLogger(level)
}

// Debug logs a debug message
func (l *Logger) Debug(v ...interface{}) {
	if l.level <= DEBUG {
		l.SetPrefix("[DEBUG] ")
		l.Println(v...)
	}
}

// Info logs an info message
func (l *Logger) Info(v ...interface{}) {
	if l.level <= INFO {
		l.SetPrefix("[INFO] ")
		l.Println(v...)
	}
}

// Warn logs a warning message
func (l *Logger) Warn(v ...interface{}) {
	if l.level <= WARN {
		l.SetPrefix("[WARN] ")
		l.Println(v...)
	}
}

// Error logs an error message
func (l *Logger) Error(v ...interface{}) {
	if l.level <= ERROR {
		l.SetPrefix("[ERROR] ")
		l.Println(v...)
	}
}

func parseLogLevel(level string) LogLevel {
	switch level {
	case "DEBUG":
		return DEBUG
	case "INFO":
		return INFO
	case "WARN":
		return WARN
	case "ERROR":
		return ERROR
	default:
		return INFO
	}
}
