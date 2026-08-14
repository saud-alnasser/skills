---
owner: repository
status: superseded
load-when: where a mode's text lives is in question
sources: [.claude/modes/]
supersedes: []
superseded-by: [0084]
---

# Amendment: modes move out of the protocol file into `.claude/modes/`

The seven mode definitions shipped as `### Mode:` sections of the protocol file (ticket aep/03). This amendment moves them to `.claude/modes/`, one file per posture, and adds the directory to the canonical layout in `specs.md` §21. Specification version moves to 1.2.0-draft.

Three things paid for the move. §22 already lists modes as their own pointer-tier item, distinct from the protocol file — the layout now matches the systems list. §21's closing line says every category is a directory rather than a naming convention, and modes were a category hidden inside another file. And a stage needs exactly one posture of the seven, so per-file modes let it load what it declared instead of all of them through the router — which also returns the router to being routing.

## Considered Options

**A single `.claude/modes.md`** was rejected: it becomes a second loose file beside `protocol.md`, which the generated tree explicitly calls a category nobody named, and every stage would still load all seven postures to use one.

**Leaving the modes in the protocol file** was rejected: every open of the router paid for seven mode definitions to use at most one, and the interim shape contradicted §22's own tier list.

## Consequences

The migration recognises both older shapes by content — no mode column at all, and `### Mode:` sections inside the protocol file — and converts either to the directory. Frozen records keep the old shape.
