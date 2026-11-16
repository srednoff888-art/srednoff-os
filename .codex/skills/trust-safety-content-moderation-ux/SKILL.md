---
name: trust-safety-content-moderation-ux
description: "Use this skill for moderation UX, reports, appeals, safety queues, review workflows, user trust."
---

# Trust Safety Content Moderation UX

## Task Decisions

1. Define what users can report, block, appeal or recover and separate automated decisions from human review.
2. Test abuse, false positives and accessible status feedback without leaking reporter identity.

Use this skill for Web Design tasks focused on moderation UX, reports, appeals, safety queues, review workflows, user trust.

## Guardrails

- Do not expose reporter identity or sensitive moderation context unnecessarily.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
