---
status: resolved
blocked-by: [03]
---

# feat(seed): the seeded rules and references state their halves

## Outcome

The rule that arrives with a fresh install stops shipping a ticket branch
convention that collides across efforts, and starts saying where a new effort's
branch is based. This repository's own copy of that rule gains the same two
facts, because an upgrade never edits it. The t3 Code reference gains the one
operational line a worktree runtime needs.

## Acceptance Criteria

- [x] The seeded version-control rule names the ticket branch
      `<effort>/<ticket-id>-<slug>` and says why the namespace exists: ticket ids
      restart per effort, so two efforts otherwise want one branch name
      (criterion 8).
- [x] It states where a new effort's branch is based, in both shapes, and ties
      that to the stacking row it already carries (criterion 9).
- [x] `.aep/rules/version-control.md` carries both, corrected against this
      repository's actual history rather than copied from the seed (criteria 8
      and 9).
- [x] The seeded t3 Code reference states that the worktree path must be
      gitignored, and why: an untracked worktree directory enters the position
      fingerprint through `git ls-files --others`, so every thread reads as
      drifted (requirement 11).

## Relevant areas

`src/seed/rules/version-control.md`, sections "Branches" and "How work reaches
the default branch". `src/seed/references/t3code.md`, which already records that
`t3.json` scripts run on worktree creation. `.aep/rules/version-control.md` is
this repository's own, owned by it, and its "Branches" section currently says
`<ticket-id>-<slug>`.

## Constraints

- **A seed is a draft that says it is a draft.** Keep that framing; this adds two
  facts to a starting point, it does not turn the file into law.
- The renaming is **forward-only**. Existing ticket branches keep their names and
  still resolve by content. Say so, so nobody reads the change as an instruction
  to rename live branches.
- `.aep/rules/` is the repository's own file. Edit it directly; it is not
  generated from the seed and reinstalling will not touch it.

## Notes

An upgrade never edits `rules/`, so every repository seeded before this keeps the
old convention. `[[skills/update]]` already reconciles rules against law that
changed under them, and this is one of those changes: it reports and the human
decides.
