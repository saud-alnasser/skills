---
status: resolved
blocked-by: [07]
---

# docs(spec): the specification follows the implementation it defines

## Outcome

The normative specification states AEP 3: the primitive set, the frontmatter contract, the absence of modes, the skill surface, the workflow spine, the adapter entrypoint contract, and installation and upgrade under a manifest.

## Acceptance Criteria

- [x] Criterion 46: the suite exits zero and every claim the specification makes about a shipped surface is asserted against it.
- [x] The frontmatter section states `use-when` and `paths`, states the four checks, and no longer describes any removed field except in the migration section.
- [x] The modes section is removed and the sections that referenced it are corrected rather than left pointing at nothing.
- [x] The upgrade section states the two classification mechanisms and the condition under which the older one is removed.

## Relevant areas

The specification at the repository root, and `src/scripts/verify.mjs` throughout.

## Constraints

The specification is not shipped, so it may name itself and its own sections. Shipped text may not (`[[rules/authoring]]`).

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

**Built.** `specs.md` now describes AEP 3, and `section('the specification')` in `src/scripts/verify.mjs` (39 assertions) checks its counts and lists against the payload that is supposed to satisfy them.

**The modes section was removed by renumbering, not by leaving a hole.** Sections 15 to 35 became 14 to 34, and every one of the 60-odd `§N` citations moved with them. Two derived sub-sections were added: `§8.1` for the four `use-when` checks, and `§30.1` for the upgrade's two layout classifiers, which pushed the 1.x migration to `§30.2` and its three inbound citations with it.

**A renumbering is exactly the edit that breaks silently** — every citation still reads correctly while pointing at different text. So the specification now requires that every section reference resolve, and the suite checks it. It caught one immediately: `verify.mjs` pinned `### 29.1 Targets and shapes` in a regex, which the renumbering had turned into `28.1`. All 28 section citations in `verify.mjs`'s own comments were remapped in the same pass.

Six fire-checks, each confirmed to have changed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| one citation retargeted to a section that does not exist | every section reference in specs.md resolves, printing `dangling: 99` |
| an eighth primitive row added | names seven primitives; same primitives; retired primitives not listed |
| `commit` put back in the Spine line | the specification and the payload name the same skills, printing both lists |
| an `owner` row added to the frontmatter table | the live contract does not describe `owner` |
| the fourth `use-when` check deleted | specs.md states four use-when checks |
| a Modes row added to `protocol.md`'s table | the specification and the bootstrap name the same primitives |

**One guard was self-referential and now is not.** `the skill set is exactly the specs.md names` compared the skills on disk against `SKILLS` in `contract.mjs` and never opened `specs.md` at all; both move in one commit, so a specification left behind could never fail it. The new assertion parses the skill names out of the specification's own grouped list and compares those.

**Carried beyond the stated criteria**, because the sections would otherwise have contradicted what already landed: `plan.md` reinstated as an effort artifact (`§14.2`) with the 2.0 prohibition and invariant 21 rewritten rather than left standing; tickets made unconditionally local (`§14.4`); the workflow spine rewritten to four typed commands with `refine`, `research`, `review`, and `converge` as stages (`§21`); the report contract's two forms collapsed to one (`§15.2`); and `§32` restructured to record what each release removed, with the two 3.0 reversals stated as reversals rather than quietly applied.

**Six invariants added** (50 to 55) for the four typed commands, the effort opening, ticket traceability, the effort as the unit of an invocation, converge appending rather than editing, and the pull request as the run's memory.
