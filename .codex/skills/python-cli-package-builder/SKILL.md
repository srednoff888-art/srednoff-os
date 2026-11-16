---
name: python-cli-package-builder
description: "Use this skill for Python CLI/package structure, pyproject.toml, console scripts, tests, linting, distribution."
---

# Python Cli Package Builder

## Task Decisions

1. Specify exit codes, stdout/stderr, argument validation and configuration precedence before packaging.
2. Test an installed wheel in a clean environment, including noninteractive failure paths and paths containing spaces.

Use this skill for Programming tasks focused on Python CLI/package structure, pyproject.toml, console scripts, tests, linting, distribution.

## Guardrails

- Do not rely on global Python state when project-local environments are available.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
