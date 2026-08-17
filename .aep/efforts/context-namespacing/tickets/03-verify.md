---
aep: 2.4.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: context-namespacing
blocked-by: [01, 02]
---

# test(verify): the contexts contract is asserted, including that it stays walked

## Outcome

A `contexts` section in `verify.mjs` holds every checkable claim this effort
makes, and each guard has been **observed failing** with its subject confirmed
removed.

## Acceptance Criteria

- [ ] The section asserts the template carries both shapes and the choosing line.
- [ ] It asserts the template states that a nested context still declares
      `paths:` — the directory is not a scope.
- [ ] **It asserts the Contexts section of `index.mjs` is not flat-listed.** This
      is the guard that keeps today's behaviour from being undone by someone
      adding `flat: true` by analogy with `skills/`. Fire-check it by adding the
      flag and watching the failure name it.
- [ ] It drives the **fixture's own** `validate.mjs` over three contexts —
      `a.md`, `a/b.md`, `a/b/c.md` — requiring the first two to pass and the third
      to fail with a message naming the limit. Reuse the existing rejection
      pattern: write the file, run with piped output, require a non-zero exit,
      check the message, **remove the file before anything downstream reads that
      tree**.
- [ ] It asserts no shipped script derives applicability from a context's
      directory.
- [ ] **Every new guard is perturbed**, and for each one the perturbation is
      confirmed to have removed its subject — not something travelling with it.
      Quote one failure in the close-out.
- [ ] `node src/scripts/verify.mjs` passes, and the pass count rises by at least
      the number of assertions added.

## Relevant areas

`src/scripts/verify.mjs` — `section(...)` at ~77, `assert(...)` at ~89, the
`reporting` section added at 2.4.0 as the nearest shape, `installFixture()` at
~168, and the rejection pattern at ~1290 (`validate then rejects it, rather than
the upgrade correcting it`).

## Constraints

- **A green run proves nothing until the perturbation is confirmed to have
  removed the subject** (`[[rules/authoring]]`). The 2.4.0 effort shipped a guard
  that could not fail because it matched a link travelling with the thing it
  checked; the tenth fire-check caught it only because silence was treated as a
  finding rather than a pass.
- Pin phrases that carry meaning, not where a line happened to break. `flat()`
  exists in this file for exactly that.
- Restore the fixture. A file left behind changes what every later assertion in
  that section sees.

## Notes

The `flat: true` guard is a negative — it fails only when someone adds a flag —
so it is the one most likely to be a check that cannot fire. Fire-checking it is
not optional.
