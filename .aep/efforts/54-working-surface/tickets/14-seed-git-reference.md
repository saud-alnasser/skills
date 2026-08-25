---
status: resolved
blocked-by: [13]
---

# fix(seed): the shipped git reference carries what this release requires

## Outcome

Ticket 11 updated `.aep/references/git.md`, which is this repository's own copy
and ships nothing. `src/seed/references/git.md` is what a repository installs, and
it still carries the pre-namespacing example and knows nothing about the run's own
surface.

So a repository installing 3.2.0 receives a protocol requiring a worktree and a
reference that has never heard of one. The seed catches up.

## Acceptance Criteria

- [x] The seed's worktree section uses `<effort>/<ticket-id>-<slug>` rather than
      the bare `<task-id>` form (requirement 10, criterion 15).
- [x] It carries creating the effort branch into `.aep/worktrees/<effort>/_run` in
      one act, and why one act (requirement 1, criterion 15).
- [x] It carries detach-then-remove as the release, and where the removal is run
      from (requirement 12, criterion 15).
- [x] It names what git refuses against a held branch, and the two holes
      (requirement 11, criterion 15).
- [x] The suite fails a shipped seed missing any of those, and the assertion has
      been seen to fail with its subject removed (requirement 11, criterion 12).

## Relevant areas

`src/seed/references/git.md`. `.aep/references/git.md` is the worked version to
port from, minus anything specific to this repository.

## Constraints

A seed is a **repository-owned starting point**, installed once and never
overwritten by an upgrade (`[[contexts/repository]]`). It must therefore read as a
sensible default for any repository, so nothing about Graphite or this
repository's stacking belongs in it.

Do not simply copy `.aep/references/git.md`. That file has been edited by this
repository since it was seeded, and the two are allowed to differ.

## Notes

This is ticket 11's criterion unmet on the copy that matters. Found while
auditing what a consumer actually receives, which is a question no assertion in
this effort was asking.
