---
owner: repository
status: accepted
load-when: a fan-out is being declared on a ticket
sources: [agents/]
supersedes: []
superseded-by: []
---

# Roles ship by name; the ticket declares the fan-out in one line

A survey of ten agent frameworks found that **no framework has an authored decomposition manifest a human writes before the run.** What gets declared is always a role or a graph; the split into N is composed at dispatch. Claude Code's agent-teams documentation goes further and says the equivalent artifact must not be hand-authored, because the runtime overwrites it.

That collides with AEP's own rule that `/implement` builds what was planned or stops, since partitioning work into parallel units is an architecture decision. The split resolves it in two pieces:

- **The reusable artifact is the role**, shipped as an agent definition and referenced by name. Identity comes only from the `name` field, so an orchestrator holds a name rather than a path or an import — which is the mechanism every additive framework in the survey uses.
- **The ticket carries one optional declaration** naming which roles run and which files each owns. That is the decomposition decision, grilled at design time and reviewable before code exists. The brief itself is composed at dispatch, from the template.

## Considered Options

- **Full decomposition declared at design time** — every child, its files, its order, its done-criteria on the ticket. Rejected: it is the heaviest possible change to the ticket format, and no surveyed framework does it, because a split authored before the code is read rarely survives being read.
- **Nothing on the ticket; `/implement` decides entirely at runtime.** Rejected despite being the purest reading of "orchestration must not change existing systems": it makes an architecture decision with no grill behind it, invisible in the diff afterwards.

## Consequences

`.claude/policies/tickets.md` gains one optional section and nothing else. That is the whole cost this design imposes on an existing system, which is what makes orchestration something a stage opts into rather than something every stage now has to know about.

Reference-by-name has a documented failure mode worth carrying into the policy: the same definition resolves to different tools in the foreground and the background, and the removal reports no error.

Specification §20 is amended in the same change to name the role, and to declare that a fan-out is declared on a ticket rather than invented by a stage.
