#Requires -Version 5.1
<#
.SYNOPSIS
    Genera icon.ico y PNG optimizados para la app de escritorio.
#>
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
$assets = Join-Path $root 'assets'
$srcPng = Join-Path $assets 'icon.png'
if (-not (Test-Path $srcPng)) {
    throw "No se encontro $srcPng"
}

function Save-SquarePng {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [int]$Size
    )
    $src = [Drawing.Image]::FromFile((Resolve-Path $SourcePath))
    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([Drawing.Color]::Transparent)
    $g.DrawImage($src, 0, 0, $Size, $Size)
    $g.Dispose()
    $src.Dispose()
    $bmp.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function Save-IconFromPng {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [int[]]$Sizes = @(16, 32, 48, 256)
    )
    $images = New-Object 'System.Collections.Generic.List[System.Drawing.Bitmap]'
    try {
        foreach ($size in $Sizes) {
            $src = [Drawing.Image]::FromFile((Resolve-Path $SourcePath))
            $bmp = New-Object System.Drawing.Bitmap($size, $size)
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.DrawImage($src, 0, 0, $size, $size)
            $g.Dispose()
            $src.Dispose()
            [void]$images.Add($bmp)
        }
        $hIcon = $images[$images.Count - 1].GetHicon()
        $icon = [System.Drawing.Icon]::FromHandle($hIcon)
        $fs = [System.IO.File]::Open($DestPath, [System.IO.FileMode]::Create)
        try {
            $icon.Save($fs)
        } finally {
            $fs.Close()
            $icon.Dispose()
        }
    } finally {
        foreach ($img in $images) { $img.Dispose() }
    }
}

Save-SquarePng -SourcePath $srcPng -DestPath (Join-Path $assets 'icon-256.png') -Size 256
Save-SquarePng -SourcePath $srcPng -DestPath (Join-Path $assets 'logo-header.png') -Size 48
Save-IconFromPng -SourcePath $srcPng -DestPath (Join-Path $assets 'icon.ico')

Write-Host "Assets de escritorio generados en assets\" -ForegroundColor Green
