---
owner: repository
title: chore(skills): vendor the gap-fillers
status: resolved
blocked-by: []
---

## Problem

`workflow.md` has no answer for work too big for one context window, for incoming issues, for hard bugs, or for crossing sessions. matt's set does. These are kept rather than reinvented.

## Outcome

Vendored into `./skills/`, paths rewritten to the Tenure layout:

| Skill | Why it survives |
| --- | --- |
| `triage` | On-ramp for issues Claude didn't create |
| `diagnosing-bugs` | Refuses to theorise before a tight feedback loop goes red |
| `handoff` | Bridge between context windows |
| `resolving-merge-conflicts` | Standalone, unchanged |
| `improve-codebase-architecture` | Surveys for deepening opportunities; feeds `/design` |

**Not vendored as skills:** `to-tickets` and `wayfinder`. Their content is **harvested into `/design`** (ticket 03) as its disclosed `TICKETS.md` and `MAP.md` branches, per ADR 0011. Read both before writing those files — the tracer-bullet slicing and the decision-ticket map are the parts worth keeping.

Rewrites needed: `.scratch/` → `.claude/tickets/`, `CONTEXT.md` → `.claude/context.md`, `docs/adr/` → `.claude/docs/decisions/`.

**Tracker configuration has one home: `.claude/tracker.md`**, written by `/configure` and read by every skill that touches the tracker — `/design`, `/implement`, `/triage`. It records which tracker this repo uses and the operations against it:

| Tracker | Tickets live in | Driven by |
| --- | --- | --- |
| **GitHub** | repo issues | `gh` — see `tools/gh.md` |
| **Local markdown** | `.claude/tickets/<effort>/` | files |

Both are first-class and must work. GitLab support carries over from matt's templates where it is cheap to keep. Triage label vocabulary folds into the same file rather than getting one of its own.

`diagnosing-bugs` and `tdd` already read `CONTEXT.md` for a mental model — that becomes Tenure's demand-driven load: `.claude/context.md`, then matching `contexts/*.md` via the routing table.

## Acceptance

- No vendored skill references a mattpocock path.
- The issue-tracker configuration has exactly one home, and every skill reading it agrees.

## Comments

**`tools/gh.md` does not exist; the reference is `tools/github.md`.** This
ticket's table names the former, ticket 15 shipped the latter. `verify.ps1`
asserts against this ticket's own wording, and fails if the template points at
the file that was never built.

**The out-of-scope knowledge base moved to `.claude/docs/out-of-scope/`, which
is not in the spec's target layout.** matt keeps it at the repository root;
ADR 0003 and ADR 0006 put everything the workflow owns under `.claude/`, so
staying at the root was not an option and this ticket does not say where it
goes. It sits with the other evidence — research findings, prototype write-ups
— because it is the same kind of artifact: a record of what was concluded and
why, which nothing revalidates afterwards. It is deliberately **not** in
`decisions/`: an ADR answers *why this approach*, and this answers *why not this
request at all*, which would never clear the 3-of-3 test. **The spec's layout
block does not list it** and was left alone rather than edited to match what was
built — that call is the user's.

**`/implement` was the third reader and had nothing.** This ticket says the
config is *"read by every skill that touches the tracker — `/design`,
`/implement`, `/triage`"*. Only `/triage` read it; `/implement` hardcoded
`Status:` lines with no branch on tracker choice, so a GitHub-tracker repository
would have had `/triage` reading the config while `/implement` wrote markdown
files beside it. `/implement` §1 now reads the config and names `Status:` as the
local-markdown form. **`/design`'s half stays ticket 14's** — its Comments
already assign `TICKETS.md` and `MAP.md`, and both need ticket 09's file to
exist first, which it now does.

Worse, the assertion for this criterion listed only `triage/SKILL.md` as a
reader, so it passed *because* of the gap it was supposed to catch. Found by
review, and the list now includes `/implement`.

**The triage roles appear in two files, and that is not a second home.**
`triage/SKILL.md` defines what each role *means*; `tracker.template.md` maps the
canonical name to whatever label string a given repository actually uses. The
mapping cannot live in the skill — it is per-repository — and the meaning cannot
live in the template, which is a form to be filled in. Different content, and
neither is derivable from the other.

**`tools/git.md` gained a bisect entry.** Ticket 15 owns `tools/`, and this is
an addition to a resolved ticket's artifact. It is forced by decision 34:
`diagnosing-bugs` builds a bisection harness, and its own guard — *no skill
issues a command for a tool with no entry* — went red on `git bisect` the moment
the skill was vendored. The entry carries the `reset` too, which is the half
that matters: without it the session continues against a detached HEAD and the
next drift read is catastrophic and wrong. Asserted under ticket 15.

**Two things dropped from matt's originals were restored after review.** The
human-in-the-loop escape in `diagnosing-bugs`' completion criterion — dropped to
`Runnable unattended`, which makes any bug needing a click unloopable and sends
the skill into the hypothesising it exists to forbid — and, in
`improve-codebase-architecture`, the `Explore` subagent, the temp-directory
resolution and open commands, and the worked vocabulary example. **ADR 0011
authorised removing the grill and the `domain-modeling` side effects; it did not
authorise those.** matt's `scripts/hitl-loop.template.sh` is still not vendored
— nothing in his skill directory ships it — so the pattern is described rather
than pointed at, which is better than a reference to a file that is not there.
