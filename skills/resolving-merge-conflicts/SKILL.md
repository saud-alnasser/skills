---
name: resolving-merge-conflicts
description: Resolve an in-progress merge or rebase conflict by recovering what each side was trying to do. Use when git reports conflicts.
---

# Resolving merge conflicts

Mode: maintenance

A conflict is two intents that a text diff could not reconcile. Recovering both intents is the work; editing the markers out is not.

1. **See the state.** Which operation is in progress, which files conflict, and what history each side carries. The invocations are in `.claude/tools/git.md`.

2. **Find the primary source for each side.** Why was each change made, and what was it for? Read the commit messages, the PR, the issue it closed. A hunk resolved without knowing what either side wanted is a guess with a clean diff.

3. **Resolve each hunk.** Preserve both intents where they can coexist. Where they genuinely cannot, take the one matching the stated goal of the merge and **say which trade-off was made** — a silent choice here is a behaviour change nobody reviewed.

   **Never invent new behaviour.** A third option that neither side wrote is not a resolution; it is an unreviewed change arriving through a merge, which is the one place nobody looks for it.

   **Always resolve. Never `--abort`.** Aborting throws away the analysis and leaves the same conflict for the next attempt.

4. **Run this repository's checks** — typecheck, tests, formatter, whatever it has. A merge that compiles is not a merge that works, and the tests are the only thing that distinguishes them.

5. **Finish the operation.** Stage the resolved paths by name and continue; on a rebase, keep going until every commit has landed. The invocations are in `.claude/tools/git.md`.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for AEP.
