---
owner: repository
title: chore(release): install Tenure and remove the mattpocock skills
status: resolved
blocked-by: []
---

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

## Comments

**The install method above is superseded by ADR 0015.** Tenure ships as a
plugin installed at `local` scope, not as a copy into `~/.claude/skills/` —
that location is personal scope, which means _every_ project, and the
requirement is personal _and_ per-project. So "copy `./skills/*`", the
copy-not-symlink note, and the first acceptance criterion no longer describe
the work. Ticket 20 builds the distribution form; this ticket now depends on
it, and its remit narrows to the parts that survive.

**What survives unchanged:** removing the mattpocock skills, deciding what
happens to `teach` and `find-skills`, trimming the global `CLAUDE.md` to cede
the engineering rules, backing up first, and counting the context load. That
last one still bites under a plugin — a model-invoked skill's `description`
is paid on every turn whether it arrives by plugin or by directory, and it has
still never been measured.

**One criterion got easier rather than moot.** Built-in `/review` was the
collision decision 13 avoided by naming the skill `code-review`; under a
namespace `/tenure:review` cannot shadow it, so the criterion holds by
construction instead of by naming discipline.

**Ticket 20 has landed**, so the distribution form now exists: add this
repository as a marketplace and install `tenure@tenure-marketplace` at `local`
scope, per `README.md`. This ticket is unblocked and its remit is the list
above.
