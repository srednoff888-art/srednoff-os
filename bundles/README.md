# Srednoff OS Bundles

Bundles are compact metadata presets for a domain of work. They do not install
tools, enable agents, or bypass the selector. A bundle only tells Srednoff OS
which domains, policy gates, skills, and validation checks are usually relevant.

## Safety Contract

- `default_enabled` must stay `false`.
- Bundles are selected by task intent, profile, or explicit user request.
- Regulated, paid, externally visible, personal-data, or production actions
  still require human confirmation.
- Bundles should reference existing policies and skills instead of duplicating
  long instructions.

## Current RU Bundles

| Bundle | Scope |
|---|---|
| `ru-seo` | Russian-market technical SEO, indexation, local/entity pages, content briefs |
| `ru-marketplaces` | Marketplace listings, ads, claims, reviews, and compliance gates |
| `ru-enterprise` | B2B, CRM, document workflows, privacy, and integration risk |
| `ru-1c` | 1C-adjacent development, review, integration, and deployment planning |
| `ru-llm` | Russian LLM providers, agent imports, RAG, prompt/security review |
| `ru-content` | Russian content, localization, editorial SEO, and claims review |
| `ru-payments` | Payment, billing, refunds, fiscal/document risk review |
| `ru-messaging` | Messaging, notifications, customer communication, externally visible sends |
| `ru-devops` | Russian-market deployment, data residency, observability, rollback |

