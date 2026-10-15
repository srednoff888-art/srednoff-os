---
name: property-based-testing
description: "Add property-based tests when a domain has meaningful invariants or many input combinations beyond a finite example table."
---

# Property Based Testing
Express a domain invariant independently of the implementation before writing generators.
## Decisions
- Generate valid and deliberately invalid inputs; preserve domain constraints instead of filtering nearly everything.
- Use round-trip, conservation, monotonicity, ordering, or reference-model properties where justified.
- Keep failure seeds and minimized examples for regression reproduction.
## Acceptance
Show that a known faulty implementation or mutation fails the property. Report execution budget, seed, smallest failing input, and any untested domain.
