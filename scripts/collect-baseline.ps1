#Requires -Version 5.1
<#
.SYNOPSIS
    Recolecta métricas de salud y rendimiento del sistema.
#>

$ErrorActionPreference = 'SilentlyContinue'
$root = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path "$root\data")) { New-Item -ItemType Directory -Path "$root\data" -Force | Out-Null }

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$ram = Get-CimInstance Win32_PhysicalMemory
$ramTotal = ($ram | Measure-Object -Property Capacity -Sum).Sum
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$gpu = Get-CimInstance Win32_VideoController
$system = Get-CimInstance Win32_ComputerSystem
$os = Get-ComputerInfo
$battery = Get-CimInstance Win32_Battery
$pagefile = Get-CimInstance Win32_PageFileUsage
$physicalDisk = Get-PhysicalDisk
$topProcs = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 15 |
    ForEach-Object { @{ Name = $_.Name; RAM_MB = [math]::Round($_.WorkingSet64 / 1MB, 0); CPU = $_.CPU } }
$startup = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location
$powerScheme = (powercfg /getactivescheme 2>$null) -join ' '

$baseline = [ordered]@{
    collected_at = (Get-Date -Format 'o')
    hostname     = $env:COMPUTERNAME
    system       = @{
        manufacturer = $system.Manufacturer
        model        = $system.Model
        os           = $os.WindowsProductName
        os_version   = $os.WindowsVersion
        timezone     = (Get-TimeZone).DisplayName
    }
    cpu          = @{
        name       = $cpu.Name
        cores      = $cpu.NumberOfCores
        threads    = $cpu.NumberOfLogicalProcessors
        max_mhz    = $cpu.MaxClockSpeed
        load_pct   = $cpu.LoadPercentage
    }
    memory       = @{
        total_gb   = [math]::Round($ramTotal / 1GB, 2)
        modules    = @($ram | ForEach-Object { @{ capacity_gb = [math]::Round($_.Capacity / 1GB, 2); speed_mhz = $_.Speed; manufacturer = $_.Manufacturer } })
    }
    storage      = @($disks | ForEach-Object {
            @{
                drive    = $_.DeviceID
                size_gb  = [math]::Round($_.Size / 1GB, 2)
                free_gb  = [math]::Round($_.FreeSpace / 1GB, 2)
                used_pct = if ($_.Size -gt 0) { [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 1) } else { 0 }
            }
        })
    physical_disk = @($physicalDisk | ForEach-Object {
            @{
                name      = $_.FriendlyName
                media     = $_.MediaType
                health    = $_.HealthStatus
                size_gb   = [math]::Round($_.Size / 1GB, 2)
            }
        })
    gpu          = @($gpu | ForEach-Object { @{ name = $_.Name; driver = $_.DriverVersion } })
    battery      = @($battery | ForEach-Object { @{ charge_pct = $_.EstimatedChargeRemaining; status = $_.BatteryStatus } })
    pagefile     = @($pagefile | ForEach-Object { @{ path = $_.Name; used_mb = $_.CurrentUsage; allocated_mb = $_.AllocatedBaseSize } })
    power_plan   = $powerScheme
    top_processes = $topProcs
    startup      = @($startup)
}

$outPath = Join-Path $root 'data\baseline.json'
$prevPath = Join-Path $root 'data\baseline.previous.json'
if (Test-Path $outPath) {
    Copy-Item -Path $outPath -Destination $prevPath -Force
}
$baseline | ConvertTo-Json -Depth 6 | Set-Content -Path $outPath -Encoding UTF8
Write-Host "Baseline guardado en: $outPath"
return $baseline
