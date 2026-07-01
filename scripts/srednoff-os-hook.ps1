param(
    [ValidateSet("SessionStart", "UserPromptSubmit", "PreToolUse", "Manual")]
    [string]$Mode = "Manual"
)

$ErrorActionPreference = "Stop"

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$RawInput = [Console]::In.ReadToEnd()
$HookInput = $null

if ($RawInput) {
    try {
        $HookInput = $RawInput | ConvertFrom-Json
    } catch {
        $HookInput = $null
    }
}

function Get-Prop {
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    if ($Object.PSObject.Properties.Name -contains $Name) { return $Object.$Name }
    return $null
}

function Get-Cwd {
    $Cwd = Get-Prop -Object $HookInput -Name "cwd"
    if ($Cwd -and (Test-Path -LiteralPath $Cwd)) { return (Resolve-Path -LiteralPath $Cwd).Path }
    return (Get-Location).Path
}

function Get-Sha256 {
    param([string]$Text)
    $Sha = [System.Security.Cryptography.SHA256]::Create()
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $Hash = $Sha.ComputeHash($Bytes)
    return (($Hash | ForEach-Object { $_.ToString("x2") }) -join "")
}

function Write-Ledger {
    param(
        [string]$Event,
        [string]$Cwd,
        [string]$Decision,
        [string[]]$Findings
    )

    $LogDir = Join-Path $CodexHome "srednoff-os\logs"
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    $Entry = [ordered]@{
        ts = (Get-Date).ToUniversalTime().ToString("o")
        version = "v2.1"
        event = $Event
        cwd = $Cwd
        decision = $Decision
        findings = @($Findings)
        input_sha256 = if ($RawInput) { Get-Sha256 -Text $RawInput } else { $null }
    }
    $Line = ($Entry | ConvertTo-Json -Compress -Depth 6) + [Environment]::NewLine
    $Path = Join-Path $LogDir "events.jsonl"
    $Encoding = New-Object System.Text.UTF8Encoding($false)
    for ($Attempt = 1; $Attempt -le 3; $Attempt++) {
        try {
            [System.IO.File]::AppendAllText($Path, $Line, $Encoding)
            return
        } catch {
            if ($Attempt -eq 3) { throw }
            Start-Sleep -Milliseconds (100 * $Attempt)
        }
    }
}

function Find-SecretSignals {
    param([string]$Text)

    $Rules = @(
        @{ Name = "openai_api_key"; Pattern = "sk-[A-Za-z0-9_-]{32,}" },
        @{ Name = "github_token"; Pattern = "gh[pousr]_[A-Za-z0-9_]{32,}" },
        @{ Name = "aws_access_key"; Pattern = "AKIA[0-9A-Z]{16}" },
        @{ Name = "google_api_key"; Pattern = "AIza[0-9A-Za-z_-]{35}" },
        @{ Name = "private_key"; Pattern = "-----BEGIN (RSA |DSA |EC |OPENSSH |)?PRIVATE KEY-----" },
        @{ Name = "jwt"; Pattern = "eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}" }
    )

    $Findings = @()
    foreach ($Rule in $Rules) {
        if ($Text -match $Rule.Pattern) {
            $Findings += $Rule.Name
        }
    }
    return @($Findings | Select-Object -Unique)
}

function Find-DangerousToolSignals {
    param([string]$Text)

    $Rules = @(
        @{ Name = "git_reset_hard"; Pattern = '(?i)git\s+reset\s+--hard' },
        @{ Name = "destructive_home_remove"; Pattern = '(?i)Remove-Item.*-Recurse.*-Force.*(C:\\Users\\Ivan(?:\\)?(?:\s|"|''|$)|\$HOME(?:\s|"|''|$))' },
        @{ Name = "destructive_root_rm"; Pattern = '(?i)rm\s+-rf\s+(/|~|\$HOME)' },
        @{ Name = "windows_format"; Pattern = '(?i)\bformat\s+[A-Z]:' }
    )

    $Findings = @()
    foreach ($Rule in $Rules) {
        if ($Text -match $Rule.Pattern) {
            $Findings += $Rule.Name
        }
    }
    return @($Findings | Select-Object -Unique)
}

function Write-HookContext {
    param([string]$Event, [string]$Context)
    $Output = @{
        hookSpecificOutput = @{
            hookEventName = $Event
            additionalContext = $Context
        }
    }
    Write-Output ($Output | ConvertTo-Json -Compress -Depth 5)
}

function Write-Block {
    param([string]$Reason)
    Write-Output (@{ decision = "block"; reason = $Reason } | ConvertTo-Json -Compress)
}

$Cwd = Get-Cwd
$ScanText = if ($RawInput) { $RawInput } else { "" }
$SecretFindings = Find-SecretSignals -Text $ScanText
$DangerFindings = if ($Mode -eq "PreToolUse") { Find-DangerousToolSignals -Text $ScanText } else { @() }

if ($SecretFindings.Count -gt 0) {
    $Reason = "Srednoff OS v2.1.2 blocked a likely secret in $Mode input: " + ($SecretFindings -join ", ")
    Write-Ledger -Event $Mode -Cwd $Cwd -Decision "block" -Findings $SecretFindings
    Write-Block -Reason $Reason
    exit 0
}

if ($DangerFindings.Count -gt 0) {
    $Reason = "Srednoff OS v2.1.2 blocked a high-risk tool action: " + ($DangerFindings -join ", ")
    Write-Ledger -Event $Mode -Cwd $Cwd -Decision "block" -Findings $DangerFindings
    Write-Block -Reason $Reason
    exit 0
}

if ($Mode -eq "SessionStart") {
    $StatusScript = Join-Path $CodexHome "scripts\srednoff-os-status.ps1"
    try {
        $Status = & $StatusScript -ProjectPath $Cwd
    } catch {
        $Status = "Srednoff OS v2.1.2 loaded: WARN | status script failed: $($_.Exception.Message)"
    }
    Write-Ledger -Event $Mode -Cwd $Cwd -Decision "allow" -Findings @()
    Write-HookContext -Event "SessionStart" -Context "$Status. Use the Srednoff OS selector before substantial work; keep the 4500-record kernel script-only."
    exit 0
}

Write-Ledger -Event $Mode -Cwd $Cwd -Decision "allow" -Findings @()

if ($Mode -eq "PreToolUse") {
    Write-HookContext -Event "PreToolUse" -Context "Srednoff OS v2.1.2 preflight passed: no high-confidence secrets or blocked destructive patterns detected."
}
