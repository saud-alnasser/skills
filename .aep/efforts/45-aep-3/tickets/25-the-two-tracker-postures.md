---
status: resolved
---

# feat(protocol): a tracker makes the issue and the pull request required, and its absence makes the merge the human's

## Outcome

The payload states both postures where today it assumes one. With a tracker, the
issue and the pull request are required and each links to the effort in both
directions; without one, `/specify` makes no tracker call, the run's record is
the branch and the ticket files, and the human merges. The line claiming a
repository with no tracker "loses the projection and nothing else" is corrected,
because it also loses the two objects, the run log's home, and what resume reads.

## Acceptance Criteria

- [x] Requirement 63 and criterion 51: a tracker-backed effort carries exactly
      one issue and one pull request; the effort directory is named for the issue
      number and both bodies name the effort's path.
- [x] A run that finds a tracker and an effort missing either object opens them
      and says so, rather than falling into the no-tracker shape by not asking.
- [x] Requirement 62 and criterion 50: with no tracker, `/specify` ends at a
      branch and a commit with no tracker call, and the close stamps `spec.md` to
      `implemented` and stops — there is no draft to mark ready.
- [x] The runner never merges, in either posture.
- [x] `[[skills/implement]]`'s resume names what it reconstructs from when there
      is no pull request, and every one of those sources already exists.
- [x] `[[policies/execution]]`'s no-tracker sentence no longer claims the
      projection is all that is lost.
- [x] This repository's effort carries both objects, linked to
      `.aep/efforts/45-aep-3/`, with every tracker write shown before it is made.
- [x] The suite asserts both postures, and fires with the right name when either
      is broken.

## Relevant areas

`src/policies/execution.md` — the two-objects table, the labels section's
no-tracker line; `src/skills/specify.md` around the numbered opening steps and
its ask; `src/skills/implement.md` — the close and the resume section;
`src/scripts/verify.mjs`.

## Constraints

**The close's order does not change.** The spec is stamped first and the tracker
touched after (`[[skills/implement]]`, requirement 33). The no-tracker path is
the same close with its second half absent, not a different close.

Opening this repository's issue and pull request is a write to shared data:
propose it with exact strings and ask, and write nothing on a refusal
(`[[policies/execution]]`). The protocol half of this ticket lands whatever the
answer is.

## Notes

Asked for by the human at the close of `aep-3`.

This repository is the instance for both halves: issues are enabled and it has
never opened one across forty-four pull requests, thirty-eight of them merged, so
every effort in it has been half the shape the protocol describes — reachable precisely because
nothing said the two objects were required.

**Built, except the one criterion that is not this session's to meet.**

The payload half is done: `[[policies/execution]]` gains a
`### Where there is no tracker` section with the effort's record laid out as a
table, `[[skills/specify]]` names which posture it is in instead of assuming one,
`[[skills/implement]]` says the close is step 1 alone without a tracker and that
the runner merges in neither shape, and `specs.md` §14.4 states both normatively.
Thirteen guards, four fire-checked.

**The corrected line is the whole finding.** "A repository with no tracker loses
the projection and nothing else" was the sentence that made the posture look
free. It also lost the issue, the pull request, the run log's home, and what
resume reads. The reason a replacement could be written at all is requirement 5:
tickets became local files, so the ticks are already in the repository and the
pull request was projecting them rather than storing them. Before that, the
sentence would have had no honest correction.

**The requiredness is the other half, and it is why the first half was reachable
by accident.** Requirement 6 creates both objects; nothing said they had to
exist. A run that never asked whether there was a tracker landed in the smaller
shape and found nothing contradicting it.

Four fire-checks against the payload, each confirmed to have removed its subject:

| Broken deliberately | Fired |
| --- | --- |
| requiredness softened to "usually opens both" | both tracker objects are required where a tracker exists |
| the old "loses the projection and nothing else" line restored | the policy no longer says the projection is all a tracker-less repository loses |
| the tracker-less close cut from the runner | the runner's close names the tracker-less shape |
| the ticket-files row cut from the record table | the tracker-less run has a durable record, and it is the repository |

Two more against `specs.md`: the REQUIRED clause, and the tracker-less procedure.

**The last criterion was parked and is now met.** Opening a public issue and
pushing a branch is a write to shared data, so every string was shown first and
approved before anything was written (`[[policies/execution]]`). Issue 45 carries
`spec.md` with its 51 criteria as checkboxes; pull request 46 carries the
approach, the 25 tickets, and `Closes #45`; the effort directory renamed to
`45-aep-3` on the human's answer, and both bodies name that path.

**Two facts about this repository that the requirement did not anticipate, both
recorded rather than smoothed over.** Requirement 4 renames the directory before
the first commit so the rename never enters history; this effort predates its own
issue by twenty-seven commits, so the rename is a commit like any other. And the
branch keeps the name `aep-3` it was pushed under rather than following the
directory: renaming a pushed branch to match a directory is a cost the
requirement never asked for, and the branch is the name the merge is read under.

**The first issue this repository has ever opened.** Forty-four pull requests,
thirty-eight of them merged, and no issue until now: the half-shape requirement
63 exists to close was not hypothetical here.
