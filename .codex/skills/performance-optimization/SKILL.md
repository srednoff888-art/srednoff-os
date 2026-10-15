---
name: performance-optimization
description: "Investigate a measured latency, memory, throughput, or bundle regression; isolate its cause and verify improvement under comparable conditions."
---

# Performance Optimization
Choose a user-visible metric before changing code: p95 request latency, time to usable UI, peak memory, frame time, or throughput.
## Decisions
- Reproduce with the same input, hardware, concurrency, warm/cold state, and build mode. Capture a trace or profile and separate CPU, I/O, locks, allocation, and network time.
- Fix the dominant measured cost. Treat caching as a correctness change: define key, invalidation, expiry, and tenant boundaries.
- Compare repeated before/after runs; report distribution and uncertainty instead of the fastest sample.
## Acceptance
Keep functional tests green, verify resource cost and tail latency, and retain the exact workload and profiling command. A theoretical complexity improvement without a measured result is reported as unmeasured.
