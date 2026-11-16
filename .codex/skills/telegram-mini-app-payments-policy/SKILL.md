---
name: telegram-mini-app-payments-policy
description: Use for Telegram work when Codex should review Mini App payments, digital-goods constraints, receipts, refunds, policy, and approval gates.
---

# telegram mini app payments policy

## Task Decisions

1. Check current Telegram policy and the actual digital/physical product/payment path before implementation.
2. Use server-confirmed payment identity, idempotency and refund handling; never grant entitlements from a client success callback.

## Domain Focus

review Mini App payments, digital-goods constraints, receipts, refunds, policy, and approval gates.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
