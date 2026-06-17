# 03 — Línea base de rendimiento (plantilla)

**Fuente**: `data/baseline.json` (regenerable con `.\scripts\collect-baseline.ps1`)

## Métricas clave

| Métrica | Valor | Fecha |
|---------|-------|-------|
| CPU load % | _baseline_ | _collected_at_ |
| RAM total GB | _baseline_ | |
| Disco C: libre GB | _baseline_ | |
| Health score /100 | _orchestrate.ps1_ | |

## Top procesos (RAM)

_Ver `top_processes` en baseline._

## Cómo regenerar

```powershell
.\scripts\collect-baseline.ps1
.\scripts\Compare-Baseline.ps1   # tras una segunda captura
```

## Objetivos (ejemplo)

| Métrica | Actual | Objetivo |
|---------|--------|----------|
| RAM libre con carga típica | — | >2 GB |
| Disco C: libre | — | >15% del total |
