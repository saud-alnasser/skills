---
status: resolved
blocked-by: [02]
---

# docs(update): a 1.x policy converts to a repository rule, never to a policy

## Outcome

`/update` distinguishes the 1.x `policies/` directory from the 2.2 one by path
and by meaning, and says out loud that the two uses of the word are inverted.

## Acceptance Criteria

- [ ] `skills/update.md`'s routing table names the 1.x marker as a `policies/`
      directory **under the runtime's own directory**, so `.aep/policies/` cannot
      be read as evidence of 1.x. *(spec criterion 11)*
- [ ] `skills/update/migration.md`'s Policies section states that a 1.x policy
      converts to a repository **rule** or to nothing, and states why: 1.x
      policies were derived per repository, and 2.2 policies are protocol law.
- [ ] The section no longer says "2.0 has one governance layer" — it has two, and
      the conversion target is the repository-owned one.
- [ ] `skills/update.md` step 5 covers a rule colliding with a *policy* name as
      well as with a rule name, since the shipped names have moved directory.
- [ ] The upgrade procedure mentions that a release may declare moves, and that
      moved links in repository-owned files are rewritten and reported.

## Relevant areas

`src/skills/update.md` — the routing table and steps 5 and 7.
`src/skills/update/migration.md` — the conversion table around
`policies/<concern>.md`, and the `### Policies` section beneath it.

## Constraints

- **The word is inverted across the version boundary, and prose has to carry
  that** — the tooling change in task 04 handles detection, but a human reading
  an old migration report is the failure this text exists to prevent.
- Do not restate the mapping from task 01 here. Link to what governs.
- 1.x carry-across behaviour is otherwise unchanged: nothing is deleted, nothing
  lands unreviewed.

## Notes

Recorded in `[[efforts/policy-rule-split/spec]]` under Risks as the failure mode
this task addresses.
