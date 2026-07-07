from __future__ import annotations

from typing import Any, Literal

from src.codes import (
    extract_obd_code,
    localized_field,
    localized_list,
    lookup_code,
    match_symptom_to_code,
)
from src.config import get_disclaimer
from src.llm import call_llm
from src.models import DiagnosticReport, Language, Source, Urgency
from src.safety import detect_urgency_from_text, merge_urgency

Mode = Literal["auto", "offline", "llm"]


def _normalize_urgency(value: str) -> Urgency:
    normalized = value.lower().strip()
    if normalized in {"low", "medium", "high", "critical"}:
        return normalized  # type: ignore[return-value]
    return "medium"


def _build_offline_report(user_input: str, language: Language) -> DiagnosticReport:
    code = extract_obd_code(user_input) or match_symptom_to_code(user_input, language)
    text_urgency, text_requires_pro, safety_warning = detect_urgency_from_text(
        user_input, language
    )

    if code:
        entry = lookup_code(code, language)
        if entry:
            base_urgency = _normalize_urgency(str(entry.get("urgency", "medium")))
            professional_required = bool(entry.get("professional_required", False))
            urgency, professional_required = merge_urgency(
                base_urgency,
                professional_required,
                text_urgency,
                text_requires_pro,
            )
            if not safety_warning and urgency in {"critical", "high"}:
                from src.safety import SAFETY_WARNINGS

                safety_warning = SAFETY_WARNINGS[language][urgency]

            return DiagnosticReport(
                input_summary=user_input.strip(),
                language=language,
                possible_causes=localized_list(entry, "causes", language),
                verification_steps=localized_list(entry, "steps", language),
                urgency=urgency,
                professional_required=professional_required,
                safety_warning=safety_warning,
                matched_code=code,
                code_description=localized_field(entry, "description", language),
                source="offline",
                disclaimer=get_disclaimer(language),
            )

    if text_urgency in {"critical", "high"}:
        questions = (
            [
                "¿Puede describir cuándo comenzó el síntoma y si hay luces en el tablero?",
                "¿Hay olores, humo o ruidos inusuales?",
                "¿El vehículo es seguro para conducir ahora mismo?",
            ]
            if language == "es"
            else [
                "When did the symptom start and are any dashboard warning lights on?",
                "Are there unusual smells, smoke, or noises?",
                "Is the vehicle safe to drive right now?",
            ]
        )
        return DiagnosticReport(
            input_summary=user_input.strip(),
            language=language,
            possible_causes=[],
            verification_steps=[],
            urgency=text_urgency,
            professional_required=True,
            safety_warning=safety_warning,
            clarifying_questions=questions,
            source="offline",
            disclaimer=get_disclaimer(language),
        )

    questions = (
        [
            "¿Tiene un código OBD-II del escáner (ej. P0300)?",
            "¿Cuál es marca, modelo y año del vehículo?",
            "¿El problema ocurre en frío, en caliente o siempre?",
        ]
        if language == "es"
        else [
            "Do you have an OBD-II code from a scanner (e.g. P0300)?",
            "What is the vehicle make, model, and year?",
            "Does the issue happen when cold, hot, or always?",
        ]
    )
    return DiagnosticReport(
        input_summary=user_input.strip(),
        language=language,
        possible_causes=(
            [
                "Código no reconocido en la base local — verifique la lectura del escáner",
                "Síntoma descrito sin código — puede requerir escaneo adicional",
            ]
            if language == "es"
            else [
                "Code not found in local database — verify scanner reading",
                "Symptom described without code — additional scanning may be needed",
            ]
        ),
        verification_steps=(
            [
                "Confirme el código con un escáner OBD-II",
                "Revise luces del tablero y condiciones cuando ocurre la falla",
                "Consulte a un técnico si el síntoma afecta seguridad o conducción",
            ]
            if language == "es"
            else [
                "Confirm the code with an OBD-II scanner",
                "Note dashboard lights and conditions when the fault occurs",
                "Consult a technician if the symptom affects safety or drivability",
            ]
        ),
        urgency="medium",
        professional_required=False,
        clarifying_questions=questions,
        source="offline",
        disclaimer=get_disclaimer(language),
    )


def _report_from_llm_payload(
    user_input: str,
    language: Language,
    payload: dict[str, Any],
    source: Source,
    matched_code: str | None = None,
) -> DiagnosticReport:
    text_urgency, text_requires_pro, safety_warning = detect_urgency_from_text(
        user_input, language
    )
    urgency = _normalize_urgency(str(payload.get("urgency", "medium")))
    urgency, professional_required = merge_urgency(
        urgency,
        bool(payload.get("professional_required", False)),
        text_urgency,
        text_requires_pro,
    )
    if not safety_warning:
        safety_warning = str(payload.get("safety_warning", ""))

    code_description = None
    if matched_code:
        entry = lookup_code(matched_code, language)
        if entry:
            code_description = localized_field(entry, "description", language)

    return DiagnosticReport(
        input_summary=user_input.strip(),
        language=language,
        possible_causes=[str(item) for item in payload.get("possible_causes", [])],
        verification_steps=[str(item) for item in payload.get("verification_steps", [])],
        urgency=urgency,
        professional_required=professional_required,
        safety_warning=safety_warning,
        clarifying_questions=[
            str(item) for item in payload.get("clarifying_questions", [])
        ],
        matched_code=matched_code,
        code_description=code_description,
        source=source,
        disclaimer=get_disclaimer(language),
    )


def diagnose(user_input: str, language: Language = "es", mode: Mode = "auto") -> DiagnosticReport:
    if not user_input.strip():
        raise ValueError("Input cannot be empty")

    matched_code = extract_obd_code(user_input)

    if mode == "offline":
        return _build_offline_report(user_input, language)

    if mode == "llm":
        payload, source = call_llm(user_input, language)
        return _report_from_llm_payload(user_input, language, payload, source, matched_code)

    try:
        payload, source = call_llm(user_input, language)
        return _report_from_llm_payload(user_input, language, payload, source, matched_code)
    except RuntimeError:
        return _build_offline_report(user_input, language)
