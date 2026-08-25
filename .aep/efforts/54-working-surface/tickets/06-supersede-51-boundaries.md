---
status: resolved
---

# fix(efforts): effort 51's two boundaries stop contradicting what 54 builds

## Outcome

`[[efforts/51-branch-scope/spec]]` declines two things this effort delivers. Both
are corrected where they stand, so no effort in the tree declines something
another effort ships.

One is narrowed to what it was actually about. The other is superseded, because
it contradicted `specs.md` section 20 from the day it was written.

## Acceptance Criteria

- [x] The bullet declining "requiring worktrees, or shipping one worktree per
      effort" is narrowed to say what it still covers: scope resolution requires
      no worktree of the runtime and behaves identically without one, reporting a
      weaker claim (requirement 9, criterion 8).
- [x] Its clause calling AEP's own `.aep/worktrees/` unchanged and unrelated is
      corrected, since effort 54 changes exactly that (requirement 9,
      criterion 8).
- [x] The bullet declining "a registry of active sessions, in the position marker
      or anywhere else" is superseded, naming effort 54 and the reason: `sessions`
      is declared in `specs.md` section 20 and the bullet contradicted it
      (requirement 9, criterion 8).
- [x] The superseding text keeps what was right in the original, that a second
      copy of a fact derivable from git goes stale, and says why a session
      identifier is not one (requirement 7, criterion 8).
- [x] No other requirement, criterion, or boundary of effort 51 is edited, and
      its `status: implemented` is unchanged (criterion 8).

## Relevant areas

`.aep/efforts/51-branch-scope/spec.md`, the `# Out of Scope` section only.

## Constraints

Effort 51 is `implemented` and landed. Edit the two bullets and nothing else: a
landed effort is the record of what was reviewed.

Do not delete either bullet outright. A boundary that vanishes reads as one that
was never drawn, and the reason it existed is worth keeping beside the reason it
moved.

This file is repository-owned and inside this run's claim, so no confinement stop
applies (`[[policies/execution]]`).

## Notes

The first bullet was about the runtime's worktrees and was written loosely enough
to catch AEP's own. The second was a genuine error: `specs.md` section 20 has
carried a `sessions` field since it was written, so declining a session registry
"anywhere else" contradicted the specification the effort was amending.

Raised at design time rather than deferred to, per this repository's practice of
superseding a contradicting decision in the change that contradicts it.
