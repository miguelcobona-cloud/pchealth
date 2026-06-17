#Requires -Version 5.1
<#
.SYNOPSIS
    Orquestador PC Health - flujo CS completo.
#>

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$src = Join-Path $root 'src'
Import-Module (Join-Path $src 'PcHealth.Core.psm1') -Force
Import-Module (Join-Path $src 'PcHealth.System.psm1') -Force

$machineCfg = Get-PcMachineConfig -ProjectRoot $root

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  PC Health - Orquestador CS' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

$dirs = @('docs', 'data', 'scripts')
foreach ($d in $dirs) {
    $path = Join-Path $root $d
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "[+] Creado: $d/" -ForegroundColor Green
    }
}

Write-Host ''
Write-Host '[Fase 1] Recolectando baseline...' -ForegroundColor Yellow
$collectScript = Join-Path $root 'scripts\collect-baseline.ps1'
if (-not (Test-Path $collectScript)) {
    Write-Error "No se encontro $collectScript"
}
$baseline = & $collectScript

Write-Host ''
Write-Host '[Fase 2] Validando entregables docs/...' -ForegroundColor Yellow
$expectedDocs = @(
    '00-executive-summary.md',
    '01-hardware-profile.md',
    '02-software-inventory.md',
    '03-performance-baseline.md',
    '04-bottlenecks.md',
    '05-recommendations.md',
    '06-action-plan.md'
)
$missing = @()
foreach ($doc in $expectedDocs) {
    $docPath = Join-Path $root "docs\$doc"
    if (Test-Path $docPath) {
        Write-Host "  [OK] docs/$doc" -ForegroundColor Green
    } else {
        Write-Host "  [!!] FALTA docs/$doc" -ForegroundColor Red
        $missing += $doc
    }
}

Write-Host ''
Write-Host '[Fase 3] Resumen ejecutivo' -ForegroundColor Yellow
Write-Host '----------------------------------------'
$cpuLoad = $baseline.cpu.load_pct
$ramGb   = $baseline.memory.total_gb
$disk    = $baseline.storage | Where-Object { $_.drive -eq 'C:' }
$freeGb  = if ($disk) { $disk.free_gb } else { '?' }
$usedPct = if ($disk) { $disk.used_pct } else { '?' }

$scoreResult = Get-PcHealthScore -InputObject $baseline -Config $machineCfg

Write-Host "  Equipo:     $($baseline.system.manufacturer) $($baseline.system.model)"
Write-Host ('  Perfil:     {0}' -f $machineCfg.machine.label)
Write-Host ('  CPU load:   {0} por ciento' -f $cpuLoad)
Write-Host ('  RAM:        {0} GB' -f $ramGb)
Write-Host ('  Disco C:    {0} GB libres ({1} por ciento usado)' -f $freeGb, $usedPct)
Write-Host ('  Score:      {0}/100 ({1})' -f $scoreResult.Total, $scoreResult.Grade)
Write-Host '  Categorias:'
foreach ($cat in $scoreResult.Categories.Keys) {
    Write-Host ('    {0,-14} {1}/100' -f $cat, $scoreResult.Categories[$cat])
}
Write-Host ''
Write-Host '  TOP 3 ACCIONES:' -ForegroundColor Cyan
Write-Host '  1. Ampliar RAM a 16 GB (DDR3L-1600)'
Write-Host '  2. SQL Server -> Manual si no se usa diario'
Write-Host '  3. Una app pesada a la vez (SW / MATLAB)'
Write-Host ''
Write-Host '  Ver: docs\00-executive-summary.md'
Write-Host '  Plan: docs\06-action-plan.md'
Write-Host '----------------------------------------'
Write-Host ''

if ($missing.Count -gt 0) {
    Write-Warning "Faltan $($missing.Count) documentos. Revisar docs/."
    exit 1
}

Write-Host 'Engagement completado. Contrato: CONTRACT.md' -ForegroundColor Green
Write-Host ''
