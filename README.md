# cursor-opinion-base

Machinery for a personal, progressively disclosed coding-opinion store in Cursor. This repo does **not** ship anyone's lessons.

Each person who installs it gets:

- a `beforeSubmitPrompt` hook that logs their own messages
- skills that extract, apply, and curate opinions
- an empty store at `~/.cursor/opinions/`
- optional macOS jobs: distill every 4 hours, curate daily at 06:00 local

Their prompts, transcripts, and topic files stay on their machine.

## Install

```sh
./install.py
```

Then paste `USER_RULE.md` into Cursor → Customize → Rules (Privacy Mode can block an agent from writing that for you). Log in once with `cursor agent login` so the scheduled jobs can run.

Re-running the installer updates skills, hook, and bin scripts. It never overwrites `~/.cursor/opinions/topics/`, `index.md`, `changelog.md`, or the inbox.

## What it does

| Piece | Role |
| --- | --- |
| `coding-opinions` | On implement/review: read the index as a router, open at most 1–2 matching topics, apply only `working` + general scope. |
| `learn-from-review` | On demand in a thread: extract candidates from that review only. Does not promote. |
| `distill-opinions` | Batch extract from the inbox. New claims stay `candidate`. |
| `curate-opinions` | Daily editor: compress, merge, tag `domain` out of defaults, promote only on ≥2 distinct parent chats. |

Opinions are provisional. Candidates are not defaults. `scope: domain` is tagged out unless the task is clearly that class of system.

## Layout in this repo

```
skills/          → ~/.cursor/skills/
hooks/           → ~/.cursor/hooks/  (plus a merge into hooks.json)
store/           → ~/.cursor/opinions/  (seed only; empty topics/)
launchd/         → ~/Library/LaunchAgents/  (HOME filled in at install)
USER_RULE.md     → paste into Customize → Rules
```

The live store (`topics/`, inbox JSONL) is not in git and must not be committed.