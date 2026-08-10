---
owner: repository
kind: drift
falsifies: [.claude/policies/version-control.md, .claude/decisions/0051-the-commit-unit-here-is-the-effort.md, skills/implement/SKILL.md]
---

# The set-dispatch prohibition forbids more than its stated reason supports

Found while building the `downstream` effort's last four tickets. Filed rather than
healed: the sentence rests on ADRs 0046 and 0051, and superseding a Decision is
`/design`'s pen rather than a build session's — `.claude/policies/knowledge.md` is
explicit that a falsified Decision is the one drift nobody heals inline.

## What the file says

*The unit is the effort, not the ticket* closes with:

> A dispatched set lands one commit per ticket on that ticket's own branch, which is
> what lets a failed sibling leave the rest landed (ADR 0046) — and there is no
> per-ticket branch here for it to land on. **So the frontier is worked in one
> branch, and a set is not dispatched.**

## Why that conclusion is wider than its premise

The premise is about **landing**: per-ticket branches are what let a failed sibling
leave the rest landed. The conclusion bans **dispatching**, which is a different act.
Parallel building does not require a per-ticket branch — it requires isolated
workspaces, and the orchestrator can integrate every child's diff into the effort's
single commit.

Run here, on the user's instruction, for tickets `04`, `05`, `07`, and `08`: four
children in isolated worktrees, each reconciled against its change record path by
path, all four integrated into one commit, `scripts/verify.ps1` rebuilt by appending
each block in ticket order. Suite went from 1213 to 1251 passing, zero failures. The
mechanism the sentence rules out worked, and what it protects was preserved by the
orchestrator declining to integrate rather than by branch topology.

What is genuinely lost is narrower than the ban: a failed sibling is excluded by the
orchestrator's judgement rather than by mechanism. That is a real cost and belongs in
the sentence — it is not a reason to forbid dispatch.

## A second sentence the same model falsifies

`/implement`'s *a spent worktree is removed* says never to force `git worktree
remove`, because the refusal on uncommitted work is "a second opinion on this stage's
judgement: one that will not come away cleanly is one whose work had not all landed
after all."

That inference assumes children commit to their own branches. Under one-effort-one-
commit they never commit at all, so every child's worktree is dirty **by
construction** once its work has been integrated, and the refusal fires on all of
them regardless of whether anything landed. All four refused here after their work
was verified integrated and the suite was green.

The rule then leaves only two exits, and the one it names is the worse one: cleaning
each worktree until the refusal cannot fire is the letter-versus-check violation that
this same effort added a standard against, while forcing at least leaves the trace in
the command. Forced, deliberately, with the reasoning stated in the transcript.

## What would close it

A design run that decides whether to narrow the prohibition to landing, states the
retained cost, and reconciles ADRs 0046 and 0051 — and that gives the worktree rule a
disposition for a repository whose children never commit.

Consumed: `.claude/policies/version-control.md`, "The unit is the effort, not the ticket" — crystallize/04 (ADR 0077)
