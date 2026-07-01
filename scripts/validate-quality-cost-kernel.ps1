param(
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$LocalSkillRoot = if ($PackageRoot) { Join-Path $PackageRoot ".codex\skills\quality-cost-skill-kernel" } else { "" }
$HomeSkillRoot = Join-Path $CodexHome "skills\quality-cost-skill-kernel"
$SkillRoot = if ($LocalSkillRoot -and (Test-Path -LiteralPath $LocalSkillRoot -PathType Container)) { $LocalSkillRoot } else { $HomeSkillRoot }
$Build = Join-Path $SkillRoot "scripts\build_core_catalog.py"
$Validate = Join-Path $SkillRoot "scripts\validate_core_catalog.py"
$QuickValidate = Join-Path $CodexHome "skills\.system\skill-creator\scripts\quick_validate.py"

if ($Rebuild) {
    python $Build
}

python $Validate
if (Test-Path -LiteralPath $QuickValidate -PathType Leaf) {
    python $QuickValidate $SkillRoot
} else {
    Write-Output "skip skill quick_validate: validator not found at $QuickValidate"
}
