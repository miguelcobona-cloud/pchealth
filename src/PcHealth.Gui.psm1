function New-PcSafeFont {
    param(
        [string]$Family = 'Segoe UI',
        [float]$Size = 9,
        [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular
    )
    try {
        return New-Object System.Drawing.Font($Family, $Size, $Style)
    } catch {
        return New-Object System.Drawing.Font('Tahoma', $Size, $Style)
    }
}

function Test-PcGuiCanLoad {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $f = New-Object System.Windows.Forms.Form
        $f.Dispose()
        return $true
    } catch {
        return $false
    }
}

function Get-PcStatusEmoji {
    param(
        [ValidateSet('idle', 'running', 'success', 'error', 'warn', 'skip')]
        [string]$State
    )
    switch ($State) {
        'idle'    { return [char]0x2705 }      # check mark
        'running' { return [char]0x23F3 }      # hourglass
        'success' { return [char]0x2705 }
        'error'   { return [char]0x274C }      # cross
        'warn'    { return [char]0x26A0 }      # warning
        'skip'    { return [char]0x23ED }      # next track
        default   { return [char]0x2753 }      # question
    }
}

function Format-PcStatusText {
    param(
        [ValidateSet('idle', 'running', 'success', 'error', 'warn', 'skip')]
        [string]$State,
        [string]$Message
    )
    return ('{0}  {1}' -f (Get-PcStatusEmoji $State), $Message)
}

function Test-PcGuiHealth {
    param(
        [string]$ProjectRoot,
        $Snapshot = $null
    )

    $sysMod = Join-Path (Split-Path $PSScriptRoot -Parent) 'PcHealth.System.psm1'
    if (Test-Path $sysMod) {
        Import-Module $sysMod -Force -ErrorAction SilentlyContinue
    }
    $coreMod = Join-Path $PSScriptRoot 'PcHealth.Core.psm1'
    if (Test-Path $coreMod) {
        Import-Module $coreMod -Force -ErrorAction SilentlyContinue
    }

    $checks = [System.Collections.Generic.List[object]]::new()

    function Add-Check([string]$Name, [bool]$Ok, [string]$Detail) {
        $checks.Add([pscustomobject]@{
            Name   = $Name
            Ok     = $Ok
            Detail = $Detail
            Status = if ($Ok) { Format-PcStatusText success $Detail } else { Format-PcStatusText error $Detail }
        })
    }

    Add-Check 'WinForms' (Test-PcGuiCanLoad) 'Interfaz grafica disponible'
    Add-Check 'Modulo Core' (Test-Path (Join-Path $ProjectRoot 'src\PcHealth.Core.psm1')) 'PcHealth.Core.psm1'
    Add-Check 'Modulo System' (Test-Path (Join-Path $ProjectRoot 'src\PcHealth.System.psm1')) 'PcHealth.System.psm1'
    Add-Check 'Baseline script' (Test-Path (Join-Path $ProjectRoot 'scripts\collect-baseline.ps1')) 'collect-baseline.ps1'

    try {
        $s = if ($Snapshot) { $Snapshot } else { Get-PcSnapshot -SkipDownloadsScan }
        Add-Check 'Snapshot sistema' $true "CPU $($s.CpuLoad)% | RAM $($s.RamGb) GB | C: $($s.DiskFreeGb) GB libres"
    } catch {
        Add-Check 'Snapshot sistema' $false $_.Exception.Message
    }

    try {
        $trim = fsutil behavior query DisableDeleteNotify 2>$null
        $ok = $trim -match '= 0'
        Add-Check 'TRIM SSD' $ok $(if ($ok) { 'TRIM activo' } else { 'TRIM no confirmado' })
    } catch {
        Add-Check 'TRIM SSD' $false $_.Exception.Message
    }

    $failed = @($checks | Where-Object { -not $_.Ok }).Count
  return [pscustomobject]@{
        Checks      = $checks
        AllOk       = ($failed -eq 0)
        PassedCount = $checks.Count - $failed
        FailedCount = $failed
        Summary     = if ($failed -eq 0) {
            Format-PcStatusText success 'GUI operativa - todos los chequeos OK'
        } else {
            Format-PcStatusText warn ("GUI parcial - $failed chequeo(s) fallaron")
        }
    }
}

function Start-PcHealthGuiProcess {
    param([string]$GuiScriptPath)
    if (-not (Test-Path $GuiScriptPath)) {
        throw "No se encontro GUI: $GuiScriptPath"
    }
    Start-Process powershell.exe -ArgumentList @(
        '-STA', '-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', "`"$GuiScriptPath`""
    )
}

function ConvertTo-PcDataTable {
    param(
        $Items,
        [string[]]$ColumnNames
    )

    $dt = New-Object System.Data.DataTable
    if ($null -eq $Items) { return $dt }

    $list = @($Items)
    if ($list.Count -eq 0) { return $dt }

    $names = @($ColumnNames | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($names.Count -eq 0) {
        $names = @($list[0].PSObject.Properties | ForEach-Object { $_.Name })
    }
    foreach ($name in $names) {
        $null = $dt.Columns.Add($name)
    }
    foreach ($item in $list) {
        $row = $dt.NewRow()
        foreach ($name in $names) {
            [void]($row[$name] = $item.$name)
        }
        [void]$dt.Rows.Add([System.Data.DataRow]$row)
    }
    return ,$dt
}

Export-ModuleMember -Function @(
    'New-PcSafeFont', 'Test-PcGuiCanLoad', 'Get-PcStatusEmoji',
    'Format-PcStatusText', 'Test-PcGuiHealth', 'Start-PcHealthGuiProcess', 'ConvertTo-PcDataTable'
)
