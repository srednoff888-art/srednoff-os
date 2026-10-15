---
name: debugging-error-recovery
description: "Use this skill for reproduction, root cause isolation, logs, minimal fixes, regression protection."
---

# Debugging Error Recovery

## Decisions

- Reproduce a failure and isolate its triggering input, state, environment, and minimal code path.
- Separate cause from symptoms; preserve errors and cancellation instead of masking them with broad catches.

## Acceptance

Add a regression for the reproduction and exercise recovery after failure.

## Constraints

- Do not patch symptoms before proving the failure mode.
