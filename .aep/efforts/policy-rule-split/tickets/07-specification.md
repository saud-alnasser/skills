---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: policy-rule-split
---

# docs(specs): the specification defines two governance primitives

## Outcome

`specs.md` defines Policy, redefines Rule, reverses the row that retired
policies, and says why the returning concept is not the one that left.

## Acceptance Criteria

- [ ] §3 lists twelve primitives, with Policy answering *what MUST be done,
      protocol-wide* and Rule *what MUST be done here*. *(spec criterion 1)*
- [ ] §4's authority order places policies above rules, and states what a rule may
      and may not do to a policy. *(spec criterion 4)*
- [ ] §5's layout shows `policies/`, and the forbidden-directory sentence no
      longer forbids it — while still forbidding `decisions/`, `tools/`, and a
      mandatory `grill/`.
- [ ] §7's ownership table maps `policies/` to `protocol` and `rules/` to
      `repository`, with no per-file exception. *(spec criterion 3)*
- [ ] §8 admits `kind: policy` and requires `use-when` on policies.
- [ ] §10 splits into policies and rules, naming the four shipped policies and
      what each absorbed, and keeps version-control a seed. *(spec criterion 6)*
- [ ] §28's separation table distinguishes a policy from a rule.
- [ ] §32.2 lists the new assertions the suite owes.
- [ ] §33's Policies row is rewritten rather than deleted, stating that what
      returned is protocol law and what was retired was per-repository derivation.
- [ ] §35's invariants are updated — 20 no longer forbids `policies/`, and new
      invariants cover the directory-owner rule and declared moves.
- [ ] The version at the top reads `2.2.0`.
- [ ] `verify.mjs` asserts Policy appears in the `specs.md` primitives table, so
      the specification and the payload cannot drift on whether the primitive
      exists. *(`[[rules/authoring]]` — the suite moves in the same pass)*

## Relevant areas

`specs.md`, sections 3, 4, 5, 7, 8, 10, 28, 32.2, 33, 35. §31.1 mentions 1.x
policies and stays true — check the wording still reads correctly now that the
word has a second meaning.

## Constraints

- **The retirement is superseded, not quietly reversed.** §33 is the record that
  the concept was tried and dropped; overwriting the row without saying what
  changed loses the reason and invites the next reversal.
- This document is normative and is never installed, so it may cite itself
  freely. Nothing here may be copied into a shipped file.
- Amending the specification is not implementing it. This task changes no
  behaviour and no payload.

## Notes

Independent of every other task by path — nothing else in this effort edits
`specs.md`. Task 08 asserts the shipped surfaces against what this task writes.
