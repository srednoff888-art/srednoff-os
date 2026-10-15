---
name: browser-devtools-qa
description: "Use this skill for browser verification, console/network errors, layout checks, user-flow QA, DevTools evidence."
---

# Browser Devtools Qa

## Decisions

- Reproduce the defect with a recorded viewport, route, input, and network condition.
- Inspect console, failed requests, layout shifts, event handlers, and performance traces before editing.

## Acceptance

Retest the original reproduction and a nearby workflow; retain the minimal evidence.

## Constraints

- Do not claim visual correctness without checking rendered output when feasible.
