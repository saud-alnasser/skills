# feat(commit): the transaction boundary

Status: ready-for-agent
Blocked by: 02, 04, 05

## Problem

In `workflow.md`, `/commit` runs a full sync and re-validates the implementation. Both are rediscovery: `/implement` already ran the suite and wrote the knowledge, `/code-review` already checked conventions and boundaries. Repeating them is the error ADR 0010 removed from sync.

What is left is genuinely `/commit`'s, and only `/commit`'s — every item needs either the finished diff or the commit itself to exist.

## Outcome

`./skills/commit/` — model-invoked, because `/implement` closes out through it.

Ticketed work commits through `/implement`, which claims, builds, reviews, commits, and resolves in one invocation. `/commit` is invoked directly for work with no ticket — hand-written edits, or a change made outside the flow — and is the shared implementation both paths use.

### Confirm, don't repeat

Three cheap checks that the prior stages ran. Each is a **question about state**, not a re-execution:

- Were tests run and did they pass? If `/implement` never ran the suite, stop.
- Did `/code-review` run, and are its findings resolved or ticketed? An unresolved finding is a blocker or a ticket, never a silent pass.
- Is the work actually finished against its ticket or spec?

A failure here is **reported**, not fixed. `/commit` does not implement, review, or research — it refuses and says which stage is incomplete.

### The four things only `/commit` can do

**1 — Diff-vs-knowledge consistency.** Not rediscovery: a whole-diff question that no earlier stage could ask, because `/implement` sees one ticket at a time and `/commit` sees the change entire. Did this change move a boundary, retire a concept, or relocate something a Source Pointer names — and does `.claude/context.md` say so? Fix what the diff contradicts; add nothing that fails the compression test.

**2 — The message.** Conventional Commits `type(scope): summary` as the **default when the repository is silent** (ADR 0008). Detect first: `CONTRIBUTING.md`, then recent `git log`. Where the repo documents or demonstrates another convention, follow it. Scope names the engineering domain; reject `misc`, `stuff`, `update`. Say what capability changed and why — never a file-by-file account.

**3 — Mark the spec.** Acceptance criteria may span several commits, so only here is the last one known. When this commit completes them, set `status: implemented`. Only the status line moves; spec content is never rewritten.

**4 — The Marker.** After the commit exists, write its SHA to `.claude/marker.json`. This ordering is not a detail — a commit cannot contain its own SHA, which is why the Marker is machine-local and written last (ADR 0005, 0010).

## Acceptance

- `/commit` never runs tests, never reviews, never researches. It confirms those happened and refuses when they didn't.
- The Marker equals `HEAD` after a successful commit, so the next verification is a single `git` check and nothing more.
- A commit whose diff contradicts `.claude/context.md` is blocked until context is corrected.
- A validation failure names the incomplete stage rather than reporting a generic refusal.
