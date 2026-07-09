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
- Updated install/init/sync and doctor to propagate and validate `docs/`.
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
- Added safe RU CLI compatibility wrappers in `scripts/srednoff-os-ru-*.ps1`.
- Added `test-srednoff-os-ru-cli.ps1` for read-only/recommendation-only wrapper validation.
- Added checkpoint 11 RU CLI notes in `.agent/SREDNOFF_OS_CHECKPOINT_11_RU_CLI.md`.
- Added donor repository research manifest in `.codex/srednoff-os/donor-research.json`.
- Added `validate-donor-research.ps1` for clean-room donor provenance validation.
- Added checkpoint 12 donor research notes in `.agent/SREDNOFF_OS_CHECKPOINT_12_DONOR_RESEARCH.md`.
- Added structured public documentation under `docs/`.
- Added `validate-docs.ps1` for documentation presence and index validation.
- Added checkpoint 13 documentation notes in `.agent/SREDNOFF_OS_CHECKPOINT_13_DOCUMENTATION.md`.
- Added public release note in `RELEASE.md`.
- Added checkpoint 14 release closure notes in `.agent/SREDNOFF_OS_CHECKPOINT_14_RELEASE.md`.
- Updated the GitHub README and banner for the public release.
- Improved README Mermaid diagrams for readability and added a Russian-language overview section.
- Hardened OpenAI key detection to avoid false positives on ordinary hyphenated text.
- Added selector `ProjectScan` modes with a fast `off` path for low-context capability selection.
- Updated README About and Release sections for the public GitHub page.

### Verified

- Srednoff OS status check passes for the public repo.
- Selector evals pass: 11/11.
- Kernel validation passes: 4500 records.
- Profile evals pass: 4/4.
- Quality mode evals pass: 5/5.
- v2.1.2 evals pass: 16/16.
- Security fixture evals pass: 14/14.
- Policy evals pass: 5/5.
- Bundle evals pass: 9/9.
- Agent evals pass: 8/8.
- RU CLI evals pass: 4/4.
- Donor research validation passes: 3 sources.
- Docs validation passes: 8 files.
- NeuralDeep registry evals pass: 5/5.
- NeuralDeep importer evals pass: 5/5.
- Srednoff OS doctor passes: 44/44.
- GitHub Actions pass on Windows and Ubuntu for the public release.

### Notes

- NeuralDeep HTML pages are reachable, but the roadmap API endpoints currently return 404.
- The vNext checkpoint run is closed.
