# Srednoff OS Checkpoint 0 Preflight

Date: 2026-07-09
Repository: https://github.com/srednoff888-art/srednoff-os
Baseline commit before checkpoint: `7a1ee44 Add safe external prompt pattern mining`

## Scope

This checkpoint records the state of Srednoff OS before the vNext roadmap work begins. It does not move runtime code. It creates a durable baseline for the next checkpoints.

## Local System Baseline

| Area | Finding |
|---|---|
| Srednoff OS status | `Srednoff OS v2.1.2 loaded: OK | project=OK | skills=308 | kernel=4500 | selector=True` |
| Public repo skills | 308 local `.codex/skills` directories |
| Global local skills | 313 after global install, because user-local system skills exist outside the public repo |
| Kernel | 4500 records, 3300 skills, 1200 agents, 60 domains |
| Source watchlist | 23 sources |
| Design source registry | 17 sources |
| Scripts | 24 files in `scripts/` |
| Evals | 4 fixture files in `evals/` |
| CI | `.github/workflows/ci.yml` with Windows and Ubuntu validation |

## Existing Validation Evidence

| Check | Result |
|---|---|
| Status check | PASS |
| Selector evals | PASS, 11/11 |
| Kernel validation | PASS, 4500 records |
| Srednoff OS doctor | PASS, 25/25 |

Full release-gate validation should run after each behavior-changing checkpoint. Checkpoint 0 only adds audit and roadmap documentation, but the full doctor was still green after the documentation change.

## Current Architecture Shape

The public repository currently has a compact layout:

| Path | Role |
|---|---|
| `.agent/` | Planning, quality, briefing, and research documents |
| `.codex/skills/` | Skill catalog and skill-local scripts |
| `.codex/srednoff-os/` | Version, source watchlist, and design source registry |
| `scripts/` | PowerShell and Bash operational scripts |
| `evals/` | Selector, router, and security fixtures |
| `.github/workflows/ci.yml` | Windows and Ubuntu CI |

The target vNext layout from the roadmap is not present yet as top-level folders. These directories currently do not exist: `core/`, `cli/`, `integrations/`, `workflows/`, `agents/`, `skills/`, `plugins/`, `policies/`, `hooks/`, `registry/`, `profiles/`, `bundles/`, `context/`, `docs/`.

Recommendation: migrate in layers. Do not move working scripts into the target layout until wrappers, docs, and CI coverage exist.

## Public Core Boundary Findings

| Finding | Risk | Next checkpoint |
|---|---|---|
| `scripts/srednoff-os-hook.ps1` contained a literal maintainer-specific Windows home path guard | Medium public-core hygiene risk. It was protective, but user-specific. | Resolved in checkpoint 1 with user-home/environment-aware matching |
| `scripts/test-srednoff-os-v211.ps1` used maintainer-specific Windows fixture paths | Low-medium portability risk. Test fixture was not a secret, but it was machine-specific. | Resolved in checkpoint 1 with temp-path fixtures |
| README intentionally contains Ivan Srednoff author and `Srednoff.agency` | Intended branding, not a privacy defect | Keep |
| GitHub remote points to `srednoff888-art/srednoff-os` | Intended public repo | Keep |

## NeuralDeep Availability Check

Checked on 2026-07-09.

| Source | Result | Impact |
|---|---|---|
| `https://neuraldeep.ru/api/skills` | 404 | Importer must not assume this API exists |
| `https://neuraldeep.ru/api/skills?q=яндекс` | 404 | Search importer needs fallback |
| `https://neuraldeep.ru/api/skills?sort=trending` | 404 | Trending importer needs fallback |
| `https://neuraldeep.ru/api/mcp` | 404 | MCP importer needs fallback |
| `https://neuraldeep.ru/api/cli` | 404 | CLI importer needs fallback |
| `https://neuraldeep.ru/skills` | 200 HTML, about 183 KB, about 50 GitHub links detected | HTML parsing is currently the real source |
| `https://neuraldeep.ru/mcp` | 200 HTML, about 80 KB, about 56 GitHub links detected | HTML parsing is currently the real source |
| `https://neuraldeep.ru/cli` | 200 HTML, about 26 KB, about 3 GitHub links detected | HTML parsing is currently the real source |
| `vakovalskii/neuraldeep` | GitHub repository not resolved by `gh repo view` | Treat repo URL as unverified until a working repo is found |

## Donor Repository Availability Snapshot

This is availability metadata only, not final research.

| Repo | Status | Stars at check | License signal | Last push at check |
|---|---|---:|---|---|
| `Yeachan-Heo/oh-my-codex` | Found | 31786 | NOASSERTION | 2026-07-08 |
| `alexandrbasis/codexops` | Found | 1 | empty | 2026-04-30 |
| `Dmatut7/codex-flow` | Found | 8 | empty | 2026-06-05 |
| `fcakyon/claude-codex-settings` | Found | 767 | empty | 2026-07-08 |
| `BaseInfinity/codex-sdlc-wizard` | Found | 9 | NOASSERTION | 2026-06-09 |
| `BaseInfinity/codex-rdlc-wizard` | Found | 0 | NOASSERTION | 2026-05-18 |
| `falcosecurity/prempti` | Found | 175 | empty | 2026-07-06 |
| `shinpr/sub-agents-skills` | Found | 58 | empty | 2026-07-07 |
| `shinpr/sub-agents-mcp` | Found | 92 | empty | 2026-07-08 |
| `shanraisshan/codex-cli-hooks` | Found | 60 | NOASSERTION | 2026-06-04 |
| `agentsmd/agents.md` | Found | 22893 | empty | 2026-03-12 |
| `openai/skills` | Found | 23394 | NOASSERTION | 2026-06-24 |
| `ComposioHQ/awesome-codex-skills` | Found | 14722 | NOASSERTION | 2026-05-15 |
| `VoltAgent/awesome-agent-skills` | Found | 27621 | empty | 2026-06-30 |
| `affaan-m/ecc` | Found as `affaan-m/ECC` | 227397 | empty | 2026-07-08 |
| `affaan-m/everything-claude-code` | Resolved to `affaan-m/ECC` by GitHub CLI | 227397 | empty | 2026-07-08 |

License signal `empty` or `NOASSERTION` is not approval to copy. The donor checkpoint must review license files and code provenance before adapting any pattern.

## Immediate Risks

| Priority | Risk | Why it matters | Recommended checkpoint |
|---|---|---|---|
| High | Personal hardcoded paths remain in public scripts/tests | Blocks clean public core and reusable template claim | 1 |
| High | NeuralDeep API contract in roadmap is not currently true | Importer design must support HTML fallback and source drift | 7, 8 |
| Medium | AGENTS.md is still large and context-heavy | It works, but is not yet a compact entrypoint | 2 |
| Medium | Target architecture directories are absent | Migration needs compatibility wrappers and CI before moving files | 3-14 |
| Medium | RU integrations have no dedicated policies yet | Any marketplace/payment/messaging connector needs strict default-deny posture | 6 |
| Low-medium | Donor repo license metadata is often unclear | Clean-room adaptation only; no direct code import | 12 |

## Decision

Proceed checkpoint by checkpoint. Start with checkpoint 1: remove public-core hardcoded personal paths and establish the personal profile boundary before adding NeuralDeep registry or new RU policies.
