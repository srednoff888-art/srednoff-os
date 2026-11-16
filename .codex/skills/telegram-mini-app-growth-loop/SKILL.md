---
name: telegram-mini-app-growth-loop
description: Use for Telegram work when Codex should design Mini App activation, referral, retention, notification-consent, and re-engagement loops responsibly.
---

# telegram mini app growth loop

## Task Decisions

1. Model the invitation/referral benefit, qualification and abuse controls using stable server-side identity.
2. Measure invited-user activation rather than clicks alone; messages and rewards require the approved product policy.

## Domain Focus

design Mini App activation, referral, retention, notification-consent, and re-engagement loops responsibly.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
