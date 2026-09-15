"""Helpers for rendering provider-neutral LangChain message content."""

from __future__ import annotations

from typing import Any


def text_content(content: Any) -> str:
    """Extract displayable text from LangChain message content.

    Some providers, including Gemini, return a list of content blocks rather
    than a string.  Those blocks can include provider-only fields such as
    thought signatures, which must not be rendered in the chat UI.
    """
    if isinstance(content, str):
        return content

    if isinstance(content, dict):
        value = content.get("text")
        return value if isinstance(value, str) else ""

    if isinstance(content, list):
        return "\n".join(
            text for block in content if (text := text_content(block))
        )

    return ""
