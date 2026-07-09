param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,
    [string]$RegistryRoot = "registry\neuraldeep",
    [string]$ReportPath = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$AllowedLicenses = @(
    "MIT",
    "Apache-2.0",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "ISC",
    "MPL-2.0",
    "Unlicense",
    "CC0-1.0"
)

$BlockedPatterns = @(
    'sk-[A-Za-z0-9_-]{16,}',
    'gh[pousr]_[A-Za-z0-9_]{20,}',
    '-----BEGIN [A-Z ]+PRIVATE KEY-----'
)

function Resolve-RequiredFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing file: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Resolve-RequiredDirectory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Missing directory: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Read-JsonFile {
    param([string]$Path)
    $Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    foreach ($Pattern in $BlockedPatterns) {
        if ($Text -match $Pattern) {
            throw "Blocked secret-like pattern in $Path"
        }
    }
    return $Text | ConvertFrom-Json
}

function Write-JsonFile {
    param(
        [string]$Path,
        [object]$Data
    )
    $Json = $Data | ConvertTo-Json -Depth 12
    Set-Content -LiteralPath $Path -Value $Json -Encoding UTF8
}

function Normalize-Id {
    param([string]$Value)
    $Id = ([string]$Value).Trim().ToLowerInvariant()
    $Id = [regex]::Replace($Id, '[^a-z0-9._-]+', '-')
    $Id = [regex]::Replace($Id, '-{2,}', '-')
    return $Id.Trim("-")
}

function Get-CatalogName {
    param([string]$Kind)
    $NormalizedKind = ([string]$Kind).Trim().ToLowerInvariant()
    switch ($NormalizedKind) {
        "skill" { return "skills" }
        "agent" { return "skills" }
        "mcp" { return "mcp" }
        "mcp-server" { return "mcp" }
        "cli" { return "cli" }
        "cli-tool" { return "cli" }
        default { return "" }
    }
}

function Get-OutputKind {
    param([string]$Kind)
    $CatalogName = Get-CatalogName -Kind $Kind
    if ($CatalogName -eq "skills") {
        if (([string]$Kind).Trim().ToLowerInvariant() -eq "agent") { return "agent" }
        return "skill"
    }
    if ($CatalogName -eq "mcp") { return "mcp-server" }
    if ($CatalogName -eq "cli") { return "cli-tool" }
    return ""
}

function Get-RiskLevel {
    param([string]$CatalogName)
    switch ($CatalogName) {
        "skills" { return "medium" }
        "mcp" { return "high" }
        "cli" { return "high" }
        default { return "high" }
    }
}

function Get-PolicyGates {
    param([string]$CatalogName)
    $Gates = New-Object System.Collections.Generic.List[string]
    $Gates.Add("neuraldeep") | Out-Null
    $Gates.Add("source_provenance_review") | Out-Null
    $Gates.Add("license_review") | Out-Null
    if ($CatalogName -eq "mcp" -or $CatalogName -eq "cli") {
        $Gates.Add("tool_permission_review") | Out-Null
        $Gates.Add("prompt_injection_review") | Out-Null
    }
    $Gates.Add("human_install_confirmation") | Out-Null
    return @($Gates.ToArray())
}

function Get-TrustScore {
    param(
        [object]$Item,
        [string]$CatalogName,
        [bool]$LicenseAllowed
    )
    $Score = 0
    if ($LicenseAllowed) { $Score += 25 }
    if (([string]$Item.source_url) -match '^https://') { $Score += 20 }
    if (([string]$Item.provenance).Length -ge 24) { $Score += 20 }
    if (([string]$Item.repo_url) -match '^https://github\.com/[^/]+/[^/]+') { $Score += 15 }
    if (-not ($Item.PSObject.Properties.Name -contains "install_command")) { $Score += 10 }
    if ($CatalogName -eq "skills") { $Score += 10 }
    if ($Score -gt 100) { return 100 }
    return $Score
}

function New-Rejection {
    param(
        [string]$Id,
        [string]$Kind,
        [string]$Reason
    )
    return [pscustomobject]@{
        id = $Id
        kind = $Kind
        decision = "rejected"
        reason = $Reason
    }
}

$InputFile = Resolve-RequiredFile -Path $InputPath
$RegistryDirectory = Resolve-RequiredDirectory -Path $RegistryRoot
$Manifest = Read-JsonFile -Path $InputFile

if (-not ($Manifest.PSObject.Properties.Name -contains "items")) {
    throw "Manifest must contain items"
}

$CatalogPaths = @{
    skills = Join-Path $RegistryDirectory "skills.json"
    mcp = Join-Path $RegistryDirectory "mcp.json"
    cli = Join-Path $RegistryDirectory "cli.json"
}

$Catalogs = @{}
foreach ($Name in $CatalogPaths.Keys) {
    $Catalogs[$Name] = Read-JsonFile -Path $CatalogPaths[$Name]
}

$ExistingKeys = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($CatalogName in $Catalogs.Keys) {
    foreach ($ExistingItem in @($Catalogs[$CatalogName].items)) {
        [void]$ExistingKeys.Add("$CatalogName|$($ExistingItem.id)")
    }
}

$SeenKeys = New-Object 'System.Collections.Generic.HashSet[string]'
$Imported = New-Object System.Collections.Generic.List[object]
$Rejected = New-Object System.Collections.Generic.List[object]
$Duplicates = New-Object System.Collections.Generic.List[object]

foreach ($RawItem in @($Manifest.items)) {
    $Id = Normalize-Id -Value $RawItem.id
    $CatalogName = Get-CatalogName -Kind $RawItem.kind
    $InputKind = ([string]$RawItem.kind).Trim().ToLowerInvariant()

    if (-not $Id) {
        $Rejected.Add((New-Rejection -Id ([string]$RawItem.id) -Kind $InputKind -Reason "missing_or_invalid_id")) | Out-Null
        continue
    }
    if (-not $CatalogName) {
        $Rejected.Add((New-Rejection -Id $Id -Kind $InputKind -Reason "unsupported_kind")) | Out-Null
        continue
    }

    $Key = "$CatalogName|$Id"
    if ($ExistingKeys.Contains($Key) -or -not $SeenKeys.Add($Key)) {
        $Duplicates.Add([pscustomobject]@{
            id = $Id
            kind = $InputKind
            decision = "duplicate"
            reason = "already_present_or_repeated"
        }) | Out-Null
        continue
    }

    $License = ([string]$RawItem.license).Trim()
    $LicenseAllowed = $AllowedLicenses -contains $License
    if (-not $LicenseAllowed) {
        $Rejected.Add((New-Rejection -Id $Id -Kind $InputKind -Reason "license_not_allowlisted")) | Out-Null
        continue
    }
    if (-not ([string]$RawItem.source_url -match '^https://')) {
        $Rejected.Add((New-Rejection -Id $Id -Kind $InputKind -Reason "source_url_must_be_https")) | Out-Null
        continue
    }
    if (-not ([string]$RawItem.provenance).Trim()) {
        $Rejected.Add((New-Rejection -Id $Id -Kind $InputKind -Reason "missing_provenance")) | Out-Null
        continue
    }

    $TrustScore = Get-TrustScore -Item $RawItem -CatalogName $CatalogName -LicenseAllowed $LicenseAllowed
    $Candidate = [ordered]@{
        id = $Id
        name = if ($RawItem.name) { [string]$RawItem.name } else { $Id }
        source_url = [string]$RawItem.source_url
        kind = Get-OutputKind -Kind $InputKind
        status = "candidate-imported-disabled"
        enabled = $false
        auto_install = $false
        risk_level = Get-RiskLevel -CatalogName $CatalogName
        license = $License
        provenance = [string]$RawItem.provenance
        policy_gates = Get-PolicyGates -CatalogName $CatalogName
        trust_score = $TrustScore
        imported_by = "srednoff-os-neuraldeep-importer"
    }
    if ($RawItem.PSObject.Properties.Name -contains "repo_url" -and $RawItem.repo_url) {
        $Candidate.repo_url = [string]$RawItem.repo_url
    }
    if ($RawItem.PSObject.Properties.Name -contains "description" -and $RawItem.description) {
        $Candidate.description = [string]$RawItem.description
    }

    $Catalogs[$CatalogName].items += [pscustomobject]$Candidate
    $ExistingKeys.Add($Key) | Out-Null
    $Imported.Add([pscustomobject]@{
        id = $Id
        catalog = $CatalogName
        decision = "imported-disabled"
        trust_score = $TrustScore
    }) | Out-Null
}

$Timestamp = (Get-Date).ToUniversalTime().ToString("o")
$Report = [ordered]@{
    schema = "srednoff-os.neuraldeep.import-report.v1"
    generated_at = $Timestamp
    input = $InputFile
    dry_run = [bool]$DryRun
    summary = [ordered]@{
        imported = $Imported.Count
        rejected = $Rejected.Count
        duplicates = $Duplicates.Count
    }
    imported = @($Imported.ToArray())
    rejected = @($Rejected.ToArray())
    duplicates = @($Duplicates.ToArray())
}

if (-not $DryRun) {
    foreach ($Name in $CatalogPaths.Keys) {
        Write-JsonFile -Path $CatalogPaths[$Name] -Data $Catalogs[$Name]
    }

    $ImportLogPath = Join-Path $RegistryDirectory "import-log.json"
    $ImportLog = Read-JsonFile -Path $ImportLogPath
    $ImportLog.events += [pscustomobject]@{
        ts = $Timestamp
        event = "controlled-import"
        decision = "metadata-only-disabled"
        details = "imported=$($Imported.Count); rejected=$($Rejected.Count); duplicates=$($Duplicates.Count)"
    }
    Write-JsonFile -Path $ImportLogPath -Data $ImportLog
}

if ($ReportPath) {
    $ReportFullPath = $ReportPath
    if (-not [System.IO.Path]::IsPathRooted($ReportFullPath)) {
        $ReportFullPath = Join-Path (Get-Location).Path $ReportFullPath
    }
    $ReportDirectory = Split-Path -Parent $ReportFullPath
    if ($ReportDirectory -and -not (Test-Path -LiteralPath $ReportDirectory -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $ReportDirectory | Out-Null
    }
    Write-JsonFile -Path $ReportFullPath -Data $Report
}

$Report | ConvertTo-Json -Depth 12

