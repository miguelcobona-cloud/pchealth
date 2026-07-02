from __future__ import annotations

import json
import re
from typing import Any

from src.config import (
    SYSTEM_PROMPT_FILE,
    get_anthropic_api_key,
    get_anthropic_model,
    get_openai_api_key,
    get_openai_model,
)
from src.models import Language, Source


def load_system_prompt() -> str:
    return SYSTEM_PROMPT_FILE.read_text(encoding="utf-8")


def _extract_json(text: str) -> dict[str, Any]:
    cleaned = text.strip()
    fence_match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", cleaned, re.DOTALL)
    if fence_match:
        cleaned = fence_match.group(1)
    else:
        brace_match = re.search(r"\{.*\}", cleaned, re.DOTALL)
        if brace_match:
            cleaned = brace_match.group(0)
    return json.loads(cleaned)


def call_openai(user_input: str, language: Language) -> tuple[dict[str, Any], Source]:
    from openai import OpenAI

    api_key = get_openai_api_key()
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not set")

    client = OpenAI(api_key=api_key)
    system_prompt = load_system_prompt()
    response = client.chat.completions.create(
        model=get_openai_model(),
        temperature=0.2,
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": system_prompt},
            {
                "role": "user",
                "content": (
                    f"Language: {language}\n"
                    f"User input: {user_input}\n"
                    "Provide diagnostic guidance in the requested language."
                ),
            },
        ],
    )
    content = response.choices[0].message.content or "{}"
    return _extract_json(content), "openai"


def call_anthropic(user_input: str, language: Language) -> tuple[dict[str, Any], Source]:
    from anthropic import Anthropic

    api_key = get_anthropic_api_key()
    if not api_key:
        raise RuntimeError("ANTHROPIC_API_KEY is not set")

    client = Anthropic(api_key=api_key)
    system_prompt = load_system_prompt()
    response = client.messages.create(
        model=get_anthropic_model(),
        max_tokens=1024,
        temperature=0.2,
        system=system_prompt,
        messages=[
            {
                "role": "user",
                "content": (
                    f"Language: {language}\n"
                    f"User input: {user_input}\n"
                    "Respond with JSON only."
                ),
            }
        ],
    )
    text_blocks = [block.text for block in response.content if block.type == "text"]
    content = "\n".join(text_blocks)
    return _extract_json(content), "anthropic"


def call_llm(user_input: str, language: Language) -> tuple[dict[str, Any], Source]:
    if get_openai_api_key():
        return call_openai(user_input, language)
    if get_anthropic_api_key():
        return call_anthropic(user_input, language)
    raise RuntimeError("No LLM API key configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY.")
