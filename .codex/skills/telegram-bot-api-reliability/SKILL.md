---
name: telegram-bot-api-reliability
description: Use for Telegram work when Codex should implement Telegram Bot API retries, idempotency, update handling, rate limits, errors, and safe logging.
---

# telegram bot api reliability

## Task Decisions

1. Verify webhook authenticity, update idempotency and retry/backoff behavior against the current Bot API.
2. Test duplicate updates, rate limiting and partial send failure without sending real messages during diagnosis.

## Domain Focus

implement Telegram Bot API retries, idempotency, update handling, rate limits, errors, and safe logging.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
