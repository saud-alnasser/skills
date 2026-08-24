---
status: resolved
---

# fix(protocol): the payload stops offering a tracker as a home for tickets

## Outcome

Every shipped artifact describes tickets as local files under the effort, with no second home. The bootstrap's primitives paragraph names `plan.md` beside `spec.md` and drops the tracker branch; `/tasks` no longer asks where tickets live; the index script no longer explains its own output as a consequence of an external tracker; and the 2.3.0 notice no longer tells a repository crossing into 3 to record a tracker query for tasks that 3 does not read.

## Acceptance Criteria

- [x] Requirement 5: no shipped artifact offers a tracker as a place tickets may live. `protocol.md`, `skills/tasks.md`, `skills/help.md`, `templates/ticket.template.md`, `scripts/index.mjs`, and the 2.3.0 notice in `scripts/payload.mjs` are each checked.
- [x] Requirement 35: what the tracker does carry, one issue and one pull request, is what those artifacts say it carries.
- [x] `protocol.md` names `plan.md` among an effort's parts and stays inside its byte budget.
- [x] The suite asserts the absence, over the whole payload rather than file by file, so the next artifact to say it fails too.

## Relevant areas

`src/protocol.md` line 33, `src/skills/tasks.md` lines 21 to 28, `src/skills/help.md` line 87, `src/templates/ticket.template.md` line 8, `src/scripts/index.mjs` lines 78, 198, and 206, and the 2.3.0 entry in `src/scripts/payload.mjs`.

## Constraints

`protocol.md` has about 150 bytes of headroom against its 8192-byte budget, so the paragraph has to get shorter rather than longer. The 2.3.0 notice is read by trees crossing that release, so what replaces it must still be true of the crossing it describes.

## Notes

Found by converge, round one. Every one of these predates the ticket that made tickets unconditionally local and none of them was in that ticket's relevant areas, which is exactly the shape of gap the tickets could not have caught: each file is individually consistent with the release it was written for.

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

**Built.** Six artifacts corrected, and one guard that asks the whole payload the question rather than asking each file.

**The guard is the point of this ticket, not the six edits.** Every one of those files was individually consistent with the release it was written for, and none was in the relevant areas of the ticket that made tickets local. A per-file check would have to be remembered; a payload-wide one is what the seventh artifact runs into. It matches the phrases that offer the choice rather than the word `tracker`, which every artifact here still has a reason to use: the tracker carries the effort.

**`scripts/payload.mjs` is exempt, and has to be.** A notice describes what a past release asked for, and 2.3.0 asked for exactly this. Saying it is over means naming it.

**The 2.3.0 notice was reversed rather than deleted.** A 2.x tree crossing into 3 is shown every notice between the two, so leaving it would have this release tell an upgrading repository to record a tracker query that nothing reads. It now says the query is dead, says what the tracker does still carry, and leaves the reference to its owner.

**The bootstrap got shorter while gaining `plan.md`.** It had about 150 bytes of headroom and the paragraph had to name one more artifact; dropping the tracker branch paid for it. 8043 of 8192.

Three fire-checks, each confirmed to have changed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| `help.md` offering optional local tickets again | no shipped artifact offers a tracker as a place tickets may live |
| the bootstrap offering a tracker for tasks again | no shipped artifact offers a tracker as a place tickets may live; the bootstrap names an effort's parts without a second home for its tasks |
| `plan.md` dropped from the bootstrap's list | the bootstrap names an effort's parts without a second home for its tasks |
