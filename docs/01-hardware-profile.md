# 01 — Perfil de hardware

## Identificación

| Campo | Valor |
|-------|-------|
| Fabricante | LENOVO |
| Modelo | 20CLA32VLM (ThinkPad L450) |
| BIOS | N10ET36W (1.15) |
| SO | Windows 10 Home (build 2009 / HAL 10.0.26100) |
| Zona horaria | UTC-06:00 (México) |

## Procesador

| Especificación | Valor |
|----------------|-------|
| Modelo | Intel Core i7-5600U @ 2.60 GHz |
| Generación | 5ª gen Broadwell (2015) |
| Núcleos / Hilos | 2 / 4 |
| Carga al diagnóstico | **91%** |

**Evaluación**: CPU de ultrabook de hace ~11 años. Adecuada para Office y navegación; **justa para SOLIDWORKS 2024 y MATLAB R2025b**. No es sustituible en portátil.

## Memoria RAM

| Especificación | Valor |
|----------------|-------|
| Instalada | **8 GB** |
| Máximo soportado (L450) | **16 GB** (2 slots SO-DIMM) |
| Tipo requerido | DDR3L-1600 (1.35 V) |

**Evaluación**: 🔴 **Cuello de botella principal**. SOLIDWORKS 2024 recomienda 16 GB mínimo; MATLAB R2025b idem. Con 8 GB el sistema usa pagefile agresivamente.

## Almacenamiento

| Disco | Tipo | Capacidad | Libre | Uso |
|-------|------|-----------|-------|-----|
| Kingston SA400S37480G | SSD SATA | 446 GB | 109 GB | ~76% |

| Métrica | Estado |
|---------|--------|
| HealthStatus | Healthy |
| OperationalStatus | OK |

**Evaluación**: ✅ Buen upgrade respecto a HDD original. SSD saludable. Mantener >15% libre (ideal >20%).

## Gráficos

| GPU | Driver |
|-----|--------|
| Intel HD Graphics 5500 | 20.19.15.5171 |

**Evaluación**: ⚠️ GPU integrada sin VRAM dedicada. SOLIDWORKS Visualize y render 3D serán lentos. Aceptable para modelado 2D/ligero 3D con calidad gráfica reducida.

## Energía

| Configuración | Valor |
|---------------|-------|
| Plan activo | **Alto rendimiento** |
| CPU throttle máx | 100% (AC y batería) |

**Evaluación**: ✅ Correctamente configurado para rendimiento.

## Batería

| Métrica | Valor |
|---------|-------|
| Carga | ~72% (en diagnóstico) |

## Pagefile

| Parámetro | Valor |
|-----------|-------|
| Ubicación | C:\pagefile.sys |
| Asignado | 7 680 MB |
| En uso | ~532 MB (al momento del scan) |

Con 8 GB de RAM, el pagefile de 7.5 GB es normal pero indica presión de memoria bajo carga.

## Límites del hardware (realistas)

| Mejora | ¿Posible? | Notas |
|--------|-----------|-------|
| Más RAM | ✅ Sí, hasta 16 GB | **Mayor impacto** |
| SSD más rápido | ⚠️ Marginal | Ya tienes SSD; NVMe no disponible (SATA) |
| CPU/GPU | ❌ No | Soldados / integrados |
| PC nuevo | ✅ | Única vía para CAD fluido a largo plazo |
