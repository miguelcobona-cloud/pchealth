# 09 — GitHub Landscape & Improvement Roadmap

**Research date**: 2026-06-16  
**Scope**: Open-source Windows health / diagnostics / optimization tools comparable to PC Health  
**Purpose**: Identify what others have built, what they do better, and a prioritized roadmap for this project

---

## Executive summary

PC Health occupies a **narrow but valuable niche**: a **Customer Success–style engagement** (contract, phased deliverables, executive summary, action plan) combined with a **machine-specific optimization GUI** for an engineering workstation (SOLIDWORKS, MATLAB, SQL Server on 8 GB RAM).

Most GitHub projects in this space fall into one of three camps:

| Camp | Focus | Examples |
|------|--------|----------|
| **IT field diagnostics** | Broad hardware/OS checks, portable toolkits | [SystemTester](https://github.com/Pnwcomputers/SystemTester), [PSWinVitals](https://github.com/ralish/PSWinVitals) |
| **Fleet / enterprise monitoring** | 100+ indicators, remote agents, HTML/email | [GetComputerHealth](https://github.com/ndemou/GetComputerHealth) |
| **Optimization + verification** | Tweaks, debloat, before/after benchmarks | [Winrift](https://github.com/emylfy/Winrift), [Windows-Optimize-Harden-Debloat](https://github.com/simeononsecurity/Windows-Optimize-Harden-Debloat) |

**None of them combine** (a) CS engagement documentation, (b) CAD/engineering workload context, and (c) a tailored WinForms dashboard in one repo. That is your differentiator.

The biggest gaps vs. mature projects are: **quantified health scoring**, **before/after baseline comparison**, **deeper diagnostics** (event logs, Windows Update, memory pressure), and **automated tests**.

---

## What PC Health already does well

Compared to the GitHub landscape, these strengths are uncommon together:

1. **Engagement methodology** — `CONTRACT.md`, phased `docs/00–08`, prioritized P0–P3 recommendations. Rivals produce logs; you produce a **client-ready narrative**.
2. **Actionable, low-risk optimizations** — high-performance power plan, SSD TRIM, lite cleanup, SQL service stop — with admin gates and a live log.
3. **Structured baseline** — `data/baseline.json` with hostname, modules, physical disk health, pagefile, startup list, top processes.
4. **Polished WinForms GUI** — themed dashboard, metric cards, tabbed workflow (Dashboard / Optimize / Disk / Drivers / Log), 30 s auto-refresh.
5. **Workload-aware content** — disk cleanup notes for SOLIDWORKS/MATLAB folders, Lenovo L450 driver guidance, SQL Express service names.

---

## Similar GitHub projects (detailed comparison)

### Tier 1 — Closest functional overlap

#### [Pnwcomputers/SystemTester](https://github.com/Pnwcomputers/SystemTester)

Portable, no-install PowerShell toolkit using **Sysinternals + CIM**. Produces a **clean summary report** and a **detailed technical report**.

| Area | SystemTester | PC Health |
|------|--------------|-----------|
| Portability | Thumb-drive friendly, zero install | Local project folder |
| Depth | CPU/RAM/disk/GPU/network/OS integrity (SFC, DISM), SMART, Windows Update | CIM snapshot + top processes |
| Reports | Auto-generated dual reports | Manual markdown docs + JSON |
| Remediation | Recommendations in report | One-click GUI actions |
| CS narrative | No | Yes (core strength) |

**Borrow**: SMART/WHEA checks, SFC/DISM optional scan, Windows Update pending status, `pslist`-style process depth.

---

#### [codepros100-dev/claude-windows-health-check](https://github.com/codepros100-dev/claude-windows-health-check)

Claude Code skill: **7 parallel PowerShell audit scripts** → scored markdown report (PASS/WARN/FAIL) → optional remediation → re-verify.

| Area | claude-windows-health-check | PC Health |
|------|----------------------------|-----------|
| Health score | 0–100 composite | Informal 5.2/10 in orchestrator |
| Categories | System, software, security, performance, network, services, hardware | Hardware, baseline, bottlenecks, recommendations |
| Workflow | Diagnose → Report → Remediate → Verify | Collect → Document → Manual optimize |
| Parallelism | 7 scripts in parallel | Sequential |

**Borrow**: PASS/WARN/FAIL per category, explicit **verify-after-fix** phase, parallel collection for speed.

---

#### [emylfy/Winrift](https://github.com/emylfy/Winrift)

Windows 11 optimizer with **built-in benchmarks** and **0–100 health score** across 7 weighted categories. Strong on **prove-it** optimization.

| Area | Winrift | PC Health |
|------|---------|-----------|
| Before/after | 13 metrics, JSON snapshots, Markdown diff | Single `baseline.json`, manual comparison |
| Sampling | 10 readings × 3 s (~30 s average) | Single-point WMI `LoadPercentage` |
| Metrics | DPC rate, context switches, committed memory, process/service counts | CPU load, RAM total, disk %, pagefile |
| Tests | 691 lines of Pester + CI | None |
| Safety | System Restore before changes | Admin prompt only |

**Borrow**: `Compare-Baseline` script, averaged performance counters, restore point before admin actions, Pester smoke tests.

---

#### [karanikn/WinDiag-AI](https://github.com/karanikn/WinDiag-AI)

WPF PowerShell GUI: **28 diagnostic categories**, standalone **HTML report**, optional **local Ollama AI** analysis with repair commands.

| Area | WinDiag-AI | PC Health |
|------|------------|-----------|
| UI | WPF + runspace threading | WinForms + timer |
| Export | Self-contained HTML | Markdown in `docs/` |
| Diagnostics | BSOD, event logs, battery, listening ports, drivers | Drivers (hardcoded map), firewall |
| AI | Optional local LLM summary | None |

**Borrow**: HTML export from `baseline.json`, BSOD/event-log section, background runspace so GUI stays responsive during long scans.

---

### Tier 2 — Architecture & module patterns

#### [jimbrig/PSSystemDiagnostics](https://github.com/jimbrig/PSSystemDiagnostics)

PowerShell **module** with `Get-SystemInfo`, `Get-ProcessAnalysis`, `Get-StartupAnalysis`, `Get-OptimizationRecommendations`, JSON output.

**Borrow**: Publish `pchealth-lib.ps1` as a proper module (`PCHealth.psd1`), export functions, versioned API.

---

#### [ndemou/GetComputerHealth](https://github.com/ndemou/GetComputerHealth)

Controller–agent framework: **100+ health indicators**, CLIXML + HTML reports, email on notable findings, **baseline drift** (new listening ports, new software).

**Borrow**: Extensible test registry (one function per check), HTML report template, optional “notable only” filter.

---

#### [ralish/PSWinVitals](https://github.com/ralish/PSWinVitals)

Gallery module: `Get-VitalInformation`, `Invoke-VitalChecks` (SFC, component store), `Invoke-VitalMaintenance` (updates, temp cleanup).

**Borrow**: Split **read-only inventory** vs **mutating maintenance** clearly (you already do this partially via admin flags).

---

#### [David-Martel/PC-AI](https://github.com/David-Martel/PC-AI)

Modular framework with **Rust/C# acceleration** for heavy scans, **local LLM** for interpretation, read-only by default.

**Borrow**: Optional AI layer that reads `baseline.json` + `docs/00-executive-summary.md` and suggests next steps — without cloud APIs.

---

### Tier 3 — Optimization-only (less overlap, useful ideas)

| Project | Stars (approx.) | Relevant idea for PC Health |
|---------|-----------------|------------------------------|
| [simeononsecurity/Windows-Optimize-Harden-Debloat](https://github.com/simeononsecurity/Windows-Optimize-Harden-Debloat) | ~1.3k | Separate GUI installer, audit-only mode, parameterized script flags |
| [hselimt/HST-WINDOWS-UTILITY](https://github.com/hselimt/HST-WINDOWS-UTILITY) | — | Per-feature documentation tooltips; C# backend for complex registry work |
| [hselimt/HST-WINDOWS-UTILITY](https://github.com/hselimt/HST-WINDOWS-UTILITY) | — | Warn that one-size-fits-all tweaks can break CAD licensing / SQL |

---

## Engineering workstation context (non-GitHub but relevant)

Open-source repos rarely target **SOLIDWORKS + MATLAB** explicitly. Industry practice (Dassault SOLIDWORKS, Hawk Ridge, MathWorks) recommends:

- **Process Explorer** — GDI/User objects, GPU VRAM per `SLDWORKS.exe`
- **Performance Monitor (`perfmon`)** — `Process → Private Bytes` for SOLIDWORKS memory over time
- **MATLAB `memory` command** — available physical RAM vs. MATLAB heap
- **RAMMap (Sysinternals)** — mapped file / standby list when “idle” RAM looks fine but apps swap

PC Health could add a **“CAD workload” profile** that watches `SLDWORKS`, `MATLAB`, `sqlservr` specifically — a gap no generic tweaker fills.

---

## Gap analysis: PC Health vs. best-of-breed

| Capability | Best reference | PC Health today | Priority |
|------------|----------------|-----------------|----------|
| Before/after baseline diff | Winrift | Manual JSON compare | **P0** |
| Composite health score (0–100) | Winrift, claude-windows-health-check | Ad-hoc 5.2/10 | **P0** |
| Averaged CPU/RAM counters | Winrift `Get-Counter` | Single WMI sample | **P1** |
| Windows Update / pending reboot | SystemTester, GetComputerHealth | Not collected | **P1** |
| Event log / BSOD summary | WinDiag-AI | Not collected | **P1** |
| HTML client report | WinDiag-AI, GetComputerHealth | Markdown only | **P1** |
| CAD-specific process watch | SOLIDWORKS best practices | Generic top-12 RAM | **P1** |
| Config-driven machine profile | — | Hardcoded L450 / SQL names | **P2** |
| Pester / CI tests | Winrift | None | **P2** |
| System Restore before changes | Winrift | None | **P2** |
| Optional local AI summary | PC-AI, WinDiag-AI | None | **P3** |
| Remote / fleet monitoring | GetComputerHealth | Single machine | **P3** |
| Sysinternals integration | SystemTester | External (Task Manager links) | **P3** |

---

## Recommended improvements (prioritized roadmap)

### Phase A — Quick wins (1–2 days)

1. **`Compare-Baseline.ps1`**  
   Load two `baseline.json` files; output a Markdown table (CPU, RAM, disk free, pagefile used, process count deltas). Wire a GUI button “Compare with previous baseline”.

2. **`Get-PcHealthScore` function**  
   Weighted score inspired by Winrift / claude-windows-health-check:

   | Category | Weight | Signals already in baseline |
   |----------|--------|----------------------------|
   | Memory | 25% | total_gb &lt; 12, pagefile usage ratio |
   | Storage | 20% | C: used %, physical_disk health |
   | CPU pressure | 15% | load_pct |
   | Startup bloat | 15% | startup array count |
   | Power | 10% | high-performance plan active |
   | Software risk | 15% | heuristic: SQL/MATLAB/SW in top processes + low RAM |

   Display score on Dashboard and in `orchestrate.ps1` summary.

3. **Restore point before admin actions**  
   `Checkpoint-Computer` (or `Enable-ComputerRestore` + checkpoint) before SQL stop, full disk cleanup, power tweaks.

4. **`config/machine.json`**  
   Move hardcoded values out of `pchealth-lib.ps1`:
   - Machine label, Lenovo support URL  
   - SQL service names  
   - RAM warning threshold (GB)  
   - Large-folder hints for Downloads tab  

---

### Phase B — Deeper diagnostics (3–5 days)

5. **Extend `collect-baseline.ps1`** with optional `-Deep` switch:
   - Pending Windows Updates (COM API)
   - Last boot / uptime
   - Pending reboot flag (registry/CBS)
   - Last 7 days: Application Error + WHEA-Logger (Event Log, capped)
   - Memory: `\Memory\Available MBytes`, `\Memory\Committed Bytes` via `Get-Counter` (3 samples)

6. **CAD workload section** in baseline + GUI tab:
   - Detect `SLDWORKS`, `MATLAB`, `sqlservr`, `MsMpEng` RAM + handle count
   - Flag if combined RAM &gt; 70% of physical memory
   - Link to `docs` snippet on “single heavy app” workflow

7. **`Export-PcHealthReport.ps1`**  
   Generate standalone `reports/pchealth-YYYYMMDD.html` from baseline + score + top recommendations (WinDiag-AI pattern).

8. **Background scan in GUI**  
   Run `collect-baseline` / deep checks in a PowerShell runspace so the UI does not freeze.

---

### Phase C — Quality & reuse (1 week+)

9. **PowerShell module layout**

   ```
   PCHealth/
   ├── PCHealth.psd1
   ├── Public/Get-PcSnapshot.ps1, Invoke-PcBaseline.ps1, ...
   ├── Private/...
   └── Tests/PCHealth.Tests.ps1
   ```

10. **Pester tests** — smoke tests for JSON schema, score calculation, admin gate logic.

11. **Orchestrator auto-doc** — `orchestrate.ps1` regenerates sections of `03-performance-baseline.md` from `baseline.json` (today partially manual).

12. **Optional Ollama integration** — read-only: send executive summary + baseline JSON to local `/api/chat`; append “AI notes” to report (opt-in).

---

## What NOT to copy (lessons from other repos)

| Pattern in other tools | Risk for your use case |
|------------------------|-------------------------|
| Aggressive debloat / telemetry kill | Can break Windows Update, licensing, SOLIDWORKS add-ins |
| Blind service disabling | SQL Server, FLEXlm, SolidWorks licensing services |
| One-size-fits-all registry packs | ThinkPad power management differs from desktop gaming rigs |
| Cloud AI diagnostics | Engineering IP on disk; keep local-only default |
| Replacing your markdown engagement | Clients need the narrative; JSON/HTML is a supplement |

Your `CONTRACT.md` policy (“no destructive changes without approval”) is **stronger than most GitHub optimizers**. Keep it.

---

## Suggested positioning if you publish to GitHub

**Tagline**: *Customer Success–style PC health engagement for engineering workstations — diagnose, document, optimize with evidence.*

**Topics**: `powershell`, `windows`, `system-diagnostics`, `performance`, `solidworks`, `baseline`, `winforms`

**Differentiators to highlight in README**:
- Engagement docs, not just a script dump  
- Before/after baseline for measurable ROI  
- CAD-aware recommendations  
- Safe-by-default remediation with admin consent  

---

## Reference links

| Project | URL |
|---------|-----|
| SystemTester | https://github.com/Pnwcomputers/SystemTester |
| PSSystemDiagnostics | https://github.com/jimbrig/PSSystemDiagnostics |
| PC-AI | https://github.com/David-Martel/PC-AI |
| claude-windows-health-check | https://github.com/codepros100-dev/claude-windows-health-check |
| GetComputerHealth | https://github.com/ndemou/GetComputerHealth |
| PSWinVitals | https://github.com/ralish/PSWinVitals |
| WinDiag-AI | https://github.com/karanikn/WinDiag-AI |
| Winrift | https://github.com/emylfy/Winrift |
| Windows-Optimize-Harden-Debloat | https://github.com/simeononsecurity/Windows-Optimize-Harden-Debloat |
| HST Windows Utility | https://github.com/hselimt/HST-WINDOWS-UTILITY |

---

## Next step for this repo

Implement **Phase A** first: `Compare-Baseline.ps1`, `Get-PcHealthScore`, and `config/machine.json`. These deliver the highest visible value with minimal risk and align PC Health with the best patterns found on GitHub while preserving your unique CS engagement model.
