---
name: oidc-release-provenance
description: "Review GitHub Actions OIDC identity and artifact provenance for a release workflow."
---

# Oidc Release Provenance

## Decisions And Evidence

1. Bind issuer/audience/subject trust to the intended repository, environment and protected release trigger.
2. Verify least-privilege job permissions and the artifact digest/attestation against the exact tested commit.

## Boundary

OIDC permission is not a reason to grant broad cloud roles; publishing remains approval-gated.

## Source

[Current primary reference](https://docs.github.com/en/actions/concepts/security/openid-connect). Check the installed version and current contract before execution.
