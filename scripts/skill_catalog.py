"""Portable skill metadata, structural audit, and bounded native deployment.

Quality findings are review signals, never a claim of model effectiveness.
"""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / ".codex" / "skills" if (ROOT / ".codex" / "skills").exists() else ROOT / "skills"
POLICY = ROOT / ".codex" / "srednoff-os" / "skill-contracts.json"
NAME = re.compile(r"^[a-z0-9][a-z0-9-]{0,63}$")
DISCOVERY_ANCHORS = {"github-research", "product-builder", "production-review", "quality-cost-skill-kernel"}
LEGACY_LAYOUTS = {
    "agentic-seo-skill": "seo",
    "claude-imported/ai-sdk/upstream": "ai-sdk-upstream-reference",
    "claude-imported/chat-sdk/upstream": "chat-sdk-upstream-reference",
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def resources(folder: Path) -> list[Path]:
    return [p for p in sorted(folder.rglob("*")) if p.is_file()
            and p.suffix not in {".pyc", ".log"} and "__pycache__" not in p.parts
            and not any(".bak." in part for part in p.parts)
            and p.name != "SKILL.srednoff-passive.md"]


def save_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def metadata(path: Path) -> tuple[dict, str]:
    text = path.read_text(encoding="utf-8-sig")
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise ValueError("missing frontmatter")
    try:
        end = lines.index("---", 1)
    except ValueError as exc:
        raise ValueError("unterminated frontmatter") from exc
    values = {}
    for index in range(1, end):
        match = re.match(r"^(name|description):\s*(.*)$", lines[index])
        if not match:
            continue
        key, value = match.groups()
        if key in values:
            raise ValueError(f"duplicate {key}")
        if value in {">", ">-", ">+", "|", "|-", "|+"}:
            parts = []
            for line in lines[index + 1:end]:
                if line and not line[0].isspace():
                    break
                parts.append(line.strip())
            value = " ".join(parts).strip()
        elif value.startswith('"'):
            value = json.loads(value)
        elif value.startswith("'") and value.endswith("'"):
            value = value[1:-1].replace("''", "'")
        values[key] = value
    if not NAME.fullmatch(values.get("name", "")):
        raise ValueError("invalid lowercase skill name")
    if not isinstance(values.get("description"), str) or not values["description"].strip():
        raise ValueError("missing description")
    return values, "\n".join(lines[end + 1:]).strip()


def passive_library(skills: Path) -> Path | None:
    state = skills.parent / "srednoff-os" / "discovery-profile.json"
    if not state.is_file():
        return None
    data = json.loads(state.read_text(encoding="utf-8-sig"))
    if data.get("mode") != "compact":
        return None
    library = state.parent / "library"
    if library.is_symlink() or not library.resolve().is_relative_to(skills.parent.resolve()):
        raise ValueError("passive library escapes installation metadata")
    if not library.is_dir():
        raise ValueError("compact discovery marker has no passive library")
    return library


def manifests(skills: Path) -> list[Path]:
    def candidates(root):
        return [p for p in sorted(root.rglob("SKILL.md")) if ".system" not in p.parts
                and not any(".bak." in part for part in p.parts)]
    active = candidates(skills)
    passive = passive_library(skills)
    if passive is None:
        return active
    # Local/private active workflows intentionally override the passive public copy.
    active_names = set()
    for path in active:
        try:
            active_names.add(metadata(path)[0]["name"])
        except ValueError:
            pass  # Leave malformed manifests visible to the validator.
    return active + [p for p in candidates(passive) if metadata(p)[0]["name"] not in active_names]


def index(skills: Path, base: Path | None = None) -> list[dict]:
    result = []
    names = set()
    for path in manifests(skills):
        if ".system" in path.parts or any(".bak." in part for part in path.parts):
            continue
        values, _ = metadata(path)
        if values["name"] in names:
            raise ValueError(f"duplicate skill name: {values['name']}")
        names.add(values["name"])
        folder = path.parent.resolve()
        stored = os.path.relpath(folder, base.resolve()).replace("\\", "/") if base else str(folder)
        canonical = path.read_text(encoding="utf-8-sig").encode("utf-8")
        result.append({
            **values, "path": stored,
            "has_openai_yaml": (folder / "agents" / "openai.yaml").exists(),
            "skill_md_bytes": len(canonical),
            "content_sha256": hashlib.sha256(canonical).hexdigest(),
            "instruction_tier": "legacy-checklist" if "Use this skill to handle " in metadata(path)[1] else "workflow",
        })
    if not result:
        raise ValueError("empty skill catalog")
    return sorted(result, key=lambda item: item["name"])


def audit(skills: Path) -> dict:
    rows, errors = [], []
    bodies = defaultdict(list)
    for path in manifests(skills):
        if ".system" in path.parts or any(".bak." in part for part in path.parts):
            continue
        try:
            values, body = metadata(path)
        except (ValueError, UnicodeError) as exc:
            errors.append({"path": path.relative_to(skills.parent).as_posix(), "issue": str(exc)})
            continue
        name, description = values["name"], values["description"]
        findings = []
        folder_base = skills if path.is_relative_to(skills) else passive_library(skills)
        relative_folder = path.parent.relative_to(folder_base).as_posix()
        if path.parent.name != name and LEGACY_LAYOUTS.get(relative_folder) != name:
            errors.append({"skill": name, "issue": "directory/frontmatter mismatch"})
        if re.search(r"\[TODO|\[TBD|TODO:", body + description):
            errors.append({"skill": name, "issue": "unfinished scaffold"})
        if len(description) > 300:
            findings.append("long-description")
        if "Trigger when the task involves" in description:
            findings.append("catchall-trigger")
        if any(line in body for line in (
                "Use this skill to handle ",
                "1. Clarify the user outcome, constraints, current stack, and definition of done.",
                "1. Restate the user outcome, target quality level, constraints, and definition of done.",
                "1. Confirm the business outcome, owner, source data, constraints, and success metric.")):
            findings.append("generic-template")
        if len(body.split()) > 1200:
            findings.append("large-entrypoint")
        # Ignore code samples, which can legitimately show placeholder links.
        prose = re.sub(r"```.*?```", "", body, flags=re.S)
        for target in re.findall(r"\]\(([^)]+)\)", prose):
            target = target.strip().split(" ", 1)[0].strip("<>")
            if re.match(r"^[a-z][a-z0-9+.-]*:", target, re.I) or target.startswith("#"):
                continue
            local = unquote(target.split("#", 1)[0])
            if local and "." in local and not (path.parent / local).exists():
                errors.append({"skill": name, "issue": f"missing reference: {local}"})
        normalized = re.sub(r"^# .*$", "", body, flags=re.M).strip()
        bodies[hashlib.sha256(normalized.encode()).hexdigest()].append(name)
        rows.append({
            "name": name, "description_chars": len(description),
            "body_words": len(body.split()), "findings": findings,
            "validation": "structural-only",
        })
    counts = Counter(row["name"] for row in rows)
    for name, count in counts.items():
        if count > 1:
            errors.append({"skill": name, "issue": "duplicate name"})
    return {
        "schema_version": 1, "skills": len(rows), "errors": errors,
        "finding_counts": dict(sorted(Counter(f for row in rows for f in row["findings"]).items())),
        "duplicate_bodies": sorted((sorted(names) for names in bodies.values() if len(names) > 1)),
        "records": rows,
        "claim_boundary": "Metadata and lint do not prove task quality, token ROI, or model compatibility.",
    }


def selector_module(skills: Path):
    script = skills / "quality-cost-skill-kernel" / "scripts" / "select_core_capabilities.py"
    spec = importlib.util.spec_from_file_location("srednoff_selector", script)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def select_profile(skills: Path, project: Path, brief: str, budget: str, maximum: int,
                   max_entrypoint_chars: int | None = None) -> dict:
    if not 1 <= maximum <= 48:
        raise ValueError("max-skills must be between 1 and 48")
    if max_entrypoint_chars is not None and max_entrypoint_chars < 1:
        raise ValueError("max-entrypoint-chars must be positive")
    module = selector_module(skills)
    catalog = module.load_json(skills / "quality-cost-skill-kernel" / "references" / "core-3000-capabilities.json")
    skills_index = module.prepare_skill_index(index(skills))
    names, _, snippets = module.walk_project(project, max_files=80, read_snippets=True)
    intent = module.normalize(brief)
    project_text = module.normalize("\n".join(names) + "\n" + snippets)
    selected = module.enrich_selected(
        module.select_records(catalog, intent, project_text, names, budget, maximum),
        skills_index, intent, budget,
    )
    # Explicit matches take precedence; generic mappings provide bounded support.
    ordered = [
        skill for record in selected for skill in record.get("mapped_skills", [])
        if skill.get("reason") == "direct-brief-alias"
    ]
    tiers = {item["name"]: item.get("instruction_tier") for item in skills_index}
    for record in selected:
        candidates = [item for item in record.get("mapped_skills", []) if tiers.get(item["name"]) != "legacy-checklist"]
        if candidates:
            ordered.append(candidates[0])
    chosen, seen, omitted = [], set(), []
    folders = {item["name"]: Path(item["path"]) for item in skills_index}
    used_chars = 0
    for skill in ordered:
        if skill["name"] in seen:
            continue
        seen.add(skill["name"])
        chars = len(metadata(folders[skill["name"]] / "SKILL.md")[1])
        if max_entrypoint_chars is not None and used_chars + chars > max_entrypoint_chars:
            omitted.append(skill["name"])
            continue
        chosen.append(skill["name"])
        used_chars += chars
        if len(chosen) >= maximum:
            break
    fingerprints = {}
    if not chosen:
        raise ValueError("no workflow fits the requested profile; increase the entrypoint budget or refine the brief")
    for name in chosen:
        folder = folders[name]
        fingerprints[name] = {p.relative_to(folder).as_posix(): digest(p) for p in resources(folder)}
    return {
        "schema_version": 1, "budget": budget, "brief": brief,
        "max_skills": maximum, "selected": chosen, "files": fingerprints,
        "entrypoint_chars": used_chars, "max_entrypoint_chars": max_entrypoint_chars,
        "omitted_by_entrypoint_budget": omitted,
        "budget_scope": "Selected SKILL.md bodies only; excludes discovery metadata, references and tool output. Not token accounting.",
        "source_paths": {name: folders[name].relative_to(skills.resolve()).as_posix()
                         if folders[name].is_relative_to(skills.resolve()) else str(folders[name]) for name in chosen},
        "catalog_sha256": hashlib.sha256(json.dumps(index(skills, skills), sort_keys=True).encode()).hexdigest(),
        "project_signals_sha256": hashlib.sha256(project_text.encode()).hexdigest(),
        "selection_is_cache": True, "model_switching": "not-performed",
    }


def install_profile(skills: Path, project: Path, profile: dict) -> None:
    destination = project / ".agents" / "skills"
    if not destination.resolve().is_relative_to(project.resolve()):
        raise ValueError("native skills destination escapes project")
    state_path = project / ".agent" / "skill-deployment.json"
    if not state_path.resolve().is_relative_to(project.resolve()):
        raise ValueError("ownership ledger escapes project")
    previous = json.loads(state_path.read_text(encoding="utf-8")) if state_path.exists() else {"files": {}}
    previous_files = previous.get("files", {})
    operations = []
    # Validate the complete plan before copying any files. Never prune or overwrite user edits.
    for name in profile["selected"]:
        source_path = skills / profile["source_paths"][name]
        if source_path.is_symlink():
            raise ValueError(f"symlinked source skill: {name}")
        source = source_path.resolve()
        passive = passive_library(skills)
        if not source.is_relative_to(skills.resolve()) and not (passive and source.is_relative_to(passive.resolve())):
            raise ValueError(f"source escapes library: {name}")
        if source.is_symlink():
            raise ValueError(f"symlinked source skill: {name}")
        source_resources = set(resources(source))
        actual = {p.relative_to(source).as_posix(): digest(p) for p in source_resources}
        if actual != profile["files"].get(name):
            raise ValueError(f"stale source fingerprint: {name}")
        for path in sorted(source.rglob("*")):
            if path.is_symlink():
                raise ValueError(f"symlinked source resource: {name}")
            if path not in source_resources:
                continue
            relative = path.relative_to(source)
            target = destination / name / relative
            if not target.resolve().is_relative_to(destination.resolve()):
                raise ValueError(f"destination escapes native skills: {name}")
            source_hash = digest(path)
            if target.exists() and digest(target) != source_hash:
                old_hash = previous_files.get(name, {}).get(relative.as_posix())
                if old_hash is None or digest(target) != old_hash:
                    raise ValueError(f"user-modified resource conflict: {name}/{relative.as_posix()}")
            operations.append((path, target))
    for source, target in operations:
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
    # Keep earlier owned files in the ledger; retained skills are intentionally not pruned.
    ownership = dict(previous_files)
    for name, files in profile["files"].items():
        ownership[name] = files
    save_json(state_path, {"schema_version": 1, "files": ownership})


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["index", "audit", "profile"])
    parser.add_argument("--skills-root", type=Path, default=SKILLS)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--relative-base", type=Path)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--summary", action="store_true")
    parser.add_argument("--project", type=Path, default=Path("."))
    parser.add_argument("--brief", default="")
    parser.add_argument("--budget", choices=["lean", "balanced", "deep", "turbo"], default="balanced")
    parser.add_argument("--max-skills", type=int, default=12)
    parser.add_argument("--max-entrypoint-chars", type=int)
    parser.add_argument("--install", action="store_true")
    args = parser.parse_args()
    try:
        if args.action == "index":
            result = index(args.skills_root, args.relative_base)
        elif args.action == "audit":
            result = audit(args.skills_root)
        else:
            project = args.project.resolve()
            if not project.is_dir():
                raise ValueError("project directory does not exist")
            result = select_profile(args.skills_root, project, args.brief, args.budget, args.max_skills,
                                    args.max_entrypoint_chars)
            if args.install:
                install_profile(args.skills_root, project, result)
            if not args.output and not (project / ".agent").resolve().is_relative_to(project):
                raise ValueError("profile output escapes project")
            args.output = args.output or project / ".agent" / "skill-profile.json"
        if args.check and args.output:
            if not args.output.exists() or json.loads(args.output.read_text(encoding="utf-8-sig")) != result:
                raise ValueError("generated artifact is stale")
        elif args.output:
            save_json(args.output, result)
        elif args.summary and args.action == "audit":
            print(json.dumps({key: result[key] for key in ("skills", "finding_counts", "errors")}))
        else:
            print(json.dumps(result, ensure_ascii=False, indent=2))
        if args.action == "audit" and result["errors"]:
            print(f"skill audit: {len(result['errors'])} structural errors")
            return 1
        print(f"skill catalog {args.action}: OK")
        return 0
    except (ValueError, OSError) as exc:
        print(f"skill catalog {args.action}: FAIL: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
