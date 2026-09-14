<#
.SYNOPSIS
    Build the release zip for WukongGM.

.DESCRIPTION
    Produces dist\WukongGM-<version>.zip laid out so users can drop the
    WukongGM folder straight into ue4ss\Mods\.

    Verifies that no shipped text file carries a UTF-8 BOM, because a BOM in
    commands.txt silently breaks the first command.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\package.ps1 -Version 1.0.0
#>
[CmdletBinding()]
param(
    [string]$Version = "1.0.0"
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root "src\WukongGM"
$dist = Join-Path $root "dist"
$stage = Join-Path $dist "stage"
$zip  = Join-Path $dist "WukongGM-$Version.zip"

if (-not (Test-Path $src)) { throw "source folder not found: $src" }

# --- BOM check -----------------------------------------------------------
$bomFiles = @()
Get-ChildItem $src -Recurse -File -Include *.lua,*.txt,*.md | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $bomFiles += $_.FullName
    }
}
if ($bomFiles.Count -gt 0) {
    Write-Host "ERROR: these files have a UTF-8 BOM and must be saved without one:" -ForegroundColor Red
    $bomFiles | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    throw "BOM check failed"
}
Write-Host "BOM check passed" -ForegroundColor Green

# --- non-ASCII check ------------------------------------------------------
# UE4SS's logger truncates a log line at the first non-ASCII byte, so an em
# dash in a Log() string silently swallows the rest of the message.
$nonAscii = @()
Get-ChildItem $src -Recurse -File -Include *.lua,*.txt | ForEach-Object {
    $n = 0
    foreach ($ch in [System.IO.File]::ReadAllText($_.FullName).ToCharArray()) {
        if ([int]$ch -gt 127) { $n++ }
    }
    if ($n -gt 0) { $nonAscii += "$($_.FullName)  ($n chars)" }
}
if ($nonAscii.Count -gt 0) {
    Write-Host "ERROR: non-ASCII characters found - UE4SS log lines will be truncated:" -ForegroundColor Red
    $nonAscii | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    throw "non-ASCII check failed"
}
Write-Host "non-ASCII check passed" -ForegroundColor Green

# --- stage ---------------------------------------------------------------
if (Test-Path $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage -Force | Out-Null

Copy-Item $src -Destination (Join-Path $stage "WukongGM") -Recurse -Force
foreach ($doc in @("README.md", "LICENSE", "CHANGELOG.md", "THIRD-PARTY.md")) {
    $p = Join-Path $root $doc
    if (Test-Path $p) { Copy-Item $p -Destination (Join-Path $stage "WukongGM") -Force }
}
$docs = Join-Path $root "docs"
if (Test-Path $docs) {
    Copy-Item $docs -Destination (Join-Path $stage "WukongGM\docs") -Recurse -Force
    # Upload instructions are for the author, not for players.
    foreach ($authorOnly in @("nexus-page.md", "images")) {
        $p2 = Join-Path $stage "WukongGM\docs\$authorOnly"
        if (Test-Path $p2) { Remove-Item -LiteralPath $p2 -Recurse -Force }
    }
}

# Bundled shared libraries. The zip mirrors ue4ss\Mods\ so users extract once
# and both WukongGM\ and shared\ land in the right place.
$shared = Join-Path $root "src\shared"
if (Test-Path $shared) {
    Copy-Item $shared -Destination (Join-Path $stage "shared") -Recurse -Force
    Write-Host "bundled shared libraries" -ForegroundColor Green
}

# --- zip -----------------------------------------------------------------
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip)

Remove-Item -LiteralPath $stage -Recurse -Force

$size = [math]::Round((Get-Item $zip).Length / 1KB, 1)
Write-Host ""
Write-Host "built $zip ($size KB)" -ForegroundColor Green
Write-Host ""
Write-Host "contents:"
[System.IO.Compression.ZipFile]::OpenRead($zip).Entries |
    ForEach-Object { Write-Host ("  " + $_.FullName) }
