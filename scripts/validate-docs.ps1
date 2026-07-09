param(
    [string]$DocsRoot = ".\docs",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

function Add-Issue {
    param(
        [System.Collections.Generic.List[object]]$Issues,
        [string]$File,
        [string]$Message
    )

    $Issues.Add([pscustomobject]@{
        file = $File
        message = $Message
    }) | Out-Null
}

$Issues = New-Object System.Collections.Generic.List[object]
$RequiredDocs = @(
    "README.md",
    "architecture.md",
    "security.md",
    "workflows.md",
    "profiles.md",
    "ru-and-neuraldeep.md",
    "risk-model.md",
    "validation.md"
)

if (-not (Test-Path -LiteralPath $DocsRoot -PathType Container)) {
    throw "docs root not found: $DocsRoot"
}

foreach ($Doc in $RequiredDocs) {
    $Path = Join-Path $DocsRoot $Doc
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-Issue -Issues $Issues -File $Doc -Message "required doc missing"
        continue
    }

    $Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if (-not $Text.Trim()) {
        Add-Issue -Issues $Issues -File $Doc -Message "doc is empty"
    }
    if ($Text -match "[\x00-\x08\x0B\x0C\x0E-\x1F]") {
        Add-Issue -Issues $Issues -File $Doc -Message "doc contains control characters"
    }
    if ($Text -match "TODO|TBD") {
        Add-Issue -Issues $Issues -File $Doc -Message "doc contains unresolved TODO/TBD marker"
    }
}

$IndexPath = Join-Path $DocsRoot "README.md"
if (Test-Path -LiteralPath $IndexPath -PathType Leaf) {
    $IndexText = Get-Content -LiteralPath $IndexPath -Raw -Encoding UTF8
    foreach ($Doc in $RequiredDocs | Where-Object { $_ -ne "README.md" }) {
        if ($IndexText -notmatch [regex]::Escape("]($Doc)")) {
            Add-Issue -Issues $Issues -File "README.md" -Message "index does not link $Doc"
        }
    }
}

$IssueItems = @($Issues.ToArray())
$Result = [ordered]@{
    name = "Srednoff OS docs validator"
    version = "v2.1.2"
    docs_root = $DocsRoot
    docs = $RequiredDocs.Count
    issues = $IssueItems.Count
    details = $IssueItems
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 6
} else {
    if ($IssueItems.Count -eq 0) {
        Write-Output "docs ok: files=$($RequiredDocs.Count)"
    } else {
        Write-Output "docs FAIL: issues=$($IssueItems.Count)"
        $IssueItems | Format-Table file, message -AutoSize
    }
}

if ($IssueItems.Count -gt 0) { exit 1 }
