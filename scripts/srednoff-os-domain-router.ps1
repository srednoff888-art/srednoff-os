param(
    [string]$ProjectPath = ".",
    [string]$Brief = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$LocalModeRouter = Join-Path $ScriptDir "srednoff-os-mode-router.ps1"
$HomeModeRouter = Join-Path $CodexHome "scripts\srednoff-os-mode-router.ps1"
$ModeRouter = if (Test-Path -LiteralPath $LocalModeRouter -PathType Leaf) { $LocalModeRouter } else { $HomeModeRouter }
$LocalRegistryPath = if ($PackageRoot) { Join-Path $PackageRoot ".codex\srednoff-os\design-source-registry.json" } else { "" }
$HomeRegistryPath = Join-Path $CodexHome "srednoff-os\design-source-registry.json"
$RegistryPath = if ($LocalRegistryPath -and (Test-Path -LiteralPath $LocalRegistryPath -PathType Leaf)) { $LocalRegistryPath } else { $HomeRegistryPath }
$Mode = (& $ModeRouter -Brief $Brief -Json | ConvertFrom-Json)
$Lower = $Brief.ToLowerInvariant()

function Resolve-PathOrLiteral {
    param([string]$Path)
    try {
        if (Test-Path -LiteralPath $Path) {
            return (Resolve-Path -LiteralPath $Path).Path
        }
    } catch {
        return $Path
    }
    return $Path
}

function Test-Any {
    param([string[]]$Patterns)
    foreach ($Pattern in $Patterns) {
        if ($Lower -match $Pattern) { return $true }
    }
    return $false
}

$Domains = New-Object System.Collections.Generic.List[string]

if (Test-Any @('ui/ux','ux','ui\b','web design','landing','dashboard','component','shadcn','figma','canva','21st','magic ui','aceternity','origin ui','react bits','design','interface')) {
    $Domains.Add("ui-ux") | Out-Null
    $Domains.Add("web-design") | Out-Null
}

if (Test-Any @('\b3d\b','three','react three fiber','r3f','webgl','webgpu','gltf','model-viewer','babylon','shader','xr','ar\b','configurator')) {
    $Domains.Add("3d-web") | Out-Null
    if (Test-Any @('configurator','viewer','hero','landing','product','interface','ui\b','ux')) {
        $Domains.Add("ui-ux") | Out-Null
    }
}

if (Test-Any @('mobile','ios','android','expo','react native','swiftui','kotlin','eas','app store','testflight')) {
    $Domains.Add("mobile-apps") | Out-Null
}

if (Test-Any @('seo','ppc','growth','ads','google ads','meta ads','serp','landing page','conversion','analytics','geo','search console','paid search','advertising')) {
    $Domains.Add("seo-ppc-growth") | Out-Null
}

if (Test-Any @('api','backend','frontend','typescript','javascript','python','node','react','next','sql','postgres','database','php','go\b','rust','swift','kotlin','bash','powershell','test','lint','build','code','programming')) {
    $Domains.Add("programming") | Out-Null
}

if ($Domains.Count -eq 0) {
    $Domains.Add("general") | Out-Null
}

$DomainList = @($Domains.ToArray() | Select-Object -Unique)
$Questions = @()
$ConnectorSuggestions = @()
$SkillPacks = @()
$ValidationGates = @("status-check", "doctor-if-system-change")

if ($DomainList -contains "ui-ux" -or $DomainList -contains "web-design") {
    $Questions += "What product/site type, target user, and desired impression?"
    $Questions += "Which visual direction: premium SaaS, editorial, ecommerce, utilitarian, luxury, playful, brutalist?"
    $Questions += "Should I offer/use 21st.dev Magic, Figma, Canva, shadcn registry, Magic UI, Aceternity, Origin UI, React Bits?"
    $ConnectorSuggestions += "magic:21st.dev"
    $ConnectorSuggestions += "figma"
    $ConnectorSuggestions += "canva"
    $SkillPacks += "design-brief-autogenerator"
    $SkillPacks += "source-ranking-roi-selector"
    $SkillPacks += "design-brief-intake-router"
    $SkillPacks += "ui-component-source-router"
    $SkillPacks += "copy-adapt-component-pipeline"
    $SkillPacks += "component-provenance-license-review"
    $SkillPacks += "anti-ai-slop-design-critic"
    $ValidationGates += "visual-regression-design-gate"
    $ValidationGates += "accessibility"
    $ValidationGates += "responsive-screenshots"
}

if ($DomainList -contains "3d-web") {
    $Questions += "Is this a product viewer, hero scene, configurator, AR/model preview, data viz, or decorative 3D scene?"
    $SkillPacks += "3d-experience-brief-intake"
    $SkillPacks += "design-brief-autogenerator"
    $SkillPacks += "source-ranking-roi-selector"
    $SkillPacks += "three-vs-babylon-vs-model-viewer"
    $SkillPacks += "gltf-optimization-pipeline-v2"
    $SkillPacks += "3d-performance-budget-gate"
    $SkillPacks += "3d-visual-screenshot-validator"
    $ValidationGates += "canvas-nonblank"
    $ValidationGates += "mobile-3d-fallback"
    $ValidationGates += "asset-size-report"
}

if ($DomainList -contains "mobile-apps") {
    $SkillPacks += "mobile-ux-platform-parity"
    $SkillPacks += "expo-eas-release-gate"
    $SkillPacks += "mobile-offline-first-review"
    $SkillPacks += "mobile-permissions-privacy-gate"
    $SkillPacks += "mobile-crash-analytics-gate"
    $ValidationGates += "mobile-device-checklist"
    $ValidationGates += "privacy-permissions-review"
}

if ($DomainList -contains "seo-ppc-growth") {
    $SkillPacks += "growth-design-message-match"
    $SkillPacks += "serp-to-page-brief-generator"
    $SkillPacks += "ppc-landing-quality-score-gate"
    $SkillPacks += "growth-experiment-backlog"
    $ValidationGates += "search-policy-review"
    $ValidationGates += "analytics-tracking-review"
}

if ($DomainList -contains "programming") {
    $SkillPacks += "language-runtime-router"
    $SkillPacks += "source-first-api-verifier"
    $SkillPacks += "dependency-minimalism-gate"
    $SkillPacks += "cross-language-test-gate"
    $ValidationGates += "lint-typecheck-build-tests"
    $ValidationGates += "code-review"
}

if ($Mode.mode -eq "turbo") {
    $SkillPacks += "turbo-mode-controller"
    $SkillPacks += "turbo-source-benchmark"
    $SkillPacks += "turbo-multi-agent-review"
    $SkillPacks += "turbo-validation-gate"
    $ValidationGates += "multi-agent-critique"
    $ValidationGates += "top-solutions-matrix"
}

$Registry = @()
if (Test-Path -LiteralPath $RegistryPath -PathType Leaf) {
    $RegistryData = Get-Content -LiteralPath $RegistryPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $Registry = @($RegistryData.sources | Where-Object {
        $Source = $_
        @($Source.domains | Where-Object { $DomainList -contains $_ }).Count -gt 0
    } | Select-Object id, name, url, kind, risk, connector, requires_user_prompt)
}

$Result = [ordered]@{
    name = "Srednoff OS domain router"
    version = "v2.1.2"
    project = Resolve-PathOrLiteral -Path $ProjectPath
    mode = $Mode.mode
    turbo = [bool]$Mode.turbo
    budget = $Mode.budget
    max_capabilities = $Mode.max_capabilities
    domains = @($DomainList)
    blocking_questions = @($Questions | Select-Object -Unique | Select-Object -First 5)
    connector_suggestions = @($ConnectorSuggestions | Select-Object -Unique)
    skill_packs = @($SkillPacks | Select-Object -Unique)
    validation_gates = @($ValidationGates | Select-Object -Unique)
    source_candidates = @($Registry)
    helper_scripts = [ordered]@{
        design_brief = "scripts\srednoff-os-design-brief.ps1"
        source_ranker = "scripts\srednoff-os-source-ranker.ps1"
    }
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS domains: $($DomainList -join ', ') | mode=$($Mode.mode) | skills=$(@($Result.skill_packs).Count) | gates=$(@($Result.validation_gates).Count)"
    if ($Result.connector_suggestions.Count -gt 0) {
        Write-Output "Connectors/sources to offer: $($Result.connector_suggestions -join ', ')"
    }
    if ($Result.blocking_questions.Count -gt 0) {
        Write-Output "Questions:"
        $Result.blocking_questions | ForEach-Object { Write-Output "- $_" }
    }
}
