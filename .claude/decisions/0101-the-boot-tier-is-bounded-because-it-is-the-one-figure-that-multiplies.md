---
owner: repository
status: accepted
load-when: whether a build figure is thresholded, or what the boot tier may cost, is in question
sources: [specs.md, skills/configure/SCRIPTS.md, CLAUDE.md, .claude/rules/, .claude/evidence/drift/2026-08-13-a-row-bound-cannot-tell-index-growth-from-prose-reinflation.md]
supersedes: []
superseded-by: []
---

# The boot tier is bounded, because it is the one figure that multiplies

The build measures the boot tier — the entrypoint plus every rule without a path
scope — against a budget of **12,000 characters**, and exceeding it fails. The
corpus's instruction count and each row's authored and generated sizes stay
reported and thresholded by nothing. Three figures, two treatments, and the split
is the decision.

**The tier is bounded because it is paid on every turn where a row is paid once.**
Adding to it is a permanent per-turn tax on every session and every dispatched
child, which is true of nothing else the build measures.

**It can be bounded because it is entirely authored prose that should not grow.**
That is the property the other two figures lack, and it is exactly what a drift
finding recorded here established the hard way: a bound over a total that mixes
authored prose with generated indexes cannot tell the regression it exists to
catch from ordinary accumulation, and the cheapest response to a crossing —
ratchet and move on — is the one that erodes the guard. That finding is answered
rather than contradicted. Its objection is about *conflated* figures; the boot
tier conflates nothing, so a crossing has exactly one meaning: somebody added an
always-on rule.

**The number has a basis, and stating it is what stops it becoming a ratchet.**
The tier measured 9,894 characters when the budget was set. 12,000 allows roughly
one further always-on rule of average size, or substantial growth in the
entrypoint. A future crossing is therefore a real addition rather than evidence
that the bound was set too tight — which is the distinction a bare number cannot
support, and the reason the basis travels with it.

## Considered Options

- **Report the tier and threshold nothing**, amending the specification to match
  the implementation and giving all three figures one treatment. Rejected: it
  amends the canonical specification to match code rather than the reverse, and
  leaves the only figure that multiplies per turn unbounded.
- **Fail against a committed baseline** that each effort amends when it raises the
  figure. Catches regression with nobody choosing an absolute number. Rejected on
  two counts: it commits a derived value, which this repository's own rule
  forbids, and the baseline becomes the file people edit to go green.
- **Express the bound in lines**, folding in the existing rule that the entrypoint
  stays under 200 lines. Rejected: this corpus writes long lines, so a reflow would
  move the figure without moving the tax, and the per-row figures are already in
  characters.

## Consequences

**The budget constrains what the framework ships, not only what a repository
writes.** The always-on rules are framework-owned and byte-locked, so a repository
pushed over the bound by a framework release cannot shrink its way back under it.
That is intended: it puts the cost of a new always-on rule where the rule is
written. The figure is reported on every run, so the margin is visible long before
a crossing.

**Two bounds now cover overlapping ground** — this one, and the older rule that the
entrypoint stays under 200 lines. The older is a subset and is kept, because it
constrains the file a human edits most often and does so in the unit that file is
reviewed in.
