---
status: obsolete
---

# test(scripts): the marker's shape is pinned to three keys

Obsolete: the assertion `the marker written by the shipped script carries exactly
three keys` in `src/scripts/verify.mjs`, added by effort 54, already pins the key
set to `head,sessions,tree` and fails on a fourth.

## Outcome

An assertion rejects a fourth key in `position/marker.json`. The boundary this
effort is built around, that surface and role are computed and never stored, is
checkable rather than merely stated, so a later change that stores one fails the
suite instead of passing review.

## Acceptance Criteria

- [ ] Criterion 3: `position.mjs read` on a stamped marker returns exactly `tree`,
      `head` and `sessions`, and an assertion rejects a fourth key.

## Relevant areas

`src/scripts/verify.mjs` — the existing marker assertions, which already spawn
`position.mjs` against an install fixture and already round-trip `stamp` through
`read`. `src/scripts/position.mjs` is read, not changed.

## Constraints

- **`position.mjs` does not change.** This ticket adds a guard around behaviour
  that is already correct. A diff touching the script means the ticket was
  misread.
- The assertion is on the key set, not on the values. `sessions` may be empty and
  `tree` or `head` may be null where git could not be read; none of that is what
  this checks.
- Seen to fail first: add a fourth key to the object `stamp` writes, confirm the
  assertion goes red, then remove it.

## Notes

Independent of every other ticket. It gates nothing and nothing gates it, so it
can run in the first wave beside 01 and 02.

Effort 54 already asserts a three-key shape. Check whether that assertion covers
this before adding a second one; if it does, this ticket is `obsolete` with that
assertion named as the reason.
