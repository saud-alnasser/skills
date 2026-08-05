---
title: feat(knowledge): state this repository's version-control policy
status: resolved
blocked-by: [04, 05]
---

## Problem

This repository's branch convention and commit discipline are not written down anywhere a reader can find them, and its tracker configuration carries the branch naming section ticket 05 moves out of the template.

## Outcome

This repository states its own version-control policy in the new file, its tracker configuration is about the tracker again, and its always-on entrypoint names both.

## Acceptance

- This repository's version-control policy file states that it uses plain git, its branch convention, its commit discipline, and the never-push rule.
- The tracker configuration no longer carries branch naming.
- The root always-on file names both policy files and is under 200 lines.
- A reader with no plugin installed can reach every instruction this repository depends on starting from the root always-on file.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**Everything in the file was detected, not asserted.** Plain git, from the absent `.git/.graphite_repo_config`. The branch convention off the six branches this effort has actually used. The commit discipline off all 27 commits: no merge commits anywhere, `Refs:` carrying a path to the ticket file, `Co-Authored-By` on every commit but the initial one and a one-line removal, and a two-clause subject joined by `, and` often enough to be the convention rather than an accident. The `Refs:` form has drifted twice — a bare number, then a `.scratch/` path — and only the current one is recorded, because the others describe a layout that no longer exists.

**Criterion 2 was already satisfied on arrival.** This repository's `.claude/tracker.md` never carried a `## Branch naming` section; the convention was demonstrated by the branches and written down nowhere. The assertion was added regardless — the criterion is that the tracker file does not carry it, and a criterion that happens to hold is not the same as one that cannot quietly stop holding.

**Deviation from criterion 1, identical to ticket 05's.** The never-push rule is reached by pointer, not restated: `CLAUDE.md` carries it unconditionally and a second copy is a second home. What this file states instead is how work lands here — the maintainer fast-forwards `main` in ticket order, no merge commits, no pull requests. Asserted in both directions.

**A real limit in the branch convention, recorded rather than fixed.** `NN` is scoped to the effort and the branch name does not carry the effort, so `01-` has already meant two different tickets. It has not collided because efforts run one at a time and the slug distinguishes them. Fixing it would mean changing the convention mid-effort, which breaks the reproducibility the convention exists for — so it is written down as the limit it is, and left for whoever first runs two efforts at once.

**Ticket 04's marking assertion was weak, and this ticket is what proved it.** It checked a hardcoded pair of ids for the word `subject` in a preceding comment, so adding a third section that reads `.claude/` by subject would have passed it silently — the exact widening it existed to prevent. Rewritten against a declared `$subjectSections` and checked both ways: a section marked but undeclared fails, and a declared section whose marker was deleted fails. Confirmed by mutation in both directions.

**Two guards from earlier tickets caught this ticket's own work**, which is the first time that has happened here. `layout/06`'s new reachability check found `CLAUDE.md` naming a bare `context.md` — legible in the sentence, ambiguous as a path to someone starting from the root file, which is precisely the reader criterion 4 is about. And `layout/04`'s tools-pointer check found this new file naming `.claude/tools/graphite.md` in the course of explaining why that file is *not* derived here. Both fixed at the source rather than exempted.

**The always-on template carries the same bare `context.md` wording** and was not changed — a `skills/` edit inside an adoption ticket is the boundary this effort has kept, the same call ticket 04 made about the shipped Graphite cross-reference. Worth a follow-up ticket; not worth silently crossing the line for.

**No Context update.** The policy/invocation split is ADR 0020's and already recorded there; nothing in `.claude/context.md` or the Domain Contexts moved.
