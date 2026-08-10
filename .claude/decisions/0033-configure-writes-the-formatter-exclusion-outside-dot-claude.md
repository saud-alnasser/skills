---
owner: repository
status: superseded
load-when: a formatter's reach includes .claude/
sources: [skills/configure/SKILL.md]
supersedes: []
superseded-by: [0076]
---

# /configure writes the formatter exclusion outside `.claude/`

ADR 0006 made "one directory" literal by keeping the workflow's ignore entries in `.claude/.gitignore` rather than the repository's root one, which git honours because git reads nested ignore files. Formatters offer no equivalent AEP can rely on — Prettier reads a single ignore file from the directory it runs in and resolves no nested ones — so the only way to stop a formatter rewriting knowledge is to write into configuration the repository owns. `/configure` does that, and it is the only thing it writes outside `.claude/` and `CLAUDE.md`.

## Considered Options

**Shipping a nested ignore file under `.claude/`** was rejected on mechanism rather than taste: for Prettier it is read by nothing, so it would look like a fix and do nothing — the worst available outcome, because it also stops anyone looking again.

**Reporting the missing line instead of writing it** was rejected. It preserves ADR 0006 exactly and leaves the repository's knowledge being reformatted until a human acts, which is the outcome the instruction exists to prevent.

**Naming the formatters in the skill** was rejected for the reason every other tool derivation is derived rather than listed (ADR 0019): the mechanism differs per formatter and changes under it, so the skill says *use its own ignore mechanism* and `.claude/tools/` says what that is here.

## Consequences

Removing AEP stops being purely a matter of deleting `.claude/` and `CLAUDE.md`; one entry in a formatter's configuration outlives it. Accepted, because the asymmetry favours it: an ignore entry naming a directory that no longer exists is inert, while an unignored `.claude/` rewrites knowledge on every format run.

ADR 0006's rule about the root `.gitignore` is untouched and still holds — the exception is bounded to formatter configuration, where no in-directory mechanism exists to prefer.
