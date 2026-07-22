# Srednoff OS Quality Status

This file documents what is currently verified and what is intentionally not promised.

## Current Smoke Status

Last verified: 2026-07-09.

Checkpoint 0 preflight was recorded on 2026-07-09 in `.agent/SREDNOFF_OS_CHECKPOINT_0_PREFLIGHT.md`. Checkpoints 1-13 added the public core boundary, compact entrypoint, profile system, quality modes, security hooks, RU/NeuralDeep gates, donor research validation, and structured docs. Checkpoint 14 closed the release with a full validation pass, public release note, and updated README banner. The post-release stress test added hook false-positive regressions, empty/no-brief eval coverage, and a selector fast path.

| Check | Status | Command |
|---|---:|---|
| Selector regression suite | PASS, 16/16 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-selector.ps1` |
| v2.1.1 compatibility evals | PASS, 13/13 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-v211.ps1` |
| v2.1.2 routing/source evals | PASS, 16/16 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-v212.ps1` |
| Independent security fixture evals | PASS, 14/14 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-security-fixtures.ps1` |
| Profile evals | PASS, 4/4 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-profiles.ps1` |
| Quality mode evals | PASS, 5/5 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-quality-modes.ps1` |
| Policy evals | PASS, 5/5 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-policies.ps1` |
| Bundle evals | PASS, 9/9 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-bundles.ps1` |
| Agent evals | PASS, 8/8 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-agents.ps1` |
| RU CLI evals | PASS, 4/4 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-ru-cli.ps1` |
| NeuralDeep registry evals | PASS, 5/5 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-neuraldeep-registry.ps1` |
| NeuralDeep importer evals | PASS, 5/5 | `powershell -ExecutionPolicy Bypass -File .\scripts\test-srednoff-os-neuraldeep-importer.ps1` |
| Fast skill metadata validation | PASS, 311/311 | `powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate-all-skills.ps1 -Mode fast` |
| Kernel catalog validation | PASS, 4500 records | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-quality-cost-kernel.ps1` |
| Source registry metadata validation | PASS, 17 sources | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-source-registry.ps1` |
| Donor research metadata validation | PASS, 3 sources | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-donor-research.ps1` |
| Docs validation | PASS, 8 files | `powershell -ExecutionPolicy Bypass -File .\scripts\validate-docs.ps1` |
| PowerShell parse check | PASS, 40 scripts | `Get-ChildItem .\scripts, .\integrations -Filter *.ps1 -File -Recurse` with PowerShell parser |
| Bash syntax check | PASS, 3 scripts | `bash -n scripts/init-codex-project.sh scripts/install-codex-md-os.sh .codex/skills/agentic-seo-skill/scripts/pre_commit_seo_check.sh` |
| Srednoff OS doctor | PASS, 44/44 | `powershell -ExecutionPolicy Bypass -File .\scripts\srednoff-os-doctor.ps1 -ProjectPath . -RunEvals -FixSafe` |
| GitHub Actions CI | PRESENT | `.github/workflows/ci.yml` installs ShellCheck and PSScriptAnalyzer on runners |
| Secret scan | PASS | high-confidence token/path scan before publication |
| Public release note | PRESENT | `RELEASE.md` |

## Selector Changes From Audit

- Local clone fallback: selector wrappers now prefer the repository-local `.codex/skills` and scripts before `$HOME\.codex`.
- Local skill index: `select_core_capabilities.py` can build a skill index directly from `SKILL.md` files when `skill-index.json` is not present.
- Direct aliases: explicit task terms such as `record replay`, `source ranking`, and `design brief` are surfaced even when the selected capability is broad.
- Multi-match output: `ids` format now shows up to three mapped skills so one direct match does not hide another.
- Stronger fixture semantics: selector evals now support `expectedAll`, not only `expectedAny`.
- Fast validation: skill metadata smoke checks now support YAML block scalar descriptions such as `description: >`.
- Expanded kernel: deterministic catalog generation now produces 4500 records with 75 capability slugs per domain and 1800/1800/900 Group 1/2/3 distribution.
- Selector speed: the local wrapper uses portable `.codex/skill-index.json` when present, avoiding repeated `SKILL.md` scans; the optional `-ProjectScan off` path measured about 3.7s locally for low-context interactive selection while `auto/full` remain available for richer project evidence.
- CI coverage: pull requests and pushes now run Windows PowerShell validation, Ubuntu Bash syntax/ShellCheck, kernel validation, registry validation, and eval suites.
- Source registry provenance: UI/3D source ranking now includes license, provenance, vetted status, and copy policy metadata for every registered source.
- Independent security fixtures: hook behavior is now tested from external fixture data instead of only inline/manual cases.
- Hook false-positive hardening: OpenAI key detection now avoids blocking ordinary hyphenated text such as source-ranking gate names while still blocking high-confidence key shapes.
- External prompt mining: claimed-leak and prompt-dump repositories are now handled through a provenance-first skill that extracts only abstract, vendor-neutral patterns and rejects verbatim proprietary prompt text.
- MCP migration: the selector routes `2026-07-28`, stateless transport, `server/discover`, Tasks extension, and SDK v2 requests to a compatibility-first migration workflow.
- Agentic workflow safety: `gh aw` repository automations now have a dedicated pin/compile/audit/safe-output workflow with least-privilege and untrusted-trigger gates.
- Remote skill supply chain: MCP-delivered skill archives require pinned provenance, bounded extraction, traversal protection, refresh TTLs, and no automatic script execution.
- Selector ROI: `ProjectScan=off` preserves direct task routing without repository scanning; on the 2026-07-19 fixture it averaged 0.968s versus 3.894s for `auto` while selecting the same MCP migration skill.
- Profile system: public defaults, maintainer examples, agency settings, and RU-market settings now live in a portable `profiles/` layer with privacy fixtures and doctor coverage.
- Quality modes: `fast`, `standard`, `production`, and `critical` now map task risk to selector budget, capability count, and validation gates without changing the old `normal/deep/turbo` compatibility fields.
- Security hook decisions: high-confidence secrets and destructive actions are blocked, externally visible or bypass-prone actions ask for confirmation, and audit entries store findings plus input hashes without raw prompt/tool input.
- RU policies: Russian-market data, payments, messaging, marketplace, and NeuralDeep/source-import work now has local policy gates with deterministic fixtures.
- RU bundles: Russian-market SEO, marketplaces, enterprise, 1C, LLM, content, payments, messaging, and DevOps workflows now have disabled selector metadata presets.
- RU agents: specialist markdown profiles now provide compact role lenses linked to bundles, policies, and existing skills.
- RU CLI wrappers: search/audit/import/install compatibility scripts are read-only or recommendation-only and do not install external tools.
- Donor research manifest: claimed-leak and prompt-archive donor repos now have machine-readable provenance, risk, accepted-pattern, rejected-pattern, and copy-policy gates.
- Structured public docs: `docs/` now separates architecture, security, workflows, profiles, RU/NeuralDeep, risk, and validation docs with a deterministic docs validator.
- Public release layer: `RELEASE.md`, checkpoint 14 notes, and the GitHub README banner now summarize the validated public package.
- NeuralDeep registry: candidate skills, MCP servers, and CLI tools are represented as disabled metadata with trust report and import log structure; nothing is installed or enabled.
- NeuralDeep importer: local manifests can be imported as disabled metadata only after license, provenance, HTTPS source, duplicate, and trust-score checks.

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
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-policies.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-bundles.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-agents.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-ru-cli.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-neuraldeep-registry.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-neuraldeep-importer.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\quick-validate-all-skills.ps1" -Mode fast
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-quality-cost-kernel.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-source-registry.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-donor-research.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\validate-docs.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\srednoff-os-doctor.ps1" -ProjectPath . -RunEvals -FixSafe
```
