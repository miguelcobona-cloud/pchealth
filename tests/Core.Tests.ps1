$src = Join-Path (Split-Path $PSScriptRoot -Parent) 'src'
Import-Module (Join-Path $src 'PcHealth.Core.psm1') -Force

Describe 'Format-PcLogLine' {
    It 'formats timestamp level and message' {
        $dt = Get-Date '2026-06-16T10:30:00'
        Format-PcLogLine -Message 'hola' -Level 'INFO' -Timestamp $dt |
            Should Be '[10:30:00] [INFO] hola'
    }
}

Describe 'ConvertFrom-PowerCfgPlanName' {
    It 'parses active high performance plan' {
        $text = 'GUID de plan de energia: 8c5e7fda (Alto rendimiento) *'
        ConvertFrom-PowerCfgPlanName $text | Should Be 'Alto rendimiento'
    }

    It 'returns Desconocido for empty input' {
        ConvertFrom-PowerCfgPlanName '' | Should Be 'Desconocido'
    }
}

Describe 'Get-DiskUsagePercent' {
    It 'calculates used percent' {
        Get-DiskUsagePercent -SizeBytes 100GB -FreeBytes 25GB | Should Be 75.0
    }

    It 'returns 0 when size is 0' {
        Get-DiskUsagePercent -SizeBytes 0 -FreeBytes 0 | Should Be 0
    }
}

Describe 'ConvertTo-PcSnapshot' {
    It 'builds snapshot from CIM-like objects' {
        $cpu  = [pscustomobject]@{ Name = 'i7'; LoadPercentage = 42 }
        $ram  = @([pscustomobject]@{ Capacity = 8GB })
        $disk = [pscustomobject]@{ Size = 400GB; FreeSpace = 100GB }
        $gpu  = [pscustomobject]@{ Name = 'HD 5500'; DriverVersion = '20.19' }

        $s = ConvertTo-PcSnapshot -Cpu $cpu -RamModules $ram -Disk $disk -Gpu $gpu `
            -PowerCfgText '(Alto rendimiento) *' -DownloadsBytes 5GB -IsAdmin $true `
            -OsMemory ([pscustomobject]@{
                FreePhysicalMemory = 2097152
                TotalVisibleMemorySize = 8388608
            })

        $s.RamGb | Should Be 8
        $s.RamFreeGb | Should Be 2
        $s.RamUsedPct | Should Be 75.0
        $s.DiskUsedPct | Should Be 75.0
        $s.PowerPlan | Should Be 'Alto rendimiento'
        $s.DownloadsGb | Should Be 5
        $s.IsAdmin | Should Be $true
    }
}

Describe 'Get-PcHighPerformanceSchemeGuid' {
    It 'returns known Windows high performance GUID' {
        Get-PcHighPerformanceSchemeGuid |
            Should Be '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
    }
}

Describe 'Test-PcActionRequiresAdmin' {
    It 'flags SQL and disk cleanup full' {
        (Test-PcActionRequiresAdmin 'Detener SQL Server') | Should Be $true
        (Test-PcActionRequiresAdmin 'Alto rendimiento') | Should Be $false
    }
}

Describe 'ConvertTo-PcDriverReport' {
    It 'maps only known devices' {
        $signed = @(
            [pscustomobject]@{
                DeviceName = 'Intel(R) HD Graphics 5500'
                DriverVersion = '20.19.15.5171'
                DriverDate = [datetime]'2020-04-10'
            },
            [pscustomobject]@{
                DeviceName = 'Unknown Device'
                DriverVersion = '1.0'
                DriverDate = [datetime]'2020-01-01'
            }
        )
        $r = ConvertTo-PcDriverReport -SignedDrivers $signed
        (@($r).Count) | Should Be 1
        $r[0].Note | Should Match 'ultima version'
    }

    It 'skips drivers with null device name' {
        $signed = @(
            [pscustomobject]@{ DeviceName = $null; DriverVersion = '1.0'; DriverDate = $null },
            [pscustomobject]@{
                DeviceName = 'Intel(R) HD Graphics 5500'
                DriverVersion = '20.19'
                DriverDate = [datetime]'2020-04-10'
            }
        )
        $r = ConvertTo-PcDriverReport -SignedDrivers $signed
        (@($r).Count) | Should Be 1
    }
}

Describe 'ConvertTo-PcDownloadsReport' {
    It 'merges folders and files sorted by size' {
        $folders = @(
            [pscustomobject]@{ Name = 'small'; Bytes = 1MB }
            [pscustomobject]@{ Name = 'Solidworks'; Bytes = 30GB }
        )
        $files = @([pscustomobject]@{ Name = 'big.rar'; Length = 5GB })
        $r = ConvertTo-PcDownloadsReport -FolderSizes $folders -TopFiles $files
        $r[0].Name | Should Be 'Solidworks'
        $r[0].SizeGb | Should Be 30
    }
}

Describe 'Get-PcMachineConfig' {
    It 'loads config/machine.json from project root' {
        $root = Split-Path $PSScriptRoot -Parent
        $cfg = Get-PcMachineConfig -ProjectRoot $root
        ($cfg.machine.label.Length -gt 0) | Should Be $true
        ($cfg.score.weights.memory -eq 25) | Should Be $true
    }
}

Describe 'Get-PcHealthScore' {
    It 'scores baseline with weighted categories 0-100' {
        $baseline = @{
            collected_at  = '2026-01-01T00:00:00'
            hostname      = 'TEST'
            cpu           = @{ load_pct = 15 }
            memory        = @{ total_gb = 16 }
            storage       = @(@{ drive = 'C:'; free_gb = 200; used_pct = 50 })
            physical_disk = @(@{ health = 'Healthy' })
            pagefile      = @(@{ used_mb = 64; allocated_mb = 4096 })
            power_plan    = '(Alto rendimiento)'
            startup       = @(1..8)
            top_processes = @(@{ Name = 'explorer'; RAM_MB = 200 })
        } | ConvertTo-Json -Depth 6 | ConvertFrom-Json

        $score = Get-PcHealthScore -InputObject $baseline
        ($score.Total -ge 75) | Should Be $true
        ($score.Categories.Memory -ge 80) | Should Be $true
        ($score.Grade -eq 'Good') | Should Be $true
    }

    It 'penalizes low RAM, heavy disk and engineering workloads' {
        $baseline = @{
            collected_at  = '2026-01-01T00:00:00'
            hostname      = 'TEST'
            cpu           = @{ load_pct = 90 }
            memory        = @{ total_gb = 8 }
            storage       = @(@{ drive = 'C:'; free_gb = 80; used_pct = 82 })
            physical_disk = @(@{ health = 'Healthy' })
            pagefile      = @(@{ used_mb = 3000; allocated_mb = 4096 })
            power_plan    = 'Equilibrado'
            startup       = @(1..22)
            top_processes = @(
                @{ Name = 'SLDWORKS'; RAM_MB = 3000 }
                @{ Name = 'MATLAB'; RAM_MB = 2500 }
            )
        } | ConvertTo-Json -Depth 6 | ConvertFrom-Json

        $score = Get-PcHealthScore -InputObject $baseline
        ($score.Total -lt 60) | Should Be $true
    }

    It 'scores live snapshot objects' {
        $snap = [pscustomobject]@{
            RamGb = 8; RamUsedPct = 70; DiskUsedPct = 72
            CpuLoad = 25; PowerPlan = 'Alto rendimiento'
        }
        $score = Get-PcHealthScore -InputObject $snap
        ($score.Total -ge 40) | Should Be $true
        ($score.Source -eq 'snapshot') | Should Be $true
    }
}

Describe 'Compare-PcBaseline' {
    It 'builds markdown comparison between two baselines' {
        $before = @{
            collected_at  = '2026-01-01T00:00:00'
            hostname      = 'TEST'
            cpu           = @{ load_pct = 80 }
            memory        = @{ total_gb = 8 }
            storage       = @(@{ drive = 'C:'; free_gb = 100; used_pct = 78 })
            physical_disk = @(@{ health = 'Healthy' })
            pagefile      = @(@{ used_mb = 200; allocated_mb = 4096 })
            power_plan    = 'Equilibrado'
            startup       = @(1..18)
            top_processes = @(1..15 | ForEach-Object { @{ Name = "p$_"; RAM_MB = 100 } })
        } | ConvertTo-Json -Depth 6 | ConvertFrom-Json

        $after = @{
            collected_at  = '2026-01-02T00:00:00'
            hostname      = 'TEST'
            cpu           = @{ load_pct = 20 }
            memory        = @{ total_gb = 8 }
            storage       = @(@{ drive = 'C:'; free_gb = 130; used_pct = 71 })
            physical_disk = @(@{ health = 'Healthy' })
            pagefile      = @(@{ used_mb = 80; allocated_mb = 4096 })
            power_plan    = '(Alto rendimiento)'
            startup       = @(1..12)
            top_processes = @(1..15 | ForEach-Object { @{ Name = "p$_"; RAM_MB = 100 } })
        } | ConvertTo-Json -Depth 6 | ConvertFrom-Json

        $cmp = Compare-PcBaseline -Before $before -After $after
        ($cmp.ScoreDelta -gt 0) | Should Be $true
        $md = Format-PcBaselineComparisonMarkdown -Comparison $cmp
        ($md -match 'Comparacion de baseline') | Should Be $true
        ($md -match 'CPU load') | Should Be $true
    }
}
