---
name: skill-catalog-orchestrator
description: "Select, audit, and deploy a bounded set of relevant skills for a project without loading the complete capability library."
---

# Skill Catalog Orchestrator
Use the library as an indexed discovery surface. Installed metadata consumes context even when skill bodies are loaded on demand.
## Decisions
- Run the quality/cost selector for the actual task. Prefer exact workflow skills over broad role profiles; keep canonical alternatives mutually exclusive.
- Read the selected skill before applying it. Load supporting files only when they resolve a task-specific question.
- Audit the library with scripts/skill_catalog.py audit; separate structural findings from behavioral model evidence.
- Generate a project profile with scripts/skill_catalog.py profile --project <path> --brief <task> --max-skills 12 --install. This deploys native .agents/skills and records ownership.
- Treat the profile as a cache. Recompute when the brief, repository, or skill content changes; never let it forbid a needed capability.
## Acceptance
Check selected skill names, source fingerprints, native discovery paths, and user-modified-file conflicts. Only delegate when the user or applicable instructions authorize it; keep final worker outcomes explicit. User instructions override this skill.
