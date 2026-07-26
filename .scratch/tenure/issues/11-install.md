# chore(release): install Tenure and remove the mattpocock skills

Status: ready-for-human
Blocked by: 10

## Problem

Tenure is built in `./skills`. It has no effect until it's installed, and matt's skills must come out at the same time — leaving both installed means two vocabularies competing for the same jobs, and shadowed names resolving unpredictably.

## Outcome

Copy `./skills/*` into `~/.claude/skills/`, and remove the mattpocock skills Tenure replaces:

```
ask-matt          grill-me            grill-with-docs
setup-matt-pocock-skills             to-spec
implement         code-review         research
prototype         grilling            tdd
codebase-design   domain-modeling     to-tickets
wayfinder         triage              diagnosing-bugs
handoff           resolving-merge-conflicts
improve-codebase-architecture        writing-great-skills
```

Decide what happens to `teach` and `find-skills` — neither is part of Tenure and neither conflicts with it, so the default is to leave them installed.

Copy, not symlink: symlinks on Windows need Administrator or Developer Mode.

**Trim `~/.claude/CLAUDE.md`.** Tenure now owns the engineering rules (ADR 0007), so the global file cedes them — remove its Engineering section and its Precedence list, leaving personal preferences that are not Tenure's business. Skipping this step doesn't remove the duplication, it just moves it, and the two copies will drift.

This is outside any repository, so `/configure` cannot do it — it is a manual install step and the one most likely to be forgotten.

**Count the context load first.** Sum the `description` field of every model-invoked skill, plus the `CLAUDE.md` template — that is what every single turn pays, forever, before any work starts. We pruned frontmatter fields hard and never measured the larger cost. If the total is uncomfortable, demote spine commands to user-invoked and let `/tenure` carry the discovery instead.

**Back up `~/.claude/skills/` before removing anything.** This is the one step in the build that is annoying to undo.

## Acceptance

- `~/.claude/skills/` contains Tenure and nothing it replaces.
- Built-in `/review` still resolves to the GitHub PR reviewer.
- A new session lists the Tenure skills and none of the removed ones.
