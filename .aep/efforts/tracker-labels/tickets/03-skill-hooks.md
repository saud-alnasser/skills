---
status: resolved
blocked-by: [02]
---

# feat(skills): tasks and implement route to the ladder

## Outcome

`/tasks` reaches the note when the answer to *where do tasks live* is a tracker,
and `/implement` computes an external frontier from the recorded query rather
than by listing every open issue. Neither skill restates the procedure.

## Acceptance Criteria

- [x] `skills/tasks.md` step 2 gains one branch: where tasks live in an external
      tracker, go to the note before writing anything, linked by its wiki path
      `skills/tasks/labels`.
- [x] The link makes the note reachable, satisfying the suite's rule that a note
      is linked from its own skill.
- [x] `skills/implement.md` step 1 states that where tasks are external, the
      frontier comes from the recorded query, and that the edges are read from
      what the tracker returns.
- [x] Neither skill instructs an agent to list every open issue and judge from
      prose.
- [x] The local-ticket path is **unchanged** in both files.
- [x] Neither file grows a copy of the ladder.

## Relevant areas

`src/skills/tasks.md` — step 2 already asks where tasks live and already forbids
mirroring; this extends it rather than replacing it.
`src/skills/implement.md` — step 1, the frontier table and the paragraph under it
that already says where tasks live is the repository's business.

## Constraints

- Both files are protocol-owned payload. Keep the additions short — these are the
  two most-loaded skills in the set.
- `skills/implement.md` must keep the sentence forbidding a task being split
  across sub-agents; the suite pins it by phrase.

## Notes

`implement.md` already says *read `[[references]]` rather than assuming*. The
change is that there is now something definite to read, and a query to run.
