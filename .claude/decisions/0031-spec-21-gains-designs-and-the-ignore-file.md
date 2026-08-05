---
status: accepted
load-when: the specification's layout section is being amended
sources: [specs.md]
supersedes: []
superseded-by: []
---

# Amendment: specification §21 gains `designs/` and the ignore file

The canonical layout in `specs.md` §21 omitted two entries the templates have generated since before the specification was written: `.claude/designs/`, where the planning stage writes specs (the specs policy names it), and `.claude/.gitignore`, which carries the membership test for per-clone state. The implementation was right and the specification was behind — the divergence class the evolution rule exists for, resolved by amending the document rather than by narrowing the layout.

Found by ticket aep/06 while asserting the generated tree against §21, which is the check that now keeps the two from diverging again. Specification version moves to 1.1.0-draft.

## Considered Options

**Dropping `designs/` from the generated layout** was rejected: the specs policy writes there, and a layout change to match a document written weeks later would be the truth hierarchy inverted.

## Consequences

First exercise of the evolution rule by the effort that adopted it, which the aep spec required to happen visibly at least once.
