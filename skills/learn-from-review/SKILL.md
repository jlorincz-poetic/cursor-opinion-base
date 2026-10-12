---
name: learn-from-review
description: Immediately distills general programming principles from the user's review feedback in the current thread and writes them to the personal opinion base. Use when the user says learn from this review, learn from this thread, remember this feedback, or asks to learn after giving a code review.
disable-model-invocation: true
---

# Learn from this review

This thread only, right now. Not the inbox. Not other skills.

Store: `~/.cursor/opinions/`. Write only `topics/`, `index.md`, `changelog.md`. Do not touch `inbox/cursor.json` (batch distill owns that). Do not create or edit skills.

## Extraction

Same bar as `~/.cursor/skills/distill-opinions/SKILL.md` (read that file): brief general programming principles, not project facts. The review comment is evidence. Ask what reusable rule would prevent this class of mistake in any codebase. Drop product names, paths, symbols, PR numbers.

If you cannot state the lesson without this repo's types, skip it.

## Workflow

1. Use this conversation. Prefer messages already in context. If you need more, open this chat's transcript (`agent-transcripts/<conversation_id>`).
2. Take only the user's review feedback in this thread (what they rejected, asked to inline, called overcomplicated, or said "never do"). Ignore task-only lines ("rebase", "fix tests", "ship it").
3. Read `~/.cursor/opinions/index.md` and matching topics. Match by principle, not symbol: reinforce, contradict, or new.
4. Write topic files in the distill-opinions shape. New → `candidate` (set `scope: general`, or `domain` if it is one product architecture). Same principle → increment `reinforced`, add evidence, do not promote. User says promote → `working` only if scope is general. Contradiction of a working topic → `tension`. Daily `curate-opinions` owns other promotions.
5. Update `index.md` and `changelog.md`. Reply with a short digest (new / reinforced / skipped). Do not dump every topic.

Do not run `distill-opinions` on the full inbox unless the user asked for that too.
