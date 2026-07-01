param(
    [string]$ProjectPath = "<project-path>",
    [string]$FixturesPath = "$HOME\.codex\evals\srednoff-os-selector-fixtures.json",
    [int]$Max = 16,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$Selector = Join-Path $HOME ".codex\scripts\select-quality-cost-capabilities.ps1"
if (-not (Test-Path -LiteralPath $Selector -PathType Leaf)) { throw "Selector not found: $Selector" }
if (-not (Test-Path -LiteralPath $FixturesPath -PathType Leaf)) { throw "Fixtures not found: $FixturesPath" }

$Fixtures = Get-Content -LiteralPath $FixturesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Results = @()

foreach ($Fixture in $Fixtures) {
    $Budget = if ($Fixture.budget) { [string]$Fixture.budget } else { "balanced" }
    $Output = & powershell -NoProfile -ExecutionPolicy Bypass -File $Selector -ProjectPath $ProjectPath -Brief ([string]$Fixture.brief) -Budget $Budget -Max $Max -Format compact 2>&1
    $Text = ($Output | Out-String)
    $HitList = @()
    foreach ($Expected in $Fixture.expectedAny) {
        if ($Text -match [regex]::Escape([string]$Expected)) {
            $HitList += [string]$Expected
        }
    }
    $Passed = $HitList.Count -gt 0
    $Results += [pscustomobject]@{
        id = [string]$Fixture.id
        budget = $Budget
        passed = $Passed
        matches = @($HitList)
        expectedAny = @($Fixture.expectedAny)
    }
}

$Failed = @($Results | Where-Object { -not $_.passed })
$Summary = [ordered]@{
    name = "Srednoff OS selector eval suite"
    version = "v2.1"
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
