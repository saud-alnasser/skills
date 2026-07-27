---
name: design
description: Turn a request into a workable plan — discover, state an understanding, grill, gather evidence, and leave a spec and tickets on disk. Use when starting any piece of work that isn't already planned.
disable-model-invocation: true
---

# Design

Everything between a request and a plan `/implement` can work. Discovery, the grill, evidence, scope, and the deliverable — one skill, because splitting them lets the grill be skipped.

`/design` **plans; it never builds.** It stops at its deliverable and hands back. It does not invoke `/implement` — that invocation is the user's approval, and taking it away is how a wrong plan gets built before anyone notices it was wrong.

## 1 — Discover

**Check the Marker first.** One `git` call, before anything is read. The rule and both drift reads are in `CLAUDE.md`; `tools/git.md` has the invocations.

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

**Gated evidence blocks.** The gate fired because the answer is load-bearing; planning past it means planning on a guess. Ungated evidence runs in the background and the design continues.

Durable findings **graduate** out of evidence and into knowledge — how the repo behaves becomes Context, why an approach was chosen becomes an ADR. `/design` owns that graduation, because `/design` read the findings and nothing downstream will.

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

Formats:

- [TICKETS.md](TICKETS.md) — always.
- [SPEC-FORMAT.md](SPEC-FORMAT.md) — Standard and above. Written to `.claude/docs/designs/`.
- [MAP.md](MAP.md) — only when the fog gate fired. That branch exists; everything about it lives in that file.

Read a format file when the tier selects it, not before. Knowing what the deliverable looks like while you are still grilling is an invitation to rush toward it.

## 6 — Capture

Vocabulary and ADRs are written **as they resolve**, not batched at the end. The refine step is where most durable understanding is produced, and batching loses the half of it that felt obvious at the time.

Use `domain-modeling`. ADRs use its 3-of-3 test — a convention is not a decision.

## Re-planning

`/design` is also the entry point when `/implement` hands a ticket back as **blocked**.

Read two things: the ticket's `## Blocked` note, and the partial work still in the tree. Both are evidence about why the plan failed, and **the tree is usually the sharper of the two** — it shows where the plan met reality, not where it was expected to.

Re-plan from there. Tickets the re-plan makes unnecessary are marked `obsolete` with a reason — **never deleted** and never left open. A deleted ticket loses the reason it existed; an open ticket nobody needs will eventually be claimed and built.
