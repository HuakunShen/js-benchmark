# Benchmark Scripts Guide

This directory contains automated scripts to run benchmarks on different server configurations.

## Prerequisites

- **Bun** - For running Bun servers and building Node.js variants
- **Deno** - For running Deno servers
- **Node.js** - For running Node.js servers (after building)
- **wrk** - For running benchmarks

### Installing wrk on Linux

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install wrk

# CentOS/RHEL
sudo yum install wrk

# Fedora
sudo dnf install wrk
```

## Scripts

### `start-server.sh`

Starts a single server instance. Automatically handles:
- Building Node.js variants (if needed)
- Freeing port 3000 if in use
- Starting the server with correct runtime

**Usage:**
```bash
./start-server.sh <server-name>
```

**Available servers:**
- `hono-bun` - Hono with Bun
- `hono-deno` - Hono with Deno
- `hono-node` - Hono with Node.js (builds automatically)
- `elysia-bun` - Elysia with Bun
- `elysia-deno` - Elysia with Deno
- `elysia-node` - Elysia with Node.js (builds automatically)
- `build-all` - Build all Node.js variants without starting

**Examples:**
```bash
# Start Hono with Bun
./start-server.sh hono-bun

# Start Elysia with Node.js (will build first if needed)
./start-server.sh elysia-node

# Build all Node.js variants
./start-server.sh build-all
```

### `run-benchmark.sh`

Runs automated benchmarks on all server configurations. Tests both root (`/`) and JSON (`/json`) endpoints.

**Usage:**
```bash
./run-benchmark.sh [duration] [connections] [threads]
```

**Default values:**
- Duration: `10s`
- Connections: `400`
- Threads: `12`

**Examples:**
```bash
# Run with defaults (10s, 400 connections, 12 threads)
./run-benchmark.sh

# Custom duration
./run-benchmark.sh 30s

# Custom duration, connections, and threads
./run-benchmark.sh 30s 500 16
```

## Manual Benchmarking

If you want to run benchmarks manually:

1. Start a server:
   ```bash
   ./start-server.sh hono-bun
   ```

2. In another terminal, run wrk:
   ```bash
   wrk -t12 -c400 -d10s http://localhost:3000/
   wrk -t12 -c400 -d10s http://localhost:3000/json
   ```

3. Stop the server (Ctrl+C) and repeat for other configurations.

## Linux-Specific Notes

- The scripts automatically detect available tools (`lsof`, `netstat`, `ss`) for port management
- Node.js variants are built using Bun's bundler (works cross-platform)
- All scripts use relative paths and work from any directory

## Troubleshooting

**Port 3000 already in use:**
- The scripts automatically try to free the port
- Manually kill the process: `lsof -ti :3000 | xargs kill -9` (Linux/macOS)

**Build fails:**
- Ensure Bun is installed: `curl -fsSL https://bun.sh/install | bash`
- Check that source files exist and are valid TypeScript

**Server won't start:**
- Check that the required runtime (bun/deno/node) is installed
- Verify dependencies are installed: `bun install`
- Check server logs in `/tmp/<server-name>.log` when using run-benchmark.sh

