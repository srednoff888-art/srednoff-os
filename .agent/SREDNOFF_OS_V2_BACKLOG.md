# Srednoff OS V2 Backlog

## v2.1 Implemented

- `srednoff-os-doctor.ps1` health gate with `-RunEvals` and `-FixSafe`.
- Global `hooks.json` for `SessionStart`, `UserPromptSubmit`, and `PreToolUse`.
- Secret and high-risk tool preflight through `srednoff-os-hook.ps1`.
- Selector eval suite with 5 regression fixtures.
- Duplicate skill name cleanup for imported upstream `ai-sdk` and `chat-sdk` references.
- MCP connector trust inventory.
- Source watchlist for daily research.
- Privacy-safe observability ledger under `.codex/srednoff-os/logs/`.
- Narrowed Codex trust from `<user-home>` to `<codex-projects-root>`.
- Daily research automation now requires doctor OK before installing updates.

## Confirmed Pre-V2 Baseline

- Srednoff OS global instructions live in `$HOME\.codex\AGENTS.md`.
- New Codex sessions load global `AGENTS.md` automatically according to Codex instruction discovery.
- Project/session folders receive local Srednoff OS files through the `codex-md-os` compatibility template.
- Startup health notification is available through:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-status.ps1" -ProjectPath "<project-path>"
```

Expected healthy output:

```text
Srednoff OS loaded: OK | project=OK | skills=<count> | kernel=4500 | selector=True
```

## V2 Features Selected From Research

| Priority | Feature | Why it belongs in V2 | Source signal |
|---:|---|---|---|
| P0 | `srednoff-os-doctor` | One command to check AGENTS, template, kernel, selector, duplicate skills, npm.cmd, automations, stale cache, old sessions | Local audit gap |
| P0 | SessionStart status hook | Automatic startup notification without relying only on model discipline | Codex Hooks support `SessionStart` |
| P0 | Prompt/secret preflight hook | Block accidental secrets before tools or prompts use them | Codex Hooks examples include prompt scanning |
| P0 | Skill active/inactive tiers | Prevent skill metadata crowding and trigger noise as catalog grows | Codex skills initial list has a context budget |
| P1 | Selector eval suite | Stop heuristic regressions like wrong skill mappings | Current selector mapping audit |
| P1 | Approved capability-to-skill alias map | Make selector deterministic for core domains | Current selector mapping audit |
| P1 | Agent improvement loop | Convert traces + feedback into evals and Codex handoff | OpenAI cookbook pattern |
| P1 | Local observability ledger | Track selector choices, skills read, validations, token budget, warnings without secrets | Agent observability best practice |
| P1 | Hook trust/audit dashboard | Hooks need review/trust; V2 should show what is enabled and why | Codex hook trust model |
| P2 | Record & Replay capture process | Turn repeated manual workflows into skills faster | Codex skill workflow |
| P2 | Subagent routing policy | Use subagents only for bounded review/research/validation with clear artifact contracts | Codex/Agents SDK orchestration |
| P2 | Project trust/config audit | Verify `.codex/config.toml`, trusted project layers, and config precedence | Codex config docs |
| P2 | Skill quality scoring | Score specificity, overlap, docs freshness, validation commands, body length | Local catalog health need |
| P2 | Safe cleanup dry-run | Remove generated cache/stale artifacts only after explicit dry-run report | Local pycache/stale artifact finding |
| P2 | MCP connector trust inventory | Track installed/available MCP servers, scope, maturity, and whether they are trusted for auto-use | MCP server ecosystem research |
| P2 | Prompt/agent red-team fixtures | Add prompt-injection, secret-leak, overbroad-tool, and unsafe-autonomy regression cases | Promptfoo/eval ecosystem research |
| P2 | Source watchlist | Versioned list of official docs, GitHub repos, and curated catalogs checked by the daily automation | V2 research traceability need |

## V2 Implementation Order

1. Build `srednoff-os-doctor.ps1` with `-Json`, `-FixSafe`, and `-ProjectPath`.
2. Add optional Codex `SessionStart` hook that runs `srednoff-os-status.ps1`.
3. Add optional `UserPromptSubmit`/`PreToolUse` secret scanner hook with local redaction-only behavior.
4. Add selector eval fixtures and expected top mappings.
5. Add selector alias map and fail the eval suite on mapping drift.
6. Add skill active/inactive tiers using `agents/openai.yaml` policy where supported.
7. Add local observability ledger under `.codex/srednoff-os/logs/` with secret-safe JSONL.
8. Add daily automation step to run doctor and selector evals before installing new skills.
9. Add MCP trust inventory and source watchlist to keep daily research auditable.
10. Add prompt/agent red-team fixtures after the selector eval harness exists.

## Guardrails

- Hooks must be opt-in/trusted and must not run destructive actions.
- Logs must not include secrets, tokens, cookies, private keys, or full prompt text when sensitive.
- The full 4500-record `core-3000-capabilities.json` must stay script-only and must not be pasted into context.
- V2 should improve routing quality before adding more catalog size.
