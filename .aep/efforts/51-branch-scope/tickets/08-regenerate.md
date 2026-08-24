---
status: resolved
blocked-by: [07]
---

# chore(dist): release 3.1.0, and this repository reinstalls its own tree

## Outcome

The generated surfaces match the payload they are generated from, the release
baseline describes the files this effort changed, and this repository's own
`.aep/` is the installation of the `src/` it now ships rather than of the one it
shipped yesterday. Nothing in this ticket is hand-written except the changelog.

## Acceptance Criteria

- [x] `node src/scripts/release.mjs 3.1.0` has been run: the version of record,
      the stamps baseline, the plugin manifest, and the adapter all move in that
      one command (criterion 11). A minor bump, for a new shipped script and a
      widened normative contract with nothing removed.
- [x] `CHANGELOG.md` carries the entry, written for a human reader
      (`[[policies/reporting]]`), including the notice a changed branch
      convention owes a repository that seeded the old one (criterion 11).
- [x] The committed adapters are current, which `verify.mjs` asserts by failing
      on a stale one (criterion 11).
- [x] `node src/scripts/manifest.mjs --check` exits 0, so `contract.mjs`'s
      generated block lists `scope.mjs` (criterion 11).
- [x] This repository's `.aep/` has been reinstalled from `src/`, and
      `node .aep/scripts/validate.mjs` reports no failure this effort introduced
      (criterion 11).
- [x] `node .aep/scripts/index.mjs` has been run and `index.md` is current
      (criterion 11).
- [x] `node src/scripts/verify.mjs` passes on the final tree (criterion 11).

## Relevant areas

`src/scripts/adapters.mjs`, `manifest.mjs`, `install.mjs`, and
`.aep/scripts/index.mjs`. `[[references/build]]` carries the invocations.

## Constraints

- **Every artifact here is generated. Never hand-edit one**, in `src/adapters/`
  or in `contract.mjs`'s generated block. A hand-edit passes review and is
  destroyed by the next regeneration, which is the worst of both.
- **Cut the release, publish nothing.** `release.mjs` writes local files. Pushing
  a tag and publishing a release stay the human's (`[[rules/version-control]]`),
  and this ticket does neither.
- The release was folded in here rather than cut as a ninth ticket, because
  `release.mjs` already does everything this ticket was doing and the suite
  cannot pass without it.
- `validate.mjs` currently reports one pre-existing failure, an empty
  `efforts/47-post-merge-labels/` directory belonging to another effort. Leave it.
  It is outside this effort's claim, which is the rule this effort is building.

## Notes

**A defect the release exposed, and fixed here.** Four assertions in the suite's
`release` section bound 3.0's removal notices to *the newest changelog entry*:
every retired field, every directory it stopped shipping, the commands it
removed, and how a tree is classified. `RETIRED_FIELDS` and `RETIRED_DIRS`
describe what 3.0 stopped accepting, so those checks could only ever have been
about 3.0.0's entry, and bound to the newest one they asked every later release
to repeat a removal it did not make. Cutting 3.1.0 was the first release after
3.0.0, so it was the first to fail them, for being correct. They are now scoped
to the release that made the removals, by a named constant beside them.

Taken rather than raised because the ticket's own criterion is a passing suite
and nothing else could satisfy it. The alternative was a changelog entry
restating 3.0's removals, which would have been false.

The reinstall is what proves the payload change works from the outside: a script
that ships correctly here and not into a fresh tree fails in the install fixture
first, in ticket 07, and in this one second.
