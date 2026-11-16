---
name: empty-state-error-recovery-design
description: "Use this skill for empty states, errors, offline states, partial failures, recovery paths, helpful microcopy."
---

# Empty State Error Recovery Design

## Task Decisions

1. Differentiate first use, no matching results, loading, authorization failure and partial outage.
2. Provide a recovery action that preserves input and context, and test screen-reader announcements and repeated failure.

Use this skill for Web Design tasks focused on empty states, errors, offline states, partial failures, recovery paths, helpful microcopy.

## Guardrails

- Do not leave users at dead ends after errors.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
