---
status: resolved
blocked-by: [09, 11]
---

# chore(dist): release 2.7.0, with the notice a widened policy owes its readers

## Outcome

2.7.0 is the version of record, the notice tells an installed repository what to
check, and this repository's own `.aep/` tree is reinstalled from it.

## Acceptance Criteria

- [ ] `NOTICES` gains a `2.7.0` entry saying that text an agent writes for a human
      is now governed by a policy, and that a repository with its own prose
      conventions has to reconcile them: a rule may tighten a policy and never
      soften it.
- [ ] The notice text carries no em dash. It is printed to a human, so the policy
      it announces governs it.
- [ ] `node src/scripts/release.mjs 2.7.0` sets the version of record, stamps only
      the artifacts whose content changed, updates `src/stamps.json`, syncs the
      plugin manifest, and regenerates the adapters.
- [ ] `CHANGELOG.md` gains a `## 2.7.0` section, written without em dashes.
- [ ] `node src/scripts/verify.mjs` exits zero, stamps baseline included
      (criterion 16).
- [ ] The repository is reinstalled and `node .aep/scripts/validate.mjs` exits
      zero, with no remaining failure from `.aep/skills/unslop.md` (criterion 16).
- [ ] `node .aep/scripts/index.mjs` regenerates, and the policies table shows the
      widened trigger while the skills table shows `prose` (criterion 1).
- [ ] The install fixture's upgrade path reports the new notice.

## Relevant areas

`src/scripts/payload.mjs` holds `NOTICES`. `src/scripts/release.mjs` cuts the
release. `CHANGELOG.md` is hand-written.

## Constraints

- **Never restamp by hand.** `aep:` records the release an artifact's content last
  changed in, and a sweep destroys the only information the field carries
  (`[[rules/authoring]]`).
- Nothing is pushed and nothing is published.

## Notes

The notice is the one thing this release asks of a reader. Nothing structural
changes in their tree: no new frontmatter field, no moved file, no failing
validation. What changes is the governance layer above their own rules, and a
rule that softens a policy is the failure they need to be able to see.
