param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$AgentsRoot = Join-Path $Root "agents"
$IndexPath = Join-Path $AgentsRoot "index.json"
$BundlesRoot = Join-Path $Root "bundles"
$PoliciesRoot = Join-Path $Root "policies"
$SkillsRoot = Join-Path $Root ".codex\skills"

foreach ($Path in @($AgentsRoot, $IndexPath, $BundlesRoot, $PoliciesRoot, $SkillsRoot)) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Missing agent test dependency: $Path" }
}

$RequiredAgents = @(
    "ru-seo-agent",
    "ru-marketplaces-agent",
    "ru-1c-agent",
    "ru-enterprise-agent",
    "ru-llm-agent",
    "ru-content-agent",
    "ru-payments-agent",
    "ru-messaging-agent"
)

$Index = Get-Content -LiteralPath $IndexPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ([bool]$Index.default_enabled) { throw "Agent index default_enabled must be false" }
$IndexAgentIds = @($Index.agents | ForEach-Object { $_.id })
$MissingAgents = @($RequiredAgents | Where-Object { $IndexAgentIds -notcontains $_ })
if ($MissingAgents.Count -gt 0) { throw "Missing agents in index: $($MissingAgents -join ',')" }

$BundleIds = @(Get-ChildItem -LiteralPath $BundlesRoot -Filter *.json -File | Where-Object { $_.BaseName -ne "index" } | ForEach-Object { $_.BaseName })
$PolicyIds = @(Get-ChildItem -LiteralPath $PoliciesRoot -Filter *.yml -File | Where-Object { $_.BaseName -ne "index" } | ForEach-Object { $_.BaseName })

$SkillNames = New-Object 'System.Collections.Generic.HashSet[string]'
Get-ChildItem -LiteralPath $SkillsRoot -Recurse -Filter SKILL.md -File | ForEach-Object {
    $Head = Get-Content -LiteralPath $_.FullName -Encoding UTF8 -TotalCount 12
    $NameLine = $Head | Where-Object { $_ -match '^\s*name\s*:' } | Select-Object -First 1
    if ($NameLine -match '^\s*name\s*:\s*["'']?([^"'']+)["'']?\s*$') {
        [void]$SkillNames.Add($Matches[1].Trim())
    }
}

function Get-FrontMatterValue {
    param(
        [string[]]$Lines,
        [string]$Key
    )
    $Pattern = "^\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$"
    $Line = $Lines | Where-Object { $_ -match $Pattern } | Select-Object -First 1
    if ($Line -match $Pattern) { return $Matches[1].Trim() }
    return ""
}

function Get-FrontMatterList {
    param(
        [string[]]$Lines,
        [string]$Key
    )
    $Values = New-Object System.Collections.Generic.List[string]
    $InList = $false
    foreach ($Line in $Lines) {
        if ($InList -and $Line -match '^---\s*$') { break }
        if ($Line -match "^\s*$([regex]::Escape($Key))\s*:\s*$") {
            $InList = $true
            continue
        }
        if ($InList -and $Line -match '^\s*-\s*(.+?)\s*$') {
            $Values.Add($Matches[1].Trim()) | Out-Null
            continue
        }
        if ($InList -and $Line -match '^\S') { break }
    }
    return @($Values.ToArray())
}

$Passed = 0
foreach ($AgentId in $RequiredAgents) {
    $Entry = $Index.agents | Where-Object { $_.id -eq $AgentId } | Select-Object -First 1
    $AgentPath = Join-Path $AgentsRoot ([string]$Entry.file)
    if (-not (Test-Path -LiteralPath $AgentPath -PathType Leaf)) { throw "Missing agent file: $AgentId" }

    $Text = Get-Content -LiteralPath $AgentPath -Raw -Encoding UTF8
    if ($Text -match 'sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9_]{20,}|-----BEGIN [A-Z ]+PRIVATE KEY-----') {
        throw "Secret-like pattern in agent file: $AgentId"
    }
    if ($Text -notmatch '(?i)confirmation|confirmation-gated|ask before|do not|never') {
        throw "Agent $AgentId missing confirmation guardrail"
    }

    $Lines = $Text -split "`r?`n"
    $Schema = Get-FrontMatterValue -Lines $Lines -Key "schema"
    $DefaultEnabled = Get-FrontMatterValue -Lines $Lines -Key "default_enabled"
    $Bundle = Get-FrontMatterValue -Lines $Lines -Key "bundle"
    $PolicyGates = Get-FrontMatterList -Lines $Lines -Key "policy_gates"
    $RecommendedSkills = Get-FrontMatterList -Lines $Lines -Key "recommended_skills"

    if ($Schema -ne "srednoff-os.agent-profile.v1") { throw "Agent $AgentId schema mismatch" }
    if ($DefaultEnabled -ne "false") { throw "Agent $AgentId default_enabled must be false" }
    if ($BundleIds -notcontains $Bundle) { throw "Agent $AgentId references missing bundle: $Bundle" }
    $MissingPolicies = @($PolicyGates | Where-Object { $PolicyIds -notcontains $_ })
    if ($MissingPolicies.Count -gt 0) { throw "Agent $AgentId references missing policies: $($MissingPolicies -join ',')" }
    $MissingSkills = @($RecommendedSkills | Where-Object { -not $SkillNames.Contains([string]$_) })
    if ($MissingSkills.Count -gt 0) { throw "Agent $AgentId references missing skills: $($MissingSkills -join ',')" }
    $Passed++
}

Write-Output "Srednoff OS agent evals passed: $Passed/$($RequiredAgents.Count)"
