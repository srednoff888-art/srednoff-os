# Srednoff OS Quality Status

This file documents what is currently verified and what is intentionally not promised.

## Current Smoke Status

Last verified: 2026-07-01.

| Check | Status | Command |
|---|---:|---|
| Selector regression suite | PASS, 8/8 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-selector.ps1` |
| v2.1.1 compatibility evals | PASS, 13/13 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-v211.ps1` |
| v2.1.2 routing/source evals | PASS, 9/9 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-v212.ps1` |
| Fast skill metadata validation | PASS, 306/306 | `powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate-all-skills.ps1 -Mode fast` |
| Kernel catalog validation | PASS, 3000 records | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-quality-cost-kernel.ps1` |
| PowerShell parse check | PASS, 20 scripts | `Get-ChildItem .\scripts -Filter *.ps1` with PowerShell parser |
| Secret scan | PASS | high-confidence token/path scan before publication |

## Selector Changes From Audit

- Local clone fallback: selector wrappers now prefer the repository-local `.codex/skills` and scripts before `$HOME\.codex`.
- Local skill index: `select_core_capabilities.py` can build a skill index directly from `SKILL.md` files when `skill-index.json` is not present.
- Direct aliases: explicit task terms such as `record replay`, `source ranking`, and `design brief` are surfaced even when the selected capability is broad.
- Multi-match output: `ids` format now shows up to three mapped skills so one direct match does not hide another.
- Stronger fixture semantics: selector evals now support `expectedAll`, not only `expectedAny`.
- Fast validation: skill metadata smoke checks now support YAML block scalar descriptions such as `description: >`.

## What This Does Not Promise

- It does not make Codex, Claude, or any model obey instructions with mathematical certainty.
- It does not replace platform-level permissions, sandboxing, secret management, or human approval.
- It does not prove all 3000 kernel records are individually optimal.
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
powershell -ExecutionPolicy Bypass -File ".\scripts\quick-validate-all-skills.ps1" -Mode fast
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-quality-cost-kernel.ps1"
```
