# Benchmark and Selector Improvement Plan

This plan is driven by the 2026-07-27 local baseline. It prioritizes measured
ROI and prevents a policy prompt from being presented as the full Srednoff OS.

## P0: Measurement Integrity

| Work | Why | Acceptance criterion |
|---|---|---|
| Add atomic per-run records and `--resume-output` | A parser crash stopped aggregation after five valid runs | Interrupted runs resume only missing cells after immutable metadata validation |
| Kill the complete child process tree on timeout | Windows cleanup extended a 600-second timeout to 728 seconds | Wall-time overshoot is below 10 seconds on Windows and Linux |
| Pin stable Codex CLI releases | The local run used `0.146.0-alpha.3.1` | Metadata rejects prerelease/stable mixing and records executable hash |
| Randomize or alternate arm order | Sequential control-first runs can absorb time/rate-limit drift | Seeded order is stored in metadata and reproducible |
| Add confidence intervals | Three runs are a pilot, not statistical proof | Reports include sample size, median, dispersion, and bootstrap interval |

## P0: Correct Arm Definitions

| Arm | Definition | Required isolation |
|---|---|---|
| `control` | Codex with task prompt only | Clean Codex home, no external instructions or skills |
| `policy_arm` | Control plus compact task-local Srednoff OS guidance | Same model, CLI, sandbox, task, and oracle |
| `full_os` | Startup check, router, selector, selected skills, hooks, and validation gates | Frozen Srednoff OS commit and script-only kernel |

The current benchmark covers `control` and `policy_arm`. It does not yet prove
the effect of the full Srednoff OS runtime.

## P0: Micro-Task Fast Lane

The first local baseline found equal correctness and zero security findings,
while the policy arm used more time and observed tokens and had one timeout.

Add a deterministic fast lane when all conditions are true:

- one small file or one isolated function;
- no auth, payments, secrets, production, migration, external API, or data-loss risk;
- deterministic local oracle exists;
- no dependency or architecture choice;
- no external research required.

Fast-lane limits:

- maximum four selected capabilities, Group 1 first;
- no agents, GitHub research, broad repository scan, or full doctor;
- one focused implementation pass and one focused validation command;
- no documentation churn unless public behavior changes.

Acceptance criterion: on the micro-task corpus, policy/full OS median token use
must be within 10% of control unless first-pass success improves by at least
five percentage points.

## P1: Representative Corpus

Add pinned, license-reviewed tasks in separate tranches:

1. Single-function algorithms.
2. Small CLI and data parsing.
3. Realistic multi-file bug repair.
4. TypeScript/React UI behavior with screenshot and accessibility oracle.
5. PowerShell/Bash cross-platform defects.
6. Security-sensitive input validation.
7. Dependency upgrade and CI failure triage.
8. Ambiguous requirements requiring a compact brief.

Each task needs a starting commit, allowed tools, hidden oracle, timeout,
license, expected risk class, and manual review rubric.

## P1: ROI Telemetry

- Store input, cached input, output, and reasoning tokens separately.
- Report completed-turn and timeout token telemetry separately.
- Record tool calls by completed command, file edits, tests, and failed actions.
- Report median time/token deltas, not only averages.
- Compare selector modes `lean`, `balanced`, `deep`, and literal `TURBO`.
- Add a `quality_gain / incremental_token_cost` score only after deterministic
  pass/fail and safety metrics.

## P1: Cross-Platform Reproduction

Run the same frozen matrix on:

- Windows 11 elevated sandbox;
- Windows unelevated fallback;
- Ubuntu or another supported Linux runner;
- WSL2 when Windows-native tooling is not required.

Never aggregate different sandbox modes or CLI versions. Publish each
environment separately before any combined analysis.

## P2: Stronger Oracles

- Add mutation tests to prove fixtures detect seeded wrong implementations.
- Add Bandit/Semgrep-style security checks where licensing and dependencies are
  acceptable.
- Add diff minimality, maintainability, and test-quality rubrics.
- Keep deterministic failures separate from human reviewer scores.
- Add adversarial task text and irrelevant-file noise to test instruction
  hierarchy and context discipline.

## Exit Criteria for Public Claims

Do not claim Srednoff OS is better than ordinary Codex until:

- at least three representative tranches pass independent reruns;
- every arm has at least ten valid runs per tranche;
- stable CLI/model/sandbox metadata match;
- confidence intervals and invalid-run counts are published;
- full OS and policy-only effects are reported separately;
- raw sanitized traces or reproducible hashes are available;
- negative results remain visible.
