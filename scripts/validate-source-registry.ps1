param(
    [string]$RegistryPath = ".\.codex\srednoff-os\design-source-registry.json",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

function Add-Issue {
    param(
        [System.Collections.Generic.List[object]]$Issues,
        [string]$Id,
        [string]$Field,
        [string]$Message
    )

    $Issues.Add([pscustomobject]@{
        id = $Id
        field = $Field
        message = $Message
    }) | Out-Null
}

if (-not (Test-Path -LiteralPath $RegistryPath -PathType Leaf)) {
    throw "source registry not found: $RegistryPath"
}

$Registry = Get-Content -LiteralPath $RegistryPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Sources = @($Registry.sources)
$Issues = New-Object System.Collections.Generic.List[object]
$RequiredFields = @(
    "id",
    "name",
    "url",
    "kind",
    "domains",
    "risk",
    "license",
    "provenance",
    "vetted",
    "copy_policy",
    "use_when",
    "requires_user_prompt"
)

if (-not $Registry.version) {
    Add-Issue -Issues $Issues -Id "registry" -Field "version" -Message "missing registry version"
}
if ($Sources.Count -eq 0) {
    Add-Issue -Issues $Issues -Id "registry" -Field "sources" -Message "registry has no sources"
}

$Ids = @{}
foreach ($Source in $Sources) {
    $Id = [string]$Source.id
    if (-not $Id) { $Id = "<missing-id>" }

    if ($Ids.ContainsKey($Id)) {
        Add-Issue -Issues $Issues -Id $Id -Field "id" -Message "duplicate source id"
    } else {
        $Ids[$Id] = $true
    }

    foreach ($Field in $RequiredFields) {
        $Property = $Source.PSObject.Properties[$Field]
        if (-not $Property) {
            Add-Issue -Issues $Issues -Id $Id -Field $Field -Message "missing required field"
            continue
        }

        $Value = $Property.Value
        if ($null -eq $Value) {
            Add-Issue -Issues $Issues -Id $Id -Field $Field -Message "field is null"
        } elseif ($Value -is [string] -and -not $Value.Trim()) {
            Add-Issue -Issues $Issues -Id $Id -Field $Field -Message "field is empty"
        } elseif ($Field -in @("domains", "use_when") -and @($Value).Count -eq 0) {
            Add-Issue -Issues $Issues -Id $Id -Field $Field -Message "array is empty"
        }
    }

    if ($Source.risk -and (@("low", "medium", "high") -notcontains [string]$Source.risk)) {
        Add-Issue -Issues $Issues -Id $Id -Field "risk" -Message "risk must be low, medium, or high"
    }

    if ([string]$Source.risk -eq "high" -and -not [bool]$Source.requires_user_prompt) {
        Add-Issue -Issues $Issues -Id $Id -Field "requires_user_prompt" -Message "high-risk sources must require user prompt"
    }

    if ($Source.PSObject.Properties["vetted"] -and $Source.vetted -isnot [bool]) {
        Add-Issue -Issues $Issues -Id $Id -Field "vetted" -Message "vetted must be boolean"
    }
}

$IssueItems = @($Issues.ToArray())
$Result = [ordered]@{
    name = "Srednoff OS source registry validator"
    version = "v2.1.2"
    registry = $RegistryPath
    sources = $Sources.Count
    issues = $IssueItems.Count
    details = $IssueItems
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    if ($IssueItems.Count -eq 0) {
        Write-Output "source registry ok: sources=$($Sources.Count)"
    } else {
        Write-Output "source registry FAIL: issues=$($IssueItems.Count)"
        $IssueItems | Format-Table id, field, message -AutoSize
    }
}

if ($IssueItems.Count -gt 0) { exit 1 }
