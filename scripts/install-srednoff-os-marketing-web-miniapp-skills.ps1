param(
    [string]$SkillsRoot = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path -LiteralPath (Join-Path $ScriptDir "..")).Path
if (-not $SkillsRoot) {
    $SkillsRoot = Join-Path $PackageRoot ".codex\skills"
}

$PpcSource = "https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis"
$SeoSource = "https://developers.google.com/search/docs | https://schema.org/docs/gs.html"
$WebSource = "https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/"
$TelegramSource = "https://core.telegram.org/bots/webapps | https://core.telegram.org/bots/api"

$Definitions = @(
    @{ name="yandex-direct-account-audit"; category="PPC"; source=$PpcSource; focus="audit Yandex Direct account structure, spend, delivery, conversion evidence, and safe optimization backlog" },
    @{ name="yandex-direct-campaign-architecture"; category="PPC"; source=$PpcSource; focus="design Yandex Direct campaign, ad group, geo, audience, and naming architecture before build" },
    @{ name="yandex-direct-query-negative-mining"; category="PPC"; source=$PpcSource; focus="analyze Yandex search queries, negatives, match intent, and preserve valuable traffic" },
    @{ name="yandex-direct-bid-strategy-review"; category="PPC"; source=$PpcSource; focus="review Yandex Direct bidding, learning constraints, conversion volume, and guardrails before bid changes" },
    @{ name="yandex-direct-goal-attribution"; category="PPC"; source=$PpcSource; focus="validate Yandex Metrica goals, attribution, offline conversion evidence, and reporting joins" },
    @{ name="yandex-direct-feed-campaigns"; category="PPC"; source=$PpcSource; focus="validate feeds, offer data, policy risk, and measurement for Yandex ecommerce campaigns" },
    @{ name="yandex-direct-policy-risk-gate"; category="PPC"; source=$PpcSource; focus="check Yandex Direct policy, landing, claims, legal, and moderation risk before publication" },
    @{ name="meta-ads-account-audit"; category="PPC"; source=$PpcSource; focus="audit Meta Ads account structure, delivery, learning, attribution, creative, audience, and spend evidence" },
    @{ name="meta-ads-capi-deduplication"; category="PPC"; source=$PpcSource; focus="design or review Meta Pixel and Conversions API event identity, deduplication, consent, and diagnostics" },
    @{ name="meta-ads-creative-fatigue"; category="PPC"; source=$PpcSource; focus="detect Meta creative fatigue, saturation, audience overlap, and a measurable refresh plan" },
    @{ name="meta-ads-audience-experiment"; category="PPC"; source=$PpcSource; focus="design Meta audience, placement, optimization-event, and creative experiments without confounded comparisons" },
    @{ name="meta-ads-catalog-dpa"; category="PPC"; source=$PpcSource; focus="validate Meta catalog, feed, event, availability, and dynamic product ad readiness" },
    @{ name="meta-ads-policy-risk-gate"; category="PPC"; source=$PpcSource; focus="check Meta policy, restricted content, personal-attribute language, landing, and account-risk signals" },
    @{ name="google-ads-conversion-quality"; category="PPC"; source=$PpcSource; focus="validate Google Ads conversion actions, enhanced conversions, consent, values, deduplication, and import quality" },
    @{ name="google-ads-search-query-hygiene"; category="PPC"; source=$PpcSource; focus="analyze Google Ads search terms, negatives, match behavior, and query-to-landing relevance" },
    @{ name="google-ads-pmax-experiment"; category="PPC"; source=$PpcSource; focus="plan Google Performance Max experiments with asset, feed, goal, brand-safety, and incrementality controls" },
    @{ name="google-ads-shopping-feed-health"; category="PPC"; source=$PpcSource; focus="review Shopping feed quality, product eligibility, price availability, taxonomy, and landing alignment" },
    @{ name="google-ads-policy-risk-gate"; category="PPC"; source=$PpcSource; focus="check Google Ads policy, API constraints, landing experience, and approval risk before changes" },
    @{ name="paid-media-attribution-governance"; category="PPC"; source=$PpcSource; focus="define cross-channel attribution, naming, UTMs, conversion ownership, consent, and reconciliation rules" },
    @{ name="paid-media-budget-pacing"; category="PPC"; source=$PpcSource; focus="analyze paid-media budget pacing, caps, marginal efficiency, and safe reallocation proposals" },
    @{ name="paid-media-experiment-design"; category="PPC"; source=$PpcSource; focus="design paid-media tests with hypotheses, holdouts, success criteria, duration, and stopping rules" },
    @{ name="search-console-performance-triage"; category="SEO"; source=$SeoSource; focus="triage Search Console impressions, clicks, queries, pages, device, country, and anomaly evidence" },
    @{ name="seo-structured-data-validation"; category="SEO"; source=$SeoSource; focus="implement and validate structured data against visible content, schema rules, and rich-result risk" },
    @{ name="seo-internal-linking-architecture"; category="SEO"; source=$SeoSource; focus="design internal linking, hubs, anchors, crawl paths, and equity flow without manipulative patterns" },
    @{ name="seo-log-file-crawl-analysis"; category="SEO"; source=$SeoSource; focus="analyze crawler logs for crawl waste, status patterns, bot access, rendering, and indexability evidence" },
    @{ name="seo-ecommerce-product-feed"; category="SEO"; source=$SeoSource; focus="review ecommerce product data, variants, availability, canonicals, structured data, and feed parity" },
    @{ name="seo-digital-pr-link-risk"; category="SEO"; source=$SeoSource; focus="assess digital PR and link acquisition for relevance, disclosure, spam risk, and durable brand value" },
    @{ name="seo-content-authorship-e-e-a-t"; category="SEO"; source=$SeoSource; focus="improve content ownership, author evidence, firsthand experience, citations, and trust signals" },
    @{ name="seo-image-media-pipeline"; category="SEO"; source=$SeoSource; focus="optimize images and media for relevance, accessibility, performance, indexing, and rights provenance" },
    @{ name="seo-cwv-rum-observability"; category="SEO"; source=$SeoSource; focus="connect Core Web Vitals lab data, RUM, releases, templates, and SEO impact triage" },
    @{ name="seo-search-intent-clustering"; category="SEO"; source=$SeoSource; focus="cluster keywords by intent, entity, funnel, SERP shape, and page ownership without cannibalization" },
    @{ name="seo-change-impact-monitoring"; category="SEO"; source=$SeoSource; focus="measure SEO release impact with pre/post baselines, annotations, crawl checks, and rollback criteria" },
    @{ name="site-platform-architecture"; category="Site Building"; source=$WebSource; focus="choose site architecture, rendering, hosting, CMS, integrations, and performance boundaries from product evidence" },
    @{ name="site-content-model-cms"; category="Site Building"; source=$WebSource; focus="design content types, editorial workflows, previews, localization, permissions, and migration-safe CMS models" },
    @{ name="site-design-system-delivery"; category="Site Building"; source=$WebSource; focus="turn design tokens and components into an accessible, reusable site delivery system" },
    @{ name="site-accessibility-performance-launch"; category="Site Building"; source=$WebSource; focus="ship website accessibility, performance, responsive, SEO fallback, and browser QA as one release gate" },
    @{ name="site-forms-lead-capture"; category="Site Building"; source=$WebSource; focus="design lead forms, validation, consent, spam prevention, CRM handoff, analytics, and recovery states" },
    @{ name="site-i18n-localization-delivery"; category="Site Building"; source=$WebSource; focus="implement site localization, locale routing, copy expansion, metadata, formatting, and visual QA" },
    @{ name="site-commerce-conversion-architecture"; category="Site Building"; source=$WebSource; focus="design ecommerce discovery, product, cart, checkout, trust, tracking, and recovery flows" },
    @{ name="site-production-launch-gate"; category="Site Building"; source=$WebSource; focus="run site launch readiness across environment, redirects, analytics, forms, error monitoring, rollback, and ownership" },
    @{ name="site-analytics-consent-instrumentation"; category="Site Building"; source=$WebSource; focus="implement consent-aware analytics events, data layer, attribution, QA, and privacy-safe observability" },
    @{ name="site-api-integration-boundaries"; category="Site Building"; source=$WebSource; focus="design resilient site API integration boundaries, failure states, caching, secrets, and contract tests" },
    @{ name="site-editorial-governance"; category="Site Building"; source=$WebSource; focus="define editorial ownership, content quality gates, publishing roles, review, and archive rules" },
    @{ name="telegram-bot-solution-architecture"; category="Telegram"; source=$TelegramSource; focus="choose Telegram bot, webhook, queue, storage, admin, and observability architecture" },
    @{ name="telegram-bot-api-reliability"; category="Telegram"; source=$TelegramSource; focus="implement Telegram Bot API retries, idempotency, update handling, rate limits, errors, and safe logging" },
    @{ name="telegram-mini-app-product-brief"; category="Telegram"; source=$TelegramSource; focus="define Telegram Mini App user job, launch surface, platform constraints, trust, and success metrics" },
    @{ name="telegram-mini-app-init-data-authentication"; category="Telegram"; source=$TelegramSource; focus="validate Telegram Mini App initData on the server, enforce expiry, map identity, and create safe sessions" },
    @{ name="telegram-mini-app-platform-ui"; category="Telegram"; source=$TelegramSource; focus="build Telegram-native Mini App UI with theme, safe areas, viewport, back button, haptics, and accessibility" },
    @{ name="telegram-mini-app-backend-contract"; category="Telegram"; source=$TelegramSource; focus="design Mini App backend contracts, authorization, idempotency, error states, and bot integration boundaries" },
    @{ name="telegram-mini-app-analytics-attribution"; category="Telegram"; source=$TelegramSource; focus="instrument Mini App acquisition, start parameters, funnel events, consent, attribution, and privacy-safe reporting" },
    @{ name="telegram-mini-app-payments-policy"; category="Telegram"; source=$TelegramSource; focus="review Mini App payments, digital-goods constraints, receipts, refunds, policy, and approval gates" },
    @{ name="telegram-mini-app-performance-budget"; category="Telegram"; source=$TelegramSource; focus="set Mini App mobile performance budgets for startup, JS, assets, rendering, network, and low-end devices" },
    @{ name="telegram-mini-app-release-gate"; category="Telegram"; source=$TelegramSource; focus="validate Mini App HTTPS, bot configuration, auth, UI states, analytics, security, and rollback readiness" },
    @{ name="telegram-mini-app-growth-loop"; category="Telegram"; source=$TelegramSource; focus="design Mini App activation, referral, retention, notification-consent, and re-engagement loops responsibly" }
)

function Get-Guardrails([string]$Category) {
    switch ($Category) {
        "PPC" { return @("- Start with read-only data and recommendations.", "- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.", "- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.") }
        "SEO" { return @("- Capture baselines before making recommendations that affect crawl, indexation, or traffic.", "- Do not delete pages, publish redirects, change robots, or alter canonicals without explicit approval.", "- Separate observed evidence from inferred search-impact estimates.") }
        "Telegram" { return @("- Treat initDataUnsafe and browser-provided user identity as untrusted.", "- Validate initData on the server, enforce a bounded auth_date lifetime, and never expose bot tokens.", "- Require explicit approval for payments, messages, production bot settings, or externally visible launches.") }
        default { return @("- Preserve existing design and content conventions unless the task calls for a redesign.", "- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.", "- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.") }
    }
}

function Write-Skill([hashtable]$Definition) {
    $SkillDir = Join-Path $SkillsRoot $Definition.name
    $AgentDir = Join-Path $SkillDir "agents"
    New-Item -ItemType Directory -Force -Path $AgentDir | Out-Null

    $Description = "Use for $($Definition.category) work when Codex should $($Definition.focus)."
    $Guardrails = Get-Guardrails -Category $Definition.category
    $Skill = @"
---
name: $($Definition.name)
description: $Description
---

# $($Definition.name -replace '-', ' ')

## Workflow

1. Confirm the business outcome, owner, source data, constraints, and success metric.
2. Inspect the project and available account or analytics evidence before proposing changes.
3. Use official documentation for current platform behavior and retain source provenance.
4. Produce an evidence-backed plan with assumptions, dependencies, and measurable validation.
5. Run only read-only diagnostics by default; gate external, paid, production, or publishing actions behind explicit approval.

## Domain Focus

$($Definition.focus).

## Official Sources

$($Definition.source)

## Guardrails

$($Guardrails -join "`n")
"@
    $Yaml = @"
interface:
  display_name: "$($Definition.name -replace '-', ' ')"
  short_description: "$($Definition.category) specialist workflow"
  default_prompt: "Use `$$($Definition.name) to complete this task with evidence and safety gates."

policy:
  allow_implicit_invocation: true
"@
    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $SkillDir "SKILL.md"), $Skill, $Utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $AgentDir "openai.yaml"), $Yaml, $Utf8NoBom)
}

New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null
foreach ($Definition in $Definitions) {
    Write-Skill -Definition $Definition
}

Write-Output "Installed $($Definitions.Count) marketing, SEO, site-building, and Telegram Mini Apps skills into $SkillsRoot"
