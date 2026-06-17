$src = Join-Path (Split-Path $PSScriptRoot -Parent) 'src'
Import-Module (Join-Path $src 'PcHealth.Gui.psm1') -Force

Describe 'PcHealth GUI module' {
    It 'loads WinForms assemblies' {
        (Test-PcGuiCanLoad) | Should Be $true
    }

    It 'creates safe fallback font' {
        $font = New-PcSafeFont -Family 'FontQueNoExisteXYZ' -Size 10
        ($null -ne $font) | Should Be $true
        $font.Dispose()
    }
}

Describe 'GUI launcher script' {
    It 'exists and parses without syntax errors' {
        $gui = Join-Path (Split-Path $PSScriptRoot -Parent) 'pchealth-gui.ps1'
        (Test-Path $gui) | Should Be $true

        $tokens = $null
        $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($gui, [ref]$tokens, [ref]$errors)
        $errors.Count | Should Be 0
    }
}

Describe 'PcHealth status emojis' {
    It 'formats status text with emoji' {
        (Get-PcStatusEmoji success).Length | Should BeGreaterThan 0
        (Format-PcStatusText -State error -Message 'fallo') | Should Match 'fallo'
    }
}

Describe 'ConvertTo-PcDataTable' {
    It 'returns a single DataTable without pipeline pollution' {
        $items = @(
            [pscustomobject]@{ Name = 'a'; RAM_MB = 100 },
            [pscustomobject]@{ Name = 'b'; RAM_MB = 200 }
        )
        $dt = ConvertTo-PcDataTable -Items $items -ColumnNames @('Name', 'RAM_MB')
        ($dt -is [System.Data.DataTable]) | Should Be $true
        $dt.Rows.Count | Should Be 2
        $dt.Columns.Count | Should Be 2
    }
}

Describe 'Test-PcGuiHealth' {
    It 'runs health checks on project' {
        $root = Split-Path $PSScriptRoot -Parent
        $h = Test-PcGuiHealth -ProjectRoot $root
        ($h.Checks.Count -ge 4) | Should Be $true
    }
}
