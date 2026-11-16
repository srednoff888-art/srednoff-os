---
name: ai-evals-regression-suite
description: "Use this skill for LLM evals, golden datasets, structured outputs, drift detection, regression gates."
---

# AI Evals Regression Suite

## Task Decisions

1. Freeze a held-out corpus, baseline/model settings and deterministic artifact assertions before editing prompts.
2. Separate routing accuracy, task correctness, refusal/approval behavior, latency and token usage; keep grader failures distinct from task failures.

Use this skill for AI Engineering tasks focused on LLM evals, golden datasets, structured outputs, drift detection, regression gates.

## Guardrails

- Do not judge AI quality only from a single hand-picked example.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
