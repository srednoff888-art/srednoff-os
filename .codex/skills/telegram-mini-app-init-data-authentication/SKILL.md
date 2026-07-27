---
name: telegram-mini-app-init-data-authentication
description: Use for Telegram work when Codex should validate Telegram Mini App initData on the server, enforce expiry, map identity, and create safe sessions.
---

# telegram mini app init data authentication

## Workflow

1. Confirm the business outcome, owner, source data, constraints, and success metric.
2. Inspect the project and available account or analytics evidence before proposing changes.
3. Use official documentation for current platform behavior and retain source provenance.
4. Produce an evidence-backed plan with assumptions, dependencies, and measurable validation.
5. Run only read-only diagnostics by default; gate external, paid, production, or publishing actions behind explicit approval.

## Domain Focus

validate Telegram Mini App initData on the server, enforce expiry, map identity, and create safe sessions.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.