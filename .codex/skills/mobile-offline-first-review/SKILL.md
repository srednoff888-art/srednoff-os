---
name: mobile-offline-first-review
description: Use for mobile apps or PWAs that need offline behavior, unreliable network handling, local persistence, or sync conflict management.
---

# Mobile Offline First Review

## Task Decisions

1. Define authoritative data, local write queues, idempotency and conflict policy for reconnect.
2. Test app restart, interrupted sync and concurrent edits without presenting unconfirmed local writes as server-accepted.

Use this skill for Mobile work focused on review offline states, sync conflicts, retries, queues, caching, storage, and recovery UX.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
