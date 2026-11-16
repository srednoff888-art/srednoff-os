---
name: cache-invalidation-design
description: "Use this skill for cache keys, TTLs, invalidation, SWR, consistency, edge/runtime caching."
---

# Cache Invalidation Design

## Task Decisions

1. Specify the cache key's tenant/auth/version boundary and acceptable staleness before choosing TTL or event invalidation.
2. Test a mutation followed by reads through each cache layer, concurrent fills and revocation; never share permission-sensitive results across principals.

Use this skill for Programming tasks focused on cache keys, TTLs, invalidation, SWR, consistency, edge/runtime caching.

## Guardrails

- Do not cache private or permission-sensitive data without isolation.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
