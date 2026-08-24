---
status: open
blocked-by: [02]
---

# feat(policies): the claim is read before the work, and confinement has no exemptions

## Outcome

`policies/execution` already says the branch is the claim. It gains the half that
makes that mean something: the claim is read on entry, a run writes nothing
belonging to an effort outside it, a named effort outside the claim stops on a
dirty tree and switches on a clean one, and a ticket branch is unique across
efforts.

## Acceptance Criteria

- [ ] The policy states that a run resolves its claim before acting and quotes the
      script's output rather than judging a branch name (criterion 1).
- [ ] It states the ambiguity stop: a run needing one effort, given a larger claim
      and none named, ends the turn listing the set (criterion 4).
- [ ] It states confinement, that reading is unrestricted, and that source outside
      `efforts/` is untouched by the rule (criterion 5).
- [ ] It states that there are no exemptions, including for a skill whose subject
      is the whole tree, and that such a run belongs on an unscoped checkout
      (criterion 5).
- [ ] It states the mismatch behaviour, clean switches and dirty stops, naming
      what the stop must report (criterion 6).
- [ ] It states that a ticket branch must be unique across efforts and that the
      mechanism is the repository's to fix in its own rule (criterion 8).

## Relevant areas

`src/policies/execution.md`, the section "Claiming, before dispatching", which is
where the existing claim rule sits and where these belong beside it.

## Constraints

- A policy states what MUST hold, never how a skill phrases it. The invocation
  belongs in the skills; the obligation belongs here.
- Do not restate the resolution algorithm. It is in the script and in
  `[[efforts/51-branch-scope/plan]]`; a policy carrying a copy is a second place
  it can change.
- Keep the existing claim paragraph. This extends it rather than replacing it.

## Notes

Confinement has no exemption list on purpose, and the reason belongs in the
policy as an italic *why*: an exemption is a second mechanism deciding how strong
the first one is, and it is the copy that goes wrong.
