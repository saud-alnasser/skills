# chore(skills): vendor the gap-fillers

Status: ready-for-agent
Blocked by: —

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
