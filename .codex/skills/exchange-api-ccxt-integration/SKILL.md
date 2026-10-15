---
name: exchange-api-ccxt-integration
description: "Use this skill for exchange APIs, CCXT integration, keys, rate limits, order safety, sandbox testing."
---

# Exchange API Ccxt Integration

## Decisions

- Confirm exchange capabilities, symbol/market mapping, precision, nonce, rate limits, and auth scope.
- Use sandbox/read-only paths first; define order idempotency, retries, and ambiguous-timeout reconciliation.

## Acceptance

Test parsing, precision, rate-limit handling, and state readback before authorized live orders.

## Constraints

- Do not place live orders or expose API keys without explicit confirmation.
