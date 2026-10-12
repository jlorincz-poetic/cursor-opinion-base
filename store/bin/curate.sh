#!/usr/bin/env python3
"""Run curate-opinions once a day. Used by launchd."""
from __future__ import annotations

import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HOME = Path.home()
OPINIONS = HOME / ".cursor" / "opinions"
INBOX = OPINIONS / "inbox"
LOCK = INBOX / "curate.lock"
DISTILL_LOCK = INBOX / "distill.lock"
LOG = INBOX / "curate.log"
SKILL = HOME / ".cursor" / "skills" / "curate-opinions" / "SKILL.md"
AGENT = Path.home() / ".local" / "bin" / "cursor-agent"
WORKSPACE = HOME / ".cursor"

PROMPT = (
    "Follow ~/.cursor/skills/curate-opinions/SKILL.md exactly. "
    "Evaluate the whole opinion store: compress, merge duplicates, "
    "tag domain topics out of defaults, promote only on distinct parent chats. "
    "Write only under ~/.cursor/opinions/. "
    "Do not create or edit skills. Do not touch ~/.cursor/skills/."
)


def log(message: str) -> None:
    INBOX.mkdir(parents=True, exist_ok=True)
    line = f"{datetime.now(timezone.utc).isoformat()} {message}\n"
    with LOG.open("a", encoding="utf-8") as handle:
        handle.write(line)


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
        log("skip: another curate is running")
        return 0
    if DISTILL_LOCK.exists():
        log("skip: distill is running")
        return 0
    if not agent_logged_in():
        log("skip: cursor-agent is not logged in (run: cursor agent login)")
        return 0
    if not SKILL.exists():
        log("skip: curate-opinions skill missing")
        return 0

    LOCK.write_text(str(os.getpid()), encoding="utf-8")
    try:
        log("start: cursor-agent curate")
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
        log("error: curate timed out after 30m")
        return 1
    finally:
        if LOCK.exists():
            LOCK.unlink()


if __name__ == "__main__":
    sys.exit(main())
