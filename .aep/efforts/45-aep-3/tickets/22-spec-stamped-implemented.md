---
status: resolved
---

# feat(implement): the close stamps the spec it just satisfied

## Outcome

When a converge round finds no gap, the runner writes `status: implemented` into
`spec.md` before it finalises the pull request. Converge's prohibition on editing
`spec.md` gains its one carve-out, stated where the prohibition is stated, and a
spec claiming `implemented` while an unresolved ticket sits under it fails
validation by name.

## Acceptance Criteria

- [x] Requirement 33: the stamp is the first of the closing acts in
      `skills/implement.md`, and the label projection table in
      `policies/execution.md` names the spec reaching `implemented` on the row
      where converge found no gap.
- [x] Requirement 33: both statements of "converge never edits `spec.md`" —
      `skills/implement.md` and `policies/execution.md` — carry the carve-out and
      say why `status` is the only field it reaches.
- [x] Criterion 47: `validate.mjs` fails an effort whose spec is `implemented`
      while a ticket under it is `open`, naming the effort and the tickets.
- [x] `policies/artifacts.md`'s `status` row says who writes `implemented` and
      when, since the value has three readers and had no writer.
- [x] The suite asserts each of the above, and each guard is fire-checked.

## Relevant areas

`src/skills/implement.md` lines 232 and 244 to 251, `src/policies/execution.md`
lines 196 to 199 and 435 to 445, `src/policies/artifacts.md` line 139,
`src/scripts/validate.mjs`, and `src/scripts/verify.mjs`.

## Constraints

The carve-out must not weaken what it carves out of. Converge acquiring the
ability to edit `spec.md` is the failure `policies/execution.md` spends a
paragraph on, so the permission is one field by name, never "the frontmatter".

The validation guard runs in the safe direction only. All tickets resolved does
not imply the effort is done — converge may still append — so the check is the
converse: `implemented` with unresolved work under it is a stamp made too early.

## Notes

Raised by the human after converge closed. AEP 2 had no runner and the stamp was
a human act at merge; AEP 3's runner closes the effort itself and inherited every
closing act except this one. Three readers depend on the value: `[[skills/tasks]]`
skips an implemented effort, `[[skills/prune]]` uses it to tell a finished effort
from an abandoned one, and `validate.mjs` stops checking traceability on one.

This repository is the first evidence: eight landed efforts carry
`status: implemented`, all stamped by hand under 2.x, and `aep-3` — the only one
the new runner closed — is still `accepted`.

The suite moves in the same pass as whatever this ticket asserts, never at the
end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately
and watch it fail with the right name.

**Built.** The close gained a first act, and the prohibition it sits inside
gained one carve-out named field by field.

**The carve-out is the delicate part, not the stamp.** `policies/execution.md`
spends a paragraph on why converge editing `spec.md` is the failure mode that
ends a run green, and the permission had to not weaken it. What makes `status`
safe is stated rather than assumed: it is the only field that records a fact
about the work instead of a requirement of it, so writing it cannot narrow what
was asked. The runner carries an explicit "never read this as permission to
touch the frontmatter" beside it.

**The value had three readers and no writer.** `[[skills/tasks]]` skips an
implemented effort, `[[skills/prune]]` uses the status to tell a finished effort
from an abandoned one, and `validate.mjs` stops checking traceability on one.
Under 2.x a human stamped it at merge; the 3.0 runner closes the effort itself
and inherited every closing act except this one, which is why all eight landed
efforts here read `implemented` and `aep-3` did not.

**The validation guard runs one direction only.** Every ticket resolved does not
mean the effort is done, because converge may still append, so the check is the
converse: `implemented` with open work under it is a stamp made ahead of the
work, and it names the tickets.

**One fixture changed with it.** The traceability suite's implemented-effort case
carried an open ticket, which is now its own failure and would have masked the
skip that case exists to prove.

Nine fire-checks, each confirmed to have removed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| the stamp dropped from the close | the close stamps the spec before it touches the pull request |
| the pull request finalised ahead of the stamp | the close stamps the spec before it touches the pull request |
| the frontmatter warning removed | the carve-out is one field by name, in both places the prohibition is |
| the policy stops saying why `status` is exempt | the carve-out says why status cannot narrow what was asked |
| `[[skills/prune]]` dropped from the readers | the close names what reads the stamp, so skipping it is not free |
| the projection row reverted | the projection table names the spec reaching implemented |
| the frontmatter contract row reverted | the frontmatter contract says who writes implemented and when |
| the early-stamp guard unnamed in the runner | the runner names the guard against stamping ahead of the work |
| the `validate.mjs` guard disabled | an implemented spec with an open ticket fails, naming the ticket |
