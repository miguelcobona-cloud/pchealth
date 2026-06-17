#Requires -Version 5.1
<#
.SYNOPSIS
    Compara dos archivos baseline.json y genera un informe Markdown.
.EXAMPLE
    .\scripts\Compare-Baseline.ps1
    .\scripts\Compare-Baseline.ps1 -Before .\data\baseline.previous.json -After .\data\baseline.json
#>
[CmdletBinding()]
param(
    [string]$Before,
    [string]$After,
    [string]$OutputPath,
    [switch]$PassThru
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$src = Join-Path $root 'src'
Import-Module (Join-Path $src 'PcHealth.Core.psm1') -Force

if (-not $Before) {
    $Before = Join-Path $root 'data\baseline.previous.json'
}
if (-not $After) {
    $After = Join-Path $root 'data\baseline.json'
}
if (-not $OutputPath) {
    $OutputPath = Join-Path $root 'docs\baseline-comparison.md'
}

if (-not (Test-Path $Before)) {
    throw "No se encontro baseline anterior: $Before`r`nEjecuta collect-baseline.ps1 al menos dos veces para generar baseline.previous.json"
}
if (-not (Test-Path $After)) {
    throw "No se encontro baseline actual: $After"
}

$beforeObj = Get-Content -Path $Before -Raw -Encoding UTF8 | ConvertFrom-Json
$afterObj  = Get-Content -Path $After -Raw -Encoding UTF8 | ConvertFrom-Json

$comparison = Compare-PcBaseline -Before $beforeObj -After $afterObj
$markdown = Format-PcBaselineComparisonMarkdown -Comparison $comparison

$outDir = Split-Path $OutputPath -Parent
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
Set-Content -Path $OutputPath -Value $markdown -Encoding UTF8

Write-Host "Comparacion guardada en: $OutputPath" -ForegroundColor Green
Write-Host ('Score: {0} -> {1} ({2:+0;-0} pts)' -f $comparison.Before.HealthScore, $comparison.After.HealthScore, $comparison.ScoreDelta)

if ($PassThru) {
    return [pscustomobject]@{
        Comparison = $comparison
        OutputPath = $OutputPath
        Markdown   = $markdown
        Before     = $comparison.Before
        After      = $comparison.After
        ScoreDelta = $comparison.ScoreDelta
        Improved   = $comparison.Improved
    }
}
