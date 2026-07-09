# Security

Srednoff OS security is a guardrail layer, not a replacement for platform permissions, sandboxing, secret management, or human approval.

## Hook Posture

| Hook | Purpose | Default effect |
|---|---|---|
| `SessionStart` | Startup status and loaded notification | Report status |
| `UserPromptSubmit` | Prompt preflight | Block high-confidence secrets |
| `PreToolUse` | Tool/action preflight | Block destructive or secret-leaking actions; ask on externally visible or bypass-prone actions |

The public hook example lives in `hooks.example.json`. The local installed hook config belongs under `$HOME/.codex` and must not be committed.

## Decisions

| Decision | Meaning |
|---|---|
| `allow` | Low-risk or read-only action can continue |
| `ask` | Human confirmation is required before continuing |
| `block` | Action is denied because the risk is too high |

High-confidence secrets and destructive filesystem actions are blocked earlier. Publish, deploy, bypass, production, payment, DNS, and account-changing actions require explicit confirmation.

## Redacted Audit Trail

The hook ledger records metadata and hashes, not raw prompts or raw tool payloads. This avoids turning safety logs into a second leak surface.

## Provenance Gates

External source intake uses conservative rules:

- no copied prompt leaks;
- no license-unclear code import;
- no unreviewed MCP/CLI execution;
- no external package or tool install without confirmation;
- no source is trusted only because it appears in a catalog.

## Private Boundary

The public repo must not contain:

- `.env` files;
- tokens, cookies, private keys, connector state;
- private client data;
- machine-specific credentials;
- private local hook state.

Public profile examples are allowed only when sanitized. Personal overlays should live locally.

## Residual Risk

Srednoff OS reduces common mistakes, but it cannot prove that every model action is safe. Treat it as a tested workflow layer with explicit blind spots, not as a formal security boundary.

