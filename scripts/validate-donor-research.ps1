param(
    [string]$ManifestPath = ".\.codex\srednoff-os\donor-research.json",
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

if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "donor research manifest not found: $ManifestPath"
}

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Sources = @($Manifest.sources)
$Issues = New-Object System.Collections.Generic.List[object]
$RequiredSourceFields = @(
    "id",
    "url",
    "owner",
    "repo",
    "type",
    "license",
    "stars_at_review",
    "forks_at_review",
    "pushed_at",
    "risk",
    "decision",
    "accepted_patterns",
    "rejected_patterns",
    "notes"
)

if (-not $Manifest.version) {
    Add-Issue -Issues $Issues -Id "manifest" -Field "version" -Message "missing manifest version"
}

if (-not $Manifest.reviewed_at) {
    Add-Issue -Issues $Issues -Id "manifest" -Field "reviewed_at" -Message "missing review date"
}

if (-not $Manifest.policy) {
    Add-Issue -Issues $Issues -Id "manifest" -Field "policy" -Message "missing policy block"
} else {
    if ([bool]$Manifest.policy.copy_prompt_text) {
        Add-Issue -Issues $Issues -Id "manifest" -Field "policy.copy_prompt_text" -Message "prompt text copying must be disabled"
    }
    if ([bool]$Manifest.policy.copy_unvetted_code) {
        Add-Issue -Issues $Issues -Id "manifest" -Field "policy.copy_unvetted_code" -Message "unvetted code copying must be disabled"
    }
    $RequiredGates = @("license_review", "provenance_review", "claimed_leak_quarantine", "verbatim_prompt_rejection", "selector_fixture", "doctor_check")
    $Gates = @($Manifest.policy.required_gates)
    foreach ($Gate in $RequiredGates) {
        if ($Gates -notcontains $Gate) {
            Add-Issue -Issues $Issues -Id "manifest" -Field "policy.required_gates" -Message "missing gate: $Gate"
        }
    }
}

if ($Sources.Count -lt 3) {
    Add-Issue -Issues $Issues -Id "manifest" -Field "sources" -Message "expected at least three donor sources"
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

    foreach ($Field in $RequiredSourceFields) {
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
        } elseif ($Field -in @("accepted_patterns", "rejected_patterns") -and @($Value).Count -eq 0) {
            Add-Issue -Issues $Issues -Id $Id -Field $Field -Message "array is empty"
        }
    }

    if ($Source.url -and ([string]$Source.url -notmatch '^https://github\.com/[^/]+/[^/]+$')) {
        Add-Issue -Issues $Issues -Id $Id -Field "url" -Message "url must be a GitHub repository URL"
    }

    if ($Source.type -match "leak" -and [string]$Source.decision -notmatch "monitor|taxonomy|analysis|adapt") {
        Add-Issue -Issues $Issues -Id $Id -Field "decision" -Message "claimed leak sources must use a quarantined decision"
    }

    $Rejected = @($Source.rejected_patterns)
    if ($Rejected -notcontains "verbatim-system-prompt-text" -and $Rejected -notcontains "compiled-leaked-prompt-text" -and $Rejected -notcontains "archived-vendor-prompt-content") {
        Add-Issue -Issues $Issues -Id $Id -Field "rejected_patterns" -Message "must explicitly reject prompt text reuse"
    }
}

$IssueItems = @($Issues.ToArray())
$Result = [ordered]@{
    name = "Srednoff OS donor research validator"
    version = "v2.1.2"
    manifest = $ManifestPath
    sources = $Sources.Count
    issues = $IssueItems.Count
    details = $IssueItems
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    if ($IssueItems.Count -eq 0) {
        Write-Output "donor research ok: sources=$($Sources.Count)"
    } else {
        Write-Output "donor research FAIL: issues=$($IssueItems.Count)"
        $IssueItems | Format-Table id, field, message -AutoSize
    }
}

if ($IssueItems.Count -gt 0) { exit 1 }
