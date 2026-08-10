---
owner: repository
title: "chore(repo): this repository adopts the crystallized layout and declares its extensions"
status: resolved
blocked-by: [06, 07]
part-of: crystallize
---

## Problem

Templates change before the repository adopts, so after tickets 02–07 land this
repository still runs on the previous shape: unowned installed files, its
repository facts — the effort commit unit, the local tracker, the spec home —
smeared through policy prose, and a context vocabulary without the new terms.

## Outcome

The new configure runs here: framework-owned files installed verbatim and
stamped, this repository's facts declared as extensions, any unprovided-for
variation recorded as a deviation. The repository context gains the effort's
vocabulary — ownership, extension point, deviation, norm form — and the
always-on measurement in the spec's acceptance is taken and recorded.

## Acceptance

- The audit passes here: no framework-owned file diverges from the release, and
  the deviation list is empty or each entry is deliberate with a reason.
- This repository's facts are readable from its extensions alone, and the
  policies that previously carried them carry none.
- The repository context defines the new terms; the suite passes; the
  before/after token measurements are recorded where the spec's acceptance can
  be checked against them.

## Comments

Adoption happened in lockstep as tickets 02–07 landed, so this ticket's own
diff is the vocabulary, the measurements, and the audit-clean assertions.
One bounded exception, recorded rather than stamped over: `CLAUDE.md` declares
no `owner` field — the harness loads it by name, frontmatter behaviour there
is unverified, and guessing it against the never-guess rule was refused. It is
repository-owned by construction (derived, carrying repository sections), and
the census records it as such. Measurements at adoption: always-on tier 9,454
→ 9,450 chars despite three added members; a /design turn ~109,800 → 81,265
(−26%), both live-asserted. The review flagged that the always-on half of the
spec's "materially smaller" acceptance is flat rather than smaller: recorded
as a known tension in the spec's own wording — its Problem statement already
called the tier cheap, and the "roughly half" goal named the stage loads,
which were delivered — held for the user's disposition rather than settled
here.

Amended at the user's direction during the crystallize/09 run: ownership
became universal. Every markdown file under `.claude/` (`position/` excepted
— machine-local and gitignored) and every installable configure surface —
modes, policies, tools, templates — now declares `owner:` in frontmatter;
the generated indexes gain theirs from the regenerator itself, and a
corpus-wide suite guard holds the set. The frozen records gained only the
frontmatter field, no prose. `CLAUDE.md` and its template keep the recorded
exception above. In the same run the router flipped to `owner: framework`
(recorded on ticket 05).
