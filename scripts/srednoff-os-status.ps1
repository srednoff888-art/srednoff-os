param(
    [string]$ProjectPath = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }

function Resolve-LocalOrHome {
    param(
        [string]$LocalRelative,
        [string]$HomeRelative,
        [string]$PathType = "Any"
    )
    $Local = if ($PackageRoot) { Join-Path $PackageRoot $LocalRelative } else { "" }
    $HomePath = Join-Path $CodexHome $HomeRelative
    if ($Local) {
        if ($PathType -eq "Container" -and (Test-Path -LiteralPath $Local -PathType Container)) { return $Local }
        if ($PathType -eq "Leaf" -and (Test-Path -LiteralPath $Local -PathType Leaf)) { return $Local }
        if ($PathType -eq "Any" -and (Test-Path -LiteralPath $Local)) { return $Local }
    }
    return $HomePath
}

$TemplateRoot = Resolve-LocalOrHome "." "templates\codex-md-os" "Container"
$SkillRoot = Resolve-LocalOrHome ".codex\skills" "skills" "Container"
$KernelRoot = Join-Path $SkillRoot "quality-cost-skill-kernel"
$KernelCatalog = Join-Path $KernelRoot "references\core-3000-capabilities.json"
$ExpectedKernelRecords = 4500
$Selector = Resolve-LocalOrHome "scripts\select-quality-cost-capabilities.ps1" "scripts\select-quality-cost-capabilities.ps1" "Leaf"
$SkillIndex = Resolve-LocalOrHome ".codex\skill-index.json" "skill-index.json" "Leaf"
$GlobalAgents = Resolve-LocalOrHome "AGENTS.md" "AGENTS.md" "Leaf"
$VersionFile = Resolve-LocalOrHome ".codex\srednoff-os\version.json" "srednoff-os\version.json" "Leaf"
$HooksJson = Join-Path $CodexHome "hooks.json"
$Doctor = Resolve-LocalOrHome "scripts\srednoff-os-doctor.ps1" "scripts\srednoff-os-doctor.ps1" "Leaf"

function Test-TextContains {
    param([string]$Path, [string]$Pattern)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    $Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    return ($Text -match [regex]::Escape($Pattern))
}

function Count-JsonArray {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return 0 }
    $Data = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    return $Data.Count
}

function Get-SrednoffVersion {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return "unknown" }
    try {
        $Data = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($Data.version) { return [string]$Data.version }
    } catch {
        return "unknown"
    }
    return "unknown"
}

$ResolvedProject = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction SilentlyContinue)
$ProjectRoot = if ($ResolvedProject) { $ResolvedProject.Path } else { $ProjectPath }
$ProjectAgents = Join-Path $ProjectRoot "AGENTS.md"
$ProjectKernel = Join-Path $ProjectRoot ".codex\skills\quality-cost-skill-kernel\references\core-3000-capabilities.json"

$KernelCount = Count-JsonArray -Path $KernelCatalog
$SkillIndexCount = Count-JsonArray -Path $SkillIndex
if ($SkillIndexCount -eq 0 -and (Test-Path -LiteralPath $SkillRoot -PathType Container)) {
    $SkillIndexCount = @(Get-ChildItem -LiteralPath $SkillRoot -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }).Count
}
$ProjectKernelCount = Count-JsonArray -Path $ProjectKernel
$Version = Get-SrednoffVersion -Path $VersionFile

$Checks = [ordered]@{
    GlobalAgents = (Test-Path -LiteralPath $GlobalAgents -PathType Leaf)
    GlobalNamed = (Test-TextContains -Path $GlobalAgents -Pattern "Srednoff OS")
    VersionManifest = ($Version -eq "v2.1.2")
    Hooks = (Test-Path -LiteralPath $HooksJson -PathType Leaf)
    Doctor = (Test-Path -LiteralPath $Doctor -PathType Leaf)
    Template = (Test-Path -LiteralPath $TemplateRoot -PathType Container)
    Kernel = ($KernelCount -eq $ExpectedKernelRecords)
    Selector = (Test-Path -LiteralPath $Selector -PathType Leaf)
    SkillIndex = ($SkillIndexCount -gt 0)
    ProjectAgents = (Test-Path -LiteralPath $ProjectAgents -PathType Leaf)
    ProjectNamed = (Test-TextContains -Path $ProjectAgents -Pattern "Srednoff OS")
    ProjectKernel = ($ProjectKernelCount -eq $ExpectedKernelRecords)
}

$Failed = @($Checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object { $_.Key })
$Status = if ($Failed.Count -eq 0) { "OK" } else { "WARN" }

$Result = [ordered]@{
    name = "Srednoff OS"
    version = $Version
    status = $Status
    project = $ProjectRoot
    kernel_records = $KernelCount
    project_kernel_records = $ProjectKernelCount
    skill_index_entries = $SkillIndexCount
    failed_checks = $Failed
    checks = $Checks
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 5
    exit 0
}

$ProjectState = if ($Checks.ProjectAgents -and $Checks.ProjectKernel) { "project=OK" } else { "project=SYNC_NEEDED" }
$FailedText = if ($Failed.Count -gt 0) { " | failed=" + ($Failed -join ",") } else { "" }
Write-Output "Srednoff OS $Version loaded: $Status | $ProjectState | skills=$SkillIndexCount | kernel=$KernelCount | selector=$($Checks.Selector)$FailedText"
