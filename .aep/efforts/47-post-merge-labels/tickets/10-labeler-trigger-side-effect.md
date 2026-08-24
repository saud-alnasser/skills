---
status: obsolete
---

# fix(skills): the proposed addition gives a host workflow's own jobs a new trigger

## Outcome

Adding the merge-time job to a workflow that already assigns labels does not
change when that workflow's existing jobs run.

## Acceptance Criteria

- [ ] Requirement 7 / criterion 7: the proposal into an existing labeler does not
      silently widen the host
      file's `on:` map for the jobs already in it. `on:` belongs to the file and
      not to the job, so adding `pull_request: types: [closed]` makes every
      existing job in that file run on a pull request closing too.
- [ ] A fixture carrying a labeler with no `if:` on its own job demonstrates the
      behaviour before and after, so the change is asserted rather than reasoned
      about.
- [ ] Where the addition cannot be made without changing the host's triggers, the
      obstacle is named and nothing is proposed, which is the rule the offer
      already follows for a file whose shape cannot take it.

## Relevant areas

`src/scripts/install.mjs`, `obstacleInWorkflow` and the proposal path.
`src/skills/install.md` step 9. `src/scripts/verify.mjs`, the `install fixture`
section.

## Notes

Raised by the correctness review of 2026-08-26, which ran the offer against the
suite's own labeler fixture and read the result: after the paste, the labeler job,
which carries no `if:`, runs on every `pull_request` close. On a fork pull request
the `pull_request` token is read-only and `actions/labeler` fails, breaking a
workflow AEP did not author.

`spec.md` requirement 7's premise, that the ten observed labelers exclude
`closed` from their default types "so the addition contests nothing", is true of
the job and not of the trigger the addition also asks for. The existing guard,
`the proposal carries that guard into the file it joins`, checks the new job's
`if:` and not the host's other jobs.

## Accepted, not fixed, on 2026-08-26

**`obsolete` here means nobody is going to do it under effort 47.** It does not
mean the finding was wrong, and nothing below has been disproved.

The human was given the state of the effort with these four open on the frontier,
and the two ways out: build them, or accept them and close. They chose to close
and merge. `[[skills/review]]` reserves **Accepted** to the human precisely so a
reviewer cannot dispose of its own findings, and this is that outcome exercised.
It is recorded here rather than in the run log alone, because a pull request is
about a diff and this ticket outlives it.

**The defect is still real and now has no owner.** `obsolete` satisfies the
frontier and stops the effort stalling; it creates no follow-up. Whoever wants
this fixed opens an effort for it, and the analysis above is written to be
picked up as-is.
