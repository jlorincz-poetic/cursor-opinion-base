---
name: coding-opinions
description: Applies the user's personal coding opinion base when implementing or reviewing code. Loads matching topic opinions (React effects, GraphQL, structure, pitfalls) as revisable defaults, not law. Use when writing, reviewing, or structuring code, especially React, effects, GraphQL, or API shape.
---

# Coding opinions

Personal taste store at `~/.cursor/opinions`. Brief general programming principles. Provisional defaults, not project rules.

Read only that store. Do not edit other skills or run their workflows. Other skills (review, GraphQL, PR bots, etc.) stay independent.

## Treat statuses this way

- `working` — follow as the default, unless `scope: domain`
- `candidate` — ignore unless the user just reinforced it
- `tension` — mention both sides; pick the less unergonomic fit
- `retired` — do not apply
- `scope: domain` — tagged out. Do not apply as a default. Open it only if this task is clearly that class of system.

If a working opinion fights this codebase, say so and propose a revision. Do not cargo-cult.

## Load only what matches

1. Read `~/.cursor/opinions/index.md` as a router only. Do not treat unread rows as defaults or as a checklist.
2. Open `~/.cursor/opinions/topics/<slug>.md` for at most 1–2 topics that match this task
3. Apply only those opened files, and only if they are `working` with general scope (or a candidate / domain topic the user just reinforced)
4. Do not dump the rest into context
