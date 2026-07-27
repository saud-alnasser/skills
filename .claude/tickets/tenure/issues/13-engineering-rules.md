# feat(rules): distribute the engineering rules across the workflow

Status: resolved
Blocked by: —

## Problem

`workflow.md` lines 4229–4598 carry Repository Philosophy, Instruction Precedence, the Truth Hierarchy, and nineteen Engineering Principles. Nothing in tickets 01–12 says where any of it lands, and roughly half of it duplicates the user's global `~/.claude/CLAUDE.md`.

ADR 0007 settles ownership: Tenure owns these rules, the global file is trimmed, and each rule lives where it fires.

## Outcome

**1 — The `CLAUDE.md` template** that `/configure` writes. Always-on, so it stays small:

- Truth hierarchy — Codebase > Context > Decisions. Documentation changes to match reality, never the reverse.
- Verify before claiming — inspect source before any repository-specific claim. Names are not proof.
- The compression test — *will this improve future engineering decisions?* If no, don't store it.
- Claude never silently decides architecture — options, tradeoffs, a recommendation, then the user chooses.
- Instruction precedence: system → developer → user → `CLAUDE.md` → `.claude/context.md` → matching `contexts/*.md` → `CONTRIBUTING.md` → `README.md` → decisions → previous conversation. **`CONTRIBUTING.md` outranks `README.md`** (ADR 0007).
- Repository conventions outrank Tenure's defaults — detect before asserting (ADR 0008).
- Automation never writes repository knowledge. CI may validate; it must not modify `.claude/context.md`, `contexts/*`, or `docs/decisions|research|designs/*`. Those change only through `/design`, `/implement`, and `/configure`.
- Context is verified where it is used and healed where the break is found (ticket 02). This must be in `CLAUDE.md`, not in a skill — it has to hold on turns where no skill runs, which is most turns.
- **The cold-request path.** Most requests arrive without a command typed, and the compounding claim does not survive being opt-in. For a request that would **change code** — not for a question — `CLAUDE.md` requires: the Marker check, routing to the matching contexts, verifying what is relied on, and naming the classification out loud with a note that `/design` would grill it. Capture still happens: a concept that moves gets written. A question gets context loading and nothing else — no classification, no ceremony.
- Routing to `.claude/context.md`.

**2 — Rules inside the skills that enforce them:**

| Rule | Skill |
| --- | --- |
| Never guess APIs — verify version, signature, limits before use | `/research`, `/implement` |
| One concept per file · directories over verbose filenames · clear naming | `codebase-design`, `/implement` |
| Self-explanatory code · comments explain *why* · document public APIs | `/implement`, `/code-review` |
| Test layout matches repo convention; no unnecessary test structure | `tdd` |
| Root-cause over workaround; a required workaround records why, alternatives, and removal conditions | `/design` |

**3 — `.claude/rules/`** for standards `/configure` discovers in the repository, path-scoped where they apply to part of the tree.

**Cut:** "architecture over convenience" and "leave the repository better" — neither is checkable, both are no-ops against the model's default. Reinstate only if made concrete.

**Not restated:** "context provides orientation", "decisions preserve reasoning", "knowledge has layers" are definitions and live in `context.md`'s glossary. "Synchronize understanding" and "scale process with risk" are embodied by the verification discipline and the tier gates.

## Acceptance

- Every one of the nineteen principles is accounted for — placed, cut, or identified as embodied elsewhere. None silently dropped.
- No rule appears in two homes.
- The `CLAUDE.md` template is under 200 lines with routing included.
- A rule that must hold unconditionally is in `CLAUDE.md`, not in a skill — a rule inside a skill only fires when that skill runs.

## Comments

**One row landed early, in ticket 05.** The *"self-explanatory code · comments
explain why · document public APIs"* row places its rules in `/implement` and
`/code-review`, and both halves are now placed: `/implement` §2 writes to them,
`/code-review`'s Standards axis catches a breach. ADR 0007 authorises the pair —
they are a producer and its checker, not one rule stated twice, and each is
worded for its own action. Both are asserted in `verify.ps1`. **Do not place
either again**; no rule in two homes is this ticket's own acceptance criterion.

Still this ticket's: *self-explanatory code* itself, which is the part of that
row neither skill carries. **Placed in `/implement` only.** `/code-review`'s
Standards axis already flags the naming behind a *what*-comment, which is the
check; a second bullet there would be the row stated three times.

**Two placements deviate from the outcome-2 table, both under ADR 0007's own
consequence paragraph** — *"any rule that must hold unconditionally therefore
has to be in `CLAUDE.md`"* — which the acceptance criteria repeat and the table
does not override:

- ***Never guess APIs*** stays in `CLAUDE.md`, where ticket 02 put it, rather
  than moving into `/research` and `/implement`. It fires on a bare question
  turn — answering "how do I call X?" from memory is the failure, and no skill
  is running then. Both named skills reach it by pointer, and each adds the act
  its own stage needs: `/research` that a fact established by trying flags is a
  fact about this build, `/implement` that version, signature, and limits are
  confirmed before the call.
- ***One concept per file · directories over verbose filenames · clear naming***
  went to `codebase-design` alone, as its new **Files and names** section, with
  `/implement` pointing at it. These are conditional — they bite only where code
  is being shaped — so a skill is the right home, and one skill is enough:
  `codebase-design` is a reference, not a checker, so the producer/checker pair
  ADR 0007 authorises for the comment row does not apply here.

**Three rules had to be *cut* from a second home before they could be placed,
and each cut left a pointer at the site.** `/design` §1 restated
verify-before-claiming; `/research` §2 restated the `tools/` routing sentence
verbatim; `/commit` §4 restated ADR 0008. The compression test was in
`domain-modeling`'s `CONTEXT-FORMAT.md` and moved to `CLAUDE.md`, because
cold-path capture writes knowledge on turns where no skill runs.

**`tools/SKILL.md` was the fourth, and the guard for it was chosen so it could
not fire.** Ticket 15's skill opened with *"Tenure's first principle is never
guess an API, and a CLI is an API … there is no third one where you try a flag
and see"* — the same rule as `CLAUDE.md`, near-verbatim. The `$singleHome` entry
written for it matched only the `tools/`-routing sentence that happens to travel
with the rule, which `tools/SKILL.md` does not carry, so it passed. Found by
review; the entry now matches the rule itself, and this is an edit to a resolved
ticket's artifact for the same reason ticket 09's bisect entry was.

**`/commit`'s message step also gained, then lost, a tiebreak.** The first
rewrite said the `git log` settles a disagreement with `CONTRIBUTING.md`.
Neither ADR 0008 nor the precedence chain says that — the chain ranks
`CONTRIBUTING.md` and does not rank `git log` at all — so it was invented
policy in a ticket-06 file. Cut; the read order alone was already there.

**Principles 02 and 03 were the ones nearly dropped silently.** The first
accounting covered seventeen of nineteen: the ticket calls them *definitions*
that live in the glossary, which is a disposition and not an exemption from
being checked. They are now asserted as the knowledge-layer table's two lower
rows, plus a guard that neither is restated as a rule inside a skill.

**`verify.ps1` carried the same duplication it exists to police.** Seven regexes
were byte-identical across ticket 02's `$singleHome` and ticket 13's `$placed`
and `$pointers`, so rewording one rule needed three coordinated edits and the
one that got missed would still pass. Hoisted to a single `$rulePattern` table;
the two rules whose placement check is deliberately stronger than their
duplication probe stay separate, with the reason recorded there.

258 assertions, 53 mutations. Two of the mutations are **over-fitting probes** —
they reword the worked example and cut the reason CONTRIBUTING outranks README
without touching either rule, and the suite must stay green under them.
