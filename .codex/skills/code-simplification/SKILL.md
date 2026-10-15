---
name: code-simplification
description: "Refactor an existing implementation to remove specific duplication or accidental complexity while preserving observable behavior."
---

# Code Simplification
Identify the maintenance problem and the behavior that must survive, including error types, ordering, serialization, side effects, and cancellation.
## Decisions
- Establish characterization coverage for risky paths before editing.
- Prefer a local simplification over a new shared abstraction unless multiple real callers share the contract.
- Keep API changes separate from behavior-preserving refactors. Retain intentional compatibility handling and data-format quirks.
## Acceptance
Review the diff against the original contract and run affected tests. State the removed complexity and any behavior change explicitly; line-count reduction alone is not a benefit.
