---
name: background-jobs-queues
description: "Use this skill for queues, retries, idempotency, cron, dead-letter queues, background processing."
---

# Background Jobs Queues

## Task Decisions

1. Define delivery semantics, idempotency key ownership, retryable failures, visibility timeout and dead-letter recovery.
2. Test duplicate delivery, worker interruption and exhausted retries; do not equate queue acceptance with completed work.

Use this skill for Programming tasks focused on queues, retries, idempotency, cron, dead-letter queues, background processing.

## Guardrails

- Do not create jobs that can double-charge, double-send, or corrupt state on retry.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
