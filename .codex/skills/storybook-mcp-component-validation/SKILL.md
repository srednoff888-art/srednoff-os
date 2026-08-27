---
name: storybook-mcp-component-validation
description: Use when Storybook MCP is available to inspect component stories, props, tokens, variants, accessibility states, or implementation examples. Apply it to component-library validation and design-system delivery, not as a substitute for project tests or visual review.
---

# Storybook MCP Component Validation

Use Storybook as a controlled component evidence surface. Start with inventory
and inspect existing stories before changing code or generated examples.

## Workflow

1. Discover the Storybook endpoint, version, component inventory, and relevant
   stories. Confirm whether it reflects the target branch and build.
2. Inspect all meaningful states: loading, empty, error, disabled, focus,
   overflow, responsive, localization, and dark/light themes where applicable.
3. Compare documented props/tokens with implementation, then make the smallest
   project-native change and add or update the corresponding story/test.
4. Run the repository's accessibility, visual, and unit gates; report any
   Storybook/build mismatch separately.

## Guardrails

- Do not infer production behavior from a stale or mock-only story.
- Keep network-backed, token-bearing, and write-capable stories isolated.
- Treat third-party example source as provenance-reviewed input, not copy-paste.
