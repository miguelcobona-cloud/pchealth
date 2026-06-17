# 03 — Línea base de rendimiento

**Capturado**: 2026-06-16  
**Fuente**: `data/baseline.json` (regenerable con `.\scripts\collect-baseline.ps1`)

## Snapshot al momento del análisis

| Métrica | Valor | Semáforo |
|---------|-------|----------|
| CPU load | 91% | 🔴 |
| RAM total | 8 GB | 🔴 |
| Disco C: libre | 109 GB / 446 GB (24%) | 🟡 |
| SSD health | Healthy | 🟢 |
| Plan energía | Alto rendimiento | 🟢 |
| Pagefile en uso | 532 MB / 7680 MB | 🟡 |

## Top procesos por RAM (al diagnóstico)

| Proceso | RAM (MB) | Notas |
|---------|----------|-------|
| Cursor | ~477 + instancias | IDE activo — varias ventanas |
| Memory Compression | ~404 | Windows comprimiendo RAM — señal de presión |
| MsMpEng | ~325 | Windows Defender |
| msedge / webview2 | ~159–209 | Navegador |
| **Total top 10** | **~2.8 GB** | Sin SOLIDWORKS/MATLAB abiertos |

> La presencia de **Memory Compression** a ~400 MB confirma que Windows ya está optimizando por falta de RAM headroom.

## Indicadores clave

### CPU al 91% sin CAD abierto

Causas probables durante el scan:
- Cursor con múltiples procesos
- Windows Defender escaneando
- OneDrive sync
- Indexación de Windows

### Disco al 76% de uso

| Umbral | Estado |
|--------|--------|
| <70% | Óptimo |
| 70–85% | Aceptable — monitorear |
| >85% | Riesgo de rendimiento |

Estás en zona **aceptable pero ajustada**. SOLIDWORKS y MATLAB generan archivos temporales grandes.

## Cómo regenerar baseline

```powershell
cd C:\Users\miguelonches\Documents\pchealth
.\scripts\collect-baseline.ps1
```

Comparar `data/baseline.json` antes/después de cada fase del plan de acción.

## Métricas objetivo post-optimización

| Métrica | Actual | Objetivo |
|---------|--------|----------|
| CPU idle (sin apps pesadas) | ~91% usado | <30% usado |
| RAM disponible (idle) | <2 GB libre est. | >4 GB libre |
| Apertura SOLIDWORKS | ? (medir) | <60 s |
| Disco libre C: | 109 GB | >130 GB |
