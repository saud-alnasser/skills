---
status: resolved
---

# feat(policies): the reporting policy states three registers and the controlled register's law

## Outcome

`policies/reporting.md` sorts every text by its reader into three registers
(public, controlled, exempt). It states the core of the controlled register,
the sketch rule, and the option-set rule with its picker fallback. Every other
ticket links to these sections, so they exist first. The hot path stays inside
a budget raised to 4200 words.

## Acceptance Criteria

- [x] Criterion 1: the policy has one `Reader | Register | Worked cases` table
      with the rows of requirement 1, and each worked case is in one row only.
      The `Governed | Exempt` table is gone. Verified: `verify.mjs --section
      reporting` passes "one Reader | Register | Worked cases table", 19 "puts
      ... under" cases, "no worked case sits under two registers", and "the old
      two-column reader table is gone". Rows with the same register were merged
      to fit the budget; every case of requirement 1 is still listed.
- [x] Criterion 3, the policy half: the policy states the order of requirement
      3 (principles, vocabulary, test) and says the 20% never drops a core
      principle. Verified: "the policy states the order" and "the 20% never
      drops a core principle" pass.
- [x] Criterion 4, the policy half: the policy says domain and AEP terms are
      technical names, kept exactly and never counted against adherence.
      Verified: "a domain or AEP term is a technical name" passes.
- [x] Criterion 5: the four prohibitions stay in `protocol.md` only, and the
      policy says they apply to both registers a human reads. Verified: "the
      policy points at the prohibitions rather than restating them" and "the
      prohibitions hold in both registers a human reads" pass.
- [x] Criterion 6, the policy half: the policy states when a sketch is drawn,
      that it is characters in a fenced block in Excalidraw style, and that a
      large structure is split. Verified: the three sketch assertions pass.
- [x] Criterion 8, the policy half: the option-set rule (requirement 7) and the
      picker fallback (requirement 8) are stated in this policy, in one section
      that other files can link to, and nowhere else. Verified: `## Sketches
      and option sets`; "stated in the policy and nowhere else" passes over
      every payload artifact.
- [x] Criterion 11: the reporting section of `verify.mjs` asserts each item
      above; the old `Governed | Exempt`, "loads skills/prose only for human
      documents", and ledger "reads as a person wrote it" assertions move to
      the new wording; `HOT_PATH.budget` is 4200, and its assertion and comment
      say why. Each new assertion is seen to fail once with its subject removed.
      Verified: `node src/scripts/verify.mjs` fails only on "policies/reporting.md
      is stamped for its current content" (expected until 07). 24 of 24 new
      assertions fired under perturbation; the order check first ran SILENT on
      a perturbation that did not change the order, then fired with the steps
      swapped. `check.mjs`: policy 793/800, hot path 4122/4200.

## Relevant areas

`src/policies/reporting.md`, `src/scripts/check.mjs` (`HOT_PATH`),
`src/scripts/verify.mjs` (the `reporting` section, and the hot-path assertion
near its end). The section order and target size are in
`[[efforts/60-session-register/plan]]`, under Interfaces.

## Constraints

- The body stays at most 800 words (`aep check`). If it does not fit, move a
  worked case out, never a MUST.
- Do not link `skills/plain` yet: it does not exist until ticket 02, and an
  unresolved link fails `validate.mjs`. Ticket 02 adds the link.
- The turn report's nine slots, their order, and the ledger's columns do not
  change. Only the sentence about a ledger cell's wording changes.
- No sentence that justifies a rule (`aep check` rejects rationale here). The
  reason goes to `specs.md`, in ticket 06.
- The stamps baseline fails until ticket 07 cuts the release. That failure is
  expected; every other assertion passes.
