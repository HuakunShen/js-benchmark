# JavaScript Runtime & Framework Performance Benchmark

This repository contains comprehensive performance benchmarks comparing different JavaScript runtimes (Bun, Deno, Node.js) with web frameworks (Hono, Elysia).

## Test Environment

- **Benchmark Tool**: `wrk`
- **Test Duration**: 10 seconds
- **Endpoints**: `/` (simple text) and `/json` (complex nested JSON)
- **Load Patterns**: 
  - High load: 12 threads, 400 connections
  - Medium load: 4 threads, 50 connections  
  - Low load: 1 thread, 1 connection

## Key Findings

### 🚨 Critical Issue: Elysia 1.4 Performance Regression

We discovered a **severe performance regression** in Elysia v1.4 when running on Bun:

| Elysia Version | Runtime | Root RPS | JSON RPS | Latency (Root) |
|----------------|---------|----------|----------|----------------|
| **1.4** | Bun | 3,853 | 3,298 | 101.76ms |
| **1.2** | Bun | 64,752 | 18,992 | 6.09ms |
| **Improvement** | - | **16.8x** | **5.8x** | **16.7x better** |

This represents a **16-17x performance degradation** in Elysia 1.4 compared to 1.2 when running on Bun.

## Performance Results

### High Load (12 threads, 400 connections)

#### Root Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 237,157 | 228,402 | 130,789 |
| **Elysia 1.2** | 64,752 | 75,363 | 36,579 |
| **Elysia 1.4** | 3,853 | 72,178 | 33,797 |

#### JSON Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 33,633 | 18,266 | 17,467 |
| **Elysia 1.2** | 18,992 | 16,086 | 14,963 |
| **Elysia 1.4** | 3,298 | 16,280 | 13,765 |

### Medium Load (4 threads, 50 connections)

#### Root Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 241,033 | 243,032 | 138,972 |
| **Elysia 1.4** | 4,026 | 73,935 | 34,742 |

#### JSON Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 34,544 | 19,676 | 16,841 |
| **Elysia 1.4** | 3,342 | 16,787 | 14,091 |

### Low Load (1 thread, 1 connection)

#### Root Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 107,970 | 95,939 | 97,472 |
| **Elysia 1.4** | 3,933 | 48,406 | 30,086 |

#### JSON Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 28,267 | 16,565 | 15,891 |
| **Elysia 1.4** | 3,310 | 14,377 | 13,445 |

## Runtime Performance Comparison

### Overall Runtime Rankings (Average across frameworks)

1. **Bun**: 151,530 RPS (with Hono) / 34,342 RPS (with Elysia 1.2)
2. **Deno**: 123,334 RPS (with Hono) / 45,724 RPS (with Elysia 1.2)  
3. **Node.js**: 74,128 RPS (with Hono) / 25,771 RPS (with Elysia 1.2)

## Framework Performance Comparison

### Hono vs Elysia (Same Runtime)

| Runtime | Hono RPS | Elysia 1.2 RPS | Performance Gap |
|---------|----------|----------------|-----------------|
| **Bun** | 237,157 | 64,752 | Hono **3.7x faster** |
| **Deno** | 228,402 | 75,363 | Hono **3.0x faster** |
| **Node.js** | 130,789 | 36,579 | Hono **3.6x faster** |

## Latency Analysis

### Best Latency (Root Endpoint)

1. **Hono-Bun**: 1.67ms
2. **Hono-Deno**: 1.73ms
3. **Hono-Node**: 7.44ms
4. **Elysia 1.2-Deno**: 5.23ms
5. **Elysia 1.2-Bun**: 6.09ms
6. **Elysia 1.4-Bun**: 101.76ms (severe regression)

## Reproduction Steps

To reproduce these benchmarks:

1. **Install dependencies**:
   ```bash
   bun install
   ```

2. **Run benchmarks**:
   ```bash
   ./run-benchmark.sh 10s 400 12  # High load
   ./run-benchmark.sh 10s 50 4   # Medium load  
   ./run-benchmark.sh 10s 1 1    # Low load
   ```

3. **To reproduce the Elysia 1.4 regression**:
   ```bash
   # Install Elysia 1.4
   bun add elysia@1.4.18
   ./run-benchmark.sh 10s 400 12
   ```

4. **To verify the fix with Elysia 1.2**:
   ```bash
   # Downgrade to Elysia 1.2
   bun add elysia@1.2.16
   ./run-benchmark.sh 10s 400 12
   ```

## Issue Report for Elysia Team

### Problem Summary
Elysia version 1.4 introduces a severe performance regression when running on Bun runtime, causing 16-17x performance degradation compared to version 1.2.

### Expected Behavior
Elysia should maintain consistent performance across minor version updates, similar to how it performs in Deno and Node.js.

### Actual Behavior
- Elysia 1.4 + Bun: 3,853 RPS (Root), 3,298 RPS (JSON)
- Elysia 1.2 + Bun: 64,752 RPS (Root), 18,992 RPS (JSON)
- Performance loss: **16.8x** (Root), **5.8x** (JSON)

### Impact
This regression makes Elysia practically unusable in production environments using Bun, as performance drops to levels that cannot handle realistic traffic loads.

### Recommendation
1. **Immediate**: Document the compatibility issue and recommend Elysia 1.2 for Bun users
2. **Short-term**: Investigate and fix the regression in the 1.4.x branch
3. **Long-term**: Implement automated performance testing to prevent future regressions

## Test Configuration Details

### Server Setup
- **Port**: 3000
- **Root endpoint**: Returns simple text response
- **JSON endpoint**: Returns complex nested JSON with 10 levels of nesting and random data

### Benchmark Commands
```bash
# High load
wrk -t12 -c400 -d10s http://localhost:3000/
wrk -t12 -c400 -d10s http://localhost:3000/json

# Medium load  
wrk -t4 -c50 -d10s http://localhost:3000/
wrk -t4 -c50 -d10s http://localhost:3000/json

# Low load
wrk -t1 -c1 -d10s http://localhost:3000/
wrk -t1 -c1 -d10s http://localhost:3000/json
```

### Versions Used
- **Bun**: Latest
- **Deno**: Latest  
- **Node.js**: Latest LTS
- **Hono**: 4.10.7
- **Elysia**: 1.4.18 (problematic) / 1.2.16 (fixed)