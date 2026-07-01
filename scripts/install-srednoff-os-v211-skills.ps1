param(
    [string[]]$Roots = @(
        "$HOME\.codex\skills",
        "$HOME\.codex\templates\codex-md-os\.codex\skills",
        "<project-path>\.codex\skills"
    )
)

$ErrorActionPreference = "Stop"

$SkillDefinitions = @(
    @{ name="design-brief-intake-router"; category="UI/UX"; type="skill"; focus="ask precise design/product questions before UI, web design, 3D web, landing, dashboard, or app design work"; description="Use for UI/UX, web design, 3D web design, landing pages, dashboards, app screens, redesigns, and visual direction work when Codex should ask a compact product/design brief before choosing components or writing code." },
    @{ name="ui-component-source-router"; category="UI/UX"; type="skill"; focus="choose 21st.dev, shadcn registry, Magic UI, Aceternity, Origin UI, React Bits, Figma, Canva, or local components"; description="Use for UI/UX and web design tasks when Codex should decide which component marketplace, registry, design connector, or local design system to use before implementation." },
    @{ name="copy-adapt-component-pipeline"; category="UI/UX"; type="skill"; focus="copy, adapt, upgrade, and validate external UI components for the current project"; description="Use when Codex may copy or import UI code from registries, GitHub, 21st.dev, shadcn, Magic UI, Aceternity, Origin UI, React Bits, or similar sources, then adapt it to project conventions." },
    @{ name="component-provenance-license-review"; category="UI/UX"; type="skill"; focus="check source, license, attribution, dependencies, and copy risk before using external UI/component code"; description="Use before copying UI, 3D, mobile, or web component code from external sources, registries, GitHub, snippets, marketplaces, or AI-generated component libraries." },
    @{ name="design-token-compiler"; category="UI/UX"; type="skill"; focus="extract and normalize colors, typography, spacing, radii, shadows, motion, and component tokens"; description="Use for UI/UX and design-system work when Codex should convert visual direction or existing UI into reusable design tokens." },
    @{ name="visual-regression-design-gate"; category="UI/UX"; type="skill"; focus="require responsive screenshots, text overflow checks, visual consistency, and interaction-state review"; description="Use before finishing UI/UX, web design, mobile web, dashboard, landing page, or component work that changes visible interface behavior." },
    @{ name="anti-ai-slop-design-critic"; category="UI/UX"; type="agent"; focus="detect generic AI-looking design, weak hierarchy, one-note palettes, fake cards, clutter, and poor fit to domain"; description="Agent profile for critiquing UI/UX, web design, landing pages, dashboards, and visual systems for generic AI-slop, weak hierarchy, poor domain fit, and low craft." },
    @{ name="ui-art-director-agent"; category="UI/UX"; type="agent"; focus="own art direction, visual taste, brand fit, visual hierarchy, and design-system coherence"; description="Agent profile for art direction and premium UI/UX review across websites, apps, dashboards, 3D web experiences, and landing pages." },
    @{ name="component-librarian-agent"; category="UI/UX"; type="agent"; focus="find, compare, and select reusable UI components and avoid duplicate component choices"; description="Agent profile for researching and selecting UI components from local code, shadcn registry, 21st.dev, Magic UI, Aceternity, Origin UI, React Bits, Figma, Canva, and GitHub." },
    @{ name="design-qa-agent-v2"; category="UI/UX"; type="agent"; focus="validate polish, accessibility, responsiveness, states, copy fit, and visual regressions"; description="Agent profile for final UI/UX QA before shipping visible design, web design, app screens, or 3D web UI." },

    @{ name="3d-experience-brief-intake"; category="3D Web"; type="skill"; focus="classify product viewer, hero scene, configurator, AR preview, data visualization, game-like UI, or decorative 3D"; description="Use before 3D web design or Three.js work to clarify the experience type, user goal, interaction depth, performance budget, and fallback needs." },
    @{ name="three-vs-babylon-vs-model-viewer"; category="3D Web"; type="skill"; focus="choose the simplest correct 3D stack: model-viewer, React Three Fiber, Three.js, Babylon.js, WebGPU, or no 3D"; description="Use when choosing 3D web technology for product viewers, configurators, immersive heroes, AR previews, games, dashboards, or visual storytelling." },
    @{ name="r3f-scene-pattern-library"; category="3D Web"; type="skill"; focus="apply React Three Fiber scene patterns, suspense, drei helpers, controls, loaders, and state boundaries"; description="Use for React Three Fiber implementation or review involving scenes, cameras, controls, lighting, assets, Suspense, drei helpers, or React state integration." },
    @{ name="gltf-optimization-pipeline-v2"; category="3D Web"; type="skill"; focus="optimize glTF assets with compression, texture sizing, Meshopt, Draco, KTX2, and asset budgets"; description="Use when 3D web work involves glTF/GLB assets, product models, AR models, performance budgets, or asset pipeline review." },
    @{ name="3d-performance-budget-gate"; category="3D Web"; type="skill"; focus="set and validate frame time, draw calls, texture memory, shader cost, and mobile fallback"; description="Use before shipping 3D web, WebGL, WebGPU, Three.js, Babylon.js, R3F, or shader-heavy UI." },
    @{ name="3d-accessibility-fallbacks"; category="3D Web"; type="skill"; focus="provide static fallback, alt content, keyboard interaction, reduced motion, and low-power device paths"; description="Use for 3D web experiences that need accessibility, SEO-readable fallback content, keyboard support, or reduced-motion behavior." },
    @{ name="shader-and-postprocessing-review"; category="3D Web"; type="skill"; focus="review shader, postprocessing, bloom, blur, particle, and material effects for value versus cost"; description="Use for 3D web or animated UI work involving shaders, postprocessing, WebGL effects, particles, or expensive visual effects." },
    @{ name="3d-visual-screenshot-validator"; category="3D Web"; type="skill"; focus="validate canvas renders, screenshots, framing, nonblank pixels, mobile viewports, and asset loading"; description="Use before finishing Three.js, R3F, WebGL, WebGPU, model-viewer, or 3D web UI work." },
    @{ name="3d-art-director-agent"; category="3D Web"; type="agent"; focus="review lighting, camera, composition, material realism, scale, visual mood, and product readability"; description="Agent profile for art direction in 3D web design, product configurators, hero scenes, AR previews, and immersive visual interfaces." },
    @{ name="webgl-performance-agent"; category="3D Web"; type="agent"; focus="review GPU budget, profiling, draw calls, texture memory, shaders, device fallback, and runtime performance"; description="Agent profile for WebGL/WebGPU/Three.js/R3F performance review before shipping 3D web work." },
    @{ name="3d-asset-pipeline-agent"; category="3D Web"; type="agent"; focus="review 3D asset source, license, optimization, compression, naming, and delivery pipeline"; description="Agent profile for glTF/GLB/model asset pipeline review in 3D web, ecommerce, AR, and configurator projects." },

    @{ name="mobile-ux-platform-parity"; category="Mobile"; type="skill"; focus="review iOS/Android/web parity, safe areas, gestures, keyboards, navigation, and native expectations"; description="Use for mobile app UI/UX, React Native, Expo, iOS, Android, or cross-platform app screens where native platform behavior matters." },
    @{ name="expo-eas-release-gate"; category="Mobile"; type="skill"; focus="check Expo/EAS build profiles, channels, updates, app store metadata, release safety, and rollback"; description="Use before Expo or React Native app release, EAS build/update, TestFlight, Play Store, App Store, or mobile deployment work." },
    @{ name="mobile-offline-first-review"; category="Mobile"; type="skill"; focus="review offline states, sync conflicts, retries, queues, caching, storage, and recovery UX"; description="Use for mobile apps or PWAs that need offline behavior, unreliable network handling, local persistence, or sync conflict management." },
    @{ name="mobile-permissions-privacy-gate"; category="Mobile"; type="skill"; focus="review camera, location, contacts, files, notifications, tracking prompts, privacy labels, and consent"; description="Use when mobile apps request permissions, collect user data, handle privacy-sensitive flows, or need App Store/Play privacy review." },
    @{ name="mobile-crash-analytics-gate"; category="Mobile"; type="skill"; focus="check crash reporting, source maps, release tags, breadcrumbs, privacy-safe logs, and alerting"; description="Use for mobile app observability, Sentry/Firebase crash reporting, release diagnostics, and production incident readiness." },
    @{ name="mobile-asset-budget-audit"; category="Mobile"; type="skill"; focus="audit mobile bundle size, static assets, images, fonts, SVGs, videos, and startup cost"; description="Use for Expo, React Native, iOS, Android, or mobile web projects with large assets, slow startup, or app size concerns." },
    @{ name="mobile-release-reviewer-agent"; category="Mobile"; type="agent"; focus="final app release review across store readiness, privacy, crash, offline, QA, and rollback"; description="Agent profile for pre-release review of iOS, Android, Expo, React Native, and cross-platform mobile apps." },
    @{ name="mobile-performance-agent"; category="Mobile"; type="agent"; focus="review startup time, jank, memory, bundle size, list performance, navigation, and native bridge cost"; description="Agent profile for mobile performance review in Expo, React Native, iOS, Android, and hybrid apps." },

    @{ name="growth-design-message-match"; category="Growth"; type="skill"; focus="align SEO/PPC query intent, ad copy, landing page structure, proof, trust, CTA, and visual hierarchy"; description="Use for SEO/PPC/growth landing pages, ad traffic pages, conversion optimization, and message-match reviews." },
    @{ name="serp-to-page-brief-generator"; category="Growth"; type="skill"; focus="turn SERP, competitor, query, and search intent research into a page brief and content/design requirements"; description="Use for SEO, GEO, content, landing pages, programmatic SEO, and competitor SERP research that should become a concrete page plan." },
    @{ name="geo-ai-search-readiness-v2"; category="Growth"; type="skill"; focus="review AI search readiness, llms.txt, entity clarity, citations, structured content, and answer extraction"; description="Use for GEO/AEO/AI-search readiness, LLM crawler access, citation readiness, entity SEO, and answer-friendly content structure." },
    @{ name="ppc-landing-quality-score-gate"; category="Growth"; type="skill"; focus="review PPC landing relevance, load speed, trust, policy risk, CTA clarity, analytics, and conversion path"; description="Use before or during PPC landing page work for Google Ads, Meta Ads, paid search, paid social, or performance marketing campaigns." },
    @{ name="growth-experiment-backlog"; category="Growth"; type="skill"; focus="rank growth experiments by impact, confidence, effort, risk, measurement quality, and dependency cost"; description="Use for growth strategy, CRO, SEO/PPC experiments, landing page tests, funnel improvements, and prioritization." },
    @{ name="growth-design-director-agent"; category="Growth"; type="agent"; focus="bridge visual design, conversion, SEO/PPC intent, trust, proof, and measurable growth outcomes"; description="Agent profile for reviewing design decisions through conversion, SEO/PPC, funnel, and business-growth impact." },
    @{ name="paid-search-risk-agent"; category="Growth"; type="agent"; focus="review paid-search policy, budget, bidding, tracking, landing relevance, and approval gates"; description="Agent profile for PPC and paid-growth risk review before changing ads, budgets, bidding, tracking, or landing pages." },

    @{ name="language-runtime-router"; category="Programming"; type="skill"; focus="detect project languages, runtimes, package managers, frameworks, test commands, and validation surface"; description="Use at the start of programming tasks across TypeScript, JavaScript, Python, PHP, Go, Rust, Swift, Kotlin, SQL, Bash, PowerShell, and mixed repos." },
    @{ name="code-copy-provenance-review"; category="Programming"; type="skill"; focus="review copied code or snippets for source, license, security, dependency, compatibility, and test risk"; description="Use before copying or adapting code from GitHub, docs, Stack Overflow, registries, AI output, UI kits, snippets, or third-party examples." },
    @{ name="source-first-api-verifier"; category="Programming"; type="skill"; focus="check local source, installed package docs, types, and official docs before coding against memory"; description="Use when implementing with APIs, SDKs, libraries, frameworks, or project-local contracts that may differ from memory or have changed recently." },
    @{ name="cross-language-test-gate"; category="Programming"; type="skill"; focus="choose and run the right lint, typecheck, unit, integration, build, and manual validation commands by stack"; description="Use before finishing programming work in any language or framework to pick the right validation gates." },
    @{ name="dependency-minimalism-gate"; category="Programming"; type="skill"; focus="reject unnecessary dependencies, prefer existing primitives, and check package risk when adding libraries"; description="Use when code changes propose new dependencies, packages, SDKs, UI libraries, build tools, or runtime services." },
    @{ name="programming-agent-pack-selector"; category="Programming"; type="skill"; focus="select only needed programming specialists: backend, frontend, DB, security, QA, DevOps, mobile, or architecture"; description="Use for complex programming work when Codex should choose a narrow set of specialist agents without bloating context." },
    @{ name="principal-code-reviewer-agent"; category="Programming"; type="agent"; focus="final code review for bugs, security, API contracts, data loss, tests, maintainability, and release risk"; description="Agent profile for principal-level programming review before merge, release, or production handoff." },
    @{ name="language-specialist-agent"; category="Programming"; type="agent"; focus="provide a narrow language/runtime expert lens only when project evidence shows it is needed"; description="Agent profile for focused language-specific review across TypeScript, Python, PHP, Go, Rust, Swift, Kotlin, SQL, Bash, and PowerShell." },

    @{ name="turbo-mode-controller"; category="TURBO"; type="skill"; focus="activate and govern explicit TURBO mode with maximum-quality workflow and strict safety stops"; description="Use when the user explicitly enters TURBO, mode TURBO, enable TURBO, or TURBO for this task, and Codex should optimize for maximum quality without normal token-cost restraint." },
    @{ name="turbo-source-benchmark"; category="TURBO"; type="skill"; focus="compare top official docs, GitHub repos, registries, community signals, package ecosystems, and examples"; description="Use in TURBO mode when Codex should compare top current solutions before choosing architecture, UI components, 3D stack, mobile stack, SEO/PPC strategy, or programming patterns." },
    @{ name="turbo-multi-agent-review"; category="TURBO"; type="agent"; focus="run role-based critique: architect, security, UX, performance, QA, domain expert, growth, and release"; description="Agent profile for TURBO mode multi-role critique when maximum result quality is more important than token economy." },
    @{ name="turbo-validation-gate"; category="TURBO"; type="skill"; focus="require expanded validation: tests, build, screenshots, accessibility, performance, security, SEO, mobile, and review gates"; description="Use in TURBO mode before finalizing implementation, architecture, UI/UX, 3D web, mobile, SEO/PPC/growth, or programming work." }
)

function Convert-ToTitle {
    param([string]$Name)
    return (($Name -split '-') | ForEach-Object {
        if ($_ -eq "ui") { "UI" }
        elseif ($_ -eq "ux") { "UX" }
        elseif ($_ -eq "3d") { "3D" }
        elseif ($_ -eq "seo") { "SEO" }
        elseif ($_ -eq "ppc") { "PPC" }
        elseif ($_ -eq "api") { "API" }
        elseif ($_ -eq "r3f") { "R3F" }
        elseif ($_ -eq "gltf") { "glTF" }
        else { (Get-Culture).TextInfo.ToTitleCase($_) }
    }) -join " "
}

function Write-Skill {
    param(
        [string]$Root,
        [hashtable]$Def
    )

    $Name = $Def.name
    $Title = Convert-ToTitle -Name $Name
    $SkillDir = Join-Path $Root $Name
    $AgentDir = Join-Path $SkillDir "agents"
    New-Item -ItemType Directory -Force -Path $AgentDir | Out-Null

    $Workflow = @(
        "1. Restate the user outcome, target quality level, constraints, and definition of done.",
        "2. Inspect the current project before proposing code, design, sources, or dependencies.",
        "3. Use Srednoff OS mode/domain routing; if TURBO is active, compare top sources and run deeper critique.",
        "4. Prefer existing project conventions and proven sources over generic invention.",
        "5. Validate with the narrowest checks that prove the result, expanding validation for high-risk or TURBO work.",
        "6. Report facts, commands, source decisions, remaining risks, and exact next steps."
    )

    $Checklist = @(
        "- Facts separated from assumptions.",
        "- Source/provenance reviewed when external code, components, assets, or advice are used.",
        "- Security, privacy, accessibility, performance, and rollback considered when relevant.",
        "- Token cost justified by concrete quality gain unless TURBO is explicitly active.",
        "- No broad context loading when a deterministic script or narrow reference is enough."
    )

    $Guardrails = @(
        "- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.",
        "- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.",
        "- Do not copy third-party code or assets without license/provenance review.",
        "- If validation is impossible, state why and provide a concrete manual verification path."
    )

    $Skill = @"
---
name: $Name
description: $($Def.description)
---

# $Title

Use this $($Def.type) for $($Def.category) work focused on $($Def.focus).

## Workflow

$($Workflow -join "`n")

## Checklist

$($Checklist -join "`n")

## Guardrails

$($Guardrails -join "`n")
"@

    $Yaml = @"
interface:
  display_name: "$Title"
  short_description: "$($Def.category) workflow for $Title"
  default_prompt: "Use `$$Name to handle this task with Srednoff OS v2.1.1."

policy:
  allow_implicit_invocation: true
"@

    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $SkillDir "SKILL.md"), $Skill, $Utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $AgentDir "openai.yaml"), $Yaml, $Utf8NoBom)
}

foreach ($Root in $Roots) {
    New-Item -ItemType Directory -Force -Path $Root | Out-Null
    foreach ($Def in $SkillDefinitions) {
        Write-Skill -Root $Root -Def $Def
    }
}

Write-Output "Srednoff OS v2.1.1 skills installed: $($SkillDefinitions.Count) definitions into $($Roots.Count) roots"
