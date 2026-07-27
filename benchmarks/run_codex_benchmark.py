#!/usr/bin/env python3
"""Reproducible clean-Codex versus Srednoff OS benchmark runner.

The generated task workspaces are intentionally outside this repository. That
keeps the control arm from inheriting the repository's AGENTS.md.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import time
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parent
DEFAULT_OUTPUT = ROOT.parent.parent.parent / "codex-benchmark-runs"
ARMS = ("control", "srednoff_os")
INHERITED_CODEX_ENV_DENYLIST = {
    "CODEX_INTERNAL_ORIGINATOR_OVERRIDE",
    "CODEX_PERMISSION_PROFILE",
    "CODEX_THREAD_ID",
}
CODEX_HOME_CONTAMINANTS = (
    "AGENTS.md",
    "config.toml",
    "history.jsonl",
    "hooks.json",
    "plugins",
    "sessions",
    "skills",
)
CODEX_HOME_STATE_PATTERNS = (
    "memories_*.sqlite",
    "state_*.sqlite",
    "thread_history_*.sqlite",
)
SREDNOFF_CONTEXT_MARKERS = (
    "srednoff os",
    "srednoff-os-domain-router",
    "srednoff-os-mode-router",
    "srednoff-os-status",
)
PROHIBITED = {
    "eval": r"\beval\s*\(",
    "exec": r"\bexec\s*\(",
    "shell_true": r"shell\s*=\s*True",
    "pickle_load": r"\bpickle\.loads?\s*\(",
}


@dataclass(frozen=True)
class Task:
    task_id: str
    title: str
    function: str
    signature: str
    prompt: str
    cases: list[tuple[Any, ...]]
    expected: list[Any]


TASKS = [
    Task("longest_unique_substring", "Longest substring without repeating characters", "length_of_longest_substring", "def length_of_longest_substring(value: str) -> int:", "Return the length of the longest contiguous substring with no repeated characters. Handle an empty string.", [("abcabcbb",), ("bbbbb",), ("pwwkew",), ("",), ("dvdf",)], [3, 1, 3, 0, 3]),
    Task("product_except_self", "Product of array except self", "product_except_self", "def product_except_self(values: list[int]) -> list[int]:", "Return products of all values except the one at each index. Do not use division. Support zeros and negative integers.", [([1, 2, 3, 4],), ([0, 1, 2, 3],), ([0, 0, 3],), ([-1, 1, -1, 1],)], [[24, 12, 8, 6], [6, 0, 0, 0], [0, 0, 0], [-1, 1, -1, 1]]),
    Task("three_sum", "Three sum", "three_sum", "def three_sum(values: list[int]) -> list[list[int]]:", "Return every unique triple whose sum is zero. Each triple and the outer result must be deterministically sorted.", [([-1, 0, 1, 2, -1, -4],), ([0, 1, 1],), ([0, 0, 0, 0],)], [[[-1, -1, 2], [-1, 0, 1]], [], [[0, 0, 0]]]),
    Task("course_schedule", "Course schedule", "can_finish", "def can_finish(course_count: int, prerequisites: list[list[int]]) -> bool:", "Return whether all courses can be completed. Each pair [course, prerequisite] means prerequisite must precede course.", [(2, [[1, 0]]), (2, [[1, 0], [0, 1]]), (4, [[1, 0], [2, 1], [3, 2]])], [True, False, True]),
    Task("number_of_islands", "Number of islands", "num_islands", "def num_islands(grid: list[list[str]]) -> int:", "Return the number of 4-directionally connected islands of '1' cells. Do not mutate the caller's grid.", [([['1','1','0','0'], ['1','0','0','1'], ['0','0','1','1']],), ([['0','0'], ['0','0']],), ([],)], [2, 0, 0]),
    Task("word_break", "Word break", "word_break", "def word_break(value: str, words: list[str]) -> bool:", "Return whether value can be segmented into one or more dictionary words. Treat an empty input as segmentable.", [("leetcode", ["leet", "code"]), ("applepenapple", ["apple", "pen"]), ("catsandog", ["cats", "dog", "sand", "and", "cat"]), ("", ["a"])], [True, True, False, True]),
    Task("daily_temperatures", "Daily temperatures", "daily_temperatures", "def daily_temperatures(values: list[int]) -> list[int]:", "For each temperature, return days until a strictly warmer future temperature, or zero if none exists.", [([73,74,75,71,69,72,76,73],), ([30,40,50,60],), ([30,60,90],), ([90,80,70],)], [[1,1,4,2,1,1,0,0], [1,1,1,0], [1,1,0], [0,0,0]]),
    Task("top_k_frequent", "Top K frequent elements", "top_k_frequent", "def top_k_frequent(values: list[int], k: int) -> list[int]:", "Return the k most frequent values. Break equal-frequency ties by smaller numeric value first, so output is deterministic.", [([1,1,1,2,2,3], 2), ([4,4,1,1,2,2,3], 3), ([-1,-1,2,2,3], 2)], [[1,2], [1,2,4], [-1,2]]),
    Task("minimum_window", "Minimum window substring", "min_window", "def min_window(source: str, target: str) -> str:", "Return the shortest substring of source containing every target character with multiplicity. Return an empty string when impossible.", [("ADOBECODEBANC", "ABC"), ("a", "a"), ("a", "aa"), ("aa", "aa")], ["BANC", "a", "", "aa"]),
]


CLI_TASK_ID = "log_metrics_cli"
CLI_TASK_PROMPT = """Create a dependency-free Python CLI named log_metrics.py and tests.

Usage: python log_metrics.py <path-to-log>
Each non-empty line has the form: ISO_TIMESTAMP LEVEL message text. LEVEL is one
of DEBUG, INFO, WARN, ERROR. Ignore malformed lines. Print one JSON object to
stdout with keys total, levels (all four levels in that order-independent map),
first_timestamp, and last_timestamp. Timestamps must be compared lexically.
Never use shell commands, eval, external packages, or write files beside tests.
Exit 2 and print a concise error to stderr when the input file does not exist.
"""


def write_task(workspace: Path, task_id: str) -> None:
    workspace.mkdir(parents=True, exist_ok=True)
    if task_id == CLI_TASK_ID:
        (workspace / "TASK.md").write_text(CLI_TASK_PROMPT, encoding="utf-8")
        return
    task = next(task for task in TASKS if task.task_id == task_id)
    (workspace / "TASK.md").write_text(
        f"# {task.title}\n\n{task.prompt}\n\nImplement only `{task.function}` in `solution.py`. "
        "Use Python standard library only and add useful tests if they help you.\n",
        encoding="utf-8",
    )
    (workspace / "solution.py").write_text(
        f"{task.signature}\n    raise NotImplementedError\n", encoding="utf-8"
    )


def write_os_instructions(workspace: Path) -> None:
    instructions = """# Srednoff OS Benchmark Arm

You are operating under Srednoff OS. Before implementation, inspect TASK.md and
the current workspace. For this deliberately small benchmark task, use the
smallest useful workflow: identify edge cases, implement minimally, add or run
tests, and review the diff for security and correctness. Do not read outside
this workspace, use network tools, or introduce dependencies. Do not modify
TASK.md. Finish only after running a relevant local check.
"""
    (workspace / "AGENTS.md").write_text(instructions, encoding="utf-8")


def run_oracle(workspace: Path, task_id: str) -> tuple[bool, str, int]:
    started = time.perf_counter()
    if task_id == CLI_TASK_ID:
        sample = workspace / "hidden-sample.log"
        sample.write_text(
            "2026-07-01T10:00:00Z INFO boot\ninvalid\n2026-07-01T10:02:00Z ERROR boom\n2026-07-01T10:01:00Z WARN warm\n",
            encoding="utf-8",
        )
        completed = subprocess.run(
            [sys.executable, "log_metrics.py", str(sample)], cwd=workspace, text=True,
            capture_output=True, timeout=20,
        )
        if completed.returncode != 0:
            return False, f"cli_exit={completed.returncode}; stderr={completed.stderr[-500:]}", int((time.perf_counter() - started) * 1000)
        try:
            result = json.loads(completed.stdout)
        except json.JSONDecodeError as error:
            return False, f"invalid_json={error}", int((time.perf_counter() - started) * 1000)
        expected = {"total": 3, "levels": {"DEBUG": 0, "INFO": 1, "WARN": 1, "ERROR": 1}, "first_timestamp": "2026-07-01T10:00:00Z", "last_timestamp": "2026-07-01T10:02:00Z"}
        return result == expected, "ok" if result == expected else f"expected={expected}; actual={result}", int((time.perf_counter() - started) * 1000)

    task = next(task for task in TASKS if task.task_id == task_id)
    source = workspace / "solution.py"
    if not source.exists():
        return False, "solution.py missing", int((time.perf_counter() - started) * 1000)
    try:
        spec = importlib.util.spec_from_file_location("candidate_solution", source)
        module = importlib.util.module_from_spec(spec)
        assert spec and spec.loader
        spec.loader.exec_module(module)
        candidate = getattr(module, task.function)
        actual = [candidate(*args) for args in task.cases]
    except Exception as error:  # Oracle error is a measured runtime/API defect.
        return False, f"{type(error).__name__}: {error}", int((time.perf_counter() - started) * 1000)
    return actual == task.expected, "ok" if actual == task.expected else f"expected={task.expected!r}; actual={actual!r}", int((time.perf_counter() - started) * 1000)


def scan_security(workspace: Path) -> list[str]:
    findings: list[str] = []
    for path in workspace.rglob("*.py"):
        if path.name.startswith("hidden-"):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for rule, pattern in PROHIBITED.items():
            if re.search(pattern, text):
                findings.append(f"{path.name}:{rule}")
    return findings


def parse_trace(trace_path: Path) -> dict[str, Any]:
    commands = 0
    tokens: int | None = None
    cached_input_tokens = 0
    session_id: str | None = None
    raw_trace = trace_path.read_text(encoding="utf-8", errors="replace") if trace_path.exists() else ""
    lowered_trace = raw_trace.lower()
    contains_srednoff = any(marker in lowered_trace for marker in SREDNOFF_CONTEXT_MARKERS)
    read_only_block = "read-only sandbox" in raw_trace.lower()
    skills_context_overflow = "exceeded skills context budget" in raw_trace.lower()
    if not trace_path.exists():
        return {
            "commands": 0,
            "tokens": None,
            "cached_input_tokens": 0,
            "session_id": None,
            "contains_srednoff": False,
            "read_only_block": False,
            "skills_context_overflow": False,
        }
    for line in raw_trace.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(event, dict):
            continue
        rendered = json.dumps(event)
        item = event.get("item")
        if (
            event.get("type") == "item.completed"
            and isinstance(item, dict)
            and item.get("type") == "command_execution"
        ):
            commands += 1
        lowered_event = rendered.lower()
        contains_srednoff = contains_srednoff or any(
            marker in lowered_event for marker in SREDNOFF_CONTEXT_MARKERS
        )
        read_only_block = read_only_block or "read-only sandbox" in rendered.lower()
        skills_context_overflow = skills_context_overflow or "exceeded skills context budget" in rendered.lower()
        if not session_id:
            for key in ("thread_id", "session_id", "conversation_id"):
                if isinstance(event.get(key), str):
                    session_id = event[key]
                    break
        # The ChatGPT CLI does not expose a money amount. "tokens" is only the
        # explicit observed input + output + reasoning count from its trace.
        usage = event.get("usage")
        if isinstance(usage, dict):
            observed = [usage.get(key) for key in ("input_tokens", "output_tokens", "reasoning_output_tokens")]
            if any(isinstance(value, int) for value in observed):
                tokens = (tokens or 0) + sum(value for value in observed if isinstance(value, int))
            if isinstance(usage.get("cached_input_tokens"), int):
                cached_input_tokens += usage["cached_input_tokens"]
        for key in ("total_tokens", "tokens_total"):
            value = event.get(key)
            if isinstance(value, int):
                tokens = (tokens or 0) + value
    return {
        "commands": commands,
        "tokens": tokens,
        "cached_input_tokens": cached_input_tokens,
        "session_id": session_id,
        "contains_srednoff": contains_srednoff,
        "read_only_block": read_only_block,
        "skills_context_overflow": skills_context_overflow,
    }


def resolve_codex_executable(explicit: str | None) -> str:
    if explicit:
        resolved = shutil.which(explicit)
        if resolved:
            return resolved
        candidate = Path(explicit).expanduser()
        if candidate.is_file():
            return str(candidate.resolve())
        raise FileNotFoundError(f"Codex executable not found: {explicit}")
    for name in ("codex.cmd", "codex.exe", "codex"):
        resolved = shutil.which(name)
        if resolved:
            return resolved
    raise FileNotFoundError(
        "Codex CLI was not found on PATH. Install @openai/codex or pass --codex-executable."
    )


def validate_codex_home(codex_home: Path) -> None:
    if not codex_home.is_dir():
        raise ValueError(
            f"Dedicated CODEX_HOME does not exist: {codex_home}. "
            "Create it and authenticate Codex there before running the benchmark."
        )
    contaminants = [name for name in CODEX_HOME_CONTAMINANTS if (codex_home / name).exists()]
    for pattern in CODEX_HOME_STATE_PATTERNS:
        contaminants.extend(path.name for path in codex_home.glob(pattern))
    if contaminants:
        raise ValueError(
            "Benchmark CODEX_HOME is not clean; remove or use another directory. "
            f"Found: {', '.join(contaminants)}"
        )


def build_codex_env(codex_home: Path) -> dict[str, str]:
    environment = dict(os.environ)
    for key in list(environment):
        if key in INHERITED_CODEX_ENV_DENYLIST or key.startswith("CODEX_INTERNAL_"):
            environment.pop(key, None)
    environment["CODEX_HOME"] = str(codex_home)
    return environment


def codex_command(
    codex_executable: str,
    workspace: Path,
    model: str,
    prompt: str,
    session_id: str | None,
    windows_sandbox: str | None = None,
) -> list[str]:
    base = [
        codex_executable,
        "--sandbox",
        "workspace-write",
        "--ask-for-approval",
        "never",
    ]
    if windows_sandbox:
        base.extend(["--config", f'windows.sandbox="{windows_sandbox}"'])
    base.append("exec")
    common = [
        "--model",
        model,
        "--skip-git-repo-check",
        "--ignore-user-config",
        "--ignore-rules",
        "--json",
    ]
    if session_id:
        return [*base, "resume", *common, session_id, prompt]
    return [
        *base,
        *common,
        "--cd",
        str(workspace),
        prompt,
    ]


def execute_turn(
    workspace: Path,
    model: str,
    prompt: str,
    trace_path: Path,
    codex_executable: str,
    codex_environment: dict[str, str],
    session_id: str | None,
    windows_sandbox: str | None,
) -> tuple[int, str]:
    command = codex_command(
        codex_executable,
        workspace,
        model,
        prompt,
        session_id,
        windows_sandbox,
    )
    try:
        completed = subprocess.run(
            command,
            cwd=workspace,
            env=codex_environment,
            stdin=subprocess.DEVNULL,
            text=True,
            encoding="utf-8",
            errors="replace",
            capture_output=True,
            timeout=600,
        )
        exit_code = completed.returncode
        stdout = completed.stdout or ""
        stderr = completed.stderr or ""
    except subprocess.TimeoutExpired as error:
        exit_code = 124
        stdout = error.stdout or ""
        stderr = error.stderr or ""
        if isinstance(stdout, bytes):
            stdout = stdout.decode("utf-8", errors="replace")
        if isinstance(stderr, bytes):
            stderr = stderr.decode("utf-8", errors="replace")
        stderr = f"{stderr}\ncodex invocation timed out".strip()
    trace_path.write_text(stdout + stderr, encoding="utf-8")
    return exit_code, stderr[-1000:]


def run_one(
    output: Path,
    arm: str,
    task_id: str,
    replicate: int,
    model: str,
    max_turns: int,
    codex_executable: str,
    codex_environment: dict[str, str],
    windows_sandbox: str | None,
) -> dict[str, Any]:
    workspace = output / "workspaces" / arm / task_id / f"run-{replicate:02d}"
    if workspace.exists():
        shutil.rmtree(workspace)
    write_task(workspace, task_id)
    if arm == "srednoff_os":
        write_os_instructions(workspace)
    initial_prompt = "Read TASK.md, implement the requested solution in this workspace, and validate it locally. Do not use network or external packages."
    started = time.perf_counter()
    total_commands = 0
    total_tokens: int | None = 0
    attempts: list[dict[str, Any]] = []
    green = False
    first_pass = False
    green_at_timeout = False
    oracle_detail = "not run"
    session_id: str | None = None
    runner_invalid_reasons: list[str] = []
    for turn in range(1, max_turns + 1):
        if turn > 1 and not session_id:
            runner_invalid_reasons.append("initial CLI trace did not expose a session id")
            break
        trace_path = output / "traces" / arm / task_id / f"run-{replicate:02d}-turn-{turn}.jsonl"
        trace_path.parent.mkdir(parents=True, exist_ok=True)
        prompt = initial_prompt if turn == 1 else f"The independent hidden oracle failed: {oracle_detail}. Fix the root cause, then validate locally."
        exit_code, stderr = execute_turn(
            workspace,
            model,
            prompt,
            trace_path,
            codex_executable,
            codex_environment,
            session_id,
            windows_sandbox,
        )
        trace = parse_trace(trace_path)
        session_id = session_id or trace["session_id"]
        if exit_code not in (0, 124):
            runner_invalid_reasons.append(f"Codex CLI exited with {exit_code} on turn {turn}")
        total_commands += int(trace["commands"])
        if trace["tokens"] is None:
            total_tokens = None
        elif total_tokens is not None:
            total_tokens += int(trace["tokens"])
        passed, oracle_detail, oracle_ms = run_oracle(workspace, task_id)
        attempts.append({"turn": turn, "codex_exit": exit_code, "stderr": stderr, "oracle_pass": passed, "oracle_detail": oracle_detail, "oracle_ms": oracle_ms, "trace": trace})
        if passed:
            green = True
            green_at_timeout = exit_code == 124
            first_pass = turn == 1 and not green_at_timeout
            break
    elapsed_s = round(time.perf_counter() - started, 3)
    invalid_reasons = list(runner_invalid_reasons)
    all_traces = [attempt["trace"] for attempt in attempts]
    if arm == "control" and any(trace["contains_srednoff"] for trace in all_traces):
        invalid_reasons.append("control inherited Srednoff OS instructions")
    if any(trace["read_only_block"] for trace in all_traces):
        invalid_reasons.append("CLI policy blocked workspace writes")
    if any(trace["skills_context_overflow"] for trace in all_traces):
        invalid_reasons.append("Codex loaded an oversized external skills catalog")
    invalid_reasons = list(dict.fromkeys(invalid_reasons))
    return {
        "arm": arm, "task_id": task_id, "replicate": replicate, "model": model,
        "valid": not invalid_reasons, "invalid_reasons": invalid_reasons,
        "green": green, "first_pass": first_pass,
        "green_at_timeout": green_at_timeout,
        "timed_out": any(attempt["codex_exit"] == 124 for attempt in attempts),
        "turns_to_green": len(attempts) if green and not green_at_timeout else None,
        "attempts": attempts, "elapsed_seconds": elapsed_s, "tool_commands": total_commands,
        "tokens": total_tokens,
        "cached_input_tokens": sum(int(attempt["trace"]["cached_input_tokens"]) for attempt in attempts),
        "security_findings": scan_security(workspace),
        "hallucinated_or_runtime_defects": sum(1 for attempt in attempts if not attempt["oracle_pass"]),
        "workspace": str(workspace),
    }


def render_report(records: list[dict[str, Any]]) -> str:
    rows = [
        "| Arm | Runs | First-pass | Green | Timeouts | Avg turns to green | Avg seconds to green | Security findings | Tokens |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for arm in ARMS:
        group = [record for record in records if record["arm"] == arm]
        if not group:
            continue
        invalid = [record for record in group if not record.get("valid", True)]
        valid = [record for record in group if record.get("valid", True)]
        if not valid:
            rows.append(f"| {arm} | {len(group)} | invalid ({len(invalid)}/{len(group)}) | invalid | n/a | n/a | n/a | n/a | n/a |")
            continue
        first = sum(record["first_pass"] for record in valid) / len(valid) * 100
        green = sum(record["green"] for record in valid) / len(valid) * 100
        timeouts = sum(record.get("timed_out", False) for record in valid)
        turns = [record["turns_to_green"] for record in valid if record["turns_to_green"] is not None]
        times = [record["elapsed_seconds"] for record in valid if record["green"]]
        findings = sum(len(record["security_findings"]) for record in valid)
        token_values = [record["tokens"] for record in valid if record["tokens"] is not None]
        if len(token_values) == len(valid):
            token_cell = f"{sum(token_values) / len(token_values):.0f} avg"
        elif token_values:
            token_cell = "incomplete"
        else:
            token_cell = "not exposed"
        completed_green = sum(record["green"] and not record.get("green_at_timeout", False) for record in valid)
        turns_cell = f"{sum(turns) / len(turns):.2f}" if turns and len(turns) == completed_green else "incomplete"
        time_cell = f"{sum(times) / len(times):.2f}" if times else "n/a"
        rows.append(f"| {arm} | {len(group)} ({len(invalid)} invalid) | {first:.1f}% | {green:.1f}% | {timeouts} | {turns_cell} | {time_cell} | {findings} | {token_cell} |")
    return "\n".join(rows) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True, help="Frozen model id used by both arms")
    parser.add_argument(
        "--repeats",
        type=int,
        default=3,
        choices=range(1, 6),
        help="Replicates per arm; use 1-2 only for non-publishable harness smoke tests",
    )
    parser.add_argument("--tasks", nargs="*", default=[task.task_id for task in TASKS] + [CLI_TASK_ID])
    parser.add_argument("--max-turns", type=int, default=3, choices=range(1, 5))
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--arms", nargs="*", default=list(ARMS), choices=ARMS)
    parser.add_argument(
        "--codex-home",
        type=Path,
        default=os.environ.get("CODEX_BENCHMARK_HOME"),
        help="Dedicated authenticated CODEX_HOME with no config, AGENTS.md, hooks, plugins, or skills",
    )
    parser.add_argument(
        "--codex-executable",
        help="Path or command name for a pinned Codex CLI executable (defaults to codex on PATH)",
    )
    parser.add_argument(
        "--windows-sandbox",
        choices=("elevated", "unelevated"),
        default="unelevated" if os.name == "nt" else None,
        help="Native Windows sandbox implementation; unelevated is the portable fallback",
    )
    args = parser.parse_args()
    known = {task.task_id for task in TASKS} | {CLI_TASK_ID}
    unknown = sorted(set(args.tasks) - known)
    if unknown:
        parser.error(f"Unknown tasks: {', '.join(unknown)}")
    if args.codex_home is None:
        parser.error(
            "--codex-home is required (or set CODEX_BENCHMARK_HOME). "
            "Use a dedicated authenticated directory, not your normal Srednoff OS CODEX_HOME."
        )
    if args.windows_sandbox and os.name != "nt":
        parser.error("--windows-sandbox is only valid on native Windows")
    codex_home = args.codex_home.expanduser().resolve()
    try:
        validate_codex_home(codex_home)
        codex_executable = resolve_codex_executable(args.codex_executable)
    except (FileNotFoundError, ValueError) as error:
        parser.error(str(error))
    codex_environment = build_codex_env(codex_home)
    version_result = subprocess.run(
        [codex_executable, "--version"],
        env=codex_environment,
        stdin=subprocess.DEVNULL,
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=True,
        timeout=30,
    )
    if version_result.returncode != 0:
        parser.error(f"Codex CLI version check failed: {version_result.stderr[-500:]}")
    codex_version = version_result.stdout.strip()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    metadata = {
        "runner": "v2",
        "model": args.model,
        "repeats": args.repeats,
        "tasks": args.tasks,
        "arms": args.arms,
        "python": sys.version,
        "platform": platform.platform(),
        "codex_cli": codex_version,
        "codex_home_isolated": True,
        "windows_sandbox": args.windows_sandbox,
        "publication_ready": args.repeats >= 3,
        "started_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    (output / "metadata.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    records: list[dict[str, Any]] = []
    for arm in args.arms:
        for task_id in args.tasks:
            for replicate in range(1, args.repeats + 1):
                print(f"RUN arm={arm} task={task_id} replicate={replicate}", flush=True)
                record = run_one(
                    output,
                    arm,
                    task_id,
                    replicate,
                    args.model,
                    args.max_turns,
                    codex_executable,
                    codex_environment,
                    args.windows_sandbox,
                )
                records.append(record)
                (output / "results.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
    report = render_report(records)
    (output / "REPORT.md").write_text(report, encoding="utf-8")
    print(report)
    if args.repeats < 3:
        print(
            "WARNING: fewer than three replicates per arm; this smoke run is not publication-ready.",
            file=sys.stderr,
        )
    if any(record["tokens"] is None for record in records):
        print("WARNING: CLI trace did not expose token usage for at least one run; token comparison is intentionally omitted.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
