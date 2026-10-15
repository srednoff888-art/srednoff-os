# October 2026 Skill Modernization

Verified source snapshot: 2026-10-15. Maintainer: Ivan Srednoff (Иван Среднёв), [Srednoff.agency](https://Srednoff.agency).

## Claude Comparison

Donor: [srednoff-os-for-claude](https://github.com/srednoff888-art/srednoff-os-for-claude), MIT, commit `d529213735d5ed2cf4c8cb80c4c43ce5ce788263`.

| Mechanism | Codex adaptation | Evidence |
|---|---|---|
| Capped project skill installation | Bounded native `.agents/skills` deployment, default 12 | `scripts/skill_catalog.py profile` |
| PROFILE.lock | JSON profile with content/project fingerprints | `.agent/skill-profile.json` |
| Catalog JSON drift checks | Portable index with content hashes and strict `--check` | CI freshness gate |
| Broken reference checking | Relative Markdown references checked outside code samples | Catalog tests |
| Skill lifecycle | File ownership ledger, preserve user edits, no pruning | Collision/update tests |
| Delegation disposition | Explicit task outcome contract | Existing orchestration skill |
| Python/infra tool workflows | 17 imported MIT skills with narrower triggers | `claude-port-provenance.json` |
| Claude hooks/plugin commands | Runtime-specific, not copied | Existing Codex hook contract retained |
| Main-session model routing | Advisory only; no automatic model switch | Profile declares no switching |
| Bulk external references | Not imported as vetted skills | Provenance exclusions |

The port deliberately improves the donor's name-based pruning: files are managed by recorded hashes, and user modifications produce a conflict before copying.

## Current AI Guidance

[OpenAI's current skill guidance](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) favors concise triggers, task-specific information, and progressive disclosure. [OpenAI's skill evaluation guidance](https://developers.openai.com/blog/eval-skills) separates routing from task artifacts and trace evidence. [Anthropic's authoring guidance](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) calls for tests on the actual supported models.

This release narrows 192 existing catchall descriptions, specializes 105 existing workflows, and moves the long SEO workflow behind a short entrypoint. It does not choose a user's model or assert results on untested models.

## Additional Source Decisions

| Source | License evidence | Adoption |
|---|---|---|
| [Vercel agent-skills](https://github.com/vercel-labs/agent-skills) | Individual skills declare MIT; no root LICENSE in inspected snapshot `063bee94` | Authored React composition/performance workflows; no copied code/prompts |
| [Microsoft Playwright CLI](https://github.com/microsoft/playwright-cli) | Apache-2.0 LICENSE | Authored bounded CLI workflow; no global executable installation |
| [Impeccable](https://github.com/pbakaus/impeccable) | Apache-2.0 LICENSE | Task-oriented critique and context concepts adapted into existing design skills |
| [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | MIT LICENSE | Discovery candidate; its recommendation dataset is not imported or treated as a universal design standard |
| [Google Ads MCP](https://github.com/googleads/google-ads-mcp) | Official Google repository, Apache-2.0 | Read-only query/metadata workflow; no account connection |
| [Blender MCP](https://www.blender.org/lab/mcp-server/) | Official runtime documentation | Isolated authoring/export workflow; generated Python execution requires an appropriate non-sensitive environment |
| [Blender glTF](https://docs.blender.org/manual/en/5.1/addons/import_export/scene_gltf2.html) | Official exporter documentation | Asset fidelity, material support, validation, and web-delivery criteria |
| Anthropic document skills | Per-folder licensing varies | No proprietary document skill import |

## Use

The library remains in `.codex/skills` for compatibility. Current Codex repository discovery uses [`.agents/skills`](https://learn.chatgpt.com/docs/build-skills).

```powershell
python scripts/skill_catalog.py profile --project C:\path\project --brief "Blender product configurator with React UI" --max-skills 12 --install
python scripts/skill_catalog.py audit --output .codex/srednoff-os/skill-quality-report.json --check
powershell -ExecutionPolicy Bypass -File scripts/generate-skill-index.ps1 -Check
```

The profile records complete resource hashes. It is a cache, not a prohibition on loading other necessary skills. Recompute after task, code, or library changes. Existing skills are retained on sync; only unchanged owned files may update. A conflicting user edit requires reconciliation rather than automatic replacement.

The cap applies to the newly selected profile, not to all skills already present in a user's global or project directories. Existing installations can expose additional metadata. No automatic deletion is used to conceal that distinction.

PowerShell init and sync provision the native set. Bash init accepts the brief as its second argument. The public library and private Yandex connector remain separate; no credentials or private connector bootstrap are packaged.

## Evidence Boundaries

- Structural lint proves metadata/reference integrity, not task quality.
- Selector evals inspect actual mapped records and include negative controls; echoed briefs no longer count as matches.
- Catalog/deployment tests cover portable paths, drift, full resources, ownership conflicts, and update behavior.
- No multi-model behavioral win, monetary ROI, or user satisfaction is claimed from these checks.
- Existing benchmark results retain their original date and scope. Use `agent-model-upgrade-evals` for a pinned, held-out comparison on a supported runtime.

## Deployment

For existing installations use `scripts/update_installed_library.py` with a
known previous clean public package, current clean public package, and explicit
installation home. The default is dry-run; `--apply` backs up replacements and
preserves differing local files. Personal global `AGENTS.md` is never replaced.
Review preserved conflicts: a partial update is not a claim of complete sync.

This repository distributes files and scripts; it has no hosted application or configured Pages site. Deployment for this release means publishing a commit and downloadable GitHub Release, then refreshing the local library/template and deploying a bounded native skill profile. CI must pass on the exact published commit.
