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
    contains_srednoff = "srednoff" in raw_trace.lower()
    read_only_block = "read-only sandbox" in raw_trace.lower()
    if not trace_path.exists():
        return {"commands": 0, "tokens": None, "session_id": None}
    for line in raw_trace.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        rendered = json.dumps(event)
        if "command_execution" in rendered:
            commands += 1
        contains_srednoff = contains_srednoff or "srednoff" in rendered.lower()
        read_only_block = read_only_block or "read-only sandbox" in rendered.lower()
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
    }


def codex_command(workspace: Path, model: str, prompt: str, resume: bool) -> list[str]:
    base = [r"G:\Program Files\npx.cmd", "--yes", "@openai/codex", "exec"]
    if resume:
        return base + ["resume", "--last", "--sandbox", "workspace-write", prompt]
    return base + ["--model", model, "--cd", str(workspace), "--sandbox", "workspace-write", "--skip-git-repo-check", "--ignore-user-config", "--ignore-rules", "--json", prompt]


def execute_turn(workspace: Path, model: str, prompt: str, trace_path: Path, resume: bool) -> tuple[int, str]:
    command = codex_command(workspace, model, prompt, resume)
    completed = subprocess.run(
        command,
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=True,
        timeout=600,
    )
    stdout = completed.stdout or ""
    stderr = completed.stderr or ""
    trace_path.write_text(stdout + stderr, encoding="utf-8")
    return completed.returncode, stderr[-1000:]


def run_one(output: Path, arm: str, task_id: str, replicate: int, model: str, max_turns: int) -> dict[str, Any]:
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
    oracle_detail = "not run"
    for turn in range(1, max_turns + 1):
        trace_path = output / "traces" / arm / task_id / f"run-{replicate:02d}-turn-{turn}.jsonl"
        trace_path.parent.mkdir(parents=True, exist_ok=True)
        prompt = initial_prompt if turn == 1 else f"The independent hidden oracle failed: {oracle_detail}. Fix the root cause, then validate locally."
        try:
            exit_code, stderr = execute_turn(workspace, model, prompt, trace_path, resume=turn > 1)
        except subprocess.TimeoutExpired:
            exit_code, stderr = 124, "codex invocation timed out"
        trace = parse_trace(trace_path)
        total_commands += int(trace["commands"])
        if trace["tokens"] is None:
            total_tokens = None
        elif total_tokens is not None:
            total_tokens += int(trace["tokens"])
        passed, oracle_detail, oracle_ms = run_oracle(workspace, task_id)
        attempts.append({"turn": turn, "codex_exit": exit_code, "stderr": stderr, "oracle_pass": passed, "oracle_detail": oracle_detail, "oracle_ms": oracle_ms, "trace": trace})
        if passed:
            green = True
            first_pass = turn == 1
            break
    elapsed_s = round(time.perf_counter() - started, 3)
    invalid_reasons: list[str] = []
    all_traces = [attempt["trace"] for attempt in attempts]
    if arm == "control" and any(trace["contains_srednoff"] for trace in all_traces):
        invalid_reasons.append("control inherited Srednoff OS instructions")
    if any(trace["read_only_block"] for trace in all_traces):
        invalid_reasons.append("CLI policy blocked workspace writes")
    return {
        "arm": arm, "task_id": task_id, "replicate": replicate, "model": model,
        "valid": not invalid_reasons, "invalid_reasons": invalid_reasons,
        "green": green, "first_pass": first_pass, "turns_to_green": len(attempts) if green else None,
        "attempts": attempts, "elapsed_seconds": elapsed_s, "tool_commands": total_commands,
        "tokens": total_tokens,
        "cached_input_tokens": sum(int(attempt["trace"]["cached_input_tokens"]) for attempt in attempts),
        "security_findings": scan_security(workspace),
        "hallucinated_or_runtime_defects": sum(1 for attempt in attempts if not attempt["oracle_pass"]),
        "workspace": str(workspace),
    }


def render_report(records: list[dict[str, Any]]) -> str:
    rows = ["| Arm | Runs | First-pass | Green | Avg turns to green | Avg seconds to green | Security findings | Tokens |", "|---|---:|---:|---:|---:|---:|---:|---:|"]
    for arm in ARMS:
        group = [record for record in records if record["arm"] == arm]
        if not group:
            continue
        invalid = [record for record in group if not record.get("valid", True)]
        valid = [record for record in group if record.get("valid", True)]
        if not valid:
            rows.append(f"| {arm} | {len(group)} | invalid ({len(invalid)}/{len(group)}) | invalid | n/a | n/a | n/a | n/a |")
            continue
        first = sum(record["first_pass"] for record in valid) / len(valid) * 100
        green = sum(record["green"] for record in valid) / len(valid) * 100
        turns = [record["turns_to_green"] for record in valid if record["turns_to_green"] is not None]
        times = [record["elapsed_seconds"] for record in valid if record["green"]]
        findings = sum(len(record["security_findings"]) for record in valid)
        token_values = [record["tokens"] for record in valid if record["tokens"] is not None]
        token_cell = f"{sum(token_values) / len(token_values):.0f} avg" if token_values else "not exposed"
        turns_cell = f"{sum(turns) / len(turns):.2f}" if turns else "n/a"
        time_cell = f"{sum(times) / len(times):.2f}" if times else "n/a"
        rows.append(f"| {arm} | {len(group)} ({len(invalid)} invalid) | {first:.1f}% | {green:.1f}% | {turns_cell} | {time_cell} | {findings} | {token_cell} |")
    return "\n".join(rows) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True, help="Frozen model id used by both arms")
    parser.add_argument("--repeats", type=int, default=3, choices=range(3, 6))
    parser.add_argument("--tasks", nargs="*", default=[task.task_id for task in TASKS] + [CLI_TASK_ID])
    parser.add_argument("--max-turns", type=int, default=3, choices=range(1, 5))
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--arms", nargs="*", default=list(ARMS), choices=ARMS)
    args = parser.parse_args()
    known = {task.task_id for task in TASKS} | {CLI_TASK_ID}
    unknown = sorted(set(args.tasks) - known)
    if unknown:
        parser.error(f"Unknown tasks: {', '.join(unknown)}")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    metadata = {"runner": "v1", "model": args.model, "repeats": args.repeats, "tasks": args.tasks, "arms": args.arms, "python": sys.version, "started_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
    (output / "metadata.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    records: list[dict[str, Any]] = []
    for arm in args.arms:
        for task_id in args.tasks:
            for replicate in range(1, args.repeats + 1):
                print(f"RUN arm={arm} task={task_id} replicate={replicate}", flush=True)
                record = run_one(output, arm, task_id, replicate, args.model, args.max_turns)
                records.append(record)
                (output / "results.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
    report = render_report(records)
    (output / "REPORT.md").write_text(report, encoding="utf-8")
    print(report)
    if any(record["tokens"] is None for record in records):
        print("WARNING: CLI trace did not expose token usage for at least one run; token comparison is intentionally omitted.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
