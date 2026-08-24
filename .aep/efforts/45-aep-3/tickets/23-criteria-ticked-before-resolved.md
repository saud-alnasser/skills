---
status: resolved
---

# feat(implement): a ticket cannot be resolved with a criterion left unticked

## Outcome

`status: resolved` on a ticket means every box under its Acceptance Criteria is
ticked. A resolved ticket carrying an unticked criterion fails validation by
name, the runner states the gate where it marks a ticket resolved, and this
effort's four tickets that were resolved without ticking are verified against the
tree and ticked with what verified them.

## Acceptance Criteria

- [x] Requirement 26: `skills/implement.md` states the gate where the runner
      marks a ticket resolved, and names the two ways out of it — park the ticket
      unresolved, or mark it `obsolete` — so the gate is never met by ticking an
      unverified box.
- [x] Criterion 48: `validate.mjs` fails a resolved ticket with an unticked
      criterion, naming the ticket and how many boxes are open. An `obsolete`
      ticket is exempt, and so is every ticket under an effort whose spec is
      `implemented`.
- [x] The four tickets of this effort resolved without ticking — 01, 02, 03, and
      09 — carry a tick per criterion with the evidence that verified it, or an
      inline correction where the criterion as written does not hold.
- [x] The suite asserts each of the above, and each guard is fire-checked.

## Relevant areas

`src/skills/implement.md` step 4, `src/scripts/validate.mjs` alongside the
traceability walk ticket 22 extended, `src/scripts/verify.mjs`, and
`efforts/aep-3/tickets/01`, `02`, `03`, `09`.

## Constraints

**A landed effort is left exactly as it is.** Eight efforts in this repository
carry `status: implemented` and 47 resolved tickets between them with unticked
boxes, all from before the runner existed. A merged effort's tickets are the
record of what was reviewed, and rewriting them makes the record say something
nobody checked. The exemption is the same one `validate.mjs` already applies to
traceability, for the same reason.

**Ticking is verification, never bookkeeping.** The four tickets here are ticked
against the tree as it stands, each with what verified it. Where a criterion as
written does not hold, the correction is stated inline rather than the box being
ticked over it.

## Notes

Raised by the human alongside ticket 22, and it is the same defect one level
down: a status written without the evidence it claims. Requirements 25 and 26
already say a criterion is ticked at the moment it is verified; nothing said a
ticket may not be resolved while one is not.

The four unticked tickets are 01, 02, 03, and 09 — the earliest built in this
effort, before the runner's own step 4 existed to be followed.

The suite moves in the same pass as whatever this ticket asserts, never at the
end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately
and watch it fail with the right name.

**Built.** The gate sits where the status is written, the check is in
`validate.mjs`, and this effort's four unticked tickets were verified against the
tree and ticked with what verified each one.

**The two ways out are the load-bearing half.** A gate on its own makes ticking
the cheapest way to satisfy it, which converts a verification step into
bookkeeping and loses exactly what the ticks were for. The runner names both
exits — park unresolved, or mark `obsolete` — and says outright that neither is
ticking the box.

**Two exemptions, both already argued elsewhere.** An `obsolete` ticket is exempt
because the spec moved on, and every ticket under an effort whose spec is
`implemented` is exempt because a landed effort is the record of what was
reviewed. That second one is the same exemption `validate.mjs` already applies to
traceability, and it is what keeps eight merged efforts and their 47 resolved
tickets from being rewritten to say something nobody checked.

**One criterion was ticked with a correction rather than a tick.** Ticket 03's
last criterion claims content hashes are unchanged "because the hash already
stripped `aep:` and `date:`". What holds is that identical content hashes
identically. `contentHash` strips `aep:`, `version:`, and `date:` only, so
removing `kind`, `mode`, `report`, `owner`, and `part-of` did move those files'
hashes, deliberately, and `release.mjs` restamped them. Criterion 39 of the spec
carries the same clause; it is a finding, not a gap, and converge does not edit a
spec's body.

**One ticket named an export that does not exist.** Ticket 01 asked for
`PROTOCOL_DIRS` and `PROTOCOL_FILES` in `contract.mjs`. Both are there; the
payload's own directory list ships as `PAYLOAD_DIRS` in `payload.mjs`, which is
the name that criterion meant. Recorded on the tick rather than silently matched.

Five fire-checks, each confirmed to have removed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| the gate sentence removed from step 4 | the runner gates resolved on every criterion being ticked |
| the two ways out removed | the gate names the two ways out, and neither is ticking it |
| what enforces the gate unnamed | the gate says what enforces it, so it is not advice |
| the `validate.mjs` check disabled | a resolved ticket with an unticked criterion fails, and the count is named |
| the `obsolete` exemption removed | an obsolete ticket with an open criterion is exempt, since the spec moved on |
