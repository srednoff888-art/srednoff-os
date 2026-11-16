---
name: dark-mode-theme-system
description: "Use this skill for dark mode tokens, contrast, theme persistence, system preference, color scheme QA."
---

# Dark Mode Theme System

## Task Decisions

1. Use semantic foreground/background/state tokens with system preference and explicit user override precedence.
2. Check focus, disabled states, native controls and embedded charts in both themes without a flash of the wrong theme.

Use this skill for Web Design tasks focused on dark mode tokens, contrast, theme persistence, system preference, color scheme QA.

## Guardrails

- Do not invert colors mechanically without contrast and semantic token review.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
