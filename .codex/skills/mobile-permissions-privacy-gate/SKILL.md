---
name: mobile-permissions-privacy-gate
description: Use when mobile apps request permissions, collect user data, handle privacy-sensitive flows, or need App Store/Play privacy review.
---

# Mobile Permissions Privacy Gate

## Task Decisions

1. Map every permission to an active user flow and platform disclosure; avoid asking before a relevant action.
2. Test denial, limited access and revoked permission without breaking unrelated app functions.

Use this skill for Mobile work focused on review camera, location, contacts, files, notifications, tracking prompts, privacy labels, and consent.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
