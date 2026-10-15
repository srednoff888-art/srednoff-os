---
name: app-analytics-crash-reporting
description: "Use this skill for analytics events, funnels, crash reporting, privacy-safe instrumentation, release health."
---

# App Analytics Crash Reporting

## Decisions

- Define crash, session, release, environment, and user identifiers with a data-minimizing event schema.
- Verify source maps/symbolication, sampling, consent, and duplicate-event handling.

## Acceptance

Trigger a controlled failure in a test build and verify the received event and release identity.

## Constraints

- Do not log sensitive user content or identifiers unnecessarily.
