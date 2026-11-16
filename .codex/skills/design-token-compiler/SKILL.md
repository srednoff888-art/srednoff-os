---
name: design-token-compiler
description: Use for UI/UX and design-system work when Codex should convert visual direction or existing UI into reusable design tokens.
---

# Design Token Compiler

## Task Decisions

1. Separate primitive values from semantic aliases and component tokens; preserve token type, units and theme references.
2. Detect unresolved aliases/cycles and compare generated outputs against source tokens with a deterministic diff.

Use this skill for UI/UX work focused on extract and normalize colors, typography, spacing, radii, shadows, motion, and component tokens.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
