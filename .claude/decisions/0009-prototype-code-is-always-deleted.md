---
status: accepted
load-when: prototype code is about to be kept
sources: [skills/prototype/]
supersedes: []
superseded-by: []
---

# Prototype code is always deleted; the write-up is the artifact

`workflow.md` stores prototypes under `.claude/prototypes/` and has a *Prototype Reuse* section that inspects existing prototypes before building a new one. matt's `prototype` says the opposite — throwaway from day one, keep the answer and delete the code. Reuse of code that was deleted is impossible, so one had to give.

Code is **always** deleted once the question is answered. If it can be promoted, it is promoted and then deleted; if it cannot, it is deleted. There is no reusable-harness exception — that carve-out would be claimed for almost every prototype at the moment of finishing it, which is exactly when reusability is most overestimated.

`.claude/prototypes/` is therefore gitignored scratch. The durable artifact is a write-up in `.claude/docs/prototypes/`, carrying the question tested, hypothesis, method, what it was verified against (version and date), limitations, result, and a conclusion of Successful / Partially Successful / Failed / Inconclusive.

The write-up is **required** for Failed and Inconclusive prototypes — that is the highest-value case, because it stops the experiment being repeated — and for Successful prototypes that were not promoted. It is optional only when a prototype was promoted, since the answer is then embodied in shipped code, with rejected alternatives recorded in the ADR instead.

Reuse operates on the write-up: same question, assumptions still hold, so trust the recorded finding rather than rebuild the experiment.

## Consequences

The write-up is **evidence, not knowledge**. A finding about how the repository behaves graduates into `context.md`; a finding about why an approach was chosen becomes an ADR. The write-up remains as the trail showing how the claim was earned, and is not itself part of the knowledge layer.

Deleting code that took real effort is uncomfortable and will be resisted in the moment. The discipline holds only because the write-up is written *before* the deletion, not after — a prototype is not finished until its conclusion is recorded.

Promotion is a fresh implementation effort — redesign, integration, tests, documented APIs — not a file move. The prototype's code informs it and is still deleted.
