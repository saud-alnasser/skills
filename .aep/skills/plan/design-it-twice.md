---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: skill
use-when: "the plan must put alternative approaches on the table and the first idea is the only one anyone has produced"
---

# Plan — design it twice

`[[skills/plan]]` requires alternatives on the table before an approach is
chosen. This is how to produce ones that genuinely differ, rather than one design
plus two strawmen written to lose.

The premise, from Ousterhout's *A Philosophy of Software Design*: **your first
idea is unlikely to be the best**, and the cost of finding that out at planning
time is one afternoon against the cost of finding out after it ships.

Uses the vocabulary in `[[skills/plan/depth]]`.

## 1 — Frame the space before designing in it

Write, for the human:

- **the constraints** any interface here must satisfy,
- **the dependencies** it would rely on, and which category each falls into
  (`[[skills/plan/depth]]`),
- **a rough sketch** — not a proposal, just something concrete enough that the
  constraints stop being abstract.

Show it, then keep going. The human reads while the designs are produced; this is
not a gate.

## 2 — Produce three, under conflicting constraints

Not "three designs" — **three designs each optimised for something different**,
because unconstrained alternatives converge on whatever you already had in mind.

| | The constraint |
| --- | --- |
| A | **Minimise the interface.** One to three entry points. Maximise leverage per entry point |
| B | **Maximise flexibility.** Support extension and cases not yet asked for |
| C | **Optimise for the common caller.** Make the default case trivial, even at the cost of the rare one |
| D | **Design around the seam**, where a dependency crosses one |

Each design states: the interface (types, operations, invariants, ordering, error
modes); a usage example from a caller's side; what stays hidden behind the
interface; the dependency strategy; and where its leverage is thin.

**Each must use this repository's own vocabulary** — its `[[contexts]]` — as well
as the terms above, so three designs can be compared without first being
translated.

Where the runtime has sub-agents, each design may be a child: **one child, one
whole design**, which is a whole question and therefore a legal dispatch under
`[[rules/sub-agents]]`. Splitting *one* design across children is not.

## 3 — Present, compare, recommend

Present them one at a time so each is absorbed on its own terms, then compare in
prose along three axes:

- **depth** — leverage at the interface,
- **locality** — where a future change concentrates,
- **seam placement** — what can be substituted, and what that costs.

Then **recommend one and say why.** Where pieces of two combine well, propose the
hybrid explicitly rather than leaving it to be noticed.

**Be opinionated.** A menu with no recommendation moves the whole decision onto
the human while looking like thorough work — and it is the failure this note is
most likely to produce, because three designs feel like enough output on their
own.

The choice remains the human's (`[[rules/engineering]]`). Recommending is not
deciding.

## 4 — Write the outcome down

The chosen approach and **the alternatives that lost, with why**, go into the
effort's `spec.md`. A rejected approach nobody recorded is re-proposed by the
next person to read the code — including you, in six weeks.
