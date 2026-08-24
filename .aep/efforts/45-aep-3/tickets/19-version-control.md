---
status: resolved
blocked-by: [10]
---

# chore(rules): this repository states what the runner may push

## Outcome

The runner pushes a branch and opens a draft pull request at the start of every effort, which is the first irreversible act AEP performs. This repository’s version-control rule states that permission explicitly instead of forbidding it outright.

## Acceptance Criteria

- [x] Criterion 45: the rule names pushing a branch and opening a draft pull request as permitted for an effort the human opened, stated rather than implied, and nothing else in the not-allowed column moves.
- [x] The rule says why the line moved and what still requires asking: merging, publishing a release, and pushing a tag.
- [x] The stacked-changes sentence is corrected or confirmed against what this repository actually does.

## Relevant areas

`.aep/rules/version-control.md`.

## Constraints

This file is `owner: repository` and is this repository’s alone. It is not shipped, and no seed changes with it.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

## Implementation notes

The permission lives in two places on purpose: a row in the table where the
prohibition is read, and a `## What the runner may push` section that states it
outright. Criterion 45 asks for stated rather than implied, and a table row alone
reads as an exception to a rule rather than as a permission.

**Readying the draft is permitted too**, which criterion 45 does not name but
requirement 33 requires: converge finalises the description and marks the pull
request ready in the same run. Had the rule stopped at `open a draft`, ticket 12
would have built a converge that trips over this repository's own rule at the
last step. Merging stays the human's.

**Right-hand column:** rows 1 and 2 moved because the permission is exactly what
they forbade. Row 3 (`pushing a tag, publishing a release`) is a context line in
the diff, unmoved.

**The stacked-changes sentence was wrong twice.** It read "there is no Graphite
configuration here". `.git/.graphite_repo_config` exists with trunk `main`, and
`gt` 1.8.6 is on PATH. What is true is that nothing has ever been stacked:
`.git/refs/branch-metadata` does not exist, `.git/.graphite_pr_info` holds an
empty `prInfos`, and `git log --merges` is empty against a log of squash merges.
So the flat shape stands and its justification changed from "no tooling" to "no
history". The dependent claim under `## Branches` was corrected with it.

**One overrun, deliberate:** the `2.0` standing exception was removed. Branch
`2.0` exists neither locally nor on `origin`, and the rule instructed a reader to
amend a single commit on it. This run is standing on `aep-3` adding one commit
per ticket, so that was a stale claim being relied on this turn
(`[[policies/authority]]`), not an improvement noticed in passing.
