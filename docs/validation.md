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
python -m unittest discover -s benchmarks -p "test_*.py" -v
```

## CI Gate

GitHub Actions runs on Windows and Ubuntu:

| Runner | Checks |
|---|---|
| Windows | Benchmark harness regressions, PowerShell parse, PSScriptAnalyzer errors, kernel/source/donor/docs validation, evals, fast skill validation |
| Ubuntu | Benchmark harness regressions, Bash syntax, ShellCheck, kernel/source/donor/docs validation, portable evals |

## Coding-Agent Benchmark

The benchmark under `benchmarks/` is separate from deterministic release
validation. It compares a clean Codex control with a compact Srednoff OS policy
arm using isolated Codex homes, fresh sessions, hidden oracles, JSONL traces,
and explicit invalid-run rules.

Benchmark evidence must record model, Codex CLI version, OS, sandbox mode,
replicate count, tasks, timeout behavior, and missing telemetry. A one-task
local pilot is not release proof and must not be generalized to all projects.

## Evidence Files

| File | Evidence |
|---|---|
| `QUALITY.md` | Current release claims and known residual risks |
| `CHANGELOG.md` | Public changes grouped by date |
| `.agent/SREDNOFF_OS_VNEXT_CHECKPOINTS.md` | Checkpoint status |
| `.agent/SREDNOFF_OS_CHECKPOINT_*.md` | Checkpoint-specific research and implementation notes |
| `.github/workflows/ci.yml` | Cross-platform validation path |
| `benchmarks/README.md` | Reproducible coding-agent benchmark protocol |
| `benchmarks/results/` | Sanitized local summaries; raw traces remain outside the repository |
