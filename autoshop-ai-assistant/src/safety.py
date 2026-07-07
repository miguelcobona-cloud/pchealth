from __future__ import annotations

import re
from typing import Literal

from src.models import Language, Urgency

CRITICAL_PATTERNS: dict[str, list[str]] = {
    "en": [
        r"\bbrake(s)?\s+(fail|failure|lost|not\s+working|spongy|go(es)?\s+to\s+floor)\b",
        r"\bbrake(s)?\b.*\b(spongy|soft|go(es)?\s+to\s+(the\s+)?floor)\b",
        r"\bairbag\b",
        r"\bsrs\b",
        r"\bfuel\s+leak\b",
        r"\boverheat(ing|ed)?\b",
        r"\bsteering\s+(loss|locked|failed)\b",
        r"\bfire\b",
        r"\bsmoke\s+from\s+engine\b",
        r"\bno\s+brakes\b",
        r"\babs\s+light\b",
    ],
    "es": [
        r"\bfrenos?\s+(fallan|falla|no\s+funcionan|esponjosos|van\s+al\s+piso)\b",
        r"\bfrenos?\b.*\b(esponjoso|esponjosos|blandos?|van\s+al\s+piso)\b",
        r"\bbolsa\s+de\s+aire\b",
        r"\bairbag\b",
        r"\bfuga\s+de\s+combustible\b",
        r"\bsobrecalent(a|amiento|ado)\b",
        r"\bdirecci[oó]n\s+(perdida|bloqueada|falla)\b",
        r"\bfuego\b",
        r"\bhumo\s+del\s+motor\b",
        r"\bsin\s+frenos\b",
        r"\bluz\s+abs\b",
    ],
}

HIGH_PATTERNS: dict[str, list[str]] = {
    "en": [
        r"\btransmission\s+slip",
        r"\bwon'?t\s+start\b",
        r"\bstall(s|ing)?\s+at\s+highway\b",
        r"\bgrinding\s+noise\b",
    ],
    "es": [
        r"\btransmisi[oó]n\s+patin",
        r"\bno\s+arranca\b",
        r"\bse\s+apaga\s+en\s+carretera\b",
        r"\bruído\s+de\s+rechinamiento\b",
    ],
}

SAFETY_WARNINGS: dict[str, dict[str, str]] = {
    "en": {
        "critical": (
            "Stop driving if safe to do so. This symptom may indicate a serious "
            "safety risk. Seek professional inspection immediately."
        ),
        "high": (
            "This issue may worsen quickly. Avoid highway driving until inspected "
            "by a qualified technician."
        ),
    },
    "es": {
        "critical": (
            "Deje de conducir si es seguro hacerlo. Este síntoma puede indicar un "
            "riesgo grave. Busque inspección profesional de inmediato."
        ),
        "high": (
            "Este problema puede empeorar rápidamente. Evite carretera hasta que un "
            "técnico calificado lo revise."
        ),
    },
}


def detect_urgency_from_text(text: str, language: Language) -> tuple[Urgency, bool, str]:
    normalized = text.lower()
    lang: Language = language if language in CRITICAL_PATTERNS else "en"
    fallback_lang: Language = "en" if lang == "es" else "es"

    for pattern in CRITICAL_PATTERNS[lang] + CRITICAL_PATTERNS[fallback_lang]:
        if re.search(pattern, normalized, re.IGNORECASE):
            return (
                "critical",
                True,
                SAFETY_WARNINGS[lang]["critical"],
            )

    for pattern in HIGH_PATTERNS[lang] + HIGH_PATTERNS[fallback_lang]:
        if re.search(pattern, normalized, re.IGNORECASE):
            return (
                "high",
                True,
                SAFETY_WARNINGS[lang]["high"],
            )

    return "medium", False, ""


def merge_urgency(
    base: Urgency,
    professional_required: bool,
    text_urgency: Urgency,
    text_requires_pro: bool,
) -> tuple[Urgency, bool]:
    order: dict[Urgency, int] = {"low": 0, "medium": 1, "high": 2, "critical": 3}
    final_urgency: Urgency = base if order[base] >= order[text_urgency] else text_urgency
    return final_urgency, professional_required or text_requires_pro
