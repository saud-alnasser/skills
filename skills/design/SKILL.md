---
name: design
description: Turn a request into a workable plan — discover, state an understanding, grill, gather evidence, and leave a spec and tickets on disk. Use when a request would change code and no ticket covers it yet, however the request arrived. Not for a question about how something works, and not when a ticket already exists — that is /implement's.
metadata:
  mode: design
  policies: [decisions, evidence, knowledge, maps, specs, tickets, tracker]
---

# Design

Everything between a request and a plan `/implement` can build. Discovery, the grill, evidence, scope, and the deliverable — one skill, because splitting them lets the grill be skipped.

`/design` **plans; it never builds.** It stops at its deliverable and hands back — it never invokes `/implement`, because that invocation is the user's approval.

## 1 — Discover

**Check the Marker first** — one `git` call, before anything is read. The rule and both drift reads are in `.claude/protocol.md`; `.claude/tools/git.md` has the invocations.

Then, in order:

1. Load `.claude/contexts/map.md`.
2. **Route** — its table says which Domain Contexts this request touches. Load those, and only those.
3. **Verify** what you are about to rely on — scoped to what routing selected, which is why it comes after routing: verifying everything is the startup scan the Marker exists to avoid.
4. **Read the code.** `.claude/rules/engineering.md` has the rule; discovery is where it bites hardest.
5. **Read the waiting drift.** `.claude/evidence/map.md` indexes every finding of every kind, with what each falsifies — **route through it and open only the findings whose area this request plans**, then fold their healing into this run's deliverable. Skipping this read is how a finding stays unread. What one is, and why it may be waiting: `.claude/policies/evidence.md`.

   **Reading the directory whole is the cost the index exists to remove**, and a stage that does it anyway has not been slowed down — it has stopped using the mechanism.

   **Waiting is read off the finding, never derived.** Which line answers it is `.claude/policies/evidence.md`'s. Opening the knowledge a finding falsified in order to work out whether anyone had already healed it is the cost that line removes — and it is a cost paid *before* anyone knows the finding was spent.

   **Raise every finding the index shows as waiting whose area this work touches** — not only the ones this run planned to open. The index already says which are waiting, so noticing them costs nothing beyond the read you have just done, and the alternative is a finding sitting unanswered until an audit happens to run. Raising it is putting it in front of somebody positioned to answer it; **it is never deciding that it was consumed.** Whether the healing landed is the reader's call on the evidence, and a wrong guess retires a finding nobody acted on.

Open with the one-line verification report, including when there was nothing to verify.

## 2 — State your understanding

Say plainly what you now believe about the problem and the code, **including the assumptions you are making.** A stated position, not a question — a position invites correction, and a wrong model is free to fix here and expensive after the plan is built on it.

**Never skip it.** Obvious work is where wrong models survive longest.

## 3 — Refine, when needed

Grill the idea. Ask only where the answer changes **architecture, behaviour, compatibility, security, or long-term maintenance** — everything else you can decide yourself or look up.

Proportionate to the work, one question at a time. Use `grilling`.

**Grill the idea, never the user.**

### Root cause, not workaround

When the plan hits a limitation, find out **why the limitation exists** before designing around it. Prefer redesign: identify the root cause, weigh the alternatives, and change the shape — a workaround costs nothing today and compounds, and this is the last stage that can still see the choice.

Where a workaround genuinely is the answer, the spec records **why it exists, what alternatives were considered, and the removal conditions**. Without a removal condition, "temporary" is a description of intent rather than a state anything can leave.

### Options

Where **more than one reasonable approach** exists, present them — not only when asked. Each one named, with:

- **Advantages** — what it buys
- **Disadvantages** — what it costs
- **Risks** — what could go wrong, and how you'd know
- **Maintenance impact** — who pays, and for how long

Recommend one, with your reasoning. **The user chooses.** This is the mechanism behind *never silently decide architecture*.

## 4 — Evidence, when the scope fits

`/research` for facts. `/prototype` for feel.

Gating and graduation are `.claude/policies/evidence.md`'s. Two things there are `/design`'s to *do*: a gate stops this stage, and this stage promotes a durable finding into Context or a Decision — nothing downstream reads the findings.

A grill that ends without a decision **may be recorded as a discussion**, in evidence — the policy says what one holds and what disqualifies it. `/design` writes it because `/design` ran the grill, and later promotes it through the graduation it already owns.

## Scope assessment

**Never before step 2.** Assessing scope early anchors the grill to the tier you guessed.

Tier is `max(Floor, Gates)`.

| Classification | Floor |
| --- | --- |
| docs, config, bug fix, isolated refactor | Express |
| feature, API addition, schema evolution | Standard |
| migration, architecture, security, performance-critical, cross-domain | Heavyweight |

Gates **only raise** — never lower:

| Gate | Raises to |
| --- | --- |
| an unverified load-bearing assumption | evidence first |
| crosses a boundary, a public contract, or data at rest | spec |
| exceeds one smart context zone (~120k) | many tickets |
| too foggy to scope at all | a map |

Report the classification, the gates that fired, and the resulting tier. The user overrides in either direction — up or down — and their override stands.

## 5 — Plan

**Always at least one ticket.** A spec as well when the tier warrants one.

| Tier | Produces |
| --- | --- |
| Express | one ticket |
| Standard | spec + ticket(s) |
| Heavyweight | evidence, then spec, then tickets with edges |
| + fog gate | a map, worked before any spec exists |

**Nothing lives only in the conversation.** The deliverable is a file, so `/implement` always has something to read and context can be cleared between any two steps.

**No ticket in the set is protocol-only.** `.claude/policies/tickets.md` says what counts as protocol-only and where that work rides instead. A set still containing one is a set-cutting error, caught here while nothing has been created.

Formats are guides in the configured repository; `.claude/protocol.md`'s routing table is the index:

- `.claude/policies/tickets.md` — always.
- `.claude/policies/specs.md` — Standard and above. Where a spec is written is `.claude/policies/tracker.md`'s.
- `.claude/policies/maps.md` — only when the fog gate fired. That branch exists; everything about it lives in that file.

Read a format file when the tier selects it, not before.

A ticket may carry **declared increments** — decisions only partial code can answer. `.claude/policies/tickets.md` has the declaration and its timing, and `/implement` what reaching one does. Declare one only where the answer genuinely needs the partial build to exist: increments on questions answerable up front are the scope assessment being dodged, and the smell that the phase split is hollowing.

A ticket may also carry a **fan-out** — the declaration that its work divides. `/design` writes it, for the reason the format gives, and this is where that reason is grilled; the format is `.claude/policies/tickets.md`'s. Declare one only where the portions are genuinely separable: a split whose parts keep reaching into each other costs more to integrate than it saved, and that shows up while the declaration is being written rather than after the code is.

### On a shared tracker, the set is approved before it is created

**Creating an issue publishes.** It lands in other people's workspace, so it is gated exactly as opening a pull request is.

```
1. write the set into the design document — every ticket, with its edges
2. show it, iterate on it, get it approved
3. only then create — root first, then each child, then the links
```

**Step 3 opens by re-running the protocol-only check on the final set**, immediately before the first issue is created — not only when the set was cut, because step 2 iterates and creating is the act that publishes. `.claude/policies/tickets.md` has the test; read it off the diff each ticket would produce. A ticket that fails it leaves the set and rides its consumer, and the rest are created.

The set lives in the design document until step 3: a context reset loses nothing, and a teammate can argue with the breakdown while arguing is still cheap. On a local-markdown tracker there is nothing to gate — the files are the proposal.

**Which kind this repository has is in `.claude/policies/tracker.md`**, read rather than inferred.

**One run creates exactly one top-level issue.** Every other ticket goes underneath it as a sub-issue, and a design that yields a single ticket makes *that* ticket the root. The top level grows by one per design, so booming is visible at a glance. `.claude/policies/tickets.md` has the hierarchy and the edges; `.claude/tools/github.md` has the invocations, including which id the sub-issues API actually wants.

## 6 — Capture

Vocabulary and Decisions are `/design`'s to write, and this is the stage that writes them — `.claude/policies/knowledge.md` says why the pen sits here.

Use `domain-modeling` to do it. The bar a Decision has to clear is in `.claude/policies/decisions.md`: a convention is not a decision.

## An incoming issue is an input, not a plan

An issue triaged to `ready-for-agent` says a change is wanted — not what "done" looks like, the acceptance criteria, or how the work divides. It is a request: it enters here, treated exactly as one typed into the conversation — discover, state an understanding, grill, size it. It **becomes the root** of the ticket set this run produces, and nothing is created above it.

## Re-planning

`/design` is also the entry point when `/implement` hands a ticket back as **blocked**.

Read the ticket's `## Blocked` note and the partial work still in the tree — **the tree is usually the sharper of the two**: it shows where the plan met reality, not where it was expected to.

Re-plan from there. Tickets the re-plan makes unnecessary are marked `obsolete` with a reason — **never deleted** and never left open. A deleted ticket loses the reason it existed; an open one will eventually be claimed and built.
