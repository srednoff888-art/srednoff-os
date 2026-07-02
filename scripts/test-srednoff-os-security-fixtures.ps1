param(
    [string]$ProjectPath = "",
    [string]$FixturesPath = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path -LiteralPath (Join-Path $ScriptDir "..")).Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }

if (-not $ProjectPath -or $ProjectPath -eq "<project-path>") {
    $ProjectPath = $PackageRoot
}

$LocalHook = Join-Path $ScriptDir "srednoff-os-hook.ps1"
$HomeHook = Join-Path $CodexHome "scripts\srednoff-os-hook.ps1"
$HookScript = if (Test-Path -LiteralPath $LocalHook -PathType Leaf) { $LocalHook } else { $HomeHook }

if (-not $FixturesPath) {
    $LocalFixtures = Join-Path $PackageRoot "evals\secret-scan-fixtures.json"
    $HomeFixtures = Join-Path $CodexHome "evals\secret-scan-fixtures.json"
    $FixturesPath = if (Test-Path -LiteralPath $LocalFixtures -PathType Leaf) { $LocalFixtures } else { $HomeFixtures }
}

if (-not (Test-Path -LiteralPath $HookScript -PathType Leaf)) { throw "Hook script not found: $HookScript" }
if (-not (Test-Path -LiteralPath $FixturesPath -PathType Leaf)) { throw "Fixtures not found: $FixturesPath" }

function Get-PowerShellExecutable {
    $Pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($Pwsh) { return $Pwsh.Source }
    $WindowsPowerShell = Get-Command powershell -ErrorAction SilentlyContinue
    if ($WindowsPowerShell) { return $WindowsPowerShell.Source }
    throw "No PowerShell executable found for hook stdin test"
}

$PowerShellExecutable = Get-PowerShellExecutable
$Fixtures = Get-Content -LiteralPath $FixturesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Results = @()

foreach ($Fixture in $Fixtures) {
    $Field = [string]$Fixture.field
    $Content = (@($Fixture.parts) | ForEach-Object { [string]$_ }) -join ""
    $Payload = [ordered]@{
        cwd = $ProjectPath
    }
    $Payload[$Field] = $Content
    $PayloadJson = $Payload | ConvertTo-Json -Compress

    $RawOutput = $PayloadJson | & $PowerShellExecutable -NoProfile -ExecutionPolicy Bypass -File $HookScript -Mode ([string]$Fixture.mode) 2>&1
    $OutputText = ($RawOutput | Out-String).Trim()
    $Decision = "allow"
    $Reason = ""
    try {
        if ($OutputText) {
            $Parsed = $OutputText | ConvertFrom-Json
            if ($Parsed.decision) { $Decision = [string]$Parsed.decision }
            if ($Parsed.reason) { $Reason = [string]$Parsed.reason }
        }
    } catch {
        $Reason = $OutputText
    }

    $ExpectedDecision = [string]$Fixture.expectedDecision
    $ExpectedFinding = [string]$Fixture.expectedFinding
    $Passed = $Decision -eq $ExpectedDecision
    if ($ExpectedDecision -eq "block" -and $ExpectedFinding) {
        $Passed = $Passed -and ($Reason -match [regex]::Escape($ExpectedFinding))
    }

    $Results += [pscustomobject]@{
        id = [string]$Fixture.id
        mode = [string]$Fixture.mode
        expected = $ExpectedDecision
        decision = $Decision
        passed = $Passed
        reason = $Reason
    }
}

$Failed = @($Results | Where-Object { -not $_.passed })
$Summary = [ordered]@{
    name = "Srednoff OS security fixture eval suite"
    version = "v2.1.2"
    total = @($Results).Count
    passed = @($Results | Where-Object { $_.passed }).Count
    failed = $Failed.Count
    results = @($Results)
}

if ($Json) {
    $Summary | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS security fixture evals: passed=$($Summary.passed) failed=$($Summary.failed) total=$($Summary.total)"
    foreach ($Result in $Results) {
        $State = if ($Result.passed) { "ok" } else { "FAIL" }
        Write-Output "$State`t$($Result.id)`texpected=$($Result.expected)`tdecision=$($Result.decision)"
    }
}

if ($Failed.Count -gt 0) { exit 1 }
