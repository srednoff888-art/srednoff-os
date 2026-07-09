# Validation

Validation is the release evidence layer for Srednoff OS.

## Local Gate

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-selector.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-v211.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-v212.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-security-fixtures.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-profiles.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-quality-modes.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-policies.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-bundles.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-agents.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-ru-cli.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-neuraldeep-registry.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-neuraldeep-importer.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-quality-cost-kernel.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-source-registry.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-donor-research.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-docs.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\quick-validate-all-skills.ps1" -Mode fast
powershell -ExecutionPolicy Bypass -File ".\scripts\srednoff-os-doctor.ps1" -ProjectPath . -RunEvals -FixSafe
```

## CI Gate

GitHub Actions runs on Windows and Ubuntu:

| Runner | Checks |
|---|---|
| Windows | PowerShell parse, PSScriptAnalyzer errors, kernel/source/donor/docs validation, evals, fast skill validation |
| Ubuntu | Bash syntax, ShellCheck, kernel/source/donor/docs validation, portable evals |

## Evidence Files

| File | Evidence |
|---|---|
| `QUALITY.md` | Current release claims and known residual risks |
| `CHANGELOG.md` | Public changes grouped by date |
| `.agent/SREDNOFF_OS_VNEXT_CHECKPOINTS.md` | Checkpoint status |
| `.agent/SREDNOFF_OS_CHECKPOINT_*.md` | Checkpoint-specific research and implementation notes |
| `.github/workflows/ci.yml` | Cross-platform validation path |

