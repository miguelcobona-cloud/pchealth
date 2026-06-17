# 07 — Auditoría de drivers

**Fecha**: 2026-06-16  
**Equipo**: ThinkPad L450 (`20CLA32VLM`)  
**Restricción**: Sin upgrade de RAM — optimizar por software, disco y drivers.

---

## Resumen ejecutivo

| Conclusión | Detalle |
|------------|---------|
| GPU Intel HD 5500 | **Ya tienes el último driver posible** (20.19.15.5171) |
| Intel dejó de soportar esta GPU | Junio 2024 — no habrá más actualizaciones |
| Drivers pendientes | Chipset/SATA (2017), Ethernet (2019), Audio Realtek (2020) |
| WiFi / Bluetooth / ME | Actualizados 2024 |
| TRIM SSD | Activo (OK) |

> No esperes milagros del driver gráfico: ya está al tope. Lo que sí puede ayudar en CAD es **tuning de SOLIDWORKS** (OpenGL, sin RealView) y **liberar RAM** cerrando SQL Server y apps en background.

---

## Estado por componente

### Gráficos — Intel HD Graphics 5500

| Campo | Valor |
|-------|-------|
| Instalado | **20.19.15.5171** (abril 2020) |
| Último Intel oficial | **20.19.15.5171** (`win64_15.40.5171.exe`) |
| Último Lenovo L450 | 20.19.15.5144 (mayo 2021) — **el tuyo es más nuevo** |
| Estado | **ACTUALIZADO — no hacer nada** |

Intel declaró fin de soporte para drivers 15.40 en [junio 2024](https://www.intel.com/content/www/us/en/download/18369/intel-graphics-driver-for-windows-15-40.html). No instales drivers genéricos de sitios terceros (PCI-DB, etc.) — riesgo sin beneficio.

**Para SOLIDWORKS con esta GPU**:
- Herramientas → Opciones → Rendimiento → desactivar RealView y sombras
- Si hay artefactos 3D: activar "Use Software OpenGL"
- Reducir calidad gráfica en ensamblajes grandes

---

### Chipset / SATA — Intel 9 Series AHCI

| Campo | Valor |
|-------|-------|
| Instalado | 14.8.16.1063 (**octubre 2017**) |
| Disponible Lenovo | Intel RST / Chipset (~agosto 2020) |
| Estado | **DESACTUALIZADO — actualizar** |
| Impacto | Medio — mejor I/O disco, estabilidad |

---

### Red cableada — Intel Ethernet I218-LM

| Campo | Valor |
|-------|-------|
| Instalado | 12.18.9.8 (**junio 2019**) |
| Estado | **DESACTUALIZADO — actualizar** |
| Impacto | Bajo (solo si usas Ethernet; en WiFi no afecta) |

---

### Audio — Realtek High Definition

| Campo | Valor |
|-------|-------|
| Instalado | 6.0.8924.1 (**marzo 2020**) |
| Estado | **Ligeramente desactualizado** |
| Impacto | Bajo — salvo crackling o micrófono fallando |

---

### WiFi — Intel Dual Band Wireless-N 7265

| Campo | Valor |
|-------|-------|
| Instalado | 23.40.0.4 (**octubre 2024**) |
| Estado | **ACTUALIZADO** |

---

### Bluetooth — Intel Wireless Bluetooth

| Campo | Valor |
|-------|-------|
| Instalado | 23.40.0.2 (**febrero 2024**) |
| Estado | **ACTUALIZADO** |

---

### Management Engine — Intel ME

| Campo | Valor |
|-------|-------|
| Instalado | 2433.6.3.0 (**agosto 2024**) |
| Estado | **ACTUALIZADO** |

---

### Lector tarjetas — Realtek PCIE CardReader

| Campo | Valor |
|-------|-------|
| Instalado | 10.0.26100.21375 (**julio 2024**) |
| Estado | **ACTUALIZADO** (vía Windows Update) |

---

### DAEMON Tools — Virtual SCSI/USB

| Campo | Valor |
|-------|-------|
| Drivers | 2018 / 2021 |
| Estado | **Innecesario si no montas ISOs** |
| Acción | Desinstalar DAEMON Tools Lite libera drivers virtuales y RAM |

---

## Cómo actualizar (método recomendado LTT + Lenovo)

### Opción A — Lenovo System Update (recomendada)

1. Descargar [Lenovo System Update](https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-l-series-laptops/thinkpad-l450/20dt/solutions/ht003029-lenovo-system-update-update-drivers-bios-and-applications)
2. Ejecutar → detecta tu serial `20CLA32VLM`
3. Instalar solo: **Chipset**, **Intel RST/SATA**, **Ethernet**, **Audio**
4. **No tocar BIOS** salvo que tengas un problema específico
5. Reiniciar

### Opción B — Manual desde Lenovo

Página de drivers L450:  
https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-l-series-laptops/thinkpad-l450/downloads

Buscar e instalar:
- Intel Chipset Driver
- Intel Rapid Storage Technology (RST)
- Intel Ethernet Connection driver
- Realtek Audio (opcional)

### Opción C — Windows Update (complementaria)

```powershell
# Ver actualizaciones de drivers pendientes
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot:$false
# O: Configuración → Windows Update → Buscar actualizaciones
```

---

## Verificación post-actualización

```powershell
# GPU (debe seguir en 20.19.15.5171)
Get-CimInstance Win32_VideoController | Select Name, DriverVersion, DriverDate

# SATA (debe ser > 2017)
Get-CimInstance Win32_PnPSignedDriver | Where-Object DeviceName -match 'SATA|RST' | Select DeviceName, DriverVersion, DriverDate

# TRIM sigue activo (0 = OK)
fsutil behavior query DisableDeleteNotify
```

---

## Lo que NO actualizar

| Evitar | Por qué |
|--------|---------|
| Driver GPU de Intel.com si ya tienes .5171 | Misma versión; pérdida de tiempo |
| Drivers de terceros (Driver Booster, IOBit) | LTT: snake oil; pueden instalar versiones incorrectas |
| `advanced-systemcare-setup.exe` en Downloads | Lo descargaste hoy — no lo instales |
| BIOS sin motivo | Riesgo innecesario |

---

## SQL Server — libera RAM ahora (42 MB + servicios)

Detectado **MSSQL$TEW_SQLEXPRESS corriendo** aunque el inicio es Manual:

```powershell
# Ejecutar como Administrador
Stop-Service MSSQL$TEW_SQLEXPRESS -Force
Set-Service MSSQL$TEW_SQLEXPRESS -StartupType Disabled  # si no usas SQL
Stop-Service SQLBrowser -Force -ErrorAction SilentlyContinue
```

Si usas SQL ocasionalmente: dejar en **Manual** y parar cuando no lo necesites.

---

## Impacto esperado (sin RAM nueva)

| Acción | Mejora esperada |
|--------|-----------------|
| Drivers chipset/SATA | 5–10% I/O disco; más estabilidad |
| Parar SQL Server | ~50 MB RAM + menos CPU background |
| Liberar Downloads (91 GB) | SSD más rápido; menos presión de espacio |
| Desinstalar DAEMON Tools | Menos drivers virtuales |
| Tuning SOLIDWORKS OpenGL | 15–30% fluidez 3D en viewport |
| **Total realista sin RAM** | **Notable pero no transformador** |

Sin 16 GB RAM, el cuello de botella principal permanece. Drivers y disco son el mejor camino disponible.
