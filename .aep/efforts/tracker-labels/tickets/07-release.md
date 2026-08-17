---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: tracker-labels
blocked-by: [01, 02, 03, 04, 06]
---

# chore(dist): release 2.3.0 and reinstall this repository's tree

## Outcome

The protocol change ships as a release rather than as an edit to one already
published. Every protocol-owned artifact stamps 2.3.0, the changelog records what
changed, the adapter is regenerated, and this repository's own `.aep/` is
reinstalled from the new payload.

## Acceptance Criteria

- [x] `specs.md` declares `**Version:** 2.3.0`.
- [x] **Every** protocol-owned artifact stamps `aep: 2.3.0` — the payload, the
      seeds, and `protocol.md` — because a protocol-owned artifact declaring
      anything else reads as out of date and gets reinstalled.
- [x] `CHANGELOG.md` gains a `## 2.3.0` section saying what changed and why: an
      external task is findable in its own tracker, native mechanism before
      label, and the two forge references rewritten against primary sources.
- [x] `.claude-plugin/plugin.json` version matches.
- [x] `node src/scripts/adapters.mjs` run; the committed adapter is current.
- [x] This repository's `.aep/` reinstalled from `src/`, and
      `node .aep/scripts/index.mjs` regenerated.
- [x] Repository-owned files survive it — `.aep/references/github.md`,
      `rules/authoring.md`, `contexts/repository.md`, and this effort.
- [x] `node src/scripts/verify.mjs` and `node .aep/scripts/validate.mjs` both
      pass.

## Relevant areas

`specs.md` line 3. Every `.md` under `src/` carrying `aep:`. `CHANGELOG.md`.
`src/adapters/claude/.claude-plugin/plugin.json`. There is no stamping script —
the previous release did this as a sweep, and `verify.mjs` fails every artifact
that is missed, one per line, which is the check.

## Constraints

- 2.2.0 is already published. Adding a feature to it silently would make an
  installed 2.2.0 tree disagree with the released 2.2.0 without anything
  detecting it — `/update` compares exactly this field.
- The install must not clobber repository-owned artifacts. If it does, that is a
  defect in the installer, not something to work around here.

## Notes

Last release did the same sweep as its own ticket; that shape held, so it is
repeated rather than redesigned.
