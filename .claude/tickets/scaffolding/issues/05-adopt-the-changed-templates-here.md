---
owner: repository
title: feat(skills): adopt the changed templates here
status: resolved
blocked-by: [01, 02, 03, 04]
part-of: scaffolding
---

## Problem

Tickets 01–04 change what ships; this repository's installed copies under the protocol directory still carry the old text. Ship first, adopt second (ADR 0025): the installed copies move only after the shipped tree is done, so the migration has a before-state to prove against.

## Outcome

This repository's installed tickets, version-control, maps, evidence, and knowledge policies match what the changed templates now install, adapted to this repository's facts — the tracker here is local markdown, so the tracker-facing rule is recorded as vacuous here rather than restated as if it bound.

## Acceptance

- Each installed policy the effort's templates changed carries the corresponding text, adapted to this repository's declared tracker and version-control facts.
- No installed copy contradicts its template on the rules 01–04 introduced.
- The suite passes.

## Comments

The Outcome anticipated adapting the tracker-facing rule as vacuous here. It was **not**
adapted: `tickets`, `maps`, `evidence`, and `knowledge` are copied guides (ADR 0019), so
editing one is the drift that line exists to prevent — and the template's own closing
sentence already says a local-markdown tracker has nothing to bind. Vacuity is
constructional, so copying verbatim discharges the Outcome and the ADR outranks the ticket.
Only `version-control` was adapted, being derived.

Two pre-existing wording divergences between `tickets.template.md` and the installed copy
were left: they predate this effort and carry none of the rules 01–04 introduced.

Review: five findings. Fixed — the decorative "ordinary case here" paragraph cut from
`version-control.md` (its reasoning did not distinguish this repository), the redundant
diff-not-label conjunct dropped so the accepted two-homes reading is not entrenched in a
third place, and the `Get-Installed` helper replaced by the read it wrapped. Reported rather
than fixed — the drift finding this ticket surfaced sits outside the machinery this effort
shipped, in two ways now recorded in the finding itself: the effort has no map to index it
on, and the never-inline exemption reaches a falsified Decision but not a falsified policy
sentence. Both are design gaps; closing either is `/design`'s.
