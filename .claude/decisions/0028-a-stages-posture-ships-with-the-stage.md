# A stage's posture ships with the stage, and is not derived per repository

Each Spine skill states its own **posture** — the tradeoffs that are acceptable while it runs, and what "done" means for it. `/prototype` says tests are optional and speed beats correctness; `/implement` says the reverse. It is a section in the skill, not a guide and not a directory.

Placement follows the rule this repository already holds: *when a rule fires decides where it lives.* A posture fires exactly when its stage runs and at no other moment, which is the definition of something belonging to the stage. `paths:` cannot express "while `/prototype` is running", and a pointer-read guide would fire only if something followed the pointer — so the skill is the only home where the timing is guaranteed rather than hoped for.

This is a deliberate exception to the line ADR 0019 drew for tool references. A tool reference is derived because the commands genuinely differ per repository; a posture does not — `/prototype` produces throwaway code everywhere, and a repository that wanted otherwise would be asking for a different stage rather than a tuned one.

## Considered Options

**A derived `.claude/policies/posture.md`**, one row per stage, was rejected. It buys tunability nobody has asked for: the postures are identical in almost every repository, so derivation costs a generation step that can go wrong in exchange for rows that come out the same. It also puts the posture behind a pointer, where it fires only if read.

**Separate `modes/` and `workflows/` directories**, as the v2 proposal has them, were rejected together. Seven of the ten proposed modes have identically-named workflows, which is the signal that the split is nominal — and ADR 0021 already rejected subject-based placement because it is a judgement call at every edge. Two directories holding one concept means every future instruction needs an argument about which it is.

## Consequences

A repository cannot tune a posture. "Here, prototypes still have to typecheck" has nowhere to go except a rule in `.claude/rules/`, which is the correct home for a standard this repository discovered about itself.

The always-on budget is unaffected — every Spine skill is loaded only when invoked. The cost lands on the invocation, which is where the posture is needed.

`verify.ps1` asserts each Spine skill carries the section, so a stage added later without one fails the build rather than shipping with its tradeoffs implied.
