from __future__ import annotations

import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from src.assistant import diagnose
from src.codes import extract_obd_code, list_available_codes, lookup_code
from src.safety import detect_urgency_from_text


def test_extract_obd_code_from_text() -> None:
    assert extract_obd_code("My scanner shows code p0300 today") == "P0300"
    assert extract_obd_code("no code here") is None


def test_offline_known_code_spanish() -> None:
    report = diagnose("P0300", language="es", mode="offline")
    assert report.matched_code == "P0300"
    assert report.possible_causes
    assert report.verification_steps
    assert report.source == "offline"


def test_offline_known_code_english() -> None:
    report = diagnose("P0171", language="en", mode="offline")
    assert report.matched_code == "P0171"
    assert report.code_description
    assert "lean" in report.code_description.lower() or report.possible_causes


def test_critical_symptom_forces_professional() -> None:
    report = diagnose(
        "Los frenos se sienten esponjosos y el pedal va al piso",
        language="es",
        mode="offline",
    )
    assert report.urgency == "critical"
    assert report.professional_required is True
    assert report.safety_warning


def test_spongy_brakes_spanish() -> None:
    report = diagnose(
        "Los frenos se sienten esponjosos",
        language="es",
        mode="offline",
    )
    assert report.urgency == "critical"
    assert report.professional_required is True


def test_overheating_code_is_critical() -> None:
    entry = lookup_code("P0217", "en")
    assert entry is not None
    report = diagnose("P0217", language="en", mode="offline")
    assert report.urgency == "critical"
    assert report.professional_required is True


def test_symptom_keyword_matching() -> None:
    report = diagnose("engine overheating at highway speed", language="en", mode="offline")
    assert report.matched_code == "P0217"


def test_unknown_code_returns_guidance() -> None:
    report = diagnose("P9999", language="en", mode="offline")
    assert report.matched_code is None
    assert report.clarifying_questions


def test_database_has_minimum_codes() -> None:
    assert len(list_available_codes()) >= 15


def test_safety_detector_english() -> None:
    urgency, requires_pro, warning = detect_urgency_from_text(
        "airbag light is flashing", "en"
    )
    assert urgency == "critical"
    assert requires_pro is True
    assert warning


@pytest.mark.parametrize("language", ["es", "en"])
def test_disclaimer_present(language: str) -> None:
    report = diagnose("P0442", language=language, mode="offline")  # type: ignore[arg-type]
    assert report.disclaimer
