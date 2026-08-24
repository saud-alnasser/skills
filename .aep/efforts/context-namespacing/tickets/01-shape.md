---
status: resolved
---

# docs(specs): a context may be namespaced by project, and the template says so

## Outcome

Both legal shapes are defined normatively and taught where an author meets them.
`contexts/<area>.md` and `contexts/<project>/<area>.md`, one project directory
deep and no more, with the directory naming and `paths:` scoping — stated in the
specification and in the template that an author actually copies from.

## Acceptance Criteria

- [ ] §12 defines both shapes and **bounds the depth**: one project directory is
      the deepest legal form. A specification that describes nesting without
      bounding it is the broken version.
- [ ] §12 states which mechanism answers which question — the directory names,
      `paths:` scopes — and that neither is derived from the other.
- [ ] §12 says `<project>` is the repository's word: AEP does not define what a
      project is and does not check the directory against the repository's layout.
- [ ] §5's canonical layout shows the nested form.
- [ ] §32.2 lists the assertions the suite must make, and §35 gains one
      invariant, both in the register of their existing entries.
- [ ] `src/templates/context.template.md` gives **both** shapes in its copy-to
      line, plus the one line that chooses between them: nest when two projects
      would otherwise fight over the same area name.
- [ ] The template states that a nested context still declares `paths:` — the
      directory is not a scope.
- [ ] The template's own instruction is not merely prose further down: an author
      who reads only the first line still learns both shapes.

## Relevant areas

`specs.md` §5 (~line 118), §12, §32.2, §35. `src/templates/context.template.md` —
its first instruction is line 10.

## Constraints

- **`specs.md` is not shipped** and may cite section numbers; the template **is**
  shipped and may not cite `specs.md` or a section number
  (`[[rules/authoring]]`).
- Define the shape; do not describe the implementation. How `validate.mjs`
  rejects a deeper file is ticket 02's, and what the suite asserts is ticket 03's.
- The seeded `contexts/repository.md` stays at the root of `contexts/`. Nothing
  in this ticket suggests moving an existing flat context.

## Notes

Everything this must contain is in [[efforts/context-namespacing/spec]] —
Requirements 1 through 6, and the Interfaces section, which already carries the
exact wording for the template's choosing line.
