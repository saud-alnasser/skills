---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
use-when: "writing the brief a sub-agent will build from"
---

# Implement — writing the brief

`[[rules/sub-agents]]` fixes **what a brief must contain** and the boundaries a
child works under. This is how to write those fields so the child builds the
right thing.

The brief is the **only** parent-to-child channel. The conversation that produced
the task is not available to the child, and nothing it assumes about that
conversation is checkable. **What is not in the brief did not happen.**

## Durability over precision

The child explores a codebase that may have moved since the task was written, and
it will move again while the child works.

- **Do** describe interfaces, types, and behavioural contracts.
- **Do** name the types, signatures, or configuration shapes to look for.
- **Do not** give file paths as the location of a concept. Paths go stale, and a
  brief pointing at a moved file sends a child somewhere that no longer exists —
  where it will then build something.
- **Do not** give line numbers. The same failure, faster.
- **Do not** assume today's internal structure survives.

The same rule a `[[contexts]]` pointer follows: **say where the concept lives,
never what is currently there.** Paths as *inputs to read* are fine and required
— that is the rule's "inputs as paths". Paths as *the definition of the work* are
what goes stale.

## Behavioural, not procedural

Say **what must be true when it is done**, never **how to do it**. The child
reads the code fresh and makes its own implementation calls; a procedure written
by someone who has not read today's code is a constraint on the wrong thing.

| | |
| --- | --- |
| ✓ | *"`SkillConfig` accepts an optional `schedule` field of type `CronExpression`."* |
| ✗ | *"Open the config type and add a schedule field."* |
| ✓ | *"Invoked with no arguments, it reports what needs attention."* |
| ✗ | *"Add a branch in the main handler."* |

## Acceptance criteria that someone else could check

The child has to know when it is finished, and the parent has to be able to
reconcile the claim. Every criterion is **independently verifiable by someone who
did not write the code**.

*"`node .aep/scripts/validate.mjs` exits zero"* is a criterion. *"Validation
should work correctly"* is a hope, and a child that returns **done** against it
has said nothing.

Where the task already carries acceptance criteria — it should
(`[[skills/tasks]]`) — the brief carries **those**, unedited. Rewriting them at
dispatch time is how a child ends up building against criteria nobody agreed to.

## Say what is out of scope

Without it, a child gold-plates, or treats the adjacent thing as implied. Name
the thing that looks related and is not — that is the one that gets built.

## The shape

```markdown
**Objective:** one line — what has to become true

**Current behaviour:**
What happens now. For a bug, the broken behaviour; for a change, the status quo
it builds on.

**Desired behaviour:**
What is true when the work is done, including edge cases and error paths.

**Key interfaces:**
- `TypeName` — what changes and why
- `operationName` — what it returns now, versus what it should

**Inputs to read:** paths, not pasted content
**Task:** the task this child owns, whole
**Worktree:** where it works
**Returns:** the shape of the result
**Acceptance criteria:** copied from the task, verifiable by a third party
**Out of scope:** what must not change; the adjacent thing that is not this
**Cap:** the bound on the work
```

## The brief that fails

Every failing brief fails the same way: it is short because the writer already
knows the context, and everything it left out is exactly what the child does not
have. *"Fix the triage bug. Look at the main handler — the function around line
150 has the issue."* No current behaviour, no desired behaviour, no criteria, no
scope boundary, and a line number that will be wrong first.

Before dispatching, read the brief as though you had never seen this repository.
That is the reader.
