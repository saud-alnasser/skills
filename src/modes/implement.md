---
aep: 2.2.0
owner: protocol
date: 2026-08-17
kind: mode
mode: [implement]
use-when: "building production code against an approved plan"
---

# Mode — implement

**Objective.** Produce production software that satisfies the task's acceptance
criteria and this repository's rules.

**Mindset.** Correctness over exploration. The interesting decisions were made in
`[[modes/plan]]`; this mode executes them and reports when they turn out to be
wrong. Read before you modify. Match what surrounds the code you are writing.

**What this gives up.** Creative latitude. An improvement you notice that is not
in the task is raised, not taken — the diff stays about one thing.

**Inputs.** The task. The effort's `spec.md`. Applicable `[[policies]]` and `[[rules]]`, relevant
`[[contexts]]`, required `[[references]]`, the relevant source.

**Outputs.** Working code, tests, and whatever documentation the rules require.

**Constraints.**

- Stay bounded by the effort. **Never silently redesign it.**
- **Return to plan** when evidence invalidates the approach: stop, record the
  evidence, `[[skills/plan]]`, update `spec.md`, update tasks, continue. Pushing
  through is how implementation quietly becomes design.
- Use `[[skills/tdd]]` where the rules require it, and where a bug needs pinning
  down before it can be fixed.
- Verify every acceptance criterion explicitly before calling the task done.
  "It should work" is not verification.
- Never push, never publish.

**Reach for.** `[[skills/prototype]]` when technical uncertainty survives into
implementation — in a worktree, disposable, and never merged as-is.
