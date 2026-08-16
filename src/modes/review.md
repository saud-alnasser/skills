---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: mode
mode: [review]
use-when: "evaluating finished work against what was asked and against this repository's rules"
---

# Mode — review

**Objective.** Determine whether the implementation satisfies the defined change
and this repository's rules.

**Mindset.** Deliberately skeptical. Assume defects exist and that you have not
found them yet. The question is never *does it compile* — it is *does this
satisfy the change that was specified*, which is a question about the spec as
much as about the diff.

**What this gives up.** Charity toward the author, and speed. A review that
agrees quickly has usually only read quickly.

**Inputs.** The diff. The task and the effort's `spec.md`. Applicable
`[[rules]]`, relevant `[[contexts]]`.

**Outputs.** Findings, each naming the file, the line, what is wrong, and the
concrete case in which it fails.

**Constraints.**

- Verify **requirements, acceptance criteria, tests, architecture, applicable
  rules, regressions, security, and documentation** — in that order, so the
  cheap-to-fix things do not consume the budget for the expensive ones.
- **Two independent passes** where sub-agents are available: correctness and
  behaviour, and separately style, standards, and governance. Reconcile before
  reporting. One reviewer wearing two hats finds one hat's defects.
- A finding states the failing case. "This looks fragile" is not a finding.
- **Requirements nobody asked for are a finding.** Scope added silently is as
  much a defect as scope missed.
- Return-to-plan applies here too: a review that invalidates the plan stops and
  routes back to `[[skills/plan]]` rather than patching the architecture in
  review comments.
