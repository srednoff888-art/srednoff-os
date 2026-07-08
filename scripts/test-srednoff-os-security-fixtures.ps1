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
$TempCodexHome = Join-Path ([System.IO.Path]::GetTempPath()) ("srednoff-security-evals-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path (Join-Path $TempCodexHome "scripts") | Out-Null
Copy-Item -LiteralPath $HookScript -Destination (Join-Path $TempCodexHome "scripts\srednoff-os-hook.ps1") -Force
$OldCodexHome = $env:CODEX_HOME
$env:CODEX_HOME = $TempCodexHome

try {
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
        if (@("block", "ask") -contains $ExpectedDecision -and $ExpectedFinding) {
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
} finally {
    $env:CODEX_HOME = $OldCodexHome
}

$LedgerPath = Join-Path $TempCodexHome "srednoff-os\logs\events.jsonl"
if (-not (Test-Path -LiteralPath $LedgerPath -PathType Leaf)) {
    $Results += [pscustomobject]@{
        id = "audit-ledger:exists"
        mode = "audit"
        expected = "present"
        decision = "missing"
        passed = $false
        reason = "ledger not written"
    }
} else {
    $LedgerLines = @(Get-Content -LiteralPath $LedgerPath -Encoding UTF8)
    $LedgerEntries = @($LedgerLines | ForEach-Object { $_ | ConvertFrom-Json })
    $RawLeak = @($LedgerLines | Where-Object { $_ -match 'sk-|ghp_|sk_live_|123456789:' })
    $HasHash = @($LedgerEntries | Where-Object { $_.input_sha256 }).Count -gt 0
    $HasAsk = @($LedgerEntries | Where-Object { $_.decision -eq "ask" }).Count -gt 0
    $HasBlock = @($LedgerEntries | Where-Object { $_.decision -eq "block" }).Count -gt 0
    $Results += [pscustomobject]@{
        id = "audit-ledger:redacted-hashed"
        mode = "audit"
        expected = "redacted"
        decision = "entries=$($LedgerEntries.Count)"
        passed = ($RawLeak.Count -eq 0 -and $HasHash -and $HasAsk -and $HasBlock)
        reason = "raw_leaks=$($RawLeak.Count); has_hash=$HasHash; has_ask=$HasAsk; has_block=$HasBlock"
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
