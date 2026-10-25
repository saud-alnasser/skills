---
status: resolved
blocked-by: [02, 03, 04, 05]
---

# docs(spec): the specification states three registers and supersedes the exempt brief

## Outcome

`specs.md` §15.2 describes what tickets 01 to 05 made true: three registers
chosen by reader, the controlled register for session, review, agent, and new
effort text, and the option-set and sketch rules. The sentence that made a
sub-agent brief exempt is gone, and §35.12 carries the reason for the change in
place of the reason it replaces.

## Acceptance Criteria

- [x] Criterion 10: no sentence in `specs.md` makes a sub-agent brief exempt.
      Verified: "specs.md makes no sub-agent brief exempt" passes over the whole
      document.
- [x] Criterion 10: §35.12 has a heading for the supersession, saying what the
      `readable-output` effort decided and why it changed. The old rationale
      is replaced, not left beside the new one.
      Verified: "§35.12 records the supersession of the exempt brief" and
      "replaces the old exemption rationale rather than keeping it beside the
      new" pass. The ledger and reader-test headings were rewritten, not kept
      beside the new text.
- [x] §15.2 states the three registers and their worked cases in agreement
      with the policy, and keeps "who reads it decides" as the test.
      Verified: "§15.2 states three registers, chosen by who reads it" and
      "puts the brief, the return, and the relayed question under controlled"
      pass; the worked cases match the policy's table.
- [x] §15.2 says the contract assumes no runtime: a sketch is plain text, and
      the picker is used only where the runtime has one.
      Verified: "§15.2 says the contract assumes no runtime for sketches and the
      picker" passes.
- [x] Criterion 11: `verify.mjs` asserts the absence of the exempt-brief
      sentence and the presence of the §35.12 heading. Each new assertion is
      seen to fail once with its subject removed.
      Verified: 6 of 6 new assertions fired under perturbation. The full suite
      fails only on stamps (expected until 07). §15, §28, and §31 were not
      touched by this ticket.

## Relevant areas

`specs.md` §15.2 and §35.12, `src/scripts/verify.mjs`.

## Constraints

- Ticket 02 has already changed §15, §28, and §31. Do not touch them.
- `specs.md` is normative protocol text and stays exempt from the controlled
  register; write it as the sections around it are written.
