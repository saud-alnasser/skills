# feat(knowledge): verification at use, healing where the break is found

Status: ready-for-agent
Blocked by: —

## Problem

There is no `/sync`. ADR 0010 dissolved it: Context is verified where it is used and healed where a break is found, so a reconciliation stage would be Claude rediscovering what it already knows.

That leaves the drift rules with no single home. This ticket places them, and they must be placed well — the safety net was the thing removed, so if the discipline lapses nothing else catches it.

## Outcome

Not a skill. A discipline written into `CLAUDE.md`, `/design`, `/implement`, and `/configure`.

### The Marker — cache validity

`.claude/marker.json`, machine-local and gitignored, holds the commit Context was last verified against.

```
marker == HEAD  AND  working tree clean
  → Context is trusted as-is. No checking, no cost.

otherwise
  → verify the statements you are about to rely on
```

Drift has two sources: commits since the Marker (`git diff --name-only <marker>..HEAD`, excluding `.claude/context.md`, `contexts/*`, `docs/decisions/*`) and uncommitted human edits (`git status --porcelain`, excluding files Claude wrote this session). When the Marker is not an ancestor of `HEAD` — branch switch, rebase — the diff is meaningless and everything touched is unverified.

### Verification at use

Never a scan, never a phase. When a context statement is about to be relied on, check it against source. Scope is whatever the work touches; drift elsewhere is not this request's problem.

Source Pointers are verified before use, always — a pointer says *start here*, never what exists. A broken pointer is recovered by searching the repository, never by inventing a path. Unrecoverable pointers are reported, not guessed.

### Healing in place

Fix what you find, where you find it. A stale pointer is repaired in the same breath as discovering it is stale; a boundary that moved is corrected. No queue, no deferred pass.

### Strict, and reported

The discipline is **not best-effort**. `/implement` opens with a verification report on every invocation (ticket 04), and `/design` does the same before it loads context. Emitting the report is what makes the rule enforceable — a silent rule erodes invisibly, where a missing report is noticeable.

Even the trusted path reports, in one line. "Nothing to check" must be a statement, not a silence, or there is no way to tell it apart from the check never running.

### Marker advance

`/commit` sets it to the new `HEAD` after committing. Nothing else moves it.

### The periodic audit

Belongs to `/configure` re-run (ticket 08), because point-of-use verification structurally cannot catch knowledge **nothing references** — nobody loads it, so nobody checks it. Same for routing-table validation and unmarked specs whose acceptance criteria reality already satisfies.

## Acceptance

- The clean path costs one `git` check and no reading.
- No skill performs a startup scan.
- A broken Source Pointer is never replaced by an invented one.
- **Every `/implement` emits a verification report, including when there was nothing to verify.**
- Every rule here has exactly one home; `CLAUDE.md` carries only what must hold on turns where no skill runs.
