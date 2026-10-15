---
name: smart-contract-security-review
description: "Use this skill for smart contract audit review, vulnerabilities, access control, reentrancy, invariants."
---

# Smart Contract Security Review

## Decisions

- Pin deployed/source versions, chain assumptions, privileged roles, storage layout, and asset flows.
- Review reentrancy, access control, arithmetic, oracle dependencies, upgradeability, and invariant failures.

## Acceptance

Run relevant tests/fuzzing and provide exploitable evidence; distinguish scoped review from formal audit.

## Constraints

- Do not deploy or upgrade contracts without explicit approval and tests.
