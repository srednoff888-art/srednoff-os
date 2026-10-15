param(
    [string]$SkillsRoot = "",
    [string]$OutputPath = "",
    [switch]$RelativePaths,
    [string]$RelativeBase = "",
    [switch]$Check
)
$ErrorActionPreference = "Stop"
$PackageRoot = Split-Path -Parent $PSScriptRoot
$LocalSkills = Join-Path $PackageRoot ".codex\skills"
$CodexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
if (-not $SkillsRoot) {
    $SkillsRoot = if (Test-Path -LiteralPath $LocalSkills) { $LocalSkills } else { Join-Path $CodexRoot "skills" }
}
if (-not $OutputPath) {
    $OutputPath = if (Test-Path -LiteralPath $LocalSkills) { Join-Path $PackageRoot ".codex\skill-index.json" } else { Join-Path $CodexRoot "skill-index.json" }
}
$Arguments = @((Join-Path $PSScriptRoot "skill_catalog.py"), "index", "--skills-root", $SkillsRoot, "--output", $OutputPath)
# Package indexes are portable by default; global indexes use resolved runtime paths.
if ($RelativePaths -or ((Test-Path -LiteralPath $LocalSkills) -and $SkillsRoot -eq $LocalSkills)) {
    if (-not $RelativeBase) { $RelativeBase = $PackageRoot }
    $Arguments += @("--relative-base", $RelativeBase)
}
if ($Check) { $Arguments += "--check" }
& python @Arguments
if ($LASTEXITCODE -ne 0) { throw "Skill index generation or freshness check failed." }
