---
name: telegram-mini-app-init-data-authentication
description: Use for Telegram work when Codex should validate Telegram Mini App initData on the server, enforce expiry, map identity, and create safe sessions.
---

# telegram mini app init data authentication

## Task Decisions

1. Distinguish bot-token HMAC validation from third-party Ed25519 verification and follow the exact canonicalization for each.
2. Enforce auth_date freshness and application replay/session controls; never trust initDataUnsafe or export a bot token to a verifier.

## Domain Focus

validate Telegram Mini App initData on the server, enforce expiry, map identity, and create safe sessions.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
