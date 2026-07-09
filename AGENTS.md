# AGENTS.md - Srednoff OS Entrypoint

You are Codex running under Srednoff OS v2.1.2, Ivan's engineering operating layer for Codex. Work in Russian when the user writes in Russian. Keep code, filenames, APIs, commands, and comments in the style of the current repository.

This file is intentionally compact. Detailed rules live in:

- `.agent/SREDNOFF_OS_OPERATING_RULES.md` - full operating rules migrated from the previous long AGENTS.md
- `.agent/SREDNOFF_OS_PUBLIC_CORE_BOUNDARY.md` - public core vs personal profile boundary
- `.agent/QUALITY_GATE.md` - validation expectations
- `.agent/GITHUB_RESEARCH.md` - GitHub research protocol
- `.agent/CONNECTORS.md` - connector use
- `docs/README.md` - public documentation index
- `code_review.md` - review stance

Read only the specific reference file needed for the current task. Do not load broad catalogs or all reference docs by default.

---

# Srednoff OS Startup Notification Rule

At the start of every new Codex session, and before substantial work in every existing project/session, verify that Srednoff OS is loaded:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-status.ps1" -ProjectPath "<project-path>"
```

Send one short commentary notification to the user:

```text
Srednoff OS v2.1.2 loaded: OK | project=OK | skills=<count> | kernel=4500 | selector=True
```

If the status is `WARN`, initialize/sync writable project folders, then re-check status:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\templates\codex-md-os\scripts\init-codex-project.ps1" "<project-path>"
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\sync-codex-skills-to-projects.ps1" -ProjectPath "<project-path>" -IncludeScripts
```

For Srednoff OS maintenance, run:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-doctor.ps1" -ProjectPath "<project-path>" -RunEvals -FixSafe
```

---

# Router And Selector Rule

Before substantial work in UI/UX, web design, 3D web design, mobile/apps, SEO/PPC/growth, programming, architecture, production, security, migration, launch, or Srednoff OS maintenance tasks, run:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-mode-router.ps1" -Brief "<task>" -Json
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-domain-router.ps1" -ProjectPath "<project-path>" -Brief "<task>" -Json
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\select-quality-cost-capabilities.ps1" -ProjectPath "<project-path>" -Brief "<task>" -Budget balanced -Max 24
```

Use `-Budget lean` for small fixes, `-Budget balanced` for normal implementation, `-Budget deep` for high-risk architecture/security/production/SEO/PPC/crypto/migration/launch work, and `-Budget turbo -Max 48` only after the user explicitly writes `TURBO`.

Do not load the full 4500-record quality/cost kernel into model context. Use the selector and open only relevant selected `SKILL.md` files.

---

# UI/UX, 3D, And Source Ranking Rule

For UI/UX, web design, 3D web design, 3D assets, component sources, design connectors, or visual redesign tasks, run the compact design brief and source ranker before choosing a library, UI kit, marketplace, connector, or asset source:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-design-brief.ps1" -ProjectPath "<project-path>" -Brief "<task>" -Json
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-source-ranker.ps1" -ProjectPath "<project-path>" -Brief "<task>" -Json
```

External component/code reuse is allowed only as copy-adapt-upgrade work: verify source, license, dependency weight, accessibility, performance, security, project fit, and visual quality before adopting it. Prefer adapting patterns over copying code when license or quality is unclear.

---

# TURBO Mode Rule

`TURBO` is activated only when the user explicitly writes `TURBO`. Synonyms like "maximum quality", "deep", or "do not save tokens" may trigger `deep`, but must not trigger `turbo` without the literal command.

When `TURBO` is active:

- run the mode router and domain router first;
- run the quality/cost selector with `-Budget turbo -Max 48` unless the task is clearly smaller;
- prefer top-source benchmarking, current GitHub/docs research, multi-agent review, visual QA, security review, and stronger validation where they produce a concrete result;
- keep all safety rules: destructive changes, paid actions, production changes, secrets, license-sensitive copying, and irreversible migrations still require explicit confirmation;
- avoid irrelevant context growth.

---

# Working Rules

- Understand the goal and definition of done before changing code.
- Inspect the repository before implementation.
- For non-trivial architecture, integrations, security, performance, UI/UX, agents, workflows, or library choices, check GitHub and official docs when the information can be stale.
- Never copy third-party code, prompts, assets, or configs without license/provenance review.
- Do not commit `.env`, secrets, tokens, cookies, private keys, private connector state, or machine-local config.
- Do not perform destructive, paid, production, account-changing, DNS/domain/payment, RLS/auth-disabling, or irreversible migration actions without explicit user confirmation.
- Keep changes minimal, tested, and aligned with existing project style.
- Add or update evals/tests for behavior-changing work.
- Update README/QUALITY/CHANGELOG when public behavior or release evidence changes.
- After each requested checkpoint, validate, commit, push, wait for GitHub Actions, then report a short status table.

---

# Global Srednoff OS Bootstrap Rule

At the start of work in any repository, check whether the project contains Srednoff OS files:

- `AGENTS.md`
- `code_review.md`
- `.agent/PLANS.md`
- `.agent/TASK_TEMPLATE.md`
- `.agent/GITHUB_RESEARCH.md`
- `.agent/CONNECTORS.md`
- `.agent/QUALITY_GATE.md`
- `.agent/USER_BRIEFING.md`
- `docs/README.md`
- `docs/architecture.md`
- `docs/security.md`
- `docs/workflows.md`
- `docs/profiles.md`
- `docs/ru-and-neuraldeep.md`
- `docs/risk-model.md`
- `docs/validation.md`
- `.codex/skills/github-research/SKILL.md`
- `.codex/skills/product-builder/SKILL.md`
- `.codex/skills/production-review/SKILL.md`

If these files are missing and the repository is writable, initialize them from `~/.codex/templates/codex-md-os`. Preserve existing files with timestamped backups before replacing.

---

# Final Response Shape

For implementation/checkpoint work, finish with:

```md
## Result

Done:
- ...

Checked:
- Command: ...
- Result: ...

GitHub/Docs checked:
- ...

Changed files:
- ...

Risks:
- ...

Next steps:
- ...
```
