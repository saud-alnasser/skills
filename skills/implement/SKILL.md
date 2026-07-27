---
name: implement
description: Build one ticket end to end — verify, claim, drive tdd at the agreed seams, review, and record what moved. Use when a plan already exists and the work is to build it.
---

# Implement

One ticket, built and closed out. `/design` always leaves at least one ticket on disk, so there is always something to read — and `/implement` reads the ticket, not the conversation.

`/implement` **builds what was planned, or it stops.** It never redesigns.

## 0 — Verification. Every invocation. No exceptions.

Open with the verification report. Not conditional on tier, on size, or on the work looking trivial: this is the command that turns Context into code, so a stale belief here becomes a wrong edit.

The rule and both drift reads live in `CLAUDE.md`; `tools/git.md` has the invocations.

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

Nothing to verify still prints:

```
Verification
  marker a3f91c2, tree clean — nothing has moved
  → context trusted as-is
```

The report **is** the enforcement. A rule that produces visible output is one whose absence is noticeable; a rule that produces nothing is one that quietly stops running.

**Completion criterion:** no source is read through a Source Pointer that has not been verified this session, and no Context statement is acted on before it has been checked against source. A pointer that cannot be recovered by searching is reported — the recovery rule is in `CLAUDE.md`.

**Never infer an API from a filename**, and never trust what a pointer's path implies about what is behind it. `src/auth/` is where to start reading; it is not a claim that an auth module exists there, still less that it exposes the function you were about to call.

## 1 — Take one ticket

**One ticket per invocation.** Never take a second, never start a blocked one.

```
frontier = tickets open, unblocked, unclaimed
           lowest number wins — /implement does not choose

  → claim it        Status: claimed, saved BEFORE any work
  → build it        tdd at the pre-agreed seams
  → /code-review    Spec + Standards
  → apply fixes
  → ASK             "commit and resolve this ticket?"

       yes      commit → resolve → advance the Marker → stop
       not yet  stays claimed. keep refining in place.
```

Setting `Status: claimed` and saving it **before any work** is the whole mechanism that stops two sessions taking the same ticket. Claiming after the first edit is the same as not claiming.

**Where the tickets are, and how claiming is expressed, come from `.claude/tracker.md`** — it is the only place that records which tracker this repository uses. The `Status:` lines above are one tracker's form of the same states; `/design`'s [`TICKETS.md`](../design/TICKETS.md) says which form goes with which tracker, and `tools/github.md` has the invocations. Read the config rather than assuming.

If the frontier is empty, say so rather than inventing work. If everything left is blocked, name what blocks it.

A ticket whose work turns out to be already done, or no longer needed, is marked `obsolete` with a one-line reason. Stop there — do not manufacture work to fill it.

**Resuming.** A claimed ticket with work in progress is picked up ahead of the frontier, as is a ticket the user names. A ticket left claimed by an abandoned session blocks its own frontier slot; say that plainly rather than silently working around it.

Work with no ticket at all — hand-written edits, a change made outside this flow — is `/commit`'s.

## 2 — Build

Drive `tdd` at the seams agreed during design. The ticket states an observable outcome; the loop is what proves it. One vertical slice at a time.

Typecheck often, and run the single test file often. Run the **full suite once**, at the end, before handing back. The command for each is in `.claude/tools/` — read it rather than guessing, for the reason `tdd` gives.

**Stay inside the approved design.** A deviation that changes architecture goes back to `/design`, not into the diff.

Three rules about what gets written, applied even where the repository documents none of them (ADR 0007). `/code-review` checks them; this is where they are obeyed:

- **Prefer self-explanatory code.** The code itself is what the next reader has to understand, and prose beside it is a second thing to keep true. Where a block needs extensive explanation to follow, the explanation is evidence about the block: improve the code instead of annotating it.
- **Comments explain *why*, not *what*.** Constraints, tradeoffs, and the reasoning behind a shape are worth writing down — they are not recoverable from the code. A comment that restates the line below it goes stale on its own schedule and is worth less than the naming it is compensating for.
- **A public interface is documented; private implementation is not.** Anything callers depend on states its contract — what it does, what it requires, how it fails. Documenting the inside as well doubles what has to be kept true.

Where the new code lands and what it is called is `codebase-design`'s. Read its **Files and names** section and apply it here, while the file is being created — a layout decision is cheap now and a rename touching every caller later.

The rule against guessing an API is in `CLAUDE.md`, and building is where it costs the most: confirm the **version, signature, and limits** of anything you call before calling it. Code compiles against what is installed, not against what you remember being true.

## 3 — When the plan turns out wrong

A plan is wrong when the ticket cannot be built as written: the architecture it assumes is not there, an approach it depends on does not work, or the change crosses a boundary nobody costed.

**Never redesign past it.** Improvising discards the grill, the options the user chose, and the tier that was assessed — and none of that loss is visible in the diff afterwards.

```
→ stop. do not build past the discovery.
→ unclaim it            Status: blocked
→ append ## Blocked     what was found, and why the plan
                        cannot proceed as written
→ leave the working tree alone
     no half-commit, no revert of the user's files
→ hand back: this needs /design
```

`blocked`, not `open` — an open ticket with no blocker is back on the frontier, and the next `/implement` claims it and walks into the same wall.

Leave the tree untouched because the partial work is usually the sharper evidence of *why* the plan was wrong — it shows where the plan met reality — and it is the user's to keep or discard.

A ticket that is merely **harder than expected** is not a wrong plan. Build it.

## 4 — Close out

`/code-review` runs **before** the commit question, both axes, and its fixes are applied before the question is asked. Reviewing after the user has approved the commit inverts the order the approval was given in — they approved reviewed work, not work about to be reviewed.

Then **ask**: *commit and resolve this ticket?* `/implement` does not decide that the work is done.

- **yes** — close out through `/commit`, then set `Status: resolved` and stop.
- **not yet** — the ticket stays `claimed` and the loop stays open. Request changes, refine, ask again, in the same context and on the same ticket, for as long as it takes.

`/commit` owns the commit itself, the whole-diff knowledge check, and the Marker. **`/implement` never writes the Marker directly** — one writer, so there is one answer to what Context was last verified against.

### Never push. Amend instead.

`/implement` **never runs `git push`.** Publishing is the user's decision, always. The rule is in `CLAUDE.md`; `tools/git.md` names the invocations it covers, including the ones that push as a side effect.

That guard is what makes the rest safe. Once a commit exists and further changes are asked for, `/implement` **amends** rather than stacking `fix typo` commits, so **one ticket stays one commit**. Amending rewrites history, which is only safe while nothing has been pushed: keep the amend without the push guard and you rewrite published history.

Each amend produces a new SHA, so the Marker re-advances on **every amend**, not only on the first commit — through `/commit`, exactly as the first commit did.

## 5 — Record what moved

`/implement` has the best available view of what just changed, which makes it the right writer for the **concepts, boundaries, and Source Pointers** the change altered. Update `.claude/context.md` and the Domain Contexts under `.claude/contexts/` that this work moved.

What belongs there, and what never does, is in `domain-modeling`'s `CONTEXT-FORMAT.md`. Apply its compression test and write nothing that fails it. **Implementation detail never lands in Context** — a walkthrough of how the new code works is stale by the next commit, and nothing points at it.

**A change that moves no concept updates no knowledge.** Silence is the correct output; writing something anyway to look thorough is how a context file turns into sediment.

`/implement` does **not** write vocabulary or ADRs. Those crystallise in conversation, and that conversation belongs to `/design`.

---

Core loop derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
