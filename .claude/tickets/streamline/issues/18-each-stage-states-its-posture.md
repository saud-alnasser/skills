# feat(skills): each stage states the tradeoffs it accepts

Status: open
Blocked by: 06
Part of: streamline

## Problem

A stage says what it produces and how it proceeds, and never says what it is willing to give up to get there. The prototype stage is the clearest case: it states that the code is thrown away, and leaves every reader to infer from that whether tests are expected, whether the result has to be optimised, and what counts as finished. Two readers infer differently, and the one who guesses wrong spends a day making throwaway code production-ready.

The same silence runs through the rest of the spine. Where correctness beats speed, and where it does not, is currently carried by tone.

## Outcome

**Shipped behaviour changes; this repository's own configuration does not.**

Each stage of the spine states its posture: the tradeoffs it accepts, the evidence it requires, and what "done" means for it. It is stated in the stage itself, because a posture applies exactly while that stage runs and at no other moment.

The postures differ from each other in ways a reader can compare, so a stage that quietly wants everything — speed and rigour and completeness — is visible as the contradiction it is.

## Acceptance

- Every command in the spine states its posture, in the command itself.
- A posture states what it is willing to give up, not only what it wants; a posture that gives up nothing is not one.
- The postures of two adjacent stages disagree where the stages disagree, and a reader can see which by comparing them.
- No posture is restated in a guide or a rule, and none is derived per repository.
- A stage added later without a posture fails the build rather than shipping with its tradeoffs implied.
- The always-on budget is unchanged by this ticket, and that is asserted rather than assumed.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

`.claude/decisions/0028-a-stages-posture-ships-with-the-stage.md` settles the placement and records why a derived guide and a separate modes directory were both rejected.

This is the ticket most likely to add prose without adding value. The test to apply to each line: does it change what somebody would do differently? "Correctness matters" changes nothing. "The suite is the gate, and a red suite is not a judgement call" changes something.

Blocked by 06 rather than 03 so that the skills are only rewritten once — 06 is already editing every spine command to declare the guides it reads.
