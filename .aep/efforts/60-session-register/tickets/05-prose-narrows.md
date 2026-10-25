---
status: resolved
blocked-by: [01]
---

# feat(skills): prose is for public text only

## Outcome

`skills/prose.md` loads for public text: a README, a docs page, an API
reference, user-interface text, a changelog, a code comment, or a docstring. It
says that session text and agent text take the controlled register instead. Its
catalogue does not change.

## Acceptance Criteria

- [x] Criterion 9: the `use-when` names public text only and does not name a
      pull request body. The opening and the constraints say the same.
      Verified: "skills/prose triggers on public text only", "opens by sending
      session and agent text to plain", and "constrains itself away from
      session and agent text" pass. The use-when names the same seven cases as
      the policy's public row.
- [x] Criterion 9: the `## The catalogue` section is byte-identical to the
      4.0.0 baseline, apart from cross-references.
      Verified: "the prose catalogue is byte-identical to the 4.0.0 release"
      passes, compared against `git show 87adbd0:src/skills/prose.md`.
- [x] The body stays at most 1200 words (it is at 1200 today).
      Verified: `check.mjs` budgets `skills/prose.md` at 1181/1200.
- [x] Criterion 11: `verify.mjs` asserts the narrowed `use-when` and compares
      the catalogue section with the baseline read from git. Each new assertion
      is seen to fail once with its subject removed.
      Verified: 4 of 4 new assertions fired under perturbation (a one-comma
      edit fires the catalogue check). The full suite fails only on stamps
      (expected until 07). The prose adapters were regenerated for the new
      use-when.

## Relevant areas

`src/skills/prose.md`, `src/scripts/verify.mjs`. The `use-when` wording is in
`[[efforts/60-session-register/plan]]`, under Interfaces.

## Constraints

- Do not edit `skills/help.md`: ticket 02 owns it, including the `prose` row.
- The public row of the policy's register table (ticket 01) and this
  `use-when` name the same cases.
