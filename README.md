```bash
wrk -t12 -c400 http://localhost:3000/
wrk -t12 -c400 http://localhost:3000/json
```

## Hono

### bun

```
Running 10s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.49ms  641.02us  12.59ms   76.00%
    Req/Sec     9.42k     1.05k   20.39k    90.46%
  1129981 requests in 10.10s, 129.32MB read
Requests/sec: 111838.64
Transfer/sec:     12.80MB
```

```
wrk -t12 -c400 http://localhost:3000/json

Running 10s test @ http://localhost:3000/json
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    13.39ms    0.87ms  30.06ms   92.28%
    Req/Sec     2.46k   115.80     2.98k    91.83%
  294409 requests in 10.02s, 2.96GB read
Requests/sec:  29383.95
Transfer/sec:    302.31MB
```

### deno

```
Running 10s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.14ms  344.31us  11.24ms   86.45%
    Req/Sec    10.48k     1.10k   25.55k    97.68%
  1256253 requests in 10.10s, 171.32MB read
Requests/sec: 124347.99
Transfer/sec:     16.96MB
```


```
wrk -t12 -c400 http://localhost:3000/json

Running 10s test @ http://localhost:3000/json
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    18.22ms    0.90ms  22.85ms   95.79%
    Req/Sec     1.81k    75.75     2.13k    91.58%
  215967 requests in 10.01s, 2.17GB read
Requests/sec:  21574.35
Transfer/sec:    222.44MB
```

### node

```
Running 10s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     7.36ms   23.69ms 453.51ms   98.27%
    Req/Sec     6.90k   750.16     9.89k    88.58%
  829144 requests in 10.10s, 132.84MB read
Requests/sec:  82066.69
Transfer/sec:     13.15MB
```

```
wrk -t12 -c400 http://localhost:3000/json

Running 10s test @ http://localhost:3000/json
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    61.66ms  190.27ms   2.00s    94.54%
    Req/Sec     1.49k   252.89     3.70k    89.68%
  177119 requests in 10.02s, 1.79GB read
  Socket errors: connect 0, read 0, write 0, timeout 16
Requests/sec:  17680.23
Transfer/sec:    182.69MB
```

## Elysia

### bun

```
Running 10s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    89.47ms   14.61ms 240.02ms   88.10%
    Req/Sec   367.06     46.62   600.00     76.25%
  43960 requests in 10.04s, 5.37MB read
Requests/sec:   4379.87
Transfer/sec:    547.48KB
```

```
wrk -t12 -c400 http://localhost:3000/json

Running 10s test @ http://localhost:3000/json
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    95.43ms   12.42ms 160.95ms   92.98%
    Req/Sec   340.01     35.59   760.00     89.33%
  40720 requests in 10.04s, 418.94MB read
Requests/sec:   4056.67
Transfer/sec:     41.74MB
```

### deno

```
Running 10s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     6.25ms    1.19ms  32.89ms   97.40%
    Req/Sec     5.31k     1.71k   63.66k    98.75%
  634330 requests in 10.10s, 82.88MB read
Requests/sec:  62780.59
Transfer/sec:      8.20MB
```

```
wrk -t12 -c400 http://localhost:3000/json

Running 10s test @ http://localhost:3000/json
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    21.43ms    1.25ms  28.26ms   95.92%
    Req/Sec     1.54k    62.42     2.00k    83.50%
  183711 requests in 10.02s, 1.85GB read
Requests/sec:  18334.64
Transfer/sec:    189.03MB
```

### node

```
wrk -t12 -c400 http://localhost:3000/

Running 10s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    25.70ms   88.01ms   1.16s    96.36%
    Req/Sec     3.00k   678.26    10.17k    89.62%
  354110 requests in 10.02s, 59.77MB read
Requests/sec:  35330.83
Transfer/sec:      5.96MB
```

```
wrk -t12 -c400 http://localhost:3000/json

Running 10s test @ http://localhost:3000/json
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    70.22ms  213.51ms   1.99s    94.38%
    Req/Sec     1.30k   313.47     2.79k    78.59%
  154259 requests in 10.02s, 1.56GB read
  Socket errors: connect 0, read 0, write 0, timeout 38
Requests/sec:  15395.72
Transfer/sec:    159.08MB
```