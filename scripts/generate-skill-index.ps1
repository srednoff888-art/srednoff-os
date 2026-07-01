param(
    [string]$SkillsRoot = "$HOME\.codex\skills",
    [string]$OutputPath = "$HOME\.codex\skill-index.json"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SkillsRoot)) {
    throw "Skills root not found: $SkillsRoot"
}

$Index = Get-ChildItem -LiteralPath $SkillsRoot -Recurse -Filter "SKILL.md" -File |
    Where-Object { $_.FullName -notmatch "\\\.system\\" } |
    ForEach-Object {
        $SkillPath = $_.FullName
        $SkillDir = Split-Path -Parent $SkillPath
        $Text = Get-Content -LiteralPath $SkillPath -Raw -Encoding UTF8
        $Name = if ($Text -match '(?m)^name:\s*(.+)$') { $Matches[1].Trim().Trim('"') } else { Split-Path -Leaf $SkillDir }
        $Description = if ($Text -match '(?m)^description:\s*"?(.+?)"?$') { $Matches[1].Trim().Trim('"') } else { "" }

        [PSCustomObject]@{
            name = $Name
            path = $SkillDir
            description = $Description
            has_openai_yaml = (Test-Path -LiteralPath (Join-Path $SkillDir "agents\openai.yaml"))
            skill_md_bytes = (Get-Item -LiteralPath $SkillPath).Length
        }
    } |
    Sort-Object name, path

$Parent = Split-Path -Parent $OutputPath
if ($Parent) {
    New-Item -ItemType Directory -Force -Path $Parent | Out-Null
}

$Json = $Index | ConvertTo-Json -Depth 4
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutputPath, $Json, $Utf8NoBom)

Write-Output "skills indexed: $($Index.Count)"
Write-Output "output: $OutputPath"
