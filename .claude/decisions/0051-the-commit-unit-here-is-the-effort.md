---
status: accepted
load-when: a branch or a commit is about to be created for a ticket
sources: [.claude/policies/version-control.md]
supersedes: []
superseded-by: []
---

# The commit unit in this repository is the effort, not the ticket

AEP's default is one ticket, one branch, one commit, amended. This repository departs from it: a directory under `.claude/tickets/` — its `spec.md` and its `issues/` together — is **one branch and one commit**, and every ticket in the effort amends it. ADR 0008 makes AEP's conventions defaults for when the repository is silent, and this is the repository declining to be silent. The argument is that `main` already demonstrates it: every commit there is one effort, squash-merged from one pull request, so the per-ticket commits existed only on branches and were collapsed on landing — the old convention produced a history shape no reader of the default branch ever saw. The branch is named for the effort, which also removes the collision the per-ticket name carried, since ticket numbers restart at `01` in every effort.

## Considered Options

- **Changing AEP itself** — rejected here as out of proportion rather than wrong. It would supersede ADRs 0044, 0046 and 0047 and remove the second orchestration axis's reason to exist, which is a design effort with its own grill, not an amendment to a policy file.
- **Squashing without recording it** — rejected: the next session reads `.claude/policies/version-control.md`, finds one-ticket-one-commit, and rebuilds a branch per ticket. A convention that lives only in a transcript is not one.
- **Keeping per-ticket branches and squashing at landing** — this is what was already happening, and it is the thing being removed. The squash was real work performed by the maintainer at merge time, and the intermediate shape was visible to nobody afterwards.

## Consequences

**The second orchestration axis does not run here.** A dispatched set lands one commit per ticket on that ticket's own branch, which is precisely what lets a failed sibling leave the rest landed (ADR 0046); with no per-ticket branch there is nowhere for it to land, and "which of the set shipped" stops being answerable from history. The frontier is therefore worked in one branch and no set is dispatched. The first axis is untouched — a fan-out already squashes its portions into one commit, and one commit is what an effort now gets.

**The Claim widens to the effort.** Two instances cannot hold different tickets of one effort. That follows from the unit rather than being a restriction added on top of it.

**It repairs the tracker's declaration.** `.claude/policies/tracker.md` declared a ticket to be tracked intent because work landed without pull requests — a premise `.claude/evidence/drift/2026-08-03-tracked-intent-rests-on-a-falsified-landing-fact.md` recorded as false. The declaration stands and now rests on the unit: the version-control policy ties a ticket to no branch, no commit, and no pull request. The drift finding is evidence and is left as the dated record of the check.

**AEP's shipped surfaces are unchanged** and still state one ticket, one commit. A reader working in this repository is under this file; a reader configuring another repository is under theirs.
