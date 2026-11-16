"""Reversibly move reviewed public manifests out of broad automatic discovery."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil

from skill_catalog import DISCOVERY_ANCHORS, index, resources, save_json
from update_installed_library import equivalent

ANCHORS = DISCOVERY_ANCHORS


def compact(package: Path, previous: Path, active: Path, apply: bool = False) -> dict:
    package, previous, active = package.resolve(), previous.resolve(), active.resolve()
    source_root, old_root = package / ".codex/skills", previous / ".codex/skills"
    if active.is_relative_to(source_root.resolve()) or active.is_relative_to(old_root.resolve()):
        raise ValueError("active installation must be separate from distribution sources")
    if not source_root.is_dir() or not old_root.is_dir() or not active.is_dir():
        raise ValueError("current/previous complete public packages and active skills root are required")
    state_root = active.parent / "srednoff-os"
    library = state_root / "library"
    if not (state_root / "discovery-profile.json").resolve().is_relative_to(active.parent):
        raise ValueError("discovery marker escapes installation root")
    if not (active.parent / "skill-index.json").resolve().is_relative_to(active.parent):
        raise ValueError("index escapes installation root")
    if state_root.is_symlink() or library.is_symlink() or not library.resolve().is_relative_to(active.parent):
        raise ValueError("passive destination escapes installation root")
    copies, retiring, preserved = [], [], []
    for row in index(source_root):
        folder = Path(row["path"])
        relative = folder.relative_to(source_root)
        local = active / relative
        old = old_root / relative
        expected = resources(folder)
        for path in expected:
            target = library / relative / path.relative_to(folder)
            if (path.is_symlink() or not path.resolve().is_relative_to(source_root.resolve())
                    or not target.resolve().is_relative_to(library.resolve())):
                raise ValueError("symlinked or escaping library resource")
            if target.exists() and not equivalent(target, path) and not equivalent(target, old / path.relative_to(folder)):
                raise ValueError("user-modified passive library conflict")
            copies.append((path, target))
        manifest = local / "SKILL.md"
        if row["name"] in ANCHORS or not manifest.is_file():
            continue
        if local.is_symlink() or not local.resolve().is_relative_to(active):
            raise ValueError("active source escapes installation root")
        local_files = resources(local)
        expected_paths = {p.relative_to(folder) for p in expected}
        if any(p.is_symlink() for p in local.rglob("*")):
            raise ValueError("symlinked active resource")
        clean = all(p.relative_to(local) in expected_paths and
                    (equivalent(p, folder / p.relative_to(local)) or equivalent(p, old / p.relative_to(local)))
                    for p in local_files)
        if not clean:
            preserved.append(row["name"])
            continue
        retired = local / "SKILL.srednoff-passive.md"
        if retired.exists():
            raise ValueError("passive manifest backup already exists beside active manifest")
        retiring.append((manifest, retired))
    if apply:
        for source, target in copies:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
        for manifest, retired in retiring:
            manifest.rename(retired)
        save_json(state_root / "discovery-profile.json", {"schema_version": 1, "mode": "compact",
                  "anchors": sorted(ANCHORS), "restore": "Restore each SKILL.srednoff-passive.md to SKILL.md; never overwrite edits."})
        # The ordinary index transparently merges the passive library and private active overrides.
        save_json(active.parent / "skill-index.json", index(active, active.parent.parent if active.parent.name == ".codex" else None))
    return {"applied": apply, "public_library_skills": len(index(source_root)),
            "manifests_to_retire": len(retiring), "preserved_custom_skills": sorted(preserved),
            "anchors": sorted(ANCHORS), "deletions": 0,
            "claim_boundary": "Reduces discovery candidates after host refresh; existing chat context is not erased."}


def restore(active: Path, apply: bool = False) -> dict:
    active = active.resolve()
    if not (active.parent / "srednoff-os/discovery-profile.json").resolve().is_relative_to(active.parent):
        raise ValueError("restore marker escapes installation root")
    operations = []
    for retired in sorted(active.rglob("SKILL.srednoff-passive.md")):
        manifest = retired.with_name("SKILL.md")
        if retired.is_symlink() or not retired.resolve().is_relative_to(active) or manifest.exists():
            raise ValueError("restore conflict or escaping manifest")
        operations.append((retired, manifest))
    if apply:
        for retired, manifest in operations:
            retired.rename(manifest)
        save_json(active.parent / "srednoff-os/discovery-profile.json", {"schema_version": 1, "mode": "legacy"})
        save_json(active.parent / "skill-index.json", index(active, active.parent.parent if active.parent.name == ".codex" else None))
    return {"applied": apply, "manifests_to_restore": len(operations), "deletions": 0}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path)
    parser.add_argument("--previous-package", type=Path)
    parser.add_argument("--active-root", type=Path, required=True)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--restore", action="store_true")
    args = parser.parse_args()
    try:
        if not args.restore and (not args.package or not args.previous_package):
            raise ValueError("compact mode requires --package and --previous-package")
        result = restore(args.active_root, args.apply) if args.restore else compact(args.package, args.previous_package, args.active_root, args.apply)
        print(json.dumps(result, indent=2))
        return 0
    except (ValueError, OSError) as exc:
        print(f"compact discovery: FAIL: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
