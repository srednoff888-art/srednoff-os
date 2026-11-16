"""Offline catalog evidence, discovery duplication and upstream drift diagnostics."""
from __future__ import annotations

import argparse
from collections import defaultdict
from datetime import date
import hashlib
import json
from pathlib import Path
import re

from skill_catalog import ROOT, SKILLS, audit, index, metadata, resources, save_json

DATA = ROOT / ".codex/srednoff-os" if (ROOT / ".codex/srednoff-os").exists() else ROOT / "srednoff-os"
TEXT_SUFFIXES = {".md", ".json", ".yaml", ".yml", ".py", ".sh", ".ps1", ".txt"}


def canonical_hash(path: Path) -> str:
    data = path.read_text(encoding="utf-8-sig").encode() if path.suffix in TEXT_SUFFIXES else path.read_bytes()
    return hashlib.sha256(data).hexdigest()


def inventory(skills: Path, source_set: dict, checked_on: str) -> dict:
    date.fromisoformat(checked_on)
    known = {item["id"] for item in source_set["sources"]}
    rows = []
    for item in index(skills):
        folder = Path(item["path"])
        if any(path.is_symlink() for path in folder.rglob("*")):
            raise ValueError(f"symlinked skill resource: {item['name']}")
        _, body = metadata(folder / "SKILL.md")
        mapped = set()
        for rule in source_set["families"]:
            if re.search(rule["pattern"], item["name"]):
                mapped.update(rule["sources"])
        if not mapped.issubset(known):
            raise ValueError("unknown source ID in family mapping")
        rows.append({"name": item["name"], "content_sha256": item["content_sha256"],
                     "resources": {p.relative_to(folder).as_posix(): canonical_hash(p) for p in resources(folder)},
                     "body_chars": len(body), "description_chars": len(item["description"]),
                     "topic_sources": sorted(mapped),
                     "source_scope": "family-reference-only" if mapped else "needs-domain-review",
                     "behavioral_evidence": "not-run"})
    result = audit(skills)
    return {"schema_version": 1, "checked_on": checked_on, "skills": len(rows),
            "structural_errors": result["errors"], "findings": result["finding_counts"],
            "source_set_sha256": hashlib.sha256(json.dumps(source_set, sort_keys=True).encode()).hexdigest(),
            "records": rows,
            "claim_boundary": "All records structurally checked. Topic mapping is not semantic or model validation."}


def discovery(roots: list[Path], include_paths: bool = False) -> dict:
    entries = defaultdict(list)
    errors = []
    seen = set()
    for root_index, root in enumerate(roots):
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("SKILL.md")):
            if ".system" in path.parts or any(".bak." in part or part == "__pycache__" for part in path.parts):
                continue
            if path.is_symlink() or not path.resolve().is_relative_to(root.resolve()):
                errors.append({"root": root_index, "issue": "escaping or symlinked manifest"})
                continue
            resolved = path.resolve()
            if resolved in seen:
                continue
            seen.add(resolved)
            try:
                fields, _ = metadata(path)
            except (ValueError, UnicodeError) as exc:
                errors.append({"root": root_index, "issue": str(exc)})
                continue
            row = {"root": root_index, "hash": canonical_hash(path),
                   "description_chars": len(fields["description"])}
            if include_paths:
                row["path"] = str(path)
            entries[fields["name"]].append(row)
    duplicates = [{"name": name, "copies": rows, "identical": len({r["hash"] for r in rows}) == 1}
                  for name, rows in sorted(entries.items()) if len(rows) > 1]
    chars = sum(row["description_chars"] for rows in entries.values() for row in rows)
    return {"manifests": len(seen), "unique_names": len(entries), "duplicate_names": len(duplicates),
            "description_chars": chars, "duplicates": duplicates, "errors": errors,
            "claim_boundary": "Filesystem discovery candidates, not proof of host loading or exact token usage.",
            "mutations": "none"}


def upstream_drift(baseline: dict, current: dict) -> dict:
    def keyed(data):
        rows = data["sources"]
        values = {row["id"]: row for row in rows}
        if len(values) != len(rows):
            raise ValueError("duplicate source ID")
        return values
    old, new = keyed(baseline), keyed(current)
    changed = []
    for name in sorted(old.keys() & new.keys()):
        fields = [key for key in ("url", "revision", "license", "archived") if old[name].get(key) != new[name].get(key)]
        if fields:
            changed.append({"id": name, "changed_fields": fields, "action": "review-required"})
    return {"added": sorted(new.keys() - old.keys()), "removed": sorted(old.keys() - new.keys()),
            "changed": changed, "auto_install": False,
            "claim_boundary": "Compares supplied metadata; does not execute code or establish compatibility."}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["inventory", "discovery", "drift"])
    parser.add_argument("--skills-root", type=Path, default=SKILLS)
    parser.add_argument("--sources", type=Path, default=DATA / "maintenance-sources.json")
    parser.add_argument("--checked-on", default="2026-11-16")
    parser.add_argument("--root", type=Path, action="append", default=[])
    parser.add_argument("--include-paths", action="store_true")
    parser.add_argument("--current", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        if args.action == "inventory":
            result = inventory(args.skills_root, json.loads(args.sources.read_text(encoding="utf-8-sig")), args.checked_on)
        elif args.action == "discovery":
            if not args.root:
                raise ValueError("discovery requires at least one explicit --root")
            result = discovery(args.root, args.include_paths)
        else:
            if not args.current:
                raise ValueError("drift requires --current")
            result = upstream_drift(json.loads(args.sources.read_text(encoding="utf-8-sig")),
                                    json.loads(args.current.read_text(encoding="utf-8-sig")))
        if args.check:
            if not args.output or not args.output.is_file() or json.loads(args.output.read_text(encoding="utf-8-sig")) != result:
                raise ValueError("maintenance evidence is stale or missing")
        elif args.output:
            save_json(args.output, result)
        else:
            print(json.dumps(result, ensure_ascii=False, indent=2))
        if result.get("structural_errors") or result.get("errors"):
            return 1
        print(f"skill maintenance {args.action}: OK")
        return 0
    except (ValueError, OSError) as exc:
        print(f"skill maintenance: FAIL: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
