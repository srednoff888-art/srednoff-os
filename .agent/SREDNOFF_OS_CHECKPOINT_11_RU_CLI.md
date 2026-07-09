# Srednoff OS Checkpoint 11 - RU CLI Compatibility Scripts

Date: 2026-07-09

## Scope

Checkpoint 11 adds safe local wrappers for RU/NeuralDeep workflows:

- `srednoff-os-ru-search.ps1`
- `srednoff-os-ru-audit.ps1`
- `srednoff-os-ru-import.ps1`
- `srednoff-os-ru-install.ps1`

## Safety Contract

- Search and audit are read-only.
- Import wrapper is recommendation-only and recommends `-DryRun`.
- Install wrapper is blocked-without-confirmation and never installs.
- Scripts do not call external package managers, MCP installers, or shell eval.
- Human approval remains required for installs, production changes, paid actions,
  externally visible actions, and personal-data workflows.

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-ru-cli.ps1"
```

