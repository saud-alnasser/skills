---
owner: framework
version: 1.19.0
---

# Map

<!-- Installed by /configure at `.claude/policies/maps.md`. -->

Reached only when the fog gate fired: the effort cannot be scoped yet, so a spec written now would be built on guesses. A map finds the way — a shared artifact of **decisions**, worked one at a time until nothing is left to decide, and only then does a spec exist to write.

## Where decision work lives

- **Read `What a ticket is` in `.claude/policies/tracker.md` before creating anything below** — whether a decision may be a *ticket* is the tracker's to say.
- **Branch-bound** — a ticket becomes a branch and a decision produces none, so decision work stays off the tracker: each decision is a section of the design document, same content as the ticket form below, resolved in place; each session's resolutions land as that session's design PR (`.claude/policies/version-control.md` names the exception this rides on). Only the map itself goes on the tracker, because only the map survives into build tickets. Everything below that says *ticket* reads as *section*: claiming and `Status:` lines fall away, and the map links to sections rather than files or issues.
- **Tracked intent** — decision tickets are tickets, and this file applies as written.
- **A tracker policy with no such declaration predates it: a configuration gap** — say so and have `/configure` backfill it; never guess the placement the gap was created to settle.

## Plan, don't do

- **Every ticket on a map resolves a decision, never a slice of a build** — a map that starts executing stops charting, and the unexplored part never gets explored. The pull to just start building usually signals the map is finished; resist it earlier than that.
- **Name the destination first** — one or two lines saying what reaching the end looks like; it fixes the scope and shapes every ticket, and every session orients to it before choosing one.

## The map file

- **The map lives inside the effort it charts**, wherever `.claude/policies/tracker.md` says efforts are: `.claude/tickets/<effort>/map.md` on a local-markdown tracker, beside that effort's own spec and issues; a pinned issue on GitHub. One map per effort, so a shared path would make two mapped efforts contend for one file; what spans every effort lives at the tickets root instead.
- **An index, not a store** — a decision lives in exactly one place, its ticket; the map gists and links.
- **Until the map exists, the design document holds the proposal and is the map**; once created, the created map supersedes it and the proposal is not mirrored back — that would be the second copy.

```markdown
# map: <effort name>

## Destination

<what reaching the end of this map looks like. One or two lines.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

- [<ticket title>](<NN>-<slug>.md) — <one-line gist of the answer>

## Not yet specified

<in-scope fog you cannot ticket yet; graduates as the frontier advances>

## Out of scope

<work ruled beyond the destination; closed, never graduates>

## Drift found

- [ ] [<what it falsifies>](<evidence file>) — <one-line gist>
```

- **Open tickets are not listed** — they carry `Part of: map` and are found by querying the tracker; a list of them on the map is a second copy that goes stale.

## Decision tickets

Same file and format as any ticket (`.claude/policies/tickets.md`), with three differences: the body is a question, the ticket carries a type, and the title's commit records the answer — an ADR or a design-document change, usually `docs:` — so the title rule holds unchanged.

```markdown
# <NN> — type(scope): summary — e.g. docs(checkout): settle the retry flow

Status: open
Part of: map
Type: grilling
Blocked by: 03

## Question

<the decision or investigation this ticket resolves>
```

- **On a branch-bound tracker a decision ticket is a section of the design document**, so its facts are lines rather than frontmatter — a section has nowhere to put fields; that is the one place the two forms differ, because the artefact does.
- **Each ticket is sized to one fresh context window; the answer is written on resolution, never in the body.**
- **Where the tracker assigns ids, its id is the only number** — no `<NN>` prefix and edges use the tracker's ids; two numbering systems force a lookup on every edge.
- **A decision ticket's `Blocked by:` is answer-gating, never a stacking instruction** — a decision produces no branch, so there is nothing to stack.

### Types

- **Every ticket is HITL — worked with a human who speaks for themselves — or AFK, driven alone.** A HITL ticket resolves only through that live exchange: an agent that answers its own grilling questions has not resolved the ticket, it has skipped it.

| Type | Mode | Use when |
| --- | --- | --- |
| `grilling` | HITL | the default. A decision to be talked out, one question at a time |
| `research` | AFK | a fact outside this repository gates the decision. `/research` resolves it |
| `prototype` | HITL | "how should it look" or "how should it behave" is the question. `/prototype` makes something cheap to react to |
| `task` | either | manual work that must happen before a decision can be made. The one type that *does* rather than decides, earning its place by unblocking a decision |

## Fog of war

- **The map is deliberately incomplete: don't chart what you cannot see yet.** Resolving a ticket clears the fog ahead of it, graduating whatever became specifiable into fresh tickets.
- **Fog or ticket — the test is whether the question can be stated precisely now**, not whether it can be answered: a sharp question is a ticket even while blocked; anything dimmer goes under **Not yet specified**, and fog is never pre-sliced into ticket-sized pieces — one patch may graduate into several tickets, or none.
- **Fog gathers only toward the destination** — work beyond it goes under **Out of scope** with one line saying why, stays out of **Decisions so far** (that section records the route actually walked), and never graduates; it returns only if the destination is redrawn, as a fresh effort. A live ticket found past the destination is marked `obsolete` with the line.

## Drift found

- **A drift finding in the effort's area gets one task-list line under `Drift found`** — the gist and the link to the evidence file (`.claude/policies/evidence.md`), checked off when the healing lands; never the finding's content.
- **On GitHub the line goes in the map's issue body, never a comment** — the body comes back with the call every session already makes; a comment is a separate paginated fetch each session would have to remember, which is how a finding stays unread.

## Working the map

One ticket per session — research tickets excepted, which run in parallel without consuming it:

1. Load the map — the low-resolution view, not every ticket body.
2. Choose a ticket: the one the user named, or the first on the frontier as `/implement` defines it. **Claim it first**, before any work.
3. Resolve it, zooming into related ticket bodies on demand; invoke the skills `## Notes` names — `grilling` and `domain-modeling` by default.
4. Record it: the answer under `## Answer`, the resolution in whatever form `.claude/policies/tracker.md` says — a `Status:` line on a local tracker, closing the issue on GitHub — and one line appended to **Decisions so far**.
5. Update the map: add surfaced tickets, graduate fog the answer sharpened — clearing each graduated patch from **Not yet specified**, so it lives only as its ticket — and mark obsolete what the decision invalidated.

- **Expect other sessions on the map concurrently** — unblocked tickets can be worked in parallel.

## Leaving the map

- **The map is done when every remaining decision is settled or declared as a scoped increment on the build ticket that can answer it** (`.claude/policies/tickets.md` has the declaration) — a map exiting with declared increments names, in the hand-back, which tickets carry them.
- **Hand back to step 5 of `/design`** — the tier's normal deliverable, a spec then tickets, now has something solid to stand on.
