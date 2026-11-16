---
name: email-deliverability-transactional
description: "Use this skill for transactional email, SPF/DKIM/DMARC, templates, retries, bounces, deliverability."
---

# Email Deliverability Transactional

## Task Decisions

1. Trace sender identity, SPF/DKIM/DMARC alignment, bounce/complaint handling and retry ownership.
2. Exercise a representative transaction and suppression behavior; delivery acceptance is not proof of inbox placement.

Use this skill for Programming tasks focused on transactional email, SPF/DKIM/DMARC, templates, retries, bounces, deliverability.

## Guardrails

- Do not send real email without explicit user confirmation.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
