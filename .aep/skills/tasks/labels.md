---
aep: 2.3.0
owner: protocol
date: 2026-08-17
kind: skill
use-when: "the effort's tasks live in an external tracker, and its work must be findable there"
---

# Tasks — carrying the effort in the tracker

`[[policies/execution]]` fixes **what must be true**: an external task is
attributable to its effort by a query the tracker answers natively, one fact
only, and nothing written into `.aep/`. This is how to find out what carries that
fact *here*, and what to do when nothing does.

Run it **once per tracker**, not once per effort. The answer is recorded and
afterwards it is read.

## The ladder

Stop at the first step that serves the fact.

```
1. a first-class feature of this tracker      milestone · epic · parent ·
                                              sub-issue · dependency
2. an existing label that already serves it
3. a new label
```

**A label is never created for a fact the tracker models natively.** A tracker
that already answers *which work belongs to this group* has answered it; a label
beside that is a second copy, maintained by hand, disagreeing with the first one
the moment somebody uses the tracker's own interface.

### 1 — What does this tracker model?

Read the tracker's own features before its labels. `[[references]]` for the tool
says what it has and how it is reached; where the reference is silent, the tool's
own help is the authority — not memory, and not what a similar tracker does.

**A native feature counts only if it answers the same question.** The test is not
whether it is nearby, but whether the query you need comes back from it:

| Serves it | Does not |
| --- | --- |
| the fact is what the feature *is for*, and it is filterable in a list query | it can hold the fact, but nothing can query it |
| one effort maps to one of them | efforts and the feature are many-to-many |
| the team is not already using it for something incompatible | it is already carrying release scheduling, and an effort is not a release |

A feature that holds the fact but cannot be queried has not served it — the whole
point is that the frontier is read rather than reconstructed.

### 2 — Does a label already serve it?

Only if no feature does. List the tracker's labels — the whole list, not the
first page — and look for one that already means the fact. An existing label
carries the team's meaning; adopting it is better than adding a synonym beside
it.

### 3 — Name a new one like the ones already there

Only if neither of the above. **One label, not a family**, and it takes its shape
from the vocabulary already in the tracker — its separator, its casing, its
prefixing:

```
a tracker labelled   area/api · area/db · type/bug
  →  effort/<slug>

a tracker labelled   Area: API · Type: Bug
  →  Effort: <slug>
```

Same fact, two strings, because the tracker was already written in two different
hands. A label that ignores the local convention reads as something a tool left
behind, which is what it would be.

**And often there is nothing to create at all.** On a tracker that models
milestones, dependencies and issue state itself, every fact lands at step 1 and
**no label is created** — the correct outcome, not a degenerate one.

## Record it, once

Write the resolution into the repository's `[[references]]` for that tracker:
what carries each fact, and the query that returns the effort's open work.

**Later sessions read it. They do not rederive it.** A resolution worked out
again each session is a resolution that differs each session, and two answers to
one question is how a tracker ends up with two labels meaning the same thing.

**Where the reference has no such section, write it.** An upgrade never re-seeds
a reference the repository has corrected, so a repository whose reference
predates this will never be handed the section — it arrives here or not at all.
Where there is no reference for the tracker, the resolution is the first thing in
one.

## Before creating anything

**Creating a label or a milestone publishes.** It lands in a workspace other
people share, so it is gated exactly as creating issues is: propose the whole
set — what would be created, and the issues alongside it — show it, get approval,
then create.

**Show exact strings, never a summary.** *"Labels will be created"* is not
something a human can judge; `effort/tracker-labels` is.

**Approval is not permission.** A human may agree and the token still refuse. A
refusal is a **stop with a report** — which fact, which mechanism, which
permission — never a quiet slide down the ladder to something the agent is
allowed to do instead. Falling back on the spot produces a label nobody approved,
carrying a fact somebody meant to be native.

## Done when

Each fact has a carrier, the carrier is recorded in the tracker's reference, and
the query that returns the effort's open work has been run once and returned what
was expected.
