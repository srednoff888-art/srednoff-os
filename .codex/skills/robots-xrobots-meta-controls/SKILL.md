---
name: robots-xrobots-meta-controls
description: "Use this skill for robots.txt, meta robots, X-Robots-Tag, environment indexing controls."
---

# Robots X-Robots Meta Controls

## Task Decisions

1. Resolve robots.txt, response X-Robots-Tag and rendered meta directives for the same URL and bot.
2. Remember that blocking crawling can prevent reading noindex; test status, canonical and recrawl evidence together.

Use this skill for SEO tasks focused on robots.txt, meta robots, X-Robots-Tag, environment indexing controls.

## Guardrails

- Do not block production search traffic by copying staging rules.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
