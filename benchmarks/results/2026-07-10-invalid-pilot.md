# Invalid Pilot: 2026-07-10

This run is retained as failure evidence, not as a comparison between Codex and
Srednoff OS.

## Scope

- Task: `log_metrics_cli`
- Arms: `control`, `srednoff_os`
- Replicates: 3 per arm
- Total wall time: 577.6 seconds
- Aggregate result: 6 of 6 runs invalid

## Observed failure

| Arm | Replicate | Elapsed seconds | Invalid reason |
|---|---:|---:|---|
| control | 1 | 78.909 | Srednoff OS context inherited; workspace writes blocked |
| control | 2 | 116.527 | Srednoff OS context inherited; workspace writes blocked |
| control | 3 | 65.987 | Srednoff OS context inherited; workspace writes blocked |
| srednoff_os | 1 | 79.200 | Workspace writes blocked |
| srednoff_os | 2 | 104.727 | Workspace writes blocked |
| srednoff_os | 3 | 130.734 | Workspace writes blocked |

No first-pass, green-rate, time-to-green, or token comparison is reported.
Token telemetry became incomplete after failed resume commands.

## Root causes

1. The nested Codex process inherited piped stdin from the parent session. The
   control arm therefore received Srednoff OS context.
2. Parent `CODEX_PERMISSION_PROFILE` and related internal environment state
   contaminated the nested process and left it read-only.
3. The runner placed `--sandbox` after `codex exec resume`, where that version
   of the CLI did not accept it.
4. The runner resumed with `--last` instead of the session ID captured from the
   corresponding trace.
5. The runner hard-coded one machine's `npx.cmd` path.
6. Global skills were discovered from the personal `CODEX_HOME`, overflowing
   the skills context budget.

## Resolution

Runner v2 closes stdin, removes inherited Codex policy variables, requires a
dedicated clean `CODEX_HOME`, resolves an installed Codex executable from
`PATH`, records its version, resumes by explicit session ID, and has automated
regression tests in both CI jobs.
