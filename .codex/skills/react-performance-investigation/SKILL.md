---
name: react-performance-investigation
description: "Investigate a measured React or Next.js performance defect involving request waterfalls, bundles, server/client boundaries, or avoidable renders."
---

# React Performance Investigation

Capture the affected interaction or request before changing React code.
## Decisions
- Find sequential independent I/O, unnecessarily serialized server props, broad client boundaries, and costly bundle imports first.
- Check cache scope and authentication before deduplicating requests. Never share mutable user/request state at module scope.
- Use memoization only after a render profile shows its value; compare update frequency and retained memory.
## Acceptance
Reproduce the same workload in a production build and compare timing/bundle/profile evidence. Retain correctness and auth tests. Apply current Vercel/React recommendations to the installed version rather than treating every rule as mandatory.
