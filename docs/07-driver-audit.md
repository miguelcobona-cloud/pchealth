# 07 — Auditoría de drivers (plantilla)

**Fuente**: pestaña **Drivers** de la GUI o WMI `Win32_PnPSignedDriver`

## Enfoque

1. Actualizar vía sitio del **fabricante** detectado (Lenovo, Dell, HP, etc.).
2. Añadir notas en `config/machine.local.json` → `drivers.notes` para dispositivos conocidos.
3. No usar herramientas de drivers de terceros de pago.

## GPU

_Documentar versión desde baseline; comparar con soporte del fabricante._

## Chipset / red / audio

_Revisar con utilidad oficial del OEM._

## SQL Server (si instalado)

Servicios detectados por patrón `MSSQL$*` — detener solo si no se usa (botón en GUI, requiere Admin).

## Firewall

Ver pestaña Drivers → texto de reglas BLOCK en la GUI.
