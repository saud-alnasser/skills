# feat(implement): a failed sibling does not sink the set, and review reaches the child that asked

Status: resolved
Blocked by: 05
Part of: parallel-tickets

## Problem

The build stage says that one child failing stops the whole set and nothing integrates. That is right for portions — a partial set satisfies no acceptance criterion — and wrong for tickets, which the tickets policy requires to be demoable or verifiable on their own. Applied unchanged, it would discard four finished, independently valid tickets because a fifth unrelated one failed.

Review has the same shape problem and a sharper consequence. It currently runs once on the integrated result, which is correct for portions that together form one ticket. For a set, each ticket is its own unit — and reviewing it after it has landed means a finding arrives with nobody left to act on it: the child that wrote the code is finished, and the orchestrator fixing it silently is the orchestrator building a ticket it did not claim to build.

## Outcome

Failure is per ticket. A child that fails, or that stops on a decision it cannot make, leaves its siblings landed; its own ticket returns to the frontier with its worktree kept, so a resumed session continues rather than rebuilding. The run **reports which of the set shipped and which did not**, and why for each that did not — a half-landed set is a new state for this workflow, and a run reporting "done" having landed three of five would be lying.

Review for a set is **brokered**. The child requests it, the orchestrator runs both axes, and the findings go back to the requester, which fixes them and returns again. The child that wrote the code is the one that answers for it, and the orchestrator stays the only party that dispatches. Requests spend the brief's cap, so a child that cannot converge runs out rather than looping.

The portion rule is unchanged and both are stated side by side: for a fan-out, review is the orchestrator's, once, after every portion integrates, because the portions are one ticket and there is no individual result to hand back.

## Acceptance

- A failed or stopped child leaves every sibling's landed work in place.
- The failed ticket returns to the frontier, and its worktree is kept.
- The run names which tickets of the set landed and which did not, with a reason for each that did not.
- A child of a set requests review, and the findings reach that child rather than being applied by the orchestrator.
- A child whose requests exhaust the cap ends as a failed ticket, not as a loop.
- The portion rule — review once, in the parent, after every portion integrates — is unchanged, and the suite asserts both rules coexist without either being stated twice.
- A decision a child stopped on still reaches the human; where it was brokered, the answer returns to the child and the run continues.
- Each guard is confirmed to fail against its removal.
- The suite passes.

## Found at review

**The third round of the same failure, and this time it ended the approach.** Both axes again reversed every rule by *adding* a sentence, and the shared refusal `05` introduced caught none of them — because these reversals were **unconditional and unhedged**. *"A failure ends the run before any sibling integrates."* *"This stage makes the corrections itself, and the child is never resumed."* No `where`, no `plainly`, nothing for a blacklist to see. The spec axis applied five at once and got a clean pass.

Blacklisting has now lost three times, so the test is inverted. `Assert-RuleParagraph` treats a rule's paragraph as the **whole** disposition of its act and requires **every sentence in it** to be one the guard pinned. A reversal is a sentence, so it fails — whatever words it chose. The first cut of this still asked only for sentences *about the act*, with the act given as a pattern; that was still a guess and it leaked twice in one run — *"where two hunks disagree, take the later child's version"* mentions no merge, no mechanism and no record. Any list of topic words is a list I have to have thought of; the sentence count is not.

The targeted refusals stay beside it, and dropping them was itself a mistake caught by re-running the older harness: the whitelist reads whole sentences, so a reversal spliced *into* a pinned sentence — *"…that branch as it stood at dispatch, or any ancestor of it, which counts equally"* — leaves that sentence still matching its pin. Two mechanisms, two shapes of attack.

`05`'s guards moved onto the same mechanism in this change. Leaving them on the one that had just been broken, beside its replacement, was not a defensible place to stop.

**`waiting` had been collapsed into failure.** My paragraph frontiered any child that "stops on something it cannot decide" — and a brokerable question is exactly that, so the case ADR 0049 exists to keep alive was being sent back to the frontier and resumed five paragraphs later. The stage is the only reader of a return, so it is the only place the four outcomes can be told apart; it now dispositions all four, and says what conflating the fourth costs.

**Review was in the wrong place and carried a second home.** ADR 0049 says the findings arrive *"so it can fix them before its ticket lands"*; my paragraph sat after the landing, restack and collision paragraphs, where "fixes them and returns again" is impossible. Moved, with the timing stated. It also reproduced the policy's closing clause — *"at depth one, from the orchestrator, so nothing about the bound moves"* — word for word, and my guard **required** it. Now refused instead.

**Both new `$rulePattern` entries required my own nouns.** *"When one ticket of a set cannot be finished, every other ticket that did finish is still integrated"* matched neither alternation, and *"each member asks for review of its own ticket, and what comes back goes to the one that wrote the code"* evaded both `requests` and `findings`. Widened to the paraphrases a restatement actually reaches for.

Also: the coexistence guard checked the set's side by the fan-out's exact wording, so a paraphrase of the portion rule inside the set's subsection passed; and "goes up" sat next to the vocabulary's `_Avoid_` entry for delegation upward.

## Accepted

**"Report" for the run's account of what landed.** `.claude/contexts/orchestration.md` lists *report* under the Change Record's `_Avoid_`, but that entry is about not calling a change record a report — this is the run's account to the human, and the effort spec uses the same word for it.

**Every rule paragraph now costs a guard update to grow.** That is the mechanism working: a sentence added to a rule without a pattern beside it is exactly what three rounds of review kept slipping through.

## A process note worth keeping

Running four mutation harnesses back to back in one shell left `skills/implement/SKILL.md` mutated — a file lock killed a harness before its `finally` restored the file. The suite caught it on the next run. Harnesses get run one at a time.

## Carried forward, and not this ticket's

ADR 0046 says review happens *"after that ticket lands"*; ADR 0049 says *"before its ticket lands"*. 0049 is later and its whole subject is this, so it governs — but 0046 still reads the other way, and `.claude/policies/decisions.md` has no *amended-by* relationship to record it with. The effort spec already lists that gap as a risk. It needs `/design`.
