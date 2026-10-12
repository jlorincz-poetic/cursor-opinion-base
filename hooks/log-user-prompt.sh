#!/usr/bin/env python3
"""Log each user send as a pointer into the conversation transcript.

Fail-open: always allow the prompt through. Never call the network.
"""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

INBOX = Path.home() / ".cursor" / "opinions" / "inbox" / "messages.jsonl"


def is_trivial(prompt: str) -> bool:
    text = prompt.strip()
    if not text:
        return True
    return " " not in text and "\n" not in text


def main() -> None:
    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw.strip() else {}
        prompt = data.get("prompt") or ""
        if not is_trivial(prompt):
            record = {
                "ts": datetime.now(timezone.utc).isoformat(),
                "prompt": prompt,
                "attachments": data.get("attachments") or [],
                "conversation_id": data.get("conversation_id"),
                "generation_id": data.get("generation_id"),
                "transcript_path": data.get("transcript_path"),
                "workspace_roots": data.get("workspace_roots") or [],
            }
            INBOX.parent.mkdir(parents=True, exist_ok=True)
            with INBOX.open("a", encoding="utf-8") as handle:
                handle.write(json.dumps(record, ensure_ascii=False) + "\n")
    except Exception:
        pass
    sys.stdout.write(json.dumps({"continue": True}) + "\n")


if __name__ == "__main__":
    main()
