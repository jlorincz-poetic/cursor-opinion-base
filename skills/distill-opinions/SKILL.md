---
name: distill-opinions
description: Distills durable coding opinions from logged user prompts by reopening conversation transcripts. Use when the user asks to distill opinions, update the opinion base, or process the inbox.
disable-model-invocation: true
---

# Distill opinions

Runs when asked to distill opinions, or from the local 4-hour launchd job (`com.cursor.distill-opinions`). Never from a normal coding turn. To learn from the current review thread only, use `learn-from-review` instead.

Store: `~/.cursor/opinions/`

Write only under `~/.cursor/opinions/` (`topics/`, `index.md`, `changelog.md`, `inbox/cursor.json`). Do not create or edit skills, and do not touch `~/.cursor/skills/` or any other skill. This is not a skill builder.

## What to extract

Write **brief general programming principles**, not project facts.

The inbox incident is evidence, not the lesson. After you reopen the transcript, ask: *what reusable rule would prevent this class of mistake in any codebase?* Write that rule. Drop product names, file paths, symbol names, PR numbers, and repo-specific types.

Good: "Don't tack type intersections onto a shared TypeScript options type. Put the field on the type that owns it, or inline it at the callers, unless the intersection is a real concept and a substantial simplification."

Bad: "Don't write `RequestOptions & { host?: string }`; add `host` on this service's source type."

Language or paradigm is fine (TypeScript, React, Go). A specific service, package, or feature is not.

Also skip: one-off task steering, product requirements, "fix this PR", questions with no taste.

Each claim is 1–2 sentences plus a tiny do/don't. Include the exception in the claim or Openness (unergonomic / substantial simplification → don't force it).

If you cannot state the lesson without naming this repo's types, skip the row.

## Workflow

1. Read `inbox/cursor.json` (`last_distilled_ts`). Process `inbox/messages.jsonl` rows with `ts` after that value (all rows if null).
2. For each row, reopen context **before** extracting anything:
   - Read `transcript_path` if it exists
   - Else search that workspace's `agent-transcripts` for `conversation_id`
   - Join the logged `prompt` (this turn) with the transcript (prior turns, especially the agent message being answered and files in play)
   - If neither path works, mark the row unresolvable in the digest and skip it. Do not invent an opinion from prompt text alone.
3. Ignore task-only messages. Lift durable taste into a general principle (structure, pitfalls, type shape, “never do X”).
4. Match to `topics/*.md` + `index.md` by principle, not by symbol name: reinforce, contradict, or new.
5. Write updates, then a short digest, then set `last_distilled_ts` to the latest processed `ts`.

## Promotion

Distill never promotes. Daily `curate-opinions` owns working / domain / merge / retire.

- New claim → new `topics/<slug>.md` with `status: candidate`, `scope: general` (or `domain` if the rule only holds for one product architecture), `reinforced: 1`
- Same *principle* again → increment `reinforced`, add one evidence row, leave status as-is
- On each evidence row, set `parent` to the `agent-transcripts/<id>/` folder (not a subagent id)
- Working claim contradicted → `tension` (do not silently overwrite)
- User says promote in this turn → allowed only if `scope` is `general`
- One message is never gospel

## Topic file shape

Title and claim stay general. Evidence may cite the concrete chat.

```markdown
---
slug: short-kebab
status: candidate
scope: general
reinforced: 1
contradicted: 0
---

# Title (principle, not a symbol)

One- or two-sentence general rule, including when not to apply it.

## Do

## Don't

Tiny generic snippet is fine. No project types.

## Openness

If following this is unergonomic here, or the "bad" form is a real simplification, say so and propose a revision.

## Evidence

- conversation_id: …
  parent: …   # agent-transcripts/<id>/ folder; same as conversation_id unless this was a subagent
  generation_id: …
  transcript_path: …
  quote: "…"
```

Keep `index.md` to one general line per topic. Append promotions, revisions, and retirements to `changelog.md`.
