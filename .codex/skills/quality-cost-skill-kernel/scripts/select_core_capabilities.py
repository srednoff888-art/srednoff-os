#!/usr/bin/env python3
"""Select a token-aware capability shortlist without loading the catalog into model context."""

from __future__ import annotations

import argparse
import difflib
import json
import os
import re
from collections import Counter
from pathlib import Path


IGNORE_DIRS = {
    ".git",
    ".codex",
    ".agent",
    ".next",
    ".turbo",
    ".venv",
    "__pycache__",
    "coverage",
    "dist",
    "build",
    "node_modules",
    "vendor",
}

KEY_FILES = {
    "README.md",
    "package.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "package-lock.json",
    "pyproject.toml",
    "requirements.txt",
    "Cargo.toml",
    "go.mod",
    "Dockerfile",
    "docker-compose.yml",
    "vercel.json",
    "netlify.toml",
    "next.config.js",
    "next.config.ts",
    "vite.config.js",
    "vite.config.ts",
    "tailwind.config.js",
    "tailwind.config.ts",
    "playwright.config.ts",
    "vitest.config.ts",
    "pytest.ini",
    "appsscript.json",
    ".clasp.json",
    "foundry.toml",
    "hardhat.config.ts",
    "robots.txt",
    "sitemap.xml",
}

RISK_TERMS = {
    "auth",
    "security",
    "payment",
    "billing",
    "production",
    "deploy",
    "migration",
    "database",
    "privacy",
    "seo",
    "ads",
    "ppc",
    "crypto",
    "wallet",
    "smart contract",
    "launch",
}

BUDGET_QUOTAS = {
    "lean": {1: 0.80, 2: 0.20, 3: 0.00},
    "balanced": {1: 0.50, 2: 0.40, 3: 0.10},
    "deep": {1: 0.35, 2: 0.45, 3: 0.20},
    "turbo": {1: 0.20, 2: 0.45, 3: 0.35},
}

GROUP_CONTEXT_COST = {
    1: 0.35,
    2: 1.00,
    3: 2.40,
}

GROUP_VALUE_MULTIPLIER = {
    1: 1.10,
    2: 1.65,
    3: 2.30,
}

DOMAIN_INTENT_TERMS = {
    "ai-llm-agents-rag": (
        "llm",
        "agent",
        "agents",
        "rag",
        "eval",
        "evals",
        "redteam",
        "red-team",
        "promptfoo",
        "prompt evaluation",
        "system prompt",
        "system prompts",
        "prompt leak",
        "prompt leaks",
        "leaked prompt",
        "fable 5",
        "fable5",
        "external prompt",
        "instruction migration",
        "prompt repository",
        "agent workflow",
        "guardrail",
    ),
    "testing-qa-quality": (
        "test",
        "tests",
        "testing",
        "qa",
        "regression",
        "ci gate",
        "quality gate",
        "eval",
        "evals",
    ),
    "repo-intake-context": (
        "selector",
        "skill selector",
        "capability",
        "capabilities",
        "kernel",
        "routing",
        "roi",
        "token roi",
    ),
    "research-competitive-intel": (
        "source ranking",
        "source-rank",
        "benchmark",
        "compare sources",
        "github research",
        "top sources",
    ),
    "web-design-visual-ui": (
        "ui",
        "ux",
        "ui/ux",
        "web design",
        "landing",
        "component",
        "components",
        "ui kit",
        "shadcn",
        "21st",
        "magic ui",
        "design brief",
    ),
    "creative-design-systems": (
        "design system",
        "design tokens",
        "visual direction",
        "brand",
        "theme",
        "source ranking",
        "ui kit",
    ),
    "three-d-web-xr-graphics": (
        "3d",
        "3d web",
        "three",
        "three.js",
        "r3f",
        "react three fiber",
        "webgl",
        "webgpu",
        "gltf",
        "glb",
        "3d asset",
        "3d assets",
        "model-viewer",
        "babylon",
        "shader",
    ),
}

SUPPORT_DOMAINS = {
    "repo-intake-context",
    "testing-qa-quality",
    "security-appsec",
    "observability-incident",
}

DOMAIN_SKILL_HINTS = {
    "repo-intake-context": [
        "codebase-map-indexer",
        "source-driven-development",
        "monorepo-boundary-architecture",
        "skill-catalog-orchestrator",
        "record-replay-skill-miner",
    ],
    "ai-llm-agents-rag": [
        "external-prompt-pattern-miner",
        "promptfoo-evals-redteam-ci",
        "agents-sdk-production-workflow",
        "codex-subagent-orchestration",
        "ai-evals-regression-suite",
        "rag-evaluation-agent",
        "context-engineering",
        "ai-sdk",
    ],
    "observability-incident": [
        "observability-instrumentation",
        "sre-incident-commander-agent",
        "performance-sre-agent",
    ],
    "performance-optimization": [
        "performance-optimization",
        "core-web-vitals-frontend",
        "performance-sre-agent",
    ],
    "research-competitive-intel": [
        "github-research",
        "source-ranking-roi-selector",
        "skill-catalog-orchestrator",
        "record-replay-skill-miner",
        "codex-subagent-orchestration",
        "content-strategist-agent",
    ],
    "web-design-visual-ui": [
        "design-brief-autogenerator",
        "source-ranking-roi-selector",
        "ui-component-source-router",
        "design-brief-intake-router",
        "visual-regression-design-gate",
    ],
    "creative-design-systems": [
        "source-ranking-roi-selector",
        "design-brief-autogenerator",
        "design-token-compiler",
        "brand-theme-factory",
    ],
    "three-d-web-xr-graphics": [
        "source-ranking-roi-selector",
        "3d-experience-brief-intake",
        "three-vs-babylon-vs-model-viewer",
        "gltf-optimization-pipeline-v2",
        "3d-performance-budget-gate",
        "webgl-performance-agent",
    ],
}

DIRECT_SKILL_ALIASES = [
    (
        "external-prompt-pattern-miner",
        (
            "system prompt repository",
            "system prompt repositories",
            "system prompt leak",
            "system prompt leaks",
            "prompt leak",
            "prompt leaks",
            "leaked prompt",
            "prompt dump",
            "prompt dumps",
            "external prompt",
            "external prompts",
            "fable 5",
            "fable5",
            "claude fable",
            "vendor prompt",
            "prompt repository",
            "prompt repositories",
            "migrate prompt patterns",
            "agent instruction migration",
        ),
    ),
    (
        "promptfoo-evals-redteam-ci",
        (
            "promptfoo",
            "promptfoo eval",
            "promptfoo evals",
            "promptfoo redteam",
            "promptfoo red-team",
            "redteam",
            "red-team",
            "llm eval ci",
            "prompt evaluation",
        ),
    ),
    (
        "record-replay-skill-miner",
        (
            "record replay",
            "record & replay",
            "record-and-replay",
            "replay capture",
            "demonstration into reusable skill",
            "workflow into reusable skill",
            "repeated workflow",
        ),
    ),
    (
        "codex-subagent-orchestration",
        (
            "subagent",
            "subagents",
            "custom agent",
            "custom agents",
            "context contract",
            "merge protocol",
        ),
    ),
    (
        "source-ranking-roi-selector",
        (
            "source ranking",
            "source-rank",
            "ui kit",
            "ui kits",
            "3d asset",
            "3d assets",
            "design source",
            "component source",
        ),
    ),
    (
        "design-brief-autogenerator",
        (
            "design brief",
            "brief before ui",
            "brief before 3d",
            "autogenerate brief",
            "autogenerated brief",
            "ui/ux brief",
        ),
    ),
]


def default_codex_home() -> Path:
    return Path(os.environ.get("CODEX_HOME", Path.home() / ".codex"))


def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower())


def contains_term(haystack: str, term: str) -> bool:
    term = normalize(term)
    if not term:
        return False
    if re.fullmatch(r"[a-z0-9]+", term) and len(term) <= 3:
        return re.search(rf"(?<![a-z0-9]){re.escape(term)}(?![a-z0-9])", haystack) is not None
    return term in haystack


def tokenize(text: str) -> set[str]:
    return {
        item
        for item in re.findall(r"[a-z0-9]+", text.lower())
        if len(item) > 1 and item not in {"and", "the", "for", "with", "from", "into", "this", "that"}
    }


def safe_read(path: Path, max_chars: int = 20000) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="ignore")[:max_chars]
    except Exception:
        return ""


def walk_project(project: Path, max_files: int = 700) -> tuple[list[str], Counter[str], str]:
    names: list[str] = []
    extensions: Counter[str] = Counter()
    snippets: list[str] = []

    if not project.exists():
        return names, extensions, ""

    for root, dirs, files in os.walk(project):
        dirs[:] = [name for name in dirs if name not in IGNORE_DIRS and not name.startswith(".cache")]
        rel_root = Path(root).relative_to(project)
        for file_name in files:
            rel = str((rel_root / file_name) if str(rel_root) != "." else Path(file_name)).replace("\\", "/")
            names.append(rel)
            suffix = Path(file_name).suffix.lower()
            if suffix:
                extensions[suffix] += 1
            if file_name in KEY_FILES or rel in KEY_FILES:
                snippets.append(f"\n--- {rel} ---\n{safe_read(Path(root) / file_name)}")
            if len(names) >= max_files:
                return names, extensions, "\n".join(snippets)
    return names, extensions, "\n".join(snippets)


def load_json(path: Path) -> list[dict]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def parse_skill_frontmatter(skill_md: Path) -> dict:
    text = safe_read(skill_md, max_chars=5000)
    name = skill_md.parent.name
    description = ""

    if text.startswith("---"):
        lines = text.splitlines()
        for line in lines[1:]:
            if line.strip() == "---":
                break
            if line.startswith("name:"):
                name = line.split(":", 1)[1].strip().strip('"').strip("'")
            elif line.startswith("description:"):
                description = line.split(":", 1)[1].strip().strip('"').strip("'")

    return {
        "name": name,
        "path": str(skill_md.parent),
        "description": description,
        "has_openai_yaml": (skill_md.parent / "agents" / "openai.yaml").exists(),
        "skill_md_bytes": skill_md.stat().st_size,
    }


def build_skill_index(skills_root: Path) -> list[dict]:
    if not skills_root.exists():
        return []

    items: list[dict] = []
    for skill_md in skills_root.rglob("SKILL.md"):
        if ".system" in skill_md.parts:
            continue
        items.append(parse_skill_frontmatter(skill_md))
    return sorted(items, key=lambda item: (str(item.get("name", "")), str(item.get("path", ""))))


def load_skill_index(skill_index_path: Path, skills_root: Path | None) -> list[dict]:
    if skills_root is not None:
        built = build_skill_index(skills_root)
        if built:
            return prepare_skill_index(built)
    if skill_index_path.exists():
        return prepare_skill_index(load_json(skill_index_path))
    return []


def prepare_skill_index(skill_index: list[dict]) -> list[dict]:
    prepared: list[dict] = []
    for skill in skill_index:
        item = dict(skill)
        skill_text = f"{item.get('name', '')} {item.get('description', '')}".lower()
        item["_text"] = skill_text
        item["_tokens"] = tokenize(skill_text)
        item["_name_lower"] = str(item.get("name", "")).lower()
        item["_path_lower"] = str(item.get("path", "")).lower()
        prepared.append(item)
    return prepared


def term_score(term: str, haystack: str) -> int:
    term = normalize(term)
    if not term:
        return 0
    if contains_term(haystack, term):
        if " " in term or len(term) > 8:
            return 3
        return 2
    return 0


def infer_intent_domains(brief_haystack: str) -> set[str]:
    domains: set[str] = set()
    for domain_id, terms in DOMAIN_INTENT_TERMS.items():
        if any(contains_term(brief_haystack, term) for term in terms):
            domains.add(domain_id)
    return domains


def estimate_context_cost(record: dict, budget: str) -> float:
    cost = GROUP_CONTEXT_COST.get(record["group"], 1.0)
    if record["kind"] == "agent":
        cost += 0.35
    if budget == "lean" and record["group"] == 3:
        cost += 1.00
    if budget == "turbo" and record["group"] == 3:
        cost -= 0.25
    return max(cost, 0.20)


def estimate_roi(relevance: float, record: dict, budget: str, intent_match: bool) -> float:
    value = max(relevance, 0.0) * GROUP_VALUE_MULTIPLIER.get(record["group"], 1.0)
    if intent_match:
        value += 4.0
    if record["kind"] == "skill":
        value += 0.75
    if record["group"] == 1:
        value += 1.25
    if budget == "turbo" and record["group"] == 3:
        value += 2.0
    return value / estimate_context_cost(record, budget)


def score_record(
    record: dict,
    brief_haystack: str,
    project_haystack: str,
    file_blob: str,
    budget: str,
    intent_domains: set[str],
) -> float:
    score = 0.0
    for term in record["selection_terms"]:
        score += term_score(term, brief_haystack) * 2.4
        score += term_score(term, project_haystack) * 0.65
    for signal in record["file_signals"]:
        if signal.lower() in file_blob or signal.lower() in project_haystack:
            score += 3.0

    group = record["group"]
    if group == 1:
        score += 1.0
    elif group == 3 and budget == "lean":
        score -= 8.0
    elif group == 3 and budget == "balanced":
        score -= 2.0

    if record["kind"] == "agent" and budget == "lean":
        score -= 1.0

    if group == 3 and any(contains_term(brief_haystack, term) or contains_term(project_haystack, term) for term in RISK_TERMS):
        score += 3.0

    intent_match = record["domain_id"] in intent_domains
    if intent_match:
        score += 7.0
    elif intent_domains and record["domain_id"] not in SUPPORT_DOMAINS:
        score -= 2.5

    roi = estimate_roi(score, record, budget, intent_match)
    score += min(4.0, roi / 4.0)

    return score


def group_limits(max_items: int, budget: str) -> dict[int, int]:
    quotas = BUDGET_QUOTAS[budget]
    limits = {group: int(max_items * ratio) for group, ratio in quotas.items()}
    remaining = max_items - sum(limits.values())
    for group in (1, 2, 3):
        if remaining <= 0:
            break
        limits[group] += 1
        remaining -= 1
    return limits


def select_records(
    catalog: list[dict],
    brief_haystack: str,
    project_haystack: str,
    file_names: list[str],
    budget: str,
    max_items: int,
) -> list[tuple[float, dict]]:
    intent_domains = infer_intent_domains(brief_haystack)
    file_blob = "\n".join(file_names).lower()
    scored = [
        (score_record(record, brief_haystack, project_haystack, file_blob, budget, intent_domains), record)
        for record in catalog
    ]
    scored.sort(key=lambda item: (item[0], -item[1]["group"], item[1]["kind"] == "skill"), reverse=True)

    limits = group_limits(max_items, budget)
    used_groups = Counter()
    used_slugs: set[str] = set()
    used_domains: Counter[str] = Counter()
    selected: list[tuple[float, dict]] = []
    per_domain_limit = {"lean": 3, "balanced": 4, "deep": 6, "turbo": 8}[budget]
    minimum_score = {"lean": 4.0, "balanced": 3.0, "deep": 2.0, "turbo": 1.0}[budget]

    for score, record in scored:
        if score < minimum_score:
            continue
        group = record["group"]
        if used_groups[group] >= limits[group]:
            continue
        if group == 3 and budget == "lean":
            continue
        if record["capability_slug"] in used_slugs:
            continue
        if used_domains[record["domain_id"]] >= per_domain_limit:
            continue
        selected.append((score, record))
        used_groups[group] += 1
        used_slugs.add(record["capability_slug"])
        used_domains[record["domain_id"]] += 1
        if len(selected) >= max_items:
            break

    if not selected:
        fallback_ids = {
            "repo-intake-context.context-map",
            "repo-intake-context.command-discovery",
            "code-quality-maintainability.pattern-extractor",
            "testing-qa-quality.cheap-regression-selector",
            "security-appsec.static-risk-scan",
        }
        selected = [(99.0, record) for record in catalog if record["id"] in fallback_ids][:max_items]

    return selected


def record_mapping_text(record: dict) -> str:
    return " ".join(
        [
            record["domain_id"],
            record["domain"],
            record["capability_slug"],
            record["title"],
            " ".join(record["selection_terms"]),
        ]
    )


def score_skill_mapping(record: dict, skill: dict, record_tokens: set[str]) -> int:
    skill_text = str(skill.get("_text", ""))
    if not record_tokens:
        record_tokens = tokenize(record_mapping_text(record))
    skill_tokens = skill.get("_tokens")
    if not isinstance(skill_tokens, set):
        skill_tokens = tokenize(skill_text)
    score = len(record_tokens & skill_tokens)

    skill_name = str(skill.get("_name_lower", skill.get("name", ""))).lower()
    skill_path = str(skill.get("_path_lower", skill.get("path", ""))).lower()
    for priority, preferred_name in enumerate(DOMAIN_SKILL_HINTS.get(record["domain_id"], [])):
        if skill_name == preferred_name:
            score += 16 - priority
    if record["domain_id"] in skill_name:
        score += 8
    if record["capability_slug"] in skill_name:
        score += 6
    if "\\upstream" in skill_path or "/upstream" in skill_path:
        score -= 5
    if "claude-imported" in skill_path:
        score -= 1
    specialized_domains = {
        "ios": "mobile-ios",
        "swiftui": "mobile-ios",
        "android": "mobile-android",
        "kotlin": "mobile-android",
        "seo": "seo-technical-content",
        "sitemap": "seo-technical-content",
        "robots": "seo-technical-content",
        "hreflang": "seo-technical-content",
        "ppc": "ppc-growth-marketing",
        "secrets": "security-appsec",
        "secret": "security-appsec",
        "web3": "crypto-web3-defi",
        "crypto": "crypto-web3-defi",
        "threejs": "three-d-web-xr-graphics",
        "three": "three-d-web-xr-graphics",
    }
    for hint, domain_id in specialized_domains.items():
        if hint in skill_name and record["domain_id"] != domain_id:
            score -= 8
    for term in record["selection_terms"]:
        term_norm = normalize(term)
        if len(term_norm) > 4 and term_norm in skill_text:
            score += 2
    return score


def map_existing_skills(record: dict, skill_index: list[dict], limit: int = 3) -> list[dict]:
    scored: list[tuple[int, dict]] = []
    record_tokens = tokenize(record_mapping_text(record))
    for skill in skill_index:
        score = score_skill_mapping(record, skill, record_tokens)
        if score >= 4:
            scored.append((score, skill))
    scored.sort(key=lambda item: (item[0], -len(str(item[1].get("path", ""))), item[1].get("name", "")), reverse=True)
    mapped = []
    seen_names: set[str] = set()
    for score, skill in scored:
        name = skill.get("name", "")
        if name in seen_names:
            continue
        mapped.append(
            {
                "score": score,
                "name": name,
                "path": skill.get("path", ""),
                "description": skill.get("description", ""),
            }
        )
        seen_names.add(name)
        if len(mapped) >= limit:
            break
    return mapped


def apply_direct_skill_aliases(enriched: list[dict], skill_index: list[dict], brief_haystack: str) -> None:
    if not enriched:
        return
    skills_by_name = {str(skill.get("name", "")): skill for skill in skill_index}
    target = enriched[0].setdefault("mapped_skills", [])
    direct: list[dict] = []
    direct_names: set[str] = set()
    for skill_name, triggers in DIRECT_SKILL_ALIASES:
        if skill_name in direct_names:
            continue
        if not any(contains_term(brief_haystack, trigger) for trigger in triggers):
            continue
        skill = skills_by_name.get(skill_name)
        if not skill:
            continue
        direct.append(
            {
                "score": 99,
                "name": skill_name,
                "path": skill.get("path", ""),
                "description": skill.get("description", ""),
                "reason": "direct-brief-alias",
            },
        )
        direct_names.add(skill_name)

    if direct:
        target[:] = direct + [skill for skill in target if skill.get("name", "") not in direct_names]


def enrich_selected(
    selected: list[tuple[float, dict]],
    skill_index: list[dict],
    brief_haystack: str,
    budget: str,
) -> list[dict]:
    enriched = []
    for score, record in selected:
        item = dict(record)
        item["score"] = round(score, 2)
        item["estimated_context_cost"] = round(estimate_context_cost(record, budget), 2)
        item["estimated_roi"] = round(estimate_roi(score, record, budget, False), 2)
        item["mapped_skills"] = map_existing_skills(record, skill_index)
        item["direct_skill_matches"] = []
        enriched.append(item)
    apply_direct_skill_aliases(enriched, skill_index, brief_haystack)
    for item in enriched:
        item["direct_skill_matches"] = [
            skill["name"]
            for skill in item.get("mapped_skills", [])
            if skill.get("reason") == "direct-brief-alias"
        ]
    return enriched


def render_markdown(selected: list[dict], project: Path, budget: str, brief: str, ext_counts: Counter[str], intent_domains: set[str]) -> str:
    lines = [
        "# Quality/Cost Capability Selection",
        "",
        f"Project: `{project}`",
        f"Budget: `{budget}`",
        f"Brief: {brief or '(not provided)'}",
        "",
        "## Selected",
        "",
        "| Score | ROI | Cost | Group | Kind | Capability | Existing skill |",
        "|---:|---:|---:|---:|---|---|---|",
    ]
    for record in selected:
        mapped = record.get("mapped_skills", [])
        skill_name = f"`{mapped[0]['name']}`" if mapped else "-"
        lines.append(
            f"| {record['score']:.1f} | {record['estimated_roi']:.1f} | {record['estimated_context_cost']:.2f} | {record['group']} {record['group_label']} | {record['kind']} | `{record['id']}` | {skill_name} |"
        )

    read_paths: list[str] = []
    seen_paths: set[str] = set()
    for record in selected:
        for skill in record.get("mapped_skills", [])[:1]:
            path = skill.get("path", "")
            if path and path not in seen_paths:
                read_paths.append(path)
                seen_paths.add(path)

    lines.extend(
        [
            "",
            "## Read Next",
            "",
            "Open only these mapped `SKILL.md` files when they are relevant to the task. Do not open the full 4500-record catalog.",
        ]
    )
    if read_paths:
        for path in read_paths[:12]:
            lines.append(f"- `{Path(path) / 'SKILL.md'}`")
    else:
        lines.append("- No direct installed skill mapping; use the selected capability ids as routing hints.")

    direct_matches = []
    seen_direct: set[str] = set()
    for record in selected:
        for skill_name in record.get("direct_skill_matches", []):
            if skill_name not in seen_direct:
                direct_matches.append(skill_name)
                seen_direct.add(skill_name)
    if direct_matches:
        lines.extend(
            [
                "",
                "## Direct Skill Matches",
                "",
                "These skills matched explicit terms in the task brief and are surfaced even when several aliases trigger at once.",
            ]
        )
        for skill_name in direct_matches:
            lines.append(f"- `{skill_name}`")

    lines.extend(
        [
            "",
            "## Use Order",
            "",
            "1. Keep the legacy selector principle: Group quotas, non-overlap, and compact mapped `SKILL.md` reads still win.",
            "2. Run Group 1 records first and keep their output compact.",
            "3. Add Group 2 records only where they affect implementation or validation.",
            "4. Use Group 3 records only when risk, value, or explicit TURBO justifies deeper context.",
            "5. Prefer higher ROI when two capabilities solve the same failure mode.",
            "",
            "## Intent Domains",
            "",
        ]
    )
    if intent_domains:
        for domain in sorted(intent_domains):
            lines.append(f"- `{domain}`")
    else:
        lines.append("- No explicit brief intent domain detected; selector used project evidence and fallback support domains.")
    lines.extend(
        [
            "",
            "## File Signal Summary",
            "",
        ]
    )
    for ext, count in ext_counts.most_common(12):
        lines.append(f"- `{ext}`: {count}")
    if not ext_counts:
        lines.append("- No files scanned.")
    return "\n".join(lines) + "\n"


def render_ids(selected: list[dict]) -> str:
    lines = ["# Capability IDs", ""]
    for record in selected:
        mapped = record.get("mapped_skills", [])
        if mapped:
            skill_names = []
            seen_names: set[str] = set()
            for skill in mapped[:3]:
                name = str(skill.get("name", ""))
                if name and name not in seen_names:
                    skill_names.append(name)
                    seen_names.add(name)
            suffix = " -> " + ", ".join(skill_names)
        else:
            suffix = ""
        lines.append(f"- {record['id']} [{record['group_label']}]{suffix}")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    default_root = Path(__file__).resolve().parents[1]
    codex_home = default_codex_home()
    parser.add_argument("--catalog", default=str(default_root / "references" / "core-3000-capabilities.json"))
    parser.add_argument("--skill-index", default=str(codex_home / "skill-index.json"))
    parser.add_argument("--skills-root", default="")
    parser.add_argument("--project", default=".")
    parser.add_argument("--brief", default="")
    parser.add_argument("--budget", choices=["lean", "balanced", "deep", "turbo"], default="balanced")
    parser.add_argument("--max", type=int, default=24)
    parser.add_argument("--json-output", default="")
    parser.add_argument("--format", choices=["compact", "ids"], default="compact")
    args = parser.parse_args()

    catalog_path = Path(args.catalog)
    skill_index_path = Path(args.skill_index)
    catalog = load_json(catalog_path)
    skills_root = Path(args.skills_root) if args.skills_root else None
    if skills_root is None and not skill_index_path.exists():
        skills_root = default_root.parent
    skill_index = load_skill_index(skill_index_path, skills_root)
    skill_names = {str(skill.get("name", "")) for skill in skill_index}
    for skill_name, _ in DIRECT_SKILL_ALIASES:
        if skill_name not in skill_names:
            close = difflib.get_close_matches(skill_name, skill_names, n=3)
            print(
                f"warning: direct skill alias '{skill_name}' is not present in the skill index"
                + (f"; closest={', '.join(close)}" if close else ""),
                file=os.sys.stderr,
            )

    project = Path(args.project).resolve()
    file_names, ext_counts, snippets = walk_project(project)
    brief_haystack = normalize(args.brief)
    project_haystack = normalize("\n".join(file_names) + "\n" + snippets)
    haystack = normalize(args.brief + "\n" + "\n".join(file_names) + "\n" + snippets)
    intent_domains = infer_intent_domains(brief_haystack)
    selected = enrich_selected(
        select_records(catalog, brief_haystack, project_haystack, file_names, args.budget, args.max),
        skill_index,
        brief_haystack,
        args.budget,
    )

    if args.json_output:
        Path(args.json_output).write_text(json.dumps(selected, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if args.format == "ids":
        print(render_ids(selected))
    else:
        print(render_markdown(selected, project, args.budget, args.brief, ext_counts, intent_domains))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
