"""Score selector outputs, never the echoed brief or human-readable report."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

from skill_catalog import SKILLS, index, selector_module


def evaluate(fixtures: list[dict], skills: Path, project: Path, maximum: int = 16) -> dict:
    module = selector_module(skills)
    library = module.prepare_skill_index(index(skills))
    kernel = module.load_json(skills / "quality-cost-skill-kernel/references/core-3000-capabilities.json")
    files, _, snippets = module.walk_project(project, max_files=80, read_snippets=True)
    project_text = module.normalize("\n".join(files) + "\n" + snippets)
    mapping_cache = {}
    original_mapping = module.map_existing_skills
    def cached_mapping(record, skill_index, limit=3):
        key = (record["id"], limit)
        if key not in mapping_cache:
            mapping_cache[key] = original_mapping(record, skill_index, limit)
        return [dict(item) for item in mapping_cache[key]]
    module.map_existing_skills = cached_mapping
    results = []
    for fixture in fixtures:
        brief = module.normalize(fixture["brief"])
        budget = fixture.get("budget", "balanced")
        output = module.enrich_selected(module.select_records(kernel, brief, project_text, files, budget, maximum),
                                        library, brief, budget)
        names = {item["name"] for row in output for item in row.get("mapped_skills", [])}
        labels = selected_labels(output)
        expected_any = fixture.get("expectedAny", [])
        expected_all = fixture.get("expectedAll", [])
        excluded = fixture.get("excludedSkills", [])
        missing = sorted(set(expected_all) - labels)
        unwanted = sorted(set(excluded) & names)
        any_ok = not expected_any or any(any(expect in label for label in labels) for expect in expected_any)
        results.append({"id": fixture["id"], "passed": any_ok and not missing and not unwanted,
                        "missing": missing, "unwanted": unwanted, "mapped_skills": sorted(names)})
    return {"total": len(results), "passed": sum(row["passed"] for row in results),
            "failed": sum(not row["passed"] for row in results), "results": results,
            "scope": "Deterministic routing only; not model task quality."}


def selected_labels(output: list[dict]) -> set[str]:
    return ({item["name"] for row in output for item in row.get("mapped_skills", [])}
            | {row["domain_id"] for row in output}
            | {row["id"] for row in output}
            | {row["capability_slug"] for row in output})


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fixtures", type=Path, required=True)
    parser.add_argument("--skills-root", type=Path, default=SKILLS)
    parser.add_argument("--project", type=Path, default=Path("."))
    parser.add_argument("--max", type=int, default=16)
    args = parser.parse_args()
    result = evaluate(json.loads(args.fixtures.read_text(encoding="utf-8-sig")),
                      args.skills_root, args.project.resolve(), args.max)
    print(json.dumps(result, indent=2))
    return int(result["failed"] > 0)


if __name__ == "__main__":
    raise SystemExit(main())
