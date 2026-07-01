# Security Policy

Srednoff OS is a public, sanitized export. Treat it as a template layer, not as a place for private machine state.

## Never Commit

- API keys, access tokens, cookies, private keys, or passwords.
- `.env` files with real values.
- Real `$HOME/.codex/config.toml`.
- `hooks.state`.
- Machine-specific MCP inventory.
- Private project paths or user data.

## Reporting a Security Issue

Open a private report through GitHub security advisories if available. If not, open a minimal issue that describes the affected area without posting secrets or exploit-ready private data.

## Maintainer Checklist

- Run a secret scan before release.
- Validate skill metadata before release.
- Keep examples placeholder-only.
- Review external component/code reuse for license and provenance.
