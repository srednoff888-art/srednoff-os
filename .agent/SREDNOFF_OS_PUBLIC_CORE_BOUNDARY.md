# Srednoff OS Public Core Boundary

Date: 2026-07-09

This file defines what belongs in the public Srednoff OS repository and what must stay in a local or personal profile.

## Public Core

Public core may contain:

- portable scripts that derive paths from `$HOME`, `$env:USERPROFILE`, `$env:CODEX_HOME`, the current project root, or script-relative locations;
- generic security rules, selector logic, routers, eval fixtures, skill metadata, and documentation;
- public branding intentionally shown in README and LICENSE;
- source watchlists and registries that do not include private tokens, account IDs, private URLs, or machine-only paths.

Public core must not contain:

- hardcoded local machine paths such as a personal Windows user directory;
- secrets, API keys, cookies, private keys, or auth tokens;
- local connector state, private MCP configuration, `config.toml`, `hooks.state`, or `.env` files;
- production account identifiers unless they are intentionally public and documented;
- personal preferences that change behavior for all users.

## Personal Profiles

Personal or organization-specific state belongs in local profiles, not the public core. Examples:

- Ivan-specific workflow preferences;
- agency-specific defaults;
- local trusted project roots;
- connector credentials and account-scoped configuration;
- private automation state;
- local model/provider preferences.

Until the formal `profiles/` system exists, personal state should remain under `$HOME\.codex` or another local-only path excluded from git.

## Script Rule

Scripts must resolve user-specific paths at runtime. Prefer this order:

1. explicit parameter;
2. script-relative project root;
3. `$env:CODEX_HOME`;
4. `$HOME`;
5. `$env:USERPROFILE`;
6. temporary directory for test fixtures.

Test fixtures should use generated temp paths or project-relative paths, not a maintainer's real home directory.

## Checkpoint 1 Result

Checkpoint 1 removed the public-core hardcoded personal path from the hook danger rule and the v2.1.1 hook eval fixture. The README author line remains intentional public branding.
