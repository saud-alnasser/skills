---
status: resolved
---

# fix(scripts): an explicit root that is not an AEP root is refused, not ignored

## Outcome

`resolveAepRoot` treats `--root` as an instruction rather than a hint. Where the
directory named does not hold `protocol.md`, the answer is that there is no tree
here, not a quiet fall through to whichever tree the script itself happens to sit
in. A scope read pointed at the wrong place then refuses instead of answering
about something else.

## Acceptance Criteria

- [x] `scope.mjs read --root <a directory holding no protocol.md>` exits 2 and
      says which root it was given, rather than printing a claim (criterion 1).
- [x] The refusal is `resolveAepRoot`'s, so every shipped script inherits it: an
      explicit root that fails the test yields no root at all (criterion 1).
- [x] The suite asserts it, and the assertion was seen to fail against the
      previous behaviour (criterion 11).
- [x] `node src/scripts/verify.mjs` passes and this repository's installed tree
      carries the change (criterion 11).

## Relevant areas

`src/scripts/contract.mjs`, `resolveAepRoot`, whose documented order is an
explicit argument, then the installed position, then `<cwd>/.aep`. The fall
through is the last two running after an explicit argument has already been
given and rejected. `src/scripts/scope.mjs` writes the message a person reads.

## Constraints

- **The fallback order stays exactly as it is when no explicit root is given.**
  This changes one case: an explicit argument that does not resolve.
- Keep returning `null` rather than throwing. Callers report absence, and the
  contract says "no AEP here" and "AEP here with nothing in it" are different
  answers.
- Every fixture in the suite that passes `--root` must still resolve, or the
  change has broken the harness rather than fixed the contract.

## Notes

Found while writing the suite for ticket 07, where a fixture without a
`protocol.md` made twelve assertions answer about this repository while looking
as though they had read the fixture. The same trap caught a sub-agent earlier in
this effort, which reported a branch as unconfined when the script had simply
been pointed at `src/`.

A guard that answers when it cannot read its subject is worse than one that
fails, because the answer is `unscoped`, and `unscoped` means take anything.
