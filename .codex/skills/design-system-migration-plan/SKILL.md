---
name: design-system-migration-plan
description: "Use this skill for migrating legacy UI to design-system primitives, component mapping, risk sequencing."
---

# Design System Migration Plan

## Task Decisions

1. Map old components and tokens to canonical replacements, identify API gaps and stage a representative low-risk route.
2. Track compatibility, visual differences and rollback at each migration slice; avoid parallel competing systems.

Use this skill for Web Design tasks focused on migrating legacy UI to design-system primitives, component mapping, risk sequencing.

## Guardrails

- Do not rewrite the whole UI when incremental migration is safer.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
