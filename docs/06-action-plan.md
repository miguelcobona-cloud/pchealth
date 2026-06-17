# 06 — Plan de acción (LTT + PC Health)

**Fuentes**: [LTT — Speed Up Tools (2024)](https://www.youtube.com/watch?v=-G-DByczbWA), [LTT forum — Slow PC tips](https://linustechtips.org/slow-computer-got-you-down/), mantenimiento Windows/SSD 2025.

**Filosofía LTT**: No pagues por "speed-up tools" (CCleaner Pro, IOBit, Glary Pro). Lo mismo se logra gratis con herramientas de Windows. Si el software no basta, **hardware** (SSD ya lo tienes → siguiente paso: **RAM**).

---

## Diagnóstico actualizado (tu equipo)

| Dato | Valor | Implicación |
|------|-------|-------------|
| RAM | **1×8 GB** Samsung DDR3L-1600 | Solo necesitas **añadir 1×8 GB** (~$15–25 USD) |
| SSD | Kingston 480 GB, Healthy | ✅ Mejor upgrade ya hecho (LTT #1) |
| Disco libre | 108 GB (24%) | LTT: mantener **≥10%**; PC Health: ideal **15–20%** → subir a **130+ GB** |
| Startup | 1 entrada | ✅ Ya limpio (LTT checklist) |
| Plan energía | Alto rendimiento | ✅ Correcto |
| Software | SW 2024 + MATLAB + SQL | Carga extrema para 8 GB |

---

## Lo que LTT dice que SÍ hacer (gratis)

| Acción | Por qué | Tu caso |
|--------|---------|---------|
| Disk Cleanup + desinstalar apps | Libera espacio y menos indexación | **Hacer ya** — 76% disco usado |
| Task Manager → Startup | Menos RAM/CPU al boot | Ya OK — revisar tras instalar apps |
| Optimizar unidades (TRIM) | SSD necesita TRIM, no defrag | Verificar una vez |
| Cerrar procesos pesados | RAM es el límite | Cursor+Edge ~2 GB sin CAD |
| Actualizar drivers GPU | Rendimiento gráfico estable | Driver Intel 2015 — **actualizar** |
| WinDirStat / TreeSize | Ver qué carpetas comen disco | SOLIDWORKS/MATLAB temp |
| Más RAM o SSD | Únicos upgrades que "transforman" | SSD ✅ — **RAM pendiente** |

## Lo que LTT dice que NO hacer

| Evitar | Razón |
|--------|-------|
| Comprar CCleaner/IOBit/Avast TuneUp | Marginal vs gratis; marketing agresivo |
| Usar Glary Utilities "en background" | Ya lo tienes — úsalo 1× al mes, no siempre |
| Defragmentar el SSD | Desgasta sin beneficio |
| Registry cleaners | Placebo; riesgo de romper Windows |
| Desactivar pagefile por completo | Inestabilidad con 8 GB |
| Debloat agresivo sin restore point | Puede romper Store/Defender |

---

## Restricciones actuales

- **RAM**: no se puede ampliar → optimizar uso de memoria (cerrar apps, parar SQL)
- **Disco**: sí se puede liberar → ver [`08-disk-cleanup.md`](08-disk-cleanup.md) (~91 GB en Downloads)
- **Drivers**: ver [`07-driver-audit.md`](07-driver-audit.md)

---

## Fase 0 — Hoy (30 min, $0)

> Estilo **"Fixing My Employee's PC"** de LTT: startup → almacenamiento → drivers.

| # | Tarea | Cómo | Hecho |
|---|-------|------|-------|
| 0.1 | Punto de restauración | `Win+R` → `rstrui` → Crear | ☐ |
| 0.2 | Baseline antes | `.\orchestrate.ps1` | ☐ |
| 0.3 | Verificar TRIM en SSD | Ver comando abajo | ☐ |
| 0.4 | Disk Cleanup profundo | `cleanmgr /d C:` → "Limpiar archivos del sistema" | ☐ |
| 0.5 | WinDirStat o Configuración → Almacenamiento | Identificar carpetas >5 GB | ☐ |
| 0.6 | Desactivar apps en segundo plano | Configuración → Privacidad → Apps en segundo plano → Desactivar | ☐ |
| 0.7 | Desactivar Copilot (si no lo usas) | Configuración → Personalización → Copilot → Desactivar | ☐ |
| 0.8 | **Drivers**: Lenovo System Update (chipset, RST, ethernet) | Ver `07-driver-audit.md` | ☐ |
| 0.9 | **Parar SQL Server** si no lo usas hoy | Libera ~50 MB + CPU | ☐ |
| 0.10 | Borrar `*.crdownload` + installers duplicados en Downloads | ~8 GB rápido | ☐ |

```powershell
# TRIM activo? (0 = OK)
fsutil behavior query DisableDeleteNotify

# Optimizar SSD (TRIM manual, 1 vez)
Optimize-Volume -DriveLetter C -ReTrim -Verbose
```

**Meta Fase 0**: Disco libre >120 GB.

---

## Fase 1 — Esta semana (sin RAM)

| # | Tarea | Impacto | Hecho |
|---|-------|---------|-------|
| 1.1 | Mover `Downloads\Solidworks` + `mat` a disco externo | ~58 GB | ☐ |
| 1.2 | Mover o borrar `PSP GAMES` (14 GB) | 14 GB | ☐ |
| 1.3 | Lenovo System Update: chipset, RST, ethernet | Drivers | ☐ |
| 1.4 | Desinstalar DAEMON Tools Lite | Menos bloat | ☐ |
| 1.5 | Tuning SOLIDWORKS (RealView off, Large Assembly) | 3D mas fluido | ☐ |
| 1.6 | 1 app pesada a la vez | RAM | ☐ |
| 1.7 | Baseline despues | Medir | ☐ |

Detalle disco: [`08-disk-cleanup.md`](08-disk-cleanup.md) | Drivers: [`07-driver-audit.md`](07-driver-audit.md)

---

## Fase 2 — Este mes (afinar sin snake oil)

| # | Tarea | Fuente | Hecho |
|---|-------|--------|-------|
| 2.1 | ~~GPU Intel HD 5500~~ — ya en ultima version (.5171) | N/A | ✅ |
| 2.2 | Storage Sense automático | PC Health 2025 | ☐ |
| 2.3 | Indexación: excluir carpetas de proyectos en disco externo | XDA/PC Health | ☐ |
| 2.4 | OneDrive: "Archivos solo en línea" para carpetas pesadas | Menos sync en background | ☐ |
| 2.5 | Auditar módulos SOLIDWORKS — desinstalar los no usados | Inventario propio | ☐ |
| 2.6 | Defender: exclusiones solo en carpetas CAD de confianza | Con cuidado | ☐ |
| 2.7 | Pagefile fijo 8192 MB (con 8 GB RAM) | SSD hygiene | ☐ |
| 2.8 | Glary Utilities: ejecutar limpieza 1×/mes, **no** al inicio | LTT anti-bloat | ☐ |

### Storage Sense

Configuración → Sistema → Almacenamiento → Activar Storage Sense:
- Archivos temporales: cada semana
- Papelera: 14 días
- Descargas: 30 días (o mover a externo)

### Visual effects (modo PC modesto)

Sistema → Configuración avanzada → Rendimiento → **Ajustar para obtener un mejor rendimiento** → dejar solo "Mostrar miniaturas en lugar de iconos".

---

## Fase 3 — Opcional avanzado (con precaución)

> Solo si Fase 0–2 no bastan. Crear restore point antes.

| Opción | Cuándo | Riesgo |
|--------|--------|--------|
| Chris Titus WinUtil (solo tweaks recomendados) | Quieres GUI para debloat reversible | Medio — usar solo perfil "Desktop" |
| Desactivar SysMain (Superfetch) | SSD + 16 GB RAM y aún hay lag de disco | Bajo — reversible |
| Desactivar hibernación (`powercfg /hibernate off`) | Liberar ~6 GB en C: | Pierdes hibernar rápido |
| Reinstalación limpia Windows 10 | LTT: único "unslow" casi como PC nueva | Alto — backup primero |

**LTT conclusión sobre tools**: Una reinstalación limpia gana a casi todos los speed-up tools pagos. Si el PC sigue lento con 16 GB RAM, evalúa fresh install antes de comprar más software.

---

## Fase 4 — Evaluación (30 días)

| Métrica | Actual | Meta | Herramienta |
|---------|--------|------|-------------|
| RAM libre (idle) | ~2 GB est. | >5 GB | Task Manager |
| CPU idle | 23% | <20% | Task Manager |
| Disco C: libre | 108 GB | >130 GB | Explorer |
| Memory Compression | ~505 MB | <100 MB | Task Manager |
| Apertura SOLIDWORKS | ? | <90 s | Cronómetro |
| Swap con 1 app CAD | Activo | Inactivo | Resource Monitor → Disco |

```powershell
# Regenerar baseline y comparar
cd C:\Users\miguelonches\Documents\pchealth
.\scripts\collect-baseline.ps1
```

### Árbol de decisión

```
¿16 GB RAM instalada?
├── NO → Fase 1 primero (no optimizar más software)
└── SÍ → ¿Metas cumplidas?
    ├── SÍ → Mantener; revisión cada 3 meses
    └── NO → ¿Disco >130 GB libre?
        ├── NO → Liberar espacio (Fase 0)
        └── SÍ → Fresh Windows O PC nuevo (Fase 3)
```

---

## Rutina de mantenimiento (LTT + PC Health)

| Frecuencia | Acción |
|------------|--------|
| Semanal | Cerrar apps no usadas; vaciar Papelera; revisar Descargas |
| Mensual | Disk Cleanup; `.\orchestrate.ps1`; revisar startup |
| Trimestral | Revisar programas instalados; actualizar drivers |
| Anual | CrystalDiskInfo (SMART SSD); evaluar hardware |

---

## Prioridad final (orden de ejecución)

1. **Liberar Downloads** (~91 GB) — mayor impacto sin hardware
2. **Drivers chipset/SATA** via Lenovo System Update
3. **Parar SQL Server** + apps background
4. **1 app CAD a la vez**
5. **Tuning SOLIDWORKS** (GPU ya al máximo)
6. PC nuevo a largo plazo — sin RAM, el límite de 8 GB permanece

---

**Próxima revisión**: 2026-07-16  
**Regenerar análisis**: `.\orchestrate.ps1`
