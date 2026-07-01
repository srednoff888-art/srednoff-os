param(
    [string]$ProjectPath = ".",
    [string]$TemplateRoot = "$HOME\.codex\templates\codex-md-os"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TemplateRoot)) {
    throw "Template root not found: $TemplateRoot"
}

New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
$ProjectRoot = (Resolve-Path $ProjectPath).Path

try {
    $GitRootRaw = git -C $ProjectRoot rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $GitRootRaw) {
        $GitRoot = (Resolve-Path $GitRootRaw).Path
        $HomeDir = (Resolve-Path $HOME).Path
        if ($GitRoot -ne $HomeDir -and $GitRoot -notmatch '^[A-Za-z]:\\?$') {
            $ProjectRoot = $GitRoot
        }
    }
} catch {}

$TemplateFiles = Get-ChildItem -LiteralPath $TemplateRoot -Recurse -File |
    Where-Object { $_.FullName -notmatch '\\.bak\\.' }

$Results = foreach ($File in $TemplateFiles) {
    $Relative = $File.FullName.Substring($TemplateRoot.Length + 1)
    $ProjectFile = Join-Path $ProjectRoot $Relative

    if (-not (Test-Path -LiteralPath $ProjectFile)) {
        [PSCustomObject]@{ Status = "missing"; Path = $Relative }
        continue
    }

    $TemplateHash = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash
    $ProjectHash = (Get-FileHash -LiteralPath $ProjectFile -Algorithm SHA256).Hash
    $Status = if ($TemplateHash -eq $ProjectHash) { "ok" } else { "changed" }
    [PSCustomObject]@{ Status = $Status; Path = $Relative }
}

$Results | Group-Object Status | Sort-Object Name | ForEach-Object {
    Write-Output "$($_.Name): $($_.Count)"
}

Write-Output ""
Write-Output "Details:"
$Results | Sort-Object Status, Path | Format-Table -AutoSize
