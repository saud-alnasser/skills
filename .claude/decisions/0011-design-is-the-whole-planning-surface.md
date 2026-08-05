---
status: accepted
load-when: planning work is proposed outside /design
sources: [skills/design/]
supersedes: []
superseded-by: []
---

# /design is the whole planning surface

`/design <text>` owns everything between a request and a workable plan: grill the idea, discover the scope, decide which skills narrow it (`/research` for facts, `/prototype` for feel), and produce a spec and/or tickets when the scope warrants them. The user then calls `/implement`, which works the plan.

This absorbs three of matt's skills. `to-spec` and `to-tickets` have no independent trigger — nobody wants a spec without having designed, or tickets without a plan — so they are output *formats* the tier already selects, not separate activities. `wayfinder`'s map of decision tickets becomes what `/design` does when scope is large and foggy, rather than a skill with its own name.

## Considered Options

- **Merge the output formats, keep `wayfinder` separate.** Its trigger and output are different in kind — decisions rather than deliverables, spanning sessions. Rejected because "discover the scope and answer the open questions" is the same activity at a different size, and splitting it by size means the user has to judge the size before choosing the skill, which is what `/design` exists to work out.

## Consequences

`/design` becomes the largest skill in the set, carrying grill, options, scope assessment, evidence dispatch, spec, tickets, and the multi-session map. **Progressive disclosure is what keeps it legible**: the grill, options, and scope assessment stay inline because every run needs them; each deliverable branch lives behind a context pointer reached only when the tier selects it.

That structure also removes a hazard rather than merely tolerating one. Grill → spec → tickets in a single visible sequence invites **premature completion** — the grill gets rushed because the agent can see what comes next. Disclosing the deliverables means it cannot see them while grilling.

Three fewer names to remember, and one hand-off instead of three. The cost is that a single skill now fails in more ways, and its branches are exercised unevenly — the map mode will be rare, so it will be the least-tested path.
