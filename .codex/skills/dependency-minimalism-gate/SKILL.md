---
name: dependency-minimalism-gate
description: Use when code changes propose new dependencies, packages, SDKs, UI libraries, build tools, or runtime services.
---

# Dependency Minimalism Gate

## Task Decisions

1. Compare an existing local primitive, a standard-platform option and the proposed package against the actual required behavior.
2. Measure bundle/runtime/maintenance costs and reject a dependency whose concrete value is not demonstrated.

Use this skill for Programming work focused on reject unnecessary dependencies, prefer existing primitives, and check package risk when adding libraries.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
