# feat(skills): the policy admits a whole-ticket child, and states the broker contract

Status: resolved
Blocked by: 01
Part of: parallel-tickets

## Problem

`.claude/policies/sub-agents.md` was written for a child working a **portion**: the brief names the files that portion owns, and the change record is the manifest for a diff about to be squashed with its siblings. A child given a whole ticket has no declared file ownership, produces a commit of its own rather than a share of one, and may hold a ticket that declares a fan-out it is not permitted to run.

The deeper gap is that a child cannot run anything that dispatches — `/review` above all, whose two axes are themselves sub-agents. Today that means review happens in the parent after the child has finished, which is too late for the child to act on. The child has no way to ask, and the policy has no way for it to be answered.

None of the policy's prohibitions need to change. A child still claims nothing, commits nothing, and dispatches nobody. What is missing is a bounded way for it to *request* what it may not do, and the certainty that the request channel does not quietly undo the prohibitions.

## Outcome

The policy states that a child is given either a portion of a ticket or a whole one, and what differs: a portion child owns declared files, a ticket child owns its ticket and is bound by that ticket's own acceptance criteria. A ticket child declines a fan-out its ticket declares — the depth bound is the reason, not a judgement about the work — and records that it declined.

It states the **broker contract**. A child may request exactly two things: a capability that requires dispatch, and a question put to the human. The menu is closed and the policy says why it is closed rather than judged case by case — a prohibition survives a menu and does not survive discretion. The orchestrator performs the request and returns the result to the requester, which resumes where it stopped.

A request spends the brief's existing cap, so a child that keeps asking runs out exactly as one that keeps working does. And the return gains a fourth outcome beside done, failed, and stopped: **waiting**, which is a child mid-conversation rather than a child finished.

The reason child-to-child traffic cannot exist is recorded where it can be checked: the sending tool is absent from every shipped role, so the only path is child to orchestrator to child.

## Acceptance

- The policy states that a brief may carry a portion or a whole ticket, and what the unit changes about ownership.
- The policy states that a ticket child declines a declared fan-out, records the decline, and does not divide the work another way.
- The policy names exactly what may be requested, states that anything else is refused without being weighed, and gives the reason the menu is closed.
- The policy states the human chain as child, orchestrator, human, orchestrator, child — and both obligations on the party in the middle: the question reaches the human attributed to a child and a ticket, and the answer returns as the human gave it.
- The policy states that an orchestrator which cannot relay an answer faithfully stops the child rather than reinterpreting for it, and says why paraphrase fails silently.
- The policy states that a request spends the brief's cap, and adds no second budget.
- The return's four outcomes are named, and `waiting` is distinguishable from `stopped` by whatever reads a return.
- The policy states that the sending tool is withheld from shipped roles, and the suite asserts no shipped role carries it.
- A ticket child neither creates nor commits to its branch and does not review its own work unrequested — each pointing at the party that does.
- The prohibitions on claiming, committing, and dispatching are stated exactly once, as they already are, and the suite asserts the new text restated none of them.
- The installed policy carries the same text as the template it ships.
- Each guard is confirmed to fail against its removal, and each rule placed carries a single-home guard confirmed to fail against a reworded restatement.
- The suite passes.

## Found at review

Four criteria were half-delivered and one was not delivered at all. The policy never mentioned the tool a child would need to message anyone — the suite asserted no role carries it, so the guard had no rule to be the second home of. The decline said what a ticket child refuses and not what it then does. The review clause named no party. And the broker section repeated the consent sentence verbatim from the list above it, which is an in-file restatement of a rule the policy already owns.

## The guards were wrong in three ways, and one of them is a pattern

**They matched their own wording.** All six new probes were transcriptions of sentences I had just written — `travels attributed`, `costs what work costs` — and a review restated all six in other words with every one staying green. This is the fourth time in this effort. The comment block forty lines above them in `scripts/verify.ps1` records the same failure from an earlier ticket, in the same file, and it recurred anyway. That is not a lapse of attention; writing a guard immediately after writing the sentence it guards makes the sentence the most available anchor, and availability is what the rule warns about. Something structural is wanted here, and inventing it is `/design`'s.

**They could not tell a rule from its negation.** "The menu is not closed; the orchestrator weighs each request on its merits" satisfied every probe written for "the menu is closed" — presence is symmetric and rules are not. Each affirmative is now paired with an explicit refusal of its inversion.

**They read a table and not the prose beside it.** The menu's two rows survived while "a child may also request that the orchestrator create its branch, and commit on the child's behalf" was added underneath — precisely the widening ADR 0049 names as the thing the closed menu prevents.

Every one of these was proved by a review agent rather than argued, and every one is now killed by the reviewers' own strings, replayed.

## Removed rather than added

The installed-matches-template assertion duplicated `orchestration/08`'s check of the same file against the same template. Dropped; 08 owns it.
