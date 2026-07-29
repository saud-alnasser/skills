# Evidence

<!--
  Installed by /configure at `.claude/policies/evidence.md`. Copied as-is — it
  describes the workflow, not this repository.

  Consolidated from /design, /research, /prototype, and /triage, each of which
  stated part of it. The gating rule and the graduation rule in particular were
  /design's, reached by pointer from the two skills that produce evidence; they
  live here now and every one of those four points at this file.

  Reached by pointer from `.claude/protocol.md`'s routing table.
-->

**Evidence is the trail showing how a claim was earned** — research findings, prototype write-ups, and the record of a rejected request.

It is not a knowledge layer, and the difference is the whole reason it has its own directory: **evidence records what was verified and when, and nothing revalidates it afterwards.** Context is maintained against the Codebase; a finding is true of the moment it was taken. That shared property is what earns the three kinds one grouping directory rather than three scattered ones.

## The three kinds

| Kind | Written to | Produced by |
| --- | --- | --- |
| research findings | `.claude/evidence/research/` | `/research` |
| prototype write-ups | `.claude/evidence/prototypes/` | `/prototype` |
| rejected requests | `.claude/evidence/out-of-scope/` | `/triage` |

**Throwaway prototype code is not evidence.** The code goes to `.claude/prototypes/` and is deleted; the write-up goes to `.claude/evidence/prototypes/` and is kept. Ignoring the code is the intent — ignoring the record of what it proved is silent data loss, which is why the ignore rules anchor the pattern rather than matching at every depth.

**Read the directory before producing more.** A finding whose question matches and whose assumptions still hold is the answer: cite it and move on. Rebuilding an experiment whose answer is already recorded is the waste these directories exist to prevent.

## Gating

A **gated** evidence block stops the design. The gate fired because the answer is load-bearing, and planning past it means planning on a guess.

**Ungated evidence runs in the background** and the design continues.

That split is the whole cost model: gating everything makes the workflow serial for answers nobody was waiting on, and gating nothing means the plan is built before its load-bearing assumption is checked.

## Graduation

Durable findings **graduate** out of evidence and into knowledge — how the repository behaves becomes Context, why an approach was chosen becomes a Decision.

**`/design` owns graduation**, because `/design` read the findings and nothing downstream will. A producing skill that promoted its own finding would be writing knowledge nobody grilled.

So `/research` and `/prototype` **never write Context directly.** They fail that way for different reasons, and both are worth keeping:

- A **research** finding is a versioned external fact. Copied into Context it lands in a layer that has no version and nothing to re-verify it against — and the finding's whole value was that it said what it was true *of*.
- A **prototype** result is true of the thing that was built, under the constraints it was built with. Copied into Context it is restated as a claim about the repository, which is not what was demonstrated.

Graduation is a **copy of what is durable, not a move.** The evidence stays where it is: it is the record of how the claim was earned, and deleting it leaves the Context statement with no provenance.
