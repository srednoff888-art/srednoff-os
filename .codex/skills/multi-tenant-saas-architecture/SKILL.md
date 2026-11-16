---
name: multi-tenant-saas-architecture
description: "Use this skill for tenant isolation, scoped queries, roles, billing boundaries, admin controls, safety checks."
---

# Multi Tenant Saas Architecture

## Task Decisions

1. Bind every resource lookup, background job and cache key to an authenticated tenant boundary.
2. Test cross-tenant identifiers and role changes; a tenant ID supplied by a client is not authorization.

Use this skill for Programming tasks focused on tenant isolation, scoped queries, roles, billing boundaries, admin controls, safety checks.

## Guardrails

- Do not share data across tenants or assume client-side tenant filters are enough.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
