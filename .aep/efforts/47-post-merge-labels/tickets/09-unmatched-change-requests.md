---
status: obsolete
---

# fix(scripts): a change request the report is silent about

## Outcome

`reconcile.mjs` says something about every observed change request, so a merged
one that closes no effort is visible rather than absent from the report.

## Acceptance Criteria

- [ ] Requirement 11: an observed change request matched to no effort produces a
      line. Today it
      produces none: `reconcile()` iterates efforts and looks observations up, so
      an object nothing claims is skipped entirely, and the report reads as
      complete.
- [ ] The line does not turn agreement into disagreement for a repository whose
      pull requests legitimately close nothing. Most merged pull requests in this
      repository close no issue and are not efforts, so a finding that moved the
      exit code would report drift on every one of them.
- [ ] Whatever the line says, it is computed and never judged, and the shape it
      takes is stated in the script's own header beside the five already there.

## Relevant areas

`src/scripts/reconcile.mjs`, the loop in `reconcile()`. `src/scripts/verify.mjs`,
the `reconcile` section.

## Notes

Raised by the correctness review of 2026-08-26, which put it this way: a pull
request whose closing keyword is missing is exactly the object requirement 11
exists to surface, and it is the one the report is silent about.

**Why it was not fixed in the wave that found it.** The script cannot tell a
missing keyword from a pull request that legitimately closes nothing, and the
difference is the whole finding. Guessing at that distinction under review
pressure is how a report starts crying wolf, and a drift script nobody trusts is
worse than one that is quiet. The design question is real and it is this ticket.

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
