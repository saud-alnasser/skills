---
aep: 2.5.1
owner: repository
date: 2026-08-18
kind: ticket
status: open
part-of: runtime-adapters
blocked-by: [05, 08, 10]
---

# chore(release): cut 2.6.0

## Outcome

The release this effort ships exists: every artifact whose content changed is
restamped, the two new seeds enter the baseline, the committed adapters are
regenerated from the released payload, and the suite passes end to end.

## Acceptance Criteria

- [ ] `node src/scripts/release.mjs 2.6.0` runs, and the report names the changed
      artifacts rather than sweeping every file (criterion 9).
- [ ] Both new seed references are in `src/stamps.json`, so the baseline no
      longer fails them as never released (criterion 10).
- [ ] Every committed adapter is current immediately after the release — the run
      regenerates them through `adapters.mjs`, and the currency assertion passes
      without a manual regeneration (criterion 9).
- [ ] `CHANGELOG.md` gains a `## 2.6.0` entry saying what a repository gains and
      what changes for an existing installation: nothing, unless it asks for a
      new adapter.
- [ ] `node src/scripts/verify.mjs` passes with no failures (criterion 10).
- [ ] This repository has installed the release it ships — reinstall `.aep/` from
      `src/` and confirm the tree declares 2.6.0.

## Relevant areas

`src/scripts/release.mjs`, `src/stamps.json`, `specs.md` version line,
`CHANGELOG.md`, `src/adapters/`.

## Constraints

- **Never restamp by hand.** `aep:` is the release an artifact's content last
  changed in, and a sweep destroys the only information the field carries.
- 2.6.0 rather than 2.5.2: this adds shipped surfaces and a CLI capability, and
  removes nothing.

## Notes

`release.mjs` already shells out to `adapters.mjs`, so once the generator
regenerates every committed target the release picks that up with no edit of its
own.
