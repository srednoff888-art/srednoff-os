param(
    [string]$ProjectPath = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path -LiteralPath (Join-Path $ScriptDir "..")).Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
if (-not $ProjectPath -or $ProjectPath -eq "<project-path>") {
    $ProjectPath = $PackageRoot
}

function Resolve-LocalOrHomeScript {
    param([string]$Name)
    $Local = Join-Path $ScriptDir $Name
    if (Test-Path -LiteralPath $Local -PathType Leaf) { return $Local }
    return (Join-Path $CodexHome "scripts\$Name")
}

$Selector = Resolve-LocalOrHomeScript "select-quality-cost-capabilities.ps1"
$SourceRanker = Resolve-LocalOrHomeScript "srednoff-os-source-ranker.ps1"
$DesignBrief = Resolve-LocalOrHomeScript "srednoff-os-design-brief.ps1"
$DomainRouter = Resolve-LocalOrHomeScript "srednoff-os-domain-router.ps1"
$LocalRegistry = Join-Path $PackageRoot ".codex\srednoff-os\design-source-registry.json"
$HomeRegistry = Join-Path $CodexHome "srednoff-os\design-source-registry.json"
$Registry = if (Test-Path -LiteralPath $LocalRegistry -PathType Leaf) { $LocalRegistry } else { $HomeRegistry }

function Add-Result {
    param([string]$Id, [bool]$Passed, [string]$Detail)
    [pscustomobject]@{ id = $Id; passed = $Passed; detail = $Detail }
}

$Results = @()

$SelectorOut = & $Selector -ProjectPath $ProjectPath -Brief "source ranking UI kits 3D assets design brief selector ROI per token" -Budget deep -Max 16 -Format ids | Out-String
$Results += Add-Result -Id "selector:v212-skills" -Passed (($SelectorOut -match "source-ranking-roi-selector") -and ($SelectorOut -match "design-brief-autogenerator")) -Detail (($SelectorOut -replace "\s+", " ").Trim())
$Results += Add-Result -Id "selector:legacy-plus-output" -Passed (($SelectorOut -match "Capability IDs") -and ($SelectorOut -match "token-saving") -and ($SelectorOut -match "balanced-value|heavyweight-result")) -Detail "legacy ids output retained"

$Rank3D = & $SourceRanker -ProjectPath $ProjectPath -Brief "optimize glTF GLB model texture asset pipeline" -Json | ConvertFrom-Json
$Top3D = @($Rank3D.ranked_sources)[0]
$Results += Add-Result -Id "source-ranker:gltf-transform-top" -Passed ($Top3D.id -eq "gltf-transform") -Detail "top=$($Top3D.id); score=$($Top3D.score)"

$RankUI = & $SourceRanker -ProjectPath $ProjectPath -Brief "rank UI kits for shadcn landing with 21st.dev and Magic UI" -Json | ConvertFrom-Json
$TopUiIds = @($RankUI.ranked_sources | Select-Object -First 3 | ForEach-Object { $_.id })
$Results += Add-Result -Id "source-ranker:ui-kit-top3" -Passed (($TopUiIds -contains "shadcn-registry") -or ($TopUiIds -contains "21st-dev")) -Detail "top3=$($TopUiIds -join ',')"

$RankResearch = & $SourceRanker -ProjectPath $ProjectPath -Brief "daily research skills agents selectors source ranking design brief all domains" -Json | ConvertFrom-Json
$False3DReasons = @($RankResearch.ranked_sources | Where-Object { @($_.reasons) -contains "3d-asset-fit" })
$Results += Add-Result -Id "source-ranker:no-ar-substring-false-3d" -Passed ($False3DReasons.Count -eq 0) -Detail "false_3d_reasons=$($False3DReasons.Count)"

$RankReactBits = & $SourceRanker -ProjectPath $ProjectPath -Brief "compare React Bits animated components for a landing page" -Json | ConvertFrom-Json
$ReactBitsSource = @($RankReactBits.ranked_sources | Where-Object { $_.id -eq "react-bits" } | Select-Object -First 1)
$Results += Add-Result -Id "source-ranker:normalized-named-source" -Passed ($ReactBitsSource.Count -gt 0 -and (@($ReactBitsSource[0].reasons) -contains "named:react bits")) -Detail "react_bits_reasons=$(@($ReactBitsSource[0].reasons) -join ',')"

$BriefSparse = & $DesignBrief -ProjectPath $ProjectPath -Brief "make 3D web landing" -Json | ConvertFrom-Json
$Results += Add-Result -Id "design-brief:sparse-asks" -Passed ([bool]$BriefSparse.should_ask_user -and @($BriefSparse.questions).Count -gt 0) -Detail "questions=$(@($BriefSparse.questions).Count)"

$BriefEnough = & $DesignBrief -ProjectPath $ProjectPath -Brief "make premium SaaS landing for CTO users with shadcn" -Json | ConvertFrom-Json
$Results += Add-Result -Id "design-brief:sufficient-brief" -Passed (-not [bool]$BriefEnough.should_ask_user) -Detail "ask_user=$($BriefEnough.should_ask_user); questions=$(@($BriefEnough.questions).Count)"

$DomainOut = & $DomainRouter -ProjectPath $ProjectPath -Brief "UI/UX 3D web design source ranking with 21st.dev and glTF assets" -Json | ConvertFrom-Json
$SkillPacks = @($DomainOut.skill_packs)
$Results += Add-Result -Id "domain-router:v212-packs" -Passed (($SkillPacks -contains "source-ranking-roi-selector") -and ($SkillPacks -contains "design-brief-autogenerator")) -Detail "packs=$($SkillPacks -join ',')"
$Results += Add-Result -Id "domain-router:helper-scripts" -Passed (($DomainOut.helper_scripts.source_ranker -match "source-ranker") -and ($DomainOut.helper_scripts.design_brief -match "design-brief")) -Detail "helpers ok"

$RegistryData = Get-Content -LiteralPath $Registry -Raw -Encoding UTF8 | ConvertFrom-Json
$SourceIds = @($RegistryData.sources | ForEach-Object { $_.id })
$Results += Add-Result -Id "registry:v212-sources" -Passed (($RegistryData.version -eq "v2.1.2") -and ($SourceIds -contains "gltf-transform") -and ($SourceIds -contains "poly-haven") -and ($SourceIds -contains "sketchfab")) -Detail "version=$($RegistryData.version); sources=$(@($SourceIds).Count)"
$MissingMetadata = @($RegistryData.sources | Where-Object {
    -not $_.license -or -not $_.provenance -or -not ($_.PSObject.Properties.Name -contains "vetted") -or -not $_.copy_policy
})
$Results += Add-Result -Id "registry:v212-source-provenance" -Passed ($MissingMetadata.Count -eq 0) -Detail "missing_metadata=$($MissingMetadata.Count)"

$Failed = @($Results | Where-Object { -not $_.passed })
$Summary = [ordered]@{
    name = "Srednoff OS v2.1.2 eval suite"
    version = "v2.1.2"
    total = @($Results).Count
    passed = @($Results | Where-Object { $_.passed }).Count
    failed = $Failed.Count
    results = @($Results)
}

if ($Json) {
    $Summary | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS v2.1.2 evals: passed=$($Summary.passed) failed=$($Summary.failed) total=$($Summary.total)"
    foreach ($Result in $Results) {
        $State = if ($Result.passed) { "ok" } else { "FAIL" }
        Write-Output "$State`t$($Result.id)`t$($Result.detail)"
    }
}

if ($Failed.Count -gt 0) { exit 1 }
