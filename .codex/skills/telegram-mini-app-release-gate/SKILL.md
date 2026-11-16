---
name: telegram-mini-app-release-gate
description: Use for Telegram work when Codex should validate Mini App HTTPS, bot configuration, auth, UI states, analytics, security, and rollback readiness.
---

# telegram mini app release gate

## Task Decisions

1. Validate launch URLs, auth, platform UI, payment callbacks, performance and rollback in the intended Telegram clients.
2. Verify production behavior after the approved launch without treating a standalone-browser preview as client certification.

## Domain Focus

validate Mini App HTTPS, bot configuration, auth, UI states, analytics, security, and rollback readiness.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
