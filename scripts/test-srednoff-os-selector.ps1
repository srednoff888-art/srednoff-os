param(
    [string]$ProjectPath = "",
    [string]$FixturesPath = "",
    [int]$Max = 16,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path -LiteralPath (Join-Path $ScriptDir "..")).Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }

if (-not $ProjectPath -or $ProjectPath -eq "<project-path>") {
    $ProjectPath = $PackageRoot
}

$LocalSelector = Join-Path $ScriptDir "select-quality-cost-capabilities.ps1"
$HomeSelector = Join-Path $CodexHome "scripts\select-quality-cost-capabilities.ps1"
$Selector = if (Test-Path -LiteralPath $LocalSelector -PathType Leaf) { $LocalSelector } else { $HomeSelector }
if (-not $FixturesPath) {
    $LocalFixtures = Join-Path $PackageRoot "evals\srednoff-os-selector-fixtures.json"
    $HomeFixtures = Join-Path $CodexHome "evals\srednoff-os-selector-fixtures.json"
    $FixturesPath = if (Test-Path -LiteralPath $LocalFixtures -PathType Leaf) { $LocalFixtures } else { $HomeFixtures }
}

if (-not (Test-Path -LiteralPath $Selector -PathType Leaf)) { throw "Selector not found: $Selector" }
if (-not (Test-Path -LiteralPath $FixturesPath -PathType Leaf)) { throw "Fixtures not found: $FixturesPath" }

$Fixtures = Get-Content -LiteralPath $FixturesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Results = @()

foreach ($Fixture in $Fixtures) {
    $Budget = if ($Fixture.budget) { [string]$Fixture.budget } else { "balanced" }
    $Output = & powershell -NoProfile -ExecutionPolicy Bypass -File $Selector -ProjectPath $ProjectPath -Brief ([string]$Fixture.brief) -Budget $Budget -Max $Max -Format compact 2>&1
    $Text = ($Output | Out-String)
    $HitList = @()
    $ExpectedAny = if ($Fixture.PSObject.Properties.Name -contains "expectedAny") { @($Fixture.expectedAny) } else { @() }
    $ExpectedAll = if ($Fixture.PSObject.Properties.Name -contains "expectedAll") { @($Fixture.expectedAll) } else { @() }
    foreach ($Expected in $ExpectedAny) {
        if ($Text -match [regex]::Escape([string]$Expected)) {
            $HitList += [string]$Expected
        }
    }
    $MissingAll = @()
    foreach ($Expected in $ExpectedAll) {
        if ($Text -match [regex]::Escape([string]$Expected)) {
            if ($HitList -notcontains [string]$Expected) { $HitList += [string]$Expected }
        } else {
            $MissingAll += [string]$Expected
        }
    }
    $HasAnyExpectation = $ExpectedAny.Count -gt 0
    $HasAllExpectation = $ExpectedAll.Count -gt 0
    $PassedAny = (-not $HasAnyExpectation) -or ($HitList.Count -gt 0)
    $PassedAll = (-not $HasAllExpectation) -or ($MissingAll.Count -eq 0)
    $Passed = $PassedAny -and $PassedAll
    $Results += [pscustomobject]@{
        id = [string]$Fixture.id
        budget = $Budget
        passed = $Passed
        matches = @($HitList)
        expectedAny = @($ExpectedAny)
        expectedAll = @($ExpectedAll)
        missingAll = @($MissingAll)
    }
}

$Failed = @($Results | Where-Object { -not $_.passed })
$Summary = [ordered]@{
    name = "Srednoff OS selector eval suite"
    version = "v2.1.2"
    total = @($Results).Count
    passed = @($Results | Where-Object { $_.passed }).Count
    failed = $Failed.Count
    results = @($Results)
}

if ($Json) {
    $Summary | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS selector evals: passed=$($Summary.passed) failed=$($Summary.failed) total=$($Summary.total)"
    foreach ($Result in $Results) {
        $State = if ($Result.passed) { "ok" } else { "FAIL" }
        Write-Output "$State`t$($Result.id)`tmatches=$($Result.matches -join ',')"
    }
}

if ($Failed.Count -gt 0) { exit 1 }
