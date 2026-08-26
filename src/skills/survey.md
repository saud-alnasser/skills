---
use-when: "the question is where the codebase is costing you, rather than a specific change"
---

# /survey — find where the architecture is costing you

Surveys a codebase for deepening opportunities and reports them so one can be
taken into `[[skills/specify]]`. Not feature work, and not a bug hunt.

**Posture.** Skeptical when judging and evidence-first when gathering: a cost
you assert is an opinion, and a cost you can point at in the code is a
finding. **What this gives up** is the tidy answer — a survey naming three
real costs beats one naming ten plausible ones.

## When to run this

Two situations: you have room to invest and want to know where; or a diagnosis
has just concluded that the real problem was **no seam to lock the behaviour
down**, which is an architecture finding wearing a bug's clothes.

Not for a specific bug, and not for a change already described — that is
`[[skills/specify]]`'s.

## Procedure

1. **Read the position and the scope, then bound the survey.**

   ```
   node .aep/scripts/position.mjs check
   node .aep/scripts/scope.mjs read
   ```

   Both quoted. **Two questions, two answers, and never merged:** the marker says
   whether this surface moved since a run last read it, and the scope says which
   efforts this branch claims and what isolation is in force. This skill takes no
   surface and enters none, so the marker it checks here is the surface it works
   in and the one it stamps at step 7.

   A non-empty claim confines this run like any other, and a subject that is the
   whole codebase buys no exemption (`[[policies/execution]]`): reaching another
   effort's artifact stops the run and names it, and a tree-wide subject belongs
   on an unscoped checkout. The claim and the isolation go in `Position`, beside
   the marker's answer and the bound (`[[policies/reporting]]`). Then bound it —
   a directory, a package, a subsystem. An unbounded survey returns a list nobody
   acts on.
2. **Read what is there.** `[[contexts]]` for the area, then the code.
3. **Look for the four costs**, in this order:

   | Cost | Tell |
   | --- | --- |
   | **resists change** | one conceptual change touches many files in lockstep |
   | **cannot be tested** | behaviour reachable only through setup nobody wants to write |
   | **hard to navigate** | you cannot predict where something lives from what it does |
   | **shallow interface** | the interface is nearly as complex as what it hides |

4. **For each candidate, establish the evidence**: where it shows up, what it has
   already cost (churn, incidents, time), and what a deeper module would look
   like.
5. **Rank by cost × frequency**, not by how bad the code looks. Ugly code nobody
   touches costs nothing.
6. **Report.**
7. **Stamp the marker**, and stop —
   `node .aep/scripts/position.mjs stamp --session <id>`, passing **the
   identifier your harness gave this session**. **Never invent one:** where the
   runtime exposes no identifier, drop the flag and stamp as before
   (`[[policies/execution]]`).

   A survey stamps despite changing nothing, because the marker records the tree
   a run **read** and not the tree a run committed. Reading is the act that earns
   the stamp, and a survey is nothing but reading.

## Output

A report the human can act on — findings ranked, each with its evidence, its
estimated cost to fix, and what it would buy. Where a visual makes the coupling
legible, produce one: `[[skills/survey/report]]` has the shape, the diagram
patterns, and the language discipline. `[[skills/plan/depth]]` defines the
vocabulary this uses — *deep*, *shallow*, *seam*, *leverage* — and using it
precisely is what separates a finding from an opinion.

The survey **produces no change and creates no effort.** The human picks one, and
that pick goes to `[[skills/specify]]`.

## Constraints

- **Evidence, not taste.** "This is messy" is not a finding; "changing a payment
  method touches nine files across three packages" is.
- Never start fixing. A survey that begins refactoring has become an unplanned,
  unreviewed effort.
- Say what you did not survey. A bounded survey read as complete is worse than no
  survey.

## Done when

The findings are ranked with evidence, the bound is stated, and the human has
chosen what — if anything — to take forward.
