param(
    [string]$Brief = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$LocalQualityMode = Join-Path $ScriptDir "srednoff-os-quality-mode.ps1"
$HomeQualityMode = Join-Path $CodexHome "scripts\srednoff-os-quality-mode.ps1"
$QualityModeScript = if (Test-Path -LiteralPath $LocalQualityMode -PathType Leaf) { $LocalQualityMode } else { $HomeQualityMode }

$Text = $Brief.Trim()
$Lower = $Text.ToLowerInvariant()

$TurboPatterns = @(
    '(^|\s)turbo(\s|$)',
    'mode\s+turbo',
    'enable\s+turbo',
    'turbo\s+для'
)

$DeepPatterns = @(
    'максимальн',
    'без оглядки',
    'не экономь',
    'production',
    'security',
    'launch',
    'architecture',
    'seo',
    'ppc',
    'crypto',
    '3d',
    'mobile',
    'deploy',
    'migration',
    'audit'
)

$DeepLiteralPatterns = @(
    ([string]::Concat([char]0x043C,[char]0x0430,[char]0x043A,[char]0x0441,[char]0x0438,[char]0x043C,[char]0x0430,[char]0x043B,[char]0x044C,[char]0x043D)),
    ([string]::Concat([char]0x043D,[char]0x0435,[char]0x0020,[char]0x044D,[char]0x043A,[char]0x043E,[char]0x043D,[char]0x043E,[char]0x043C)),
    ([string]::Concat([char]0x0431,[char]0x0435,[char]0x0437,[char]0x0020,[char]0x043E,[char]0x0433,[char]0x043B,[char]0x044F,[char]0x0434))
)

$IsTurbo = $false
foreach ($Pattern in $TurboPatterns) {
    if ($Lower -match $Pattern) {
        $IsTurbo = $true
        break
    }
}

$IsDeep = $false
foreach ($Pattern in $DeepPatterns) {
    if ($Lower -match $Pattern) {
        $IsDeep = $true
        break
    }
}

if (-not $IsDeep) {
    foreach ($Pattern in $DeepLiteralPatterns) {
        if ($Lower.Contains($Pattern)) {
            $IsDeep = $true
            break
        }
    }
}

if (Test-Path -LiteralPath $QualityModeScript -PathType Leaf) {
    $Quality = & $QualityModeScript -Brief $Brief -Json | ConvertFrom-Json
    $Mode = [string]$Quality.legacy_mode
    $Budget = [string]$Quality.budget
    $MaxCapabilities = [int]$Quality.max_capabilities
    if (-not $IsTurbo -and $IsDeep -and $Mode -eq "normal" -and [string]$Quality.quality_mode -eq "standard") {
        $Mode = "deep"
        $Budget = "deep"
        $MaxCapabilities = 24
        $Quality.quality_mode = "production"
        $Quality.validation_gates = @("status-check", "doctor-if-system-change", "tests-build-lint", "release-risk-review")
        $Quality.group_policy = "allow_group_3_when_result_is_concrete"
    }
} else {
    $Mode = if ($IsTurbo) { "turbo" } elseif ($IsDeep) { "deep" } else { "normal" }
    $Budget = if ($Mode -eq "turbo") { "turbo" } elseif ($Mode -eq "deep") { "deep" } else { "balanced" }
    $MaxCapabilities = if ($Mode -eq "turbo") { 48 } elseif ($Mode -eq "deep") { 24 } else { 16 }
    $Quality = [pscustomobject]@{
        quality_mode = if ($IsTurbo) { "turbo" } elseif ($IsDeep) { "production" } else { "standard" }
        validation_gates = @("status-check")
        group_policy = "groups_1_2_first"
    }
}

$Result = [ordered]@{
    name = "Srednoff OS mode router"
    version = "v2.1.2"
    mode = $Mode
    quality_mode = [string]$Quality.quality_mode
    budget = $Budget
    max_capabilities = $MaxCapabilities
    turbo = $IsTurbo
    validation_gates = @($Quality.validation_gates)
    group_policy = [string]$Quality.group_policy
    reason = if ($IsTurbo) { "explicit TURBO trigger" } elseif ($IsDeep) { "high-value/deep-work trigger without TURBO" } else { "normal scoped work" }
    safety = [ordered]@{
        destructive_confirmation_required = $true
        paid_confirmation_required = $true
        production_confirmation_required = $true
        secret_protection_enabled = $true
        license_review_required = $true
    }
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 6
} else {
    Write-Output "Srednoff OS mode: $Mode | budget=$Budget | max=$MaxCapabilities | reason=$($Result.reason)"
}
