# Growth, Web, And Mini Apps Skill Pack

This pack adds 54 compact, task-specific skills to Srednoff OS. It is designed
for selector-first use: the relevant `SKILL.md` is opened only after a task
brief matches a narrow capability.

## Scope

| Pack | Added | Purpose |
|---|---:|---|
| Paid media | 21 | Yandex Direct, Meta Ads, Google Ads, attribution, budget pacing, and experiments |
| SEO | 11 | Search Console, schema, links, logs, ecommerce, trust, media, CWV, and monitoring |
| Site building | 11 | Architecture, CMS, design system, forms, i18n, commerce, analytics, integrations, and launch |
| Telegram and Mini Apps | 11 | Bot architecture, Mini App auth, UI, backend, analytics, payments, performance, release, and growth |

## Skills

### Paid media

`yandex-direct-account-audit`, `yandex-direct-campaign-architecture`,
`yandex-direct-query-negative-mining`, `yandex-direct-bid-strategy-review`,
`yandex-direct-goal-attribution`, `yandex-direct-feed-campaigns`,
`yandex-direct-policy-risk-gate`, `meta-ads-account-audit`,
`meta-ads-capi-deduplication`, `meta-ads-creative-fatigue`,
`meta-ads-audience-experiment`, `meta-ads-catalog-dpa`,
`meta-ads-policy-risk-gate`, `google-ads-conversion-quality`,
`google-ads-search-query-hygiene`, `google-ads-pmax-experiment`,
`google-ads-shopping-feed-health`, `google-ads-policy-risk-gate`,
`paid-media-attribution-governance`, `paid-media-budget-pacing`, and
`paid-media-experiment-design`.

### SEO

`search-console-performance-triage`, `seo-structured-data-validation`,
`seo-internal-linking-architecture`, `seo-log-file-crawl-analysis`,
`seo-ecommerce-product-feed`, `seo-digital-pr-link-risk`,
`seo-content-authorship-e-e-a-t`, `seo-image-media-pipeline`,
`seo-cwv-rum-observability`, `seo-search-intent-clustering`, and
`seo-change-impact-monitoring`.

### Site building

`site-platform-architecture`, `site-content-model-cms`,
`site-design-system-delivery`, `site-accessibility-performance-launch`,
`site-forms-lead-capture`, `site-i18n-localization-delivery`,
`site-commerce-conversion-architecture`, `site-production-launch-gate`,
`site-analytics-consent-instrumentation`, `site-api-integration-boundaries`,
and `site-editorial-governance`.

### Telegram and Mini Apps

`telegram-bot-solution-architecture`, `telegram-bot-api-reliability`,
`telegram-mini-app-product-brief`,
`telegram-mini-app-init-data-authentication`, `telegram-mini-app-platform-ui`,
`telegram-mini-app-backend-contract`,
`telegram-mini-app-analytics-attribution`,
`telegram-mini-app-payments-policy`,
`telegram-mini-app-performance-budget`, `telegram-mini-app-release-gate`, and
`telegram-mini-app-growth-loop`.

## Research Decision

| Source | Decision | Reason |
|---|---|---|
| Yandex Direct API v5 | Adopt workflow patterns | Official API reference for campaign management, reporting, and automation |
| Google Ads API | Adopt workflow patterns | Official guidance for campaign types, reporting, auth, and API policy |
| Meta Marketing API and Conversions API | Adopt workflow patterns | Official CAPI measurement and server-event model; account writes remain approval-gated |
| Telegram Mini Apps docs and `Telegram-Mini-Apps/reactjs-template` | Adopt platform patterns | Official `initData` verification requirement plus a current OSS React/TypeScript template |
| `nowork-studio/toprank`, `inhouseseo/superseo-skills`, SiteOne Crawler | Adapt only | Useful research/audit patterns; no verbatim prompt or code import |

## Safety Boundaries

- PPC skills start read-only. Any budget, bid, campaign, audience, creative, or
  account mutation requires explicit owner approval.
- SEO skills require a baseline. They do not delete pages, publish redirects,
  or change robots/canonicals without approval.
- Telegram Mini Apps validate `initData` server-side with a bounded lifetime;
  `initDataUnsafe` is never treated as proof of identity.
- Site skills require provenance review for reused code/assets and preserve
  accessibility, privacy, analytics-consent, and rollback gates.

## Selector Coverage

The selector has direct aliases for Russian and English task language covering
Yandex Direct, Meta Ads, CAPI, Google Ads, PMax, Shopping feeds, Telegram bot,
Telegram Mini Apps, `initData`, Search Console, schema/JSON-LD, SEO logs, site
architecture, CMS, and site launch.
