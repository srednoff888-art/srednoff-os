---
name: telegram-mini-app-product-brief
description: Use for Telegram work when Codex should define Telegram Mini App user job, launch surface, platform constraints, trust, and success metrics.
---

# telegram mini app product brief

## Task Decisions

1. Record the user job, launch surface, identity needs, monetization and permitted bot interaction.
2. Prototype the smallest complete Mini App journey before choosing backend or payment infrastructure.

## Domain Focus

define Telegram Mini App user job, launch surface, platform constraints, trust, and success metrics.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
