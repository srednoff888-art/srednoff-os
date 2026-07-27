from __future__ import annotations

import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


MODULE_PATH = Path(__file__).with_name("run_codex_benchmark.py")
SPEC = importlib.util.spec_from_file_location("run_codex_benchmark", MODULE_PATH)
assert SPEC and SPEC.loader
benchmark = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = benchmark
SPEC.loader.exec_module(benchmark)


class BenchmarkHarnessTests(unittest.TestCase):
    def test_initial_command_uses_workspace_write_and_pinned_executable(self) -> None:
        command = benchmark.codex_command(
            "codex-test",
            Path("workspace"),
            "gpt-test",
            "do the task",
            None,
        )

        self.assertEqual(command[0], "codex-test")
        self.assertLess(command.index("--sandbox"), command.index("exec"))
        self.assertLess(command.index("--ask-for-approval"), command.index("exec"))
        self.assertIn("workspace-write", command)
        self.assertIn("never", command)
        self.assertIn("--ignore-user-config", command)
        self.assertNotIn("npx", " ".join(command).lower())

    def test_resume_targets_session_id_without_unsupported_sandbox_flag(self) -> None:
        command = benchmark.codex_command(
            "codex-test",
            Path("workspace"),
            "gpt-test",
            "fix the failure",
            "019f-test-session",
        )

        self.assertEqual(command[0], "codex-test")
        self.assertEqual(command[command.index("exec") + 1], "resume")
        self.assertIn("019f-test-session", command)
        self.assertNotIn("--last", command)
        self.assertLess(command.index("--sandbox"), command.index("exec"))

    def test_environment_removes_parent_codex_policy_state(self) -> None:
        with patch.dict(
            os.environ,
            {
                "CODEX_HOME": "parent",
                "CODEX_THREAD_ID": "thread",
                "CODEX_PERMISSION_PROFILE": "read-only",
                "CODEX_INTERNAL_ORIGINATOR_OVERRIDE": "desktop",
                "PATH": "example",
            },
            clear=True,
        ):
            environment = benchmark.build_codex_env(Path("clean-home"))

        self.assertEqual(environment["CODEX_HOME"], "clean-home")
        self.assertEqual(environment["PATH"], "example")
        self.assertNotIn("CODEX_THREAD_ID", environment)
        self.assertNotIn("CODEX_PERMISSION_PROFILE", environment)
        self.assertNotIn("CODEX_INTERNAL_ORIGINATOR_OVERRIDE", environment)

    def test_codex_home_rejects_context_contaminants(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            codex_home = Path(temporary)
            (codex_home / "skills").mkdir()

            with self.assertRaisesRegex(ValueError, "skills"):
                benchmark.validate_codex_home(codex_home)

    def test_execute_turn_closes_stdin_and_uses_workspace_as_cwd(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary)
            trace_path = workspace / "trace.jsonl"
            completed = subprocess.CompletedProcess(
                args=["codex-test"],
                returncode=0,
                stdout='{"type":"thread.started","thread_id":"session"}\n',
                stderr="",
            )
            with patch.object(benchmark.subprocess, "run", return_value=completed) as run:
                benchmark.execute_turn(
                    workspace,
                    "gpt-test",
                    "do the task",
                    trace_path,
                    "codex-test",
                    {"CODEX_HOME": "clean-home"},
                    None,
                    None,
                )

        kwargs = run.call_args.kwargs
        self.assertEqual(kwargs["stdin"], subprocess.DEVNULL)
        self.assertEqual(kwargs["cwd"], workspace)
        self.assertEqual(kwargs["env"]["CODEX_HOME"], "clean-home")

    def test_execute_turn_preserves_partial_trace_on_timeout(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary)
            trace_path = workspace / "trace.jsonl"
            timeout = subprocess.TimeoutExpired(
                cmd=["codex-test"],
                timeout=600,
                output=b'{"type":"thread.started","thread_id":"partial"}\n',
                stderr=b"partial stderr",
            )
            with patch.object(benchmark.subprocess, "run", side_effect=timeout):
                exit_code, stderr = benchmark.execute_turn(
                    workspace,
                    "gpt-test",
                    "do the task",
                    trace_path,
                    "codex-test",
                    {"CODEX_HOME": "clean-home"},
                    None,
                    None,
                )

            trace = benchmark.parse_trace(trace_path)

        self.assertEqual(exit_code, 124)
        self.assertIn("timed out", stderr)
        self.assertEqual(trace["session_id"], "partial")

    def test_trace_counts_completed_commands_once(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            trace_path = Path(temporary) / "trace.jsonl"
            trace_path.write_text(
                "\n".join(
                    [
                        '{"type":"thread.started","thread_id":"session"}',
                        '"non-object diagnostic line"',
                        '{"type":"item.started","item":{"type":"command_execution"}}',
                        '{"type":"item.completed","item":{"type":"command_execution"}}',
                        '{"type":"turn.completed","usage":{"input_tokens":10,"cached_input_tokens":4,"output_tokens":2,"reasoning_output_tokens":1}}',
                    ]
                ),
                encoding="utf-8",
            )

            trace = benchmark.parse_trace(trace_path)

        self.assertEqual(trace["commands"], 1)
        self.assertEqual(trace["tokens"], 13)
        self.assertEqual(trace["cached_input_tokens"], 4)
        self.assertEqual(trace["session_id"], "session")

    def test_windows_sandbox_choice_is_an_explicit_root_override(self) -> None:
        command = benchmark.codex_command(
            "codex-test",
            Path("workspace"),
            "gpt-test",
            "do the task",
            None,
            "unelevated",
        )

        self.assertIn('windows.sandbox="unelevated"', command)
        self.assertLess(command.index("--config"), command.index("exec"))

    def test_srednoff_path_alone_does_not_contaminate_control(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            trace_path = Path(temporary) / "trace.jsonl"
            trace_path.write_text(
                '{"type":"item.completed","item":{"type":"agent_message",'
                '"text":"using G:\\\\Temp\\\\srednoff-benchmark-home"}}',
                encoding="utf-8",
            )

            trace = benchmark.parse_trace(trace_path)

        self.assertFalse(trace["contains_srednoff"])


if __name__ == "__main__":
    unittest.main()
