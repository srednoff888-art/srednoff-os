param(
    [string]$Query = "",
    [string]$ProjectPath = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$BundlesRoot = Join-Path $Root "bundles"
$AgentsRoot = Join-Path $Root "agents"

foreach ($Path in @($BundlesRoot, $AgentsRoot)) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Missing RU search dependency: $Path"
    }
}

$LowerQuery = $Query.ToLowerInvariant()
$Results = New-Object System.Collections.Generic.List[object]

Get-ChildItem -LiteralPath $BundlesRoot -Filter "ru-*.json" -File | ForEach-Object {
    $Data = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    $Haystack = (@($Data.id, $Data.title) + @($Data.domains) + @($Data.policy_gates) + @($Data.recommended_skills)) -join " "
    if (-not $Query -or $Haystack.ToLowerInvariant().Contains($LowerQuery)) {
        $Results.Add([pscustomobject]@{
            kind = "bundle"
            id = $Data.id
            title = $Data.title
            file = $_.FullName
            default_enabled = [bool]$Data.default_enabled
            policy_gates = @($Data.policy_gates)
        }) | Out-Null
    }
}

$IndexPath = Join-Path $AgentsRoot "index.json"
if (Test-Path -LiteralPath $IndexPath -PathType Leaf) {
    $Index = Get-Content -LiteralPath $IndexPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($Agent in @($Index.agents)) {
        $AgentPath = Join-Path $AgentsRoot ([string]$Agent.file)
        if (-not (Test-Path -LiteralPath $AgentPath -PathType Leaf)) { continue }
        $Text = Get-Content -LiteralPath $AgentPath -Raw -Encoding UTF8
        if (-not $Query -or $Text.ToLowerInvariant().Contains($LowerQuery) -or ([string]$Agent.id).ToLowerInvariant().Contains($LowerQuery)) {
            $Results.Add([pscustomobject]@{
                kind = "agent"
                id = $Agent.id
                bundle = $Agent.bundle
                file = $AgentPath
                default_enabled = [bool]$Index.default_enabled
                policy_gates = @()
            }) | Out-Null
        }
    }
}

$Result = [ordered]@{
    name = "Srednoff OS RU search"
    version = "v2.1.2"
    query = $Query
    project = $Root
    mode = "read-only"
    count = $Results.Count
    results = @($Results.ToArray())
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS RU search: matches=$($Results.Count)"
    $Results | Format-Table kind, id, bundle, default_enabled -AutoSize
}

