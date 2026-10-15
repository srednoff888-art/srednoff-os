import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "skill_catalog.py"
spec = importlib.util.spec_from_file_location("skill_catalog", SCRIPT)
catalog = importlib.util.module_from_spec(spec)
spec.loader.exec_module(catalog)


class CatalogTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.skills = self.root / "library"
        self.skills.mkdir()

    def tearDown(self):
        self.temp.cleanup()

    def skill(self, name="sample-skill", description="Use for sample validation."):
        folder = self.skills / name
        folder.mkdir(exist_ok=True)
        (folder / "SKILL.md").write_text(
            f"---\nname: {name}\ndescription: {description}\n---\n\n# Sample\nVerify the result.\n",
            encoding="utf-8",
        )
        return folder

    def profile(self, folder):
        name = folder.name
        return {"selected": [name], "source_paths": {name: name},
                "files": {name: {p.relative_to(folder).as_posix(): catalog.digest(p)
                                for p in folder.rglob("*") if p.is_file()}}}

    def test_portable_index(self):
        self.skill()
        row = catalog.index(self.skills, self.root)[0]
        self.assertEqual(row["path"], "library/sample-skill")
        self.assertEqual(len(row["content_sha256"]), 64)

    def test_block_description(self):
        folder = self.skill(description=">\n  Use for structured\n  migration checks.")
        self.assertEqual(catalog.metadata(folder / "SKILL.md")[0]["description"],
                         "Use for structured migration checks.")

    def test_index_ignores_checkout_line_endings(self):
        folder = self.skill()
        before = catalog.index(self.skills, self.root)
        path = folder / "SKILL.md"
        path.write_bytes(path.read_text(encoding="utf-8").encode().replace(b"\n", b"\r\n"))
        self.assertEqual(before, catalog.index(self.skills, self.root))

    def test_invalid_name_rejected(self):
        folder = self.skill()
        path = folder / "SKILL.md"
        path.write_text(path.read_text().replace("name: sample-skill", "name: Bad_Name"))
        with self.assertRaises(ValueError):
            catalog.index(self.skills)

    def test_known_reference_layouts_only(self):
        for layout, name in catalog.LEGACY_LAYOUTS.items():
            folder = self.skills / layout
            folder.mkdir(parents=True)
            (folder / "SKILL.md").write_text(
                f"---\nname: {name}\ndescription: Reference contract.\n---\n# Reference\n")
        self.assertEqual(catalog.audit(self.skills)["errors"], [])
        folder = self.skills / "unrecognized-alias"
        folder.mkdir()
        (folder / "SKILL.md").write_text("---\nname: different-name\ndescription: Example.\n---\n# Example\n")
        self.assertEqual(catalog.audit(self.skills)["errors"][0]["issue"], "directory/frontmatter mismatch")

    def test_duplicate_name_rejected(self):
        first = self.skill()
        second = self.skills / "other"
        second.mkdir()
        (second / "SKILL.md").write_bytes((first / "SKILL.md").read_bytes())
        with self.assertRaises(ValueError):
            catalog.index(self.skills)

    def test_reference_integrity(self):
        folder = self.skill()
        with (folder / "SKILL.md").open("a") as stream:
            stream.write("\nRead [reference](references/missing.md).\n")
        self.assertIn("missing reference", catalog.audit(self.skills)["errors"][0]["issue"])
        (folder / "references").mkdir()
        (folder / "references" / "missing.md").write_text("# Reference")
        self.assertEqual(catalog.audit(self.skills)["errors"], [])

    def test_fenced_example_not_a_missing_reference(self):
        folder = self.skill()
        with (folder / "SKILL.md").open("a") as stream:
            stream.write("\n```md\n[example](missing.md)\n```\n")
        self.assertEqual(catalog.audit(self.skills)["errors"], [])

    def test_deploy_all_resources_to_native_path(self):
        folder = self.skill()
        (folder / "references").mkdir()
        (folder / "references" / "contract.md").write_text("contract")
        catalog.install_profile(self.skills, self.root, self.profile(folder))
        target = self.root / ".agents" / "skills" / folder.name
        self.assertTrue((target / "references" / "contract.md").is_file())

    def test_owned_unchanged_file_can_update(self):
        folder = self.skill()
        catalog.install_profile(self.skills, self.root, self.profile(folder))
        with (folder / "SKILL.md").open("a") as stream:
            stream.write("\nNew guidance.\n")
        catalog.install_profile(self.skills, self.root, self.profile(folder))
        target = self.root / ".agents" / "skills" / folder.name / "SKILL.md"
        self.assertIn("New guidance", target.read_text())

    def test_user_edit_never_overwritten(self):
        folder = self.skill()
        catalog.install_profile(self.skills, self.root, self.profile(folder))
        target = self.root / ".agents" / "skills" / folder.name / "SKILL.md"
        target.write_text("user customization")
        with self.assertRaisesRegex(ValueError, "user-modified"):
            catalog.install_profile(self.skills, self.root, self.profile(folder))
        self.assertEqual(target.read_text(), "user customization")

    def test_collision_plan_is_atomic(self):
        first = self.skill("a-skill")
        second = self.skill("z-skill")
        conflict = self.root / ".agents" / "skills" / "z-skill"
        conflict.mkdir(parents=True)
        (conflict / "SKILL.md").write_text("user")
        profile = {"selected": ["a-skill", "z-skill"], "source_paths": {"a-skill": "a-skill", "z-skill": "z-skill"},
                   "files": {**self.profile(first)["files"], **self.profile(second)["files"]}}
        with self.assertRaises(ValueError):
            catalog.install_profile(self.skills, self.root, profile)
        self.assertFalse((self.root / ".agents" / "skills" / "a-skill").exists())

    def test_redeploy_does_not_prune_user_skills(self):
        folder = self.skill()
        user = self.root / ".agents" / "skills" / "user-skill"
        user.mkdir(parents=True)
        (user / "SKILL.md").write_text("user")
        catalog.install_profile(self.skills, self.root, self.profile(folder))
        self.assertEqual((user / "SKILL.md").read_text(), "user")

    def test_check_detects_stale_content(self):
        folder = self.skill()
        baseline = catalog.index(self.skills, self.root)
        with (folder / "SKILL.md").open("a") as stream:
            stream.write("\nChanged content.")
        self.assertNotEqual(baseline, catalog.index(self.skills, self.root))

    def test_source_traversal_rejected(self):
        profile = {"selected": ["bad"], "source_paths": {"bad": ".."}, "files": {"bad": {}}}
        with self.assertRaisesRegex(ValueError, "escapes library"):
            catalog.install_profile(self.skills, self.root, profile)

    def test_stale_profile_cannot_install_changed_resources(self):
        folder = self.skill()
        profile = self.profile(folder)
        (folder / "SKILL.md").write_text("changed after selection")
        with self.assertRaisesRegex(ValueError, "stale source fingerprint"):
            catalog.install_profile(self.skills, self.root, profile)
        self.assertFalse((self.root / ".agents/skills" / folder.name).exists())



    def test_actual_selector_negative_control(self):
        spec = importlib.util.spec_from_file_location("selector_eval", SCRIPT.with_name("selector_eval.py"))
        import sys
        sys.modules["skill_catalog"] = catalog
        evaluator = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(evaluator)
        rows = [{"id": "docs.context", "domain_id": "docs", "capability_slug": "context",
                 "brief": "blender google ads mcp", "mapped_skills": []}]
        labels = evaluator.selected_labels(rows)
        self.assertNotIn("blender", labels)
        self.assertNotIn("google-ads-mcp-reporting", labels)
        self.assertIn("context", labels)

    def test_explicit_domains_survive_project_noise(self):
        module = catalog.selector_module(catalog.SKILLS)
        kernel = module.load_json(catalog.SKILLS / "quality-cost-skill-kernel/references/core-3000-capabilities.json")
        brief = module.normalize("MCP server interactive UI dashboard")
        rows = module.select_records(kernel, brief, "python security research audit " * 20, [], "deep", 16)
        domains = {row["domain_id"] for _, row in rows}
        self.assertTrue(module.infer_intent_domains(brief).issubset(domains))

    def test_unrelated_prose_is_not_a_mobile_domain(self):
        import subprocess
        repo = SCRIPT.parents[1]
        command = ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                   str(repo / "scripts/srednoff-os-domain-router.ps1"),
                   "-ProjectPath", str(repo), "-Brief", "Srednoff OS maintenance release", "-Json"]
        import os
        if os.name != "nt":
            command[0] = "pwsh"
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
        self.assertNotIn("mobile-apps", data["domains"])
        self.assertIn("agents-research", data["domains"])

    def test_profile_cap_and_specific_workflow(self):
        project = self.root / "fixture"
        project.mkdir()
        profile = catalog.select_profile(catalog.SKILLS, project, "Blender product model", "balanced", 3)
        self.assertLessEqual(len(profile["selected"]), 3)
        self.assertIn("blender-web-asset-authoring", profile["selected"])
        self.assertEqual(profile["model_switching"], "not-performed")

if __name__ == "__main__":
    unittest.main()
