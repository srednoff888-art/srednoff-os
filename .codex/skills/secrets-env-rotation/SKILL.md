---
name: secrets-env-rotation
description: "Use this skill for secret inventory, env vars, rotation plans, safe dev/prod separation, leak response."
---

# Secrets Env Rotation

## Task Decisions

1. Identify the exposed credential's issuer, scope and dependent deployments without repeating the secret.
2. Revoke/rotate only with approved access, update consumers, then verify both new-key health and old-key rejection.

Use this skill for Security tasks focused on secret inventory, env vars, rotation plans, safe dev/prod separation, leak response.

## Guardrails

- Do not print, commit, or expose secrets in logs, diffs, screenshots, or reports.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
