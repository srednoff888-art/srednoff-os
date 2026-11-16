---
name: site-crawler-automation
description: "Use this skill for automated site crawling, exports, issue classification, reproducible technical SEO audits."
---

# Site Crawler Automation

## Task Decisions

1. Bound crawl scope, concurrency, robots policy and URL normalization before making requests.
2. Report actual statuses and discovery limits; do not scan unrelated hosts or authenticated content by accident.

Use this skill for SEO tasks focused on automated site crawling, exports, issue classification, reproducible technical SEO audits.

## Guardrails

- Do not overload production sites with aggressive crawl settings.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
