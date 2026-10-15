import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
spec = importlib.util.spec_from_file_location("installation_update", SCRIPTS / "update_installed_library.py")
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.current, self.previous, self.home = [self.root / part for part in ("current", "previous", "home")]
        for folder in (self.current, self.previous):
            skill = folder / ".codex/skills/sample"
            skill.mkdir(parents=True)
            (folder / "AGENTS.md").write_text("public instructions")
            (skill / "SKILL.md").write_text("---\nname: sample\ndescription: Sample testing.\n---\n# Sample\n")
            (folder / "scripts").mkdir()
            (folder / "scripts/helper.py").write_text("old")
        (self.current / "scripts/helper.py").write_text("new")
        (self.home / "scripts").mkdir(parents=True)
        (self.home / "scripts/helper.py").write_text("old")
        (self.home / "AGENTS.md").write_text("private instructions")

    def tearDown(self):
        self.temp.cleanup()

    def test_dry_run_does_not_mutate(self):
        result = updater.update(self.current, self.previous, self.home)
        self.assertFalse(result["applied"])
        self.assertEqual((self.home / "scripts/helper.py").read_text(), "old")
        self.assertFalse((self.home / "skills").exists())

    def test_update_backups_and_preserves_personal_profile(self):
        result = updater.update(self.current, self.previous, self.home, True)
        self.assertEqual((self.home / "scripts/helper.py").read_text(), "new")
        self.assertEqual((Path(result["backup"]) / "scripts/helper.py").read_text(), "old")
        self.assertEqual((self.home / "AGENTS.md").read_text(), "private instructions")
        self.assertTrue((self.home / "skill-index.json").is_file())

    def test_customization_preserved(self):
        (self.home / "scripts/helper.py").write_text("user")
        result = updater.update(self.current, self.previous, self.home, True)
        self.assertIn("scripts/helper.py", result["preserved_conflicts"])
        self.assertEqual((self.home / "scripts/helper.py").read_text(), "user")

    def test_repeated_update_is_noop(self):
        updater.update(self.current, self.previous, self.home, True)
        result = updater.update(self.current, self.previous, self.home, True)
        self.assertEqual(result["changed_files"], 0)

    def test_source_home_collision_rejected(self):
        with self.assertRaises(ValueError):
            updater.update(self.current, self.previous, self.current, True)


if __name__ == "__main__":
    unittest.main()
