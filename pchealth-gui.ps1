#Requires -Version 5.1
<#
.SYNOPSIS
    PC Health GUI - optimizacion visual del equipo.
.EXAMPLE
    .\pchealth-gui.ps1
#>

# WinForms requiere apartamento STA
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $launchArgs = @('-STA', '-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', $PSCommandPath)
    Start-Process powershell.exe -ArgumentList $launchArgs
    exit
}

$ErrorActionPreference = 'Continue'
$root = $PSScriptRoot
$src  = Join-Path $root 'src'
Import-Module (Join-Path $src 'PcHealth.Core.psm1') -Force
Import-Module (Join-Path $src 'PcHealth.System.psm1') -Force
Import-Module (Join-Path $src 'PcHealth.Gui.psm1') -Force

$script:MachineCfg = Get-PcMachineConfig -ProjectRoot $root

if (-not (Test-PcGuiCanLoad)) {
    [System.Windows.Forms.MessageBox]::Show(
        'No se pudo cargar Windows Forms en este equipo.',
        'PC Health', 'OK', 'Error'
    ) | Out-Null
    exit 1
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Tema visual ---
$script:Theme = @{
    Bg          = [Drawing.Color]::FromArgb(245, 247, 250)
    Surface     = [Drawing.Color]::White
    Header      = [Drawing.Color]::FromArgb(15, 23, 42)
    HeaderSub   = [Drawing.Color]::FromArgb(148, 163, 184)
    Accent      = [Drawing.Color]::FromArgb(14, 165, 233)
    AccentHover = [Drawing.Color]::FromArgb(2, 132, 199)
    AccentSoft  = [Drawing.Color]::FromArgb(224, 242, 254)
    Text        = [Drawing.Color]::FromArgb(30, 41, 59)
    TextMuted   = [Drawing.Color]::FromArgb(100, 116, 139)
    Border      = [Drawing.Color]::FromArgb(226, 232, 240)
    Success     = [Drawing.Color]::FromArgb(22, 163, 74)
    Warning     = [Drawing.Color]::FromArgb(234, 88, 12)
    Danger      = [Drawing.Color]::FromArgb(220, 38, 38)
    GridAlt     = [Drawing.Color]::FromArgb(248, 250, 252)
    GridHeader  = [Drawing.Color]::FromArgb(241, 245, 249)
    LogBg       = [Drawing.Color]::FromArgb(15, 23, 42)
    LogText     = [Drawing.Color]::FromArgb(148, 236, 172)
    Footer      = [Drawing.Color]::FromArgb(241, 245, 249)
}

$script:FontTitle   = New-PcSafeFont -Family 'Segoe UI' -Size 11 -Style ([Drawing.FontStyle]::Bold)
$script:FontHeading = New-PcSafeFont -Family 'Segoe UI' -Size 10 -Style ([Drawing.FontStyle]::Bold)
$script:FontBody    = New-PcSafeFont -Family 'Segoe UI' -Size 9
$script:FontSmall   = New-PcSafeFont -Family 'Segoe UI' -Size 8
$script:FontMetric  = New-PcSafeFont -Family 'Segoe UI' -Size 14 -Style ([Drawing.FontStyle]::Bold)
$script:FontMono    = New-PcSafeFont -Family 'Consolas' -Size 9

function Set-ThemeControl {
    param($Control, [string]$Role = 'surface')
    switch ($Role) {
        'surface' { $Control.BackColor = $script:Theme.Surface; $Control.ForeColor = $script:Theme.Text }
        'bg'      { $Control.BackColor = $script:Theme.Bg; $Control.ForeColor = $script:Theme.Text }
        'header'  { $Control.BackColor = $script:Theme.Header; $Control.ForeColor = [Drawing.Color]::White }
        'footer'  { $Control.BackColor = $script:Theme.Footer; $Control.ForeColor = $script:Theme.TextMuted }
        'muted'   { $Control.BackColor = $script:Theme.Surface; $Control.ForeColor = $script:Theme.TextMuted }
    }
    $Control.Font = $script:FontBody
}

function Style-DataGrid {
    param($Grid)
    $Grid.BackgroundColor = $script:Theme.Surface
    $Grid.BorderStyle = 'None'
    $Grid.CellBorderStyle = 'SingleHorizontal'
    $Grid.GridColor = $script:Theme.Border
    $Grid.RowHeadersVisible = $false
    $Grid.EnableHeadersVisualStyles = $false
    $Grid.ColumnHeadersDefaultCellStyle.BackColor = $script:Theme.GridHeader
    $Grid.ColumnHeadersDefaultCellStyle.ForeColor = $script:Theme.Text
    $Grid.ColumnHeadersDefaultCellStyle.Font = $script:FontHeading
    $Grid.ColumnHeadersDefaultCellStyle.Padding = New-Object System.Windows.Forms.Padding(8, 6, 8, 6)
    $Grid.ColumnHeadersHeight = 36
    $Grid.ColumnHeadersBorderStyle = 'Single'
    $Grid.DefaultCellStyle.BackColor = $script:Theme.Surface
    $Grid.DefaultCellStyle.ForeColor = $script:Theme.Text
    $Grid.DefaultCellStyle.SelectionBackColor = $script:Theme.AccentSoft
    $Grid.DefaultCellStyle.SelectionForeColor = $script:Theme.Text
    $Grid.DefaultCellStyle.Padding = New-Object System.Windows.Forms.Padding(8, 4, 8, 4)
    $Grid.AlternatingRowsDefaultCellStyle.BackColor = $script:Theme.GridAlt
    $Grid.RowTemplate.Height = 30
}

function New-ThemeButton {
    param(
        [string]$Text,
        [int]$Width = 200,
        [int]$Height = 36,
        [switch]$Primary,
        [switch]$Ghost
    )
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $Text
    $b.Size = New-Object System.Drawing.Size($Width, $Height)
    $b.FlatStyle = 'Flat'
    $b.Font = $script:FontHeading
    $b.Cursor = [Windows.Forms.Cursors]::Hand

    if ($Ghost) {
        $b.BackColor = $script:Theme.Surface
        $b.ForeColor = $script:Theme.Accent
        $b.FlatAppearance.BorderColor = $script:Theme.Border
        $b.FlatAppearance.BorderSize = 1
        $b.Add_MouseEnter({ $this.BackColor = $script:Theme.AccentSoft })
        $b.Add_MouseLeave({ $this.BackColor = $script:Theme.Surface })
    } elseif ($Primary) {
        $b.BackColor = $script:Theme.Accent
        $b.ForeColor = [Drawing.Color]::White
        $b.FlatAppearance.BorderSize = 0
        $b.Add_MouseEnter({ $this.BackColor = $script:Theme.AccentHover })
        $b.Add_MouseLeave({ $this.BackColor = $script:Theme.Accent })
    } else {
        $b.BackColor = $script:Theme.GridHeader
        $b.ForeColor = $script:Theme.Text
        $b.FlatAppearance.BorderColor = $script:Theme.Border
        $b.FlatAppearance.BorderSize = 1
        $b.Add_MouseEnter({ $this.BackColor = $script:Theme.Border })
        $b.Add_MouseLeave({ $this.BackColor = $script:Theme.GridHeader })
    }
    return $b
}

function New-MetricCard {
    param(
        [string]$Title,
        [string]$Key,
        [Drawing.Color]$AccentColor
    )
    $card = New-Object System.Windows.Forms.Panel
    $card.Size = New-Object System.Drawing.Size(200, 88)
    $card.Margin = New-Object System.Windows.Forms.Padding(0, 0, 12, 12)
    $card.BackColor = $script:Theme.Surface
    $card.Padding = New-Object System.Windows.Forms.Padding(14, 12, 14, 12)

    $stripe = New-Object System.Windows.Forms.Panel
    $stripe.Size = New-Object System.Drawing.Size(4, 64)
    $stripe.Location = New-Object System.Drawing.Point(0, 12)
    $stripe.BackColor = $AccentColor

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = $Title
    $lblTitle.Location = New-Object System.Drawing.Point(14, 10)
    $lblTitle.Size = New-Object System.Drawing.Size(180, 18)
    $lblTitle.Font = $script:FontSmall
    $lblTitle.ForeColor = $script:Theme.TextMuted
    $lblTitle.BackColor = $script:Theme.Surface

    $lblValue = New-Object System.Windows.Forms.Label
    $lblValue.Name = $Key
    $lblValue.Text = '-'
    $lblValue.Location = New-Object System.Drawing.Point(14, 30)
    $lblValue.Size = New-Object System.Drawing.Size(180, 44)
    $lblValue.Font = $script:FontMetric
    $lblValue.ForeColor = $script:Theme.Text
    $lblValue.BackColor = $script:Theme.Surface

    $card.Controls.AddRange(@($stripe, $lblTitle, $lblValue))
    return [pscustomobject]@{ Card = $card; ValueLabel = $lblValue }
}

function New-SectionHeader {
    param([string]$Text, [System.Windows.Forms.Control]$Parent = $null)
    $h = New-Object System.Windows.Forms.Label
    $h.Text = $Text
    $h.Dock = 'Top'
    $h.Height = 36
    $h.Font = $script:FontHeading
    $h.ForeColor = $script:Theme.Text
    $h.BackColor = $script:Theme.Bg
    $h.Padding = New-Object System.Windows.Forms.Padding(4, 8, 0, 0)
    if ($Parent) { $Parent.Controls.Add($h) }
    return $h
}

function New-InfoBanner {
    param([string]$Text)
    $p = New-Object System.Windows.Forms.Panel
    $p.Dock = 'Top'
    $p.Height = 72
    $p.BackColor = $script:Theme.AccentSoft
    $p.Padding = New-Object System.Windows.Forms.Padding(16, 12, 16, 12)

    $l = New-Object System.Windows.Forms.Label
    $l.Text = $Text
    $l.Dock = 'Fill'
    $l.Font = $script:FontBody
    $l.ForeColor = $script:Theme.Text
    $l.BackColor = $script:Theme.AccentSoft
    $p.Controls.Add($l)
    return $p
}

# --- Estado global ---
$script:MetricLabels = @{}
$script:ActionStatuses = @{}

function Format-PcShortStatus {
    param(
        [string]$Message,
        [int]$MaxLen = 88
    )
    if ([string]::IsNullOrEmpty($Message)) { return '' }
    if ($Message.Length -le $MaxLen) { return $Message }
    return $Message.Substring(0, $MaxLen - 3) + '...'
}

function Set-PcUiStatus {
    param(
        [ValidateSet('idle', 'running', 'success', 'error', 'warn')]
        [string]$State,
        [string]$Message
    )

    $colors = @{
        idle    = $script:Theme.Success
        running = $script:Theme.Warning
        success = $script:Theme.Success
        error   = $script:Theme.Danger
        warn    = $script:Theme.Warning
    }
    $bannerBg = @{
        idle    = [Drawing.Color]::FromArgb(220, 252, 231)
        running = [Drawing.Color]::FromArgb(254, 243, 199)
        success = [Drawing.Color]::FromArgb(220, 252, 231)
        error   = [Drawing.Color]::FromArgb(254, 226, 226)
        warn    = [Drawing.Color]::FromArgb(255, 247, 237)
    }

    $text = Format-PcStatusText -State $State -Message (Format-PcShortStatus $Message)
    $apply = {
        $script:StatusLabel.Text = $text
        $script:StatusDot.BackColor = $colors[$State]
        if ($script:LblStatusBanner) {
            $script:LblStatusBanner.Text = $text
            $script:LblStatusBanner.BackColor = $bannerBg[$State]
            $script:LblStatusBanner.ForeColor = $script:Theme.Text
        }
        if ($script:LblHealthScore) {
            if ($State -eq 'error') { $script:LblHealthScore.ForeColor = $script:Theme.Danger }
            elseif ($State -eq 'warn') { $script:LblHealthScore.ForeColor = $script:Theme.Warning }
            else { $script:LblHealthScore.ForeColor = $script:Theme.Success }
        }
    }

    if ($script:Form -and $script:Form.InvokeRequired) {
        $script:Form.Invoke([Action]$apply)
    } else {
        & $apply
    }
}

function Set-PcActionStatus {
    param(
        [string]$ActionName,
        [ValidateSet('idle', 'running', 'success', 'error', 'warn', 'skip')]
        [string]$State,
        [string]$Detail = ''
    )
    if ([string]::IsNullOrWhiteSpace($ActionName)) { return }
    if (-not $script:ActionStatuses) { return }
    if (-not $script:ActionStatuses.ContainsKey($ActionName)) { return }

    $lbl = $script:ActionStatuses[$ActionName]
    $msg = if ($Detail) { $Detail } else { $ActionName }
    $lbl.Text = Format-PcStatusText -State $State -Message $msg
    $lbl.ForeColor = switch ($State) {
        'success' { $script:Theme.Success }
        'error'   { $script:Theme.Danger }
        'running' { $script:Theme.Warning }
        'warn'    { $script:Theme.Warning }
        default   { $script:Theme.TextMuted }
    }
}

function Set-PcHealthScoreLabel {
    param(
        $ScoreInput,
        [switch]$UseHealthEmoji
    )
    if (-not $script:LblHealthScore) { return $null }

    try {
        $result = if ($null -eq $ScoreInput) {
            Get-PcHealthScore -InputObject (Get-PcSnapshot -SkipDownloadsScan) -Config $script:MachineCfg
        } elseif ($ScoreInput.PSObject.Properties.Name -contains 'Total') {
            $ScoreInput
        } else {
            Get-PcHealthScore -InputObject $ScoreInput -Config $script:MachineCfg
        }
    } catch {
        $result = [pscustomobject]@{ Total = 0; Grade = 'Error' }
    }

    $ok = $result.Total -ge 60
    $emoji = if ($UseHealthEmoji) {
        if ($ok) { Get-PcStatusEmoji success } else { Get-PcStatusEmoji warn }
    } elseif ($result.Total -ge 60) {
        Get-PcStatusEmoji success
    } elseif ($result.Total -ge 40) {
        Get-PcStatusEmoji warn
    } else {
        Get-PcStatusEmoji error
    }

    $script:LblHealthScore.Text = "$emoji  Score: $($result.Total)/100 ($($result.Grade))"
    $script:LblHealthScore.ForeColor = if ($result.Total -ge 60) {
        $script:Theme.Success
    } elseif ($result.Total -ge 40) {
        $script:Theme.Warning
    } else {
        $script:Theme.Danger
    }
    return $result
}

function Invoke-PcBaselineCompare {
    $compareScript = Join-Path $root 'scripts\Compare-Baseline.ps1'
    if (-not (Test-Path $compareScript)) {
        throw 'No se encontro scripts\Compare-Baseline.ps1'
    }
    $prev = Join-Path $root 'data\baseline.previous.json'
    if (-not (Test-Path $prev)) {
        throw 'No hay baseline anterior. Ejecuta Recolectar baseline dos veces (la segunda copia la previa).'
    }
    $result = & $compareScript -PassThru
    $msg = @(
        "Comparacion guardada en:",
        $result.OutputPath,
        '',
        ('Score: {0} -> {1} ({2:+0;-0} pts)' -f $result.Before.HealthScore, $result.After.HealthScore, $result.ScoreDelta)
    ) -join "`r`n"
    [Windows.Forms.MessageBox]::Show(
        $msg,
        'PC Health - Comparacion baseline',
        [Windows.Forms.MessageBoxButtons]::OK,
        [Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
    Write-PcLog "Comparacion baseline: $($result.Before.HealthScore) -> $($result.After.HealthScore)" 'INFO'
}

function Update-HealthChecks {
    param(
        [switch]$UpdateBanner,
        $Snapshot = $null
    )

    $health = Test-PcGuiHealth -ProjectRoot $root -Snapshot $Snapshot
    $lines = @($health.Checks | ForEach-Object { $_.Status })
    if ($script:TxtHealthChecks) {
        $script:TxtHealthChecks.Text = ($lines -join "`r`n")
    }
    if ($script:LblHealthScore) {
        Set-PcHealthScoreLabel -ScoreInput $Snapshot -UseHealthEmoji | Out-Null
    }
    if ($UpdateBanner) {
        $msg = if ($health.AllOk) {
            'GUI operativa - todos los chequeos OK'
        } else {
            ('GUI parcial - {0} chequeo(s) fallaron' -f $health.FailedCount)
        }
        Set-PcUiStatus -State $(if ($health.AllOk) { 'success' } else { 'warn' }) -Message $msg
    }
    return $health
}


$script:LogCallback = {
    param($Line, $Level)
    if ($script:TxtLog -and -not $script:TxtLog.IsDisposed) {
        $append = {
            $color = $script:Theme.LogText
            if ($Level -eq 'ERROR') { $color = [Drawing.Color]::FromArgb(252, 165, 165) }
            elseif ($Level -eq 'WARN') { $color = [Drawing.Color]::FromArgb(253, 224, 71) }
            $script:TxtLog.SelectionStart = $script:TxtLog.Text.Length
            $script:TxtLog.SelectionLength = 0
            $script:TxtLog.SelectionColor = $color
            $script:TxtLog.AppendText("$Line`r`n")
            $script:TxtLog.SelectionStart = $script:TxtLog.Text.Length
            $script:TxtLog.ScrollToCaret()
        }
        if ($script:TxtLog.InvokeRequired) {
            $script:TxtLog.Invoke([Action]$append)
        } else {
            & $append
        }
    }
}

function Get-TrafficColor {
    param([double]$Pct, [switch]$Inverse)
    if ($Inverse) {
        if ($Pct -lt 30) { return $script:Theme.Success }
        if ($Pct -lt 70) { return $script:Theme.Warning }
        return $script:Theme.Danger
    }
    if ($Pct -gt 85) { return $script:Theme.Danger }
    if ($Pct -gt 70) { return $script:Theme.Warning }
    return $script:Theme.Success
}

function Set-MetricLabel {
    param(
        [string]$Key,
        [string]$Text,
        [System.Drawing.Color]$Color,
        [System.Drawing.Font]$Font = $null
    )
    if (-not $script:MetricLabels.ContainsKey($Key)) { return }
    $lbl = $script:MetricLabels[$Key]
    if (-not $lbl) { return }
    $lbl.Text = $Text
    if ($Color) { $lbl.ForeColor = $Color }
    if ($Font) { $lbl.Font = $Font }
}

function Set-PcGridData {
    param($Grid, $Items, [string[]]$ColumnNames)
    if (-not $Grid) { return }
    $Grid.DataSource = $null
    $dt = ConvertTo-PcDataTable -Items $Items -ColumnNames $ColumnNames
    $Grid.DataSource = $dt
}

function Update-DiskTab {
    if ($script:DiskTabLoaded) { return }
    try {
        Set-PcUiStatus -State running -Message 'Analizando carpeta Downloads...'
        [System.Windows.Forms.Application]::DoEvents()
        Set-PcGridData -Grid $script:GridDownloads -Items @(Get-PcDownloadsReport) -ColumnNames @('Name', 'Type', 'SizeGb')
        $script:DiskTabLoaded = $true
    } catch {
        Write-PcLog $_.Exception.Message 'ERROR'
    }
}

function Update-DriversTab {
    if ($script:DriversTabLoaded) { return }
    try {
        Set-PcUiStatus -State running -Message 'Leyendo drivers y firewall...'
        [System.Windows.Forms.Application]::DoEvents()
        Set-PcGridData -Grid $script:GridDrivers -Items @(Get-PcDriverReport) -ColumnNames @('Device', 'Version', 'Date', 'Note')
        $fw = Get-PcFirewallReport
        $fwText = "Firewall activo en todos los perfiles. Salida: Permitida por defecto.`r`n"
        $fwText += "Reglas BLOCK activas: $($fw.BlockRules.Count)`r`n"
        foreach ($b in $fw.BlockRules) {
            $fwText += "  • $($b.DisplayName) [$($b.Direction)]`r`n"
        }
        $script:TxtFirewall.Text = $fwText
        $script:DriversTabLoaded = $true
    } catch {
        Write-PcLog $_.Exception.Message 'ERROR'
    }
}

function Update-Dashboard {
    param(
        [ValidateSet('Lite', 'Full')]
        [string]$Mode = 'Full'
    )
    try {
        $s = Get-PcSnapshot -SkipDownloadsScan:($Mode -eq 'Lite')

        Set-MetricLabel 'cpu' "$($s.CpuLoad)%" (Get-TrafficColor $s.CpuLoad)

        $ramColor = if ($s.RamUsedPct -gt 85) { $script:Theme.Danger }
                    elseif ($s.RamUsedPct -gt 70) { $script:Theme.Warning }
                    else { $script:Theme.Success }
        Set-MetricLabel 'ram' ('{0}/{1} GB' -f $s.RamFreeGb, $s.RamGb) $ramColor (New-PcSafeFont -Size 12 -Style ([Drawing.FontStyle]::Bold))
        Set-MetricLabel 'rampct' ('{0}% usada' -f $s.RamUsedPct) $ramColor

        Set-MetricLabel 'disk' "$($s.DiskFreeGb) GB" (Get-TrafficColor $s.DiskUsedPct)
        Set-MetricLabel 'diskpct' "$($s.DiskUsedPct)% usado" (Get-TrafficColor $s.DiskUsedPct)

        $gpuName = if ($s.GpuName) { [string]$s.GpuName } else { 'N/D' }
        $gpuShort = if ($gpuName.Length -gt 22) { $gpuName.Substring(0, 20) + '...' } else { $gpuName }
        Set-MetricLabel 'gpu' $gpuShort $script:Theme.Text (New-PcSafeFont -Size 10 -Style ([Drawing.FontStyle]::Bold))

        $powerText = if ($s.PowerPlan -match 'Alto') { 'Alto rend.' } else { $s.PowerPlan }
        $powerColor = if ($s.PowerPlan -match 'Alto') { $script:Theme.Success } else { $script:Theme.Warning }
        Set-MetricLabel 'power' $powerText $powerColor

        $dlText = if ($null -eq $s.DownloadsGb) { '...' } else { "$($s.DownloadsGb) GB" }
        Set-MetricLabel 'downloads' $dlText $script:Theme.TextMuted

        if ($script:LblCpuDetail) {
            $script:LblCpuDetail.Text = if ($s.CpuName) { $s.CpuName } else { 'CPU: N/D' }
        }
        if ($script:LblAdminBadge) {
            $script:LblAdminBadge.Text = if ($s.IsAdmin) { '  Administrador  ' } else { '  Usuario  ' }
            $script:LblAdminBadge.BackColor = if ($s.IsAdmin) { $script:Theme.Success } else { $script:Theme.Warning }
        }

        $procs = @(Get-PcTopProcesses)
        Set-PcGridData -Grid $script:GridProcs -Items $procs -ColumnNames @('Name', 'RAM_MB')

        if ($Mode -eq 'Full') {
            $s = Get-PcSnapshot
            $script:LastSnapshot = $s
            Set-MetricLabel 'downloads' "$($s.DownloadsGb) GB" $script:Theme.TextMuted
        } else {
            $script:LastSnapshot = $s
        }

        if ($script:LblHealthScore) {
            Set-PcHealthScoreLabel -ScoreInput $script:LastSnapshot | Out-Null
        }
        Set-PcUiStatus -State idle -Message 'Dashboard actualizado'
    } catch {
        Set-PcUiStatus -State error -Message ('Dashboard: ' + $_.Exception.Message)
        Write-PcLog $_.Exception.Message 'ERROR'
    }
}

function Invoke-PcAction {
    param(
        [scriptblock]$Action,
        [string]$Name,
        [switch]$NeedAdmin
    )
    if ($NeedAdmin -and -not (Test-IsAdmin)) {
        Set-PcUiStatus -State warn -Message "Se requiere Admin para: $Name"
        Set-PcActionStatus -ActionName $Name -State warn -Detail 'Necesita Administrador'
        [Windows.Forms.MessageBox]::Show(
            "$(Get-PcStatusEmoji warn) La accion '$Name' requiere Administrador.`r`n`r`nUsa el boton 'Reiniciar como Administrador' abajo.",
            'PC Health',
            [Windows.Forms.MessageBoxButtons]::OK,
            [Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    Set-PcUiStatus -State running -Message "Ejecutando: $Name..."
    Set-PcActionStatus -ActionName $Name -State running -Detail 'En progreso...'
    $script:Form.Refresh()

    $ok = $false
    try {
        & $Action
        $ok = $true
        Set-PcActionStatus -ActionName $Name -State success -Detail 'Completado OK'
        Set-PcUiStatus -State success -Message "Listo: $Name"
        Write-PcLog "$(Get-PcStatusEmoji success) OK: $Name" 'INFO'
    } catch {
        Set-PcActionStatus -ActionName $Name -State error -Detail $_.Exception.Message
        Set-PcUiStatus -State error -Message "Fallo: $Name"
        Write-PcLog "$(Get-PcStatusEmoji error) ERROR en $Name : $($_.Exception.Message)" 'ERROR'
        [Windows.Forms.MessageBox]::Show(
            "$(Get-PcStatusEmoji error) Error en '$Name':`r`n`r`n$($_.Exception.Message)",
            'PC Health - Error',
            [Windows.Forms.MessageBoxButtons]::OK,
            [Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    } finally {
        if (-not $ok -and -not $NeedAdmin) {
            # status already set in catch
        }
        Update-Dashboard
    }
}

# --- Formulario principal ---
$script:Form = New-Object System.Windows.Forms.Form
$script:Form.Text = 'PC Health'
$script:Form.Size = New-Object System.Drawing.Size(980, 720)
$script:Form.StartPosition = 'CenterScreen'
$script:Form.Font = $script:FontBody
$script:Form.MinimumSize = New-Object System.Drawing.Size(860, 620)
$script:Form.BackColor = $script:Theme.Bg

$iconPath = Join-Path $root 'assets\icon.ico'
if (Test-Path $iconPath) {
    try {
        $script:Form.Icon = New-Object System.Drawing.Icon($iconPath)
    } catch { }
}

# --- Header ---
$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 76
Set-ThemeControl $header 'header'

$lblAppTitle = New-Object System.Windows.Forms.Label
$lblAppTitle.Text = 'PC Health'
$lblAppTitle.Font = New-PcSafeFont -Size 15 -Style ([Drawing.FontStyle]::Bold)
$lblAppTitle.ForeColor = [Drawing.Color]::White
$lblAppTitle.BackColor = $script:Theme.Header
$lblAppTitle.Location = New-Object System.Drawing.Point(72, 10)
$lblAppTitle.AutoSize = $true

$lblAppSub = New-Object System.Windows.Forms.Label
$lblAppSub.Text = 'Optimizador Windows - cualquier PC'
$lblAppSub.Font = $script:FontSmall
$lblAppSub.ForeColor = $script:Theme.HeaderSub
$lblAppSub.BackColor = $script:Theme.Header
$lblAppSub.Location = New-Object System.Drawing.Point(72, 42)
$lblAppSub.AutoSize = $true

$picLogo = $null
$logoPath = Join-Path $root 'assets\icon-256.png'
if (-not (Test-Path $logoPath)) { $logoPath = Join-Path $root 'assets\logo-header.png' }
if (Test-Path $logoPath) {
    try {
        $picLogo = New-Object System.Windows.Forms.PictureBox
        $picLogo.Size = New-Object System.Drawing.Size(48, 48)
        $picLogo.Location = New-Object System.Drawing.Point(16, 14)
        $picLogo.SizeMode = 'Zoom'
        $picLogo.BackColor = $script:Theme.Header
        $picLogo.Image = [System.Drawing.Image]::FromFile($logoPath)
    } catch { $picLogo = $null }
}

$script:LblAdminBadge = New-Object System.Windows.Forms.Label
$script:LblAdminBadge.Text = '  Usuario  '
$script:LblAdminBadge.Font = $script:FontSmall
$script:LblAdminBadge.ForeColor = [Drawing.Color]::White
$script:LblAdminBadge.BackColor = $script:Theme.Warning
$script:LblAdminBadge.AutoSize = $false
$script:LblAdminBadge.Size = New-Object System.Drawing.Size(110, 24)
$script:LblAdminBadge.TextAlign = 'MiddleCenter'
$script:LblAdminBadge.Anchor = 'Top,Right'
$script:LblAdminBadge.Location = New-Object System.Drawing.Point(830, 26)

$header.Controls.AddRange(@($lblAppTitle, $lblAppSub, $script:LblAdminBadge))
if ($picLogo) { $header.Controls.Add($picLogo); $picLogo.BringToFront() }
$header.Add_Resize({
    $script:LblAdminBadge.Location = New-Object System.Drawing.Point(($header.Width - 130), 26)
})

# --- Banner de estado global (visible siempre) ---
$script:BannerPanel = New-Object System.Windows.Forms.Panel
$script:BannerPanel.Dock = 'Top'
$script:BannerPanel.Height = 44
$script:BannerPanel.Padding = New-Object System.Windows.Forms.Padding(16, 8, 16, 8)
$script:BannerPanel.BackColor = [Drawing.Color]::FromArgb(220, 252, 231)

$script:LblStatusBanner = New-Object System.Windows.Forms.Label
$script:LblStatusBanner.Dock = 'Fill'
$script:LblStatusBanner.Font = New-PcSafeFont -Size 10 -Style ([Drawing.FontStyle]::Bold)
$script:LblStatusBanner.ForeColor = $script:Theme.Text
$script:LblStatusBanner.BackColor = [Drawing.Color]::FromArgb(220, 252, 231)
$script:LblStatusBanner.TextAlign = 'MiddleLeft'
$script:LblStatusBanner.AutoEllipsis = $true
$script:LblStatusBanner.Text = (Format-PcStatusText -State idle -Message 'Iniciando PC Health...')

$script:BannerPanel.Controls.Add($script:LblStatusBanner)

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = 'Fill'
$tabs.Font = $script:FontHeading
$tabs.Padding = New-Object System.Drawing.Point(16, 6)

# === TAB Dashboard ===
$tabDash = New-Object System.Windows.Forms.TabPage
$tabDash.Text = '  Dashboard  '
$tabDash.BackColor = $script:Theme.Bg
$tabDash.Padding = New-Object System.Windows.Forms.Padding(16)

$panelDash = New-Object System.Windows.Forms.Panel
$panelDash.Dock = 'Fill'
$panelDash.AutoScroll = $true
Set-ThemeControl $panelDash 'bg'

$cardsFlow = New-Object System.Windows.Forms.FlowLayoutPanel
$cardsFlow.Dock = 'Top'
$cardsFlow.Height = 200
$cardsFlow.WrapContents = $true
$cardsFlow.AutoSize = $false
$cardsFlow.Padding = New-Object System.Windows.Forms.Padding(0, 0, 0, 8)
Set-ThemeControl $cardsFlow 'bg'

$cardDefs = @(
    @{ Title = 'Carga CPU'; Key = 'cpu'; Color = $script:Theme.Accent }
    @{ Title = 'RAM libre / total'; Key = 'ram'; Color = $script:Theme.Accent }
    @{ Title = 'RAM usada'; Key = 'rampct'; Color = $script:Theme.Warning }
    @{ Title = 'Disco libre'; Key = 'disk'; Color = $script:Theme.Success }
    @{ Title = 'Disco usado'; Key = 'diskpct'; Color = $script:Theme.Warning }
    @{ Title = 'GPU'; Key = 'gpu'; Color = $script:Theme.Accent }
    @{ Title = 'Plan energia'; Key = 'power'; Color = $script:Theme.Success }
    @{ Title = 'Downloads'; Key = 'downloads'; Color = $script:Theme.TextMuted }
)

foreach ($def in $cardDefs) {
    $mc = New-MetricCard -Title $def.Title -Key $def.Key -AccentColor $def.Color
    $cardsFlow.Controls.Add($mc.Card)
    $script:MetricLabels[$def.Key] = $mc.ValueLabel
}

$script:LblCpuDetail = New-Object System.Windows.Forms.Label
$script:LblCpuDetail.Dock = 'Top'
$script:LblCpuDetail.Height = 28
$script:LblCpuDetail.Font = $script:FontSmall
$script:LblCpuDetail.ForeColor = $script:Theme.TextMuted
$script:LblCpuDetail.BackColor = $script:Theme.Bg
$script:LblCpuDetail.Padding = New-Object System.Windows.Forms.Padding(4, 0, 0, 0)
$script:LblCpuDetail.Text = 'CPU: cargando...'

# Panel chequeos de salud GUI
$healthPanel = New-Object System.Windows.Forms.Panel
$healthPanel.Dock = 'Top'
$healthPanel.Height = 130
$healthPanel.Padding = New-Object System.Windows.Forms.Padding(0, 8, 0, 8)
$healthPanel.BackColor = $script:Theme.Bg

$script:LblHealthScore = New-Object System.Windows.Forms.Label
$script:LblHealthScore.Dock = 'Top'
$script:LblHealthScore.Height = 28
$script:LblHealthScore.Font = New-PcSafeFont -Size 11 -Style ([Drawing.FontStyle]::Bold)
$script:LblHealthScore.ForeColor = $script:Theme.Success
$script:LblHealthScore.BackColor = $script:Theme.Bg
$script:LblHealthScore.Text = (Format-PcStatusText -State running -Message 'Calculando score...')

$lblHealthTitle = New-Object System.Windows.Forms.Label
$lblHealthTitle.Dock = 'Top'
$lblHealthTitle.Height = 22
$lblHealthTitle.Text = 'Chequeos del sistema (GUI)'
$lblHealthTitle.Font = $script:FontSmall
$lblHealthTitle.ForeColor = $script:Theme.TextMuted
$lblHealthTitle.BackColor = $script:Theme.Bg

$script:TxtHealthChecks = New-Object System.Windows.Forms.TextBox
$script:TxtHealthChecks.Dock = 'Fill'
$script:TxtHealthChecks.Multiline = $true
$script:TxtHealthChecks.ReadOnly = $true
$script:TxtHealthChecks.BorderStyle = 'FixedSingle'
$script:TxtHealthChecks.Font = $script:FontMono
$script:TxtHealthChecks.BackColor = $script:Theme.Surface
$script:TxtHealthChecks.ForeColor = $script:Theme.Text
$script:TxtHealthChecks.ScrollBars = 'Vertical'

$healthPanel.Controls.Add($script:TxtHealthChecks)
$healthPanel.Controls.Add($lblHealthTitle)
$healthPanel.Controls.Add($script:LblHealthScore)

$lblProcSection = New-SectionHeader 'Top procesos por RAM' $panelDash

$script:GridProcs = New-Object System.Windows.Forms.DataGridView
$script:GridProcs.Dock = 'Top'
$script:GridProcs.Height = 220
$script:GridProcs.ReadOnly = $true
$script:GridProcs.AllowUserToAddRows = $false
$script:GridProcs.AutoSizeColumnsMode = 'Fill'
$script:GridProcs.SelectionMode = 'FullRowSelect'
Style-DataGrid $script:GridProcs

$dashActions = New-Object System.Windows.Forms.Panel
$dashActions.Dock = 'Top'
$dashActions.Height = 52
$dashActions.Padding = New-Object System.Windows.Forms.Padding(0, 12, 0, 0)
Set-ThemeControl $dashActions 'bg'

$btnRefresh = New-ThemeButton -Text 'Actualizar dashboard' -Width 200 -Height 36 -Primary
$btnRefresh.Location = New-Object System.Drawing.Point(0, 0)
$btnRefresh.Add_Click({
    Update-Dashboard -Mode Full
    Update-HealthChecks -UpdateBanner -Snapshot $script:LastSnapshot | Out-Null
    if ($tabs.SelectedTab -eq $tabDisk) { $script:DiskTabLoaded = $false; Update-DiskTab }
    if ($tabs.SelectedTab -eq $tabDrv) { $script:DriversTabLoaded = $false; Update-DriversTab }
})

$btnCompareBaseline = New-ThemeButton -Text 'Comparar baseline' -Width 200 -Height 36
$btnCompareBaseline.Location = New-Object System.Drawing.Point(212, 0)
$btnCompareBaseline.Add_Click({
    try {
        Invoke-PcBaselineCompare
    } catch {
        Set-PcUiStatus -State warn -Message $_.Exception.Message
        [Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'PC Health',
            [Windows.Forms.MessageBoxButtons]::OK,
            [Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
})

$dashActions.Controls.AddRange(@($btnRefresh, $btnCompareBaseline))

$panelDash.Controls.Add($dashActions)
$panelDash.Controls.Add($script:GridProcs)
$panelDash.Controls.Add($lblProcSection)
$panelDash.Controls.Add($healthPanel)
$panelDash.Controls.Add($script:LblCpuDetail)
$panelDash.Controls.Add($cardsFlow)

$tabDash.Controls.Add($panelDash)

# === TAB Optimizar ===
$tabOpt = New-Object System.Windows.Forms.TabPage
$tabOpt.Text = '  Optimizar  '
$tabOpt.BackColor = $script:Theme.Bg
$tabOpt.Padding = New-Object System.Windows.Forms.Padding(16)

$flow = New-Object System.Windows.Forms.FlowLayoutPanel
$flow.Dock = 'Fill'
$flow.FlowDirection = 'TopDown'
$flow.WrapContents = $false
$flow.AutoScroll = $true
$flow.Padding = New-Object System.Windows.Forms.Padding(0, 4, 0, 8)
Set-ThemeControl $flow 'bg'

function New-ActionCard($text, $tip, $action, [switch]$Admin) {
    $card = New-Object System.Windows.Forms.Panel
    $card.Size = New-Object System.Drawing.Size(860, 72)
    $card.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 10)
    $card.BackColor = $script:Theme.Surface
    $card.Padding = New-Object System.Windows.Forms.Padding(12, 10, 12, 10)

    $b = New-ThemeButton -Text $text -Width 240 -Height 40 -Primary:$(-not $Admin)
    if ($Admin) {
        $b.BackColor = $script:Theme.GridHeader
        $b.ForeColor = $script:Theme.Text
        $b.FlatAppearance.BorderColor = $script:Theme.Warning
        $b.FlatAppearance.BorderSize = 1
    }
    $b.Location = New-Object System.Drawing.Point(12, 16)
    $actionName = $text
    $actionBlock = $action
    $needAdmin = [bool]$Admin
    $b.Add_Click({
        Invoke-PcAction -Action $actionBlock -Name $actionName -NeedAdmin:$needAdmin
    })

    $t = New-Object System.Windows.Forms.Label
    $t.Text = $tip
    $t.Location = New-Object System.Drawing.Point(268, 10)
    $t.Size = New-Object System.Drawing.Size(380, 52)
    $t.ForeColor = $script:Theme.TextMuted
    $t.BackColor = $script:Theme.Surface
    $t.Font = $script:FontBody

    $statusLbl = New-Object System.Windows.Forms.Label
    $statusLbl.Location = New-Object System.Drawing.Point(660, 22)
    $statusLbl.Size = New-Object System.Drawing.Size(180, 28)
    $statusLbl.Font = New-PcSafeFont -Size 9 -Style ([Drawing.FontStyle]::Bold)
    $statusLbl.TextAlign = 'MiddleRight'
    $statusLbl.ForeColor = $script:Theme.TextMuted
    $statusLbl.BackColor = $script:Theme.Surface
    $statusLbl.Text = (Format-PcStatusText -State idle -Message 'Listo')
    $script:ActionStatuses[$text] = $statusLbl

    if ($Admin) {
        $badge = New-Object System.Windows.Forms.Label
        $badge.Text = 'ADMIN'
        $badge.Font = $script:FontSmall
        $badge.ForeColor = $script:Theme.Warning
        $badge.BackColor = [Drawing.Color]::FromArgb(255, 247, 237)
        $badge.AutoSize = $false
        $badge.Size = New-Object System.Drawing.Size(52, 20)
        $badge.TextAlign = 'MiddleCenter'
        $badge.Location = New-Object System.Drawing.Point(188, 26)
        $card.Controls.Add($badge)
    }

    $card.Controls.AddRange(@($b, $t, $statusLbl))
    return $card
}

$sqlHint = if (@($script:MachineCfg.sql_services.known_instances).Count -gt 0) {
    $inst = @($script:MachineCfg.sql_services.known_instances) -join ', '
    "Detiene instancias SQL detectadas (p. ej. MSSQL`$$inst) si no las necesitas"
} else {
    'Detiene servicios SQL Server detectados en este equipo'
}

$actions = @(
    @{ T = 'Alto rendimiento'; D = 'CPU al 100% enchufado y bateria, sin ahorro en disco ni USB'; A = { Set-PcHighPerformance } }
    @{ T = 'TRIM SSD'; D = 'Requiere Admin. Sin permisos se omite (Windows ya hace TRIM solo)'; A = { Invoke-PcTrimSsd -ThrowOnDenied } }
    @{ T = 'Recolectar baseline'; D = 'Guarda metricas en data\baseline.json (copia la anterior a baseline.previous.json)'; A = { Invoke-PcBaseline } }
    @{ T = 'Limpieza ligera'; D = 'Elimina .crdownload y archivos temporales de mas de 7 dias'; A = { Invoke-PcDiskCleanupLite } }
    @{ T = 'Disk Cleanup (sistema)'; D = 'Abre cleanmgr para liberar espacio del sistema Windows'; A = { Invoke-PcDiskCleanupFull }; Admin = $true }
    @{ T = 'Detener SQL Server'; D = $sqlHint; A = { Stop-PcSqlServices }; Admin = $true }
    @{ T = 'Abrir Startup'; D = 'Administrador de tareas - programas al inicio'; A = { Open-PcExternal 'startup' } }
    @{ T = 'Storage Sense'; D = 'Configuracion de almacenamiento automatico de Windows'; A = { Open-PcExternal 'storage' } }
    @{ T = 'Efectos visuales'; D = 'Ajustar Windows para mejor rendimiento'; A = { Open-PcExternal 'performance' } }
    @{ T = 'Drivers del fabricante'; D = 'Abre soporte Lenovo/Dell/HP segun tu equipo'; A = { Open-PcExternal 'drivers' } }
    @{ T = 'Abrir documentacion'; D = 'Carpeta docs\ con analisis completo y plan de accion'; A = { Open-PcExternal 'docs' } }
    @{ T = 'Administrador de tareas'; D = 'Monitor en vivo de CPU, RAM y procesos'; A = { Open-PcExternal 'taskmgr' } }
)

foreach ($item in $actions) {
    $admin = [bool]$item.Admin
    $act = $item.A
    $flow.Controls.Add((New-ActionCard $item.T $item.D $act -Admin:$admin))
}

$tabOpt.Controls.Add($flow)

# === TAB Disco ===
$tabDisk = New-Object System.Windows.Forms.TabPage
$tabDisk.Text = '  Disco  '
$tabDisk.BackColor = $script:Theme.Bg
$tabDisk.Padding = New-Object System.Windows.Forms.Padding(16)

$diskHintLines = @('Carpetas pesadas en Downloads (ver config\machine.json):')
foreach ($hint in @($script:MachineCfg.downloads.large_folder_hints)) {
    $diskHintLines += ('  - {0}: {1}' -f $hint.name_contains, $hint.hint)
}
$diskHintLines += 'Detalle completo en docs\08-disk-cleanup.md'
$diskBanner = New-InfoBanner ($diskHintLines -join "`r`n")

$script:GridDownloads = New-Object System.Windows.Forms.DataGridView
$script:GridDownloads.Dock = 'Fill'
$script:GridDownloads.ReadOnly = $true
$script:GridDownloads.AllowUserToAddRows = $false
$script:GridDownloads.AutoSizeColumnsMode = 'Fill'
Style-DataGrid $script:GridDownloads

$tabDisk.Controls.Add($script:GridDownloads)
$tabDisk.Controls.Add($diskBanner)

# === TAB Drivers / Firewall ===
$tabDrv = New-Object System.Windows.Forms.TabPage
$tabDrv.Text = '  Drivers  '
$tabDrv.BackColor = $script:Theme.Bg
$tabDrv.Padding = New-Object System.Windows.Forms.Padding(16)

$splitDrv = New-Object System.Windows.Forms.SplitContainer
$splitDrv.Dock = 'Fill'
$splitDrv.Orientation = 'Horizontal'
$splitDrv.SplitterDistance = 260
$splitDrv.BackColor = $script:Theme.Bg

$drvBannerText = if ($script:MachineCfg.drivers.banner) {
    [string]$script:MachineCfg.drivers.banner
} else {
    'Actualiza drivers desde el sitio del fabricante.'
}
$drvBanner = New-InfoBanner $drvBannerText

$script:GridDrivers = New-Object System.Windows.Forms.DataGridView
$script:GridDrivers.Dock = 'Fill'
$script:GridDrivers.ReadOnly = $true
$script:GridDrivers.AllowUserToAddRows = $false
$script:GridDrivers.AutoSizeColumnsMode = 'Fill'
Style-DataGrid $script:GridDrivers

$panelDrvTop = New-Object System.Windows.Forms.Panel
$panelDrvTop.Dock = 'Fill'
$panelDrvTop.BackColor = $script:Theme.Bg
$panelDrvTop.Controls.Add($script:GridDrivers)
$panelDrvTop.Controls.Add($drvBanner)

$lblFw = New-SectionHeader 'Firewall' $null
$lblFw.Dock = 'Top'

$script:TxtFirewall = New-Object System.Windows.Forms.TextBox
$script:TxtFirewall.Dock = 'Fill'
$script:TxtFirewall.Multiline = $true
$script:TxtFirewall.ReadOnly = $true
$script:TxtFirewall.ScrollBars = 'Vertical'
$script:TxtFirewall.Font = $script:FontMono
$script:TxtFirewall.BackColor = $script:Theme.Surface
$script:TxtFirewall.ForeColor = $script:Theme.Text
$script:TxtFirewall.BorderStyle = 'None'

$panelFw = New-Object System.Windows.Forms.Panel
$panelFw.Dock = 'Fill'
$panelFw.BackColor = $script:Theme.Bg
$panelFw.Padding = New-Object System.Windows.Forms.Padding(0, 8, 0, 0)
$panelFw.Controls.Add($script:TxtFirewall)
$panelFw.Controls.Add($lblFw)

$splitDrv.Panel1.Controls.Add($panelDrvTop)
$splitDrv.Panel2.Controls.Add($panelFw)
$tabDrv.Controls.Add($splitDrv)

# === TAB Log ===
$tabLog = New-Object System.Windows.Forms.TabPage
$tabLog.Text = '  Log  '
$tabLog.BackColor = $script:Theme.LogBg
$tabLog.Padding = New-Object System.Windows.Forms.Padding(12)

$script:TxtLog = New-Object System.Windows.Forms.RichTextBox
$script:TxtLog.Dock = 'Fill'
$script:TxtLog.ReadOnly = $true
$script:TxtLog.BorderStyle = 'None'
$script:TxtLog.Font = $script:FontMono
$script:TxtLog.BackColor = $script:Theme.LogBg
$script:TxtLog.ForeColor = $script:Theme.LogText

$tabLog.Controls.Add($script:TxtLog)

# --- Barra inferior ---
$footer = New-Object System.Windows.Forms.Panel
$footer.Dock = 'Bottom'
$footer.Height = 122
Set-ThemeControl $footer 'footer'

$statusBar = New-Object System.Windows.Forms.Panel
$statusBar.Dock = 'Bottom'
$statusBar.Height = 24
$statusBar.Padding = New-Object System.Windows.Forms.Padding(12, 0, 12, 0)
$statusBar.BackColor = $script:Theme.Footer

$script:StatusDot = New-Object System.Windows.Forms.Panel
$script:StatusDot.Size = New-Object System.Drawing.Size(8, 8)
$script:StatusDot.Dock = 'Left'
$script:StatusDot.Margin = New-Object System.Windows.Forms.Padding(0, 8, 8, 0)
$script:StatusDot.BackColor = $script:Theme.Success

$script:StatusLabel = New-Object System.Windows.Forms.Label
$script:StatusLabel.Dock = 'Fill'
$script:StatusLabel.Text = (Format-PcStatusText -State idle -Message 'Listo')
$script:StatusLabel.Font = $script:FontSmall
$script:StatusLabel.ForeColor = $script:Theme.TextMuted
$script:StatusLabel.BackColor = $script:Theme.Footer
$script:StatusLabel.TextAlign = 'MiddleLeft'
$script:StatusLabel.AutoEllipsis = $true

$statusBar.Controls.AddRange(@($script:StatusDot, $script:StatusLabel))

$btnRunAll = New-ThemeButton -Text 'Optimizacion rapida' -Width 860 -Height 36 -Primary
$btnRunAll.Dock = 'Top'
$btnRunAll.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 6)
$btnRunAll.Add_Click({
    Invoke-PcAction -Action { Invoke-PcQuickOptimize } -Name 'Optimizacion rapida'
})

$btnAdmin = New-ThemeButton -Text 'Reiniciar como Administrador' -Width 860 -Height 32 -Ghost
$btnAdmin.Dock = 'Top'
$btnAdmin.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 0)
$btnAdmin.Add_Click({
    if (Test-IsAdmin) {
        [Windows.Forms.MessageBox]::Show('Ya estas en modo Administrador.', 'PC Health') | Out-Null
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList @(
            '-STA', '-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', $PSCommandPath
        )
        $script:Form.Close()
    }
})

$footerInner = New-Object System.Windows.Forms.Panel
$footerInner.Dock = 'Fill'
$footerInner.Padding = New-Object System.Windows.Forms.Padding(16, 8, 16, 8)
$footerInner.BackColor = $script:Theme.Footer
$footerInner.Controls.Add($btnAdmin)
$footerInner.Controls.Add($btnRunAll)

$footer.Controls.Add($statusBar)
$footer.Controls.Add($footerInner)

# --- Ensamblar ---
$tabs.TabPages.AddRange(@($tabDash, $tabOpt, $tabDisk, $tabDrv, $tabLog))

$script:Form.Controls.Add($tabs)
$script:Form.Controls.Add($footer)
$script:Form.Controls.Add($script:BannerPanel)
$script:Form.Controls.Add($header)

$script:DiskTabLoaded = $false
$script:DriversTabLoaded = $false
$script:LastSnapshot = $null

$tabs.Add_SelectedIndexChanged({
    if ($tabs.SelectedTab -eq $tabDisk) { Update-DiskTab }
    elseif ($tabs.SelectedTab -eq $tabDrv) { Update-DriversTab }
})

# --- Timer auto-refresh ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 30000
$timer.Add_Tick({ Update-Dashboard -Mode Lite })
$timer.Start()

$loadTimer = New-Object System.Windows.Forms.Timer
$loadTimer.Interval = 100
$loadTimer.Add_Tick({
    $loadTimer.Stop()
    $loadTimer.Dispose()
    try {
        Set-PcUiStatus -State running -Message 'Calculando tamano de Downloads...'
        [System.Windows.Forms.Application]::DoEvents()
        Update-Dashboard -Mode Full
        $h = Update-HealthChecks -UpdateBanner -Snapshot $script:LastSnapshot
        foreach ($c in $h.Checks) {
            Write-PcLog $c.Status $(if ($c.Ok) { 'INFO' } else { 'ERROR' })
        }
    } catch {
        Write-PcLog $_.Exception.Message 'ERROR'
    }
})

$script:Form.Add_Shown({
    Set-PcLogCallback $script:LogCallback
    Write-PcLog "$(Get-PcStatusEmoji success) PC Health GUI iniciado"
    Write-PcLog "Proyecto: $root"
    $script:LblAdminBadge.Location = New-Object System.Drawing.Point(($header.Width - 130), 26)
    Set-PcUiStatus -State running -Message 'Cargando metricas...'
    [System.Windows.Forms.Application]::DoEvents()
    Update-Dashboard -Mode Lite
    Update-HealthChecks -Snapshot $script:LastSnapshot | Out-Null
    $loadTimer.Start()
})

if ($args -contains '-Admin' -and -not (Test-IsAdmin)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        '-STA', '-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', "`"$PSCommandPath`""
    )
    exit
}

[void]$script:Form.ShowDialog()
