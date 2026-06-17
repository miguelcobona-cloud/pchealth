# Resumen ejecutivo — PC Health Analysis

**Fecha**: 2026-06-16  
**Equipo**: LENOVO ThinkPad L450 (`20CLA32VLM`)  
**Cliente**: miguelonches  
**Estado del engagement**: Análisis inicial completado

---

## Veredicto en una frase

> Tienes un **portátil de 2015 con SSD moderno**, pero **8 GB de RAM y software de ingeniería pesado** (SOLIDWORKS 2024, MATLAB R2025b, SQL Server 2022) lo empujan al límite. La mejora con mayor ROI es **ampliar RAM a 16 GB** y **gestionar qué corre en simultáneo**.

## Scorecard

| Dimensión | Score | Comentario |
|-----------|-------|------------|
| Hardware base | 4/10 | CPU/GPU de 5ª gen; ya envejecidos para CAD 2024 |
| Almacenamiento | 8/10 | SSD Kingston 480 GB saludable — buena mejora previa |
| Memoria | 3/10 | 8 GB es el cuello de botella #1 |
| Software | 4/10 | Suite completa SOLIDWORKS + MATLAB + SQL en 8 GB |
| Configuración OS | 7/10 | Plan alto rendimiento; pocos programas al inicio |
| **Global** | **5.2/10** | Funcional con paciencia; mejorable sin comprar PC nuevo |

## Top 3 acciones (orden de impacto)

| # | Acción | Impacto | Esfuerzo | Coste |
|---|--------|---------|----------|-------|
| 1 | **RAM → 16 GB** (2×8 GB DDR3L-1600 SO-DIMM) | 🔴 Alto | Bajo (30 min) | ~$25–40 USD |
| 2 | **SQL Server: desactivar auto-inicio** si no se usa a diario | 🟠 Medio-alto | 5 min | $0 |
| 3 | **No abrir SOLIDWORKS + MATLAB + Edge/Cursor a la vez** | 🟠 Medio-alto | Hábito | $0 |

## Riesgos si no se actúa

- Swap constante → lentitud extrema y desgaste SSD
- Cierre inesperado de apps por falta de memoria
- Tiempos de apertura de SOLIDWORKS/MATLAB > 2–3 min
- Disco al 76% de uso — riesgo de quedarse sin espacio para archivos temporales CAD

## Próximo paso

Seguir el plan en [`06-action-plan.md`](06-action-plan.md), empezando por la **Fase 1 (esta semana)**.
