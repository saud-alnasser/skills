# feat(knowledge): the five evidence kinds declare fields and share one index

Status: open
Blocked by: 05
Part of: declared-fields

## Problem

Contexts and Decisions each declare fields and are reached through an index generated from them (ADR 0053). Evidence has none, and one sentence in its policy governs all five kinds: *read the directory before producing more*. That obligation is exactly the cost an index removes, and it is currently paid by reading directories in full — by the design stage for waiting drift, by research before repeating an investigation, by triage before re-litigating a rejected request.

ADR 0039 records the consequence for drift without flinching: a finding can sit unread until a design run touches its area.

## Outcome

All five kinds declare fields, and evidence gains **one** index at the family root rather than one per kind — ADR 0056 has the reasoning and the consequence that `kind` becomes a real column rather than a restatement of the path.

The field that does the work beyond kind is the healing target: what a finding falsifies. The consumption line stays as it is, so a spent finding is still distinguishable from a waiting one without opening what it falsified.

The account itself is frozen. Nothing about what was checked, when, or against which commit moves — ADR 0034's line on frozen records holds, and the fields are added beside the account rather than inside it.

Templates first, per ADR 0025; the specification's evidence enumeration and layout are amended in the same change, per ADR 0029.

## Design increment

**HITL.** Two questions only the partial build can settle, both changing what ships rather than how:

1. Whether the generated index and a live effort map's `## Drift found` line are two questions or one fact in two homes. Answerable once the index exists in draft and both can be read side by side. If they are one fact, this ticket stops and hands back rather than shipping a second home.
2. Whether existing findings are backfilled with fields, or the index covers only new ones. An index generated from declared fields cannot show a file that declares none — so forward-only leaves exactly the backlog this exists to surface invisible to it, and backfilling touches records ADR 0034 deliberately left alone.

## Acceptance

- Each of the five kinds declares its fields, including `kind`, and the index spans all five.
- The index is produced by the regenerator from ticket 05, never by hand, and the suite's comparison covers it.
- A finding that declares no fields cannot appear in a regeneration.
- The design stage reads the index rather than the directory, and the suite fails if the skill still describes reading the directory whole.
- Both questions in the increment are answered with the user in the exchange — an agent that answers its own has skipped the ticket.
- The two evidence directories that do not yet exist are not created empty; a kind earns its directory when it has a file.
