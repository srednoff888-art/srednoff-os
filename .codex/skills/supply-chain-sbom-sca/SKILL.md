---
name: supply-chain-sbom-sca
description: "Use this skill for SBOM, SCA, lockfile review, provenance, package integrity, supply-chain risk."
---

# Supply Chain SBOM SCA

## Task Decisions

1. Generate an inventory from resolved artifacts/lockfiles and retain advisory/source timestamps.
2. Separate package presence, reachable vulnerable behavior and distribution obligations; no scanner result alone proves exploitation or safety.

Use this skill for Security tasks focused on SBOM, SCA, lockfile review, provenance, package integrity, supply-chain risk.

## Guardrails

- Do not ignore transitive dependencies in production software.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
