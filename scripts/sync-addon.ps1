# Sync GearQuest addon files to the local WoW Anniversary install.
# Run from repo root after making changes.

$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "..\GearQuest"
$target = "C:\Program Files (x86)\World of Warcraft\_anniversary_\Interface\AddOns\GearQuest"

if (-not (Test-Path $source)) {
    Write-Error "Source not found: $source"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -Path (Join-Path $source "*") -Destination $target -Recurse -Force

Write-Host "Synced GearQuest -> $target"
