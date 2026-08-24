---
status: resolved
blocked-by: [02]
---

# feat(protocol): the bootstrap and the templates name both governance layers

## Outcome

`protocol.md` lists Policies among the primitives, routes to four policies rather
than nine rules, and places the repository's own rules beside them. The templates
stop describing a single governance layer.

## Acceptance Criteria

- [ ] The primitives table gains a Policies row and keeps Rules, each answering a
      distinct question. *(spec criterion 1)*
- [ ] The load-when table lists the four policies against their triggers, plus one
      line saying a repository's own rules sit beside them. *(spec criterion 5)*
- [ ] The state layout shows both `policies/` and `rules/`.
- [ ] `protocol.md` still routes and does not govern: no policy text is restated
      there.
- [ ] `protocol.md` is under 8 KB. *(spec criterion 13)*
- [ ] `templates/rule.template.md` names *repository* governance in its heading
      and `use-when`, and no `templates/policy.template.md` exists. *(spec
      criterion 8)*
- [ ] `templates/protocol.template.md` no longer calls the bootstrap "not a policy
      database" — the phrase now reads as being about `policies/`, which is the
      opposite of what it means.

## Relevant areas

`src/protocol.md`, `src/templates/rule.template.md`,
`src/templates/protocol.template.md`. Check `src/templates/agents.template.md`
and `src/templates/context.template.md` for the same phrasing problem.

## Constraints

- **A repository never authors a policy**, so no policy template ships. The rule
  template is the one a repository uses, and it should now say so plainly rather
  than by omission. *(spec, Out of Scope)*
- The table shrinks from ten rows to five. The budget was 6,918 of 8,192 bytes
  before this effort; check the number rather than assuming the change is
  neutral.
- Do not restate the policy→rule authority order here. `policies/authority.md`
  states it, and the bootstrap links.

## Notes

Task 02 has already rewritten this file's links; this task changes its structure.
The two are separated so the mechanical sweep is reviewable on its own.
