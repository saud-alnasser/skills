---
title: feat(knowledge): the five evidence kinds declare fields and share one index
status: resolved
blocked-by: [05]
part-of: declared-fields
---

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

## Comments

**The declared increment was reached and both questions were answered with the user, at the point the ticket names.** The index was built in draft first — fields on the format, fields on the six existing findings, the regenerator's evidence family — so both questions could be read against a real table rather than a description of one.

- **Two questions, not one fact in two homes.** The index is a repository-wide inventory of every kind, existing whether or not an effort is live; a map's `## Drift found` line is one effort's checklist, scoped to its area, checked off when that effort heals it. They differ in scope, in lifetime, and in what checking one off means. The effort spec's Risks section set exactly this test and the index passes it.
- **All six existing findings are backfilled.** An index generated from declared fields cannot show a file that declares none, so forward-only would have left precisely the backlog it exists to surface invisible to it. The accounts are untouched: every one of the six is `+5/-0`, frontmatter above the H1, ADR 0034's freeze intact.

**A ticket error, harmless but worth naming:** the last acceptance criterion says *"the two evidence directories that do not yet exist"*. There are **three** — `prototypes`, `out-of-scope`, and `discussions`. The assertion is written as *no directory without a finding in it*, so it covers all three and would cover a fourth; the miscount changes nothing.

**What `/review` found, and what happened to it. Two of the findings were reintroducible defects nothing in the suite could see:**

- **A per-kind index could be created by hand and the whole suite passed — fixed.** ADR 0056's *first rejected option*. Both the regenerator and every assertion filter `map.md` out of each kind directory, so an index beneath one was invisible to everything that walks them. Now asserted directly, and confirmed by creating one.
- **The `kind` column could lie — fixed.** A finding declaring `kind: discussions` while sitting in `research/` produced a row that read as one kind and linked to another, with six assertions passing. ADR 0056 rejected inferring kind from the path *precisely* to make the column real, and nothing was keeping it honest. The regenerator now refuses the disagreement and names it.
- **The `/design` guard could not fire — fixed, and it is the fourth of these in this effort.** It was anchored on the old sentence's verb rather than on the subject; review rewrote the step to read the whole directory in different words and both this assertion and `scaffolding/04` stayed green. It anchors on the path now: after this ticket the discovery step has no reason to name the drift directory at all.
- **`specs.md` was never amended, and the ticket's own Outcome requires it — fixed.** *"the specification's evidence enumeration and layout are amended in the same change, per ADR 0029."* I missed it entirely. §21's layout now names the index, and the evidence section states the fields and the one-index width.
- **A comment claimed the scoping half of an assertion was unchanged when I had just widened its pattern — fixed**, along with the dead alternation branch that widening created.
- **Two sentences were second homes and are gone:** a restatement of the freeze inside the new format section, where the rule already lives further down, and a sentence added to `/design` naming the `Consumed:` line, which the next paragraph deliberately delegates to the evidence policy.
- **The format said the two fields are "the only frontmatter it carries" — softened.** That wording forecloses a `consumed` field without any Decision recording the choice, which is the silent-architecture rule. Whether the index should answer *waiting or spent* is a real open question and is left open rather than closed by a sentence.

**One finding accepted rather than fixed, and it is the most interesting.** ADR 0039's recorded cost is that *a finding can sit unread*, and this index cannot say whether one is spent — only what exists and what it falsifies. So `/design` still opens each drift row to read its `Consumed:` line. The ticket's Outcome explicitly says the consumption line stays as it is, so making it a field is a scope change rather than a build decision. Recorded here; graduating it is `/design`'s.

Seven deliberate reintroductions, each caught: a hand edit to the index, the kind column dropped, `/design` returning to the directory in its old words and again in review's new ones, the format dropping `falsifies`, a per-kind index, a kind disagreeing with its directory, and a finding declaring no `falsifies`.

Suite: 1018 passed.
