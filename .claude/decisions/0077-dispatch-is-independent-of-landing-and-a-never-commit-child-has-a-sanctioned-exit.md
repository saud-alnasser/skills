---
owner: repository
status: accepted
load-when: a ticket set is about to be dispatched, or a worktree whose child never commits is about to be removed
sources: [.claude/policies/version-control.md, skills/implement/SKILL.md, .claude/decisions/0046-ticket-orchestration-is-a-second-axis-and-its-failure-rule-inverts.md, .claude/decisions/0051-the-commit-unit-here-is-the-effort.md]
supersedes: []
superseded-by: []
---

# Dispatch is independent of landing, and a never-commit child has a sanctioned exit

The version-control policy banned dispatching a set on an effort-commit
repository, but its premise (ADR 0046) is about landing — per-ticket branches
let a failed sibling leave the rest landed — and a recorded run showed the
banned mechanism working: children in isolated worktrees, integrated by change
record into the effort's one commit, verified green. Decided: the prohibition
narrows to what the premise supports. A set may be dispatched under
one-effort-one-commit (ADR 0051 stands); what is genuinely lost, and the norm
states it, is that a failed sibling is excluded by the orchestrator's judgement
over the change records rather than by branch topology. ADRs 0046 and 0051 are
reconciled, not superseded — each is true of its own landing model.

The worktree corollary: under effort-commit a child never commits, so its
worktree is dirty by construction after integration, and the removal refusal
fires on every child regardless of whether work landed — the refusal's
second-opinion value is zero there. Decided: once a child's work is verified
integrated against its change record and the suite is green, forced removal is
the sanctioned exit, with the verification stated where the removal is done.
Cleaning a tree until the refusal cannot fire is the letter-versus-check
violation; the force at least leaves its trace in the command.
