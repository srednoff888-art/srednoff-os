---
name: log-file-crawl-analysis
description: "Use this skill for server log crawl analysis, bot behavior, wasted crawl paths, crawl budget, anomalies."
---

# Log File Crawl Analysis

## Task Decisions

1. Verify bot identity and sample request status, latency, canonical groups and crawl frequency over comparable periods.
2. Separate actual requests from estimated crawl demand and prioritize repeatable waste or failures.

Use this skill for SEO tasks focused on server log crawl analysis, bot behavior, wasted crawl paths, crawl budget, anomalies.

## Guardrails

- Do not process logs containing sensitive data without privacy review.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
