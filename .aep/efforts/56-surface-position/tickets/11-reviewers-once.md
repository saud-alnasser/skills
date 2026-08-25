---
status: resolved
blocked-by: [04, 10]
---

# feat(implement): the reviewers are dispatched once, for the effort

## Outcome

`/implement` stops running review between integrating a ticket and landing it, and
runs it once at the close, after converge finds no gap, against the effort branch.
The two reviewer agents see the diff a human is asked to merge. An open finding
stops the pull request being marked ready.

## Acceptance Criteria

- [x] Criterion 12: two assertions, scoped to the `## 4` and `## 5` blocks by a
      local helper rather than by heading title. Perturbed separately, and
      **neither perturbation fired the other assertion**, which is what proves the
      pair is not one check written twice.
- [x] Criterion 14: `no rule parks a ticket after two review rejections, anywhere
      shipped` sweeps every `.md` under `src/` and names the file it finds one in.
      The handover gate is three further assertions, each of which fired alone on
      its own perturbation.
- [x] `review.md` step 2 leads with the effort's `spec.md`. The assertion parses
      the numbered rows and rejects any row naming the task the caller holds,
      rather than matching the new wording.
- [x] Criterion 16: the discriminating perturbation is the one the criterion
      demands, bound removed and path kept, which printed `the correction path is
      stated with no bound on the rounds`. It fails on exactly the document the
      criterion describes as unacceptable.

**Three judgement calls, all checked at integration.**

`review.md` step 1 justified reviewing the working tree by saying `implement`
calls it *before* it commits. This change makes that false, so the builder
rewrote the justification and left the union procedure itself untouched. No
assertion covered that sentence. Correcting prose its own change falsified is
right; it is the same class of defect ticket 12 raised two files over.

Landing step 1 said a criterion that cannot be met parks the ticket "with what the
review said". No review runs there now, so it reads "with what blocked it".

The new close sub-heading is `####` on purpose. `headingBlock` does a bare
`indexOf('## When a round finds no gap')`, so renaming that heading or inserting a
`###` sibling would have silently re-scoped a pre-existing assertion into throwing
`the close does not stamp the spec`. That is a trap this effort has now hit three
times in different forms, and this is the first time one was avoided rather than
discovered.

**Verified at integration that ticket 12's edit to the same file survived**, since
11 was built against a tip that predates it: the run log reads `the review round
and what it found`, the old wording is gone, and 12's assertion over it still
passes.

## Relevant areas

`src/skills/implement.md` — step 4 "Integrate, review, land, repeat", its
"Landing it" sequence, and the close where the issue and the pull request move to
`status: in review`. `src/skills/review.md` — step 2's ordered list.
`src/scripts/verify.mjs`.

## Constraints

- **Two assertions, not one.** "Review is named after converge" and "review is
  absent from the landing sequence" are each satisfied by a document that runs
  review twice. Criterion 12 needs both halves or it does not check what it says.
- Review stays a **stage** and opens no report of its own
  ([[policies/reporting]]). Moving when it runs does not make it a turn.
- `[[skills/review]]`'s own procedure is otherwise untouched. Its step 1 already
  pins a merge-base and reviews the union of the committed range and the working
  tree, which is what an effort subject needs, and its step 2 already falls
  through to the effort's `spec.md`. Promote the path that exists; do not add one.
- Landing reviewed work stays unprompted. The close still readies the draft, now
  gated on findings having outcomes.
- Shipped text may not cite `specs.md` ([[rules/authoring]]).
- Every assertion added here is seen to fail first.

## Notes

Blocked by 04 because both edit `skills/implement.md`. 04 moves the position check
in step 0 and step 2; this rewrites step 4 and the close. Different sections, one
file, so the edge is declared rather than discovered at integration.

**The correction path is the loop that already exists.** A validated finding
becomes a ticket, the ticket reaches the frontier, and the run schedules it. That
costs nothing extra because nothing has left the run's reach: the effort branch is
held in the orchestrator's own surface, its pull request is a draft, and `main` is
untouched. What must be carried forward from the rule being replaced is the bound,
which is why criterion 16 fails a description of the path that omits it.
