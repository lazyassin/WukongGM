<#
.SYNOPSIS
    A console for WukongGM. Type GM commands, they run in the game.

.DESCRIPTION
    Writes each command to the mod's live.txt. The in-game watcher polls that
    file, runs the command, and truncates it. Results are read back out of
    UE4SS.log so you see what happened without alt-tabbing.

    Run this beside the game (second monitor, or alt-tab). The game must be
    running and you must be in gameplay, not at the main menu.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\console.ps1
    powershell -ExecutionPolicy Bypass -File tools\console.ps1 -GameDir "H:\Games\Black Myth - Wukong"
#>
[CmdletBinding()]
param(
    [string]$GameDir = "H:\Games\Black Myth - Wukong"
)

$ErrorActionPreference = 'Stop'

$win64 = Join-Path $GameDir "b1\Binaries\Win64"
$live  = Join-Path $win64 "ue4ss\Mods\WukongGM\live.txt"
$log   = Join-Path $win64 "ue4ss\UE4SS.log"

if (-not (Test-Path $win64)) {
    Write-Host "Game folder not found: $win64" -ForegroundColor Red
    Write-Host "Pass the right path with -GameDir" -ForegroundColor Yellow
    exit 1
}

$liveDir = Split-Path $live -Parent
if (-not (Test-Path $liveDir)) {
    Write-Host "WukongGM is not installed at $liveDir" -ForegroundColor Red
    exit 1
}

# ASCII, no BOM — a BOM becomes part of the first command and it silently
# does nothing.
$enc = New-Object System.Text.ASCIIEncoding

function Send-Command([string]$cmd) {
    [System.IO.File]::AppendAllText($live, $cmd + "`n", $enc)
}

function Get-LogPosition {
    if (Test-Path $log) { return (Get-Item $log).Length }
    return 0
}

# Read anything the mod logged since we sent the command.
function Show-Response([long]$from, [int]$waitMs = 1500) {
    Start-Sleep -Milliseconds $waitMs
    if (-not (Test-Path $log)) { return }
    $fs = [System.IO.File]::Open($log, 'Open', 'Read', 'ReadWrite')
    try {
        if ($fs.Length -le $from) { return }
        $fs.Seek($from, 'Begin') | Out-Null
        $reader = New-Object System.IO.StreamReader($fs)
        $text = $reader.ReadToEnd()
        foreach ($line in ($text -split "`r?`n")) {
            if ($line -match '\[WukongGM\]') {
                $clean = $line -replace '^\[[\d\-\s:\.]+\]\s*\[Lua\]\s*', ''
                Write-Host "  $clean" -ForegroundColor DarkGray
            }
        }
    } finally { $fs.Dispose() }
}

Write-Host ""
Write-Host "  WukongGM console" -ForegroundColor Cyan
Write-Host "  commands go to: $live" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Examples:" -ForegroundColor DarkGray
Write-Host "    additem 1002 100000      add Will" -ForegroundColor DarkGray
Write-Host "    allweapon                every weapon" -ForegroundColor DarkGray
Write-Host "    addtalentpoint 50" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  :help   command reference     :quit   exit" -ForegroundColor DarkGray
Write-Host ""

while ($true) {
    Write-Host "wukong> " -NoNewline -ForegroundColor Green
    $entry = Read-Host

    if ($null -eq $entry) { break }
    $cmd = $entry.Trim()
    if ($cmd -eq "") { continue }

    switch -Regex ($cmd) {
        '^:(q|quit|exit)$' { Write-Host "bye"; exit 0 }
        '^:help$' {
            $docs = Join-Path (Split-Path $PSScriptRoot -Parent) "docs\commands.md"
            if (Test-Path $docs) { Get-Content $docs | Select-Object -First 60 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray } }
            else { Write-Host "  docs/commands.md not found" -ForegroundColor Yellow }
            continue
        }
        default {
            $pos = Get-LogPosition
            Send-Command $cmd
            Show-Response $pos
        }
    }
}
