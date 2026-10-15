---
name: observability-instrumentation
description: "Use this skill for structured logs, metrics, traces, alerts, production diagnostics, privacy-safe telemetry."
---

# Observability Instrumentation

## Decisions

- Define actionable signals, service boundaries, correlation IDs, and failure budgets.
- Separate metrics/logs/traces; bound cardinality, sampling, overhead, and sensitive fields.

## Acceptance

Trigger a controlled failure and verify trace correlation and alert usefulness.

## Constraints

- Do not log secrets, tokens, cookies, private keys, or unnecessary PII.
