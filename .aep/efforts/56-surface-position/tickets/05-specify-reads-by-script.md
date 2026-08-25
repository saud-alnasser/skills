---
status: resolved
blocked-by: [02]
---

# feat(specify): specify reads position by script rather than by prose

## Outcome

`/specify` invokes `position.mjs` at step 1 instead of telling the agent to read
`position/marker.json` and compare it by hand. The one skill that reads position
without running the script stops being an exception, and the invoker set becomes
something the suite can assert against the skills rather than around one of them.

## Acceptance Criteria

- [x] Criterion 5: `grep -n "position\.mjs" src/skills/specify.md` returns line 22;
      `grep -c "position/marker.json"` returns 0. Pinned mechanically by two
      assertions so it survives a later rewrite, including one that the skill
      stamps nothing **and says why**. Independently re-checked at integration:
      removing the script call gave `2000 passed, 3 failed` with the diagnostic
      printing `on disk: implement, install`, then `2003 passed, 0 failed`
      restored.
- [x] The sentence "`specify` reads position/marker.json directly and runs no
      script, which is why it is not here" is gone;
      `grep -c "which is why it is not here"` returns 0. The merged comment gives
      `specify` a reason of its own: it reads the surface it was invoked in,
      before it opens the effort into another, and stamps neither.

Its stamps.json edit, made at `3.2.0` to get its own tree green, is superseded by
the single re-cut at ticket 09.

## Relevant areas

`src/skills/specify.md` — step 1, "Orient". `src/scripts/verify.mjs` — the comment
at the invoker-set assertion, which currently reads "`specify` reads
position/marker.json directly and runs no script, which is why it is not here".

## Constraints

- The read stays against the surface `/specify` is standing in at step 1, which is
  the checkout it was invoked in. `/specify` has not taken a surface yet at that
  point, and the effort it is about to open does not exist. This is not the
  cross-surface split ticket 04 fixes.
- Do not add a stamp. `/specify` commits in the surface it creates, and stamping
  the surface it is leaving would reintroduce exactly the split this effort
  removes.
- Shipped text may not cite `specs.md` ([[rules/authoring]]).

## Notes

Ticket 06 also edits the invoker-set assertion. Whichever lands second updates the
set to its final five members; both must leave the comment stating why each member
is in it. If they collide, the resolution is the union of the two sets, never the
one that happens to be second.
