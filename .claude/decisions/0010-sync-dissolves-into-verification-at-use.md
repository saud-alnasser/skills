---
status: accepted
load-when: a synchronisation or reconciliation pass is proposed
sources: [.claude/protocol.md]
supersedes: [0005]
superseded-by: []
---

# /sync dissolves; Context is verified where it is used

There is no synchronization stage. `/sync` is removed as a command, and the spine drops from eight to seven.

The Source Pointer Protocol already requires that Context is never trusted without checking it against source. If that discipline holds, a sync phase is redundant — verification happens at the moment Claude is about to rely on a statement, and **healing happens where the break is found**, not in a later pass. A scheduled reconciliation is Claude rediscovering, through the filesystem, things it either already knows or is about to check anyway.

The Marker changes job accordingly. It was "when do I run sync"; it is now a **cache-validity check**: when it matches `HEAD` and the working tree is clean, Context can be trusted without re-verification. That keeps the common path free.

What point-of-use cannot catch is knowledge **nothing references any more** — nobody loads it, so nobody checks it — and routing-table validation. That is periodic maintenance, and `/configure` already carries it: it is specified as idempotent, re-run "to improve repository understanding rather than duplicate documentation."

## Considered Options

- **Keep `/sync` model-invoked but never user-facing.** Behaviourally close, and it keeps the drift rules in one auditable file. Rejected because the logic belongs where it fires: a rule inside `/design` and `/implement` runs every time those run, where a rule in a skill they must remember to invoke does not.

## Consequences

Verification is now a discipline spread across `/design`, `/implement`, and `CLAUDE.md` rather than a single file. That is harder to audit and easier to erode — if the discipline lapses, nothing else catches it, because the safety net was the thing removed.

The mitigation is that the discipline is **strict and reported**: `/implement` emits a verification report on every invocation, including when there was nothing to verify. A silent rule erodes invisibly; a missing report is noticeable. "Nothing to check" must be stated in one line rather than expressed as silence, or it cannot be distinguished from the check never running.

The Marker file is named `.claude/marker.json`, since no command named sync remains to name it after.

Repository knowledge changes through `/design`, `/implement`, and `/configure` — never CI.
