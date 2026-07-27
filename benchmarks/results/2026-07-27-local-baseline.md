# Local Benchmark Baseline: 2026-07-27

This is a limited local baseline, not proof that either arm is generally
better. It is retained so independent runners can compare methodology and
results without relying on a marketing claim.

## Frozen Environment

| Variable | Value |
|---|---|
| Task | `log_metrics_cli` |
| Model | `gpt-5.4` |
| Codex CLI | `0.146.0-alpha.3.1` |
| Platform | Windows 10 `10.0.19045` |
| Native sandbox | `unelevated`, workspace-write |
| Control | Dedicated clean Codex home; no AGENTS, config, hooks, plugins, skills, or parent stdin |
| OS arm | Same environment plus task-local compact Srednoff OS instructions |
| Oracle | Hidden deterministic Python CLI check |

## Aggregate

| Arm | Runs | First-pass | Green | Timeouts | Avg seconds to green | Observed tokens | Security findings |
|---|---:|---:|---:|---:|---:|---:|---:|
| control | 3 | 100.0% | 100.0% | 0 | 94.51 | 77,972 average | 0 |
| srednoff_os | 3 | 66.7% | 100.0% | 1 | 354.35 | incomplete | 0 |

For the two completed non-timeout OS runs, average time was 167.58 seconds and
average observed tokens were 117,628. The third OS run produced an
oracle-passing workspace but the Codex invocation exceeded the 600-second turn
limit, so it is `green_at_timeout`, not first-pass, and its token telemetry is
unavailable.

## Per-Run Evidence

| Arm | Run | First-pass | Green | Seconds | Tokens |
|---|---:|---:|---:|---:|---:|
| control | 1 | yes | yes | 97.332 | 68,903 |
| control | 2 | yes | yes | 80.098 | 70,353 |
| control | 3 | yes | yes | 106.102 | 94,660 |
| srednoff_os | 1 | yes | yes | 153.385 | 97,977 |
| srednoff_os | 2 | yes | yes | 181.765 | 137,278 |
| srednoff_os | 3 | no, timeout | yes at timeout | 727.912 | unavailable |

## Interpretation

On this small deterministic task, Srednoff OS produced no correctness or
security improvement because both arms were already perfect on the hidden
oracle. Its workflow added substantial latency and observed token cost, and one
run did not finish before timeout. This is evidence that the selector needs a
stricter micro-task fast lane.

The result does not answer whether Srednoff OS helps on repository repair,
security-sensitive changes, migrations, ambiguous requirements, or multi-file
tasks. Those need separate representative corpora and independent reruns.

## Provenance Note

The original six-run process saved five complete records before a JSONL parser
bug stopped aggregation. The missing OS replicate was rerun in a fresh,
metadata-matched Codex home. The replacement timed out after producing an
oracle-passing workspace. No failed or expensive result was discarded.
