# Changelog

## 2026-07-09

### Changed

- Converted root `AGENTS.md` into a compact Srednoff OS entrypoint and preserved the previous full rules in `.agent/SREDNOFF_OS_OPERATING_RULES.md`.
- Updated project init/sync scripts to propagate all `.agent` reference files.
- Updated project init/sync/install scripts to propagate the public `profiles/` layer.
- Updated project init to prefer the local package template when running from a repository checkout, with the global template as fallback.
- Updated the mode router to expose explicit `quality_mode`, validation gates, and group policy while preserving old `mode` compatibility.
- Updated the Srednoff OS hook with deny/ask/allow decisions, expanded high-confidence secret patterns, stronger destructive command detection, and redacted audit logging.
- Updated install/init/sync and doctor to propagate and validate `policies/`.
- Updated install/init/sync and doctor to propagate and validate `registry/`.
- Updated install/init/sync and doctor to propagate and validate `integrations/`.
- Updated install/init/sync and doctor to propagate and validate `bundles/`.
- Updated install/init/sync and doctor to propagate and validate `agents/`.
- Removed maintainer-specific Windows home paths from the public hook rule and v2.1.1 hook eval fixture.
- Added `.agent/SREDNOFF_OS_PUBLIC_CORE_BOUNDARY.md` to define public core vs personal profile boundaries.

### Added

- Added the vNext checkpoint plan in `.agent/SREDNOFF_OS_VNEXT_CHECKPOINTS.md`.
- Added checkpoint 0 preflight audit in `.agent/SREDNOFF_OS_CHECKPOINT_0_PREFLIGHT.md`.
- Added `profiles/` with `public-default`, `ivan`, `agency`, and `ru-market` profile scaffolding.
- Added `srednoff-os-profile.ps1` and profile fixtures for privacy/default validation.
- Added `quality-modes.json`, `srednoff-os-quality-mode.ps1`, and quality mode fixtures for `fast`, `standard`, `production`, and `critical`.
- Added checkpoint 5 security hook research notes in `.agent/SREDNOFF_OS_CHECKPOINT_5_SECURITY_HOOK_RESEARCH.md`.
- Added RU and NeuralDeep risk policies in `policies/*.yml`.
- Added `srednoff-os-policy-check.ps1` and policy fixtures.
- Added checkpoint 6 RU policy research notes in `.agent/SREDNOFF_OS_CHECKPOINT_6_RU_POLICY_RESEARCH.md`.
- Added disabled NeuralDeep registry skeleton in `registry/neuraldeep/`.
- Added `test-srednoff-os-neuraldeep-registry.ps1` and NeuralDeep registry fixtures.
- Added checkpoint 7 NeuralDeep registry notes in `.agent/SREDNOFF_OS_CHECKPOINT_7_NEURALDEEP_REGISTRY.md`.
- Added controlled NeuralDeep metadata importer in `integrations/neuraldeep/`.
- Added `test-srednoff-os-neuraldeep-importer.ps1` and importer fixture manifest.
- Added checkpoint 8 NeuralDeep importer notes in `.agent/SREDNOFF_OS_CHECKPOINT_8_NEURALDEEP_IMPORTER.md`.
- Added RU domain bundles in `bundles/*.json`.
- Added `test-srednoff-os-bundles.ps1` for bundle metadata validation.
- Added checkpoint 9 RU bundle notes in `.agent/SREDNOFF_OS_CHECKPOINT_9_RU_BUNDLES.md`.
- Added RU specialist agent profiles in `agents/*.md`.
- Added `test-srednoff-os-agents.ps1` for agent profile validation.
- Added checkpoint 10 RU agent notes in `.agent/SREDNOFF_OS_CHECKPOINT_10_RU_AGENTS.md`.

### Verified

- Srednoff OS status check passes for the public repo.
- Selector evals pass: 11/11.
- Kernel validation passes: 4500 records.
- Profile evals pass: 4/4.
- Quality mode evals pass: 5/5.
- Security fixture evals pass: 12/12.
- Policy evals pass: 5/5.
- Bundle evals pass: 9/9.
- Agent evals pass: 8/8.
- NeuralDeep registry evals pass: 5/5.
- NeuralDeep importer evals pass: 5/5.
- Srednoff OS doctor passes: 39/39.

### Notes

- NeuralDeep HTML pages are reachable, but the roadmap API endpoints currently return 404.
- The next checkpoint is RU CLI compatibility scripts.
