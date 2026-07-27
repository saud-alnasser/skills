# Tenure — build status

Where the build has got to. Moved here from the root `CLAUDE.md` during the migration in ticket 12: it is ticket state, so it belongs with the tickets rather than in the always-on file every turn pays for.

## Phase 1 — done

Shipped under `./skills/`:

- the four vendored primitives — `grilling`, `tdd`, `codebase-design`, `domain-modeling` (01)
- `tools/` — the tool reference: `git.md`, `github.md`, `gitlab.md`, `graphite.md` (15)
- `configure/CLAUDE.template.md` — the always-on verification and healing rules (02)
- `design/` — `/design`, with `SPEC-FORMAT.md`, `TICKETS.md`, `MAP.md` behind pointers (03)
- `implement/` — `/implement`, the build stage (04)
- `review/` — `/review`, two axes plus the smell baseline behind a pointer (05)
- `commit/` — `/commit`, the transaction boundary and the Marker's only writer (06)
- `research/` and `prototype/` — the two evidence commands, with `LOGIC.md` and `UI.md` behind pointers (07)
- the on-ramps — `triage/`, `diagnosing-bugs/`, `handoff/`, `resolving-merge-conflicts/`, `survey/` — plus `configure/tracker.template.md` (09)
- the nineteen engineering rules, each placed where it fires (13)
- `configure/` — `/configure`, with `MIGRATION.md` behind a pointer (08)
- `help/` — `/help`, the router over the whole set, replacing `ask-matt` (10)

## Tickets 16–20 — resolved

The multi-instance and distribution work decided by ADRs 0012–0016:

- **16** — Position named as a category. `CLAUDE.template.md` split: the always-on file keeps only rules that hold with or without the plugin, and Tenure's protocol moved to `configure/tenure.template.md`.
- **17** — the Claim is the ticket's branch, created before any work. `claimed` left the ticket lifecycle entirely.
- **18** — creating an issue is publishing and is gated; one root issue per `/design` run; the frontier is build tickets only.
- **19** — on a stacking repository `Blocked by` means *stacked on*, and a ticket is buildable once its blockers are committed.
- **20** — Tenure ships as a plugin from `.claude-plugin/`, installed at `local` scope. Three skills renamed to suit the namespace — `help`, `review`, `survey`.

## Ticket 11 — install

Done, outside the ticket's own process. Tenure is installed at `local` scope from the `tenure-marketplace` published by this repository, sourced from GitHub (`saud-alnasser/skills`) rather than a local path. `~/.claude/skills/` is empty — the mattpocock skills this framework replaces are gone.

**One consequence to be aware of:** `writing-great-skills` went with them. It was the authoring standard these skills were written against, and it is no longer readable from this machine. `.claude/contexts/skill-authoring.md` records what survived and what did not.

## Ticket 12 — migrate this repository

Done. This file is part of it. See ticket 12's `## Comments` for the deviations.

## Not done

**Phase 2 — the dogfood checkpoint.** Ticket 07 was built directly rather than designed first, and phase 2 remains a human-in-the-loop step: run `/design` on a real piece of work in this repository and watch what breaks.

**The chain has never run end to end as skills.** `/configure` has run once — this migration — and `/commit` has run once, on that migration's own diff. `/implement` and `/review` have still only ever been executed by hand, and no single piece of work has passed through all four as skills.
