#Requires -Version 5.1
# Compatibilidad: reexporta modulos fragmentados en src/

$src = Join-Path (Split-Path $PSScriptRoot -Parent) 'src'
Import-Module (Join-Path $src 'PcHealth.Core.psm1') -Force
Import-Module (Join-Path $src 'PcHealth.System.psm1') -Force
