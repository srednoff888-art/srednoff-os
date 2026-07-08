# Checkpoint 5 Security Hook Research

Date: 2026-07-09

## Search Intent

Strengthen Srednoff OS hooks for secret leakage, destructive commands, explicit-confirmation actions, and audit logging without copying third-party hook code.

## Sources Checked

| Source | Relevance | Pattern adapted | Risk avoided |
|---|---|---|---|
| `gitleaks/gitleaks` | Mature secret scanning tool | Known-format secret rules and stdin/local scan posture | Did not copy rule files or scanner implementation |
| `Yelp/detect-secrets` | Enterprise secret baseline workflow | Baseline/audit mindset and local-first detection | Did not introduce dependency or baseline format |
| `mattpocock/skills` git guardrails | Claude Code guardrail pattern | Block dangerous git commands before tool execution | Did not copy hook text |
| `Dicklesworthstone/destructive_command_guard` | AI-agent destructive command guard | Treat filesystem/git destructive actions as pre-execution deny | Did not vendor code |
| `disler/claude-code-hooks-mastery` | Hook lifecycle/security examples | Separate prompt, tool, and lifecycle coverage | Did not import personalized/runtime behavior |
| GitHub community discussions on `--no-verify` | Hook bypass risk | Ask before bypass-prone git commands | Did not depend on external package |

## Decision

Adopt:
- deny high-confidence destructive commands;
- ask before externally visible or bypass-prone actions;
- keep audit logs hash-only, with no raw prompt/tool input.

Adapt:
- expand secret patterns only for high-confidence token formats;
- add regression fixtures for every new rule.

Avoid:
- broad keyword/entropy-only blocking that would create false positives;
- copying external rule databases;
- installing third-party scanners inside the hook path.

## Validation

Security fixtures now cover block, ask, allow, and redacted audit logging.
