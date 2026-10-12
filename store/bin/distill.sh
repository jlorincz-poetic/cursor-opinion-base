#!/usr/bin/env python3
"""Run distill-opinions if the inbox has new messages. Used by launchd."""
from __future__ import annotations

import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HOME = Path.home()
OPINIONS = HOME / ".cursor" / "opinions"
INBOX = OPINIONS / "inbox"
MESSAGES = INBOX / "messages.jsonl"
CURSOR = INBOX / "cursor.json"
LOCK = INBOX / "distill.lock"
CURATE_LOCK = INBOX / "curate.lock"
LOG = INBOX / "distill.log"
SKILL = HOME / ".cursor" / "skills" / "distill-opinions" / "SKILL.md"
AGENT = Path.home() / ".local" / "bin" / "cursor-agent"
WORKSPACE = HOME / ".cursor"

PROMPT = (
    "Follow ~/.cursor/skills/distill-opinions/SKILL.md exactly. "
    "Distill brief general programming principles, not project-specific facts. "
    "New claims stay candidate. Do not promote to working. "
    "Write only under ~/.cursor/opinions/. "
    "Do not create or edit skills. Do not touch ~/.cursor/skills/."
)


def log(message: str) -> None:
    INBOX.mkdir(parents=True, exist_ok=True)
    line = f"{datetime.now(timezone.utc).isoformat()} {message}\n"
    with LOG.open("a", encoding="utf-8") as handle:
        handle.write(line)


def last_distilled_ts() -> str | None:
    if not CURSOR.exists():
        return None
    try:
        data = json.loads(CURSOR.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None
    return data.get("last_distilled_ts")


def has_new_messages() -> bool:
    if not MESSAGES.exists():
        return False
    cutoff = last_distilled_ts()
    with MESSAGES.open(encoding="utf-8") as handle:
        for raw in handle:
            raw = raw.strip()
            if not raw:
                continue
            try:
                row = json.loads(raw)
            except json.JSONDecodeError:
                continue
            ts = row.get("ts")
            if not ts:
                continue
            if cutoff is None or ts > cutoff:
                return True
    return False


def agent_logged_in() -> bool:
    if not AGENT.exists():
        return False
    try:
        result = subprocess.run(
            [str(AGENT), "status"],
            capture_output=True,
            text=True,
            timeout=30,
        )
    except (OSError, subprocess.TimeoutExpired):
        return False
    text = (result.stdout or "") + (result.stderr or "")
    return "Not logged in" not in text and result.returncode == 0


def main() -> int:
    if LOCK.exists():
        log("skip: another distill is running")
        return 0
    if CURATE_LOCK.exists():
        log("skip: curate is running")
        return 0
    if not has_new_messages():
        log("skip: no new inbox messages")
        return 0
    if not agent_logged_in():
        log("skip: cursor-agent is not logged in (run: cursor agent login)")
        return 0
    if not SKILL.exists():
        log("skip: distill-opinions skill missing")
        return 0

    LOCK.write_text(str(os.getpid()), encoding="utf-8")
    try:
        log("start: cursor-agent distill")
        result = subprocess.run(
            [
                str(AGENT),
                "-p",
                "--trust",
                "--force",
                "--workspace",
                str(WORKSPACE),
                PROMPT,
            ],
            cwd=str(WORKSPACE),
            capture_output=True,
            text=True,
            timeout=1800,
        )
        if result.stdout:
            log(result.stdout[-4000:])
        if result.stderr:
            log(result.stderr[-2000:])
        log(f"done: exit {result.returncode}")
        return result.returncode
    except subprocess.TimeoutExpired:
        log("error: distill timed out after 30m")
        return 1
    finally:
        if LOCK.exists():
            LOCK.unlink()


if __name__ == "__main__":
    sys.exit(main())
