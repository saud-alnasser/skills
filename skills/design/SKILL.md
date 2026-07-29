---
name: design
description: Turn a request into a workable plan — discover, state an understanding, grill, gather evidence, and leave a spec and tickets on disk. Use when starting any piece of work that isn't already planned.
disable-model-invocation: true
---

# Design

Everything between a request and a plan `/implement` can work. Discovery, the grill, evidence, scope, and the deliverable — one skill, because splitting them lets the grill be skipped.

`/design` **plans; it never builds.** It stops at its deliverable and hands back. It does not invoke `/implement` — that invocation is the user's approval, and taking it away is how a wrong plan gets built before anyone notices it was wrong.

## 1 — Discover

**Check the Marker first.** One `git` call, before anything is read. The rule and both drift reads are in `.claude/protocol.md`; `.claude/tools/git.md` has the invocations.

Then, in this order:

1. Load `.claude/context.md`.
2. **Route** — its routing table says which Domain Contexts this request touches. Load those, and only those.
3. **Verify** what you are about to rely on. Verification is scoped to what routing selected, which is why it comes after routing and not before: verifying everything is the startup scan the Marker exists to avoid.
4. **Read the code.** `CLAUDE.md` has the rule; discovery is where it bites hardest, because a plan built on a guessed model of the repository is wrong before the first ticket is cut.

Open with the one-line verification report, including when there was nothing to verify.

## 2 — State your understanding

Say plainly what you now believe about the problem and about the code, **including the assumptions you are making.**

This is a stated position, not a question. A question invites agreement; a position invites correction, and a wrong model is free to fix here and expensive to fix after the plan is built on it.

**Never skip it** — not when the work looks obvious. Obvious work is where wrong models survive longest, because nobody thinks to check.

## 3 — Refine, when needed

Grill the idea. Ask only where the answer changes **architecture, behaviour, compatibility, security, or long-term maintenance** — everything else you can decide yourself or look up.

Proportionate to the work: one or two sharp questions on a config change, relentless on an architecture change. One question at a time. Use `grilling`.

**Grill the idea, never the user.**

### Root cause, not workaround

When the plan runs into a limitation, the grill's job is to find out **why the limitation exists** before designing around it. Prefer redesign: identify the root cause, understand what put it there, weigh the alternatives, and change the shape rather than accreting a bypass. A workaround costs nothing today and compounds; this is the last stage that can still see the choice.

Where a workaround genuinely is the answer, the spec records three things — **why it exists, what alternatives were considered, and the removal conditions**. The removal condition is the one that matters: without it, "temporary" is a description of intent rather than a state anything can leave, and nobody later can tell whether the reason still holds.

### Options

Where **more than one reasonable approach** exists, present them — not only when asked. Each one named, with:

- **Advantages** — what it buys
- **Disadvantages** — what it costs
- **Risks** — what could go wrong, and how you'd know
- **Maintenance impact** — who pays, and for how long

Recommend one, with your reasoning. **The user chooses.**

This is the whole mechanism behind *Claude never silently decides architecture*. Without options on the table, that rule has nothing to attach to — a single confident recommendation is a silent decision wearing a suit.

## 4 — Evidence, when the scope fits

`/research` for facts. `/prototype` for feel.

Whether a block waits, and what happens to a finding afterwards, are in `.claude/policies/evidence.md`. Two things there are `/design`'s to *do* rather than merely to know: this is the stage a gate stops, and this is the stage that promotes a durable finding into Context or a Decision — nothing downstream reads the findings.

## Scope assessment

**Never before step 2.** An understanding has to exist before it can be sized, and assessing scope early anchors the grill to the tier you guessed.

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

**Nothing lives only in the conversation.** The deliverable is always a file, so `/implement` always has something to read and context can be cleared between any two steps without losing the plan.

Formats, all of them guides in the configured repository rather than files inside this skill — `.claude/protocol.md`'s routing table is the index:

- `.claude/policies/tickets.md` — always.
- `.claude/policies/specs.md` — Standard and above. Written to `.claude/designs/`.
- `.claude/policies/maps.md` — only when the fog gate fired. That branch exists; everything about it lives in that file.

Read a format file when the tier selects it, not before. Knowing what the deliverable looks like while you are still grilling is an invitation to rush toward it.

### On a shared tracker, the set is approved before it is created

**Creating an issue publishes.** It lands in other people's workspace, so it is gated exactly as opening a pull request is — and this is the worst place to boom, because the mess is in a queue a team reads.

```
1. write the set into the design document — every ticket, with its edges
2. show it, iterate on it, get it approved
3. only then create — root first, then each child, then the links
```

The set lives in the design document until step 3, which is what makes it survivable: a context reset loses nothing, and a teammate can argue with the breakdown while arguing is still cheap. On a local-markdown tracker there is nothing to gate — the files are the proposal.

**One run creates exactly one top-level issue.** Every other ticket goes underneath it as a sub-issue; a design that yields a single ticket makes *that* ticket the root rather than wrapping one child in a parent. The tracker's top level therefore grows by one per design, so booming is visible at a glance instead of needing a count. `.claude/policies/tickets.md` has the hierarchy and the edges; `.claude/tools/github.md` has the invocations, including which id the sub-issues API actually wants.

## 6 — Capture

Vocabulary and Decisions are `/design`'s to write, and this is the stage that writes them — `.claude/policies/knowledge.md` says why the pen sits here rather than downstream.

Use `domain-modeling` to do it. The bar a Decision has to clear is in `.claude/policies/decisions.md`: a convention is not a decision.

## An incoming issue is an input, not a plan

An issue somebody filed and triaged to `ready-for-agent` says a change is wanted. It does not say what "done" looks like, what the acceptance criteria are, or how the work divides — so it is a request, and it enters here rather than at `/implement`.

Treat it exactly as a request typed into the conversation: discover, state an understanding, grill, size it. It **becomes the root** of the ticket set this run produces, so the issue the human already opened is the top-level one and nothing is created above it.

## Re-planning

`/design` is also the entry point when `/implement` hands a ticket back as **blocked**.

Read two things: the ticket's `## Blocked` note, and the partial work still in the tree. Both are evidence about why the plan failed, and **the tree is usually the sharper of the two** — it shows where the plan met reality, not where it was expected to.

Re-plan from there. Tickets the re-plan makes unnecessary are marked `obsolete` with a reason — **never deleted** and never left open. A deleted ticket loses the reason it existed; an open ticket nobody needs will eventually be claimed and built.
