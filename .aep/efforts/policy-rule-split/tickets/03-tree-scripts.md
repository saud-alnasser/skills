---
status: resolved
---

# feat(scripts): the tree scripts know the policy primitive

## Outcome

`contract.mjs` declares what a policy is, `validate.mjs` enforces that a
directory holds only its own owner, and `index.mjs` gives policies their own
section above rules.

## Acceptance Criteria

- [ ] `KINDS` includes `policy`; `FORBIDDEN_DIRS` no longer includes `policies`;
      `USE_WHEN_REQUIRED_DIRS` includes `policies`. *(spec criteria 1, 5)*
- [ ] `contract.mjs` exports `DIRECTORY_OWNERS = { policies: 'protocol', rules:
      'repository' }`, and it is the only place that mapping is written.
- [ ] `validate.mjs` fails on a `policies/` artifact declaring `owner:
      repository`, naming the file and the required owner. *(spec criterion 3)*
- [ ] `validate.mjs` fails on a `rules/` artifact declaring `owner: protocol`,
      with a message that says the file belongs under `policies/`.
- [ ] Both failures were demonstrated by writing the offending file, running the
      script, and reading the output — not by inspection. *(spec Testing
      Strategy)*
- [ ] `index.mjs` emits a `## Policies` section with the same columns as Rules,
      ordered before it, and regeneration over an unchanged tree stays
      byte-identical. *(spec criterion 12)*
- [ ] Both `validate.mjs` failures above are asserted in `verify.mjs`'s install
      fixture, by writing the offending file and expecting a non-zero exit.
      *(`[[rules/authoring]]` — the suite moves in the same pass)*

## Relevant areas

`src/scripts/contract.mjs`, `src/scripts/validate.mjs`, `src/scripts/index.mjs`.
`SECTIONS` in `index.mjs` is the list to extend.

## Constraints

- `validate.mjs` keeps deciding everything else off the declared `owner` field.
  This adds one directory-scoped check; it does not start inferring ownership
  from paths anywhere else.
- The Rules section keeps rendering `_None._` when a repository has written no
  rules. That is a true and useful statement, unlike the empty Tickets section
  the index deliberately omits.
- These three scripts install into every repository. They stay dependency-free
  ESM runnable by a bare Node runtime.

## Notes

Why the invariant lives in `validate` rather than in `install` — preserve, then
report — is in `[[efforts/policy-rule-split/spec]]` under Architecture — Decision
3. It is the reason this task does not touch the installer.
