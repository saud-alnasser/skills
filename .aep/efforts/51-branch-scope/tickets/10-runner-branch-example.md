---
status: resolved
---

# fix(skills): the runner's ticket branch example carries the effort namespace

## Outcome

`[[skills/implement]]` shows the branch names a run creates. Its ticket branch
example is the bare form this effort just made non-unique, so the shipped skill
and the shipped rule disagree about the same name, and a repository following
both gets two answers.

## Acceptance Criteria

- [x] The branch table in `skills/implement.md` shows a ticket branch as
      `<effort>/<ticket-id>-<slug>`, with an example matching the form
      (criterion 8).
- [x] No shipped surface still presents a bare `<ticket-id>-<slug>` as the ticket
      branch form (criterion 8).
- [x] The suite asserts it over the shipped surfaces, and the assertion was seen
      to fail against the bare form (criterion 11).

## Relevant areas

`src/skills/implement.md`, the branch table under the claim step, which sits
beside the sentence saying a repository's own convention wins. That sentence
stays: the example is what changes.

## Constraints

- **The example changes; the rule about who owns branch naming does not.** The
  repository's convention still wins, and the skill still says so.
- Do not restate why the namespace exists. That reasoning is in
  `[[policies/execution]]` and in the version-control rule, and a third copy is
  the one that goes stale.

## Notes

Raised by the sub-agent that built ticket 04, which left it alone rather than
reach into a parallel ticket's subject. That was the right call at the time and
the reason this exists as its own ticket rather than as a line in someone else's
diff.
