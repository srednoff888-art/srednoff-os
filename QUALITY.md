# Srednoff OS Quality Status

This file documents what is currently verified and what is intentionally not promised.

## Current Smoke Status

Last verified: 2026-07-09.

Checkpoint 0 preflight was recorded on 2026-07-09 in `.agent/SREDNOFF_OS_CHECKPOINT_0_PREFLIGHT.md`. Checkpoint 1 removed public-core hardcoded personal paths. Checkpoint 2 compacted `AGENTS.md` and moved the full rules to `.agent/SREDNOFF_OS_OPERATING_RULES.md`. Checkpoint 3 added the public profile system. Checkpoint 4 added explicit quality modes. Checkpoint 5 upgraded security hook decisions and audit coverage.

| Check | Status | Command |
|---|---:|---|
| Selector regression suite | PASS, 11/11 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-selector.ps1` |
| v2.1.1 compatibility evals | PASS, 13/13 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-v211.ps1` |
| v2.1.2 routing/source evals | PASS, 12/12 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-v212.ps1` |
| Independent security fixture evals | PASS, 12/12 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-security-fixtures.ps1` |
| Profile evals | PASS, 4/4 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-profiles.ps1` |
| Quality mode evals | PASS, 5/5 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-quality-modes.ps1` |
| Fast skill metadata validation | PASS, 308/308 | `powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate-all-skills.ps1 -Mode fast` |
| Kernel catalog validation | PASS, 4500 records | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-quality-cost-kernel.ps1` |
| Source registry metadata validation | PASS, 17 sources | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-source-registry.ps1` |
| PowerShell parse check | PASS, 26 scripts | `Get-ChildItem .\scripts -Filter *.ps1` with PowerShell parser |
| Bash syntax check | PASS, 3 scripts | `bash -n scripts/init-codex-project.sh scripts/install-codex-md-os.sh .codex/skills/agentic-seo-skill/scripts/pre_commit_seo_check.sh` |
| Srednoff OS doctor | PASS, 29/29 | `powershell -ExecutionPolicy Bypass -File .\scripts\srednoff-os-doctor.ps1 -ProjectPath . -RunEvals -FixSafe` |
| GitHub Actions CI | PRESENT | `.github/workflows/ci.yml` installs ShellCheck and PSScriptAnalyzer on runners |
| Secret scan | PASS | high-confidence token/path scan before publication |

## Selector Changes From Audit

- Local clone fallback: selector wrappers now prefer the repository-local `.codex/skills` and scripts before `$HOME\.codex`.
- Local skill index: `select_core_capabilities.py` can build a skill index directly from `SKILL.md` files when `skill-index.json` is not present.
- Direct aliases: explicit task terms such as `record replay`, `source ranking`, and `design brief` are surfaced even when the selected capability is broad.
- Multi-match output: `ids` format now shows up to three mapped skills so one direct match does not hide another.
- Stronger fixture semantics: selector evals now support `expectedAll`, not only `expectedAny`.
- Fast validation: skill metadata smoke checks now support YAML block scalar descriptions such as `description: >`.
- Expanded kernel: deterministic catalog generation now produces 4500 records with 75 capability slugs per domain and 1800/1800/900 Group 1/2/3 distribution.
- Selector speed: the local wrapper uses portable `.codex/skill-index.json` when present, avoiding repeated `SKILL.md` scans; measured wrapper scenario improved from about 5.9s to about 1.9s on this machine.
- CI coverage: pull requests and pushes now run Windows PowerShell validation, Ubuntu Bash syntax/ShellCheck, kernel validation, registry validation, and eval suites.
- Source registry provenance: UI/3D source ranking now includes license, provenance, vetted status, and copy policy metadata for every registered source.
- Independent security fixtures: hook behavior is now tested from external fixture data instead of only inline/manual cases.
- External prompt mining: claimed-leak and prompt-dump repositories are now handled through a provenance-first skill that extracts only abstract, vendor-neutral patterns and rejects verbatim proprietary prompt text.
- Profile system: public defaults, maintainer examples, agency settings, and RU-market settings now live in a portable `profiles/` layer with privacy fixtures and doctor coverage.
- Quality modes: `fast`, `standard`, `production`, and `critical` now map task risk to selector budget, capability count, and validation gates without changing the old `normal/deep/turbo` compatibility fields.
- Security hook decisions: high-confidence secrets and destructive actions are blocked, externally visible or bypass-prone actions ask for confirmation, and audit entries store findings plus input hashes without raw prompt/tool input.

## What This Does Not Promise

- It does not make Codex, Claude, or any model obey instructions with mathematical certainty.
- It does not replace platform-level permissions, sandboxing, secret management, or human approval.
- It does not prove all 4500 kernel records are individually optimal.
- It does not guarantee that every skill improves every project.

## Known Residual Risks

- Full skill validation can still take longer than smoke validation because it invokes the external skill validator for each skill.
- Source ranking is heuristic and must be reviewed before copying third-party code or assets.
- Public forks can become unsafe if users add their own `.env`, `config.toml`, `hooks.state`, tokens, or machine-specific paths.
- The selector still relies on handcrafted terms and fixtures; broader benchmark coverage is needed before making stronger claims.

## Release Gate

Before publishing a new release, run:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-selector.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-v211.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-v212.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-security-fixtures.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-profiles.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-quality-modes.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\quick-validate-all-skills.ps1" -Mode fast
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-quality-cost-kernel.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-source-registry.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\srednoff-os-doctor.ps1" -ProjectPath . -RunEvals -FixSafe
```
