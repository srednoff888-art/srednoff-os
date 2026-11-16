---
name: monorepo-boundary-architecture
description: "Use this skill for monorepo package boundaries, workspace dependencies, shared libraries, build graph, ownership rules."
---

# Monorepo Boundary Architecture

## Task Decisions

1. Map workspace ownership, package exports, dependency direction and build/test caching inputs.
2. Exercise a cross-package contract change and prevent hidden imports that bypass public package boundaries.

Use this skill for Programming tasks focused on monorepo package boundaries, workspace dependencies, shared libraries, build graph, ownership rules.

## Guardrails

- Do not introduce cross-package dependencies that violate existing architecture.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
