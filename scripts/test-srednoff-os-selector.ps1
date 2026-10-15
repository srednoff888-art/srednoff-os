param(
    [string]$ProjectPath = "",
    [string]$FixturesPath = "",
    [int]$Max = 16,
    [switch]$Json
)
$ErrorActionPreference = "Stop"
$PackageRoot = Split-Path -Parent $PSScriptRoot
$CodexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
if (-not $ProjectPath -or $ProjectPath -eq "<project-path>") { $ProjectPath = $PackageRoot }
$LocalSkills = Join-Path $PackageRoot ".codex\skills"
$SkillsRoot = if (Test-Path -LiteralPath $LocalSkills) { $LocalSkills } else { Join-Path $CodexRoot "skills" }
if (-not $FixturesPath) {
    $LocalFixtures = Join-Path $PackageRoot "evals\srednoff-os-selector-fixtures.json"
    $FixturesPath = if (Test-Path -LiteralPath $LocalFixtures) { $LocalFixtures } else { Join-Path $CodexRoot "evals\srednoff-os-selector-fixtures.json" }
}
$Output = & python (Join-Path $PSScriptRoot "selector_eval.py") --fixtures $FixturesPath --project $ProjectPath --skills-root $SkillsRoot --max $Max
$ExitCode = $LASTEXITCODE
$Summary = ($Output | Out-String) | ConvertFrom-Json
if ($Json) { $Summary | ConvertTo-Json -Depth 8 } else {
    Write-Output "Srednoff OS selector evals: passed=$($Summary.passed) failed=$($Summary.failed) total=$($Summary.total)"
    foreach ($Result in $Summary.results) {
        $State = if ($Result.passed) { "ok" } else { "FAIL" }
        Write-Output "$State $($Result.id) missing=$($Result.missing -join ',') unwanted=$($Result.unwanted -join ',')"
    }
}
if ($ExitCode -ne 0 -or $Summary.failed -gt 0) { exit 1 }
