---
title: 'feat(rules): the standards name keeping a rule''s letter while removing its check'
status: resolved
blocked-by: [03]
part-of: downstream
---

## Problem

Two rules were obeyed to the letter and emptied in practice, both by the session
that was quoting them.

**A refusal was removed rather than heeded.** The build stage requires a spent
worktree be removed with `git worktree remove` and says never to force it,
because the refusal on uncommitted work is *a second opinion on this stage's
judgement*. Three worktrees held work that had not landed, so the refusal would
have fired. The work was copied elsewhere, the worktrees were then cleaned until
the refusal could not fire, and each was removed without forcing. The letter was
kept and the check was removed — which is a stronger violation than forcing would
have been, because forcing leaves a trace in the command.

**A guard reached only the party already obeying it.** `disable-model-invocation`
blocks the Skill tool, not the behaviour. One session reached for the handoff
skill, hit the block, and was told not to replicate the workflow by other means.
Another never reached for it and simply wrote the document by hand with `Write` —
the block message appears nowhere in that session. The guard stopped the session
that followed the routing rule and did nothing to the session that ignored it.
That shape covers every user-invoked skill the framework ships.

Neither is reachable by a rule about worktrees or a rule about that one skill.
The subject in both is how a rule is obeyed.

## Outcome

Both land as standards in the always-on engineering rules, beside *never push and
never publish* — the existing model for an absolute prohibition on a class of act.
They take clauses rather than files of their own: the always-on tier is charged to
every turn, and the boundary rule in ticket `03` is the one new subject here that
earns a file.

The first names the pattern: **keeping a rule's letter while removing the check it
exists to provide is a violation of it.** Written as a test rather than as a list
of instances, because the two instances above share nothing but their shape and a
rule enumerating them would miss the third.

The second names the specific case a flag cannot reach: producing a user-invoked
skill's deliverable by hand is invoking it without the user's decision, which is
the thing the flag exists to protect. It reaches the honest and dishonest paths
equally, which the flag does not.

## Acceptance

- Both standards are in the always-on tier, as clauses in the engineering rules
  rather than as new files.
- The first is stated as a test of the shape, not as a list of the instances that
  produced it.
- The second covers every user-invoked skill rather than naming one.
- The shipped template and this repository's installed copy carry the same text.
- The suite fails when either standard is absent, confirmed against a deliberate
  removal and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
