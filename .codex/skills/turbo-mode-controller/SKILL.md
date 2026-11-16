---
name: turbo-mode-controller
description: Use when the user explicitly enters TURBO, mode TURBO, enable TURBO, or TURBO for this task, and Codex should optimize for maximum quality without normal token-cost restraint.
---

# Turbo Mode Controller

## Task Decisions

1. Activate turbo only on the user's explicit command for the current task and keep approval/secret boundaries unchanged.
2. Choose additional research/review/tests for a stated benefit; do not change the user's model or delegate merely because a role profile exists.

Use this skill for TURBO work focused on activate and govern explicit TURBO mode with maximum-quality workflow and strict safety stops.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
