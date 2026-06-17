Import-Module (Join-Path $PSScriptRoot 'PcHealth.Core.psm1') -Force

$script:PcHealthRoot = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { $PWD.Path }
$script:LogCallback = $null
$script:DownloadsSizeCache = $null

function Set-PcLogCallback {
    param([scriptblock]$Callback)
    $script:LogCallback = $Callback
}

function Clear-PcLogCallback {
    $script:LogCallback = $null
}

function Write-PcLog {
    param([string]$Message, [string]$Level = 'INFO')
    $line = Format-PcLogLine -Message $Message -Level $Level
    if ($script:LogCallback) { & $script:LogCallback $line $Level }
    return $line
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal $id
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-PcProjectRoot {
    return $script:PcHealthRoot
}

function Get-PcDownloadsBytes {
    param(
        [string]$DownloadsPath = (Join-Path $env:USERPROFILE 'Downloads'),
        [switch]$Force
    )

    if (-not (Test-Path $DownloadsPath)) { return 0L }

    if (-not $Force -and $script:DownloadsSizeCache) {
        if ((Get-Date) -lt $script:DownloadsSizeCache.Expires) {
            return [long]$script:DownloadsSizeCache.Bytes
        }
    }

    $bytes = [long](Get-ChildItem $DownloadsPath -Recurse -File -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum

    $script:DownloadsSizeCache = @{
        Bytes   = $bytes
        Expires = (Get-Date).AddMinutes(10)
    }
    return $bytes
}

function Clear-PcDownloadsCache {
    $script:DownloadsSizeCache = $null
}

function Get-PcSnapshot {
    param([switch]$SkipDownloadsScan)

    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue
    $osMem = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -First 1
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue |
        Where-Object { $_.DeviceID -eq 'C:' } | Select-Object -First 1
    $gpu = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
    $power = (powercfg /getactivescheme 2>$null) -join ' '

    $downloads = if ($SkipDownloadsScan) { -1L } else { Get-PcDownloadsBytes }

    return ConvertTo-PcSnapshot -Cpu $cpu -RamModules $ram -Disk $disk -Gpu $gpu `
        -PowerCfgText $power -DownloadsBytes $downloads -IsAdmin:(Test-IsAdmin) -OsMemory $osMem
}

function Set-PcHighPerformance {
    $scheme = Get-PcHighPerformanceSchemeGuid
    powercfg /setactive $scheme | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0 | Out-Null
    powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null
    powercfg /setactive $scheme | Out-Null
    Write-PcLog 'Plan Alto rendimiento aplicado (CPU 100% AC/DC, disco y USB sin ahorro)'
}

function Invoke-PcTrimSsd {
    param([switch]$ThrowOnDenied)

    if (-not (Test-IsAdmin)) {
        $msg = 'TRIM omitido sin Administrador (Windows ya programa TRIM automatico en SSD)'
        Write-PcLog $msg 'WARN'
        if ($ThrowOnDenied) { throw 'Acceso denegado: TRIM SSD requiere Administrador' }
        return [pscustomobject]@{ Ok = $false; Skipped = $true; Message = $msg }
    }
    try {
        Optimize-Volume -DriveLetter C -ReTrim -Verbose:$false -ErrorAction Stop
        $trim = fsutil behavior query DisableDeleteNotify 2>$null
        Write-PcLog "TRIM SSD ejecutado. $trim"
        return [pscustomobject]@{ Ok = $true; Skipped = $false; Message = 'TRIM OK' }
    } catch {
        Write-PcLog $_.Exception.Message 'ERROR'
        if ($ThrowOnDenied) { throw }
        return [pscustomobject]@{ Ok = $false; Skipped = $false; Message = $_.Exception.Message }
    }
}

function Invoke-PcQuickOptimize {
    $steps = [System.Collections.Generic.List[object]]::new()

    try {
        Set-PcHighPerformance
        $steps.Add([pscustomobject]@{ Step = 'Energia'; Ok = $true; Message = 'Alto rendimiento' })
    } catch {
        $steps.Add([pscustomobject]@{ Step = 'Energia'; Ok = $false; Message = $_.Exception.Message })
    }

    $trim = Invoke-PcTrimSsd
    $steps.Add([pscustomobject]@{
        Step = 'TRIM SSD'; Ok = $trim.Ok; Message = $trim.Message; Skipped = $trim.Skipped
    })

    try {
        Invoke-PcBaseline
        $steps.Add([pscustomobject]@{ Step = 'Baseline'; Ok = $true; Message = 'baseline.json' })
    } catch {
        $steps.Add([pscustomobject]@{ Step = 'Baseline'; Ok = $false; Message = $_.Exception.Message })
    }

    try {
        $clean = Invoke-PcDiskCleanupLite
        $steps.Add([pscustomobject]@{
            Step = 'Limpieza'; Ok = $true
            Message = ('{0} archivos, ~{1} MB' -f $clean.Removed, [math]::Round($clean.BytesFreed / 1MB, 1))
        })
    } catch {
        $steps.Add([pscustomobject]@{ Step = 'Limpieza'; Ok = $false; Message = $_.Exception.Message })
    }

    $failed = @($steps | Where-Object { -not $_.Ok -and -not $_.Skipped })
    if ($failed.Count -gt 0) {
        throw ('Fallaron: ' + (($failed | ForEach-Object { $_.Step }) -join ', '))
    }

    $skipped = @($steps | Where-Object { $_.Skipped })
    if ($skipped.Count -gt 0) {
        Write-PcLog ('Optimizacion parcial. Omitido: ' + (($skipped | ForEach-Object { $_.Step }) -join ', ')) 'WARN'
    }

    return $steps
}

function Invoke-PcBaseline {
    $collect = Join-Path $script:PcHealthRoot 'scripts\collect-baseline.ps1'
    if (-not (Test-Path $collect)) { throw "No se encontro collect-baseline.ps1" }
    $null = & $collect
    Write-PcLog 'Baseline guardado en data\baseline.json'
}

function Invoke-PcDiskCleanupLite {
    param([string]$DownloadsPath = (Join-Path $env:USERPROFILE 'Downloads'))

    $removed = 0
    $bytes = 0L
    if (Test-Path $DownloadsPath) {
        Get-ChildItem $DownloadsPath -Filter '*.crdownload' -File -Force -ErrorAction SilentlyContinue |
            ForEach-Object {
                $bytes += $_.Length
                Remove-Item $_.FullName -Force
                $removed++
            }
    }
    if (Test-Path $env:TEMP) {
        Get-ChildItem $env:TEMP -Force -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
            ForEach-Object {
                try {
                    $bytes += $_.Length
                    Remove-Item $_.FullName -Force
                    $removed++
                } catch { }
            }
    }
    Write-PcLog ("Limpieza ligera: {0} elementos, ~{1} MB liberados" -f $removed, [math]::Round($bytes / 1MB, 1))
    return [pscustomobject]@{ Removed = $removed; BytesFreed = $bytes }
}

function Invoke-PcDiskCleanupFull {
    if (-not (Test-IsAdmin)) { throw 'Disk Cleanup completo requiere Administrador' }
    Start-Process cleanmgr.exe -ArgumentList '/d C:' -Wait
    Write-PcLog 'Disk Cleanup abierto para C:'
}

function Test-PcSqlServiceName {
    param([string]$ServiceName, $Config)

    if (-not $Config) { $Config = Get-PcMachineConfig }
    foreach ($pattern in @($Config.sql_services.name_patterns)) {
        if ($ServiceName -like $pattern) { return $true }
    }
    return $false
}

function Stop-PcSqlServices {
    if (-not (Test-IsAdmin)) { throw 'Detener SQL Server requiere Administrador' }
    $cfg = Get-PcMachineConfig
    $names = @(Get-Service -ErrorAction SilentlyContinue |
        Where-Object { Test-PcSqlServiceName -ServiceName $_.Name -Config $cfg } |
        Select-Object -ExpandProperty Name)
    if ($names.Count -eq 0) {
        Write-PcLog 'No se encontraron servicios SQL Server en este equipo'
        return
    }
    foreach ($s in $names) {
        $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -eq 'Running') {
            Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
            Write-PcLog "Servicio detenido: $s"
        }
        if ($svc) { Set-Service -Name $s -StartupType Manual -ErrorAction SilentlyContinue }
    }
    Write-PcLog 'SQL Server configurado en Manual y detenido'
}

function Get-PcDownloadsReport {
    param([string]$DownloadsPath = (Join-Path $env:USERPROFILE 'Downloads'))
    if (-not (Test-Path $DownloadsPath)) { return @() }

    $folders = Get-ChildItem $DownloadsPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $sum = (Get-ChildItem $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        [pscustomobject]@{ Name = $_.Name; Bytes = [long]$sum }
    }
    $files = Get-ChildItem $DownloadsPath -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending | Select-Object -First 15
    return ConvertTo-PcDownloadsReport -FolderSizes $folders -TopFiles $files
}

function Get-PcDriverReport {
    $drivers = Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue
    return ConvertTo-PcDriverReport -SignedDrivers $drivers
}

function Get-PcFirewallReport {
    $profiles = Get-NetFirewallProfile -ErrorAction SilentlyContinue |
        Select-Object Name, Enabled, DefaultOutboundAction
    $blocks = Get-NetFirewallRule -PolicyStore ActiveStore -Enabled True -ErrorAction SilentlyContinue |
        Where-Object { $_.Action -eq 'Block' } |
        Select-Object DisplayName, Direction, Action
    return [pscustomobject]@{ Profiles = $profiles; BlockRules = $blocks }
}

function Get-PcTopProcesses {
    Get-Process -ErrorAction SilentlyContinue |
        Sort-Object WorkingSet64 -Descending |
        Select-Object -First 12 Name,
        @{ N = 'RAM_MB'; E = { [math]::Round($_.WorkingSet64 / 1MB, 0) } }
}

function Get-PcManufacturerSupportUrl {
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    $maker = if ($cs) { $cs.Manufacturer } else { '' }
    $cfg = Get-PcMachineConfig
    $urls = $cfg.support_urls

    switch -Regex ($maker) {
        'Lenovo' { return [string]$urls.Lenovo }
        'Dell'   { return [string]$urls.Dell }
        'HP'     { return [string]$urls.HP }
        'ASUS'   { return [string]$urls.ASUS }
        default  { return [string]$urls.default }
    }
}

function Open-PcExternal {
    param([string]$Target)
    switch ($Target) {
        'docs'        { Start-Process (Join-Path $script:PcHealthRoot 'docs') }
        'startup'     { Start-Process taskmgr.exe -ArgumentList '/0 /startup' }
        'storage'     { Start-Process 'ms-settings:storagesense' }
        'power'       { Start-Process powercfg.cpl }
        'performance' { Start-Process sysdm.cpl }
        'lenovo'      { Start-Process (Get-PcManufacturerSupportUrl) }
        'drivers'     { Start-Process (Get-PcManufacturerSupportUrl) }
        'taskmgr'     { Start-Process taskmgr.exe }
        default       { throw "Destino desconocido: $Target" }
    }
}

Export-ModuleMember -Function @(
    'Set-PcLogCallback', 'Clear-PcLogCallback',
    'Write-PcLog', 'Test-IsAdmin', 'Get-PcProjectRoot', 'Get-PcSnapshot',
    'Get-PcDownloadsBytes', 'Clear-PcDownloadsCache',
    'Set-PcHighPerformance', 'Invoke-PcTrimSsd', 'Invoke-PcQuickOptimize', 'Invoke-PcBaseline',
    'Invoke-PcDiskCleanupLite', 'Invoke-PcDiskCleanupFull', 'Stop-PcSqlServices',
    'Get-PcDownloadsReport', 'Get-PcDriverReport', 'Get-PcFirewallReport',
    'Get-PcTopProcesses', 'Open-PcExternal', 'Test-PcSqlServiceName'
)
