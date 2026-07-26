# Map

Reached only when the fog gate fired: the effort cannot be scoped yet. The way from here to the end is not visible, so there is nothing to write a spec about — and writing one anyway produces a spec built on guesses.

A map finds the way. It is a shared artifact of **decision tickets**, worked one at a time until nothing is left to decide, and only then does a spec exist to write.

## Plan, don't do

Every ticket on a map resolves a **decision**, not a slice of a build. The map is done when the way is clear — when someone could go and do the thing without another question.

The pull to just start building is usually the signal that the map is finished and it is time to hand back. Resist it earlier than that: a map that starts executing stops charting, and the unexplored part never gets explored.

## The destination

Naming the destination is the first act, because it fixes the scope and shapes every ticket. One or two lines saying what reaching the end looks like — the spec to hand off, the decision to lock, the change made in place.

Every session orients to it before choosing a ticket.

## The map file

`.claude/tickets/map.md`. An **index**, not a store: a decision lives in exactly one place — its ticket — and the map only gists it and links.

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
```

Open tickets are **not** listed. They are files in `.claude/tickets/` with `Part of: map`, found by looking — a list of them on the map is a second copy that goes stale.

## Decision tickets

Same file and format as any other ticket (see [TICKETS.md](TICKETS.md)), with two differences: the body is a question, and the ticket carries a type.

```markdown
# <NN> — <the question, as a title>

Status: ready-for-agent
Part of: map
Type: grilling
Blocked by: 03

## Question

<the decision or investigation this ticket resolves>
```

Each is sized to one fresh context window. The answer is not part of the body — it is written on resolution.

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

## Working the map

One ticket per session. Research tickets are the exception — they run in parallel and don't consume the session.

1. Load the map. The low-resolution view, not every ticket body.
2. Choose a ticket: the one the user named, or the first on the **frontier** — open, unblocked, unclaimed. **Claim it first**, before any work, by setting `Status: claimed`.
3. Resolve it. Zoom as needed: read the full body of a related or resolved ticket on demand. Invoke the skills the `## Notes` block names; `grilling` and `domain-modeling` by default.
4. Record it: write the answer into the ticket under `## Answer`, set `Status: resolved`, and append one line to **Decisions so far**.
5. Update the map — add newly surfaced tickets, graduate the fog the answer made specifiable (clearing each graduated patch from **Not yet specified**, so it lives only as its ticket), and mark obsolete anything the decision invalidated.

Expect other sessions to be editing the map concurrently — unblocked tickets can be worked in parallel.

## Leaving the map

When nothing is left to decide, the map is done. Hand back to step 5 of `/design`: the tier's normal deliverable — a spec, then tickets — now has something solid to stand on.
