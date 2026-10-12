#!/usr/bin/env python3
"""Install the opinion-base harness into ~/.cursor. Never overwrite a live store."""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
ROOT = Path(__file__).resolve().parent
CURSOR = HOME / ".cursor"
SKILLS_DST = CURSOR / "skills"
HOOKS_DST = CURSOR / "hooks"
HOOKS_JSON = CURSOR / "hooks.json"
OPINIONS = CURSOR / "opinions"
LAUNCH_DST = HOME / "Library" / "LaunchAgents"
HOOK_COMMAND = "./hooks/log-user-prompt.sh"
SKILL_NAMES = (
    "coding-opinions",
    "distill-opinions",
    "learn-from-review",
    "curate-opinions",
)


def copy_file(src: Path, dst: Path, mode: int | None = None) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    if mode is not None:
        dst.chmod(mode)


def install_skills() -> None:
    for name in SKILL_NAMES:
        src = ROOT / "skills" / name / "SKILL.md"
        dst = SKILLS_DST / name / "SKILL.md"
        copy_file(src, dst)
        print(f"skill  {dst}")


def install_hook() -> None:
    src = ROOT / "hooks" / "log-user-prompt.sh"
    dst = HOOKS_DST / "log-user-prompt.sh"
    copy_file(src, dst, mode=0o755)
    print(f"hook   {dst}")
    merge_hooks_json()


def merge_hooks_json() -> None:
    data: dict = {"version": 1, "hooks": {}}
    if HOOKS_JSON.exists():
        try:
            data = json.loads(HOOKS_JSON.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            print(f"warn   could not parse {HOOKS_JSON}; leaving it alone", file=sys.stderr)
            return
    hooks = data.setdefault("hooks", {})
    entries = list(hooks.get("beforeSubmitPrompt") or [])
    if any(item.get("command") == HOOK_COMMAND for item in entries if isinstance(item, dict)):
        print(f"hooks  {HOOKS_JSON} already lists {HOOK_COMMAND}")
        return
    entries.insert(0, {"command": HOOK_COMMAND})
    hooks["beforeSubmitPrompt"] = entries
    data["version"] = data.get("version") or 1
    HOOKS_JSON.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"hooks  added {HOOK_COMMAND} to {HOOKS_JSON}")


def seed_store() -> None:
    OPINIONS.mkdir(parents=True, exist_ok=True)
    (OPINIONS / "topics").mkdir(parents=True, exist_ok=True)
    (OPINIONS / "inbox").mkdir(parents=True, exist_ok=True)
    (OPINIONS / "bin").mkdir(parents=True, exist_ok=True)

    for name in ("distill.sh", "curate.sh", "topic_stats.py"):
        copy_file(ROOT / "store" / "bin" / name, OPINIONS / "bin" / name, mode=0o755)
        print(f"bin    {OPINIONS / 'bin' / name}")

    seeded = False
    for rel in ("index.md", "changelog.md", "inbox/cursor.json"):
        dst = OPINIONS / rel
        if dst.exists():
            print(f"keep   {dst}")
            continue
        copy_file(ROOT / "store" / rel, dst)
        print(f"seed   {dst}")
        seeded = True
    if seeded:
        print("store  empty opinion store created (no topics)")
    else:
        print("store  existing topics/index/inbox left untouched")


def install_launchd() -> None:
    if sys.platform != "darwin":
        print("skip   launchd (not macOS)")
        return
    LAUNCH_DST.mkdir(parents=True, exist_ok=True)
    home = str(HOME)
    uid = str(HOME.stat().st_uid)
    for name in ("com.cursor.distill-opinions", "com.cursor.curate-opinions"):
        tmpl = (ROOT / "launchd" / f"{name}.plist.tmpl").read_text(encoding="utf-8")
        dst = LAUNCH_DST / f"{name}.plist"
        dst.write_text(tmpl.replace("__HOME__", home), encoding="utf-8")
        print(f"plist  {dst}")
        label = f"gui/{uid}/{name}"
        subprocess.run(["launchctl", "bootout", label], check=False, capture_output=True)
        loaded = subprocess.run(
            ["launchctl", "bootstrap", f"gui/{uid}", str(dst)],
            capture_output=True,
            text=True,
        )
        if loaded.returncode != 0:
            print(f"warn   launchctl bootstrap {name}: {loaded.stderr.strip() or loaded.stdout.strip()}", file=sys.stderr)
        else:
            print(f"load   {label}")


def main() -> int:
    install_skills()
    install_hook()
    seed_store()
    install_launchd()
    print()
    print("Paste USER_RULE.md into Cursor → Customize → Rules.")
    print("Then: cursor agent login")
    return 0


if __name__ == "__main__":
    sys.exit(main())
