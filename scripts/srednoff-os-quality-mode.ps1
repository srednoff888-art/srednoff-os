param(
    [string]$Brief = "",
    [string]$QualityMode = "",
    [string]$ConfigPath = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }

function Resolve-QualityConfig {
    if ($ConfigPath) {
        return (Resolve-Path -LiteralPath $ConfigPath).Path
    }

    $Local = if ($PackageRoot) { Join-Path $PackageRoot ".codex\srednoff-os\quality-modes.json" } else { "" }
    if ($Local -and (Test-Path -LiteralPath $Local -PathType Leaf)) {
        return $Local
    }

    $HomePath = Join-Path $CodexHome "srednoff-os\quality-modes.json"
    if (Test-Path -LiteralPath $HomePath -PathType Leaf) {
        return $HomePath
    }

    throw "Quality modes config not found"
}

function Test-Any {
    param([string]$Text, [string[]]$Patterns)
    foreach ($Pattern in $Patterns) {
        if ($Text -match $Pattern) { return $true }
    }
    return $false
}

$ConfigFile = Resolve-QualityConfig
$Config = Get-Content -LiteralPath $ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
$Lower = $Brief.ToLowerInvariant()

$TurboPatterns = @('(^|\s)turbo(\s|$)', 'mode\s+turbo', 'enable\s+turbo')
$IsTurbo = Test-Any -Text $Lower -Patterns $TurboPatterns

$SelectedName = ""
if ($QualityMode) {
    $SelectedName = $QualityMode.ToLowerInvariant()
} elseif ($IsTurbo) {
    $SelectedName = "turbo"
} elseif (Test-Any -Text $Lower -Patterns @('\bfast\b', '\bquick\b', '\blean\b', 'small fix', 'typo', 'minor docs')) {
    $SelectedName = "fast"
} elseif (Test-Any -Text $Lower -Patterns @('critical', 'security', 'auth', 'payment', 'database', 'migration', 'audit', 'data loss', 'irreversible', 'compliance', 'crypto')) {
    $SelectedName = "critical"
} elseif (Test-Any -Text $Lower -Patterns @('production', 'launch', 'deploy', 'release', 'seo', 'ppc', 'growth', 'mobile', '\b3d\b')) {
    $SelectedName = "production"
} else {
    $SelectedName = [string]$Config.default_quality_mode
}

if ($SelectedName -eq "turbo") {
    $ModeData = [pscustomobject]@{
        name = "turbo"
        description = "Explicit TURBO override for maximum useful quality."
        budget = $Config.turbo_override.budget
        max_capabilities = $Config.turbo_override.max_capabilities
        legacy_mode = $Config.turbo_override.legacy_mode
        validation_gates = @("status-check", "doctor-if-system-change", "top-solutions-matrix", "multi-agent-critique", "strongest-relevant-validation")
        group_policy = "allow_more_group_3_with_relevance"
    }
} else {
    $ModeData = @($Config.modes | Where-Object { $_.name -eq $SelectedName } | Select-Object -First 1)
    if (-not $ModeData) {
        throw "Unknown quality mode: $SelectedName"
    }
}

$Result = [ordered]@{
    name = "Srednoff OS quality mode"
    version = $Config.version
    config = $ConfigFile
    quality_mode = [string]$ModeData.name
    legacy_mode = [string]$ModeData.legacy_mode
    budget = [string]$ModeData.budget
    max_capabilities = [int]$ModeData.max_capabilities
    turbo = ($SelectedName -eq "turbo")
    validation_gates = @($ModeData.validation_gates)
    group_policy = [string]$ModeData.group_policy
    reason = if ($QualityMode) { "explicit quality mode" } elseif ($SelectedName -eq "turbo") { "explicit TURBO trigger" } else { "brief signals" }
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 6
} else {
    Write-Output "Srednoff OS quality mode: $($Result.quality_mode) | budget=$($Result.budget) | max=$($Result.max_capabilities)"
}
