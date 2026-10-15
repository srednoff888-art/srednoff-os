---
name: auth-oauth-session-architecture
description: "Implement or review an authentication/session flow involving OAuth, cookies, token refresh, account linking, or logout."
---

# Auth OAuth Session Architecture
Map trust boundaries, provider grants, redirect URIs, session storage, and tenant identity before modifying the flow.
## Decisions
- Bind OAuth state/PKCE to the initiating session; validate redirect and callback context.
- Keep tokens server-side where possible; define cookie flags, expiry, refresh races, logout, and revocation.
- Distinguish authentication from per-resource authorization. Verify tenant isolation independently.
## Acceptance
Exercise failed/cancelled login, replayed callback, expired session, refresh concurrency, logout, and unauthorized resource access. Never log tokens or weaken validation to make a test pass.
