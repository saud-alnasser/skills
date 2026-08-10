---
owner: repository
title: feat(implement): build, and record what moved
status: resolved
blocked-by: [01]
---

## Problem

matt's `implement` is four lines and carries no knowledge responsibility. Tenure's `/implement` has the best possible view of what just changed in the repository — it is the right writer for concepts, boundaries, and Source Pointers.

## Outcome

`./skills/implement/` — model-invoked, so `/design` can reach it.

### Step 0 — Verification. Every invocation. No exceptions.

`/implement` **opens with a verification report and cannot proceed without emitting one.** Not conditional on tier, size, or whether the work looks trivial. This is the strict form of ticket 02's discipline, and `/implement` is where it is enforced hardest — it is the command that turns context into code, so a stale belief here becomes a wrong edit.

The report is the enforcement. A rule that produces visible output is one whose absence is noticeable:

```
Verification
  marker a3f91c2 == HEAD, tree clean
  → context trusted as-is
```

```
Verification
  marker a3f91c2, HEAD 8b2d417 — 14 files changed
  working tree: 2 files edited outside this session
  contexts touched by this ticket: database
  → 3 pointers checked, 1 stale:
      contexts/database.md  src/db/ → src/persistence/  repaired
  → 1 claim contradicted by source:
      "migrations are transactional" — they are not. corrected.
```

**Completion criterion:** no source is read through a Source Pointer that has not been verified this session, and no context statement is acted on without being checked against source. A pointer that cannot be recovered by searching is reported — never replaced by a guess.

Retains matt's core: drive `tdd` at pre-agreed seams, typecheck often, full suite once at the end, close out with `/code-review`.

**One ticket per invocation, and it closes it out.** `/design` always leaves at least one ticket, so `/implement` always has something to read.

```
frontier = tickets open, unblocked, unclaimed
           lowest number wins — /implement does not choose

  → claim it        Status: claimed, saved BEFORE any work
  → build it        tdd at pre-agreed seams
  → /code-review    Spec + Standards
  → apply fixes
  → ASK             "commit and resolve this ticket?"

       yes      commit → resolve → advance Marker → stop
       not yet  stays claimed. keep refining in place.
```

Never take a second ticket in one invocation, and never start a blocked one. Claiming **before** any work is what stops two sessions grabbing the same ticket. If the frontier is empty, say so rather than inventing work; if everything left is blocked, name what blocks it.

### The close-out is the user's call

`/implement` does not decide the work is done. After review and fixes it **asks**, and a *not yet* keeps the ticket claimed and the loop open — request changes, refine, ask again. Refinement continues in the same context, on the same ticket, for as long as it takes.

### Never push. Amend instead.

`/implement` **never runs `git push`.** Pushing is the user's decision, always.

That guard is what makes the rest safe: once a commit exists and more changes are asked for, `/implement` **amends** it rather than stacking `fix typo` commits — so one ticket stays one commit. Amending rewrites history, which is only safe while nothing has been pushed. The two rules hold each other up; keeping the amend without the push guard would rewrite published history.

Each amend produces a new SHA, so **the Marker re-advances on every amend**, not just the first commit.

### When the plan turns out wrong

`/implement` **never redesigns.** It builds what was planned, or it stops — the same discipline `diagnosing-bugs` applies by refusing to theorise without a failing loop.

A plan is wrong when the ticket cannot be built as written: the architecture it assumes isn't there, an approach it depends on doesn't work, or the change turns out to cross a boundary nobody costed. Improvising past any of those silently discards the grill, the options the user chose, and the tier that was assessed.

```
→ stop. do not build past the discovery.
→ unclaim it            Status: open
→ append ## Blocked     what was found, and why the
                        plan cannot proceed as written
→ leave the working tree alone
     no half-commit, no revert of the user's files
→ hand back: this needs /design
```

Leaving the tree untouched matters — the partial work is often the best evidence of *why* the plan was wrong, and it is the user's to keep or discard.

If the ticket is merely harder than expected, that is not a wrong plan. Build it.

### Resuming

A claimed ticket with work in progress is **resumed**, not skipped — `/implement` picks it up ahead of the frontier, or takes a ticket named explicitly. A ticket left claimed by an abandoned session blocks its own frontier slot; say so plainly rather than silently working around it.

`/commit` handles work with no ticket — hand-written edits, or a change made outside this flow.

Adds:

- **Verify before use.** Every Source Pointer is checked against source before it's relied on. Never infer an API from a filename; never trust a pointer's implied claims.
- **Record what moved.** Update `.claude/context.md` and the relevant `contexts/*.md` for concepts, boundaries, and pointers this change altered. Apply the compression test — *will this improve future engineering decisions?* — and write nothing that fails it.
- **Stay inside the approved design.** A deviation that changes architecture goes back to `/design`, not into the diff.

`/implement` does **not** write vocabulary or ADRs — those crystallise in conversation and belong to `/design` (ADR 0005).

## Acceptance

- `/implement` never runs `git push`.
- A ticket is resolved only after the user says so — never on the skill's own judgement that the work looks finished.
- Post-commit changes amend; they never stack fix-up commits.
- The Marker equals `HEAD` after every commit *and* every amend.
- Implementation detail never lands in context; concepts and boundaries do.
- A change that moves no concept updates no knowledge — silence is the correct output.
- Tests pass and the full suite has been run once before hand-off.

## Comments

**Three of this ticket's own instructions were overridden by things that bind
harder.** Each is a real conflict, not a preference:

1. **Hand-back leaves the ticket `blocked`, not `open`.** This ticket says
   `Status: open`; ticket 03 shipped `blocked` for exactly this case, and the
   reason is decisive — an open ticket with no blocker is back on the frontier,
   so the next `/implement` claims it and walks into the same wall. Ticket 14
   still has to fold `blocked` into its four-state list.
2. **The close-out routes through `/commit`.** This ticket's flow diagram reads
   `commit → resolve → advance Marker`. Ticket 06 line 14 says `/commit` is
   model-invoked *"because `/implement` closes out through it"*, and the
   always-on rule is *"Only `/commit` advances the Marker. Nothing else moves
   it."* `/implement` asks, then hands to `/commit`, then sets `resolved`.
   The acceptance criterion still holds — the Marker equals `HEAD` after every
   commit and every amend — it is just not `/implement` that writes it.
3. **Model-invoked is right; the stated reason is not.** This ticket justifies
   it as *"so `/design` can reach it"*, which ticket 03 explicitly forbids.
   The spec's Scope section is the actual authority, and the caller it is for
   is the router (ticket 10).

**The never-push enumeration and the amend invocations point at
`tools/git.md`** rather than being restated — `git.md` already owns both, and a
third copy is the duplication ADR 0007 exists to stop. What stays here is the
part that is `/implement`'s alone: one ticket stays one commit, and why the
amend rule depends on the push guard.

**The comment and public-API rules were added later, during ticket 05.**
ADR 0007 places them in `/implement` and `/code-review` both, and ticket 05's
review found `/implement` carrying neither. They sit in §2, where code is
written; `/code-review` catches breaches. Noted on ticket 13 so its
distribution pass does not place them a second time.

**The `obsolete` branch landed early, from ticket 14** — `/implement` claiming
a ticket whose work is already done sets the state, gives the reason, and
stops. It is asserted here, so ticket 14 inherits it verified.
