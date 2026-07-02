param(
    [string]$ProjectPath = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path -LiteralPath (Join-Path $ScriptDir "..")).Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
if (-not $ProjectPath -or $ProjectPath -eq "<project-path>") {
    $ProjectPath = $PackageRoot
}

function Resolve-LocalOrHomeScript {
    param([string]$Name)
    $Local = Join-Path $ScriptDir $Name
    if (Test-Path -LiteralPath $Local -PathType Leaf) { return $Local }
    return (Join-Path $CodexHome "scripts\$Name")
}

function Resolve-LocalOrHomeEval {
    param([string]$Name)
    $Local = Join-Path $PackageRoot "evals\$Name"
    if (Test-Path -LiteralPath $Local -PathType Leaf) { return $Local }
    return (Join-Path $CodexHome "evals\$Name")
}

$ModeRouter = Resolve-LocalOrHomeScript "srednoff-os-mode-router.ps1"
$DomainRouter = Resolve-LocalOrHomeScript "srednoff-os-domain-router.ps1"
$InventoryScript = Resolve-LocalOrHomeScript "srednoff-os-mcp-inventory.ps1"
$HookScript = Resolve-LocalOrHomeScript "srednoff-os-hook.ps1"
$ModeFixtures = Resolve-LocalOrHomeEval "srednoff-os-mode-fixtures.json"
$DomainFixtures = Resolve-LocalOrHomeEval "srednoff-os-domain-fixtures.json"

function Add-Result {
    param([string]$Id, [bool]$Passed, [string]$Detail)
    [pscustomobject]@{ id = $Id; passed = $Passed; detail = $Detail }
}

$Results = @()

$Modes = Get-Content -LiteralPath $ModeFixtures -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($Fixture in $Modes) {
    $Out = & $ModeRouter -Brief ([string]$Fixture.brief) -Json | ConvertFrom-Json
    $Results += Add-Result -Id ("mode:" + $Fixture.id) -Passed ($Out.mode -eq $Fixture.expectedMode) -Detail "expected=$($Fixture.expectedMode); actual=$($Out.mode)"
}

$Domains = Get-Content -LiteralPath $DomainFixtures -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($Fixture in $Domains) {
    $Out = & $DomainRouter -ProjectPath $ProjectPath -Brief ([string]$Fixture.brief) -Json | ConvertFrom-Json
    $Missing = @($Fixture.expectedDomains | Where-Object { $Out.domains -notcontains $_ })
    $Results += Add-Result -Id ("domain:" + $Fixture.id) -Passed ($Missing.Count -eq 0) -Detail "expected=$($Fixture.expectedDomains -join ','); actual=$($Out.domains -join ','); missing=$($Missing -join ',')"
}

$ConfigPath = Join-Path $CodexHome "config.toml"
if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
    $Inventory = & $InventoryScript -Json | ConvertFrom-Json
    $FalseEnvServers = @($Inventory.items | Where-Object { $_.kind -eq "mcp_server" -and $_.name -match '\.env$' })
    $Magic = @($Inventory.items | Where-Object { $_.kind -eq "mcp_server" -and $_.name -eq "magic" })
    $Results += Add-Result -Id "mcp:no-env-server" -Passed ($FalseEnvServers.Count -eq 0) -Detail "false_env_servers=$($FalseEnvServers.Count)"
    $Results += Add-Result -Id "mcp:magic-env" -Passed ($Magic.Count -eq 1 -and [bool]$Magic[0].has_env) -Detail "magic_count=$($Magic.Count); magic_has_env=$([bool]$Magic[0].has_env)"
} else {
    $Results += Add-Result -Id "mcp:no-env-server" -Passed $true -Detail "skipped: config.toml not present in this runner"
    $Results += Add-Result -Id "mcp:magic-env" -Passed $true -Detail "skipped: config.toml not present in this runner"
}

$Danger = '{"cwd":"C:\\Users\\Ivan\\Documents\\Codex\\2026-06-28\\new-chat","tool_name":"shell_command","tool_input":{"command":"git reset --hard"}}'
$DangerOut = $Danger | powershell -NoProfile -ExecutionPolicy Bypass -File $HookScript -Mode PreToolUse | Out-String
$Results += Add-Result -Id "hook:block-danger" -Passed ($DangerOut -match '"decision"\s*:\s*"block"' -and $DangerOut -match "git_reset_hard") -Detail (($DangerOut -replace "\s+", " ").Trim())

$Safe = '{"cwd":"C:\\Users\\Ivan\\Documents\\Codex\\2026-06-28\\new-chat","tool_name":"shell_command","tool_input":{"command":"Get-ChildItem"}}'
$SafeOut = $Safe | powershell -NoProfile -ExecutionPolicy Bypass -File $HookScript -Mode PreToolUse | Out-String
$Results += Add-Result -Id "hook:allow-safe" -Passed ($SafeOut -match "preflight passed") -Detail (($SafeOut -replace "\s+", " ").Trim())

$Failed = @($Results | Where-Object { -not $_.passed })
$Summary = [ordered]@{
    name = "Srednoff OS v2.1.1 eval suite"
    version = "v2.1.1"
    total = @($Results).Count
    passed = @($Results | Where-Object { $_.passed }).Count
    failed = $Failed.Count
    results = @($Results)
}

if ($Json) {
    $Summary | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS v2.1.1 evals: passed=$($Summary.passed) failed=$($Summary.failed) total=$($Summary.total)"
    foreach ($Result in $Results) {
        $State = if ($Result.passed) { "ok" } else { "FAIL" }
        Write-Output "$State`t$($Result.id)`t$($Result.detail)"
    }
}

if ($Failed.Count -gt 0) { exit 1 }
