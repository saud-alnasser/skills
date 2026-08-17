---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: tracker-labels
blocked-by: [01, 02, 03, 04]
---

# test(verify): the shipped surfaces are asserted against the new requirement

## Outcome

Every checkable claim this effort adds has an assertion in `verify.mjs`, in the
existing pinned-phrase idiom, in the section that owns the surface — and each one
has been **observed failing** before it is trusted.

## Acceptance Criteria

- [x] `policies` section: the policy requires an external task to be findable in
      its tracker, and keeps status and edges out of labels with their reasons.
- [x] `skill notes` section: the note states the three steps in order; forbids
      creating a label for a natively-modelled fact; carries the two-tracker
      style example; requires the resolution to be recorded; names labels and
      milestones in the creation gate; states it writes the section where none
      exists.
- [x] `skills` section: `skills/implement` computes an external frontier by
      query.
- [x] `seeds` section: both forge seeds carry the recording section.
- [x] The generic assertions still cover the new files without change — the note
      is linked from its skill, one level deep, not published as a command; no
      shipped text cites `specs.md`; the fixture index still has no `## Tickets`
      section.
- [x] **Each new assertion is perturbed**: delete the pinned phrase from the
      shipped file, run the suite, confirm it fails **naming that assertion**,
      restore. Quote one such failure in the close-out.
- [x] `node src/scripts/verify.mjs` passes, and the count of passes rises by at
      least the number of assertions added.

## Relevant areas

`src/scripts/verify.mjs` — sections `policies` (~line 469), `skills` (~318),
`skill notes` (~389), `seeds` (~515). The idiom is
`assert('<claim>', () => /<phrase>/.test(readSrc(...)))`.

## Constraints

- **A green run proves nothing until the perturbation is confirmed to have
  removed the subject** (`[[rules/authoring]]`). The recurring failure here is a
  guard that matches something travelling *with* the thing it checks.
- Pin phrases that carry the meaning, not incidental wording. A phrase that a
  legitimate rewrite would drop makes the suite brittle for no safety.

## Notes

The suite is the only thing that catches a broken build here — there is no
compiler and no test runner. An added claim without an assertion is untested by
construction.
