# Changelog

## 2026-07-09

### Changed

- Converted root `AGENTS.md` into a compact Srednoff OS entrypoint and preserved the previous full rules in `.agent/SREDNOFF_OS_OPERATING_RULES.md`.
- Updated project init/sync scripts to propagate all `.agent` reference files.
- Updated project init to prefer the local package template when running from a repository checkout, with the global template as fallback.
- Removed maintainer-specific Windows home paths from the public hook rule and v2.1.1 hook eval fixture.
- Added `.agent/SREDNOFF_OS_PUBLIC_CORE_BOUNDARY.md` to define public core vs personal profile boundaries.

### Added

- Added the vNext checkpoint plan in `.agent/SREDNOFF_OS_VNEXT_CHECKPOINTS.md`.
- Added checkpoint 0 preflight audit in `.agent/SREDNOFF_OS_CHECKPOINT_0_PREFLIGHT.md`.

### Verified

- Srednoff OS status check passes for the public repo.
- Selector evals pass: 11/11.
- Kernel validation passes: 4500 records.
- Srednoff OS doctor passes: 25/25.

### Notes

- NeuralDeep HTML pages are reachable, but the roadmap API endpoints currently return 404.
- The next checkpoint is public-core cleanup of personal hardcoded paths.
