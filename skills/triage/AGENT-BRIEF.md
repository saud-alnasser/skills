# Writing agent briefs

An agent brief is the comment posted when an item moves to `ready-for-agent`. The original body and the discussion are context; **the brief is the contract**, and it is what an agent will actually build from.

It states what the agent should do, which reads differently on the two surfaces: for an issue, build the change from nothing; for a PR, finish the diff that already exists — close the gaps, address the review points.

## Durability over precision

The item may sit in `ready-for-agent` for weeks, and the codebase will move underneath it. Write the brief so it survives that.

- **Do** describe interfaces, types, and behavioural contracts.
- **Do** name the types, signatures, or config shapes to look for.
- **Don't** reference file paths. They go stale, and a brief that points at a moved file sends an agent somewhere that no longer exists.
- **Don't** reference line numbers — the same failure, faster.
- **Don't** assume today's implementation structure survives.

This is the same rule as a Source Pointer: say where the concept lives, never what is there.

## Behavioural, not procedural

**What** the system should do, not **how** to build it. The agent explores fresh and makes its own implementation calls.

- Good: *"`SkillConfig` should accept an optional `schedule` field of type `CronExpression`."*
- Bad: *"Open src/types/skill.ts and add a schedule field on line 42."*
- Good: *"`/triage` with no arguments shows a summary of issues needing attention."*
- Bad: *"Add a switch statement in the main handler."*

## Complete acceptance criteria

The agent has to know when it is done. Every criterion independently verifiable by someone who did not write the code.

- Good: *"`gh issue list --label needs-triage` returns issues that have been through initial classification."*
- Bad: *"Triage should work correctly."*

## Explicit scope boundaries

Say what is **out of scope**. Without it the agent gold-plates, or assumes an adjacent feature was implied.

## Template

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** one line — what has to happen

**Current behaviour:**
What happens now. For a bug, the broken behaviour. For an enhancement,
the status quo it builds on. For a PR, the state of the diff.

**Desired behaviour:**
What is true when the work is done, including edge cases and errors.

**Key interfaces:**
- `TypeName` — what changes and why
- `functionName()` — what it returns now versus what it should
- Config shape — any new options

**Acceptance criteria:**
- [ ] Specific, testable
- [ ] Specific, testable

**Out of scope:**
- What must not change
- The adjacent thing that looks related and is not
```

## A good one

```markdown
## Agent Brief

**Category:** bug
**Summary:** Description truncation breaks mid-word

**Current behaviour:**
A description over 1024 characters is cut at exactly 1024 regardless of
word boundaries, producing output that ends mid-word — "Use when the user
wants to confi".

**Desired behaviour:**
Truncation breaks at the last word boundary before the limit and appends
"..." to show it was cut.

**Key interfaces:**
- The metadata type's `description` field — no type change, but whatever
  populates it has to respect word boundaries
- Anything that reads frontmatter and extracts a description

**Acceptance criteria:**
- [ ] Descriptions under the limit are unchanged
- [ ] Longer ones break at the last word boundary before it
- [ ] Truncated descriptions end with "..."
- [ ] Total length including "..." stays within the limit

**Out of scope:**
- Changing the limit
- Multi-line descriptions
```

## A bad one

```markdown
## Agent Brief

**Summary:** Fix the triage bug

**What to do:**
The triage thing is broken. Look at the main file and fix it. The function
around line 150 has the issue.

**Files to change:**
- src/triage/handler.ts (line 150)
- src/types.ts (line 42)
```

No category. No description of current versus desired behaviour. No acceptance criteria, so nothing says when it is done. No scope boundary. And two file paths with line numbers, which is the part that will be wrong first.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
