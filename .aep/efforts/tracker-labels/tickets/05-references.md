---
status: resolved
---

# docs(references): the forge references carry verified operations

## Outcome

`github.md` and `gitlab.md` say what each tracker actually models, which
operations reach it, where the gaps are, and what the body does and does not do —
every command checked against a primary source rather than recognised by shape.

## Acceptance Criteria

- [x] GitHub: the native table — milestone, issue dependencies, state and close
      reason, issue type — with the verified flags.
- [x] GitHub: the frontier query returning `blockedBy`, so the frontier is
      computed rather than guessed.
- [x] GitHub: the gaps stated — no `gh milestone` command, no `--parent` filter
      on `gh issue list`.
- [x] GitHub: what body text does and does not do, including that `Blocked by
      #123` does nothing at all.
- [x] GitLab: milestone for membership, and the dependency gap stated in both
      halves — `glab` has no issue-link subcommand, and blocks/is-blocked-by is
      Premium and Ultimate.
- [x] GitLab: the description-carried edge is named a hand-maintained convention
      rather than state.
- [x] GitLab: `obsolete` identified as the one fact with no native carrier — the
      single place a derived label is genuinely the answer.
- [x] Both: the label section states that a new label matches the vocabulary
      already there, and is reached only after the native check.
- [x] Both keep `This file is yours`, `owner: repository`, and a `use-when`.
- [x] `node src/scripts/verify.mjs` passes.

## Relevant areas

`src/seed/references/github.md`, `src/seed/references/gitlab.md`, and this
repository's own `.aep/references/github.md`, which is repository-owned and
therefore never refreshed by an upgrade.

## Constraints

- A seeded command the repository does not have is worse than no reference at
  all. Verify before shipping; state a gap rather than guessing a flag.

## Notes

**Resolved during `/plan`, at the human's direction** — *"for github or things
like this simply check the docs and write these into the reference file for this
tool"*. Recorded as a task because it covers real acceptance criteria and the map
of the work would otherwise be missing them, not because it is still to do.

Checked against the `gh` 2.96.0 binary directly and GitLab's own documentation.
One correction fell out of it: the GitLab seed had been shipping
`--description-file`, which is not among `glab issue create`'s documented flags.
