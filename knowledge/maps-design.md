---
owner: framework
type: norm
subject: maps
fires-when: stage
stages: [design]
spans:
  - read-what-a-ticket-is-before-creating-anything: v1hdpx
  - branch-bound: cel550
  - tracked-intent: 6uvxjt
  - an-undeclared-placement-is-a-configuration-gap: n8izt7
  - every-ticket-on-a-map-resolves-a-decision: xucwlf
  - name-the-destination-first: i5z7cg
  - the-map-lives-inside-the-effort-it-charts: 3d5usf
  - an-index-not-a-store: xxlhje
  - the-design-document-is-the-map-until-one-exists: kahlcy
  - open-tickets-are-not-listed: t7av1o
  - decision-tickets: wg90su
  - a-branch-bound-decision-ticket-is-a-section: uy43op
  - a-decision-ticket-is-sized-to-one-context-window: 30msfk
  - the-tracker-s-id-is-the-only-number: oxbx82
  - a-decision-ticket-s-blocker-is-answer-gating: 0f04uz
  - every-ticket-is-hitl-or-afk: y6lqfo
  - the-map-is-deliberately-incomplete: l6qkx6
  - fog-or-ticket-is-a-test-of-precision: tqdh0q
  - fog-gathers-only-toward-the-destination: d6bfsj
  - a-drift-finding-gets-one-task-list-line: f33x4q
  - on-github-the-drift-line-goes-in-the-body: 5344xz
  - working-the-map: sxixi3
  - expect-other-sessions-on-the-map: br5zio
  - the-map-is-done-when-nothing-is-left-to-decide: on6sfl
  - hand-back-to-step-5-of-design: bmnb0v
---

# Map

Reached only when the fog gate fired: the effort cannot be scoped yet, so a spec written now would be built on guesses. A map finds the way — a shared artifact of **decisions**, worked one at a time until nothing is left to decide, and only then does a spec exist to write.

## Read what a ticket is before creating anything

- **Read `What a ticket is` in the tracker record before creating anything below** — whether a decision may be a *ticket* is the tracker's to say.

## Branch-bound

- **Branch-bound** — a ticket becomes a branch and a decision produces none, so decision work stays off the tracker: each decision is a section of the design document, same content as the ticket form below, resolved in place; each session's resolutions land as that session's design PR (the version-control record names the exception this rides on). Only the map itself goes on the tracker, because only the map survives into build tickets. Everything below that says *ticket* reads as *section*: claiming and `Status:` lines fall away, and the map links to sections rather than files or issues.

## Tracked intent

- **Tracked intent** — decision tickets are tickets, and this file applies as written.

## An undeclared placement is a configuration gap

- **A tracker policy with no such declaration predates it: a configuration gap** — say so and have `/configure` backfill it; never guess the placement the gap was created to settle.

## Every ticket on a map resolves a decision

- **Every ticket on a map resolves a decision, never a slice of a build** — a map that starts executing stops charting, and the unexplored part never gets explored. The pull to just start building usually signals the map is finished; resist it earlier than that.

## Name the destination first

- **Name the destination first** — one or two lines saying what reaching the end looks like; it fixes the scope and shapes every ticket, and every session orients to it before choosing one.

## The map lives inside the effort it charts

- **The map lives inside the effort it charts**, wherever the tracker record says efforts are: `.claude/tickets/<effort>/map.md` on a local-markdown tracker, beside that effort's own spec and issues; a pinned issue on GitHub. One map per effort, so a shared path would make two mapped efforts contend for one file; what spans every effort lives at the tickets root instead.

## An index, not a store

- **An index, not a store** — a decision lives in exactly one place, its ticket; the map gists and links.

## The design document is the map until one exists

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

- [ ] [<what it falsifies>](<evidence record>) — <one-line gist>
```

## Open tickets are not listed

- **Open tickets are not listed** — they carry `Part of: map` and are found by querying the tracker; a list of them on the map is a second copy that goes stale.

## Decision tickets

Same file and format as any ticket (`tickets.md`), with three differences: the body is a question, the ticket carries a type, and the title's commit records the answer — an ADR or a design-document change, usually `docs:` — so the title rule holds unchanged.

```markdown
# <NN> — type(scope): summary — e.g. docs(checkout): settle the retry flow

Status: open
Part of: map
Type: grilling
Blocked by: 03

## Question

<the decision or investigation this ticket resolves>
```

## A branch-bound decision ticket is a section

- **On a branch-bound tracker a decision ticket is a section of the design document**, so its facts are lines rather than frontmatter — a section has nowhere to put fields; that is the one place the two forms differ, because the artefact does.

## A decision ticket is sized to one context window

- **Each ticket is sized to one fresh context window; the answer is written on resolution, never in the body.**

## The tracker's id is the only number

- **Where the tracker assigns ids, its id is the only number** — no `<NN>` prefix and edges use the tracker's ids; two numbering systems force a lookup on every edge.

## A decision ticket's blocker is answer-gating

- **A decision ticket's `Blocked by:` is answer-gating, never a stacking instruction** — a decision produces no branch, so there is nothing to stack.

## Every ticket is HITL or AFK

- **Every ticket is HITL — worked with a human who speaks for themselves — or AFK, driven alone.** A HITL ticket resolves only through that live exchange: an agent that answers its own grilling questions has not resolved the ticket, it has skipped it.

| Type | Mode | Use when |
| --- | --- | --- |
| `grilling` | HITL | the default. A decision to be talked out, one question at a time |
| `research` | AFK | a fact outside this repository gates the decision. `/research` resolves it |
| `prototype` | HITL | "how should it look" or "how should it behave" is the question. `/prototype` makes something cheap to react to |
| `task` | either | manual work that must happen before a decision can be made. The one type that *does* rather than decides, earning its place by unblocking a decision |

## The map is deliberately incomplete

- **The map is deliberately incomplete: don't chart what you cannot see yet.** Resolving a ticket clears the fog ahead of it, graduating whatever became specifiable into fresh tickets.

## Fog or ticket is a test of precision

- **Fog or ticket — the test is whether the question can be stated precisely now**, not whether it can be answered: a sharp question is a ticket even while blocked; anything dimmer goes under **Not yet specified**, and fog is never pre-sliced into ticket-sized pieces — one patch may graduate into several tickets, or none.

## Fog gathers only toward the destination

- **Fog gathers only toward the destination** — work beyond it goes under **Out of scope** with one line saying why, stays out of **Decisions so far** (that section records the route actually walked), and never graduates; it returns only if the destination is redrawn, as a fresh effort. A live ticket found past the destination is marked `obsolete` with the line.

## A drift finding gets one task-list line

- **A drift finding in the effort's area gets one task-list line under `Drift found`** — the gist and the link to the evidence record (`evidence.md`), checked off when the healing lands; never the finding's content.

## On GitHub the drift line goes in the body

- **On GitHub the line goes in the map's issue body, never a comment** — the body comes back with the call every session already makes; a comment is a separate paginated fetch each session would have to remember, which is how a finding stays unread.

## Working the map

One ticket per session — research tickets excepted, which run in parallel without consuming it:

1. Load the map — the low-resolution view, not every ticket body.
2. Choose a ticket: the one the user named, or the first on the frontier as `/implement` defines it. **Claim it first**, before any work.
3. Resolve it, zooming into related ticket bodies on demand; invoke the skills `## Notes` names — `grilling` and `domain-modeling` by default.
4. Record it: the answer under `## Answer`, the resolution in whatever form the tracker record says — a `Status:` line on a local tracker, closing the issue on GitHub — and one line appended to **Decisions so far**.
5. Update the map: add surfaced tickets, graduate fog the answer sharpened — clearing each graduated patch from **Not yet specified**, so it lives only as its ticket — and mark obsolete what the decision invalidated.

## Expect other sessions on the map

- **Expect other sessions on the map concurrently** — unblocked tickets can be worked in parallel.

## The map is done when nothing is left to decide

- **The map is done when every remaining decision is settled or declared as a scoped increment on the build ticket that can answer it** (`tickets.md` has the declaration) — a map exiting with declared increments names, in the hand-back, which tickets carry them.

## Hand back to step 5 of design

- **Hand back to step 5 of `/design`** — the tier's normal deliverable, a spec then tickets, now has something solid to stand on.
