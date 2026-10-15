---
name: app-ci-cd-release-automation
description: "Use this skill for mobile/web app CI/CD, signing, build numbers, release lanes, environment gates."
---

# App CI CD Release Automation

## Decisions

- Separate build signing, tests, store submission, and rollout into independently visible jobs.
- Keep signing secrets outside source, pin tooling, and retain rollback artifacts.

## Acceptance

Verify a test release end-to-end and confirm version/build numbers and artifact identity.

## Constraints

- Do not expose signing keys or release credentials.
