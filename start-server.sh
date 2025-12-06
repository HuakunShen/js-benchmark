#!/bin/bash

# Script to start benchmark servers
# Usage: ./start-server.sh <server-name>
# Server names: hono-bun, hono-deno, hono-node, elysia-bun, elysia-deno, elysia-node

set -e

SERVER_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is in use
port_in_use() {
    if command_exists lsof; then
        lsof -i :3000 >/dev/null 2>&1
    elif command_exists netstat; then
        netstat -tuln 2>/dev/null | grep -q ':3000 '
    elif command_exists ss; then
        ss -tuln 2>/dev/null | grep -q ':3000 '
    else
        # Fallback: try to connect to port
        timeout 1 bash -c "echo >/dev/tcp/localhost/3000" 2>/dev/null
    fi
}

# Function to kill process on port 3000
kill_port() {
    if port_in_use; then
        echo -e "${YELLOW}Port 3000 is in use. Attempting to free it...${NC}"
        if command_exists lsof; then
            lsof -ti :3000 | xargs kill -9 2>/dev/null || true
        elif command_exists fuser; then
            fuser -k 3000/tcp 2>/dev/null || true
        elif command_exists ss; then
            # Get PID from ss and kill it
            ss -tlnp 2>/dev/null | grep ':3000 ' | grep -oP 'pid=\K[0-9]+' | xargs kill -9 2>/dev/null || true
        fi
        sleep 1
    fi
}

# Build Node.js variants
build_node() {
    local file="$1"
    local output="$2"
    
    # Ensure dist directory exists
    mkdir -p dist
    
    if [ ! -f "$output" ] || [ "$file" -nt "$output" ]; then
        echo -e "${YELLOW}Building $file...${NC}"
        if ! command_exists bun; then
            echo -e "${RED}Error: bun is required to build Node.js variants${NC}"
            exit 1
        fi
        bun build "$file" --target node --outdir dist
        echo -e "${GREEN}Build complete: $output${NC}"
    else
        echo -e "${GREEN}Build up to date: $output${NC}"
    fi
}

# Start server based on name
case "$SERVER_NAME" in
    "hono-bun")
        if ! command_exists bun; then
            echo -e "${RED}Error: bun is not installed${NC}"
            exit 1
        fi
        kill_port
        echo -e "${GREEN}Starting Hono with Bun...${NC}"
        bun run hono-bun.ts
        ;;
    
    "hono-deno")
        if ! command_exists deno; then
            echo -e "${RED}Error: deno is not installed${NC}"
            exit 1
        fi
        kill_port
        echo -e "${GREEN}Starting Hono with Deno...${NC}"
        deno run --allow-net --allow-env hono-deno.ts
        ;;
    
    "hono-node")
        if ! command_exists node; then
            echo -e "${RED}Error: node is not installed${NC}"
            exit 1
        fi
        kill_port
        build_node "hono-node.ts" "dist/hono-node.js"
        echo -e "${GREEN}Starting Hono with Node.js...${NC}"
        node dist/hono-node.js
        ;;
    
    "elysia-bun")
        if ! command_exists bun; then
            echo -e "${RED}Error: bun is not installed${NC}"
            exit 1
        fi
        kill_port
        echo -e "${GREEN}Starting Elysia with Bun...${NC}"
        bun run elysia-bun.ts
        ;;
    
    "elysia-deno")
        if ! command_exists deno; then
            echo -e "${RED}Error: deno is not installed${NC}"
            exit 1
        fi
        kill_port
        echo -e "${GREEN}Starting Elysia with Deno...${NC}"
        deno run --allow-net --allow-env elysia-deno.ts
        ;;
    
    "elysia-node")
        if ! command_exists node; then
            echo -e "${RED}Error: node is not installed${NC}"
            exit 1
        fi
        kill_port
        build_node "elysia-node.ts" "dist/elysia-node.js"
        echo -e "${GREEN}Starting Elysia with Node.js...${NC}"
        node dist/elysia-node.js
        ;;
    
    "build-all")
        echo -e "${YELLOW}Building all Node.js variants...${NC}"
        if ! command_exists bun; then
            echo -e "${RED}Error: bun is required to build Node.js variants${NC}"
            exit 1
        fi
        mkdir -p dist
        build_node "hono-node.ts" "dist/hono-node.js"
        build_node "elysia-node.ts" "dist/elysia-node.js"
        echo -e "${GREEN}All builds complete!${NC}"
        ;;
    
    *)
        echo -e "${RED}Error: Unknown server name '$SERVER_NAME'${NC}"
        echo ""
        echo "Usage: $0 <server-name>"
        echo ""
        echo "Available servers:"
        echo "  hono-bun      - Start Hono with Bun"
        echo "  hono-deno     - Start Hono with Deno"
        echo "  hono-node     - Start Hono with Node.js (builds if needed)"
        echo "  elysia-bun    - Start Elysia with Bun"
        echo "  elysia-deno   - Start Elysia with Deno"
        echo "  elysia-node   - Start Elysia with Node.js (builds if needed)"
        echo "  build-all     - Build all Node.js variants"
        exit 1
        ;;
esac

