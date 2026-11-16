---
name: telegram-mini-app-backend-contract
description: Use for Telegram work when Codex should design Mini App backend contracts, authorization, idempotency, error states, and bot integration boundaries.
---

# telegram mini app backend contract

## Task Decisions

1. Validate the documented launch data before binding a user session; authorize each resource operation separately.
2. Test replay/expiry, duplicate requests and cross-user IDs; native platform conveniences do not authorize application data access.

## Domain Focus

design Mini App backend contracts, authorization, idempotency, error states, and bot integration boundaries.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
