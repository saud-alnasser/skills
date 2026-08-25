---
status: resolved
blocked-by: [08, 09]
---

# chore(dist): release 3.2.0 and reinstall this repository's tree

## Outcome

The change ships. The version of record moves to 3.2.0, the changelog says what a
consuming repository has to know, and this repository reinstalls its own `.aep/`
so its output matches the `src/` that produced it.

## Acceptance Criteria

- [x] `node src/scripts/release.mjs 3.2.0` stamps the bootstrap and the changelog
      (requirement 11, criterion 12).
- [x] The changelog entry says that a run now takes a worktree where its checkout
      is not isolated, which is a new requirement of every conforming runner
      (requirement 2, criterion 2).
- [x] The changelog says the marker gains `sessions` and that it is a diagnostic
      nothing acts on, and that `--session` is optional so no installed marker
      needs migrating (requirements 5, 6, criterion 5).
- [x] `.aep/` is reinstalled from `src/` and the tree validates
      (criterion 12).
- [x] `node src/scripts/verify.mjs` and `node .aep/scripts/validate.mjs` both
      pass on the finished tree (requirement 11, criterion 12).

## Relevant areas

`src/protocol.md`'s `version:` field, which is the version of record.
`CHANGELOG.md`. `src/scripts/release.mjs` for how a release is cut, and
`[[references/build]]` for the checks that must pass first.

## Constraints

**3.2.0, a minor.** The precedent is 3.1.0, which added a requirement that every
skill operating on an effort consult the scope on entry: a new obligation on
conforming implementations, released as a minor. Nothing existing breaks here.
`--session` is optional, markers are not migrated, and section 18.1's MUST NOT is
unchanged.

Releasing and reinstalling are the run's. **Publishing a release and pushing a
tag are the human's** (`[[rules/version-control]]`).

The changelog is text a human reads, so `[[policies/reporting]]` governs it.

## Notes

`.aep/` is this repository's installed copy of `src/`, so the reinstall is what
makes the protocol this repository runs match the one it just shipped
(`[[contexts/repository]]`).

Worth stating in the changelog: the guarantee is git's and stops at porcelain.
`git update-ref` bypasses it and a second clone ignores it. A reader who believes
the surface is inviolable is worse off than one who knows the two holes.
