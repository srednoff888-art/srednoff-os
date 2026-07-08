# Changelog

## 2026-07-09

### Changed

- Converted root `AGENTS.md` into a compact Srednoff OS entrypoint and preserved the previous full rules in `.agent/SREDNOFF_OS_OPERATING_RULES.md`.
- Updated project init/sync scripts to propagate all `.agent` reference files.
- Updated project init/sync/install scripts to propagate the public `profiles/` layer.
- Updated project init to prefer the local package template when running from a repository checkout, with the global template as fallback.
- Updated the mode router to expose explicit `quality_mode`, validation gates, and group policy while preserving old `mode` compatibility.
- Removed maintainer-specific Windows home paths from the public hook rule and v2.1.1 hook eval fixture.
- Added `.agent/SREDNOFF_OS_PUBLIC_CORE_BOUNDARY.md` to define public core vs personal profile boundaries.

### Added

- Added the vNext checkpoint plan in `.agent/SREDNOFF_OS_VNEXT_CHECKPOINTS.md`.
- Added checkpoint 0 preflight audit in `.agent/SREDNOFF_OS_CHECKPOINT_0_PREFLIGHT.md`.
- Added `profiles/` with `public-default`, `ivan`, `agency`, and `ru-market` profile scaffolding.
- Added `srednoff-os-profile.ps1` and profile fixtures for privacy/default validation.
- Added `quality-modes.json`, `srednoff-os-quality-mode.ps1`, and quality mode fixtures for `fast`, `standard`, `production`, and `critical`.

### Verified

- Srednoff OS status check passes for the public repo.
- Selector evals pass: 11/11.
- Kernel validation passes: 4500 records.
- Profile evals pass: 4/4.
- Quality mode evals pass: 5/5.
- Srednoff OS doctor passes: 29/29.

### Notes

- NeuralDeep HTML pages are reachable, but the roadmap API endpoints currently return 404.
- The next checkpoint is security hook upgrade.
