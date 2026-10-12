#!/usr/bin/env python3
"""Compact per-topic stats for curate-opinions. Do not treat this as promotion."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

TOPICS = Path.home() / ".cursor" / "opinions" / "topics"
FM_RE = re.compile(r"^---\n(.*?)\n---", re.S)
EVIDENCE_RE = re.compile(
    r"(?m)^- conversation_id:\s*(\S+).*?(?=^- conversation_id:|\Z)",
    re.S,
)
PATH_RE = re.compile(r"(?m)^\s+transcript_path:\s+(\S+)")


def parent_id(conversation_id: str, transcript_path: str) -> str:
    if transcript_path:
        parts = Path(transcript_path).parts
        if "agent-transcripts" in parts:
            i = parts.index("agent-transcripts")
            if i + 1 < len(parts):
                return parts[i + 1]
    return conversation_id


def parse_frontmatter(text: str) -> dict[str, str]:
    match = FM_RE.match(text)
    if not match:
        return {}
    data: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip()
    return data


def evidence_parents(text: str) -> list[str]:
    parents: list[str] = []
    seen: set[str] = set()
    for block in EVIDENCE_RE.finditer(text):
        cid = block.group(1).strip()
        path_match = PATH_RE.search(block.group(0))
        path = path_match.group(1) if path_match else ""
        pid = parent_id(cid, path)
        if pid not in seen:
            seen.add(pid)
            parents.append(pid)
    return parents


def main() -> int:
    rows = []
    for path in sorted(TOPICS.glob("*.md")):
        text = path.read_text(encoding="utf-8")
        meta = parse_frontmatter(text)
        parents = evidence_parents(text)
        rows.append(
            {
                "slug": meta.get("slug") or path.stem,
                "status": meta.get("status") or "unknown",
                "scope": meta.get("scope") or "general",
                "reinforced": int(meta.get("reinforced") or 0),
                "contradicted": int(meta.get("contradicted") or 0),
                "unique_parents": len(parents),
                "parents": parents,
                "lines": text.count("\n") + 1,
            }
        )
    json.dump(rows, sys.stdout, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
