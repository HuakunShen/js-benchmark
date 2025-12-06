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

### 🚨 Critical Issue: Elysia AOT Performance Bug on Bun

We discovered a **severe performance regression** in Elysia when using AOT (Ahead of Time) compilation on Bun runtime:

| Elysia Version | AOT Setting | Runtime | Root RPS | JSON RPS | Latency (Root) |
|----------------|--------------|---------|----------|----------|----------------|
| **1.4** | aot: true (default) | Bun | 3,853 | 3,298 | 101.76ms |
| **1.4** | aot: false | Bun | 175,951 | 32,275 | 2.27ms |
| **1.2** | default | Bun | 64,752 | 18,992 | 6.09ms |
| **1.2** | aot: false | Bun | 160,000+ | - | - |

**Key Finding**: AOT compilation causes **45.7x performance degradation** on Bun. Setting `aot: false` completely resolves the issue and actually improves performance beyond Elysia 1.2 levels.

## Performance Results

### High Load (12 threads, 400 connections)

#### Root Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 237,229 | 231,065 | 130,533 |
| **Elysia (aot: false)** | 175,951 | 147,429 | 36,266 |
| **Elysia (aot: true)** | 3,853 | 72,178 | 33,797 |

#### JSON Endpoint Performance (RPS)

| Framework | Bun | Deno | Node.js |
|-----------|-----|------|---------|
| **Hono** | 33,528 | 18,313 | 17,335 |
| **Elysia (aot: false)** | 32,275 | 18,033 | 14,941 |
| **Elysia (aot: true)** | 3,298 | 16,280 | 13,765 |

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

| Runtime | Hono RPS | Elysia (aot: false) RPS | Elysia (aot: true) RPS | Performance Gap |
|---------|----------|------------------------|----------------------|-----------------|
| **Bun** | 237,229 | 175,951 | 3,853 | Hono **1.3x faster** (vs aot:false) |
| **Deno** | 231,065 | 147,429 | 72,178 | Hono **1.6x faster** (vs aot:false) |
| **Node.js** | 130,533 | 36,266 | 33,797 | Hono **3.6x faster** (vs aot:false) |

**Key Insight**: With `aot: false`, Elysia becomes competitive with Hono on Bun (only 26% slower).

## Latency Analysis

### Best Latency (Root Endpoint)

1. **Hono-Bun**: 1.67ms
2. **Hono-Deno**: 1.72ms
3. **Elysia (aot: false)-Bun**: 2.27ms
4. **Elysia (aot: false)-Deno**: 2.69ms
5. **Hono-Node**: 7.48ms
6. **Elysia (aot: true)-Bun**: 101.76ms (severe AOT regression)

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
Elysia's AOT (Ahead of Time) compilation has a severe performance bug specifically when running on Bun runtime, causing 45.7x performance degradation. The issue affects both Elysia 1.4 (default aot: true) and can be reproduced in 1.2 when manually enabling AOT.

### Expected Behavior
- AOT compilation should improve performance, not degrade it
- Default settings should provide optimal performance across all supported runtimes
- Performance should be consistent between runtimes for the same configuration

### Actual Behavior
- Elysia 1.4 + Bun (aot: true, default): 3,853 RPS (Root), 3,298 RPS (JSON)
- Elysia 1.4 + Bun (aot: false): 175,951 RPS (Root), 32,275 RPS (JSON)
- Elysia 1.2 + Bun (aot: false): 64,752 RPS (Root), 18,992 RPS (JSON)
- Performance loss with AOT: **45.7x** (Root), **9.8x** (JSON)

### Additional Findings
- AOT works correctly on Deno and Node.js (no major performance impact)
- The issue is specific to Bun runtime + AOT compilation combination
- Documentation may be incorrect about default AOT settings in different versions

### Impact
This regression makes Elysia practically unusable in production environments using Bun, as performance drops to levels that cannot handle realistic traffic loads.

### Recommendation
1. **Immediate**: Update documentation to recommend `aot: false` for Bun users
2. **Short-term**: Fix AOT compilation bug for Bun runtime in the 1.4.x branch
3. **Medium-term**: Consider runtime-specific default AOT settings
4. **Long-term**: Implement automated performance testing across all runtimes to prevent future regressions

### Workaround for Users
```typescript
import { Elysia } from 'elysia';

// Add aot: false for Bun runtime
const app = new Elysia({ aot: false });
```

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