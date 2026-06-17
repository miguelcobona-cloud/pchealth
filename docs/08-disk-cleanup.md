# 08 — Liberación de disco (sin tocar RAM)

**Hallazgo**: `C:\Users\miguelonches\Downloads` ocupa **~91 GB** de los 108 GB libres totales. Limpiar aquí es la acción de mayor impacto disponible.

---

## Mapa de Downloads

| Ubicación | Tamaño | Acción sugerida |
|-----------|--------|-----------------|
| `Downloads\Solidworks\` | **30 GB** | Mover a disco externo o eliminar si ya instalado |
| `Downloads\mat\` | **28 GB** | Probablemente MATLAB — mover a externo |
| `Downloads\PSP GAMES\` | **14 GB** | Mover a externo o eliminar si no juegas |
| Archivos sueltos (installers) | **10 GB** | Eliminar instaladores ya usados |
| `Proteus 8.13\` | 1 GB | Eliminar si ya instalado |
| `Topaz Gigapixel AI\` | 0.8 GB | Eliminar installer si ya instalado |
| `Corona pharma\` | 0.3 GB | Revisar si necesitas |

### Instaladores seguros de borrar (ya tienes las apps)

| Archivo | Tamaño | Motivo |
|---------|--------|--------|
| Adobe Photoshop 2025.rar | 5.1 GB | Ya tienes PS 2022 instalado |
| Curso Contabilidad part1+2.rar | 2.5 GB | Curso, no app |
| VSCodeUserSetup (×2 duplicados) | 0.22 GB | Duplicado |
| advanced-systemcare-setup (×2) | 0.12 GB | **No instalar** — LTT anti snake-oil |
| DTLite1230 (DAEMON Tools) | 0.07 GB | Desinstalar DAEMON, borrar installer |
| CursorUserSetup, Git, node, arduino | ~0.4 GB | Borrar si ya instalados |
| `*.crdownload` incompletos | ~0.06 GB | Borrar siempre |

**Potencial inmediato sin mover carpetas**: ~8 GB (installers sueltos)  
**Potencial moviendo Solidworks + mat + PSP**: ~72 GB  
**Total posible**: pasar de 108 GB libres → **~180 GB libres** (40% del disco)

---

## Comandos seguros

```powershell
# Ver qué ocupa más (top 20 archivos)
Get-ChildItem "$env:USERPROFILE\Downloads" -Recurse -File -ErrorAction SilentlyContinue |
  Sort-Object Length -Descending | Select-Object -First 20 FullName,
  @{N='GB';E={[math]::Round($_.Length/1GB,2)}}

# Borrar descargas incompletas
Remove-Item "$env:USERPROFILE\Downloads\*.crdownload" -Force -ErrorAction SilentlyContinue

# Disk Cleanup sistema
cleanmgr /d C:
```

### Mover carpetas pesadas a disco externo

```powershell
# Ejemplo — ajustar letra de unidad externa (E:)
Move-Item "$env:USERPROFILE\Downloads\Solidworks" "E:\Archivo\Solidworks"
Move-Item "$env:USERPROFILE\Downloads\mat" "E:\Archivo\mat"
Move-Item "$env:USERPROFILE\Downloads\PSP GAMES" "E:\Archivo\PSP GAMES"
```

---

## Meta

| Métrica | Actual | Objetivo |
|---------|--------|----------|
| Libre en C: | 108 GB | **>150 GB** |
| % usado | 76% | **<66%** |
| Downloads | 91 GB | **<5 GB** (solo activos) |

SSD con >20% libre = mejor rendimiento sostenido (wear leveling + menos presión).
