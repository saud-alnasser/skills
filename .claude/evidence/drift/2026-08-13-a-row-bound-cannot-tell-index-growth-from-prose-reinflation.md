---
owner: repository
kind: drift
falsifies: [scripts/verify.ps1]
---

# A row bound cannot tell index growth from prose re-inflation

Checked 2026-08-13 against `4c2b085` plus the working tree, while recording the
`substrate` map's sixth ADR. `crystallize/05`'s assertion failed: *"the review row
loads 65353 chars against a 65000 bound"*.

The assertion's stated purpose is that **"a regression that quietly re-inflates
any row fails here rather than reading as noise."** It fired on neither a
regression nor prose. It fired because six ADRs were written, and `/review`'s row
names `.claude/decisions/map.md`, the generated index over every ADR in the
repository.

Measured at the moment of the failure:

- `.claude/decisions/map.md` — **19,483 chars, 88 rows, 30% of the whole review
  row**, growing at ~220 chars per ADR.
- The bound was set to 65,000 by `crystallize/09`, just above the 61,940 measured
  then.

So the bound is crossed roughly every three ADRs, permanently, by ordinary
knowledge accumulation. Each crossing looks identical to the regression the
assertion exists to catch, and the cheapest response — ratchet and move on — is
also the one that erodes the guard.

**The row cannot be cut, which is what makes this structural.** The protocol's own
norm says a row that cannot be afforded whole is too big and the fix is cutting
it, never restoring selection. But the growing member is the Decisions index, and
`/review` exists in part to judge *whether a change contradicts an accepted ADR* —
the growing part is the part the stage is for. There is no cut available that
leaves the stage able to do its job.

**What this falsifies** is not a norm but the assertion's implicit claim to
measure one thing. A row's total conflates two quantities with opposite
expectations: authored prose, which should not grow, and generated indexes, which
must. A single bound over their sum can only be wrong in one direction or the
other.

The 1.x remedy available is to ratchet, which was done — 65,000 to 68,000, about
twelve ADRs of headroom — with this record so the next reader knows the number
moved for accumulation rather than for a caught regression. **The structural fix
belongs to `substrate`**: under ADR 0084 the Decisions index stops being a file a
stage loads whole and becomes a store a stage queries, at which point a row bound
measures only what someone wrote.

Re-run the check by adding ADRs until the review row's sum crosses its bound, or
by measuring `.claude/decisions/map.md` against the row total in
`scripts/verify.ps1`, ticket `crystallize/05`.

Consumed: `specs.md`, §24 "Quality gates" and `skills/configure/policies/records.template.md`,
"What the build reports" — the split into separate authored and generated figures is this
finding's remedy, made normative. Its objection is answered a second time in
`.claude/decisions/0101-the-boot-tier-is-bounded-because-it-is-the-one-figure-that-multiplies.md`,
which bounds the one figure that conflates nothing. The file this finding names was deleted
with the PowerShell suite, so its check is re-run against the store builder's row figures.
