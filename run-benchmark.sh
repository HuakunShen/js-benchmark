#!/bin/bash

# Script to run benchmarks on all server configurations
# Usage: ./run-benchmark.sh [duration] [connections] [threads]
# Default: 10s, 400 connections, 12 threads

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DURATION="${1:-10s}"
CONNECTIONS="${2:-400}"
THREADS="${3:-12}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if wrk is installed
if ! command -v wrk >/dev/null 2>&1; then
    echo -e "${RED}Error: wrk is not installed${NC}"
    echo "Install with: sudo apt-get install wrk (Ubuntu/Debian)"
    echo "              brew install wrk (macOS)"
    exit 1
fi

# Check if start-server.sh exists
if [ ! -f "$SCRIPT_DIR/start-server.sh" ]; then
    echo -e "${RED}Error: start-server.sh not found${NC}"
    exit 1
fi

# Servers to test
SERVERS=(
    "hono-bun"
    "hono-deno"
    "hono-node"
    "elysia-bun"
    "elysia-deno"
    "elysia-node"
)

# Function to kill process on port 3000
kill_server() {
    if command -v lsof >/dev/null 2>&1; then
        lsof -ti :3000 | xargs kill -9 2>/dev/null || true
    elif command -v fuser >/dev/null 2>&1; then
        fuser -k 3000/tcp 2>/dev/null || true
    elif command -v ss >/dev/null 2>&1; then
        ss -tlnp 2>/dev/null | grep ':3000 ' | grep -oP 'pid=\K[0-9]+' | xargs kill -9 2>/dev/null || true
    fi
    sleep 2
}

# Function to wait for server to be ready
wait_for_server() {
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:3000/ >/dev/null 2>&1; then
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    return 1
}

# Function to run benchmark
run_benchmark() {
    local server_name="$1"
    local endpoint="$2"
    local label="$3"
    
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}Testing: $server_name - $label${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Start server in background
    echo -e "${YELLOW}Starting server...${NC}"
    "$SCRIPT_DIR/start-server.sh" "$server_name" > "/tmp/${server_name}.log" 2>&1 &
    local server_pid=$!
    
    # Wait for server to be ready
    if ! wait_for_server; then
        echo -e "${RED}Error: Server failed to start${NC}"
        kill $server_pid 2>/dev/null || true
        return 1
    fi
    
    echo -e "${GREEN}Server is ready. Running benchmark...${NC}"
    
    # Run benchmark
    echo -e "\n${YELLOW}wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION} http://localhost:3000${endpoint}${NC}\n"
    wrk -t"$THREADS" -c"$CONNECTIONS" -d"$DURATION" "http://localhost:3000${endpoint}" || true
    
    # Stop server
    echo -e "\n${YELLOW}Stopping server...${NC}"
    kill $server_pid 2>/dev/null || true
    kill_server
    sleep 2
}

# Main execution
echo -e "${GREEN}Starting benchmark suite${NC}"
echo -e "Duration: ${DURATION}, Connections: ${CONNECTIONS}, Threads: ${THREADS}\n"

# Ensure port is free
kill_server

# Run benchmarks for each server
for server in "${SERVERS[@]}"; do
    # Test root endpoint
    run_benchmark "$server" "/" "Root endpoint"
    
    # Test JSON endpoint
    run_benchmark "$server" "/json" "JSON endpoint"
done

echo -e "\n${GREEN}All benchmarks complete!${NC}"

