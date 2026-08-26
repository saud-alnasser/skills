---
status: obsolete
---

# fix(scripts): a refusal recorded for one forge does not answer for another

## Outcome

Declining the merge-time job for one forge leaves the offer standing for a
different one, which is what the recorded decision already tells a human it
means.

## Acceptance Criteria

- [ ] Requirement 6 / criterion 6: a decision recorded naming one forge
      suppresses the offer for that forge
      only. Today `declinedHere()` greps the whole rule for one sentence, so a
      refusal recorded for GitHub silently answers for GitLab as well.
- [ ] The skill's instruction and the installer's read agree about what the
      recorded sentence means. The skill already asks a human to name the forge
      and the date; nothing reads the forge.
- [ ] A fixture records a refusal for one forge, runs the installer for the other,
      and gets the offer.

## Relevant areas

`src/scripts/install.mjs`, `DECLINED` and `declinedHere`. `src/skills/install.md`
step 9. `src/scripts/verify.mjs`, the `install fixture` section.

## Notes

Raised by the correctness review of 2026-08-26, which recorded
`The merge-time status job is declined. GitHub, on 2026-08-26` and then ran
`--automation gitlab`, getting `Declined here already`.

A repository on one forge is the ordinary case, so this is latent rather than
live. It is still a decision being read as answering a question it was not asked,
and the sentinel's own wording invites the narrower reading.

**Read `[[efforts/47-post-merge-labels/plan]]` first**, under *Where a refusal is
recorded*: the sentinel is prose in a file the repository owns, and making it
carry more structure trades against exactly the property that put it in a rule.

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
