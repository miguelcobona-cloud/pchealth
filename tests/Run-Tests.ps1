#Requires -Version 5.1
<#
.SYNOPSIS
    Ejecuta unit tests de PC Health (Pester 3+).
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Error 'Pester no instalado. Ejecuta: Install-Module Pester -Scope CurrentUser'
}

Import-Module Pester -Force

$results = Invoke-Pester -Script (Join-Path $PSScriptRoot '*.Tests.ps1') -PassThru

Write-Host ''
$color = if ($results.FailedCount -eq 0) { 'Green' } else { 'Red' }
Write-Host ("Tests: {0} passed, {1} failed, {2} total" -f `
    $results.PassedCount, $results.FailedCount, $results.TotalCount) -ForegroundColor $color

if ($results.FailedCount -gt 0) { exit 1 }
exit 0
