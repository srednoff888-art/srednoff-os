---
name: sql-query-plan-optimizer
description: "Use this skill for SQL query plans, indexes, N+1s, pagination, transactions, performance bottlenecks."
---

# Sql Query Plan Optimizer

## Task Decisions

1. Capture the actual query, bound parameters, row estimates and representative execution plan.
2. Compare index/write cost and lock impact as well as latency; production EXPLAIN ANALYZE requires appropriate approval.

Use this skill for Programming tasks focused on SQL query plans, indexes, N+1s, pagination, transactions, performance bottlenecks.

## Guardrails

- Do not add indexes without considering write cost and migration impact.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
