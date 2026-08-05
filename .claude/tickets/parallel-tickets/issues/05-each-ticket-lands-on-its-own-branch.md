---
title: feat(implement): each ticket lands on its own branch, and collisions are resolved
status: resolved
blocked-by: [04]
part-of: parallel-tickets
---

## Problem

Integration as built squashes every child's work into one commit, because portions of one ticket are one commit. Whole tickets are one commit each, on the branch named for that ticket, so the existing path is not merely insufficient here — it would collapse a set into a single commit and lose the one-ticket-one-branch convention that makes a ticket recoverable from a branch name.

And two tickets that gate neither each other may still write the same file. The declared edges do not say otherwise, and this repository is the example: the orchestration effort's tickets all appended to one file, four of them mutually ungated.

## Outcome

Each child's return is integrated onto its own ticket's branch: the record reconciled against the diff exactly as a portion child's is, then one commit, then the branches restacked in ticket order. One ticket, one commit, one branch — unchanged from a ticket built alone, which is the point.

Where two children wrote the same path, the orchestrator resolves it. The mechanism comes from the version-control policy — a restack conflict on a stacking repository, a rebase or merge on plain git — and is read rather than assumed. What the orchestrator brings that no merge tool has is **both change records**: it knows what each child believed it was doing, which is the difference between resolving two intents and resolving two hunks.

Where the two intents genuinely conflict rather than the text, that is a decision, and it takes the route every decision this stage cannot make already takes.

## Acceptance

- Each landed ticket produces exactly one commit, on the branch named for that ticket.
- The record is reconciled against the child's diff before anything lands, with the same two mismatches named as for a portion.
- After landing, the set is restacked in ticket order.
- A path written by two children is resolved by the orchestrator, and the resolution reads both records.
- Which mechanism resolves it is taken from the version-control policy, and the stage states no merge strategy of its own.
- A conflict of intent rather than text is raised, not resolved, and takes the existing route.
- The child-base check is stated as equality against the branch that ticket was assigned, closing the ancestry question orchestration/05 left open.
- Each guard is confirmed to fail against its removal.
- The suite passes.

## Found at review

**Both axes broke all seven guards again, and my harness had been extended to catch exactly that.** After `04` I added addition-shaped mutations, and they killed everything I threw. The axes threw different words — *integrated anyway*, *fold them into one*, *leave the branches as they stand*, *in practice a three-way merge* — and walked straight past licence arrays keyed to mine. Enumerating vocabulary is the losing half of this game, and it had now lost twice.

What every attack across both tickets shares is a **shape**: a hedge that makes an exception sound self-evident (*plainly*, *obviously*, *in practice*, *as they stand*, *anyway*), or a condition carrying a verb that disposes of the act (*where … may / leave / take / fold / return*). `Assert-NoEscapeHatch` refuses both, once, for every rule in this block — so a rule added later inherits the refusal instead of re-earning it. All fifteen sentences the axes said would pass are now killed.

**One `$rulePattern` entry guarded the wrong file entirely, and my mutation passed for the wrong reason.** Both entries were sentence-scoped with `[^.]`, and every pointer in this workflow is a path with dots in it — so the scope died at `.claude` and the lookahead never reached the policy. `'the collision mechanism…'` matched *nothing* in the file that owns the rule; its single home was an unrelated sentence in `/configure`. The single-home sweep was green, and my planted restatement was killed for making it *two* homes rather than for being a restatement. Both entries are line-scoped now, and each carries a second alternation spelling the subject out, because a faithful restatement says *two children wrote the same path* without using the word.

**ADR 0047's qualifier had been dropped.** It says the base is the branch's tip *as it stood at dispatch*; I wrote *that branch itself*. Since this same subsection restacks, a check against the present tip refuses a late child for a base that was right when it was given one — reintroducing, in the equality form, the inversion `orchestration/05` recorded against the ancestry form. Restored, with the reason.

**What a failed record check does was unowned.** The sub-agent policy routes it here by name; the fan-out answers it; and this subsection's own opening forbids inheriting that answer. `06` covers a failed *child*, not a refused record. Now stated: the refusal is per ticket.

**Two second homes.** *"a file list a set never had"* was the policy's ownership sentence again — the same slip `03` was caught making, and the guard now refuses the phrase outright. And naming the version-control policy for the restack repeated what step 1 already makes the reader do.

## Accepted

**Restacking builds a stack the edges never declared.** The members gate none of each other, so chaining them imports the stack cost — a rejected review low down invalidates everything above. It is what the effort's design chose: siblings while they run, a stack once they land. Kept, and the subsection now says so rather than leaving a reader to infer a dependency that was never declared.

## Carried forward, and not this ticket's

The **fan-out** base check still reads *"the claim must be an ancestor of what the child built on"*, which `orchestration/05` recorded as inverting when the parent commits mid-run and `orchestration/06` explicitly declined as a design decision. A set dissolves the question rather than answering it, so that sentence is still standing and still owned by nobody. It needs `/design`.
