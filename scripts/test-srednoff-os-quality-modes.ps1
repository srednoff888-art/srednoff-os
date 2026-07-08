param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$QualityScript = Join-Path $Root "scripts\srednoff-os-quality-mode.ps1"
$ModeRouter = Join-Path $Root "scripts\srednoff-os-mode-router.ps1"
$ConfigPath = Join-Path $Root ".codex\srednoff-os\quality-modes.json"
$FixturesPath = Join-Path $Root "evals\srednoff-os-quality-mode-fixtures.json"

foreach ($Path in @($QualityScript, $ModeRouter, $ConfigPath, $FixturesPath)) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing quality mode test dependency: $Path"
    }
}

$Config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
$ModeNames = @($Config.modes | ForEach-Object { $_.name })
foreach ($ExpectedMode in @("fast", "standard", "production", "critical")) {
    if ($ModeNames -notcontains $ExpectedMode) {
        throw "Missing quality mode metadata: $ExpectedMode"
    }
}

$Fixtures = Get-Content -LiteralPath $FixturesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Passed = 0
foreach ($Fixture in $Fixtures) {
    $Quality = & $QualityScript -Brief ([string]$Fixture.brief) -ConfigPath $ConfigPath -Json | ConvertFrom-Json
    if ($Quality.quality_mode -ne $Fixture.expectedQualityMode) {
        throw "Fixture $($Fixture.id) failed quality_mode: got $($Quality.quality_mode)"
    }
    if ($Quality.budget -ne $Fixture.expectedBudget) {
        throw "Fixture $($Fixture.id) failed budget: got $($Quality.budget)"
    }
    if ([int]$Quality.max_capabilities -ne [int]$Fixture.expectedMax) {
        throw "Fixture $($Fixture.id) failed max: got $($Quality.max_capabilities)"
    }

    $Router = & $ModeRouter -Brief ([string]$Fixture.brief) -Json | ConvertFrom-Json
    if ($Router.quality_mode -ne $Fixture.expectedQualityMode) {
        throw "Router fixture $($Fixture.id) failed quality_mode: got $($Router.quality_mode)"
    }
    if ($Router.budget -ne $Fixture.expectedBudget) {
        throw "Router fixture $($Fixture.id) failed budget: got $($Router.budget)"
    }
    if ([int]$Router.max_capabilities -ne [int]$Fixture.expectedMax) {
        throw "Router fixture $($Fixture.id) failed max: got $($Router.max_capabilities)"
    }
    $Passed++
}

Write-Output "Srednoff OS quality mode evals passed: $Passed/$($Fixtures.Count)"
