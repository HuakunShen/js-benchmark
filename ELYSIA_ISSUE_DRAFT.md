# 🚨 Severe Performance Regression: AOT Compilation 45x Slower on Bun Runtime

## Issue Summary
Elysia's AOT (Ahead of Time) compilation causes a **45.7x performance degradation** specifically when running on Bun runtime. This makes Elysia practically unusable in production with default settings.

## Environment
- **Elysia Version**: 1.4.18 (also affects 1.2 when AOT manually enabled)
- **Runtime**: Bun (latest)
- **Node.js**: Works fine
- **Deno**: Works fine

## Performance Data

| Configuration | Runtime | Root RPS | JSON RPS | Latency (Root) |
|--------------|----------|-----------|-----------|----------------|
| **Elysia 1.4 (aot: true, default)** | Bun | 3,853 | 3,298 | 101.76ms |
| **Elysia 1.4 (aot: false)** | Bun | 175,951 | 32,275 | 2.27ms |
| **Elysia 1.2 (aot: false)** | Bun | 64,752 | 18,992 | 6.09ms |

**Performance Impact**: AOT causes **45.7x slower** performance on Bun.

## Comparison with Other Runtimes

| Configuration | Bun RPS | Deno RPS | Node.js RPS |
|--------------|-----------|-----------|-------------|
| **Elysia (aot: true)** | 3,853 | 72,178 | 33,797 |
| **Elysia (aot: false)** | 175,951 | 147,429 | 36,266 |

The issue is **Bun-specific** - AOT works fine on Deno and Node.js.

## Reproduction Steps

1. Create a simple Elysia app:
```typescript
import { Elysia } from 'elysia';

const app = new Elysia() // Uses aot: true by default in 1.4
  .get("/", "Hello Elysia")
  .get("/json", () => ({ message: "Hello World", timestamp: Date.now() }));

app.listen(3000);
```

2. Run with Bun:
```bash
bun run app.ts
```

3. Benchmark:
```bash
wrk -t12 -c400 -d10s http://localhost:3000/
```

4. Expected: ~150K+ RPS
5. Actual: ~3K RPS

## Workaround
Add `aot: false` to Elysia configuration:
```typescript
import { Elysia } from 'elysia';

const app = new Elysia({ aot: false })
  .get("/", "Hello Elysia")
  .get("/json", () => ({ message: "Hello World", timestamp: Date.now() }));

app.listen(3000);
```

This restores performance to ~175K RPS.

## Root Cause Analysis

The issue appears to be in Elysia's AOT compiler generating code that is incompatible or inefficient with Bun's runtime. Possible causes:

1. **Bun-specific bytecode incompatibility**
2. **Memory allocation patterns that trigger Bun's GC issues**
3. **Runtime-specific optimizations that conflict with Bun's JIT**
4. **Compilation pipeline assumes Node.js runtime characteristics**

## Impact Assessment

- **Severity**: Critical - makes Elysia unusable on Bun with default settings
- **Scope**: Affects all Elysia 1.4 users on Bun
- **User Impact**: Silent performance regression (users expect AOT to improve performance)

## Expected Behavior

1. AOT compilation should improve or maintain performance, not degrade it
2. Default settings should work optimally across all supported runtimes
3. Performance should be consistent between runtimes for the same configuration

## Actual Behavior

1. AOT compilation causes 45x performance degradation on Bun
2. Default settings make Elysia practically unusable on Bun
3. Performance varies dramatically between runtimes for same configuration

## Suggested Solutions

### Immediate (Documentation)
- Update docs to recommend `aot: false` for Bun users
- Add runtime-specific recommendations

### Short-term (Bug Fix)
- Investigate AOT compilation pipeline for Bun compatibility
- Fix bytecode generation for Bun runtime
- Consider runtime-specific compilation paths

### Medium-term (Defaults)
- Consider runtime-specific default AOT settings
- Add runtime detection and appropriate defaults

### Long-term (Testing)
- Implement automated performance testing across all runtimes
- Add CI checks to prevent performance regressions

## Additional Context

This issue was discovered during comprehensive benchmarking of JavaScript runtimes and frameworks. The benchmark repository is available for reproduction and testing.

The fact that `aot: false` performs **better** than the supposed optimization suggests a fundamental issue with the AOT implementation for Bun runtime.

## Priority: Critical

This issue blocks production use of Elysia on Bun and represents a significant performance regression that contradicts the intended purpose of AOT compilation.