---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: ticket
status: resolved
part-of: policy-rule-split
---

# feat(policies): nine rules consolidate into four protocol-owned policies

## Outcome

`src/policies/` holds `authority.md`, `engineering.md`, `execution.md`, and
`artifacts.md`. `src/rules/` is gone. Every normative sentence from the nine
rules has a recorded destination, and the four files read as written rather than
as concatenated.

## Acceptance Criteria

- [ ] Four files exist under `src/policies/`, each declaring `kind: policy`,
      `owner: protocol`, and a `use-when` naming a moment rather than a subject.
      *(spec criteria 1, 5, 6)*
- [ ] No file declares `mode:`. Only `artifacts.md` declares `paths:`, as
      `.aep/**/*.md`. *(spec, Architecture — Decision 1)*
- [ ] Each policy carries a `##` section named for each rule it absorbed, so the
      content stays findable by the name it had.
- [ ] `src/rules/` no longer exists.
- [ ] `authority.md` states the policy → rule → effort → task order, and states
      what a rule may and may not do to a policy. *(spec criterion 4)*
- [ ] The `## Mapping` section of this ticket is filled in: every one of the nine
      rules, its destination policy, and — for anything deliberately dropped —
      the reason. *(spec criterion 7)*
- [ ] No policy cites `specs.md`, a section number, or anything else that exists
      only in this repository. *(spec Constraints)*
- [ ] `verify.mjs`'s `rules` section becomes `policies` and asserts the four
      ship, each `kind: policy` with a `use-when`; its `forbidden` section stops
      forbidding `policies/` while still forbidding `decisions/`, `tools/`, and
      `grill/`. *(`[[rules/authoring]]` — the suite moves in the same pass)*

## Relevant areas

`src/rules/` — the nine sources. `src/policies/` — new.
`[[templates/rule.template]]` for the artifact shape.

## Constraints

- **This is an editorial merge, not a rewrite.** The reason each rule gives for
  itself is load-bearing and survives. Where two absorbed rules said the same
  thing, one statement remains and the duplication is noted in `## Mapping`.
- The two cross-references that motivated the merges — `evidence` deferring to
  `engineering`, `ownership` deferring to `artifacts` — become ordinary prose
  inside one file rather than links to a file that no longer exists.
- Links to `rules/version-control` stay as they are: it remains a rule.
- Do not touch links in any file outside `src/policies/`. That is task 02.

## Notes

The four groupings, and the alternatives that lost, are in
`[[efforts/policy-rule-split/spec]]` under Architecture — Decision 1. The human
chose four; the `execution` merge carries a known cost, recorded under Technical
Risks.

## Mapping

Filled in by the implementer as the merge is performed. One row per source rule.

| Source rule | Destination | What changed, and why |
| --- | --- | --- |
| `rules/precedence.md` | `policies/authority.md` | Rank 5 split into two: policies then rules. "Rules outrank references and contexts" generalised to "Governance outranks…". "Between rules" became "Between policies and rules" and gained the tighten/never-soften contract — **new normative content**, required by spec criterion 4. |
| `rules/boundary.md` | `policies/authority.md` | Intact. The `## Worktrees are not another repository` heading became the closing paragraph of the same section; no sentence dropped. |
| `rules/engineering.md` | `policies/engineering.md` | Intact. "Obeying a rule means letting its check fire" reworded to "the letter of a requirement", since it now covers policies as well as rules. |
| `rules/evidence.md` | `policies/engineering.md` | Intact. Its opening paragraph deferring to `engineering` became a one-line transition — the two files are now one, so the cross-reference had nothing left to point at. Grill's conclusions now land in "a policy, a rule, a context". |
| `rules/change-control.md` | `policies/execution.md` | Intact, unchanged. |
| `rules/sub-agents.md` | `policies/execution.md` | Intact. Its "applies only where the runtime supports sub-agents" preamble moved from the file head to the section head, which is what it now scopes. "Parallelism MUST NOT compromise the rules" → "governance". |
| `rules/artifacts.md` | `policies/artifacts.md` | Intact, plus required amendments: `policy` added to the `kind` list, `policies` removed from the forbidden directories, `use-when` required list gains policies. |
| `rules/ownership.md` | `policies/artifacts.md` | Intact. Its closing "See `rules/artifacts` for the shape" dissolved — same file now. "Which is which" gained the policies/rules split and the one-owner-per-directory paragraph. |
| `rules/placement.md` | `policies/artifacts.md` | Intact. `## The test` and `## Consequences` folded into the "Where it goes" section as prose; the `.aep/` contents list gained `policies`. |

**Nothing was dropped.** Four sentences were generalised from "rule" to
"governance" or "requirement" because they now bind both layers, and three
cross-references between merged files dissolved into the prose that absorbed
them. 581 source lines became 553, and the difference is those cross-references
plus three headings that became paragraph leads.
