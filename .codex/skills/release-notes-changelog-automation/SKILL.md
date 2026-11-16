---
name: release-notes-changelog-automation
description: "Use this skill for release notes, changelog generation, PR/commit summarization, public impact review."
---

# Release Notes Changelog Automation

## Task Decisions

1. Derive user-visible changes and migration notes from the scoped commits and verified tests.
2. Separate shipped behavior from plans and link exact evidence instead of repeating unsupported performance claims.

Use this skill for Programming tasks focused on release notes, changelog generation, PR/commit summarization, public impact review.

## Guardrails

- Do not publish release notes that include secrets or internal-only context.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
