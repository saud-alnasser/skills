---
name: implement
description: Build one ticket end to end — verify, claim, drive tdd at the agreed seams, review, and record what moved. Use when a plan already exists and the work is to build it.
metadata:
  mode: implementation
  policies: [context, knowledge, sub-agents, tickets, tracker, version-control]
---

# Implement

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

**One ticket per invocation, where the invocation named one.** Never take a second, never start a blocked one. Where none was named the unit is a set, computed below rather than chosen here.

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

### The invocation decides the mode

**Named a ticket, the stage builds that one**, and nothing below dispatches anything: one ticket, one claim, one commit, exactly as it has always run. **A named ticket is never joined by others.** The set exists for the invocation that named none, and a stage that answered a named ticket with several would be choosing work it was not given — which is the rule above, breached by the mode rather than by the pick.

**Named nothing, the unit is a set.** The frontier regularly holds several tickets that gate none of each other, and taking them one invocation at a time makes each wait on the one before it for a reason neither ticket states. So the stage computes the **dispatched set** — the frontier tickets that no `Blocked by` edge orders against each other — and works all of it.

Computing a set is not choosing one. The edges were declared by `/design`, and reading a declaration is the opposite of writing one, which is why this does not except the rule above so much as leave it standing. That also fixes the bound: **the set is exactly what the edges permit — never widened, never reordered.** A ticket that looks independent, or that would obviously be fine alongside, is not a member unless the edges say so; no other property of a ticket is consulted, and nothing is added to the ticket format to record one.

**State the plan before creating anything** — which tickets, which role builds them, and the branch each is built on:

```
set from the frontier: 04, 05, 07 — no edge orders them against each other
  role     ticket-builder, one child per ticket
  branches 04-…, 05-…, 07-… — created by this stage, held by this stage
```

**Stated, not gated.** The stage does not stop for approval, for the same reason the close-out below does not prompt before committing — that argument is made there and is not remade here. What is this rule's own is what stating buys: a set in the transcript before it costs anything, rather than one reconstructed afterwards from the branches it left behind.

**Then create every branch in the set — all of them, before the first child is dispatched.** Creating the branch is the claim, so the parent holds the whole set before any of it is worked; the check that a claim is free applies to each, as below. A branch made after its child started is a claim made after the race it existed to win.

**A set of one is a set, and the parent builds it.** Where the frontier leaves a single ticket there is nothing to run alongside, and a child would spend a whole context producing work this instance is already positioned to do.

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

`blocked-by: [01]` means *wait until 01 is resolved* on plain git. Where the repository uses stacked changes it means *stack on top of 01*, and waiting is the thing the tool exists to remove.

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

### A declared increment is reached

A build ticket may carry design increments — decisions only partial code can answer, each declared with its step, question, and type; the declaration lives in `.claude/policies/tickets.md`. Reaching one invokes the design activity **scoped to that increment alone**, never widening:

- **AFK types** (`research`, `task`) resolve inline: answer the question where the build just made it measurable, record the resolution where any design decision lands, and keep building. The answer and the code ship in the same commit.
- **HITL types** (`grilling`, `prototype`) stop the build at the declared step, **holding the claim** — the branch stays, the ticket stays open, and the session hands back naming the increment it stopped at. This is not `blocked`: the plan is right and only the human is absent. A declared stop is a session the human can schedule; a discovered one loses the run.

**`/implement` never invents an increment.** The declaration is the licence, and only `/design` writes one. A decision discovered mid-build undeclared is what it always was — `blocked`, through the hand-back below.

### A fan-out is declared, or there is none

A build ticket may also carry a **fan-out**: the declaration that its work divides, and what each part of it may touch. The shape is `.claude/policies/tickets.md`'s; what a dispatched child is bound by is `.claude/policies/sub-agents.md`'s.

**`/implement` never invents a fan-out.** The declaration is the licence, and only `/design` writes one — why that is so belongs to the format. A ticket with no declaration is built by one instance, not by a split that looked obvious once the code was open.

A ticket that turns out to divide differently than declared is the plan being wrong, and takes the hand-back below. It is **not** re-partitioned in flight: the portions were reviewed before code existed, and a split rewritten mid-build is one nobody saw.

Where a fan-out and an increment needing a human meet, the format states the order and the case it refuses. Reaching such an increment after children are already running is the same event as discovering an undeclared decision.

**Confirm a child's base before integrating anything of its.** The claim must be an ancestor of what the child built on; `.claude/tools/git.md` has the read. `/configure` writes the setting that makes this true, and this check exists because a repository can be configured by hand or by an older version — a setting nobody verified is a setting that is right until it is not.

A child based on anything but the claim is **not integrated**. The refusal **names what it found** — which child, the base it has, and the base it should have had. A generic failure sends the reader into the diff, and the diff is the one place this defect does not show: the child's work is coherent, it is merely coherent with the wrong tree.

### Running one

`.claude/policies/sub-agents.md` says what a child may do and what its two artifacts contain; the declaration says which roles run and what each owns. Neither is repeated below. What follows is only what this stage does with them.

**Dispatch one child per declared role.** Each gets a brief built from the policy's template, composed now rather than carried on the ticket, because only now has anything read the code. Each runs in its own isolated worktree, so no child can reach another's files — and an isolated child's version-control commands fail if they reach the main checkout, so the boundary holds whether or not a brief mentioned it. Where that worktree is based is configuration rather than anything this stage states (ADR 0044), which is why the base is checked above rather than asserted here.

**Say that the claim has widened, as the children are created.** How far it widens is the policy's; what belongs here is that nobody learns of it at the collision that would otherwise be the first sign.

**Integrate from each child's record, not from its branch.** The record names the workspace and what was done in it; taking the branch on trust would leave the declaration's file-ownership half as a comment nothing enforces. Two mismatches stop the **whole** fan-out, and each is reported with the path that caused it:

- a path in the child's diff that its record never declared — **undeclared**
- a path the child was never declared to own — **unowned**

**One ticket is still one commit.** Children's work is squashed in, so a fanned-out ticket is indistinguishable in history from one built alone and the amend that keeps that rule true still applies.

**One child failing stops the whole fan-out** — and so does one child stopping, which is the same event seen from the other side. Nothing is integrated: not the failed or stopped portion, and not its siblings. Together the portions are one ticket, so a partial set of them satisfies no acceptance criterion, and reviewing one would review a ticket nobody built. The surviving children's worktrees stay where they are, holding their work, so a resumed session continues instead of rebuilding; the hand-back names the portion that failed and the decision, if there was one.

**What a child stopped on takes the hand-back below**, exactly as a decision discovered undeclared does — it is the same event, and it has one route out of this stage. The question reaches the human because the hand-back reaches the human; this stage has no other way to dispose of it.

That is also the bound on the inline path above. `research` and `task` increments resolve inline because the parent reached them with a human available; **a question that came back from a child is never one of those**, whatever type it resembles. Answering it here would be this stage deciding on a child's behalf, which is the one thing the isolation was for.

**`/review` runs once, on the integrated result.** Per-child review would review portions nobody ships and would miss the only thing a fan-out newly risks, which is the seam between them.

### Working a set

Everything under the two headings above is a fan-out's. A set is the other axis, and its unit is a whole ticket rather than a portion, so **no rule crosses from there to here without being restated** — the two agree on what a child is and disagree on nearly everything done with one. What `.claude/policies/sub-agents.md` says about a child holds for both and is repeated in neither.

**One child per ticket, in the role the plan named**, briefed from the policy's template exactly as a portion child is, and each working an isolated worktree on the branch this stage already created for its ticket. Nothing here reads a declaration: the members were computed from edges, and a fan-out one of them declares is not this stage's to run.

**A set child's base is checked for equality, and never for ancestry.** The parent created that ticket's branch and handed the child that branch, so the only correct base is **that branch as it stood at dispatch** — with the base chosen rather than inherited there is nothing to weigh, and an ancestor of it is a child that started somewhere else and will land work its ticket's own history cannot explain. **As it stood at dispatch**, because the tip moves: this stage restacks below, and a check against the branch's current tip would refuse a late child for a base that was right when it was given one. `.claude/tools/git.md` has the read, and the refusal names the same three things it names for a portion.

**Check each child's record against that child's diff before anything of its lands**, by the same read a portion's gets and at the bar the policy sets for one. Of the two mismatches named there, one carries over and one has nothing to test: **undeclared** is the same question here, while **unowned** tests a declaration a set never makes. What that second check would have caught arrives instead as a collision, below.

**A record that fails the check stops that ticket, and reaches no further.** The whole fan-out stops because its portions are one ticket between them; here the other members are other tickets, and a manifest nobody could trust says nothing about any of them. So the refusal is per ticket — named with the path that caused it, as a portion's is.

**A set child requests its own review, and the findings come back to it — before that ticket lands.** Review dispatches, so a child cannot run it; the policy has that bound and what a request costs. What belongs to this axis is where the findings go: to the child that wrote the code, which fixes them and returns again. This stage applying them instead would make it the author of a ticket it never claimed, and would leave the party answering for the code the one party that never read it. Reviewing after the commit would be worse still — the child is finished, and there is nobody left to act on a finding.

**Each child's work lands as one commit, on the branch named for its ticket.** Nothing is squashed across children: a fan-out squashes because its portions are one ticket between them, and here each child *is* a ticket and already holds a branch of its own. A ticket built in a set is therefore indistinguishable in history from one built alone — which is what keeps a branch name enough to recover a ticket from.

**Then restack the set in ticket order.** The members were siblings while they ran — that is what let them run at once — and become a stack only once they have landed. Whether there is anything to restack follows from the version-control model step 1 already required reading: where the repository stacks, each landed branch is rebased onto the one before it and the tool guide has the invocation; where it does not, the branches were never stacked and there is nothing to repair.

**Two children writing one path is a collision, and the orchestrator resolves it.** The edges never promised against this — an edge gates work, and says nothing about files — so it is discovered at integration rather than predicted before dispatch. It is resolved rather than refused: the children are finished, and a stage that stopped here would hand back two worktrees and a question.

**The mechanism is the repository's own**, and comes from `.claude/policies/version-control.md`. **This stage names no merge strategy**: one chosen here would be right on the repositories that happened to match it and silently wrong on the rest. What the orchestrator has that no merge tool has is **both change records** — it knows what each child believed it was doing, which is the difference between reconciling two intents and reconciling two hunks.

**Where the intents conflict rather than the text, that is a decision, and this stage does not make it.** Two children that each did what their ticket asked, in ways that cannot both stand, is not a merge problem in disguise. It takes the route every decision this stage cannot make already takes.

**A child that comes back failed or stopped leaves its siblings landed.** The fan-out stops whole because its portions are one ticket between them; a member of a set is verifiable on its own, so discarding four finished tickets over a fifth unrelated one would throw away work nobody found fault with. That ticket returns to the frontier and **its worktree is kept**, so a resumed session continues from where the child got to rather than rebuilding from nothing.

**Of the four outcomes a return names, only two move a ticket backwards.** `done` lands it; `failed` and `stopped` put it back on the frontier; **`waiting` moves nothing at all**, because the child is holding the work while its question is carried. A stage that read the fourth as an ending would re-dispatch a ticket somebody is in the middle of.

**Report which of the set shipped and which did not, and why for each that did not.** Nothing else in this workflow ends with some of its units landed and the rest returned, so a reader has no habit to fall back on here: a run that said *done* having landed three of five would be true about the three and false about the run.

**A child that exhausts its cap on requests ends as a failed ticket.** One that cannot converge therefore runs out rather than looping, and running out is the failure above rather than a state of its own: the ticket goes back to the frontier, the worktree stays.

**What a child stopped on still reaches the human.** A question this stage can carry goes to the human, and the child is resumed with the answer and the run continues. One it cannot carry travels in the report above, and that ticket returns to the frontier like any other that did not land. The human answers either way — neither disposition is this stage answering on a child's behalf.

### A spent worktree is removed

**This rule holds for both axes**, and says so out loud because the two are otherwise kept deliberately apart: a portion's workspace and a whole ticket's are the same kind of thing once the work inside them has landed.

A worktree is **spent when the work it held has landed** — integrated, committed, and therefore recoverable from the branch rather than from the checkout. Remove it then; it holds nothing the branch does not.

**The determination is this stage's and nobody else's.** The harness created the worktree and cannot tell whether the work in it ever reached a branch. The child cannot — it is bound against touching version control, and it is gone by the time the question becomes answerable. Only the party that integrated the work knows the work is safe somewhere else, which is why nothing removes a worktree unless this stage does, and why they otherwise accumulate one per dispatched ticket for the life of the clone.

**What is kept is still kept.** A failed or stopped child's worktree stays, for the reason given above — a resumed session continues from it instead of rebuilding. Removal reaches what has landed, retention reaches what may still be resumed, and neither reaches the other's case.

**Never force it.** `git worktree remove` refuses a worktree that still holds uncommitted or untracked work, and that refusal is a **second opinion on this stage's judgement** rather than an obstacle to it: one that will not come away cleanly is one whose work had not all landed after all. Forcing past it destroys the evidence that the determination was wrong. `.claude/tools/git.md` has the invocations, and what `prune` does not do.

## 3 — When the plan turns out wrong

A plan is wrong when the ticket cannot be built as written: the architecture it assumes is not there, an approach it depends on does not work, or the change crosses a boundary nobody costed.

**Never redesign past it.** Improvising discards the grill, the options the user chose, and the tier that was assessed — and none of that loss is visible in the diff afterwards.

```
→ stop. do not build past the discovery.
→ mark it               status: blocked
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

Then **commit — without asking**: close out through `/commit` — invoke the `commit` skill, never a hand-rolled `git commit` — then set `status: resolved` and stop. **On a shared tracker, do not resolve** — the merge resolves the ticket there, and `/implement` never closes an issue other people read. `.claude/policies/tickets.md` has why; `.claude/policies/tracker.md` says which kind this repository has.

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
