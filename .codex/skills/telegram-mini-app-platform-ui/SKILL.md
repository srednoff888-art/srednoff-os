---
name: telegram-mini-app-platform-ui
description: Use for Telegram work when Codex should build Telegram-native Mini App UI with theme, safe areas, viewport, back button, haptics, and accessibility.
---

# telegram mini app platform ui

## Task Decisions

1. Use available theme, viewport/safe-area and navigation APIs with version/capability guards.
2. Test theme/viewport changes and back behavior inside supported clients; avoid browser-only assumptions.

## Domain Focus

build Telegram-native Mini App UI with theme, safe areas, viewport, back button, haptics, and accessibility.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
