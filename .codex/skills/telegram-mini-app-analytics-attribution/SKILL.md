---
name: telegram-mini-app-analytics-attribution
description: Use for Telegram work when Codex should instrument Mini App acquisition, start parameters, funnel events, consent, attribution, and privacy-safe reporting.
---

# telegram mini app analytics attribution

## Task Decisions

1. Define launch/referral parameters and events without treating client-supplied attribution as authenticated identity.
2. Reconcile sessions, users and paid outcomes while excluding raw initData and tokens from analytics.

## Domain Focus

instrument Mini App acquisition, start parameters, funnel events, consent, attribution, and privacy-safe reporting.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
