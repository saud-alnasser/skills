---
owner: repository
kind: drift
falsifies: [scripts/verify.ps1]
---

# The suite forbids the map phase its own policy creates

Checked 2026-08-13 against `4c2b085`, while cutting the `substrate` map — the
first map this repository has ever created, though the machinery has shipped
since the `fieldwork` effort.

`.claude/policies/maps.md` sanctions an effort that holds decision tickets and no
spec: a map is reached when the effort cannot be scoped yet, is worked one
decision at a time, and hands back to `/design` step 5 so that *"the tier's
normal deliverable, a spec then tickets, now has something solid to stand on."*
The spec does not exist until the map is done. `.claude/policies/tracker.md`
places both in the effort directory, the map beside the issues.

Two assertions treat that state as a defect:

- `records/03`, *"no effort holds tickets without a spec the index can reach"* —
  fails any effort directory holding `issues/` and no `spec.md`.
- `axis/03`, *"no open ticket is stranded under an implemented spec"* — its
  no-spec branch (`if (-not (Test-Path $spec)) { $stale += ... }`) counts an
  open ticket under a spec-less effort as stranded.

Both were written against efforts that had **landed**. `records/03`'s own comment
names its target: an effort that finished with no spec produces no index row and
the generation succeeds, so the index spans fewer efforts than exist and nothing
says so. `axis/03`'s comment reasons entirely about implemented specs. Neither
considered an effort that has not started, because none existed when they were
written — the map path had never been walked here.

The gap between the two is what makes the fix safe: a **charting** effort has a
`map.md` and open tickets; a **landed** effort has resolved tickets. Exempting
only the first leaves both original catches reachable.

Re-run the check by creating an effort directory holding `map.md` and one open
ticket with no `spec.md`, then running `pwsh -NoProfile -File scripts/verify.ps1`.

Consumed: `scripts/verify.ps1`, `records/03` and `axis/03` — substrate map cut
