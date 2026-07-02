from __future__ import annotations

import json
import sys
from pathlib import Path

import streamlit as st

PROJECT_ROOT = Path(__file__).resolve().parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from src.assistant import diagnose
from src.codes import list_available_codes
from src.config import get_anthropic_api_key, get_openai_api_key

URGENCY_COLORS = {
    "low": "#2e7d32",
    "medium": "#f9a825",
    "high": "#ef6c00",
    "critical": "#c62828",
}

EXAMPLES = {
    "es": [
        ("P0300 — Fallo de encendido", "P0300"),
        ("P0171 — Mezcla pobre", "P0171"),
        ("P0217 — Sobrecalentamiento", "P0217"),
        ("Síntoma: frenos esponjosos", "Los frenos se sienten esponjosos y pierde líquido"),
        ("Síntoma: ralentí irregular", "El motor vibra en ralentí y huele a gasolina"),
    ],
    "en": [
        ("P0300 — Misfire", "P0300"),
        ("P0171 — System lean", "P0171"),
        ("P0217 — Overheating", "P0217"),
        ("Symptom: spongy brakes", "Brakes feel spongy and ABS light is on"),
        ("Symptom: rough idle", "Engine shakes at idle and smells like fuel"),
    ],
}


def render_report(report_dict: dict[str, object]) -> None:
    urgency = str(report_dict.get("urgency", "medium"))
    color = URGENCY_COLORS.get(urgency, "#f9a825")

    st.markdown(
        f"""
        <div style="padding: 0.75rem 1rem; border-left: 6px solid {color};
        background: #1e1e1e; border-radius: 8px; margin-bottom: 1rem;">
        <strong>Urgency:</strong> {urgency.upper()}
        </div>
        """,
        unsafe_allow_html=True,
    )

    if report_dict.get("matched_code"):
        st.subheader(f"OBD: {report_dict['matched_code']}")
        if report_dict.get("code_description"):
            st.caption(str(report_dict["code_description"]))

    col1, col2 = st.columns(2)
    with col1:
        st.metric(
            "Professional required",
            "Yes" if report_dict.get("professional_required") else "No",
        )
    with col2:
        st.metric("Source", str(report_dict.get("source", "offline")))

    if report_dict.get("safety_warning"):
        st.error(str(report_dict["safety_warning"]))

    causes = report_dict.get("possible_causes", [])
    if causes:
        st.markdown("### Possible causes")
        for cause in causes:
            st.markdown(f"- {cause}")

    steps = report_dict.get("verification_steps", [])
    if steps:
        st.markdown("### Verification steps")
        for step in steps:
            st.markdown(f"- {step}")

    questions = report_dict.get("clarifying_questions", [])
    if questions:
        st.markdown("### Clarifying questions")
        for question in questions:
            st.markdown(f"- {question}")

    st.caption(str(report_dict.get("disclaimer", "")))


def main() -> None:
    st.set_page_config(
        page_title="AutoShop AI Assistant",
        page_icon="🔧",
        layout="wide",
    )

    st.title("🔧 AutoShop AI Assistant")
    st.markdown(
        "Bilingual automotive diagnostic demo — OBD codes, symptoms, and safety guardrails."
    )

    has_llm = bool(get_openai_api_key() or get_anthropic_api_key())

    with st.sidebar:
        st.header("Settings")
        language = st.selectbox("Language / Idioma", ["es", "en"], format_func=lambda x: "Español" if x == "es" else "English")
        mode_options = ["auto", "offline", "llm"]
        mode = st.selectbox(
            "Mode",
            mode_options,
            help="auto: LLM if API key is set, otherwise offline database",
        )
        if mode == "llm" and not has_llm:
            st.warning("Set OPENAI_API_KEY or ANTHROPIC_API_KEY in .env for LLM mode.")
        elif has_llm:
            st.success("LLM API key detected")

        st.divider()
        st.markdown(f"**Offline codes:** {len(list_available_codes())}")
        st.caption("Portfolio demo by Miguel Corona — Mechatronics & AI")

    if "input_value" not in st.session_state:
        st.session_state.input_value = ""

    example_labels = EXAMPLES[language]  # type: ignore[index]
    cols = st.columns(len(example_labels))
    for col, (label, value) in zip(cols, example_labels, strict=True):
        if col.button(label, use_container_width=True):
            st.session_state.input_value = value

    user_input = st.text_area(
        "OBD code or symptom / Código OBD o síntoma",
        height=120,
        placeholder="P0300  |  Engine overheating  |  Frenos esponjosos",
        key="input_value",
    )

    if st.button("Run diagnosis / Diagnosticar", type="primary", use_container_width=True):
        if not user_input.strip():
            st.warning("Enter a code or symptom.")
            return
        with st.spinner("Analyzing..."):
            report = diagnose(user_input.strip(), language=language, mode=mode)  # type: ignore[arg-type]
            report_dict = report.to_dict()
        render_report(report_dict)
        with st.expander("Raw JSON"):
            st.code(json.dumps(report_dict, indent=2, ensure_ascii=False), language="json")

    st.divider()
    st.markdown(
        """
        **Disclaimer:** Educational demo only. Does not replace professional workshop diagnosis.
        For brake, airbag, overheating, or fuel leak symptoms — stop driving and visit a certified technician.
        """
    )


if __name__ == "__main__":
    main()
