---
owner: repository
status: accepted
load-when: a row's instruction density, what counts as one instruction, or the order a row arrives in is in question
sources: [.claude/tickets/substrate/issues/13-what-bounds-a-row-s-instruction-count.md, .claude/evidence/research/2026-08-13-what-a-norm-corpus-must-look-like-to-actually-be-followed.md, .claude/evidence/prototypes/2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md]
supersedes: []
superseded-by: []
---

# The corpus shrinks, a record is one instruction, and the count is reported rather than thresholded

**The response to a row over its instruction count is fewer norms, not a smaller row.**
This is chosen against a measurement rather than an argument: filtering `/implement`'s row
by `fires-when` cuts 34.7% of characters and only **27.4% of norm-shaped imperatives, 168
to 122**, leaving it inside the 100–115 band the question was opened about. The filter
strips the one-line *why* clauses ADR 0074 requires faster than it strips imperatives, so
the density barely moves. **Cutting the row was costed and does not reach.** ADR 0089's
filter stands as a token mechanism with its compliance claim withdrawn, and the corpus is
where the remaining work is.

**A record is one instruction, and a record carrying more than one imperative fails the
build.** This unifies the count with ADR 0085's addressable span rather than adding a
second unit: counting becomes a filter like any other, and the rule becomes a forcing
function for the *smallest span that is correct alone* discipline ADR 0085 already wants
but could not check. Accepted, and it is the strictest reading available: much of the
corpus fails it today. Under *cut the corpus* that is the mechanism working rather than a
cost — the failures are the list of what to merge or split.

**The count is reported, never thresholded.** The build emits each row's instruction count
and its trend; no number fails anything. A ratcheted threshold was rejected on this
repository's own evidence: `.claude/evidence/drift/2026-08-13-a-row-bound-cannot-tell-index-growth-from-prose-reinflation.md`
records a character bound crossed every few ADRs and ratcheted rather than fixed, which is
what a number set by observation buys. Deriving one from IFScale's per-density figures was
rejected because **those figures were never obtained** — two attempts at the source failed
and the finding records it as its largest open gap. A number nobody can source is a number
set by observation wearing better clothes.

**A row arrives ordered by computed precedence.** Primacy is measured and peaks around
150–200 instructions, so position in the payload is not neutral and a filter result's
natural order spends a real effect on nothing. ADR 0086 already computes precedence from
type, store, and `fires-when`; the row is emitted in that order, highest-ranked binder
first. No new authored field, and the ordering carries meaning rather than breaking a tie.
Precedence orders binders only, so records that bind nothing form a defined tail after
them.

**The fidelity floor is now two things and they are named apart.** ADR 0023 calls
`scripts/verify.ps1` the fidelity floor — prose surviving compression. ADR 0085 calls the
id the fidelity floor — a norm surviving addressing. They are complementary failure modes,
and one term in two senses is what `.claude/policies/context.md` calls a finding about the
repository rather than a filing problem. **The id carries the *addressing* floor; the
suite carries the *compression* floor.** Neither decision changes; the word does.

## Considered Options

- **A count bound that fails the build** — rejected on the drift finding above: it
  inherits the ratchet weakness exactly, and the effort already has one instrument
  documented as moving whenever it is inconvenient.
- **Counting bolded imperative lines** — what the prototype actually measured, and
  rejected as the durable rule: it is a formatting heuristic, gameable by rewrapping, and
  it makes a build check depend on prose style rather than structure.
- **One record, one instruction, unenforced** — rejected: it counts a record holding three
  imperatives as one, which understates exactly the density being managed and leaves ADR
  0085's fidelity question circling.
- **One checkable claim, judged** — truest to what IFScale measured, rejected under ADR
  0078: a fixed-core procedure is computed or it names its judgement, and this is neither
  computable nor a named judgement point.
- **Declared row order per record** — rejected: a new authored field on every record, and
  ADR 0084 admitted fields only where the two axes forced them.
