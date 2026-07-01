param(
    [string]$ProjectPath = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$TemplateRoot = Join-Path $CodexHome "templates\codex-md-os"
$SkillRoot = Join-Path $CodexHome "skills"
$KernelRoot = Join-Path $SkillRoot "quality-cost-skill-kernel"
$KernelCatalog = Join-Path $KernelRoot "references\core-3000-capabilities.json"
$Selector = Join-Path $CodexHome "scripts\select-quality-cost-capabilities.ps1"
$SkillIndex = Join-Path $CodexHome "skill-index.json"
$GlobalAgents = Join-Path $CodexHome "AGENTS.md"
$VersionFile = Join-Path $CodexHome "srednoff-os\version.json"
$HooksJson = Join-Path $CodexHome "hooks.json"
$Doctor = Join-Path $CodexHome "scripts\srednoff-os-doctor.ps1"

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
$ProjectKernelCount = Count-JsonArray -Path $ProjectKernel
$Version = Get-SrednoffVersion -Path $VersionFile

$Checks = [ordered]@{
    GlobalAgents = (Test-Path -LiteralPath $GlobalAgents -PathType Leaf)
    GlobalNamed = (Test-TextContains -Path $GlobalAgents -Pattern "Srednoff OS")
    VersionManifest = ($Version -eq "v2.1.1")
    Hooks = (Test-Path -LiteralPath $HooksJson -PathType Leaf)
    Doctor = (Test-Path -LiteralPath $Doctor -PathType Leaf)
    Template = (Test-Path -LiteralPath $TemplateRoot -PathType Container)
    Kernel = ($KernelCount -eq 3000)
    Selector = (Test-Path -LiteralPath $Selector -PathType Leaf)
    SkillIndex = ($SkillIndexCount -gt 0)
    ProjectAgents = (Test-Path -LiteralPath $ProjectAgents -PathType Leaf)
    ProjectNamed = (Test-TextContains -Path $ProjectAgents -Pattern "Srednoff OS")
    ProjectKernel = ($ProjectKernelCount -eq 3000)
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
