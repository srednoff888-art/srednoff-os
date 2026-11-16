import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import compact_skill_discovery as compact
import skill_catalog as catalog
import update_installed_library as updater


class CompactTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.package = self.root / "package"
        self.home = self.root / "home"
        self.active = self.home / "skills"
        self.active.mkdir(parents=True)
        self.source = self.package / ".codex/skills/owned-skill"
        self.source.mkdir(parents=True)
        (self.package / "AGENTS.md").write_text("public")
        (self.source / "SKILL.md").write_text("---\nname: owned-skill\ndescription: Own one contract.\n---\n# Owned\n")
        shutil.copytree(self.source, self.active / "owned-skill")

    def tearDown(self):
        self.temp.cleanup()

    def apply(self):
        return compact.compact(self.package, self.package, self.active, True)

    def test_dry_run_never_retires(self):
        result = compact.compact(self.package, self.package, self.active)
        self.assertEqual(result["manifests_to_retire"], 1)
        self.assertTrue((self.active / "owned-skill/SKILL.md").is_file())
        self.assertFalse((self.home / "srednoff-os").exists())

    def test_compact_keeps_catalog_and_is_reversible(self):
        self.apply()
        self.assertFalse((self.active / "owned-skill/SKILL.md").exists())
        self.assertEqual(catalog.index(self.active)[0]["name"], "owned-skill")
        self.assertEqual(catalog.audit(self.active)["errors"], [])
        compact.restore(self.active, True)
        self.assertTrue((self.active / "owned-skill/SKILL.md").exists())
        self.assertIsNone(catalog.passive_library(self.active))

    def test_custom_workflow_remains_active_and_wins(self):
        local = self.active / "owned-skill/SKILL.md"
        local.write_text(local.read_text() + "\nprivate extension")
        result = self.apply()
        self.assertEqual(result["preserved_custom_skills"], ["owned-skill"])
        self.assertEqual(Path(catalog.index(self.active)[0]["path"]), local.parent)

    def test_extra_user_resource_prevents_retirement(self):
        (self.active / "owned-skill/user.txt").write_text("user")
        self.assertEqual(self.apply()["manifests_to_retire"], 0)

    def test_timestamped_backups_are_retained_but_not_deployed(self):
        backup = self.active / "owned-skill/SKILL.md.bak.20261116-120000"
        backup.write_text("old public manifest")
        self.assertEqual(self.apply()["manifests_to_retire"], 1)
        self.assertTrue(backup.is_file())
        self.assertFalse((self.home / "srednoff-os/library/owned-skill" / backup.name).exists())

    def test_owned_update_does_not_reactivate_catalog(self):
        self.apply()
        (self.source / "SKILL.md").write_text((self.source / "SKILL.md").read_text() + "\nnext")
        # Use an intact previous package for the update's three-way comparison.
        previous = self.root / "previous"
        shutil.copytree(self.package, previous)
        old = previous / ".codex/skills/owned-skill/SKILL.md"
        old.write_text(old.read_text().removesuffix("\nnext"))
        updater.update(self.package, previous, self.home, True)
        self.assertFalse((self.active / "owned-skill/SKILL.md").exists())
        self.assertIn("next", (self.home / "srednoff-os/library/owned-skill/SKILL.md").read_text())

    def test_second_compaction_is_idempotent(self):
        self.apply()
        self.assertEqual(self.apply()["manifests_to_retire"], 0)

    def test_restore_collision_is_not_overwritten(self):
        self.apply()
        (self.active / "owned-skill/SKILL.md").write_text("user")
        with self.assertRaises(ValueError):
            compact.restore(self.active, True)
        self.assertEqual((self.active / "owned-skill/SKILL.md").read_text(), "user")

    def test_portable_project_index_resolves_passive_paths(self):
        project = self.root / "project"
        active = project / ".codex/skills"
        shutil.copytree(self.active, active)
        compact.compact(self.package, self.package, active, True)
        rows = json.loads((project / ".codex/skill-index.json").read_text())
        self.assertEqual(rows[0]["path"], ".codex/srednoff-os/library/owned-skill")
        relative = catalog.index(active, active)[0]["path"]
        self.assertTrue(relative.startswith("../srednoff-os/library/"))

    def test_real_selector_profile_can_read_passive_library(self):
        real = Path(__file__).resolve().parents[1]
        active = self.root / "real-home/skills"
        shutil.copytree(real / ".codex/skills", active, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
        compact.compact(real, real, active, True)
        profile = catalog.select_profile(active, self.root, "Blender product model", "balanced", 3)
        self.assertIn("blender-web-asset-authoring", profile["selected"])
        destination = self.root / "destination"
        destination.mkdir()
        catalog.install_profile(active, destination, profile)
        self.assertTrue((destination / ".agents/skills/blender-web-asset-authoring/SKILL.md").is_file())


if __name__ == "__main__":
    unittest.main()
