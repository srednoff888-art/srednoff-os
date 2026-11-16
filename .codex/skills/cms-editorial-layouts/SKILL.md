---
name: cms-editorial-layouts
description: "Use this skill for CMS-driven pages, editorial templates, rich text rendering, content governance."
---

# CMS Editorial Layouts

## Task Decisions

1. Define the content model for rich text, media, embeds and reusable blocks, including empty and migrated entries.
2. Test long titles, missing media, draft previews and sanitized rich text in the actual templates.

Use this skill for Web Design tasks focused on CMS-driven pages, editorial templates, rich text rendering, content governance.

## Guardrails

- Do not trust CMS HTML without sanitization and design constraints.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
