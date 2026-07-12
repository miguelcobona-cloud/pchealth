# AGENTS.md

This repository contains two independent products that share no code:

- **PC Health** (repo root): a Windows-only PowerShell/WinForms desktop diagnostics tool (`pchealth-gui.ps1`, `orchestrate.ps1`, `src/*.psm1`, tests via Pester). See `README.md`.
- **`dental-demo/`**: a Next.js 16 + React 19 + Tailwind v4 marketing/booking website ("Sonríe Dental"). See `dental-demo/README.md` and `dental-demo/AGENTS.md`.

## Cursor Cloud specific instructions

- The **PC Health** product (repo root) is **Windows-only** (Windows PowerShell 5.1, WinForms, WMI/CIM). It **cannot run or be tested on this Linux cloud VM** — no PowerShell runtime is present. Only its Pester tests would run under a Windows host.
- **`dental-demo/` is the only runnable product on this VM.** All standard commands are in `dental-demo/package.json` (`dev`, `build`, `start`, `lint`). Run them from the `dental-demo/` directory.
- The app is self-contained: **no database, no environment variables, and no external services** are required. `/api/bookings` is an in-memory route that validates fields and returns a synthetic booking (`SD-...`) — nothing is persisted.
- Dev server runs on port `3000` (`npm run dev`). Booking wizard lives at `/agendar`.
- Next.js 16 has breaking changes vs. older versions; per `dental-demo/AGENTS.md`, consult `node_modules/next/dist/docs/` before writing Next.js code.
