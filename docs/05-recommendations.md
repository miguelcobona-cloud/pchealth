# 05 — Recomendaciones priorizadas

Leyenda: **Impacto** (1–5) × **Esfuerzo** (1–5, menor = más fácil). Prioridad P0 = urgente.

---

## P0 — Crítico (hacer ya)

### R-01 · Ampliar RAM a 16 GB

| | |
|---|---|
| **Impacto** | ⭐⭐⭐⭐⭐ |
| **Esfuerzo** | ⭐ (comprar + instalar) |
| **Coste** | ~$15–25 USD (solo 1 módulo) |
| **Detalle** | Tienes **1×8 GB** Samsung DDR3L-1600. Añadir **1×8 GB** idéntico (no reemplazar dos módulos). Mismo voltaje 1.35 V. |
| **Ganancia esperada** | 40–60% mejora en multitarea CAD; elimina swap en uso normal |

### R-02 · Regla de una app pesada a la vez

| | |
|---|---|
| **Impacto** | ⭐⭐⭐⭐ |
| **Esfuerzo** | ⭐ (hábito) |
| **Coste** | $0 |
| **Detalle** | Cerrar MATLAB antes de abrir SOLIDWORKS. Cerrar Edge/Cursor si no los necesitas durante CAD. |
| **Ganancia esperada** | Evita cuelgues inmediatos |

---

## P1 — Alto impacto (esta semana)

### R-03 · SQL Server: manual o deshabilitado

| | |
|---|---|
| **Impacto** | ⭐⭐⭐ |
| **Esfuerzo** | ⭐ |
| **Coste** | $0 |

```powershell
# Ejecutar como Administrador — solo si NO usas SQL diariamente
Stop-Service MSSQLSERVER -Force
Set-Service MSSQLSERVER -StartupType Manual
```

También revisar `SQLSERVERAGENT` y `SQLTELEMETRY`.

### R-04 · Liberar espacio en disco C:

| | |
|---|---|
| **Impacto** | ⭐⭐⭐ |
| **Esfuerzo** | ⭐⭐ |
| **Coste** | $0 |
| **Acciones** | Disk Cleanup → archivos sistema; desinstalar apps no usadas; mover proyectos SW/MATLAB a disco externo; vaciar Downloads |

**Objetivo**: >130 GB libres (>25%).

### R-05 · Optimizar SOLIDWORKS para hardware débil

| | |
|---|---|
| **Impacto** | ⭐⭐⭐ |
| **Esfuerzo** | ⭐⭐ |
| **Coste** | $0 |

En SOLIDWORKS → Herramientas → Opciones → Rendimiento:
- Activar **Use Software OpenGL** si hay artefactos
- Desactivar **RealView Graphics**
- Desactivar **Shadows in Shaded Mode**
- Reducir nivel de detalle en assemblies grandes
- Usar **Large Assembly Mode**

### R-06 · Desinstalar módulos SOLIDWORKS no usados

| | |
|---|---|
| **Impacto** | ⭐⭐⭐ |
| **Esfuerzo** | ⭐⭐⭐ |
| **Coste** | $0 |

Candidatos si no los usas: Visualize, Visualize Boost, Plastics, Flow Simulation, Inspection, Composer.

> Mantén solo core + los que uses semanalmente.

---

## P2 — Impacto medio (este mes)

### R-07 · Pagefile tamaño fijo

| | |
|---|---|
| **Impacto** | ⭐⭐ |
| **Esfuerzo** | ⭐⭐ |
| **Detalle** | Con 16 GB RAM: pagefile fijo 4096 MB en C:. Con 8 GB actual: mantener 8192 MB fijo (evita fragmentación por resize). |

Configuración: Sistema → Configuración avanzada → Rendimiento → Avanzado → Memoria virtual.

### R-08 · OneDrive: archivos bajo demanda

| | |
|---|---|
| **Impacto** | ⭐⭐ |
| **Esfuerzo** | ⭐⭐ |
| **Detalle** | Evitar sync de carpetas con proyectos CAD pesados. Excluir `.SLDPRT`, `.SLDASM` del sync si no necesitas backup cloud. |

### R-09 · Windows Defender exclusiones (con cuidado)

| | |
|---|---|
| **Impacto** | ⭐⭐ |
| **Esfuerzo** | ⭐⭐ |
| **Detalle** | Excluir carpetas de trabajo SOLIDWORKS/MATLAB del escaneo en tiempo real. **Solo carpetas de confianza.** |

### R-10 · Desinstalar DAEMON Tools / Glary si no se usan

| | |
|---|---|
| **Impacto** | ⭐ |
| **Esfuerzo** | ⭐ |
| **Coste** | $0 |

### R-11 · MATLAB: aumentar swap y limitar workers

```matlab
% En MATLAB, reducir paralelismo
maxNumCompThreads(2);
```

---

## P3 — Largo plazo

### R-12 · Planificar reemplazo de equipo

| | |
|---|---|
| **Impacto** | ⭐⭐⭐⭐⭐ |
| **Esfuerzo** | ⭐⭐⭐⭐⭐ |
| **Detalle** | Para SOLIDWORKS 2024 + MATLAB R2025b cómodamente: i7/i9 o Ryzen 7 reciente, **32 GB RAM**, GPU dedicada (NVIDIA RTX), SSD NVMe 1 TB. |

### R-13 · Considerar SOLIDWORKS en máquina remota / cloud

Si el presupuesto no permite PC nuevo, una estación remota o VM dedicada puede ser más rentable que forzar este portátil.

---

## Resumen rápido

| Prioridad | Cantidad | Inversión |
|-----------|----------|-----------|
| P0 | 2 | ~$30 + hábitos |
| P1 | 4 | $0 |
| P2 | 5 | $0 |
| P3 | 2 | $800–1500+ (PC nuevo) |

**ROI máximo**: R-01 (RAM 16 GB) + R-03 (SQL manual) + R-05 (tuning SW).
