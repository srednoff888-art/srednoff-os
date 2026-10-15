# Srednoff OS Public Release Note

## October Maintenance: v2.1.2-20261015.1

**Code. Design. Advertising. 3D. Websites. UI/UX.**

By Ivan Srednoff (Иван Среднёв), [Srednoff.agency](https://srednoff.agency).

This update ports useful workflows from the Claude edition without importing
its runtime-specific hooks or pretending to switch the user's model.

| Area | Delivered |
|---|---|
| Code | React composition/performance; 16 focused Python/infra workflows |
| Design and UI/UX | Specific acceptance criteria, task-based critique, smaller triggers |
| Advertising | Read-only Google Ads MCP workflow, experiment and attribution rigor |
| 3D | Blender source-to-GLB authoring and target-viewer validation |
| Catalog | 396 installable skills; 4500 script-only capability records |
| Deployment | Native profiles, resource hashes, conflicts preserved, backup-first updater |
| Evidence | 40 routing scenarios, 25 catalog/update tests, 9 harness tests |

The structural audit passes without errors, catchall triggers, or duplicate
bodies. This is not a claim that every workflow has been independently
benchmarked on every model. The local doctor reports 45 OK, 1 historical-session
warning, and 0 failures. Exact-commit Windows/Ubuntu CI is required for publication.

See [modernization decisions](docs/skill-modernization-2026-10.md),
[Russian README](README.ru.md), and [current quality evidence](QUALITY.md).

## Original July Release

Release date: 2026-07-09

Srednoff OS v2.1.2 is a quality/cost-aware operating layer for Codex. This release closes the vNext checkpoint run and packages the public core for sharing, review, and reuse.

Stress-test hardening update, 2026-07-09: the public branch now includes a hook false-positive fix, extra regression fixtures, empty-brief/no-brief eval coverage, and a selector fast path for low-context calls.

## What Changed

| Area | Result |
|---|---|
| Startup | Compact `AGENTS.md` entrypoint with linked reference docs |
| Selector | 4500-record script-only quality/cost kernel with compact selected skill reads |
| Quality modes | `fast`, `standard`, `production`, `critical`, plus explicit `TURBO` override |
| Security | Prompt/tool preflight hooks, ask/block decisions, redacted audit logging |
| Source intake | UI/3D source registry, donor research manifest, provenance/license gates |
| Selector performance | Optional `-ProjectScan off` path for faster low-context capability selection |
| RU workflows | RU policies, bundles, agents, and safe CLI wrappers |
| NeuralDeep | Disabled registry and controlled metadata importer, no auto-install |
| Documentation | Structured public docs under `docs/` |
| CI | Windows and Ubuntu validation through GitHub Actions |

## Validation Snapshot

| Gate | Status |
|---|---:|
| Selector evals | PASS, 11/11 |
| v2.1.1 evals | PASS, 13/13 |
| v2.1.2 evals | PASS, 16/16 |
| Security fixtures | PASS, 14/14 |
| Profiles | PASS, 4/4 |
| Quality modes | PASS, 5/5 |
| Policies | PASS, 5/5 |
| Bundles | PASS, 9/9 |
| Agents | PASS, 8/8 |
| RU CLI | PASS, 4/4 |
| NeuralDeep registry | PASS, 5/5 |
| NeuralDeep importer | PASS, 5/5 |
| Kernel | PASS, 4500 records |
| Source registry | PASS, 17 sources |
| Donor research | PASS, 3 sources |
| Docs | PASS, 8 files |
| Skills smoke | PASS, 308/308 |
| Doctor | PASS, 44/44 |
| GitHub Actions | PASS, Windows and Ubuntu |

## Safety Notes

- External code, prompt, skill, MCP, CLI, and asset sources require provenance and license review.
- NeuralDeep registry entries are disabled and untrusted by default.
- RU policies are conservative review gates, not legal advice.
- Hooks reduce accidental misuse but do not replace sandboxing, secret management, or human approval.

## Entry Points

- [README](README.md)
- [Documentation portal](docs/README.md)
- [Quality evidence](QUALITY.md)
- [Changelog](CHANGELOG.md)
- [Checkpoint plan](.agent/SREDNOFF_OS_VNEXT_CHECKPOINTS.md)
