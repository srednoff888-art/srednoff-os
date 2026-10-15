---
name: api-interface-design
description: "Design or revise an HTTP/API contract, including errors, validation, pagination, retries, and backward compatibility."
---

# API Interface Design
Start from callers and ownership boundaries. Record request/response schemas and expected error semantics.
## Decisions
- Specify identifiers, nullability, authorization/tenant scope, pagination ordering, idempotency, timeout, and retry policy.
- Use machine-readable schemas where the stack supports them. Preserve large integer identifiers without precision loss.
- Version breaking changes or provide a migration path; do not silently reinterpret existing fields.
## Acceptance
Test valid and invalid input, auth failures, empty pages, duplicate retries, and old-client behavior. Confirm implementation matches the documented schema.
