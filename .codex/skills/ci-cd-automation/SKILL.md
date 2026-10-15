---
name: ci-cd-automation
description: "Use this skill for GitHub Actions, checks, release gates, deployment automation, reproducible pipelines."
---

# CI CD Automation

## Decisions

- Map existing local gates to independent CI jobs with explicit tool versions and failure status.
- Use scoped permissions, lockfile caches, bounded timeouts, and separate deployment credentials.

## Acceptance

Verify a clean checkout and one intentionally failing job; confirm failure propagates.

## Constraints

- Do not change production deploy behavior without explaining impact and rollback.
