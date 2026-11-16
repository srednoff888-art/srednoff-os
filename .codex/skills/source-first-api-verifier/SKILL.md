---
name: source-first-api-verifier
description: Use when implementing with APIs, SDKs, libraries, frameworks, or project-local contracts that may differ from memory or have changed recently.
---

# Source First API Verifier

## Task Decisions

1. Check the exact installed SDK and current official endpoint/schema before writing an integration.
2. Record a minimal request/response contract and test unsupported fields and failure modes; never infer API support from UI availability.

Use this skill for Programming work focused on check local source, installed package docs, types, and official docs before coding against memory.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
