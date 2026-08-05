---
title: feat(design): the whole planning surface
status: resolved
blocked-by: [01, 02]
---

## Problem

`/design <text>` owns everything between a request and a workable plan (ADR 0011). It absorbs `to-spec`, `to-tickets`, and `wayfinder`. The user then calls `/implement`, which works the plan.

This makes `/design` the largest skill in the set. Progressive disclosure is what keeps it legible — and, not incidentally, what stops the grill being rushed.

## Outcome

`./skills/design/` — user-invoked.

### Inline in SKILL.md — every run needs these

**1 — Discover.** Marker check first (one `git` call). Load `.claude/context.md`, route to the matching `contexts/*.md`, then read the code. Verify what you are about to rely on — verification is scoped to the contexts routing selected, so it comes *after* routing, not before. Inspect source before any repository-specific claim.

**2 — State your understanding.** Say plainly what you now believe about the problem and the code, including the assumptions you are making. This is a stated position, not a question — it lets a wrong model be corrected while correcting it is still free. Never skip it, even when the work looks obvious; obvious work is where wrong models survive longest.

**3 — Refine, when needed.** Ask only where the answer changes architecture, behaviour, compatibility, security, or long-term maintenance. Grill the idea — proportionate to the work, one or two sharp questions on a config change, relentless on an architecture change. Grill the idea, never the user.

Where more than one reasonable approach exists, present **options**: each named, with advantages, disadvantages, risks, and long-term maintenance impact. Recommend one. **The user chooses.** This is the mechanism behind "Claude never silently decides architecture" — without it, that rule has nothing to attach to.

**4 — Evidence, when the scope fits.** `/research` for facts, `/prototype` for feel. Gated evidence **blocks** — the gate fired because the answer is load-bearing. Ungated runs in the background. Durable findings **graduate**: how the repo behaves → `context.md`, why an approach was chosen → an ADR. `/design` owns that graduation, since it read the findings.

**5 — Plan.** Always at least one ticket. A spec as well when the scope warrants one.

**Scope assessment** decides how much of 3–5 happens, as `max(Floor, Gates)`:

| Classification | Floor |
| --- | --- |
| docs, config, bug fix, isolated refactor | Express |
| feature, API addition, schema evolution | Standard |
| migration, architecture, security, performance-critical, cross-domain | Heavyweight |

Gates raise only — unverified load-bearing assumption → evidence first; crosses a boundary, public contract, or data at rest → spec; exceeds one smart zone (~120k) → many tickets; too foggy to scope → map.

Never assess scope before step 2. Report classification, gates, and resulting tier; the user overrides in either direction.

**6 — Capture.** Vocabulary and ADRs are written *as they resolve*, not batched — the refine step is where most durable understanding is produced. ADRs use the 3-of-3 test.

### The deliverable is always a file

| Tier | Produces |
| --- | --- |
| Express | one ticket |
| Standard | spec + ticket(s) |
| Heavyweight | evidence, then spec, then tickets with edges |
| + fog | a map of decision tickets, worked before any spec exists |

Nothing lives only in the conversation. `/implement` therefore always has something to read, and context can be cleared between any two steps.

### Disclosed — reached only when the tier selects it

| File | Reached when |
| --- | --- |
| `SPEC-FORMAT.md` | Standard or above — problem, goal, constraints, architecture, approach, acceptance criteria, risks. Written to `.claude/docs/designs/` |
| `TICKETS.md` | always — but the multi-ticket slicing rules, `Blocked by:` / `Part of:` edges and the observable-outcome rule matter only above Express |
| `MAP.md` | fog gate fired — the effort cannot be scoped yet. Everything about maps lives in this file; `SKILL.md` says only that the branch exists |

Keeping these behind pointers is deliberate: with the deliverable formats invisible during the refine step, the grill cannot be rushed toward them.

### Re-planning

`/design` is also the entry point when `/implement` hands a ticket back as **blocked**. Read its `## Blocked` note and the partial work still in the tree — both are evidence about why the plan failed, and the tree is often the sharper of the two. Re-plan from there.

Tickets the re-plan makes unnecessary are marked `obsolete` with a reason, never deleted and never left open — an open ticket nobody needs will eventually be claimed and built.

### `/design` plans; it never builds

It stops at its deliverable and hands back. It does not invoke `/implement`. That invocation is the user's approval.

## Acceptance

- Step 2 always happens — an understanding is stated before any scope assessment.
- Scope is never assessed before the refine step has run.
- `/design` never invokes `/implement`.
- Options are presented whenever more than one reasonable approach exists, not only on request.
- Every run leaves at least one ticket on disk. Nothing important lives only in the conversation.
- `SKILL.md` carries no deliverable-format detail; each lives behind its pointer.

## Comments

**Ticket status vocabulary aligned with `docs/agents/issue-tracker.md`.** `TICKETS.md`
and `MAP.md` use `ready-for-agent` / `claimed` / `blocked` / `resolved` /
`obsolete`. The first draft invented `in-progress` / `done`; the repo already
documents `claimed` / `resolved`, and a second vocabulary for the same states is
the sediment this framework is supposed to prevent.

**Decision 37 was missing and is now in `TICKETS.md`** — every ticket after the
first declares `Part of:` or `Blocked by:`, with `Blocked by: —` as a positive
statement rather than an omitted line. Found by the spec review.

**`SPEC-FORMAT.md`'s status vocabulary was completed during ticket 06.** It
listed `draft` / `accepted` / `superseded`; decision 23 also gives specs
`implemented`, `superseded by <path>`, and `abandoned`, and `/commit` writes
`implemented` — a status the format did not define. All three were added, and
the *reasoning is frozen, only the status line moves* rule now lives here rather
than being restated by the skill that writes the status. `verify.ps1` asserts
that every status `/commit` writes is one this file enumerates.
