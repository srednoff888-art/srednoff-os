---
name: realtime-websockets-sse
description: "Use this skill for WebSockets, SSE, realtime auth, reconnects, backpressure, presence, delivery semantics."
---

# Realtime Websockets SSE

## Task Decisions

1. Define authenticated connection ownership, event ordering, replay/resume and backpressure behavior.
2. Test reconnect, token expiry and slow consumers; transport delivery is not business-operation completion.

Use this skill for Programming tasks focused on WebSockets, SSE, realtime auth, reconnects, backpressure, presence, delivery semantics.

## Guardrails

- Do not expose events across tenant or user boundaries.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
