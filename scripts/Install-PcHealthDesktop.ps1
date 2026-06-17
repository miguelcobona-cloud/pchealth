#Requires -Version 5.1
<#
.SYNOPSIS
    Instala PC Health como aplicacion de escritorio (acceso directo + menu Inicio).
.EXAMPLE
    .\scripts\Install-PcHealthDesktop.ps1
#>
[CmdletBinding()]
param(
    [switch]$Desktop,
    [switch]$StartMenu,
    [switch]$All
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$gui = Join-Path $root 'pchealth-gui.ps1'
$build = Join-Path $PSScriptRoot 'Build-DesktopAssets.ps1'
$launcher = Join-Path $root 'PC Health.vbs'

if (-not (Test-Path $gui)) { throw "No se encontro $gui" }
& $build

$iconIco = Join-Path $root 'assets\icon.ico'
if (-not (Test-Path $iconIco)) { throw "No se genero icon.ico" }

$guiEscaped = $gui.Replace('\', '\\')
$vbsContent = @"
Set shell = CreateObject("Wscript.Shell")
cmd = "powershell.exe -STA -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File ""$guiEscaped"""
shell.Run cmd, 1, False
"@
Set-Content -Path $launcher -Value $vbsContent -Encoding ASCII

function New-PcHealthShortcut {
    param(
        [string]$ShortcutPath,
        [string]$Description
    )
    $wsh = New-Object -ComObject WScript.Shell
    $lnk = $wsh.CreateShortcut($ShortcutPath)
    $lnk.TargetPath = $launcher
    $lnk.WorkingDirectory = $root
    $lnk.IconLocation = "$iconIco,0"
    $lnk.Description = $Description
    $lnk.Save()
}

if ($All) { $Desktop = $true; $StartMenu = $true }
if (-not $Desktop -and -not $StartMenu) { $Desktop = $true; $StartMenu = $true }

if ($Desktop) {
    $desk = [Environment]::GetFolderPath('Desktop')
    New-PcHealthShortcut -ShortcutPath (Join-Path $desk 'PC Health.lnk') -Description 'PC Health - optimizador Windows'
    Write-Host "Acceso directo en Escritorio" -ForegroundColor Green
}

if ($StartMenu) {
    $programs = [Environment]::GetFolderPath('Programs')
    $folder = Join-Path $programs 'PC Health'
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
    New-PcHealthShortcut -ShortcutPath (Join-Path $folder 'PC Health.lnk') -Description 'PC Health - optimizador Windows'
    Write-Host "Acceso directo en Menu Inicio > PC Health" -ForegroundColor Green
}

Write-Host ""
Write-Host "Listo. Abre PC Health desde el acceso directo (sin ventana de consola)." -ForegroundColor Cyan
