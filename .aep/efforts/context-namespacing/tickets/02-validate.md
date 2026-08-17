---
aep: 2.4.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: context-namespacing
---

# feat(validate): a context sits one project directory deep, no more

## Outcome

`validate.mjs` rejects a context nested deeper than one project directory, with a
message that names the file, the limit, and the two legal forms. Both legal
shapes still pass. The rule ships to every configured repository, because that is
where contexts are written.

## Acceptance Criteria

- [ ] `contexts/<area>.md` passes.
- [ ] `contexts/<project>/<area>.md` passes.
- [ ] `contexts/<project>/<x>/<area>.md` **fails**, naming the file and the legal
      forms. Whoever reads that line has no other source, so it carries both.
- [ ] **Fire-checked at all three depths, not just the failing one.** A guard
      proven only on the rejection can still be rejecting what it should accept.
- [ ] The check reads the `rel` and `segments` `checkArtifact` already computes —
      no new parsing, no second walk of the tree.
- [ ] The rule is written **for contexts**, with no table of directories and no
      extension point. `rules/` and `references/` are repository-wide and have no
      namespace to collide in; the reason is in the spec's Out of Scope and is not
      re-litigated here.
- [ ] **Nothing derives applicability from the directory.** After this change,
      `index.mjs` and `validate.mjs` still decide relevance from `use-when` and
      `paths` only — confirmed by reading both, not by assuming.
- [ ] The probe: create `contexts/<project>/<area>.md` in this repository's tree,
      show `node .aep/scripts/index.mjs` listing it and
      `node .aep/scripts/validate.mjs` passing it, **quote both**, then remove it.
      This repository is not a monorepo, and a context that documents nothing is
      worse than none.

## Relevant areas

`src/scripts/validate.mjs` — `checkArtifact`, beside the situational-field rules
(the `report` block added at 2.4.0 is the nearest shape). `src/scripts/index.mjs`
— read `SECTIONS` and `collect` to confirm nothing changes there.

## Constraints

- **`validate.mjs` ships.** Its failure text is read by a stranger with no
  context: name the file, the limit, and the legal forms in one line.
- **Reject; never repair.** `contexts/` is repository-owned. The validator says
  what is wrong and stops — it does not move the file, and neither does any
  installer.
- Do not touch `index.mjs`. Nested contexts already index; making that
  deliberate is ticket 03's assertion, not an edit here.

## Notes

The mechanism was probed before planning and already works — a nested context
validates, indexes, and resolves as a wiki link. This ticket adds the **bound**,
not the capability. See the Problem section of
[[efforts/context-namespacing/spec]] for what was measured.
