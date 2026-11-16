---
name: react-server-client-boundary-audit
description: "Audit data exposure and module boundaries between React Server Components, Client Components and server actions."
---

# React Server Client Boundary Audit

## Decisions And Evidence

1. Trace server-only imports and serialized props rather than treating a client boundary as authorization.
2. Verify auth at each callable server action, minimal client payloads and production hydration with representative untrusted input.

## Boundary

For cache lifetime/invalidation use the cache workflow; this skill owns the RSC data boundary.

## Source

[Current primary reference](https://react.dev/reference/rsc/server-components). Check the installed version and current contract before execution.
