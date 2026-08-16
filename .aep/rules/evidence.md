---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: rule
mode: [specify, plan, refine, implement, research, prototype]
use-when: "material uncertainty has surfaced and you are about to guess, research, or prototype"
---

# Rule — evidence before guessing

## Climb only as far as the uncertainty warrants

```
known fact → repository inspection → existing context/evidence
→ research → prototype → grill
```

Use the **cheapest reliable** mechanism. Expensive investigation for trivial
uncertainty is its own defect — a config rename does not get a research phase.

Route by the *kind* of uncertainty, because the wrong instrument produces a
confident wrong answer:

| Uncertainty | Instrument |
| --- | --- |
| factual — what does this API actually do | `[[skills/research]]` |
| technical — will this approach work | `[[skills/prototype]]` |
| product, requirement, tradeoff, disagreement | grill, via `[[skills/refine]]` |

Argument cannot settle a factual question, and reading cannot settle whether an
interaction feels right.

The standards that govern how a claim is made at all — inspect before asserting,
never guess an API — are `[[rules/engineering]]`'s. This rule is about what to do
once you have found that you do not know.

## What gets recorded

Evidence lives at `efforts/<effort>/evidence/`, in `research/` or `prototypes/`.
Those are the only two kinds.

- **Research records findings, never decisions.** If a finding changes the
  design, change `spec.md` deliberately. *Why: research that quietly becomes a
  decision is an architecture chosen by whoever ran the search.*
- **Prototype code is disposable.** It MUST NOT automatically become production
  code; promotion is an explicit decision recorded in `spec.md`, and what is
  promoted is rewritten under `[[modes/implement]]`.
- **Grill is not evidence.** It is a mechanism; its conclusions land in the spec,
  a rule, a context, or an evidence file. There is no `grill/` directory.
- What you looked for and did **not** find is a finding. Record it.

## Graduation

Knowledge that outlives its effort moves into a `[[contexts]]`, a `[[rules]]`, or
a `[[references]]`. The evidence file stays where it is, as the record of how it
was learned.
