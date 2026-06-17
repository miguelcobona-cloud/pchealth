# PC Health

<p align="center">
  <img src="assets/icon-256.png" alt="PC Health" width="96" height="96">
</p>

**Customer Success–style PC health engagement for Windows workstations** — diagnose, document, optimize with evidence.

Diagnóstico y optimización segura para equipos Windows (especialmente estaciones de ingeniería: SOLIDWORKS, MATLAB, SQL Server). Incluye GUI de escritorio, baseline JSON, health score 0–100 y documentación de engagement.

## Instalar como app de escritorio

```powershell
cd C:\ruta\a\pchealth
.\scripts\Install-PcHealthDesktop.ps1
```

Crea accesos directos en **Escritorio** y **Menú Inicio** (sin ventana de consola). Si tienes `assets\icon.png` en alta resolución, el instalador genera `icon.ico` automáticamente.

## Inicio rápido (desarrollo)

```powershell
# Tests
.\tests\Run-Tests.ps1

# GUI
.\pchealth-gui.ps1

# Orquestador CS (CLI)
.\orchestrate.ps1

# Baseline y comparación
.\scripts\collect-baseline.ps1
.\scripts\Compare-Baseline.ps1
```

## Configuración

- **`config/machine.json`** — valores genéricos incluidos en el repo.
- **`config/machine.local.json`** — opcional, **no se sube a Git**; copia desde [`machine.json.example`](config/machine.json.example) para tu equipo (SQL, drivers, hints Downloads).

## Estructura

```
pchealth/
├── assets/                 # Icono y branding (icon.ico, logo-header.png)
├── config/
│   ├── machine.json          # Genérico (repo)
│   ├── machine.json.example  # Plantilla
│   └── machine.local.json    # Tu equipo (local, gitignore)
├── src/                    # Módulos PowerShell
├── pchealth-gui.ps1        # Aplicación de escritorio (WinForms)
├── scripts/
│   ├── Install-PcHealthDesktop.ps1
│   ├── Build-DesktopAssets.ps1
│   ├── collect-baseline.ps1
│   └── Compare-Baseline.ps1
├── docs/                   # Entregables CS
├── tests/
└── data/                   # baseline.json (local, no versionado)
```

## Qué hace la optimización

- Plan de energía **Alto rendimiento**
- TRIM SSD (con admin)
- Limpieza ligera (`.crdownload`, temp > 7 días)
- **No** borra carpetas de Downloads ni desinstala software

Ver [`CONTRACT.md`](CONTRACT.md) para la metodología del engagement.

## Licencia

[MIT](LICENSE)
