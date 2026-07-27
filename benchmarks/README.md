# Reproducible Codex Benchmark

This benchmark measures a clean Codex CLI control against the Srednoff OS policy
arm. It deliberately does not call the control arm "raw" unless it meets all
of the conditions below.

## What is controlled

- identical model, CLI version, task prompt, time limit, and machine;
- a fresh Codex session for every `task x arm x replicate` run;
- hidden, deterministic Python oracles that are outside the agent workspace;
- no project `AGENTS.md`, user config, or rules in the control arm;
- a task-local Srednoff OS `AGENTS.md` in the OS arm;
- JSONL traces, elapsed time, tool-command count, validation output, and source
  diff retained under the run output directory.

The initial corpus contains nine medium algorithmic tasks and one reproducible
CLI task. The separate OSS-repair tranche is intentionally not counted until
each upstream repository, commit, license, environment, and oracle are pinned.
That avoids calling a hand-written toy regression an open-source bugfix.

## Metrics

| Metric | Definition |
|---|---|
| First-pass success | Hidden oracle passes immediately after the initial agent turn. |
| Turns to green | Initial turn plus resumptions after an oracle failure; capped by `--max-turns`. |
| Security findings | Static prohibited-pattern findings plus manual-review findings. |
| Hallucinated API / runtime defects | Import, attribute, syntax, command, and oracle execution failures. |
| Observed tokens | CLI-reported `input + output + reasoning`; cached input is retained separately. This is not a money amount. |
| Time to green | Wall time from the initial call until the hidden oracle first passes. |
| Timeout | A measured model/CLI outcome, not automatically an invalid environment. A green oracle after timeout is recorded as `green_at_timeout`, not first-pass. |

An unsuccessful run is not silently dropped. It remains in the aggregate with
`first_pass=false`, `green=false`, and its real elapsed time.

## Run a pilot

Use a dedicated Codex home for the benchmark. It must contain authentication,
but no `AGENTS.md`, `config.toml`, hooks, plugins, or skills. This prevents both
arms from inheriting personal Srednoff OS state.

Authenticate once on Windows:

```powershell
$benchmarkHome = Join-Path $env:LOCALAPPDATA "SrednoffCodexBenchmark"
New-Item -ItemType Directory -Force -Path $benchmarkHome | Out-Null
$env:CODEX_HOME = $benchmarkHome
codex login
```

Authenticate once on macOS or Linux:

```bash
export CODEX_BENCHMARK_HOME="$HOME/.codex-benchmark-clean"
mkdir -p "$CODEX_BENCHMARK_HOME"
CODEX_HOME="$CODEX_BENCHMARK_HOME" codex login
```

Treat the resulting `auth.json` like a password. Never commit, upload, or share
the benchmark home.

From the repository root, run the Windows pilot:

```powershell
python benchmarks/run_codex_benchmark.py `
  --model gpt-5.4 `
  --repeats 3 `
  --tasks log_metrics_cli `
  --codex-home $benchmarkHome
```

Run the complete algorithmic corpus:

```powershell
python benchmarks/run_codex_benchmark.py `
  --model gpt-5.4 `
  --repeats 3 `
  --codex-home $benchmarkHome
```

On macOS or Linux, pass `--codex-home "$CODEX_BENCHMARK_HOME"`.

The runner resolves `codex` from `PATH`, records the exact CLI version, closes
stdin, strips parent Codex policy variables, applies `workspace-write` with
non-interactive `never` approvals at the root CLI layer, and resumes by explicit
session ID. Use `--codex-executable` to pin another installed executable.
Results are written outside this repository by default, so the control
workspace cannot inherit this repository's `AGENTS.md`.

On native Windows, the runner records and defaults to
`--windows-sandbox unelevated`, the documented fallback when elevated sandbox
setup is unavailable. Use `--windows-sandbox elevated` only after that sandbox
has been configured successfully. Do not mix the two modes in one comparison.

Before a publishable comparison, run the harness regressions:

```powershell
python -m unittest discover -s benchmarks -p "test_*.py" -v
```

For a cheap harness-only smoke, pass `--repeats 1`. The output metadata will
record `publication_ready=false`; never publish that run as a comparison.

## Validity rules

- Do not compare different models, CLI versions, reasoning settings, or
  sandboxes.
- A control trace containing `Srednoff OS` or a policy-denied workspace write
  is invalid and must not enter an aggregate.
- A trace with an external skills-context overflow is invalid.
- Reusing a benchmark home that already contains memory, session, history, or
  state databases is invalid. Authenticate in a fresh dedicated directory for
  each published comparison.
- A run from a normal personal `CODEX_HOME` is invalid even when
  `--ignore-user-config` is present; that flag does not make global
  `AGENTS.md`, hooks, plugins, or skills a valid benchmark input.
- Do not use model self-reports as a correctness signal.
- Do not report a proxy control as unmodified Codex.
- Do not aggregate runs that terminated because auth, network, or the runner
  itself failed; record them as invalid instead.
- Do not classify a model/CLI timeout as an infrastructure failure by default.
  Preserve partial traces and report timeout counts separately.
- Review every green diff for prohibited patterns before publishing a claim.

The runner prints an explicit warning if the CLI trace lacks token telemetry.
It does not estimate a monetary cost for a ChatGPT subscription.

## Recorded runs

| Run | Status | Meaning |
|---|---|---|
| [2026-07-10 invalid pilot](results/2026-07-10-invalid-pilot.md) | Invalid | Captured the isolation and resume defects that runner v2 fixes; contains no comparative claim. |
