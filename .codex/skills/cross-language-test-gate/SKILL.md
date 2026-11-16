---
name: cross-language-test-gate
description: Use before finishing programming work in any language or framework to pick the right validation gates.
---

# Cross Language Test Gate

## Task Decisions

1. Discover manifests and existing CI commands for each changed language; select the smallest type/build/unit/integration gates covering the contract.
2. Report which changed surfaces were exercised and which toolchains were unavailable; one language's tests do not validate another runtime.

Use this skill for Programming work focused on choose and run the right lint, typecheck, unit, integration, build, and manual validation commands by stack.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
