# Contrato de Engagement — PC Health Analysis

## Partes

| Rol | Responsabilidad |
|-----|-----------------|
| **Cliente** | Proporcionar acceso al equipo, ejecutar acciones aprobadas, validar resultados |
| **CS / Analista** | Diagnosticar, documentar, priorizar y recomendar sin ejecutar cambios destructivos sin aprobación |

## Alcance

Este engagement cubre un **análisis de salud y rendimiento** del equipo, con entregables en `docs/` y un script de recolección reproducible.

### Incluido

- Inventario de hardware y software
- Línea base de rendimiento (CPU, RAM, disco, procesos)
- Identificación de cuellos de botella
- Recomendaciones priorizadas (impacto × esfuerzo)
- Plan de acción por fases

### Excluido

- Compra de hardware (solo se recomienda)
- Reinstalación de Windows sin aprobación explícita
- Eliminación de software de producción sin confirmación del cliente

## Metodología (flujo CS)

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│  Discovery  │───▶│   Baseline   │───▶│  Analysis   │───▶│ Recommend.   │
│  (contrato) │    │  (collect)   │    │  (docs/)    │    │  + Action    │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
   CONTRACT.md      baseline.json         01-06 *.md         06-action-plan
```

### Fases

| Fase | Entregable | Criterio de éxito |
|------|------------|-------------------|
| **0. Kickoff** | `CONTRACT.md`, `README.md` | Alcance acordado |
| **1. Discovery** | `docs/01-hardware-profile.md`, `docs/02-software-inventory.md` | Inventario completo |
| **2. Baseline** | `docs/03-performance-baseline.md`, `data/baseline.json` | Métricas capturadas |
| **3. Analysis** | `docs/04-bottlenecks.md` | Cuellos de botella identificados |
| **4. Recommend** | `docs/05-recommendations.md` | Lista priorizada P0–P3 |
| **5. Close** | `docs/00-executive-summary.md`, `docs/06-action-plan.md` | Plan ejecutable |

## Orquestación

Ejecutar el análisis completo:

```powershell
.\orchestrate.ps1
```

Esto:

1. Crea la estructura `docs/` y `data/` si no existen
2. Ejecuta `scripts\collect-baseline.ps1`
3. Genera/actualiza los markdown en `docs/`
4. Emite un resumen en consola

## Política de cambios

- **P0 (crítico)**: Requiere acción inmediata; riesgo alto de degradación
- **P1 (alto)**: Mejora notable con esfuerzo moderado
- **P2 (medio)**: Optimización incremental
- **P3 (bajo)**: Nice-to-have

Ningún cambio P0+ se ejecuta automáticamente. El cliente aprueba cada ítem del plan.

## Registro de engagement (opcional)

Completa localmente si usas la metodología CS; no es necesario para ejecutar la app.

| Campo | Valor |
|-------|--------|
| **Inicio** | _fecha_ |
| **Equipo** | _modelo / serial (ver `data/baseline.json`)_ |
| **Estado** | _en curso / completado_ |

Perfil opcional del equipo: copia `config/machine.json.example` → `config/machine.json` y edítalo en tu máquina (no subas datos personales al repositorio).
