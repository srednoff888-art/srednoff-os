import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
PS = shutil.which("powershell" if os.name == "nt" else "pwsh")


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.env = dict(os.environ, CODEX_HOME=str(self.home))

    def tearDown(self):
        self.temp.cleanup()

    def ps(self, script, *args, success=True):
        result = subprocess.run([PS, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script), *map(str, args)],
                                env=self.env, cwd=REPO, text=True, capture_output=True, timeout=180)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout[-3000:] + result.stderr[-3000:])
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def assert_compact(self, active, index):
        self.assertEqual(len(list(active.rglob("SKILL.md"))), 4)
        self.assertEqual(len(json.loads(index.read_text(encoding="utf-8-sig"))), 416)

    @unittest.skipUnless(PS, "PowerShell is unavailable")
    def test_fresh_project_and_no_accidental_project_as_template(self):
        project = self.root / "project"
        self.ps(REPO / "scripts/init-codex-project.ps1", "-ProjectPath", project,
                "-Brief", "Blender product model", "-MaxSkills", 3)
        self.assert_compact(project / ".codex/skills", project / ".codex/skill-index.json")
        result = self.ps(project / "scripts/init-codex-project.ps1", "-ProjectPath", self.root / "other", success=False)
        self.assertIn("distribution template", result.stderr)

    @unittest.skipUnless(PS, "PowerShell is unavailable")
    def test_fresh_install_preserves_personal_and_reinstall_stops(self):
        instructions = self.home / "AGENTS.md"
        instructions.write_text("Personal instructions stay.")
        self.ps(REPO / "scripts/install-codex-md-os.ps1")
        self.assertTrue(instructions.read_text(encoding="utf-8-sig").startswith("Personal instructions stay."))
        self.assert_compact(self.home / "skills", self.home / "skill-index.json")
        before = hashlib.sha256(instructions.read_bytes()).hexdigest()
        self.ps(REPO / "scripts/install-codex-md-os.ps1", success=False)
        self.assertEqual(before, hashlib.sha256(instructions.read_bytes()).hexdigest())

    @unittest.skipIf(os.name == "nt" or not shutil.which("bash"), "Portable Bash smoke runs on Unix")
    def test_fresh_bash_project_has_full_docs_and_compact_index(self):
        project = self.root / "bash-project"
        result = subprocess.run(["bash", str(REPO / "scripts/init-codex-project.sh"), str(project), "Blender product model"],
                                env=self.env, cwd=REPO, text=True, capture_output=True, timeout=180)
        self.assertEqual(result.returncode, 0, result.stdout[-3000:] + result.stderr[-3000:])
        self.assert_compact(project / ".codex/skills", project / ".codex/skill-index.json")
        self.assertTrue((project / "docs/README.md").is_file())
        self.assertTrue((project / ".agent/SREDNOFF_OS_OPERATING_RULES.md").is_file())


if __name__ == "__main__":
    unittest.main()
