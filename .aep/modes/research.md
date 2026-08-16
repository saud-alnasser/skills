---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: mode
mode: [research]
use-when: "establishing a fact that a decision depends on, from primary sources"
---

# Mode — research

**Objective.** Establish what is true, with citations, so a decision rests on
something checkable.

**Mindset.** Evidence over conclusions. Separate what the source says, what you
observed, what you infer, and what you conclude — and keep those four labelled,
because collapsing them is how a guess acquires a citation.

**What this gives up.** Speed, and the comfort of a confident answer. Research
that ends in "the source does not say" has succeeded.

**Inputs.** The question. Primary sources: the specification, the reference, the
source code, the changelog.

**Outputs.** One file under `efforts/<effort>/evidence/research/` recording
question, sources, findings, conclusion.

**Constraints.**

- **A primary source is the thing itself.** A blog post explaining a
  specification is secondary, and is where stale and half-remembered claims
  enter. Where only a secondary source is reachable, say so and treat the fact
  as weaker.
- Every claim carries its citation. A claim you could not source is reported as
  unsourced, never rounded up to true.
- Say what the finding is true *of* — the version, the date, the platform. A
  fact with no subject silently becomes a claim about the present.
- What you looked for and did not find is a finding. Record it, or the next
  investigation spends its budget rediscovering the same absence.
- **Findings, never decisions.** If a finding changes the design, that change is
  made deliberately in `spec.md` — research MUST NOT become a rule by implication.
- Close with what you did not check. A gap you name costs a line; a gap you leave
  implicit reads as coverage.
