---
name: implement
description: Build one ticket end to end — verify, claim, drive tdd at the agreed seams, review, and record what moved. Use when a plan already exists and the work is to build it.
---

# Implement

One ticket, built and closed out. `/design` always leaves at least one ticket on disk, so there is always something to read — and `/implement` reads the ticket, not the conversation.

`/implement` **builds what was planned, or it stops.** It never redesigns.

## 0 — Verification. Every invocation. No exceptions.

Open with the verification report. Not conditional on tier, on size, or on the work looking trivial: this is the command that turns Context into code, so a stale belief here becomes a wrong edit.

The rule and both drift reads live in `.claude/tenure.md`; `tools/git.md` has the invocations.

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

  → claim it        create the branch, BEFORE any work
  → build it        tdd at the pre-agreed seams
  → /review    Spec + Standards
  → apply fixes
  → ASK             "commit and resolve this ticket?"

       yes      commit → resolve → advance the Marker → stop
       not yet  the branch stays. keep refining in place.
```

**Where the tickets are comes from `.claude/tracker.md`** — it is the only place that records which tracker this repository uses. `/design`'s [`TICKETS.md`](../design/TICKETS.md) has the ticket format and the lifecycle, and `tools/github.md` has the invocations. Read the config rather than assuming.

If the frontier is empty, say so rather than inventing work. If everything left is blocked, name what blocks it.

**The frontier is build tickets only.** On a shared tracker the triage queue and the frontier are the same list, so an issue somebody filed and triaged to `ready-for-agent` sits right beside a ticket `/design` cut. It is not one: it has no outcome, no acceptance criteria, and no edges, and there is nothing to build from. Say which is missing and route it to `/design`, which is what turns an incoming issue into a root ticket. **Do not fill the gaps in yourself** — inventing an outcome for someone else's issue is designing without the grill, on a surface a team reads.

A ticket whose work turns out to be already done, or no longer needed, is marked `obsolete` with a one-line reason. Stop there — do not manufacture work to fill it.

Work with no ticket at all — hand-written edits, a change made outside this flow — is `/commit`'s.

### The branch is the Claim

**Claiming is creating the ticket's branch, and it is the first act of the run** — before the first read of source, and long before the first edit. A claim made after the first edit is not a claim; it is a report of a race already lost.

Nothing about the Claim is written to the tracker. A tracker carries human-level facts, and which instance is building something right now is not one — see [`TICKETS.md`](../design/TICKETS.md) for what the tracker does hold.

The branch name is **Tenure's own convention**, not the default of whichever tool created the branch, because two tools must produce the same name for the same ticket or the claim stops being a claim:

```
<ticket-id>-<slug-of-the-summary>       17-assignment-and-claim
                                        142-retry-a-failed-payment
```

The id leads so the ticket is recoverable from the name by reading up to the first `-`. Slug from the ticket's summary: lowercase, `-` for spaces, punctuation dropped. Where the repository already has a branch convention, that one wins and `.claude/tracker.md` records it — the detect-before-asserting rule in `CLAUDE.md` applies here as everywhere.

**Check before creating, on both sides.** `tools/git.md` has the reads:

```
claimed here      a local branch of that name exists
claimed elsewhere the remote has one — fetch first, or the answer is stale
free              neither
```

**A claim held elsewhere is never taken.** Not renamed around, not branched from, not force-created over. Report which ticket, which branch, and where the claim was seen, then move to the next ticket on the frontier. Git enforces this at the last line of defence — it refuses to check one branch out in two worktrees — but arriving there means the check was skipped, so treat that `fatal:` as a bug in the run, not a result.

A claim **this clone's own branch identifies** is not someone else's: resume it, or release it by deleting the branch, freely.

### On a stacking repository, blocked means stacked

`Blocked by: 01` means *wait until 01 is resolved* on plain git. Where the repository uses stacked changes it means *stack on top of 01*, and waiting is the thing the tool exists to remove.

**Read which one applies off the repository; never guess it.** `tools/graphite.md` has the check, and it is one command. Getting it wrong in either direction is expensive: assume plain git on a stacking repository and the frontier empties, because Tenure commits and never merges, so every blocker sits committed-and-unmerged forever and the tool makes the framework slower than not having it; assume stacking on a plain repository and branches get built on unmerged work that was supposed to wait.

So, on a stacking repository only:

```
a ticket joins the frontier once its blockers are COMMITTED
                                        not merged, not resolved

  → check out the blocker's branch
  → create this ticket's branch on top of it
     the name is still Tenure's, not the one the tool would generate
```

**The Claim's unit becomes the whole stack, not one branch.** Restacking rewrites every descendant, so an instance working a branch low in the stack rewrites the branches above it — which are other tickets' Claims. **A stack belongs to one instance.** Claiming any branch in it claims everything upstack, and parallel instances need separate stacks off trunk. Say this when the stack is created, not when it breaks.

Say the cost too, in the same breath, because it is being accepted on the user's behalf: **a rejected review low in the stack invalidates every branch above it.** That is the trade for not waiting.

Amend through the stacking tool, never with a bare `git commit --amend` — the plain amend leaves every descendant pointing at a commit that no longer exists. `tools/graphite.md` has the invocation and what it restacks.

The closing keyword also moves, into the commit body, reversing the split that applies to plain git. `/commit` has the rule and the reason — `/implement` only has to know that stacking is what selects it.

### Resuming after losing context

An instance that has lost its context reads the branch it is standing on. That is the whole recovery: the current branch names the ticket, the ticket says what "done" looks like, and the diff since the branch point says how far it got.

A detached HEAD names no branch and therefore holds no Claim. Do not guess from the diff what was being built — claim a ticket properly or hand back.

### Assignment is not this

**Assignment** — which human owns delivering the ticket — lives on the tracker and belongs to them. `/implement` reads it and **never writes it unasked**; if the user asks to take a ticket, `tools/github.md` has the invocation.

It matters here for one reason: Assignment already separates humans, so the Claim only ever has to arbitrate between one person's own instances. That is why a branch is enough, and why nothing heavier is needed.

## 2 — Build

Drive `tdd` at the seams agreed during design. The ticket states an observable outcome; the loop is what proves it. One vertical slice at a time.

Typecheck often, and run the single test file often. Run the **full suite once**, at the end, before handing back. The command for each is in `.claude/tools/` — read it rather than guessing, for the reason `tdd` gives.

**Stay inside the approved design.** A deviation that changes architecture goes back to `/design`, not into the diff.

Three rules about what gets written, applied even where the repository documents none of them (ADR 0007). `/review` checks them; this is where they are obeyed:

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
→ mark it               Status: blocked
→ append ## Blocked     what was found, and why the plan
                        cannot proceed as written
→ release the claim     delete the branch, so the tree is
                        not left holding a ticket it cannot build
→ leave the working tree alone
     no half-commit, no revert of the user's files
→ hand back: this needs /design
```

`blocked`, not `open` — an open ticket with no blocker is back on the frontier, and the next `/implement` claims it and walks into the same wall.

Release the claim *and* set `blocked`. The status is what keeps the ticket off the frontier; deleting the branch is what stops this clone reporting a Claim on work nobody is doing. Neither alone is enough, and the branch goes only because there is nothing on it — where a partial commit exists, keep the branch and say so.

Leave the tree untouched because the partial work is usually the sharper evidence of *why* the plan was wrong — it shows where the plan met reality — and it is the user's to keep or discard.

A ticket that is merely **harder than expected** is not a wrong plan. Build it.

## 4 — Close out

`/review` runs **before** the commit question, both axes, and its fixes are applied before the question is asked. Reviewing after the user has approved the commit inverts the order the approval was given in — they approved reviewed work, not work about to be reviewed.

Then **ask**: *commit and resolve this ticket?* `/implement` does not decide that the work is done.

- **yes** — close out through `/commit`, then set `Status: resolved` and stop. **On a shared tracker, do not** — the merge resolves the ticket there, and `/implement` never closes an issue other people read. `TICKETS.md` has why; `.claude/tracker.md` says which kind this repository has.
- **not yet** — the branch stays, so the ticket stays claimed, and the loop stays open. Request changes, refine, ask again, in the same context and on the same ticket, for as long as it takes.

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
