---
status: resolved
blocked-by: [01]
---

# feat(skills): every place that puts options to the human sends them as an option set

## Outcome

Each shipped file that puts a choice to the human links to the option-set rule
in `[[policies/reporting]]`, and no file carries wording that competes with it.
A human gets the same shape of question from refine, plan, specify, install,
update, and the tracker ask.

## Acceptance Criteria

- [x] Criterion 7: `skills/refine.md`, `skills/plan.md`,
      `skills/plan/design-it-twice.md`, `skills/specify.md`,
      `skills/install.md`, `skills/update.md`, `policies/tracker.md`, and
      `protocol.md` each require explanation, an illustration where structure
      differs, and a recommendation, by a link to the policy's option-set
      section.
      Verified: `verify.mjs --section reporting` passes "<file> puts its choice
      as an option set, linked to the policy" for all eight files.
- [x] Criterion 8, the link half: each of those files links to that one
      section, and none restates the picker fallback.
      Verified: the eight link assertions pass, and "the option-set rule and
      its fallback are stated in the policy and nowhere else" passes.
- [x] "reply yes or b", or any other instruction about how the human answers,
      appears in no payload file.
      Verified: "no shipped file tells the human how to answer" passes over
      every payload artifact. refine keeps its five questions and its
      recommended answer ("refine keeps five questions" passes).
- [x] `protocol.md` stays at most 1000 words: its edit is net zero.
      Verified: `check.mjs` prints `protocol.md 1000`, as before the edit.
- [x] Criterion 11: `verify.mjs` asserts the link in each file named above and
      the absence of the competing wording. Each new assertion is seen to fail
      once with its subject removed.
      Verified: 10 of 10 new assertions fired under perturbation.
      `node src/scripts/verify.mjs` fails only on stamps (expected until 07);
      `validate.mjs`: 243 artifacts checked, no failures.

## Relevant areas

The eight files above, and `src/scripts/verify.mjs`. The search that found them
is in `[[efforts/60-session-register/plan]]`, under Technical Risks.

## Constraints

- Do not touch `policies/execution/parallel.md`: ticket 04 owns it, including
  its question-relay sentence.
- A link, not a copy. No file other than the policy states what an option set
  contains.
- `refine` keeps its limit of five questions, one at a time, each with a
  recommended answer. Only the presentation changes.
