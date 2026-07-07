from __future__ import annotations

from dataclasses import dataclass, field
from typing import Literal

Language = Literal["es", "en"]
Urgency = Literal["low", "medium", "high", "critical"]
Source = Literal["offline", "openai", "anthropic", "mock"]


@dataclass
class DiagnosticReport:
    input_summary: str
    language: Language
    possible_causes: list[str] = field(default_factory=list)
    verification_steps: list[str] = field(default_factory=list)
    urgency: Urgency = "medium"
    professional_required: bool = False
    safety_warning: str = ""
    clarifying_questions: list[str] = field(default_factory=list)
    matched_code: str | None = None
    code_description: str | None = None
    source: Source = "offline"
    disclaimer: str = ""

    def to_dict(self) -> dict[str, object]:
        return {
            "input_summary": self.input_summary,
            "language": self.language,
            "possible_causes": self.possible_causes,
            "verification_steps": self.verification_steps,
            "urgency": self.urgency,
            "professional_required": self.professional_required,
            "safety_warning": self.safety_warning,
            "clarifying_questions": self.clarifying_questions,
            "matched_code": self.matched_code,
            "code_description": self.code_description,
            "source": self.source,
            "disclaimer": self.disclaimer,
        }
