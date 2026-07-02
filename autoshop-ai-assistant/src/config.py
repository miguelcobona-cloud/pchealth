from __future__ import annotations

import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data"
PROMPTS_DIR = PROJECT_ROOT / "prompts"
CODES_FILE = DATA_DIR / "common_codes.json"
SYSTEM_PROMPT_FILE = PROMPTS_DIR / "system_prompt.md"

DISCLAIMER_EN = (
    "Educational use only. This assistant does not replace professional "
    "diagnosis by a certified mechanic."
)
DISCLAIMER_ES = (
    "Solo para fines educativos. Este asistente no sustituye el diagnóstico "
    "profesional de un mecánico certificado."
)


def get_disclaimer(language: str) -> str:
    return DISCLAIMER_ES if language == "es" else DISCLAIMER_EN


def get_openai_api_key() -> str | None:
    return os.getenv("OPENAI_API_KEY")


def get_anthropic_api_key() -> str | None:
    return os.getenv("ANTHROPIC_API_KEY")


def get_openai_model() -> str:
    return os.getenv("OPENAI_MODEL", "gpt-4o-mini")


def get_anthropic_model() -> str:
    return os.getenv("ANTHROPIC_MODEL", "claude-3-5-haiku-20241022")
