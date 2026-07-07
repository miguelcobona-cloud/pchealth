from __future__ import annotations

import json
import re
from functools import lru_cache

from src.config import CODES_FILE
from src.models import Language

OBD_PATTERN = re.compile(r"\b[PBCU][0-9A-F]{4}\b", re.IGNORECASE)


@lru_cache(maxsize=1)
def load_codes() -> dict[str, dict[str, object]]:
    with CODES_FILE.open(encoding="utf-8") as handle:
        return json.load(handle)


def extract_obd_code(text: str) -> str | None:
    match = OBD_PATTERN.search(text.upper())
    return match.group(0).upper() if match else None


def localized_field(entry: dict[str, object], field_prefix: str, language: Language) -> str:
    key = f"{field_prefix}_{language}"
    fallback_key = f"{field_prefix}_en"
    value = entry.get(key) or entry.get(fallback_key)
    return str(value) if value is not None else ""


def localized_list(entry: dict[str, object], field_prefix: str, language: Language) -> list[str]:
    key = f"{field_prefix}_{language}"
    fallback_key = f"{field_prefix}_en"
    value = entry.get(key) or entry.get(fallback_key)
    if isinstance(value, list):
        return [str(item) for item in value]
    return []


def lookup_code(code: str, language: Language) -> dict[str, object] | None:
    codes = load_codes()
    return codes.get(code.upper())


def list_available_codes() -> list[str]:
    return sorted(load_codes().keys())


SYMPTOM_KEYWORDS: dict[str, dict[Language, list[str]]] = {
    "P0217": {
        "en": ["overheating", "temperature high", "coolant hot", "red zone"],
        "es": ["sobrecalentamiento", "temperatura alta", "refrigerante caliente", "zona roja"],
    },
    "P0300": {
        "en": ["misfire", "rough idle", "shaking at idle", "engine stumble"],
        "es": ["fallo de encendido", "ralentí irregular", "vibración en ralentí", "tironeo"],
    },
    "P0171": {
        "en": ["lean", "hesitation", "lack of power"],
        "es": ["mezcla pobre", "hesitación", "falta de potencia"],
    },
    "P0562": {
        "en": ["battery light", "dim lights", "slow crank", "low voltage"],
        "es": ["luz de batería", "luces tenues", "arranque lento", "voltaje bajo"],
    },
    "P0442": {
        "en": ["check gas cap", "fuel smell near tank", "evap leak"],
        "es": ["tapón de gasolina", "olor a gasolina cerca del tanque", "fuga evap"],
    },
}


def match_symptom_to_code(text: str, language: Language) -> str | None:
    normalized = text.lower()
    for code, keywords in SYMPTOM_KEYWORDS.items():
        for keyword in keywords[language] + keywords["en"]:
            if keyword.lower() in normalized:
                return code
    return None
