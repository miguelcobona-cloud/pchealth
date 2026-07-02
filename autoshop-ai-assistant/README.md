# AutoShop AI Assistant

Bilingual automotive diagnostic assistant demo (Spanish / English) built with Python.  
Portfolio project combining **mechatronics domain knowledge**, **OBD-II codes**, and **LLM guardrails**.

![Python](https://img.shields.io/badge/Python-3.10+-blue)
![Streamlit](https://img.shields.io/badge/UI-Streamlit-red)
![Mode](https://img.shields.io/badge/Mode-Offline%20%2B%20LLM-green)

## Features

- **20 common OBD-II codes** with causes and verification steps (ES/EN)
- **Symptom-based matching** when no code is provided
- **Safety guardrails** for brakes, airbag, overheating, fuel leaks
- **Offline mode** — works without API keys (great for demos and interviews)
- **LLM mode** — OpenAI or Anthropic when `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` is set
- **CLI + Streamlit UI**

## Quick start

```bash
cd autoshop-ai-assistant
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### CLI demo (no API key needed)

```bash
python main.py P0300 --lang es
python main.py "engine overheating" --lang en
python main.py --demo --lang es
python main.py --list-codes
```

### Streamlit UI

```bash
streamlit run app.py
```

Open `http://localhost:8501` and try the example buttons.

### Optional LLM mode

```bash
cp .env.example .env
# Add OPENAI_API_KEY or ANTHROPIC_API_KEY
python main.py P0171 --mode auto --lang en
```

## Project structure

```
autoshop-ai-assistant/
├── app.py                 # Streamlit demo UI
├── main.py                # CLI entry point
├── data/common_codes.json # OBD database (bilingual)
├── prompts/system_prompt.md
├── src/
│   ├── assistant.py       # Diagnosis orchestration
│   ├── codes.py           # OBD lookup & symptom matching
│   ├── safety.py          # Critical symptom detection
│   ├── llm.py             # OpenAI / Anthropic integration
│   └── models.py
└── tests/test_assistant.py
```

## Example output

```
=== Reporte de diagnóstico ===

Código OBD: P0300
Descripción: Fallo de encendido aleatorio/múltiple detectado
Urgencia: MEDIUM
Requiere taller profesional: No

Posibles causas:
  • Bujías o bobinas de encendido desgastadas
  • Fuga de vacío
  ...
```

## Safety disclaimer

This project is for **educational and portfolio purposes only**.  
It does **not** replace diagnosis by a certified automotive technician.

## Author

Miguel Angel Corona Delgado — Mechatronics Engineering · AI Data Trainer · Automotive diagnostics

## License

MIT
