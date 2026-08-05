# feat(specs): the specification declares orchestration

Status: resolved
Blocked by: —
Part of: orchestration

## Problem

The specification's multi-agent section describes peer coordination only — assignment, the claim, the branch as the lock. It has no notion of a parent dispatching children, which four shipped skills already do, and no contract for what a child receives or returns. Its harness-binding section states that exactly two things load without a pointer being followed, which is true of a session and silently untrue of a sub-agent: a child inherits that whole tier and none of the conversation. Building on a specification that describes neither would make every later ticket in this effort an amendment, and the framework's own rule is that a change conforms or amends in the same change.

## Outcome

The specification describes orchestration as it will be built: the parent-and-child relationship as distinct from peer coordination, the three artifacts of the contract, the constraint that human authority cannot be delegated downward, and the loading fact that a child inherits the boot tier but not the conversation. The version moves. Everything after this ticket conforms to a document that already describes the system, and no later ticket in this effort amends it again.

## Acceptance

- The multi-agent section covers a parent dispatching children and says how that differs from assignment and claim, without restating either.
- The harness-binding section states what a sub-agent inherits and what it does not, so a reader cannot conclude from it that a child starts bare.
- The section that lists what a policy set covers names the sub-agent contract as one of them.
- The specification names the constraint that a child has no surface on which to ask a human, and what follows from it.
- Each of the five decisions this effort records is referenced from the section it amends.
- The version is bumped and the amendment rule is visibly exercised.
- The suite asserts the specification carries each of the above, each guard confirmed to fail against its removal.
- The suite passes.

## Accepted at review

§20 names only the question tool and plan mode where ADR 0041 withholds four. Accepted: the clause explains why a child has no surface on which to *ask*, and both named tools are asking surfaces — `ScheduleWakeup` and `Workflow` are withheld for unrelated reasons and would read as an enumeration the sentence is not making. Do not re-raise.
