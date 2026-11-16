---
name: code-copy-provenance-review
description: Use before copying or adapting code from GitHub, docs, Stack Overflow, registries, AI output, UI kits, snippets, or third-party examples.
---

# Code Copy Provenance Review

## Task Decisions

1. Record the exact source revision, applicable file license, required notices and any generated or vendored origin.
2. Review the copied behavior and dependency surface before adaptation; unclear provenance means adapt the idea without copying the implementation.

Use this skill for Programming work focused on review copied code or snippets for source, license, security, dependency, compatibility, and test risk.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
