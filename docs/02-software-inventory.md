# 02 — Inventario de software

## Resumen

El equipo está configurado como **estación de trabajo de ingeniería/diseño**, no como PC de oficina ligera. La combinación de aplicaciones explica la mayor parte de la lentitud percibida.

## Software pesado (impacto en rendimiento)

### CAD / Ingeniería — SOLIDWORKS 2024 SP02 (suite completa)

| Componente | Impacto RAM típico |
|------------|-------------------|
| SOLIDWORKS core | 2–4 GB |
| Flow Simulation | +1–2 GB |
| Plastics / CAM / Composer | +500 MB–1 GB c/u |
| Visualize | +2–4 GB (render) |

> Ejecutar la suite completa en 8 GB es **inviable** sin swap masivo.

### Cálculo — MATLAB R2025b

| Impacto | Notas |
|---------|-------|
| 2–8 GB RAM | Depende del workspace; R2025b es más pesado que versiones anteriores |

### Base de datos — SQL Server 2022

| Servicio | Riesgo |
|----------|--------|
| Database Engine | Consume RAM en background aunque no uses SQL |
| Múltiples instancias/componentes instalados | ~15+ paquetes SQL en el sistema |

> Si SQL Server no es necesario en el día a día, **desactivar el servicio** libera 500 MB–2 GB.

### Diseño / Adobe

| App | Notas |
|-----|-------|
| CorelDRAW 2022 | Moderado |
| Adobe Photoshop 2022 | Moderado-alto con archivos grandes |

### Otros relevantes

| Software | Notas |
|----------|-------|
| Microsoft 365 | Normal |
| Microsoft OneDrive | Sync en background — puede competir por disco/CPU |
| Glary Utilities | Útil para limpieza; no dejar corriendo en background |
| DAEMON Tools Lite | Innecesario si no montas ISOs a diario |
| Git, Java 8 | Ligeros |
| Copilot | Background AI — consume RAM |

## Programas al inicio (startup)

| Programa | Ubicación |
|----------|-----------|
| SecurityHealthSystray | HKLM Run |

**Evaluación**: ✅ Muy limpio. No hay bloatware evidente en autostart.

## Servicios

- **123 servicios** en ejecución (normal en Windows con SQL Server)
- Revisar servicios SQL si no se usan diariamente

## Mapa de conflicto de recursos

```
                    ┌─────────────────┐
                    │   8 GB RAM      │
                    └────────┬────────┘
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
   ┌───────────┐      ┌────────────┐      ┌────────────┐
   │ Windows   │      │ SOLIDWORKS │      │ MATLAB     │
   │ ~2-3 GB   │      │ 2-6 GB     │      │ 2-8 GB     │
   └───────────┘      └────────────┘      └────────────┘
         +                   +                   +
   ┌───────────┐      ┌────────────┐      ┌────────────┐
   │ Defender  │      │ SQL Server │      │ Cursor/Edge│
   │ ~300 MB   │      │ 0.5-2 GB   │      │ 1-2 GB     │
   └───────────┘      └────────────┘      └────────────┘
```

**Conclusión**: Con 8 GB, abrir 2 apps pesadas simultáneamente ya satura el sistema.
