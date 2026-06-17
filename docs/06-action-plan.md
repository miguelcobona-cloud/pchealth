# 06 — Plan de acción (plantilla)

## Fase 0 — Quick wins (sin hardware)

| # | Acción | Herramienta | Estado |
|---|--------|-------------|--------|
| 0.1 | Optimización rápida | GUI | ☐ |
| 0.2 | Recolectar baseline | GUI / script | ☐ |
| 0.3 | Comparar antes/después | `Compare-Baseline.ps1` | ☐ |

## Fase 1 — Disco y servicios

| # | Acción | Estado |
|---|--------|--------|
| 1.1 | Limpieza ligera | ☐ |
| 1.2 | Revisar Downloads | ☐ |
| 1.3 | SQL → Manual (si aplica) | ☐ |

## Fase 2 — Hardware / upgrades

| # | Acción | Estado |
|---|--------|--------|
| 2.1 | Evaluar ampliación RAM | ☐ |

## Medición de éxito

| KPI | Antes | Después |
|-----|-------|---------|
| Health score | — | — |
| RAM libre en reposo | — | — |

```powershell
cd <ruta-del-proyecto>
.\orchestrate.ps1
.\scripts\Compare-Baseline.ps1
```
