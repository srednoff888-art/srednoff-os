#!/usr/bin/env python3
"""Build the 4500-record quality/cost capability catalog.

The output file keeps the historical ``core-3000-capabilities.json`` name for
compatibility with installed wrappers, but the generated catalog now contains
4500 records.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


DOMAINS = [
    ("repo-intake-context", "Repository intake and context", ["repo", "repository", "codebase", "workspace", "monorepo"], ["AGENTS.md", "README.md", ".git", "package.json", "pyproject.toml"]),
    ("code-quality-maintainability", "Code quality and maintainability", ["refactor", "maintainability", "dead code", "complexity", "style"], ["src", "lib", "eslint.config", "ruff.toml", "sonar-project.properties"]),
    ("architecture-system-design", "Architecture and system design", ["architecture", "system design", "service boundary", "module", "ADR"], [".agent/PLANS.md", "docs/adr", "architecture", "infra"]),
    ("backend-api-services", "Backend APIs and services", ["backend", "api", "service", "endpoint", "controller"], ["openapi.yaml", "routes", "controllers", "server.ts", "main.py"]),
    ("frontend-ui-engineering", "Frontend UI engineering", ["frontend", "react", "vue", "component", "state"], ["src/App", "components", "vite.config", "next.config", "tailwind.config"]),
    ("web-design-visual-ui", "Web design and visual UI", ["web design", "visual", "layout", "landing", "brand"], ["app", "pages", "styles", "public", "design-system"]),
    ("ui-ux-research-product", "UI/UX research and product flows", ["ux", "user flow", "journey", "wireframe", "prototype"], ["figma", "user-flows", "product", "stories"]),
    ("accessibility-inclusive-design", "Accessibility and inclusive design", ["accessibility", "wcag", "aria", "keyboard", "screen reader"], ["axe", "aria", "accessibility", "playwright"]),
    ("testing-qa-quality", "Testing and QA quality", ["test", "qa", "regression", "coverage", "e2e"], ["tests", "__tests__", "playwright.config", "vitest.config", "pytest.ini"]),
    ("security-appsec", "Application security", ["security", "auth", "xss", "csrf", "injection"], [".env.example", "auth", "middleware", "security", "policies"]),
    ("devops-ci-cd-release", "DevOps CI/CD and release", ["ci", "cd", "pipeline", "release", "deploy"], [".github/workflows", "Dockerfile", "vercel.json", "netlify.toml", "Makefile"]),
    ("cloud-infrastructure-sre", "Cloud infrastructure and SRE", ["cloud", "infra", "sre", "terraform", "kubernetes"], ["terraform", "k8s", "helm", "pulumi", "docker-compose.yml"]),
    ("data-engineering-analytics", "Data engineering and analytics", ["data", "etl", "warehouse", "analytics", "pipeline"], ["dbt_project.yml", "airflow", "dagster", "analytics", "events"]),
    ("databases-storage", "Databases and storage", ["database", "sql", "schema", "migration", "storage"], ["migrations", "schema.sql", "prisma", "supabase", "drizzle.config"]),
    ("ai-llm-agents-rag", "AI, LLM, agents, and RAG", ["ai", "llm", "agent", "rag", "embedding"], ["prompts", "evals", "openai", "langchain", "agents"]),
    ("seo-technical-content", "SEO technical and content", ["seo", "crawl", "index", "schema", "serp"], ["robots.txt", "sitemap.xml", "metadata", "schema.org", "content"]),
    ("ppc-growth-marketing", "PPC, growth, and marketing", ["ppc", "ads", "campaign", "roas", "conversion"], ["gtm", "ga4", "ads", "utm", "landing"]),
    ("ecommerce-revenue", "Ecommerce and revenue flows", ["ecommerce", "checkout", "cart", "product page", "revenue"], ["checkout", "cart", "stripe", "products", "orders"]),
    ("crypto-web3-defi", "Crypto, Web3, and DeFi", ["crypto", "web3", "wallet", "defi", "smart contract"], ["contracts", "hardhat", "foundry.toml", "wagmi", "ethers"]),
    ("mobile-ios", "iOS app development", ["ios", "swiftui", "xcode", "testflight", "app store"], ["Package.swift", ".xcodeproj", ".xcworkspace", "Info.plist", "SwiftUI"]),
    ("mobile-android", "Android app development", ["android", "kotlin", "compose", "gradle", "play store"], ["build.gradle", "settings.gradle", "AndroidManifest.xml", "gradlew"]),
    ("cross-platform-apps", "Cross-platform apps", ["react native", "expo", "flutter", "capacitor", "desktop app"], ["app.json", "expo", "pubspec.yaml", "capacitor.config", "electron"]),
    ("google-workspace-apps", "Google Workspace apps", ["google apps script", "sheets", "docs", "workspace", "clasp"], ["appsscript.json", ".clasp.json", "sheets", "docs"]),
    ("three-d-web-xr-graphics", "3D web, WebGL, WebGPU, and XR", ["three.js", "webgl", "webgpu", "3d", "xr"], ["three", "react-three-fiber", "gltf", "glb", "shaders"]),
    ("animation-media-production", "Animation and media production", ["animation", "motion", "video", "image", "media"], ["lottie", "motion", "ffmpeg", "canvas", "timeline"]),
    ("documentation-content", "Documentation and technical content", ["docs", "documentation", "readme", "guide", "changelog"], ["docs", "README.md", "CHANGELOG.md", "mkdocs.yml", "docusaurus.config"]),
    ("product-management-discovery", "Product management and discovery", ["product", "requirements", "roadmap", "prd", "backlog"], ["product", "requirements", "roadmap", "issues", "stories"]),
    ("business-ops-automation", "Business operations automation", ["operations", "automation", "workflow", "crm", "zapier"], ["workflows", "crm", "automation", "scripts", "jobs"]),
    ("customer-support-success", "Customer support and success", ["support", "ticket", "helpdesk", "customer success", "sla"], ["support", "help", "tickets", "kb", "intercom"]),
    ("legal-privacy-compliance", "Legal, privacy, and compliance", ["privacy", "gdpr", "policy", "legal", "compliance"], ["privacy", "terms", "dpia", "policies", "consent"]),
    ("finance-billing-pricing", "Finance, billing, and pricing", ["billing", "pricing", "invoice", "subscription", "finance"], ["billing", "stripe", "pricing", "invoices", "entitlements"]),
    ("localization-international", "Localization and internationalization", ["i18n", "localization", "locale", "translation", "rtl"], ["locales", "i18n", "translations", "messages", "intl"]),
    ("observability-incident", "Observability and incident response", ["observability", "logs", "tracing", "incident", "monitoring"], ["sentry", "opentelemetry", "logs", "alerts", "dashboards"]),
    ("performance-optimization", "Performance optimization", ["performance", "latency", "core web vitals", "profiling", "cache"], ["lighthouse", "profiling", "cache", "bundle", "perf"]),
    ("integration-api-connectors", "Integrations, APIs, and connectors", ["integration", "webhook", "oauth", "connector", "sdk"], ["webhooks", "integrations", "oauth", "openapi", "sdk"]),
    ("browser-automation-scraping", "Browser automation and scraping", ["browser", "scraping", "crawler", "playwright", "selenium"], ["playwright", "crawler", "scraper", "puppeteer", "selenium"]),
    ("identity-access-enterprise-it", "Identity, access, and enterprise IT", ["identity", "sso", "saml", "rbac", "enterprise"], ["saml", "sso", "rbac", "roles", "permissions"]),
    ("creative-design-systems", "Creative systems and brand production", ["design system", "brand", "tokens", "creative", "assets"], ["tokens", "brand", "figma", "assets", "components"]),
    ("open-source-github-community", "Open source, GitHub, and community", ["github", "open source", "issues", "pull request", "maintainers"], [".github", "CONTRIBUTING.md", "LICENSE", "CODEOWNERS"]),
    ("research-competitive-intel", "Research and competitive intelligence", ["research", "competitor", "market", "benchmark", "trend"], ["research", "benchmarks", "market", "analysis", "reports"]),
    ("desktop-cli-tooling", "Desktop, CLI, and local tooling", ["desktop", "cli", "terminal", "shell", "local tool"], ["cli", "bin", "scripts", "shell", "powershell"]),
    ("package-release-supply-chain", "Package release and supply chain", ["package", "release", "registry", "supply chain", "dependency"], ["package.json", "pyproject.toml", "npm", "pypi", "sbom"]),
    ("content-ai-editorial", "Content, AI editorial, and publishing", ["content", "editorial", "publishing", "ai writing", "brief"], ["content", "posts", "articles", "cms", "editorial"]),
    ("email-crm-sales", "Email, CRM, and sales workflows", ["email", "crm", "sales", "lead", "pipeline"], ["crm", "sales", "email", "leads", "hubspot"]),
    ("data-visualization-bi", "Data visualization and BI", ["dashboard", "bi", "chart", "metrics", "visualization"], ["dashboards", "charts", "looker", "metabase", "reports"]),
    ("machine-learning-mlops", "Machine learning and MLOps", ["machine learning", "mlops", "model", "training", "feature"], ["models", "training", "mlflow", "features", "notebooks"]),
    ("vector-search-retrieval", "Vector search and retrieval", ["vector", "retrieval", "embedding", "semantic search", "index"], ["vectors", "embeddings", "faiss", "qdrant", "pinecone"]),
    ("computer-vision-ocr", "Computer vision and OCR", ["vision", "ocr", "image recognition", "document extraction", "cv"], ["ocr", "images", "cv", "vision", "documents"]),
    ("audio-speech-voice", "Audio, speech, and voice", ["audio", "speech", "voice", "transcription", "tts"], ["audio", "voice", "transcripts", "tts", "stt"]),
    ("game-development-interactive", "Game development and interactive systems", ["game", "physics", "level", "npc", "interactive"], ["game", "levels", "physics", "sprites", "assets"]),
    ("geospatial-maps", "Geospatial and maps", ["map", "geospatial", "geojson", "location", "routing"], ["geojson", "maps", "tiles", "postgis", "location"]),
    ("healthcare-life-sciences", "Healthcare and life sciences", ["healthcare", "medical", "clinical", "patient", "life sciences"], ["hl7", "fhir", "clinical", "patients", "medical"]),
    ("education-learning", "Education and learning products", ["education", "learning", "course", "quiz", "student"], ["courses", "lessons", "quizzes", "lms", "students"]),
    ("real-estate-local-services", "Real estate and local services", ["real estate", "local service", "listing", "booking", "lead"], ["listings", "locations", "booking", "reviews", "services"]),
    ("travel-hospitality", "Travel and hospitality", ["travel", "hotel", "booking", "itinerary", "reservation"], ["travel", "hotels", "bookings", "itinerary", "reservations"]),
    ("hr-recruiting-talent", "HR, recruiting, and talent", ["hr", "recruiting", "candidate", "resume", "interview"], ["jobs", "candidates", "resumes", "ats", "interviews"]),
    ("procurement-vendor-risk", "Procurement and vendor risk", ["procurement", "vendor", "supplier", "risk", "contract"], ["vendors", "suppliers", "procurement", "contracts", "risk"]),
    ("manufacturing-iot-robotics", "Manufacturing, IoT, and robotics", ["manufacturing", "iot", "robotics", "device", "telemetry"], ["iot", "devices", "telemetry", "firmware", "robots"]),
    ("legal-contract-ops", "Legal contract operations", ["contract", "clause", "legal ops", "review", "redline"], ["contracts", "clauses", "legal", "redlines", "policies"]),
    ("personal-productivity-pkm", "Personal productivity and PKM", ["productivity", "notes", "pkm", "knowledge base", "tasks"], ["notes", "tasks", "calendar", "pkm", "vault"]),
]


GROUP_1 = [
    ("context-map", "Context map", "skill", ["map", "inventory", "summary"], "Build a local map of project facts before loading expensive context.", "compact local map and file shortlist"),
    ("dependency-inventory", "Dependency inventory", "skill", ["dependency", "package", "version"], "List relevant dependencies and config files using local manifests.", "dependency and config inventory"),
    ("static-risk-scan", "Static risk scan", "skill", ["static", "risk", "scan"], "Run cheap static checks for obvious risks and missing guardrails.", "risk checklist with file pointers"),
    ("pattern-extractor", "Local pattern extractor", "skill", ["pattern", "convention", "style"], "Extract existing local patterns to avoid over-designing.", "project pattern notes"),
    ("command-discovery", "Command discovery", "skill", ["command", "script", "task"], "Find build, test, lint, deploy, and validation commands.", "command shortlist"),
    ("file-boundary-check", "File boundary check", "skill", ["boundary", "ownership", "module"], "Identify likely ownership boundaries before editing.", "boundary notes"),
    ("cheap-regression-selector", "Cheap regression selector", "skill", ["regression", "test", "affected"], "Select the smallest useful verification set.", "targeted validation plan"),
    ("docs-index", "Docs index", "skill", ["docs", "readme", "reference"], "Index local docs relevant to the task without reading all docs.", "doc pointers"),
    ("config-drift-check", "Config drift check", "skill", ["config", "drift", "environment"], "Compare related config files for inconsistencies.", "drift findings"),
    ("token-budget-gate", "Token budget gate", "skill", ["token", "budget", "scope"], "Stop context growth by choosing the next smallest useful read.", "budget decision"),
    ("manifest-health-check", "Manifest health check", "skill", ["manifest", "health", "metadata"], "Check manifests and metadata before reading implementation files.", "manifest health notes"),
    ("dependency-graph-pruner", "Dependency graph pruner", "skill", ["graph", "import", "dependency"], "Identify the smallest dependency subgraph relevant to the task.", "dependency subgraph"),
    ("secret-placeholder-scan", "Secret placeholder scan", "skill", ["secret", "env", "placeholder"], "Find secret placeholders and env expectations without exposing values.", "secret placeholder map"),
    ("local-api-surface-map", "Local API surface map", "skill", ["api surface", "export", "public"], "Map public functions, routes, and exports before editing.", "API surface map"),
    ("route-map", "Route map", "skill", ["route", "page", "endpoint"], "List app routes, pages, and endpoints from local files.", "route inventory"),
    ("type-surface-index", "Type surface index", "skill", ["type", "schema", "interface"], "Index important types, schemas, and interfaces.", "type surface notes"),
    ("test-fixture-inventory", "Test fixture inventory", "skill", ["fixture", "mock", "sample"], "Find fixtures and mocks that can validate the change cheaply.", "fixture inventory"),
    ("asset-size-inventory", "Asset size inventory", "skill", ["asset", "bundle", "size"], "List large assets and bundle candidates before optimization.", "asset size notes"),
    ("permission-scope-inventory", "Permission scope inventory", "skill", ["permission", "scope", "role"], "Map permissions, roles, and scopes locally before security-sensitive work.", "permission scope notes"),
    ("stale-artifact-cleanup-plan", "Stale artifact cleanup plan", "skill", ["stale", "cache", "artifact"], "Identify generated caches, backups, and stale artifacts without deleting them.", "cleanup candidate list"),
    ("selector-preflight-index", "Selector preflight index", "skill", ["selector", "index", "latency", "ranking"], "Build normalized task, file, and domain hints before expensive scoring or reads.", "selector preflight index"),
    ("duplicate-capability-filter", "Duplicate capability filter", "skill", ["duplicate", "overlap", "dedupe", "similar"], "Detect overlapping capability candidates before loading repeated instructions.", "dedupe notes"),
    ("schema-contract-lint", "Schema and contract lint", "skill", ["schema", "contract", "lint", "validation"], "Check local schemas, manifests, and contracts for cheap inconsistencies.", "schema contract findings"),
    ("failure-mode-checklist", "Failure mode checklist", "skill", ["failure mode", "edge case", "risk", "checklist"], "List likely edge cases and failure modes before choosing heavier review.", "failure checklist"),
    ("changelog-impact-scan", "Changelog impact scan", "skill", ["changelog", "release notes", "impact", "version"], "Scan local changelog and version markers for compatibility implications.", "impact notes"),
    ("provenance-license-inventory", "Provenance and license inventory", "skill", ["provenance", "license", "source", "copy"], "Record source and license signals before adapting external code or assets.", "provenance inventory"),
    ("minimal-repro-captor", "Minimal repro captor", "skill", ["repro", "error", "log", "failure"], "Capture the smallest local reproduction path before debugging or changing behavior.", "minimal repro notes"),
    ("observability-signal-map", "Observability signal map", "skill", ["logs", "metrics", "traces", "observability"], "Map available logs, metrics, traces, and diagnostics before deeper analysis.", "observability signal map"),
    ("data-classification-map", "Data classification map", "skill", ["pii", "data", "privacy", "classification"], "Identify sensitive data classes and boundaries before using tools or logs.", "data classification notes"),
    ("cache-key-inventory", "Cache key inventory", "skill", ["cache", "key", "invalidation", "ttl"], "List cache keys, invalidation paths, and TTL hints before changing cached behavior.", "cache key inventory"),
]

GROUP_2 = [
    ("focused-official-docs-check", "Focused official docs check", "skill", ["official docs", "api", "version"], "Check current official documentation only for the specific moving part.", "docs-backed decision"),
    ("github-pattern-comparison", "GitHub pattern comparison", "skill", ["github", "open source", "pattern"], "Compare active repositories and reuse patterns without copying code.", "GitHub research summary"),
    ("implementation-slice-plan", "Implementation slice plan", "skill", ["plan", "implementation", "slice"], "Plan the smallest production-ready implementation slice.", "scoped implementation plan"),
    ("contract-and-interface-review", "Contract and interface review", "skill", ["contract", "interface", "api"], "Review interfaces, types, schemas, and edge cases.", "contract risk notes"),
    ("validation-matrix", "Validation matrix", "skill", ["validation", "matrix", "quality"], "Define tests, manual checks, and build gates matching risk.", "validation matrix"),
    ("design-decision-record", "Design decision record", "agent", ["decision", "tradeoff", "adr"], "Capture options and tradeoffs when multiple valid approaches exist.", "short ADR"),
    ("focused-debugger", "Focused debugger", "agent", ["debug", "root cause", "failure"], "Reproduce and isolate a domain-specific bug before fixing it.", "root-cause summary"),
    ("reviewer-pass", "Reviewer pass", "agent", ["review", "audit", "risk"], "Run a second-pass review for bugs, maintainability, and missing tests.", "review findings"),
    ("migration-checklist", "Migration checklist", "skill", ["migration", "upgrade", "compatibility"], "Prepare compatibility and rollback checks for a bounded migration.", "migration checklist"),
    ("docs-and-handoff", "Docs and handoff", "skill", ["handoff", "readme", "docs"], "Update only the docs needed to make the change maintainable.", "handoff notes"),
    ("risk-based-test-plan", "Risk-based test plan", "skill", ["risk", "test plan", "coverage"], "Choose tests by failure impact and changed surface area.", "risk-based test plan"),
    ("data-flow-review", "Data flow review", "skill", ["data flow", "input", "output"], "Trace data movement across boundaries and identify validation points.", "data-flow notes"),
    ("threat-model-lite", "Threat model lite", "skill", ["threat model", "abuse", "security"], "Run a bounded STRIDE-style review for the changed surface.", "lite threat model"),
    ("ux-copy-state-review", "UX copy and state review", "skill", ["copy", "empty state", "error state"], "Check microcopy, empty states, errors, loading, and disabled states.", "UX state notes"),
    ("performance-budget-plan", "Performance budget plan", "skill", ["performance budget", "latency", "size"], "Set practical performance budgets and validation commands.", "performance budget"),
    ("accessibility-checklist-pass", "Accessibility checklist pass", "skill", ["accessibility", "keyboard", "contrast"], "Apply a focused accessibility checklist to the selected UI surface.", "accessibility notes"),
    ("release-gate-plan", "Release gate plan", "skill", ["release gate", "ship", "quality"], "Define the minimum ship gate for the task risk.", "release gate checklist"),
    ("dependency-choice-review", "Dependency choice review", "skill", ["dependency choice", "library", "sdk"], "Review whether adding or upgrading a dependency is justified.", "dependency decision"),
    ("integration-contract-plan", "Integration contract plan", "skill", ["integration contract", "webhook", "sdk"], "Define request, response, retries, idempotency, and failure contracts.", "integration contract plan"),
    ("rollback-observability-plan", "Rollback observability plan", "skill", ["rollback", "observability", "monitor"], "Pair a change with rollback and monitoring expectations.", "rollback observability plan"),
    ("source-quality-ranking", "Source quality ranking", "skill", ["source ranking", "quality", "license", "benchmark"], "Rank candidate libraries, examples, assets, or patterns by fit, quality, license, and maintenance.", "ranked source shortlist"),
    ("benchmark-fixture-design", "Benchmark fixture design", "skill", ["benchmark", "fixture", "eval", "metric"], "Design representative fixtures and metrics that can catch selector or behavior regressions.", "benchmark fixture plan"),
    ("agent-role-boundary-review", "Agent role boundary review", "agent", ["agent", "role", "boundary", "handoff"], "Review specialist agent responsibilities so selected agents do not duplicate each other.", "agent boundary notes"),
    ("selector-roi-tuning-pass", "Selector ROI tuning pass", "skill", ["selector", "roi", "scoring", "ranking"], "Tune score terms, quotas, and ROI tie-breakers for the task while preserving compact output.", "selector tuning notes"),
    ("dependency-weight-benchmark", "Dependency weight benchmark", "skill", ["dependency", "bundle", "weight", "benchmark"], "Compare dependency cost, bundle size, maintenance, and replacement options before adopting a package.", "dependency benchmark"),
    ("error-handling-resilience-review", "Error handling resilience review", "skill", ["error handling", "resilience", "retry", "fallback"], "Review failures, retries, fallback behavior, and user-visible recovery.", "resilience findings"),
    ("accessibility-performance-crosscheck", "Accessibility and performance crosscheck", "skill", ["accessibility", "performance", "core web vitals", "keyboard"], "Check accessibility and performance together where improving one can harm the other.", "a11y performance notes"),
    ("security-abuse-case-review", "Security abuse-case review", "agent", ["abuse case", "security", "misuse", "threat"], "Review likely abuse cases and security boundaries for the changed surface.", "abuse-case findings"),
    ("release-risk-diff-review", "Release risk diff review", "skill", ["release", "diff", "risk", "regression"], "Compare intended changes against release risk, rollback, and regression surfaces.", "release risk notes"),
    ("migration-compatibility-probe", "Migration compatibility probe", "skill", ["migration", "compatibility", "version", "deprecation"], "Probe compatibility, deprecated APIs, and transitional states before a migration.", "compatibility findings"),
]

GROUP_3 = [
    ("deep-research-benchmark", "Deep research benchmark", "agent", ["deep research", "benchmark", "landscape"], "Run broad research across current repos, docs, and market patterns.", "ranked benchmark report"),
    ("multi-agent-red-team", "Multi-agent red-team", "agent", ["red team", "security", "failure"], "Use independent review passes for high-risk failure modes.", "red-team findings"),
    ("full-system-audit", "Full system audit", "agent", ["full audit", "end to end", "production"], "Audit the entire domain surface before launch or major change.", "full audit report"),
    ("migration-simulation", "Migration simulation", "agent", ["simulation", "rollback", "migration"], "Simulate migration, rollback, and failure scenarios.", "simulation report"),
    ("stakeholder-scenario-synthesis", "Stakeholder scenario synthesis", "agent", ["stakeholder", "scenario", "strategy"], "Synthesize competing user, business, compliance, and engineering scenarios.", "scenario decision brief"),
    ("adversarial-security-review", "Adversarial security review", "agent", ["adversarial", "abuse", "exploit"], "Run a deep adversarial review of security, abuse, and prompt-injection paths.", "adversarial review"),
    ("end-to-end-launch-review", "End-to-end launch review", "agent", ["launch", "go live", "readiness"], "Review readiness across product, engineering, support, analytics, and rollback.", "launch readiness report"),
    ("large-scale-refactor-plan", "Large-scale refactor plan", "agent", ["large refactor", "incremental migration", "compatibility"], "Plan a multi-step refactor with compatibility and verification strategy.", "refactor execution plan"),
    ("market-competitor-deep-dive", "Market competitor deep dive", "agent", ["market", "competitor", "positioning"], "Do deep current research across competitors, examples, and best practices.", "competitive deep dive"),
    ("resilience-chaos-planning", "Resilience chaos planning", "agent", ["resilience", "chaos", "failure injection"], "Plan high-impact failure, chaos, and recovery validation scenarios.", "resilience plan"),
    ("frontier-solution-landscape", "Frontier solution landscape", "agent", ["frontier", "best practice", "landscape", "state of the art"], "Research current best-in-class approaches across active repos, official docs, and expert examples.", "frontier landscape report"),
    ("independent-specialist-panel", "Independent specialist panel", "agent", ["specialist", "panel", "multi agent", "expert review"], "Run multiple independent specialist perspectives and merge only non-overlapping recommendations.", "specialist panel findings"),
    ("adversarial-eval-suite-design", "Adversarial eval suite design", "agent", ["adversarial", "eval", "benchmark", "regression"], "Design a high-signal adversarial evaluation suite for risky workflows or agent behavior.", "adversarial eval plan"),
    ("production-readiness-war-room", "Production readiness war room", "agent", ["production readiness", "incident", "launch", "rollback"], "Coordinate launch, incident, rollback, observability, support, and ownership checks for high-stakes work.", "production readiness brief"),
    ("architecture-evolution-roadmap", "Architecture evolution roadmap", "agent", ["architecture", "roadmap", "evolution", "strategy"], "Plan a staged architecture evolution across constraints, migrations, owners, and validation gates.", "architecture roadmap"),
]


GROUP_LABELS = {
    1: "token-saving",
    2: "balanced-value",
    3: "heavyweight-result",
}


def make_record(domain: tuple[str, str, list[str], list[str]], template: tuple[str, str, str, list[str], str, str], group: int) -> dict:
    domain_id, domain_title, domain_terms, file_signals = domain
    slug, capability_title, kind, template_terms, use_when, output = template
    record_id = f"{domain_id}.{slug}"
    title = f"{domain_title}: {capability_title}"
    if group == 1:
        activation = "Prefer deterministic local scan or script before reading long files."
        cost_rule = "Default on when matched; saves or avoids context."
    elif group == 2:
        activation = "Load focused instructions or run one bounded specialist pass."
        cost_rule = "Use when expected quality gain matches the added context."
    else:
        activation = "Use only for high-risk, high-value, or explicitly deep work."
        cost_rule = "Require concrete output and summarize aggressively."

    return {
        "id": record_id,
        "name": record_id.replace(".", "-"),
        "kind": kind,
        "group": group,
        "group_label": GROUP_LABELS[group],
        "domain_id": domain_id,
        "domain": domain_title,
        "capability_slug": slug,
        "title": title,
        "description": f"{kind.title()} capability for {domain_title.lower()} that provides {capability_title.lower()} with a {GROUP_LABELS[group]} token profile.",
        "use_when": f"{use_when} Apply only when the task or files clearly involve {domain_title.lower()}.",
        "avoid_when": "Avoid when another selected record covers the same capability slug more directly for the matched domain, or when the task is a trivial one-line edit.",
        "selection_terms": sorted(set(domain_terms + template_terms + domain_id.replace("-", " ").split() + slug.replace("-", " ").split())),
        "file_signals": file_signals,
        "expected_output": output,
        "activation": activation,
        "cost_rule": cost_rule,
        "non_overlap_boundary": f"Bounded to {domain_title.lower()} and capability slug '{slug}'. Do not select another '{slug}' record unless it scores higher for the project.",
    }


def build_catalog() -> list[dict]:
    records: list[dict] = []
    for domain in DOMAINS:
        for template in GROUP_1:
            records.append(make_record(domain, template, 1))
        for template in GROUP_2:
            records.append(make_record(domain, template, 2))
        for template in GROUP_3:
            records.append(make_record(domain, template, 3))
    return records


def write_summary(catalog: list[dict], output_path: Path) -> None:
    by_domain: dict[str, list[dict]] = {}
    by_group: dict[int, int] = {1: 0, 2: 0, 3: 0}
    by_kind: dict[str, int] = {}
    for record in catalog:
        by_domain.setdefault(record["domain_id"], []).append(record)
        by_group[record["group"]] += 1
        by_kind[record["kind"]] = by_kind.get(record["kind"], 0) + 1

    lines = [
        "# Quality Cost Skill Kernel Summary",
        "",
        f"Total records: {len(catalog)}",
        f"Group 1 token-saving: {by_group[1]}",
        f"Group 2 balanced-value: {by_group[2]}",
        f"Group 3 heavyweight-result: {by_group[3]}",
        f"Skill records: {by_kind.get('skill', 0)}",
        f"Agent records: {by_kind.get('agent', 0)}",
        "",
        "## Domains",
        "",
        "| Domain | Records | Group 1 | Group 2 | Group 3 |",
        "|---|---:|---:|---:|---:|",
    ]
    for domain_id in sorted(by_domain):
        items = by_domain[domain_id]
        g1 = sum(1 for item in items if item["group"] == 1)
        g2 = sum(1 for item in items if item["group"] == 2)
        g3 = sum(1 for item in items if item["group"] == 3)
        lines.append(f"| {domain_id} | {len(items)} | {g1} | {g2} | {g3} |")
    lines.append("")
    output_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    default_root = Path(__file__).resolve().parents[1]
    parser.add_argument("--output", default=str(default_root / "references" / "core-3000-capabilities.json"))
    parser.add_argument("--summary", default=str(default_root / "references" / "core-3000-capabilities-summary.md"))
    args = parser.parse_args()

    catalog = build_catalog()
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    write_summary(catalog, Path(args.summary))
    print(f"records: {len(catalog)}")
    print(f"output: {output}")
    print(f"summary: {args.summary}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
