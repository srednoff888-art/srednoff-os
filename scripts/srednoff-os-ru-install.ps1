param(
    [string]$CandidateId = "",
    [string]$ProjectPath = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$RegistryRoot = Join-Path $Root "registry\neuraldeep"
if (-not (Test-Path -LiteralPath $RegistryRoot -PathType Container)) { throw "Missing registry: $RegistryRoot" }

$Matches = New-Object System.Collections.Generic.List[object]
foreach ($CatalogFile in @("skills.json", "mcp.json", "cli.json")) {
    $Path = Join-Path $RegistryRoot $CatalogFile
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { continue }
    $Catalog = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($Item in @($Catalog.items)) {
        if (-not $CandidateId -or ([string]$Item.id) -eq $CandidateId) {
            $Matches.Add([pscustomobject]@{
                id = $Item.id
                catalog = $CatalogFile
                kind = $Item.kind
                status = $Item.status
                enabled = [bool]$Item.enabled
                auto_install = [bool]$Item.auto_install
                risk_level = $Item.risk_level
                license = $Item.license
                source_url = $Item.source_url
            }) | Out-Null
        }
    }
}

$Result = [ordered]@{
    name = "Srednoff OS RU install wrapper"
    version = "v2.1.2"
    project = $Root
    mode = "blocked-without-confirmation"
    executed = $false
    candidate_id = $CandidateId
    matches = @($Matches.ToArray())
    required_before_install = @(
        "source_provenance_review",
        "license_review",
        "tool_permission_review",
        "prompt_injection_review",
        "secret_exfiltration_review",
        "human_install_confirmation"
    )
    message = "This wrapper never installs automatically. Use it to inspect candidates and decide whether a separate human-approved install step is justified."
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS RU install wrapper: blocked-without-confirmation"
    Write-Output "executed: False"
    $Matches | Format-Table id, catalog, kind, risk_level, license, enabled, auto_install -AutoSize
}

