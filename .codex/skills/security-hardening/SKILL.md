---
name: security-hardening
description: "Use this skill for auth boundaries, input validation, secrets, RLS, injection risks, destructive-action review."
---

# Security Hardening

## Decisions

- Map assets, attack surface, trust boundaries, and observed vulnerabilities before changing controls.
- Prioritize exploitable findings; preserve legitimate behavior and avoid blanket permission removal.

## Acceptance

Verify the original exploit/reproduction is blocked and affected workflows still work.

## Constraints

- Do not disable security controls or expose secrets without explicit user confirmation.
