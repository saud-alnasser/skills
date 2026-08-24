---
use-when: "a decision turns on a fact that is not in this repository"
---

# research — establish what is true

Investigates one question against primary sources and writes the answer as
evidence.

**A stage, not a command.** `[[skills/specify]]` and `[[skills/plan]]` run this
where a material fact is not in this repository, inside the same invocation.
Nobody types it, and it opens no report of its own (`[[policies/reporting]]`).
Most changes never need it.

**Posture.** Evidence over conclusions. Keep what the source says, what you
observed, what you infer, and what you conclude labelled apart — collapsing
them is how a guess acquires a citation. **What this gives up** is speed, and
the comfort of a confident answer: research ending in "the source does not
say" has succeeded.

## When this is the right instrument

The uncertainty is **factual** and external: an API's actual behaviour, a
library's guarantees, a specification's wording, a platform's limits, whether a
known issue is fixed. `[[policies/engineering]]` routes the other kinds elsewhere —
argument cannot settle a fact, and neither can a prototype settle what a
specification says.

Not for: what this repository does (read it), or whether an approach will work
here (`[[skills/prototype]]`).

## Procedure

1. **Write the question down first**, as one sentence that an answer could be
   wrong about. A vague question returns a summary of the topic.
2. **Check what is already recorded.** `efforts/<effort>/evidence/research/` — it may already be answered.
3. **Go to primary sources.** The specification, the reference documentation, the
   library's own source, the changelog, the issue tracker.
4. **Trace every claim** back to the source that owns it.
5. **Dispatch the reading where it pays.** Where the runtime supports sub-agents,
   dispatch `[[agents/researcher]]` so the pages nobody needs again are read in
   its context rather than yours.
6. **Write the findings.**

## Output

`efforts/<effort>/evidence/research/<question-slug>.md`, in the shape
`[[templates/research.template]]` gives: Question, Sources, Findings, Conclusion, and what
was **not** checked.

## Constraints

- **A primary source is the thing itself.** A blog post explaining a
  specification is secondary and is where stale claims enter — where only a
  secondary source is reachable, say so and treat the fact as weaker.
- **Every claim carries its citation.** A claim you could not source is reported
  as unsourced, never rounded up to true.
- **Say what the finding is true *of*** — version, date, platform. A fact with no
  subject silently becomes a claim about the present and stops being checkable.
- **What you looked for and did not find is a finding.** Record it, or the next
  investigation spends its budget rediscovering the same absence.
- **Findings, never decisions.** If a finding changes the design, that change is
  made deliberately in `spec.md`. Research MUST NOT become a rule by implication.

## Done when

The question is answered or explicitly recorded as unanswerable, every claim is
cited, and what you did not check is named.
