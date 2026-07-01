# Srednoff OS v2.1 Release

Date: 2026-06-30

## What Changed

- Added global `hooks.json` for `SessionStart`, `UserPromptSubmit`, and `PreToolUse`.
- Added `srednoff-os-hook.ps1` for startup context, secret preflight, tool safety preflight, and privacy-safe JSONL event logging.
- Added `srednoff-os-doctor.ps1` as the full health gate for Srednoff OS.
- Added selector eval fixtures and `test-srednoff-os-selector.ps1`.
- Added MCP trust inventory generation through `srednoff-os-mcp-inventory.ps1`.
- Added `srednoff-os/version.json` and `srednoff-os/source-watchlist.json`.
- Removed broad `<user-home>` trust by narrowing Codex trust to `<codex-projects-root>`.
- Removed duplicate skill names by renaming imported upstream reference skills.
- Updated init/sync scripts to propagate v2.1 scripts, evals, and Srednoff OS assets.
- Updated daily research automation to require `srednoff-os-doctor.ps1 -RunEvals -FixSafe`.

## Health Gate

Required healthy result:

```text
Srednoff OS v2.1 doctor: OK
```

## Guardrails

- Hooks block high-confidence secrets and high-risk destructive tool commands.
- Hooks do not log raw prompts or tool payloads; the ledger stores metadata and input hashes only.
- The expanded kernel remains script-only and must not be pasted into model context.
