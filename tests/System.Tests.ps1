$root = Split-Path $PSScriptRoot -Parent
$src  = Join-Path $root 'src'
Import-Module (Join-Path $src 'PcHealth.Core.psm1') -Force
Import-Module (Join-Path $src 'PcHealth.System.psm1') -Force

Describe 'Write-PcLog' {
    It 'invokes callback when set' {
        $script:seen = $null
        Set-PcLogCallback { param($line, $level) $script:seen = $line }
        $out = Write-PcLog 'test callback'
        ($out -match 'test callback') | Should Be $true
        ($script:seen -match 'test callback') | Should Be $true
        Clear-PcLogCallback
    }
}

Describe 'Invoke-PcDiskCleanupLite' {
    It 'removes crdownload files from temp test folder' {
        $testDl = Join-Path $TestDrive 'Downloads'
        New-Item -ItemType Directory -Path $testDl -Force | Out-Null
        $f = Join-Path $testDl 'partial.crdownload'
        Set-Content -Path $f -Value ('x' * 1024)

        $result = Invoke-PcDiskCleanupLite -DownloadsPath $testDl

        (Test-Path $f) | Should Be $false
        ($result.Removed -ge 1) | Should Be $true
        ($result.BytesFreed -gt 0) | Should Be $true
    }
}

Describe 'Get-PcDownloadsReport' {
    It 'returns empty array when folder missing' {
        $r = Get-PcDownloadsReport -DownloadsPath (Join-Path $TestDrive 'nope')
        $r.Count | Should Be 0
    }
}

Describe 'Open-PcExternal' {
    It 'throws on unknown target' {
        { Open-PcExternal 'invalid-target' } | Should Throw
    }
}

Describe 'Project layout' {
    It 'has required scripts and docs' {
        $proj = Get-PcProjectRoot
        (Test-Path (Join-Path $proj 'scripts\collect-baseline.ps1')) | Should Be $true
        (Test-Path (Join-Path $proj 'scripts\Compare-Baseline.ps1')) | Should Be $true
        (Test-Path (Join-Path $proj 'scripts\Install-PcHealthDesktop.ps1')) | Should Be $true
        (Test-Path (Join-Path $proj 'config\machine.json')) | Should Be $true
        (Test-Path (Join-Path $proj 'config\machine.json.example')) | Should Be $true
        (Test-Path (Join-Path $proj 'assets\icon.ico')) | Should Be $true
        (Test-Path (Join-Path $proj 'pchealth-gui.ps1')) | Should Be $true
    }
}
