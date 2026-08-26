---
status: resolved
blocked-by: [02]
---

# feat(scripts): the ladder's rows become a value a script can compute with

## Outcome

`contract.mjs` carries the ladder's rows as an exported value beside
`TICKET_STATUSES`, and `verify.mjs` asserts that value equal to the table in
`policies/execution.md` so the two cannot drift. Nothing consumes it yet. The
next ticket does, and could not be written before this one.

## Acceptance Criteria

- [x] Requirement 8: the projection from an effort's `spec.md` `status:` onto a
      `status:` label is an exported value in `src/scripts/contract.mjs`, in the
      shape `TICKET_STATUSES` and `SPEC_STATUSES` already establish.
      `contract.mjs:292` exports `STATUS_LADDER`, six entries, beside those two.
- [x] Criterion 1: `verify.mjs` asserts the exported value and the ladder in
      `policies/execution.md` equal, row for row, and fails when either moves
      without the other. Fire-checked in both directions — edit the table, then
      edit the policy — because a one-directional check passes for half the drift
      it exists to catch.
      Four perturbations, each applied and confirmed applied before the suite ran,
      each reverted after. Value side, `spec` swapped between rows 1 and 4:
      `FAIL the ladder row "the spec is being drafted" projects the spec status it
      states: carries "implemented", and its row says draft`. Value side,
      `changeRequest` swapped between the two terminal rows: `FAIL the ladder row
      "merged" names the state that selects it: carries "closed", and it is the
      merged row`. Policy side, the closed row's issue label moved to
      `status: shipped`: `FAIL contract.mjs carries the ladder row for row: in the
      policy, missing from STATUS_LADDER: closed without merging | status: shipped
      | status: done`. Policy side, the two terminal rows reordered: `FAIL the
      policy and STATUS_LADDER state the rows in the same order: row 5 ...`. The
      first two are the pair the ticket 03 review found uncompared, so they are
      fire-checked by name. A fifth perturbation against `.aep/policies/execution.md`
      passed 74/0 and proved nothing: the section parses `src/`, so that run had
      not perturbed its subject.
- [x] Requirement 8: the terminal row's second input, a change request that
      merged or closed, is in the value as data rather than left to the consumer.
      It is the one row `spec.md` cannot reach, and a consumer that has to know
      that is a consumer that can get it wrong.
      Both terminal rows carry `changeRequest: 'merged'` and `'closed'` with
      `spec: null`; `SELECTS_A_TERMINAL_ROW` in `verify.mjs` fails closed on a
      terminal row it does not know.
- [x] `contract.mjs` already ships to an installed tree, so the value arrives with
      it and nothing is added to the manifest by hand.
      `node src/scripts/manifest.mjs --check` → `the manifest is current`, exit 0,
      with no edit to it in this diff.

## Relevant areas

`src/scripts/contract.mjs`, beside the other exported vocabularies.
`src/scripts/verify.mjs`, the `labels` section, which already parses the ladder's
rows out of the policy and is where the comparison belongs.

## Constraints

**`contract.mjs` is the contract, not the computation.** The projection is a
table here; the function that reads it belongs in the ticket that needs one. A
script's logic living in the contract file is how the contract stops being
readable as one.

## Notes

The plan names this the effort's load-bearing risk: the ladder's rows now live in
two places, and the equality assertion is the only thing holding them together.
Without that assertion this is the effort's worst idea rather than the one
everything else rests on.
