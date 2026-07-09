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
        [string[]]$Findings,
        [string]$Reason = ""
    )

    $LogDir = Join-Path $CodexHome "srednoff-os\logs"
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    $Entry = [ordered]@{
        ts = (Get-Date).ToUniversalTime().ToString("o")
        version = "v2.1.2"
        event = $Event
        cwd = $Cwd
        decision = $Decision
        findings = @($Findings)
        reason_code = $Reason
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
        @{ Name = "openai_api_key"; Pattern = "(?<![A-Za-z0-9_-])(?:sk-(?:proj|svcacct|admin)-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,})(?![A-Za-z0-9_-])" },
        @{ Name = "github_token"; Pattern = "gh[pousr]_[A-Za-z0-9_]{32,}" },
        @{ Name = "aws_access_key"; Pattern = "AKIA[0-9A-Z]{16}" },
        @{ Name = "google_api_key"; Pattern = "AIza[0-9A-Za-z_-]{35}" },
        @{ Name = "stripe_secret_key"; Pattern = "sk_(live|test)_[0-9A-Za-z]{24,}" },
        @{ Name = "slack_token"; Pattern = "xox[baprs]-[0-9A-Za-z-]{20,}" },
        @{ Name = "npm_token"; Pattern = "npm_[A-Za-z0-9]{36,}" },
        @{ Name = "telegram_bot_token"; Pattern = "[0-9]{8,10}:[A-Za-z0-9_-]{35}" },
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

function Get-HomeTargetPattern {
    $HomeCandidates = @(
        $HOME,
        $env:USERPROFILE,
        [Environment]::GetFolderPath("UserProfile")
    ) | Where-Object { $_ } | ForEach-Object {
        try {
            (Resolve-Path -LiteralPath $_ -ErrorAction Stop).Path.TrimEnd("\", "/")
        } catch {
            ([string]$_).TrimEnd("\", "/")
        }
    } | Sort-Object -Unique

    $Targets = @($HomeCandidates | ForEach-Object { [regex]::Escape($_) })
    $Targets += @("\`$HOME", "~")
    return "(?:" + (($Targets | Where-Object { $_ }) -join "|") + ")(?:\\)?(?:\s|`"|''|$)"
}

function Find-DangerousToolSignals {
    param([string]$Text)

    $NormalizedText = $Text.Replace('\\', '\')
    $HomeTargetPattern = Get-HomeTargetPattern

    $Rules = @(
        @{ Name = "git_reset_hard"; Pattern = '(?i)git\s+reset\s+--hard' },
        @{ Name = "git_clean_force"; Pattern = '(?i)git\s+clean\s+-(?:[a-z]*f[a-z]*d|[a-z]*d[a-z]*f|[a-z]*f)\b' },
        @{ Name = "git_branch_delete_force"; Pattern = '(?i)git\s+branch\s+-D\b' },
        @{ Name = "git_checkout_all"; Pattern = '(?i)git\s+checkout\s+(?:--\s+)?[.]' },
        @{ Name = "git_restore_all"; Pattern = '(?i)git\s+restore\s+(?:--source\s+\S+\s+)?[.]' },
        @{ Name = "destructive_home_remove"; Pattern = "(?i)Remove-Item.*-Recurse.*-Force.*$HomeTargetPattern" },
        @{ Name = "destructive_root_rm"; Pattern = '(?i)rm\s+-rf\s+(/|~|\$HOME)' },
        @{ Name = "destructive_current_dir_rm"; Pattern = '(?i)\brm\s+-rf\s+(?:\.|\*)\b' },
        @{ Name = "windows_format"; Pattern = '(?i)\bformat\s+[A-Z]:' },
        @{ Name = "curl_pipe_shell"; Pattern = '(?i)\b(curl|wget|iwr|Invoke-WebRequest)\b.+\|\s*(bash|sh|pwsh|powershell|iex|Invoke-Expression)\b' },
        @{ Name = "encoded_command"; Pattern = '(?i)\b(powershell|pwsh)\b.+-(enc|encodedcommand)\b' },
        @{ Name = "base64_pipe_shell"; Pattern = '(?i)\bbase64\b.+\|\s*(bash|sh|pwsh|powershell)\b' },
        @{ Name = "chmod_private_key"; Pattern = '(?i)\bchmod\s+600\s+.*(?:id_rsa|id_ed25519|\.pem)\b' }
    )

    $Findings = @()
    foreach ($Rule in $Rules) {
        if ($NormalizedText -match $Rule.Pattern) {
            $Findings += $Rule.Name
        }
    }
    return @($Findings | Select-Object -Unique)
}

function Find-ApprovalRequiredSignals {
    param([string]$Text)

    $NormalizedText = $Text.Replace('\\', '\')
    $Rules = @(
        @{ Name = "git_push_force"; Pattern = '(?i)git\s+push\b.*--force(?:-with-lease)?' },
        @{ Name = "git_no_verify"; Pattern = '(?i)git\s+(commit|push)\b.*--no-verify' },
        @{ Name = "git_push"; Pattern = '(?i)git\s+push\b' },
        @{ Name = "package_publish"; Pattern = '(?i)\b(npm|pnpm|yarn)\s+publish\b|dotnet\s+nuget\s+push\b|twine\s+upload\b' },
        @{ Name = "deploy_command"; Pattern = '(?i)\b(vercel|netlify|firebase|supabase)\s+(deploy|functions\s+deploy|db\s+push)\b' },
        @{ Name = "gh_release"; Pattern = '(?i)\bgh\s+release\s+(create|upload|delete)\b' },
        @{ Name = "docker_push"; Pattern = '(?i)\bdocker\s+push\b' }
    )

    $Findings = @()
    foreach ($Rule in $Rules) {
        if ($NormalizedText -match $Rule.Pattern) {
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

function Write-Ask {
    param([string]$Reason)
    Write-Output (@{ decision = "ask"; reason = $Reason } | ConvertTo-Json -Compress)
}

$Cwd = Get-Cwd
$ScanText = if ($RawInput) { $RawInput } else { "" }
$SecretFindings = Find-SecretSignals -Text $ScanText
$DangerFindings = if ($Mode -eq "PreToolUse") { Find-DangerousToolSignals -Text $ScanText } else { @() }
$ApprovalFindings = if ($Mode -eq "PreToolUse") { Find-ApprovalRequiredSignals -Text $ScanText } else { @() }

if ($SecretFindings.Count -gt 0) {
    $Reason = "Srednoff OS v2.1.2 blocked a likely secret in $Mode input: " + ($SecretFindings -join ", ")
    Write-Ledger -Event $Mode -Cwd $Cwd -Decision "block" -Findings $SecretFindings -Reason "secret"
    Write-Block -Reason $Reason
    exit 0
}

if ($DangerFindings.Count -gt 0) {
    $Reason = "Srednoff OS v2.1.2 blocked a high-risk tool action: " + ($DangerFindings -join ", ")
    Write-Ledger -Event $Mode -Cwd $Cwd -Decision "block" -Findings $DangerFindings -Reason "deny"
    Write-Block -Reason $Reason
    exit 0
}

if ($ApprovalFindings.Count -gt 0) {
    $Reason = "Srednoff OS v2.1.2 requires explicit user confirmation before this externally visible or bypass-prone action: " + ($ApprovalFindings -join ", ")
    Write-Ledger -Event $Mode -Cwd $Cwd -Decision "ask" -Findings $ApprovalFindings -Reason "ask"
    Write-Ask -Reason $Reason
    exit 0
}

if ($Mode -eq "SessionStart") {
    $StatusScript = Join-Path $CodexHome "scripts\srednoff-os-status.ps1"
    try {
        $Status = & $StatusScript -ProjectPath $Cwd
    } catch {
        $Status = "Srednoff OS v2.1.2 loaded: WARN | status script failed: $($_.Exception.Message)"
    }
    Write-Ledger -Event $Mode -Cwd $Cwd -Decision "allow" -Findings @() -Reason "session_start"
    Write-HookContext -Event "SessionStart" -Context "$Status. Use the Srednoff OS selector before substantial work; keep the 4500-record kernel script-only."
    exit 0
}

Write-Ledger -Event $Mode -Cwd $Cwd -Decision "allow" -Findings @() -Reason "clean"

if ($Mode -eq "PreToolUse") {
    Write-HookContext -Event "PreToolUse" -Context "Srednoff OS v2.1.2 preflight passed: no high-confidence secrets or blocked destructive patterns detected."
}
