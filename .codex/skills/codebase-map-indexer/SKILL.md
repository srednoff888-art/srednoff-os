---
name: codebase-map-indexer
description: "Use this skill for repo mapping, entry points, ownership, dependency graph, risk areas, impact analysis before implementation."
---

# Codebase Map Indexer

## Task Decisions

1. Map execution entrypoints, ownership boundaries, state stores, build/test commands and external integrations from code evidence.
2. Return a task-sized dependency map with exact paths and unresolved edges, not a full repository dump.

Use this skill for Programming tasks focused on repo mapping, entry points, ownership, dependency graph, risk areas, impact analysis before implementation.

## Guardrails

- Do not change code until the relevant source boundaries are mapped.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
