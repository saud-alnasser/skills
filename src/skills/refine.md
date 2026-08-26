---
use-when: "a spec exists but reads as ambiguous, under-constrained, or too agreeable"
---

# refine — grill the specification

Attacks an effort's `spec.md` until ambiguity and unresolved tradeoffs have
surfaced. Repeatable, and frequently the highest-value work in the spine.

**A stage, not a command.** `[[skills/specify]]` and `[[skills/plan]]` run this
where product uncertainty or an unresolved tradeoff would otherwise reach the
spec. Nobody types it, and it opens no report of its own
(`[[policies/reporting]]`) — everything it produces still reaches the human.

**Posture.** Adversarial, on purpose. Find the reading of this spec under
which the delivered thing is wrong and everybody was technically correct.
Agreement is not the goal and is often the failure. **What this gives up** is
momentum, and the human's comfort: refinement feels like obstruction while it
is happening and like foresight afterwards.

## Procedure

1. **Read the scope, then the spec.** `node .aep/scripts/scope.mjs read`, quoted:
   it names the effort whose `.aep/efforts/<effort>/spec.md` this reads in full,
   and a non-empty claim confines the run to the efforts it names
   (`[[policies/execution]]`). The claim and the isolation go in the `Position` of
   the turn this is a stage of (`[[policies/reporting]]`).
2. **Load what applies.** Applicable `[[policies]]` and `[[rules]]`, relevant `[[contexts]]` and
   `[[references]]`.
3. **Find the weak points.** Work down this list — it is ordered by how expensive
   the defect is to discover later:

   | Look for | The question that exposes it |
   | --- | --- |
   | a requirement with two readings | which one ships? |
   | an acceptance criterion nothing could fail | what would a broken version look like? |
   | a constraint that is really a preference | what happens if we violate it? |
   | scope with no stated edge | what is the nearest thing we are *not* doing? |
   | a tradeoff stated as a decision | what did we give up, and who decided? |
   | an assumption written as a fact | how do we know? |
   | a dependency on something not yet true | what if it never becomes true? |

4. **Ask one question at a time**, with real options and their consequences. A
   list of eight questions gets one answer to the easiest.
5. **Reach for the right instrument.** Where discussion cannot settle it:
   `[[skills/research]]` for a fact, `[[skills/prototype]]` for a feel,
   `[[skills/domain]]` when the disagreement is really about words.
6. **Write every answer into the spec** as you get it. An answer that lives only
   in the conversation was not obtained.

## Constraints

- **MUST NOT silently expand product scope.** A question that reveals new scope
  is raised *as* new scope and the human decides.
- Challenge the assumption, not the person.
- **Stop at the floor.** When the remaining ambiguity is cheaper to discover in
  code than to resolve in prose, stop and say so. Grinding past that point is
  waste dressed as rigour.

## Output

The **same** `spec.md`, clarified. Unresolved items stay visible under
`# Open Questions` — a spec that quietly drops a question it could not answer is
worse than one that admits it.

## Done when

The remaining questions are ones only code can answer, and the human agrees.
