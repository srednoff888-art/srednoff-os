# Profiles

Profiles separate public defaults from local or user-specific behavior.

## Profile Index

| Profile | Default | Purpose |
|---|---:|---|
| `public-default` | yes | Portable behavior safe for public sharing |
| `ivan` | no | Sanitized example for a personal overlay |
| `agency` | no | Agency/client workflow hints without private data |
| `ru-market` | no | Regional policy hints for Russian-market work |

Profiles are metadata. They do not override system safety rules and do not install tools.

## Public Core Boundary

Public files may contain:

- generic workflow rules;
- sanitized examples;
- disabled metadata;
- validation commands;
- public documentation.

Public files must not contain:

- private user secrets;
- client-specific data;
- local connector state;
- hardcoded private paths beyond documented examples;
- production credentials.

## Old Session Sync

Existing Codex project folders can be synchronized with:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\sync-codex-skills-to-projects.ps1" -ProjectPath "<project-path>" -IncludeScripts
```

Sync must not delete project files. If a target file exists and differs, the scripts create timestamped backups.

