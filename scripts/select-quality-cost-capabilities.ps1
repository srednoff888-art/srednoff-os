param(
    [string]$ProjectPath = ".",
    [AllowEmptyString()]
    [string]$Brief = "",
    [ValidateSet("lean", "balanced", "deep", "turbo")]
    [string]$Budget = "balanced",
    [int]$Max = 24,
    [string]$JsonOutput = "",
    [ValidateSet("compact", "ids")]
    [string]$Format = "compact",
    [ValidateSet("auto", "full", "off")]
    [string]$ProjectScan = "auto"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$LocalSelector = if ($PackageRoot) { Join-Path $PackageRoot ".codex\skills\quality-cost-skill-kernel\scripts\select_core_capabilities.py" } else { "" }
$HomeSelector = Join-Path $CodexHome "skills\quality-cost-skill-kernel\scripts\select_core_capabilities.py"
$Selector = if ($LocalSelector -and (Test-Path -LiteralPath $LocalSelector -PathType Leaf)) { $LocalSelector } else { $HomeSelector }
$LocalSkillsRoot = if ($PackageRoot) { Join-Path $PackageRoot ".codex\skills" } else { "" }
$LocalSkillIndex = if ($PackageRoot) { Join-Path $PackageRoot ".codex\skill-index.json" } else { "" }

if (-not (Test-Path -LiteralPath $Selector)) {
    throw "quality-cost selector not found: $Selector"
}

$Args = @($Selector, "--project", $ProjectPath, "--budget", $Budget, "--max", "$Max", "--format", $Format)
$Args += @("--project-scan", $ProjectScan)
if ($LocalSkillIndex -and (Test-Path -LiteralPath $LocalSkillIndex -PathType Leaf) -and $Selector -eq $LocalSelector) {
    $Args += @("--skill-index", $LocalSkillIndex)
} elseif ($LocalSkillsRoot -and (Test-Path -LiteralPath $LocalSkillsRoot -PathType Container) -and $Selector -eq $LocalSelector) {
    $Args += @("--skills-root", $LocalSkillsRoot)
}
if ($Brief) {
    $Args += @("--brief", $Brief)
}
if ($JsonOutput) {
    $Args += @("--json-output", $JsonOutput)
}

python @Args
