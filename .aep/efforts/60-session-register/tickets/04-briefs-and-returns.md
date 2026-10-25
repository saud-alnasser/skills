---
status: resolved
blocked-by: [01]
---

# feat(agents): a brief, a return, and a relayed question take the controlled register

## Outcome

What one agent writes for another is no longer exempt. The brief, the child's
return, and a question a child sends up for the human are written in the
controlled register, and a relayed question reaches the human as an option set.

## Acceptance Criteria

- [x] Criterion 12: `skills/implement/dispatch.md` requires the brief in the
      controlled register; `policies/execution/parallel.md` requires it for the
      brief and the return; the `## Return` section of `agents/implementer.md`,
      `agents/researcher.md`, `agents/reviewer-correctness.md`, and
      `agents/reviewer-standards.md` each requires it. Each by a link to
      `[[policies/reporting]]`.
      Verified: `verify.mjs --section policies` passes the dispatch, parallel,
      and four `agents/<name> writes its return in the controlled register`
      assertions.
- [x] Criteria 7 and 8, for `parallel.md`: a child's question for the human is
      recorded as an option set, by a link to the policy's option-set section.
      The rule that the orchestrator may reshape wording but never substance
      stays as it is.
      Verified: "parallel has the child record the question as an option set"
      and "keeps substance out of what may be reshaped" pass.
- [x] No agent file names `skills/prose` (an existing assertion still passes).
      Verified: "no agent brief carries the catalogue down to a child" passes.
- [x] Criterion 11: `verify.mjs` asserts each link above. Each new assertion is
      seen to fail once with its subject removed.
      Verified: 7 of 7 new assertions fired under perturbation. The full suite
      fails only on stamps (expected until 07). `parallel.md` is 722 words
      before the edit and under 800 after; `check.mjs`: 0 of 39 files over.

## Relevant areas

`src/skills/implement/dispatch.md`, `src/policies/execution/parallel.md`,
`src/agents/*.md`, `src/scripts/verify.mjs`.

## Constraints

- `parallel.md` stays at most 800 words, and `dispatch.md` at most 600.
- The return shape (done, failed, stopped, or waiting, a path, and a capped
  summary) does not change. Only the wording rule is added.
