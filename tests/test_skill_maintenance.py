import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import skill_catalog as catalog
import skill_maintenance as maintenance
import mcp_capability_diff as mcp


class MaintenanceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def skill(self, root, name="test-skill", content="Review a specific test contract."):
        path = root / name / "SKILL.md"
        path.parent.mkdir(parents=True)
        path.write_text(f"---\nname: {name}\ndescription: {content}\n---\n# Contract\nVerify a concrete outcome.\n", encoding="utf-8")
        return path

    def sources(self):
        return {"sources": [{"id": "primary", "url": "https://example.org", "revision": "a"}],
                "families": [{"pattern": "test", "sources": ["primary"]}]}

    def test_inventory_tracks_resource_changes(self):
        path = self.skill(self.root)
        before = maintenance.inventory(self.root, self.sources(), "2026-11-16")
        (path.parent / "contract.txt").write_text("v2")
        after = maintenance.inventory(self.root, self.sources(), "2026-11-16")
        self.assertNotEqual(before, after)
        self.assertEqual(after["records"][0]["behavioral_evidence"], "not-run")

    def test_inventory_rejects_unknown_source(self):
        self.skill(self.root)
        source = self.sources()
        source["sources"] = []
        with self.assertRaises(ValueError):
            maintenance.inventory(self.root, source, "2026-11-16")

    def test_inventory_does_not_invent_topic_review(self):
        self.skill(self.root, "unmatched")
        row = maintenance.inventory(self.root, self.sources(), "2026-11-16")["records"][0]
        self.assertEqual(row["source_scope"], "needs-domain-review")

    def test_discovery_counts_duplicates_without_paths(self):
        first, second = self.root / "one", self.root / "two"
        self.skill(first)
        self.skill(second)
        result = maintenance.discovery([first, second])
        self.assertEqual(result["manifests"], 2)
        self.assertEqual(result["duplicate_names"], 1)
        self.assertTrue(result["duplicates"][0]["identical"])
        self.assertNotIn(str(self.root), json.dumps(result))

    def test_overlapping_discovery_roots_do_not_double_count(self):
        self.skill(self.root)
        result = maintenance.discovery([self.root, self.root / "test-skill"])
        self.assertEqual(result["manifests"], 1)

    def test_discovery_reports_differing_versions(self):
        first, second = self.root / "one", self.root / "two"
        self.skill(first)
        self.skill(second, content="A different contract.")
        result = maintenance.discovery([first, second])
        self.assertFalse(result["duplicates"][0]["identical"])

    def test_upstream_license_drift_requires_review(self):
        old, new = self.sources(), self.sources()
        new["sources"][0]["license"] = "unknown"
        result = maintenance.upstream_drift(old, new)
        self.assertEqual(result["changed"][0]["action"], "review-required")
        self.assertFalse(result["auto_install"])

    def test_upstream_duplicate_ids_rejected(self):
        bad = self.sources()
        bad["sources"] *= 2
        with self.assertRaises(ValueError):
            maintenance.upstream_drift(self.sources(), bad)

    def test_annotations_never_grant_authorization(self):
        data = {"tools": [{"name": "create_asset", "annotations": {"readOnlyHint": True}}]}
        result = mcp.compare(data, data, {"search"})
        self.assertTrue(result["review_required"])
        self.assertEqual(result["authorization"], "not-granted")

    def test_schema_drift_requires_review_even_for_allowed_read(self):
        old = {"tools": [{"name": "search", "inputSchema": {"type": "object"}}]}
        new = copy.deepcopy(old)
        new["tools"][0]["inputSchema"]["additionalProperties"] = True
        self.assertEqual(mcp.compare(old, new, {"search"})["changed"], ["search"])

    def test_nested_mcp_envelope_and_removal(self):
        old = {"result": {"tools": [{"name": "search"}]}}
        result = mcp.compare(old, {"tools": []}, {"search"})
        self.assertEqual(result["removed"], ["search"])

    def test_duplicate_tool_names_rejected(self):
        with self.assertRaises(ValueError):
            mcp.compare({"tools": []}, {"tools": [{"name": "x"}, {"name": "x"}]}, set())

    def test_allowed_unchanged_inventory_has_no_delta(self):
        data = {"tools": [{"name": "search"}]}
        self.assertFalse(mcp.compare(data, data, {"search"})["review_required"])

    def test_native_skills_are_not_project_signals(self):
        module = catalog.selector_module(catalog.SKILLS)
        self.skill(self.root / ".agents/skills", "foreign-ai-rag")
        (self.root / "app.py").write_text("print('test')")
        names, _, snippets = module.walk_project(self.root, max_files=80, read_snippets=True)
        self.assertEqual(names, ["app.py"])
        self.assertNotIn("foreign-ai-rag", snippets)

    def test_entrypoint_budget_is_measured_and_enforced(self):
        full = catalog.select_profile(catalog.SKILLS, self.root, "Blender product model", "balanced", 3)
        limited = catalog.select_profile(catalog.SKILLS, self.root, "Blender product model", "balanced", 3,
                                         full["entrypoint_chars"])
        self.assertLessEqual(limited["entrypoint_chars"], full["entrypoint_chars"])
        self.assertIn("Not token accounting", limited["budget_scope"])

    def test_too_small_entrypoint_budget_is_not_silent_success(self):
        with self.assertRaisesRegex(ValueError, "no workflow fits"):
            catalog.select_profile(catalog.SKILLS, self.root, "Blender product model", "balanced", 3, 1)

    def test_generic_template_is_a_lint_finding(self):
        path = self.skill(self.root)
        with path.open("a") as stream:
            stream.write("\n1. Clarify the user outcome, constraints, current stack, and definition of done.\n")
        self.assertEqual(catalog.audit(self.root)["finding_counts"]["generic-template"], 1)


if __name__ == "__main__":
    unittest.main()
