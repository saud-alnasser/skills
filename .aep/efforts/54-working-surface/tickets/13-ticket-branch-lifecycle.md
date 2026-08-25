---
status: resolved
blocked-by: [12]
---

# fix(protocol): a ticket branch is released once its work is in the effort branch

## Outcome

Nothing shipped said what becomes of a ticket branch after the orchestrator
integrates it, so runs leave them behind. This effort left twelve, every commit
of which was already in the effort branch, plus stacking metadata describing
levels that would never be reviewed or merged on their own.

A ticket branch is a build claim. It exists so git refuses a second run the same
ticket, and it holds nothing the moment its work reaches the effort branch. It is
deleted there, in the same step that lands the work.

Folded into this effort at the human's direction, after being raised at the
close.

## Acceptance Criteria

- [x] `policies/execution.md` says a ticket branch is a build claim, released
      when its work reaches the effort branch, and that the effort branch is the
      reviewable unit (requirement 13, criterion 13).
- [x] `skills/implement.md`'s landing step deletes the ticket branch after the
      commit lands on the effort branch, and says why keeping it costs something
      (requirement 13, criterion 13).
- [x] `specs.md` carries it as a numbered requirement, so a conforming
      implementation is judged on it (requirement 11, criterion 13).
- [x] `[[rules/version-control]]` no longer says a ticket branch is a tracked
      stack level, and says why: a branch integrated rather than merged is not a
      level of anything, and this repository allows one pull request per effort
      (requirement 10, criterion 13).
- [x] The suite fails a shipped close that does not release the ticket branch,
      and the assertion has been seen to fail with its subject removed
      (requirement 11, criterion 12).
- [x] This effort itself leaves one branch behind, `working-surface`, verified
      against the clone (requirement 13, criterion 13).
- [x] `node src/scripts/verify.mjs` passes and `node .aep/scripts/validate.mjs`
      reports no failures, with `.aep/` reinstalled from `src/` (requirement 11,
      criterion 12).

## Relevant areas

`src/policies/execution.md` under "Returning, and integrating",
`src/skills/implement.md` under "Landing it", `specs.md` section 19.2 and its
numbered requirement list, `.aep/rules/version-control.md` where ticket 07
answered the tracking question, and `src/scripts/verify.mjs`.

## Constraints

**This reverses part of ticket 07 and says so.** Ticket 07 concluded a ticket
branch is tracked, reasoning that tracking creates no tracker object. That was
right about tracking and wrong about what a ticket branch is: one that is
integrated rather than merged is not a stack level, so tracking it describes a
level nobody will review. Correct it in place rather than leaving two answers.

**Deleting a branch whose work is not integrated is data loss.** The delete
belongs in the landing step, after the commit is on the effort branch, and never
before.

A parked or failed ticket keeps its branch. There is nothing to release, because
nothing was integrated.

## Notes

The alternative, left for the human and not taken here: ticket branches become
separately reviewable, each with its own pull request. That changes
`[[policies/execution]]`'s two-object rule, which a repository rule may tighten
and never soften, so it cannot be reached from the version-control rule alone.

This is the same question as requirement 12, one level down. The run's surface
had a stated lifecycle and the ticket branches it creates did not.
