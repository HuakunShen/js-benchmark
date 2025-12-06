## What is the expected behavior?

AOT (Ahead of Time) compilation should improve or maintain performance compared to JIT compilation, not degrade it. With default settings, Elysia should provide optimal performance across all supported runtimes (Bun, Deno, Node.js).

Specifically:
- AOT compilation should result in equal or better RPS than non-AOT
- Default settings should work well on all supported runtimes
- Performance should be consistent between runtimes for the same configuration
- Users should expect ~150K+ RPS on Bun for simple endpoints (based on framework capabilities)

## What do you see instead?

AOT compilation causes a **45.7x performance degradation** specifically on Bun runtime:

| Configuration | Runtime | Root RPS | JSON RPS | Latency (Root) |
|--------------|----------|-----------|-----------|----------------|
| **Elysia 1.4 (aot: true, default)** | Bun | 3,853 | 3,298 | 101.76ms |
| **Elysia 1.4 (aot: false)** | Bun | 175,951 | 32,275 | 2.27ms |
| **Elysia 1.2 (aot: false)** | Bun | 64,752 | 18,992 | 6.09ms |

**Key Issues:**
- AOT causes 45.7x slower performance on Bun (3,853 vs 175,951 RPS)
- The issue is Bun-specific - AOT works fine on Deno (72,178 RPS) and Node.js (33,797 RPS)
- Default settings make Elysia practically unusable on Bun
- Performance contradicts the intended purpose of AOT compilation

## Additional information

### Environment
- **Elysia Version**: 1.4.18 (also affects 1.2 when AOT manually enabled)
- **Runtime**: Bun (latest)
- **OS**: Linux
- **Benchmark Tool**: wrk

### Reproduction Code
```typescript
import { Elysia } from 'elysia';

// This uses aot: true by default in 1.4 (broken on Bun)
const app = new Elysia()
  .get("/", "Hello Elysia")
  .get("/json", () => ({ message: "Hello World", timestamp: Date.now() }));

app.listen(3000);
```

### Reproduction Steps
1. Create Elysia app with default settings (aot: true)
2. Run with Bun: `bun run app.ts`
3. Benchmark: `wrk -t12 -c400 -d10s http://localhost:3000/`
4. Observe ~3K RPS instead of expected ~150K+ RPS

### Working Workaround
```typescript
import { Elysia } from 'elysia';

// Adding aot: false fixes the issue
const app = new Elysia({ aot: false })
  .get("/", "Hello Elysia")
  .get("/json", () => ({ message: "Hello World", timestamp: Date.now() }));

app.listen(3000);
```

### Performance Comparison with Other Frameworks
| Framework | Runtime | Configuration | RPS |
|-----------|----------|----------------|-----|
| **Hono** | Bun | - | 237,229 |
| **Elysia** | Bun | aot: false | 175,951 |
| **Elysia** | Bun | aot: true (default) | 3,853 |

### Root Cause Analysis
The issue appears to be in Elysia's AOT compiler generating code that is incompatible or inefficient with Bun's runtime. The fact that:
- Only Bun is affected (Deno/Node.js work fine)
- `aot: false` performs better than supposed optimization
- Performance difference is 45x (not marginal)

Suggests a fundamental incompatibility between Elysia's AOT output and Bun's execution environment.

### Impact
- **Severity**: Critical - makes Elysia unusable on Bun with default settings
- **User Impact**: Silent performance regression (users expect AOT to improve performance)
- **Production Risk**: Default configuration cannot handle realistic traffic loads

### Additional Test Results
The issue was discovered during comprehensive benchmarking across multiple load patterns:
- High load (12 threads, 400 connections): 45.7x regression
- Medium load (4 threads, 50 connections): Similar regression pattern
- Low load (1 thread, 1 connection): Regression persists

This confirms the issue is not load-dependent but fundamental to the AOT compilation process on Bun.