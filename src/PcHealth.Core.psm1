# Pure helpers - easy to unit test

function Format-PcLogLine {
    param(
        [string]$Message,
        [string]$Level = 'INFO',
        [datetime]$Timestamp = (Get-Date)
    )
    return '[{0}] [{1}] {2}' -f $Timestamp.ToString('HH:mm:ss'), $Level, $Message
}

function ConvertFrom-PowerCfgPlanName {
    param([string]$PowerCfgOutput)
    if ($PowerCfgOutput -match '\((.+)\)\s*\*?$') { return $matches[1].Trim() }
    if ($PowerCfgOutput -match '\((.+)\)') { return $matches[1].Trim() }
    return 'Desconocido'
}

function Get-DiskUsagePercent {
    param(
        [long]$SizeBytes,
        [long]$FreeBytes
    )
    if ($SizeBytes -le 0) { return 0 }
    return [math]::Round((($SizeBytes - $FreeBytes) / $SizeBytes) * 100, 1)
}

function ConvertTo-PcSnapshot {
    param(
        $Cpu,
        $RamModules,
        $Disk,
        $Gpu,
        [string]$PowerCfgText,
        [long]$DownloadsBytes = 0,
        [bool]$IsAdmin = $false,
        $OsMemory = $null
    )
    $ramTotal = ($RamModules | Measure-Object -Property Capacity -Sum).Sum
    if (-not $ramTotal) { $ramTotal = 0 }

    $ramFree = 0L
    if ($OsMemory) {
        $ramFree = [long]$OsMemory.FreePhysicalMemory * 1024
        if ($ramTotal -eq 0 -and $OsMemory.TotalVisibleMemorySize) {
            $ramTotal = [long]$OsMemory.TotalVisibleMemorySize * 1024
        }
    }
    $ramUsedPct = if ($ramTotal -gt 0) {
        Get-DiskUsagePercent -SizeBytes $ramTotal -FreeBytes $ramFree
    } else { 0 }

    return [pscustomobject]@{
        CpuName     = $Cpu.Name
        CpuLoad     = $Cpu.LoadPercentage
        RamGb       = [math]::Round($ramTotal / 1GB, 1)
        RamFreeGb   = [math]::Round($ramFree / 1GB, 1)
        RamUsedPct  = $ramUsedPct
        DiskFreeGb  = if ($Disk) { [math]::Round($Disk.FreeSpace / 1GB, 1) } else { 0 }
        DiskTotalGb = if ($Disk) { [math]::Round($Disk.Size / 1GB, 1) } else { 0 }
        DiskUsedPct = if ($Disk) { Get-DiskUsagePercent $Disk.Size $Disk.FreeSpace } else { 0 }
        GpuName     = $Gpu.Name
        GpuDriver   = $Gpu.DriverVersion
        PowerPlan   = ConvertFrom-PowerCfgPlanName $PowerCfgText
        DownloadsGb = if ($DownloadsBytes -lt 0) { $null } else { [math]::Round($DownloadsBytes / 1GB, 1) }
        IsAdmin     = $IsAdmin
    }
}

function Get-PcHighPerformanceSchemeGuid {
    return '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
}

function Test-PcActionRequiresAdmin {
    param([string]$ActionName)
    $adminActions = @(
        'Disk Cleanup (sistema)',
        'Detener SQL Server',
        'Invoke-PcDiskCleanupFull',
        'Stop-PcSqlServices'
    )
    return $adminActions -contains $ActionName
}

function Get-PcDefaultMachineConfig {
    return @{
        version = 1
        machine = @{
            label        = 'PC generica'
            model        = ''
            manufacturer = ''
        }
        thresholds = @{
            ram_warning_gb            = 8
            ram_ideal_gb              = 16
            disk_used_warn_pct        = 75
            disk_used_critical_pct    = 85
            cpu_load_warn_pct         = 80
            startup_count_warn        = 15
            pagefile_usage_warn_ratio = 0.5
        }
        sql_services = @{
            name_patterns   = @('MSSQL$*', 'MSSQLSERVER', 'SQLBrowser')
            known_instances = @()
        }
        support_urls = @{
            Lenovo  = 'https://pcsupport.lenovo.com/'
            Dell    = 'https://www.dell.com/support/home'
            HP      = 'https://support.hp.com/'
            ASUS    = 'https://www.asus.com/support/'
            default = 'https://www.google.com/search?q=windows+10+drivers+download'
        }
        downloads = @{
            min_folder_bytes   = 52428800
            large_folder_hints = @()
        }
        drivers = @{
            banner = 'Actualiza drivers desde el sitio del fabricante.'
            notes  = @{}
        }
        workload_processes = @('SLDWORKS', 'MATLAB', 'sqlservr', 'MsMpEng')
        score = @{
            weights = @{
                memory         = 25
                storage        = 20
                cpu_pressure   = 15
                startup_bloat  = 15
                power          = 10
                software_risk  = 15
            }
            grades = @{
                good = 75
                fair = 55
            }
        }
    } | ConvertTo-Json -Depth 8 | ConvertFrom-Json
}

function Get-PcMachineConfig {
    param([string]$ProjectRoot)

    if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
        if ($script:PcHealthRoot) { $ProjectRoot = $script:PcHealthRoot }
        elseif ($PSScriptRoot) { $ProjectRoot = Split-Path $PSScriptRoot -Parent }
        else { $ProjectRoot = (Get-Location).Path }
    }

    $localPath = Join-Path $ProjectRoot 'config\machine.local.json'
    $path = Join-Path $ProjectRoot 'config\machine.json'
    foreach ($cfgPath in @($localPath, $path)) {
        if (Test-Path $cfgPath) {
            try {
                return Get-Content -Path $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
            } catch { }
        }
    }
    return Get-PcDefaultMachineConfig
}

function Test-PcIsBaselineObject {
    param($InputObject)
    if (-not $InputObject) { return $false }
    $names = @($InputObject.PSObject.Properties.Name)
    return ($names -contains 'memory') -and ($names -contains 'cpu')
}

function Get-PcDriverNoteMap {
    $cfg = Get-PcMachineConfig
    $map = @{}
    if ($cfg.drivers -and $cfg.drivers.notes) {
        foreach ($prop in $cfg.drivers.notes.PSObject.Properties) {
            $map[$prop.Name] = [string]$prop.Value
        }
    }
    if ($map.Count -eq 0) {
        return @{}
    }
    return $map
}

function Get-PcScoreGrade {
    param(
        [double]$Total,
        $Config
    )
    if (-not $Config) { $Config = Get-PcMachineConfig }
    $good = if ($Config.score.grades.good) { [double]$Config.score.grades.good } else { 75 }
    $fair = if ($Config.score.grades.fair) { [double]$Config.score.grades.fair } else { 55 }
    if ($Total -ge $good) { return 'Good' }
    if ($Total -ge $fair) { return 'Fair' }
    return 'Poor'
}

function Get-PcCategoryScore-Memory {
    param($Data, $Config)
    $t = $Config.thresholds
    $score = 100.0

    $ramGb = if ($Data.RamTotalGb) { [double]$Data.RamTotalGb } else { [double]$Data.RamGb }
    $ideal = if ($t.ram_ideal_gb) { [double]$t.ram_ideal_gb } else { 16 }
    $warn = if ($t.ram_warning_gb) { [double]$t.ram_warning_gb } else { 8 }

    if ($ramGb -ge $ideal) { $score = 100 }
    elseif ($ramGb -ge 12) { $score = 85 }
    elseif ($ramGb -ge $warn) { $score = 60 }
    else { $score = 40 }

    if ($null -ne $Data.RamUsedPct -and [double]$Data.RamUsedPct -gt 85) { $score -= 15 }
    if ($Data.PagefileUsedMb -and $Data.PagefileAllocatedMb -gt 0) {
        $ratio = [double]$Data.PagefileUsedMb / [double]$Data.PagefileAllocatedMb
        $pfWarn = if ($t.pagefile_usage_warn_ratio) { [double]$t.pagefile_usage_warn_ratio } else { 0.5 }
        if ($ratio -gt $pfWarn) { $score -= 20 }
    }

    return [math]::Round([math]::Max(0, [math]::Min(100, $score)), 0)
}

function Get-PcCategoryScore-Storage {
    param($Data, $Config)
    $t = $Config.thresholds
    $used = [double]$Data.DiskUsedPct
    $warn = if ($t.disk_used_warn_pct) { [double]$t.disk_used_warn_pct } else { 75 }
    $crit = if ($t.disk_used_critical_pct) { [double]$t.disk_used_critical_pct } else { 85 }

    $score = if ($used -lt 70) { 100 }
             elseif ($used -lt $warn) { 85 }
             elseif ($used -lt $crit) { 60 }
             else { 30 }

    if ($Data.DiskHealth -and $Data.DiskHealth -notmatch 'Healthy|OK') { $score -= 30 }

    return [math]::Round([math]::Max(0, [math]::Min(100, $score)), 0)
}

function Get-PcCategoryScore-CpuPressure {
    param($Data, $Config)
    $load = [double]$Data.CpuLoadPct
    if ($load -lt 30) { return 100 }
    if ($load -lt 50) { return 85 }
    if ($load -lt 70) { return 70 }
    if ($load -lt 85) { return 50 }
    return 25
}

function Get-PcCategoryScore-StartupBloat {
    param($Data, $Config)
    if ($null -eq $Data.StartupCount) { return 70 }
    $count = [int]$Data.StartupCount
    $warn = if ($Config.thresholds.startup_count_warn) { [int]$Config.thresholds.startup_count_warn } else { 15 }
    if ($count -le 10) { return 100 }
    if ($count -le $warn) { return 80 }
    if ($count -le 25) { return 60 }
    return 40
}

function Get-PcCategoryScore-Power {
    param($Data)
    $plan = [string]$Data.PowerPlan
    if ($plan -match 'Alto rendimiento|High performance|rendimiento|performance') { return 100 }
    if ($plan -match 'Equilibrado|Balanced') { return 70 }
    if ($plan -match 'Ahorro|Power saver|ahorro') { return 40 }
    return 60
}

function Get-PcCategoryScore-SoftwareRisk {
    param($Data, $Config)
    $workloads = @($Config.workload_processes | ForEach-Object { [string]$_ })
    if ($workloads.Count -eq 0) { return 100 }

    $procs = @($Data.TopProcesses)
    if ($procs.Count -eq 0) { return 100 }

    $ramTotalMb = if ($Data.RamTotalGb) { [double]$Data.RamTotalGb * 1024 } elseif ($Data.RamGb) { [double]$Data.RamGb * 1024 } else { 0 }
    $heavyRam = 0L
    $heavyInTop5 = 0

    $i = 0
    foreach ($p in $procs) {
        $name = [string]$p.Name
        $isHeavy = $false
        foreach ($w in $workloads) {
            if ($name -like "*$w*") { $isHeavy = $true; break }
        }
        if ($isHeavy) {
            $heavyRam += [long]$p.RAM_MB
            if ($i -lt 5) { $heavyInTop5++ }
        }
        $i++
    }

    if ($heavyInTop5 -eq 0) { return 100 }
    if ($heavyInTop5 -ge 2) { $score = 50 } else { $score = 75 }

    if ($ramTotalMb -gt 0 -and ($heavyRam / $ramTotalMb) -gt 0.7) { $score = 40 }
    if ($Data.RamTotalGb -and [double]$Data.RamTotalGb -lt 12 -and $heavyInTop5 -ge 1) {
        $score = [math]::Min($score, 45)
    }

    return [math]::Round([math]::Max(0, $score), 0)
}

function ConvertTo-PcScoreData {
    param($InputObject)

    if (Test-PcIsBaselineObject $InputObject) {
        $disk = @($InputObject.storage | Where-Object { $_.drive -eq 'C:' } | Select-Object -First 1)
        $pf = @($InputObject.pagefile | Select-Object -First 1)
        $pd = @($InputObject.physical_disk | Select-Object -First 1)
        return [pscustomobject]@{
            Source               = 'baseline'
            RamTotalGb           = $InputObject.memory.total_gb
            RamUsedPct           = $null
            DiskUsedPct          = if ($disk) { $disk.used_pct } else { 0 }
            DiskFreeGb           = if ($disk) { $disk.free_gb } else { 0 }
            DiskHealth           = if ($pd) { $pd.health } else { 'Unknown' }
            CpuLoadPct           = $InputObject.cpu.load_pct
            StartupCount         = @($InputObject.startup).Count
            PagefileUsedMb       = if ($pf) { $pf.used_mb } else { 0 }
            PagefileAllocatedMb  = if ($pf) { $pf.allocated_mb } else { 0 }
            PowerPlan            = ConvertFrom-PowerCfgPlanName ([string]$InputObject.power_plan)
            TopProcesses         = @($InputObject.top_processes)
        }
    }

    return [pscustomobject]@{
        Source               = 'snapshot'
        RamTotalGb           = $InputObject.RamGb
        RamGb                = $InputObject.RamGb
        RamUsedPct           = $InputObject.RamUsedPct
        DiskUsedPct          = $InputObject.DiskUsedPct
        DiskFreeGb           = $InputObject.DiskFreeGb
        DiskHealth           = 'Unknown'
        CpuLoadPct           = $InputObject.CpuLoad
        StartupCount         = $null
        PagefileUsedMb       = $null
        PagefileAllocatedMb  = $null
        PowerPlan            = $InputObject.PowerPlan
        TopProcesses         = @()
    }
}

function Get-PcHealthScore {
    param(
        $InputObject,
        $Config = $null
    )

    if (-not $Config) { $Config = Get-PcMachineConfig }
    $data = ConvertTo-PcScoreData -InputObject $InputObject

    $weights = $Config.score.weights
    $wMem = if ($weights.memory) { [double]$weights.memory } else { 25 }
    $wSto = if ($weights.storage) { [double]$weights.storage } else { 20 }
    $wCpu = if ($weights.cpu_pressure) { [double]$weights.cpu_pressure } else { 15 }
    $wSta = if ($weights.startup_bloat) { [double]$weights.startup_bloat } else { 15 }
    $wPow = if ($weights.power) { [double]$weights.power } else { 10 }
    $wSw  = if ($weights.software_risk) { [double]$weights.software_risk } else { 15 }

    $categories = [ordered]@{
        Memory        = Get-PcCategoryScore-Memory -Data $data -Config $Config
        Storage       = Get-PcCategoryScore-Storage -Data $data -Config $Config
        CpuPressure   = Get-PcCategoryScore-CpuPressure -Data $data -Config $Config
        StartupBloat  = Get-PcCategoryScore-StartupBloat -Data $data -Config $Config
        Power         = Get-PcCategoryScore-Power -Data $data
        SoftwareRisk  = Get-PcCategoryScore-SoftwareRisk -Data $data -Config $Config
    }

    $total = (
        ($categories.Memory * $wMem) +
        ($categories.Storage * $wSto) +
        ($categories.CpuPressure * $wCpu) +
        ($categories.StartupBloat * $wSta) +
        ($categories.Power * $wPow) +
        ($categories.SoftwareRisk * $wSw)
    ) / 100.0

    $total = [math]::Round([math]::Max(0, [math]::Min(100, $total)), 0)

    return [pscustomobject]@{
        Total      = $total
        Grade      = Get-PcScoreGrade -Total $total -Config $Config
        Categories = $categories
        Source     = $data.Source
        Weights    = $weights
    }
}

function Get-PcBaselineMetrics {
    param($Baseline)

    $disk = @($Baseline.storage | Where-Object { $_.drive -eq 'C:' } | Select-Object -First 1)
    $pf = @($Baseline.pagefile | Select-Object -First 1)
    $pd = @($Baseline.physical_disk | Select-Object -First 1)

    return [pscustomobject]@{
        CollectedAt      = $Baseline.collected_at
        Hostname         = $Baseline.hostname
        CpuLoadPct       = $Baseline.cpu.load_pct
        RamTotalGb       = $Baseline.memory.total_gb
        DiskFreeGb       = if ($disk) { $disk.free_gb } else { $null }
        DiskUsedPct      = if ($disk) { $disk.used_pct } else { $null }
        PagefileUsedMb   = if ($pf) { $pf.used_mb } else { $null }
        StartupCount     = @($Baseline.startup).Count
        ProcessCount     = @($Baseline.top_processes).Count
        PowerPlan        = ConvertFrom-PowerCfgPlanName ([string]$Baseline.power_plan)
        DiskHealth       = if ($pd) { $pd.health } else { 'Unknown' }
        HealthScore      = (Get-PcHealthScore $Baseline).Total
    }
}

function Compare-PcBaseline {
    param(
        $Before,
        $After
    )

    $beforeM = Get-PcBaselineMetrics $Before
    $afterM  = Get-PcBaselineMetrics $After

    function Get-DeltaDisplay {
        param($Old, $New, [switch]$LowerIsBetter, [switch]$HigherIsBetter)
        if ($null -eq $Old -or $null -eq $New) { return '—' }
        $delta = [double]$New - [double]$Old
        if ([math]::Abs($delta) -lt 0.05) { return '0' }
        $sign = if ($delta -gt 0) { '+' } else { '' }
        $text = "$sign$([math]::Round($delta, 1))"
        if ($LowerIsBetter) {
            if ($delta -lt 0) { return "$text (mejor)" }
            if ($delta -gt 0) { return "$text (peor)" }
        }
        if ($HigherIsBetter) {
            if ($delta -gt 0) { return "$text (mejor)" }
            if ($delta -lt 0) { return "$text (peor)" }
        }
        return $text
    }

    $rows = @(
        [pscustomobject]@{ Metric = 'Fecha'; Before = $beforeM.CollectedAt; After = $afterM.CollectedAt; Delta = '—' }
        [pscustomobject]@{ Metric = 'Health score (/100)'; Before = $beforeM.HealthScore; After = $afterM.HealthScore; Delta = (Get-DeltaDisplay $beforeM.HealthScore $afterM.HealthScore -HigherIsBetter) }
        [pscustomobject]@{ Metric = 'CPU load (%)'; Before = $beforeM.CpuLoadPct; After = $afterM.CpuLoadPct; Delta = (Get-DeltaDisplay $beforeM.CpuLoadPct $afterM.CpuLoadPct -LowerIsBetter) }
        [pscustomobject]@{ Metric = 'RAM total (GB)'; Before = $beforeM.RamTotalGb; After = $afterM.RamTotalGb; Delta = (Get-DeltaDisplay $beforeM.RamTotalGb $afterM.RamTotalGb -HigherIsBetter) }
        [pscustomobject]@{ Metric = 'Disco C: libre (GB)'; Before = $beforeM.DiskFreeGb; After = $afterM.DiskFreeGb; Delta = (Get-DeltaDisplay $beforeM.DiskFreeGb $afterM.DiskFreeGb -HigherIsBetter) }
        [pscustomobject]@{ Metric = 'Disco C: usado (%)'; Before = $beforeM.DiskUsedPct; After = $afterM.DiskUsedPct; Delta = (Get-DeltaDisplay $beforeM.DiskUsedPct $afterM.DiskUsedPct -LowerIsBetter) }
        [pscustomobject]@{ Metric = 'Pagefile usado (MB)'; Before = $beforeM.PagefileUsedMb; After = $afterM.PagefileUsedMb; Delta = (Get-DeltaDisplay $beforeM.PagefileUsedMb $afterM.PagefileUsedMb -LowerIsBetter) }
        [pscustomobject]@{ Metric = 'Programas inicio'; Before = $beforeM.StartupCount; After = $afterM.StartupCount; Delta = (Get-DeltaDisplay $beforeM.StartupCount $afterM.StartupCount -LowerIsBetter) }
        [pscustomobject]@{ Metric = 'Top procesos (n)'; Before = $beforeM.ProcessCount; After = $afterM.ProcessCount; Delta = (Get-DeltaDisplay $beforeM.ProcessCount $afterM.ProcessCount) }
        [pscustomobject]@{ Metric = 'Plan energia'; Before = $beforeM.PowerPlan; After = $afterM.PowerPlan; Delta = if ($beforeM.PowerPlan -eq $afterM.PowerPlan) { 'sin cambio' } else { 'cambio' } }
        [pscustomobject]@{ Metric = 'Salud disco fisico'; Before = $beforeM.DiskHealth; After = $afterM.DiskHealth; Delta = if ($beforeM.DiskHealth -eq $afterM.DiskHealth) { 'sin cambio' } else { 'cambio' } }
    )

    return [pscustomobject]@{
        Before    = $beforeM
        After     = $afterM
        Rows      = $rows
        Improved  = ($afterM.HealthScore -gt $beforeM.HealthScore)
        ScoreDelta = $afterM.HealthScore - $beforeM.HealthScore
    }
}

function Format-PcBaselineComparisonMarkdown {
    param($Comparison)

    $lines = @(
        '# Comparacion de baseline PC Health',
        '',
        ('**Antes:** {0} ({1})' -f $Comparison.Before.CollectedAt, $Comparison.Before.Hostname),
        ('**Despues:** {0} ({1})' -f $Comparison.After.CollectedAt, $Comparison.After.Hostname),
        '',
        '| Metrica | Antes | Despues | Delta |',
        '|---------|------:|--------:|-------|'
    )

    foreach ($row in $Comparison.Rows) {
        $lines += ('| {0} | {1} | {2} | {3} |' -f $row.Metric, $row.Before, $row.After, $row.Delta)
    }

    $trend = if ($Comparison.Improved) { 'mejora' } elseif ($Comparison.ScoreDelta -lt 0) { 'regresion' } else { 'sin cambio neto' }
    $lines += ''
    $lines += ('**Resumen:** score {0} -> {1} ({2:+0;-0} pts) — {3}' -f `
        $Comparison.Before.HealthScore, $Comparison.After.HealthScore, $Comparison.ScoreDelta, $trend)
    $lines += ''
    $lines += '_Generado por scripts/Compare-Baseline.ps1_'

    return ($lines -join "`r`n")
}

function ConvertTo-PcDriverReport {
    param($SignedDrivers)
    $map = Get-PcDriverNoteMap
    $drivers = @()
    foreach ($d in $SignedDrivers) {
        if ([string]::IsNullOrWhiteSpace($d.DeviceName)) { continue }
        if (-not $map.ContainsKey($d.DeviceName)) { continue }
        $drivers += [pscustomobject]@{
            Device  = $d.DeviceName
            Version = $d.DriverVersion
            Date    = if ($d.DriverDate) { $d.DriverDate.ToString('yyyy-MM-dd') } else { '' }
            Note    = $map[$d.DeviceName]
        }
    }
    return @($drivers)
}

function ConvertTo-PcDownloadsReport {
    param(
        $FolderSizes,
        $TopFiles,
        $Config = $null
    )
    if (-not $Config) { $Config = Get-PcMachineConfig }
    $minBytes = if ($Config.downloads.min_folder_bytes) { [long]$Config.downloads.min_folder_bytes } else { 52428800 }
    $items = @()
    foreach ($f in $FolderSizes) {
        if ($f.Bytes -gt $minBytes) {
            $items += [pscustomobject]@{
                Name   = $f.Name
                Type   = 'Carpeta'
                SizeGb = [math]::Round($f.Bytes / 1GB, 2)
            }
        }
    }
    foreach ($file in $TopFiles) {
        $items += [pscustomobject]@{
            Name   = $file.Name
            Type   = 'Archivo'
            SizeGb = [math]::Round($file.Length / 1GB, 2)
        }
    }
    return $items | Sort-Object SizeGb -Descending
}

Export-ModuleMember -Function @(
    'Format-PcLogLine',
    'ConvertFrom-PowerCfgPlanName',
    'Get-DiskUsagePercent',
    'ConvertTo-PcSnapshot',
    'Get-PcHighPerformanceSchemeGuid',
    'Test-PcActionRequiresAdmin',
    'Get-PcMachineConfig',
    'Get-PcDefaultMachineConfig',
    'Test-PcIsBaselineObject',
    'Get-PcDriverNoteMap',
    'ConvertTo-PcDriverReport',
    'ConvertTo-PcDownloadsReport',
    'Get-PcHealthScore',
    'Get-PcBaselineMetrics',
    'Compare-PcBaseline',
    'Format-PcBaselineComparisonMarkdown'
)
