# Changelog

## 2026-07-09

### Changed

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
