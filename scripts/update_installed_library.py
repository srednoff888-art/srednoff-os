"""Refresh an existing library against a known prior package, preserving local edits."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil

from skill_catalog import DISCOVERY_ANCHORS, index, save_json

ROOTS = (".agent", ".codex/skills", ".codex/srednoff-os", "scripts", "evals",
         "profiles", "policies", "registry", "integrations", "bundles", "agents", "docs")


def equivalent(first: Path, second: Path) -> bool:
    if not first.is_file() or not second.is_file():
        return False
    if first.suffix in {".md", ".ps1", ".sh", ".py", ".json", ".yaml", ".yml", ".txt"}:
        return first.read_text(encoding="utf-8-sig") == second.read_text(encoding="utf-8-sig")
    return first.read_bytes() == second.read_bytes()


def destinations(relative: Path, home: Path, project: bool = False):
    if project:
        marker = home / ".codex/srednoff-os/discovery-profile.json"
        compact_mode = marker.is_file() and json.loads(marker.read_text(encoding="utf-8-sig")).get("mode") == "compact"
        parts = relative.parts
        if compact_mode and parts[:2] == (".codex", "skills") and parts[2] not in DISCOVERY_ANCHORS:
            yield home / ".codex/srednoff-os/library" / Path(*parts[2:])
        else:
            yield home / relative
        return
    yield home / "templates/codex-md-os" / relative
    if relative == Path(".srednoff-package.json"):
        return
    parts = relative.parts
    if parts[:2] == (".codex", "skills"):
        marker = home / "srednoff-os/discovery-profile.json"
        compact_mode = marker.is_file() and json.loads(marker.read_text(encoding="utf-8" )).get("mode") == "compact"
        if compact_mode:
            yield home / "srednoff-os/library" / Path(*parts[2:])
        if not compact_mode or parts[2] in DISCOVERY_ANCHORS:
            yield home / "skills" / Path(*parts[2:])
    elif parts[:2] == (".codex", "srednoff-os"):
        yield home / "srednoff-os" / Path(*parts[2:])
    elif parts[0] not in {"AGENTS.md", "code_review.md", ".agent", ".codex"}:
        yield home / relative


def update(package: Path, previous: Path, home: Path, apply: bool = False, project: bool = False) -> dict:
    package, previous, home = package.resolve(), previous.resolve(), home.resolve()
    for root in (package, previous):
        if not (root / "AGENTS.md").is_file() or not (root / ".codex/skills").is_dir():
            raise ValueError("current and previous packages must be complete public packages")
    if home == package or home == previous or home.is_relative_to(package) or home.is_relative_to(previous):
        raise ValueError("installation home must be separate from package sources")
    index_path = home / ".codex/skill-index.json" if project else home / "skill-index.json"
    if not index_path.resolve().is_relative_to(home):
        raise ValueError("index destination escapes installation home")
    files = [package / "AGENTS.md", package / "code_review.md", package / ".codex/skill-index.json"]
    if not project:
        files.append(package / ".srednoff-package.json")
    for root in ROOTS:
        files.extend(path for path in (package / root).rglob("*") if path.is_file())
    operations, conflicts = [], []
    for source in sorted(set(files)):
        if not source.exists():
            continue
        relative = source.relative_to(package)
        if any(".bak." in part or part == "__pycache__" for part in relative.parts) or source.suffix in {".pyc", ".log"}:
            continue
        if source.is_symlink() or not source.resolve().is_relative_to(package):
            raise ValueError("source symlinks are not deployable")
        if project and relative == Path(".codex/skill-index.json"):
            continue  # Regenerated against preserved project overrides below.
        for target in destinations(relative, home, project):
            if not target.resolve().is_relative_to(home):
                raise ValueError("destination escapes installation home")
            if equivalent(source, target):
                continue
            if target.exists() and not equivalent(target, previous / relative):
                conflicts.append(target.relative_to(home).as_posix())
                continue
            operations.append((source, target))
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup = home / (".agent/backups" if project else "backups") / f"srednoff-update-{stamp}"
    if not backup.resolve().is_relative_to(home):
        raise ValueError("backup destination escapes installation root")
    if apply:
        for source, target in operations:
            if target.exists():
                saved = backup / target.relative_to(home)
                saved.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(target, saved)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
        root = home / ".codex/skills" if project else home / "skills"
        save_json(index_path, index(root, home if project else None))
    return {"applied": apply, "changed_files": len(operations), "preserved_conflicts": conflicts,
            "personal_agents_preserved": True, "backup": str(backup) if apply else None}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--previous-package", type=Path, required=True)
    parser.add_argument("--home", type=Path, required=True)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--project-installation", action="store_true")
    args = parser.parse_args()
    try:
        print(json.dumps(update(args.package, args.previous_package, args.home, args.apply, args.project_installation), indent=2))
        return 0
    except (ValueError, OSError) as exc:
        print(f"installation update failed: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
