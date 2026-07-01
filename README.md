# Srednoff OS

Srednoff OS is an engineering operating system for Codex. It adds startup checks, project bootstrap files, a 3000-record quality/cost capability kernel, selector scripts, review gates, UI/UX and 3D source ranking, compact design brief generation, safety hooks, and reusable skills/agent profiles.

This repository is a shareable, sanitized export. It intentionally excludes local secrets, private Codex config, hook trust state, connector API keys, runtime caches, and machine-specific MCP inventory.

## What Is Included

- `AGENTS.md`: global/project instructions for Srednoff OS v2.1.2.
- `code_review.md`: review rules.
- `.agent/`: planning, quality gate, connector, release, and task docs.
- `.codex/skills/`: reusable skills and agent metadata.
- `.codex/srednoff-os/`: version, source watchlist, design/source registry.
- `scripts/`: status, doctor, selector, sync, install, source ranking, design brief, and eval scripts.
- `evals/`: regression fixtures for selector/domain routing.
- `hooks.example.json`: portable example for Codex hooks.

## Install

PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\install-codex-md-os.ps1"
```

Bash:

```bash
./scripts/install-codex-md-os.sh
```

Then initialize a project:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\templates\codex-md-os\scripts\init-codex-project.ps1" "C:\path\to\project"
```

## Verify

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-status.ps1" -ProjectPath "C:\path\to\project"
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-doctor.ps1" -ProjectPath "C:\path\to\project" -RunEvals -FixSafe
```

Expected status:

```text
Srednoff OS v2.1.2 loaded: OK | project=OK | skills=<count> | kernel=3000 | selector=True
```

## Safety Notes

- Do not publish your real `$HOME/.codex/config.toml`, `hooks.state`, API keys, `.env` files, or MCP connector env values.
- Use `hooks.example.json` as a template and adjust paths for your machine.
- Connector setup is intentionally local. Add your own API keys through Codex or your shell environment, not through this repo.

## License

MIT. See `LICENSE`.
