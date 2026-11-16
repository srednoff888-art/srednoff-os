---
name: design-token-drift-ci
description: "Detect drift between design-token source, generated theme outputs and consumed UI tokens."
---

# Design Token Drift Ci

## Decisions And Evidence

1. Separate changed source tokens from stale generated artifacts and invalid alias/type references.
2. Produce a deterministic diff by theme/component and verify one representative consumer; do not auto-approve a visual baseline.

## Boundary

Use the existing compiler for token generation; this workflow owns drift evidence and the CI gate.

## Source

[Current primary reference](https://www.designtokens.org/tr/2025.10/format/). Check the installed version and current contract before execution.
