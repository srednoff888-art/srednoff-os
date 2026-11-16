---
name: dependency-reachability-triage
description: "Distinguish resolved vulnerable dependencies from reachable exploitable behavior in the deployed artifact."
---

# Dependency Reachability Triage

## Decisions And Evidence

1. Pin advisory time, lockfile version, runtime inclusion, entrypoint and attacker-controlled input.
2. Return affected/unaffected/unknown with a call path and a regression or mitigation test; scanner absence is not proof of safety.

## Boundary

Do not execute untrusted dependency scripts or upload private source to a scanner without authorization.

## Source

[Current primary reference](https://google.github.io/osv-scanner/). Check the installed version and current contract before execution.
