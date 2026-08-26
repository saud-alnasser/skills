---
status: resolved
---

# fix(protocol): the terminal row of the label ladder gets its owners

## Outcome

`policies/execution.md`'s status ladder names, for every row including the
terminal one, what moves the label and what corrects it if that did not happen,
and it reaches the terminal value for a change request closed without merging as
well as one merged. The specification stops forbidding the value the ladder now
requires. A reader holds both documents at once without either being wrong.

## Acceptance Criteria

- [x] Criterion 1: every row of the ladder in `src/policies/execution.md` names
      an owner, and the terminal row names both — the job that fires at merge and
      the reconciliation that corrects it late. `verify.mjs` fails when the
      terminal row names none, fire-checked by stripping the owner and watching
      that assertion, and no other, go red.
- [x] Criterion 2: the specification's prohibition on creating a label for a fact
      the tracker already models is amended so that a `status:` family AEP
      maintains keeps its terminal value, with the reason stated: a family with a
      hole cannot be filtered on, and the value projects the effort's state rather
      than copying the forge's.
- [x] Criterion 2: `verify.mjs`'s `the specification` section asserts the ladder
      against the amended clause rather than the old one, and fails if the
      amended clause goes missing.
- [x] Requirement 3: the ladder reaches the terminal value for a change request
      closed without merging, so an abandoned effort leaves more than a
      `flag: wontfix` behind.
- [x] The existing `the status projection covers every effort state` assertion is
      moved deliberately: it counts rows, and both a new row and a new column
      change what it counts. The new number is the one the ladder now has, and
      the assertion still fails on a missing row.

## Relevant areas

`src/policies/execution.md`, the `What projects onto what` table under
`Labels are markings, never state`. `specs.md`, the clause forbidding a label for
a natively modelled fact. `src/scripts/verify.mjs`, sections `labels` and
`the specification`.

## Constraints

**The amendment narrows a prohibition; it does not remove one.** A label for a
fact the tracker models natively stays forbidden everywhere the family is not one
AEP maintains. An amendment that reads as permission to add labels has changed
something nobody asked to change.

**Shipped text cites no record that exists only in this repository.** The
`forbidden` sweep fails on the string `specs.md` in the payload, so the policy
states its rule rather than pointing at the specification for it.

**Neither owner is a person.** Both are mechanisms, and the row is what every
later ticket in this effort is built against.

## Notes

First of the three the plan forces into order. Nothing downstream can be asserted
until the ladder names owners, because every later check quotes it — and both
normative documents move in this one ticket, or a reader holds two contradicting
claims for the length of the stack.
