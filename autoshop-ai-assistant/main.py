from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from src.assistant import diagnose
from src.codes import list_available_codes
from src.models import DiagnosticReport, Language


def format_report(report: DiagnosticReport) -> str:
    labels = {
        "es": {
            "title": "Reporte de diagnóstico",
            "code": "Código OBD",
            "description": "Descripción",
            "causes": "Posibles causas",
            "steps": "Pasos de verificación",
            "urgency": "Urgencia",
            "professional": "Requiere taller profesional",
            "warning": "Advertencia de seguridad",
            "questions": "Preguntas de aclaración",
            "source": "Fuente",
            "yes": "Sí",
            "no": "No",
        },
        "en": {
            "title": "Diagnostic report",
            "code": "OBD code",
            "description": "Description",
            "causes": "Possible causes",
            "steps": "Verification steps",
            "urgency": "Urgency",
            "professional": "Professional shop required",
            "warning": "Safety warning",
            "questions": "Clarifying questions",
            "source": "Source",
            "yes": "Yes",
            "no": "No",
        },
    }
    lang = report.language
    text = labels[lang]
    lines = [
        f"=== {text['title']} ===",
        "",
        f"{text['code']}: {report.matched_code or '—'}",
    ]
    if report.code_description:
        lines.append(f"{text['description']}: {report.code_description}")
    lines.extend(
        [
            f"{text['urgency']}: {report.urgency.upper()}",
            f"{text['professional']}: {text['yes'] if report.professional_required else text['no']}",
            "",
            f"{text['causes']}:",
        ]
    )
    if report.possible_causes:
        lines.extend(f"  • {cause}" for cause in report.possible_causes)
    else:
        lines.append("  —")
    lines.extend(["", f"{text['steps']}:"])
    if report.verification_steps:
        lines.extend(f"  • {step}" for step in report.verification_steps)
    else:
        lines.append("  —")
    if report.safety_warning:
        lines.extend(["", f"{text['warning']}:", f"  {report.safety_warning}"])
    if report.clarifying_questions:
        lines.extend(["", f"{text['questions']}:"])
        lines.extend(f"  • {question}" for question in report.clarifying_questions)
    lines.extend(
        [
            "",
            f"{text['source']}: {report.source}",
            "",
            report.disclaimer,
        ]
    )
    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="AutoShop AI Assistant — bilingual automotive diagnostic demo"
    )
    parser.add_argument(
        "input",
        nargs="?",
        help='OBD code or symptom, e.g. "P0300" or "engine overheating"',
    )
    parser.add_argument(
        "--lang",
        choices=["es", "en"],
        default="es",
        help="Response language (default: es)",
    )
    parser.add_argument(
        "--mode",
        choices=["auto", "offline", "llm"],
        default="auto",
        help="auto = LLM if API key exists, else offline database",
    )
    parser.add_argument("--json", action="store_true", help="Print JSON output")
    parser.add_argument(
        "--list-codes",
        action="store_true",
        help="List OBD codes available in the offline database",
    )
    parser.add_argument(
        "--demo",
        action="store_true",
        help="Run built-in demo cases",
    )
    return parser


def run_demo(language: Language, mode: str) -> None:
    cases = [
        "P0300",
        "P0217",
        "Los frenos se sienten esponjosos y la luz ABS está encendida",
    ]
    for case in cases:
        report = diagnose(case, language=language, mode=mode)  # type: ignore[arg-type]
        print(format_report(report))
        print("\n" + "-" * 48 + "\n")


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.list_codes:
        print("\n".join(list_available_codes()))
        return 0

    if args.demo:
        run_demo(args.lang, args.mode)
        return 0

    if not args.input:
        parser.error("input is required unless --demo or --list-codes is used")

    report = diagnose(args.input, language=args.lang, mode=args.mode)  # type: ignore[arg-type]
    if args.json:
        print(json.dumps(report.to_dict(), indent=2, ensure_ascii=False))
    else:
        print(format_report(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
