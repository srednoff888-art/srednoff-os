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

An unsuccessful run is not silently dropped. It remains in the aggregate with
`first_pass=false`, `green=false`, and its real elapsed time.

## Run a pilot

From the repository root:

```powershell
python benchmarks/run_codex_benchmark.py --model gpt-5.4 --repeats 3 --tasks log_metrics_cli
```

Run the complete algorithmic corpus:

```powershell
python benchmarks/run_codex_benchmark.py --model gpt-5.4 --repeats 3
```

The runner uses `npx @openai/codex`. It requires an authenticated official
Codex CLI account. Results are written outside this repository by default, so
the control workspace cannot inherit this repository's `AGENTS.md`.

## Validity rules

- Do not compare different models, CLI versions, reasoning settings, or
  sandboxes.
- A control trace containing `Srednoff OS` or a policy-denied workspace write
  is invalid and must not enter an aggregate.
- Do not use model self-reports as a correctness signal.
- Do not report a proxy control as unmodified Codex.
- Do not aggregate runs that terminated because auth, network, or the runner
  itself failed; record them as invalid instead.
- Review every green diff for prohibited patterns before publishing a claim.

The runner prints an explicit warning if the CLI trace lacks token telemetry.
It does not estimate a monetary cost for a ChatGPT subscription.
