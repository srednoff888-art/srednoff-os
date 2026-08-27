---
name: figma-mcp-design-system-delivery
description: Use when Figma MCP supplies approved design context, components, variables, Code Connect mappings, or an editable Figma canvas for design-system delivery. Convert intent into accessible, project-native UI without treating generated code or canvas writes as automatically approved.
---

# Figma MCP Design-System Delivery

Use the design file as a specification, not an authority that overrides the
repository's runtime, accessibility, localization, or security constraints.

## Workflow

1. Identify the approved file, frame/node, component library, variables, and
   user rights before reading design context.
2. Extract layout, states, tokens, assets, and existing Code Connect mappings.
   Resolve discrepancies against the repository's implemented components.
3. Implement or adapt components locally, preserving keyboard behavior,
   responsive constraints, contrast, reduced motion, and semantic structure.
4. Use write-to-canvas only after explicit approval; re-read the changed nodes
   and report their exact scope.

## Guardrails

- Do not export or reuse assets without confirming file and asset rights.
- Treat Figma code generation as a starting point; review dependencies, visual
  behavior, and accessible states before merging.
- Keep design-context reads separate from canvas edits and design-library writes.
