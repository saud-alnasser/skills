---
status: resolved
---

# feat(skills): the runner writes the closing keyword, in the half its shape puts it

## Outcome

`specify` and `implement` each state which half of the closing keyword they
write, and each reads which half applies from `[[rules/version-control]]` rather
than assuming a shape. Neither version-control rule still says the pull request
body is one a human writes, which stopped being true when the runner started
opening it, and the stacked half names which change carries the keyword rather
than leaving it to be read as every ticket's. The seeded `status: done`
description covers an effort completed without a merge as well as one merged.
An issue closes on its own merge because the keyword was written, not because
somebody remembered.

## Acceptance Criteria

- [x] Criterion 11: `src/skills/specify.md` states that it writes the closing
      keyword into the pull request body where the repository merges a branch
      through a pull request, and `src/skills/implement.md` states that it writes
      the keyword onto the change that merges last where the repository stacks.
      Each cites `[[rules/version-control]]` as what decides which.
- [x] Criterion 11: `verify.mjs` fails if either statement goes missing, and
      fails if either skill names one shape as the only one. Both guards are
      fire-checked — once by removing the statement, once by rewriting it to name
      a single shape — and the subject is confirmed gone before the red is
      believed. Both defeats found in review are reproduced and caught: a second
      paragraph mentioning the keyword, and the governing paragraph naming one
      shape while a neighbour supplies the other.
- [x] Criterion 11: `src/seed/rules/version-control.md` no longer attributes the
      pull request body to a human. Its flat row still puts the keyword in the
      body, because that is correct for that shape; what changes is the claim
      about who writes it.
- [x] Criterion 11: `.aep/rules/version-control.md` carries no such claim either.
      Read rather than asserted — `verify.mjs` covers shipped surfaces, and this
      repository's own rule is not one.
- [x] Requirement 3: `src/seed/labels.json`'s `status: done` description covers
      completion without a merge as well as a merge, and states a trigger true
      for both. Nothing asserts that a description states a trigger — the requirement
      lives in prose, in `[[skills/install]]` and in the seed's own comment — so
      this one is checked by reading.

## Relevant areas

`src/skills/specify.md`, around the effort-opening table's row 5 and the
paragraphs under it that say where the branch is based. `src/skills/implement.md`,
step 3 of the commit procedure, which already routes the ticket reference's form
to the rule. `src/seed/rules/version-control.md`, the two-row table under how work
reaches the default branch. `src/seed/labels.json`. `src/scripts/verify.mjs`,
sections `skills` and `seeds`.

## Constraints

**Neither shape is the default.** A skill that hard-codes the stacking form is
the same defect as one hard-coding the flat form, pointed the other way. The
requirement is that the shape is read, and the guard is written to fail either
hard-coding.

The seeded rule is `owner: repository`. Correcting it changes what a new install
receives and never what an installed repository holds, so nothing here reaches
into a tree that already exists.

Shipped text cites no record that exists only in this repository. The `forbidden`
sweep fails on `specs.md` appearing anywhere in the payload.

## Notes

Independent of every other ticket here, and first in the stack on purpose: the
plan asks for it to be cut early so it is not the one that slips.

The two failures are already recorded and are what this is written against. Pull
request #46 carried `Closes #45` and issue #45 closed itself. Pull request #52
carried `Refs #51` and issue #51 survived its own merge until a person closed it
by hand. Same protocol, different luck.
