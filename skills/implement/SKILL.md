---
name: implement
description: Build one ticket end to end — verify, claim, drive tdd at the agreed seams, review, and record what moved. Use when a plan already exists and the work is to build it.
---

# Implement

Mode: implementation
Policies: `.claude/policies/context.md`, `.claude/policies/knowledge.md`, `.claude/policies/tickets.md`, `.claude/policies/tracker.md`, `.claude/policies/version-control.md`

One ticket, built and closed out. `/design` always leaves at least one ticket on disk, so there is always something to read — and `/implement` reads the ticket, not the conversation.

`/implement` **builds what was planned, or it stops.** It never redesigns.

## 0 — Verification. Every invocation. No exceptions.

Open with the verification report. Not conditional on tier, size, or the work looking trivial: this is the command that turns Context into code, so a stale belief here becomes a wrong edit.

The rule and both drift reads live in `.claude/protocol.md`; `.claude/tools/git.md` has the invocations.

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

The report **is** the enforcement: a rule that produces visible output is one whose absence is noticeable.

**Completion criterion:** no source is read through a Source Pointer that has not been verified this session, and no Context statement is acted on before it has been checked against source. A pointer that cannot be recovered by searching is reported — the recovery rule is in `.claude/protocol.md`.

**Never infer an API from a filename**, and never trust what a pointer's path implies. `src/auth/` is where to start reading — not a claim that an auth module exists there, still less that it exposes the function you were about to call.

## 1 — Take one ticket

**One ticket per invocation.** Never take a second, never start a blocked one.

```
frontier = tickets open, unblocked, unclaimed
           lowest number wins — /implement does not choose

  → claim it        create the branch, BEFORE any work
  → build it        tdd at the pre-agreed seams
  → /review    Spec + Standards
  → apply fixes
  → commit          through /commit — no prompt
  → resolve         the Marker advances, and stop

  further changes amend that commit. nothing is pushed.
```

**Where the tickets are comes from `.claude/policies/tracker.md`** — the only place that records which tracker this repository uses. `.claude/policies/tickets.md` has the ticket format and lifecycle; `.claude/tools/github.md` has the invocations. Read the config rather than assuming.

If the frontier is empty, say so rather than inventing work. If everything left is blocked, name what blocks it.

**The frontier is build tickets only.** On a shared tracker an issue triaged to `ready-for-agent` sits right beside a ticket `/design` cut, and it is not one: no outcome, no acceptance criteria, no edges. Say which is missing and route it to `/design`. **Do not fill the gaps in yourself** — inventing an outcome for someone else's issue is designing without the grill, on a surface a team reads.

A ticket whose work turns out to be already done, or no longer needed, is marked `obsolete` with a one-line reason. Stop there — do not manufacture work to fill it.

Work with no ticket at all — hand-written edits, a change made outside this flow — is `/commit`'s.

### The branch is the Claim

**Claiming is creating the ticket's branch, and it is the first act of the run** — before the first read of source, and long before the first edit. A claim made after the first edit is not a claim; it is a report of a race already lost.

Nothing about the Claim is written to the tracker: a tracker carries human-level facts, and which instance is building something right now is not one — see `.claude/policies/tickets.md`.

The branch name is **AEP's own convention**, not the default of whichever tool created the branch, because two tools must produce the same name for the same ticket or the claim stops being a claim:

```
<ticket-id>-<slug-of-the-summary>       17-assignment-and-claim
                                        142-retry-a-failed-payment
```

The id leads so the ticket is recoverable from the name by reading up to the first `-`. Slug from the ticket's summary: lowercase, `-` for spaces, punctuation dropped. Where the repository already has a branch convention, that one wins and `.claude/policies/version-control.md` records it — the detect-before-asserting rule in `CLAUDE.md` applies here as everywhere.

**Check before creating, on both sides.** `.claude/tools/git.md` has the reads:

```
claimed here      a local branch of that name exists
claimed elsewhere the remote has one — fetch first, or the answer is stale
free              neither
```

**A claim held elsewhere is never taken.** Not renamed around, not branched from, not force-created over. Report which ticket, which branch, and where the claim was seen, then move to the next ticket on the frontier. Git refuses to check one branch out in two worktrees, but arriving at that `fatal:` means the check was skipped — treat it as a bug in the run, not a result.

A claim **this clone's own branch identifies** is not someone else's: resume it, or release it by deleting the branch, freely.

### On a stacking repository, blocked means stacked

`Blocked by: 01` means *wait until 01 is resolved* on plain git. Where the repository uses stacked changes it means *stack on top of 01*, and waiting is the thing the tool exists to remove.

**`.claude/policies/version-control.md` states which one applies**, and how to confirm it. Read it and do what it says. Getting the model wrong is expensive in both directions: assume plain git on a stacking repository and the frontier empties — every blocker sits committed-and-unmerged forever; assume stacking on a plain repository and branches get built on unmerged work that was supposed to wait.

**Never substitute a probe for the read** — a fact rediscovered silently is a fact nobody can review, and verifying the file costs the same command the probe was already running.

So, on a stacking repository only:

```
a ticket joins the frontier once its blockers are COMMITTED
                                        not merged, not resolved

  → check out the blocker's branch
  → create this ticket's branch on top of it
     the name is still AEP's, not the one the tool would generate
```

**The Claim's unit becomes the whole stack.** Restacking rewrites every descendant — other tickets' Claims — so **a stack belongs to one instance**: claiming any branch in it claims everything upstack, and parallel instances need separate stacks off trunk. Say this when the stack is created, not when it breaks.

Say the cost too, because it is being accepted on the user's behalf: **a rejected review low in the stack invalidates every branch above it.** That is the trade for not waiting.

Amend through the stacking tool, never with a bare `git commit --amend` — the plain amend leaves every descendant pointing at a commit that no longer exists. `.claude/tools/graphite.md` has the invocation and what it restacks.

The closing keyword also moves, into the commit body, reversing the split that applies to plain git. `/commit` has the rule and the reason.

### Resuming after losing context

An instance that has lost its context reads the branch it is standing on: the branch names the ticket, the ticket says what "done" looks like, and the diff since the branch point says how far it got.

A detached HEAD names no branch and holds no Claim. Do not guess from the diff — claim a ticket properly or hand back.

### Assignment is not this

**Assignment** — which human owns delivering the ticket — lives on the tracker and belongs to them. `/implement` reads it and **never writes it unasked**; if the user asks to take a ticket, `.claude/tools/github.md` has the invocation.

Assignment already separates humans, so the Claim only arbitrates between one person's own instances — which is why a branch is enough.

## 2 — Build

Drive `tdd` at the seams agreed during design. The ticket states an observable outcome; the loop is what proves it. One vertical slice at a time.

Typecheck often, and run the single test file often. Run the **full suite once**, at the end, before handing back. The command for each is in `.claude/tools/` — read it rather than guessing, for the reason `tdd` gives.

**Stay inside the approved design.** A deviation that changes architecture goes back to `/design`, not into the diff.

Three rules about what gets written, applied even where the repository documents none of them (ADR 0007). `/review` checks them; this is where they are obeyed:

- **Prefer self-explanatory code.** Where a block needs extensive explanation to follow, the explanation is evidence about the block: improve the code instead of annotating it.
- **Comments explain *why*, not *what*.** Constraints, tradeoffs, and reasoning are not recoverable from the code; a comment that restates the line below it goes stale on its own schedule.
- **A public interface is documented; private implementation is not.** Anything callers depend on states its contract — what it does, what it requires, how it fails.

Where the new code lands and what it is called is `codebase-design`'s. Read its **Files and names** section and apply it here, while the file is being created — a layout decision is cheap now and a rename touching every caller later.

The rule against guessing an API is in `.claude/rules/engineering.md`, and building is where it costs the most: confirm the **version, signature, and limits** of anything you call before calling it. Code compiles against what is installed, not against what you remember being true.

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

`blocked`, not `open` — an open ticket with no blocker is back on the frontier, and the next `/implement` walks into the same wall.

Release the claim *and* set `blocked`: the status keeps the ticket off the frontier, and deleting the branch stops this clone reporting a Claim on work nobody is doing. Neither alone is enough. The branch goes only because there is nothing on it — where a partial commit exists, keep the branch and say so.

Leave the tree untouched: the partial work is usually the sharper evidence of *why* the plan was wrong, and it is the user's to keep or discard.

A ticket that is merely **harder than expected** is not a wrong plan. Build it.

## 4 — Close out

`/review` runs **both axes**, and its fixes are applied, **before** anything is committed — reviewing afterwards would land work about to be reviewed rather than work that has been.

Then **commit — without asking**: close out through `/commit` — invoke the `commit` skill, never a hand-rolled `git commit` — then set `Status: resolved` and stop. **On a shared tracker, do not resolve** — the merge resolves the ticket there, and `/implement` never closes an issue other people read. `.claude/policies/tickets.md` has why; `.claude/policies/tracker.md` says which kind this repository has.

There is no prompt because there was never a choice: one ticket is one commit and further changes amend it, so "not yet, change this" and "commit, then change this" reach an identical tree. What makes that safe is the push prohibition below — nothing is published, and every effect is locally reversible.

Further changes are requested the same way they always were, in the same context and on the same ticket. They amend.

`/commit` owns the commit itself, the whole-diff knowledge check, and the Marker. **`/implement` never writes the Marker directly** — one writer, so there is one answer to what Context was last verified against. A `/commit` that refuses stops the close-out; it is not worked around, and the ticket stays open.

### Never push. Amend instead.

`/implement` **never runs `git push`.** Publishing is the user's decision, always. The rule is in `.claude/rules/engineering.md`; `.claude/tools/git.md` names the invocations it covers, including the ones that push as a side effect.

That guard is what makes the rest safe: `/implement` **amends** rather than stacking `fix typo` commits, so **one ticket stays one commit** — and amending rewrites history, which is only safe while nothing has been pushed.

Each amend produces a new SHA, so the Marker re-advances on **every amend** — through `/commit`, exactly as the first commit did.

## 5 — Record what moved

Update the **concepts, boundaries, and Source Pointers** this change moved, in `.claude/contexts/repository.md` and the Domain Contexts under `.claude/contexts/`.

`.claude/policies/knowledge.md` says which layers this stage may write, and `.claude/policies/context.md` what belongs in Context at all. Read them rather than deciding here — the row for `/implement` is narrower than it looks, and the two things it excludes are exactly the two that feel most natural to write while holding a finished diff.

---

Core loop derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for AEP.
