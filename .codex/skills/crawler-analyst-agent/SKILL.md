---
name: crawler-analyst-agent
description: "Use this skill for crawler behavior, log files, sitemap/indexation analysis, crawl-budget diagnostics."
---

# Crawler Analyst Agent

## Task Decisions

1. Reconcile verified bot requests, response classes, canonical destinations and sitemap coverage with indexing evidence.
2. Separate blocked crawling, unrendered content and low demand; present a sampled URL trail for each hypothesis.

Use this skill for Agent Profile tasks focused on crawler behavior, log files, sitemap/indexation analysis, crawl-budget diagnostics.

## Guardrails

- Do not crawl production sites aggressively without rate limits.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
