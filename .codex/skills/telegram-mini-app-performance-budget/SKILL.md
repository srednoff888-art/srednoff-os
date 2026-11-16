---
name: telegram-mini-app-performance-budget
description: Use for Telegram work when Codex should set Mini App mobile performance budgets for startup, JS, assets, rendering, network, and low-end devices.
---

# telegram mini app performance budget

## Task Decisions

1. Measure bridge readiness, first usable screen, bundle transfer and image decode in a real Telegram client.
2. Keep loading and offline recovery usable and compare the same device/network workload after optimization.

## Domain Focus

set Mini App mobile performance budgets for startup, JS, assets, rendering, network, and low-end devices.

## Official Sources

https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api

## Guardrails

- Treat initDataUnsafe and browser-provided user identity as untrusted.
- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.
- Require explicit approval for payments, messages, production bot settings, or externally visible launches.
