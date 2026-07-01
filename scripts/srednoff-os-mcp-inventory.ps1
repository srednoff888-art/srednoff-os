param(
    [string]$ConfigPath = "$HOME\.codex\config.toml",
    [string]$OutDir = "$HOME\.codex\srednoff-os",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

function Get-RiskForName {
    param([string]$Name, [string]$Kind)
    $Lower = $Name.ToLowerInvariant()
    if ($Lower -match "node_repl|browser|computer|shell|filesystem|supabase|vercel|github|gmail|drive") { return "high" }
    if ($Lower -match "figma|canva|hugging|notion|replit|convex|magic") { return "medium" }
    if ($Kind -eq "plugin") { return "medium" }
    return "unknown"
}

function Get-ScopeForName {
    param([string]$Name)
    $Lower = $Name.ToLowerInvariant()
    if ($Lower -match "node_repl") { return "code-execution" }
    if ($Lower -match "github") { return "repository" }
    if ($Lower -match "gmail") { return "email" }
    if ($Lower -match "drive") { return "documents" }
    if ($Lower -match "supabase") { return "database" }
    if ($Lower -match "vercel|netlify") { return "deployment" }
    if ($Lower -match "figma|canva|shutterstock") { return "design-assets" }
    if ($Lower -match "browser|magic") { return "browser-ui" }
    return "general"
}

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Config not found: $ConfigPath"
}

$Lines = Get-Content -LiteralPath $ConfigPath -Encoding UTF8
$Items = @()
$Current = $null

foreach ($Line in $Lines) {
    if ($Line -match '^\s*\[mcp_servers\.([^\]]+)\.env\]\s*$') {
        $Name = $Matches[1].Trim('"')
        $MatchItem = $Items | Where-Object { $_.kind -eq "mcp_server" -and $_.name -eq $Name } | Select-Object -Last 1
        if ($MatchItem) { $MatchItem.has_env = $true }
        $Current = $MatchItem
        continue
    }

    if ($Line -match '^\s*\[mcp_servers\.([^\]]+)\]\s*$') {
        $Name = $Matches[1].Trim('"')
        if ($Name -match '\.env$') { continue }
        $Current = [pscustomobject]@{
            kind = "mcp_server"
            name = $Name
            enabled = $true
            scope = Get-ScopeForName -Name $Name
            risk = Get-RiskForName -Name $Name -Kind "mcp_server"
            command = $null
            has_env = $false
        }
        $Items += $Current
        continue
    }

    if ($Line -match '^\s*\[plugins\."([^"]+)"\]\s*$') {
        $Name = $Matches[1]
        $Current = [pscustomobject]@{
            kind = "plugin"
            name = $Name
            enabled = $null
            scope = Get-ScopeForName -Name $Name
            risk = Get-RiskForName -Name $Name -Kind "plugin"
            command = $null
            has_env = $false
        }
        $Items += $Current
        continue
    }

    if ($Current -and $Line -match '^\s*command\s*=\s*[''"]([^''"]+)[''"]') {
        $Current.command = $Matches[1]
    }

    if ($Current -and $Line -match '^\s*enabled\s*=\s*(true|false)') {
        $Current.enabled = [bool]::Parse($Matches[1])
    }
}

$Result = [ordered]@{
    name = "Srednoff OS MCP trust inventory"
    version = "v2.1.1"
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    config = $ConfigPath
    items = @($Items)
    summary = [ordered]@{
        total = @($Items).Count
        high_risk = @($Items | Where-Object { $_.risk -eq "high" }).Count
        medium_risk = @($Items | Where-Object { $_.risk -eq "medium" }).Count
    }
    guardrails = @(
        "Prefer read-only connector scopes by default.",
        "Require explicit user approval for destructive, paid, production, email-send, billing, DNS, deployment, and credential-changing actions.",
        "Do not log env values, OAuth tokens, cookies, private keys, or personal data."
    )
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$OutFile = Join-Path $OutDir "mcp-inventory.json"
$Result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutFile -Encoding UTF8

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS MCP inventory: $($Result.summary.total) entries | high=$($Result.summary.high_risk) | medium=$($Result.summary.medium_risk)"
    Write-Output "Saved: $OutFile"
}
