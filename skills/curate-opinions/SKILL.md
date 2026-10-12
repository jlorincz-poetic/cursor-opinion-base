---
name: curate-opinions
description: Daily hygiene for the personal coding opinion store — compresses topics, merges duplicates, tags domain claims out of defaults, and promotes only on distinct parent chats. Use when the user asks to curate opinions, compress the opinion base, or when the local daily launchd job (com.cursor.curate-opinions) runs.
disable-model-invocation: true
---

# Curate opinions

Runs once a day from `com.cursor.curate-opinions`, or when asked to curate / compress the opinion base. Never from a normal coding turn. Distill and learn-from-review only add candidates; this job is the editor.

Store: `~/.cursor/opinions/`

Write only under `~/.cursor/opinions/` (`topics/`, `index.md`, `changelog.md`, `inbox/cursor.json`). Do not create or edit skills.

## First step

Run `python3 ~/.cursor/opinions/bin/topic_stats.py`. Use that table. Do not open every topic.

Open a topic only if it is long (>50 lines), `unique_parents` looks like a promotion case, scope is missing and the claim smells product-specific, or two slugs are the same principle.

## What to do

**Compress.** Claim stays 1–2 sentences. Tiny do/don't. Evidence: at most 3 quotes, one per distinct parent. Drop extra subagent quotes from the same parent chat. Openness stays one short paragraph.

**Merge.** If two slugs are the same principle, keep the clearer name, move unique evidence, delete the other file, fix `index.md`.

**Tag out (`scope: domain`).** The incident is not the lesson. If you cannot state a reusable rule that applies in any codebase — or the general form is forced and the evidence is one product architecture — set `scope: domain` and keep or demote to `candidate`. Domain is tagged out of defaults.

**Promote.** `working` only when `scope` is `general` (or missing) and there are **≥2 distinct parent chats**. Parent = the `agent-transcripts/<id>/` folder, not a subagent id. `topic_stats.py` already computes this (`unique_parents`). `reinforced` is not enough. User said promote → allowed if scope is general.

**Demote / retire.** `working` + `domain` → `candidate`. Not a principle, or superseded by a merge → `retired`. Working claim contradicted → `tension`.

**Index.** One general line per living topic. Status cell is `working`, `candidate`, `candidate · domain`, `tension`, or `retired`. Do not list retired rows.

## Topic frontmatter

```markdown
---
slug: short-kebab
status: candidate
scope: general
reinforced: 1
contradicted: 0
---
```

`scope` is `general` or `domain`. Missing means general.

## Finish

Set `inbox/cursor.json` `last_curated_ts` to now (ISO UTC). Append a short changelog line (compressed / tagged / merged / promoted / retired). Reply with that digest only.
