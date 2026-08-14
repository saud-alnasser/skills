---
name: design
description: Turn a request into a workable plan — discover, state an understanding, grill, gather evidence, and leave a spec and tickets on disk. Use when a request would change code and no ticket covers it yet, however the request arrived. Not for a question about how something works, and not when a ticket already exists — that is /implement's.
metadata:
  mode: design
  policies: [decisions, evidence, knowledge, maps, specs, tickets, tracker]
---

# Design

Everything between a request and a plan `/implement` can build — discovery, the grill, evidence, scope, and the deliverable in one skill, because splitting them lets the grill be skipped.

`/design` **plans; it never builds.** It stops at its deliverable and hands back — it never invokes `/implement`, because that invocation is the user's approval.

## 1 — Discover

**Check the Marker first**, before anything is read — the rule and both drift reads are in `.claude/protocol.md`, and the position script it names computes them; a tool guide is opened only when an operation needs one. Then, in order:

1. Query the store for the repository's `context` records.
2. **Route** — its table says which Domain Contexts this request touches. Load those, and only those.
3. **Verify** what you are about to rely on — scoped to what routing selected, which is why it comes after routing: verifying everything is the startup scan the Marker exists to avoid.
4. **Read the code.** `.claude/rules/engineering.md` has the rule; discovery is where it bites hardest.
5. **Read the waiting drift.** Every `evidence` record declares its kind and what it falsifies, so one filter over the store answers which findings bear on this request — open only those whose area this request plans, then fold their healing into this run's deliverable. Reading the directory whole is the cost the index exists to remove. **Waiting is read off the finding, never derived** — which line answers it is the `evidence` norm's, and opening the knowledge a finding falsified to work out whether anyone healed it is the cost that line removes. **Raise every finding the index shows as waiting whose area this work touches** — not only the ones this run planned to open; raising one is putting it in front of somebody positioned to answer, and **it is never deciding that it was consumed** — a wrong guess retires a finding nobody acted on.

Open with the one-line verification report, including when there was nothing to verify.

## 2 — State your understanding

Say plainly what you now believe about the problem and the code, **including the assumptions you are making** — a stated position, not a question: a position invites correction, and a wrong model is free to fix here and expensive after the plan is built on it. **Never skip it** — obvious work is where wrong models survive longest.

## 3 — Refine, when needed

Grill the idea, proportionate to the work, one question at a time, using `grilling`. Ask only where the answer changes **architecture, behaviour, compatibility, security, or long-term maintenance** — everything else is decided or looked up. **Grill the idea, never the user.**

- **Root cause, not workaround** — when the plan hits a limitation, find out why the limitation exists before designing around it; this is the last stage that can still see the choice. Where a workaround genuinely is the answer, the spec records **why it exists, what alternatives were considered, and the removal conditions** — without a removal condition, "temporary" is intent, not a state anything can leave.
- **Where more than one reasonable approach exists, present the options** — each named, with **Advantages**, **Disadvantages**, **Risks**, and **Maintenance impact** — recommend one with reasoning, and **the user chooses.** This is the mechanism behind *never silently decide architecture*.

## 4 — Evidence, when the scope fits

`/research` for facts, `/prototype` for feel. Gating and graduation are the `evidence` norm's; what is `/design`'s to *do*: a gate stops this stage, and this stage promotes a durable finding into Context or a Decision — nothing downstream reads the findings. A grill that ends without a decision **may be recorded as a discussion** in evidence — `/design` writes it because `/design` ran the grill, and later promotes it through the graduation it owns.

## Scope assessment

**Never before step 2** — assessing scope early anchors the grill to the tier you guessed. Tier is `max(Floor, Gates)`:

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

Report the classification, the gates that fired, and the resulting tier. The user overrides in either direction, and their override stands.

## 5 — Plan

**Always at least one ticket**, and a spec when the tier warrants one — **nothing lives only in the conversation**: the deliverable is a file, so `/implement` always has something to read and context can be cleared between any two steps.

| Tier | Produces |
| --- | --- |
| Express | one ticket |
| Standard | spec + ticket(s) |
| Heavyweight | evidence, then spec, then tickets with edges |
| + fog gate | a map, worked before any spec exists |

- **No ticket in the set is protocol-only** — the `tickets` norm says what counts and where that work rides instead; a set still containing one is a set-cutting error, caught here while nothing has been created.
- The formats are the stage's own norms: `tickets` always; `specs` at Standard and above (where a spec is written is the `tracker` norm's); `maps` only when the fog gate fired. The row loads whole; **a format is applied when the tier selects it** — applying a map format to an Express fix is the tier being ignored, not the row being read.
- **A ticket may carry declared increments** — decisions only partial code can answer; the `tickets` norm has the declaration, `/implement` what reaching one does. Declare one only where the answer genuinely needs the partial build: increments on questions answerable up front are the scope assessment being dodged.
- A ticket may also carry a **fan-out** — the declaration that its work divides. `/design` writes it, for the reason the format gives; the format is the `tickets` norm's, and this is where the reason is grilled. Declare one only where the portions are genuinely separable — a split whose parts keep reaching into each other costs more to integrate than it saved, and that shows while the declaration is being written.

### On a shared tracker, the set is approved before it is created

**Creating an issue publishes** — it lands in other people's workspace, gated exactly as opening a pull request is:

1. Write the set into the design document — every ticket, with its edges.
2. Show it, iterate on it, get it approved.
3. only then create — root first, then each child, then the links. **Step 3 opens by re-running the protocol-only check on the final set**, immediately before the first issue is created — step 2 iterates, and creating is the act that publishes. A ticket that fails leaves the set and rides its consumer.

The set lives in the design document until step 3: a context reset loses nothing, and a teammate can argue with the breakdown while arguing is still cheap. On a local-markdown tracker there is nothing to gate — the files are the proposal. **Which kind this repository has is in the `tracker` norm**, read rather than inferred.

**One run creates exactly one top-level issue** — every other ticket goes underneath it, and a design that yields a single ticket makes *that* ticket the root: the top level grows by one per design, so booming is visible at a glance. The `tickets` norm has the hierarchy and edges; the `github` reference the invocations.

## 6 — Capture

Vocabulary and Decisions are `/design`'s to write, and this is the stage that writes them — the `knowledge` norm says why the pen sits here. Use `domain-modeling`. The bar a Decision must clear is the `decisions` norm's: a convention is not a decision.

## An incoming issue is an input, not a plan

An issue triaged to `ready-for-agent` says a change is wanted — not what done looks like, the acceptance criteria, or how the work divides. It enters here exactly as a typed request — discover, state an understanding, grill, size — and **becomes the root** of the ticket set this run produces; nothing is created above it.

## Re-planning

`/design` is also the entry point when `/implement` hands a ticket back as **blocked**. Read the ticket's `## Blocked` note and the partial work still in the tree — **the tree is usually the sharper of the two**: it shows where the plan met reality. Re-plan from there. Tickets the re-plan makes unnecessary are marked `obsolete` with a reason — **never deleted** and never left open: a deleted ticket loses the reason it existed, and an open one will eventually be claimed and built.
