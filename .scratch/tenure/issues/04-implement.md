# feat(implement): build, and record what moved

Status: ready-for-agent
Blocked by: 01

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
