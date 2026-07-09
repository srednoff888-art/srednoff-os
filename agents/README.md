# Srednoff OS Agent Profiles

Agent profiles are compact specialist lenses for Codex. They are not autonomous
workers, plugins, MCP servers, or installed tools. Srednoff OS may use them as
selection metadata when a task matches their domain.

## Safety Contract

- `default_enabled` is `false`.
- Profiles do not execute code or call external services.
- Profiles do not override Srednoff OS policies, hooks, or user confirmation.
- RU profiles must reference existing RU bundles and policy gates.
- Regulated, paid, production, externally visible, or personal-data actions
  still require explicit human confirmation.

