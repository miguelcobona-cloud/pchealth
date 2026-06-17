# 08 — Limpieza de disco (plantilla)

## Principio

La GUI solo borra **basura acotada** (`.crdownload`, archivos sueltos en `%TEMP%` > 7 días).  
Las carpetas grandes de Downloads se **listan** en la pestaña Disco; el usuario decide qué mover o borrar.

## Pasos seguros

1. Abrir GUI → pestaña **Disco** (carga bajo demanda).
2. Revisar carpetas > umbral (`config/machine.json` → `downloads.min_folder_bytes`).
3. Mover instaladores ya usados a disco externo o NAS.
4. Opcional: **Disk Cleanup** de Windows (botón en Optimizar, requiere Admin).

## Comandos útiles (manual)

```powershell
# Solo descargas incompletas de navegador
Remove-Item "$env:USERPROFILE\Downloads\*.crdownload" -Force -ErrorAction SilentlyContinue
```

## No hacer automáticamente

- Borrar carpetas de proyectos, CAD o VMs
- Desinstalar software sin confirmación
- Vaciar Downloads completo

Configura hints opcionales en `config/machine.local.json` → `downloads.large_folder_hints`.
