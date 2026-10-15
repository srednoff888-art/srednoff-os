---
name: seo
description: "Audit or repair technical SEO, content discoverability, structured data, and web accessibility using the bundled deterministic checks and site evidence."
  Deterministic LLM-first SEO audits for websites, blog posts, and GitHub
  repositories. Use this when the user asks to "perform SEO analysis", "run SEO
  audit", "analyze SEO", "check technical SEO", "review schema", "Core Web
  Vitals", "E-E-A-T", "hreflang", "GEO", "AEO", or GitHub repository SEO
  optimization. For full/page/repo audits, run bundled scripts for evidence and
  return prioritized, confidence-labeled fixes.
---

# SEO Workflow Router

Use the existing site, audience, search intent, evidence, and toolchain as the starting point.

## Choose the Necessary Evidence

- For crawl/indexing questions, reconcile URL status, redirects, robots, canonical targets, rendered content, and sitemap membership.
- For structured data, compare machine-readable fields with visible page facts and current search-engine requirements.
- For content/traffic diagnosis, distinguish Search Console observations from analytics, lab performance, inferred intent, and missing data.
- Use the bundled scripts only for the relevant checks. Their output is evidence for their scope, not an end-to-end ranking verdict.

## Detailed Workflow

Read [the detailed workflow](references/seo-workflow.md) when the request needs its CLI procedures, code examples, or full audit checklist. All commands in that reference are relative to the skill root, not to the reference file's directory.

## Acceptance

Deliver affected URLs/templates, source observations, reproducible commands, severity, and the next measurement window. Preserve the user's site and current stack. Confirm authorized publishing changes through readback and the affected public routes.
