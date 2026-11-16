---
name: telegram-bot-solution-architecture
description: Use for Telegram work when Codex should choose Telegram bot, webhook, queue, storage, admin, and observability architecture.
---

# telegram bot solution architecture

## Task Decisions

1. Choose webhook/polling, persistent state, authorization and idempotent job ownership for the requested bot flow.
2. Separate Mini App UI identity from server authorization and keep bot tokens server-side.

## Domain Focus

choose Telegram bot, webhook, queue, storage, admin, and observability architecture.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
