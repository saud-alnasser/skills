# Map

Reached only when the fog gate fired: the effort cannot be scoped yet. The way from here to the end is not visible, so there is nothing to write a spec about — and writing one anyway produces a spec built on guesses.

A map finds the way. It is a shared artifact of **decisions**, worked one at a time until nothing is left to decide, and only then does a spec exist to write. Whether a decision may be a *ticket* is the tracker's to say — the next section is read before anything is created.

## Where decision work lives

**Read `What a ticket is` in `.claude/policies/tracker.md` first.** Nothing below is created until it has been.

- **Branch-bound** — a ticket here becomes a branch, and a decision produces none, so decision work does **not** go on the tracker. Each decision is a section of the design document, same content as the ticket form below, resolved in place; each session's resolutions land as that session's design PR — `.claude/policies/version-control.md` names the exception this rides on. Only the map itself goes on the tracker, because only the map survives into build tickets. **Everything below that says *ticket* reads as *section* here**: claiming and `Status:` lines fall away — the document is one shared surface — and the map's links point at sections of the design document rather than at ticket files or issues.
- **Tracked intent** — decision tickets are tickets, and the rest of this file applies as written.

A tracker policy with no such declaration predates it. That is a configuration gap: say so and have `/configure` backfill the declaration — never guess the placement the gap was created to settle.

## Plan, don't do

Every ticket on a map resolves a **decision**, not a slice of a build. The map is done when the way is clear — **Leaving the map**, below, states the test.

The pull to just start building is usually the signal that the map is finished and it is time to hand back. Resist it earlier than that: a map that starts executing stops charting, and the unexplored part never gets explored.

## The destination

Naming the destination is the first act, because it fixes the scope and shapes every ticket. One or two lines saying what reaching the end looks like — the spec to hand off, the decision to lock, the change made in place.

Every session orients to it before choosing a ticket.

## The map file

The map lives **inside the effort it charts**, wherever `.claude/policies/tracker.md` says efforts are: `.claude/tickets/<effort>/map.md` on a local-markdown tracker, beside that effort's own spec and issues; a pinned issue on GitHub. An **index**, not a store: a decision lives in exactly one place — its ticket — and the map only gists it and links.

It goes inside the effort rather than at the root of the tickets directory because there is **one map per effort** — the title below names one — and a shared path is one file for an artefact that comes one per effort, so two efforts mapped at once would contend for it. The root of the tickets directory carries what spans every effort instead.

Until the map exists in that form, the design document holds the proposal and *is* the map; once created, the created map supersedes it. The proposal is not mirrored onto the map afterwards — that would be the second copy the rule below exists to prevent.

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

Open tickets are **not** listed. They carry `Part of: map` and are found by querying the tracker — a list of them on the map is a second copy that goes stale.

## Decision tickets

Same file and format as any other ticket (see `.claude/policies/tickets.md`), with three differences: the body is a question, the ticket carries a type, and the title's commit is not code. The title rule in `.claude/policies/tickets.md` holds unchanged, because a decision ticket is not commitless — it records the answer as an ADR or a design-document change, usually `docs:`, and that is the commit the title writes.

A decision ticket is a **section of the design document**, not a file, so it carries these facts as lines rather than as frontmatter: `.claude/policies/tickets.md`'s fields belong to a file, and a section has nowhere to put them. That is the one place the two forms differ, and it differs because the artefact does.

```markdown
# <NN> — type(scope): summary — e.g. docs(checkout): settle the retry flow

Status: open
Part of: map
Type: grilling
Blocked by: 03

## Question

<the decision or investigation this ticket resolves>
```

Each is sized to one fresh context window. The answer is not part of the body — it is written on resolution.

Where the tracker assigns ids, its id is the ticket's only number: no `<NN>` prefix in the title, and edges use the tracker's ids. Two numbering systems for one set of tickets forces a lookup on every edge, and dependency order is already readable from the edges themselves.

A decision ticket's `Blocked by:` is **answer-gating, never a stacking instruction** — it waits on the blocker's *answer*, whatever the version-control policy makes the same edge mean for build tickets. A decision produces no branch, so there is nothing to stack.

### Types

Every ticket is either **HITL** — worked *with* a human who speaks for themselves — or **AFK**, driven alone. A HITL ticket resolves only through that live exchange. **An agent that answers its own grilling questions has not resolved the ticket; it has skipped it.**

| Type | Mode | Use when |
| --- | --- | --- |
| `grilling` | HITL | the default. A decision to be talked out, one question at a time |
| `research` | AFK | a fact outside this repository gates the decision. `/research` resolves it |
| `prototype` | HITL | "how should it look" or "how should it behave" is the question. `/prototype` makes something cheap to react to |
| `task` | either | manual work that must happen before a decision can be made — provisioning access, moving data so its shape can be seen. The one type that *does* rather than decides, and it earns its place by unblocking a decision |

## Fog of war

The map is **deliberately incomplete**. Don't chart what you cannot see yet.

Beyond the live tickets is the **fog of war**: decisions you can tell are coming but cannot pin down, because they hang on questions still open. Resolving a ticket clears the fog ahead of it, graduating whatever is now specifiable into fresh tickets.

**Not yet specified** is where that dim view is written down — the suspected question, the area to revisit. It is in scope, just not sharp enough to ticket.

**Fog or ticket?** The test is whether you can state the question precisely *now* — not whether you can answer it.

- **Ticket** when the question is already sharp, even if it is blocked and you cannot act on it.
- **Not yet specified** when you cannot phrase it that sharply. Don't pre-slice fog into ticket-sized pieces: one patch may graduate into several tickets, or none.

## Out of scope

Fog gathers only *toward* the destination. Work beyond the destination is not fog and does not belong in **Not yet specified** — it goes in **Out of scope**, with one line saying what it is and why it is out.

Ruling something out of scope is a scoping act, not a step on the route, so it stays out of **Decisions so far** — that section records the route actually walked. When a ticket that already exists turns out to sit past the destination, mark it `obsolete` and add the line.

Out-of-scope work never graduates. It returns only if the destination is redrawn, and then as a fresh effort.

## Drift found

A drift finding in the effort's area — `.claude/policies/evidence.md` says what one is and where it lives — gets one task-list line under **Drift found**, linking to the evidence file, checked off when the healing lands. The line is an index entry like every other line on the map: the gist and the link, never the finding's content.

On GitHub the line goes in the map's issue **body, never a comment**. The body comes back with the one call every session already makes; a comment is a separate paginated fetch each session would have to remember, which is how a finding stays unread.

## Working the map

One ticket per session. Research tickets are the exception — they run in parallel and don't consume the session.

1. Load the map. The low-resolution view, not every ticket body.
2. Choose a ticket: the one the user named, or the first on the **frontier** as `/implement` defines it. **Claim it first**, before any work.
3. Resolve it. Zoom as needed: read the full body of a related or resolved ticket on demand. Invoke the skills the `## Notes` block names; `grilling` and `domain-modeling` by default.
4. Record it: write the answer into the ticket under `## Answer`, resolve it in whatever form `.claude/policies/tracker.md` says — a `Status:` line on a local tracker, closing the issue on GitHub — and append one line to **Decisions so far**.
5. Update the map — add newly surfaced tickets, graduate the fog the answer made specifiable (clearing each graduated patch from **Not yet specified**, so it lives only as its ticket), and mark obsolete anything the decision invalidated.

Expect other sessions to be editing the map concurrently — unblocked tickets can be worked in parallel.

## Leaving the map

The map is done when every remaining decision is either settled, or declared as a scoped increment on the build ticket that can answer it (`.claude/policies/tickets.md` has the declaration). A map exiting with declared increments says, in the hand-back, which tickets carry them.

Hand back to step 5 of `/design`: the tier's normal deliverable — a spec, then tickets — now has something solid to stand on.
