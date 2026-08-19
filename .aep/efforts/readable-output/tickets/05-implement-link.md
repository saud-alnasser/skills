---
aep: 2.6.0
owner: repository
date: 2026-08-19
kind: ticket
status: resolved
part-of: readable-output
blocked-by: [02]
---

# docs(implement): close-out routes to the reconciliation the orchestrator owes

## Outcome

The orchestrator's post-dispatch obligation is reachable from the skill that
dispatches, not only from the policy that states it. `skills/implement.md`'s
close-out links to it.

## Acceptance Criteria

- [ ] `src/skills/implement.md`'s close-out links to `[[policies/execution]]`'s
      reconciliation section, in a sentence saying what the link is for
      (criterion 15).
- [ ] The link is a pointer, not a summary. The three obligations are not restated
      here.
- [ ] `stageNames()` still extracts a name for every one of this skill's steps,
      and every existing `skills/implement` assertion in `verify.mjs` passes:
      the position fill, the *Nothing to report is still reported* line, the
      stages-of-this-turn line, the no-splitting line, and the external frontier
      line.

## Relevant areas

`src/skills/implement.md`, section `## 4 — Close out`.

## Constraints

- **Stay bounded.** This is one link and the sentence that carries it. The
  close-out's existing routing to review and commit is untouched.
- `skills/implement.md` is pinned by six separate assertions. Read them before
  rewording anything around the insertion point.

## Notes

Blocked by 02 because the section this points at does not exist until then.
