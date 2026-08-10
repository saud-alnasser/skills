---
status: accepted
load-when: where a spec is written is in question, or which policies may carry a repository-specific fact
sources: [skills/configure/policies/tracker.template.md, skills/configure/policies/specs.template.md, skills/configure/SCRIPTS.md, skills/configure/SKILL.md]
supersedes: []
superseded-by: []
---

# Where a spec lives is declared in the derived tracker policy

Specs sit in one of two layouts — flat in the designs directory, or one per effort
beside the tickets it governs — and **which one a repository uses is recorded in
its tracker policy**, the guide `/configure` derives rather than copies. Every
other surface that needs the answer reads it there and asserts nothing.

The layout was already a two-way choice in the scripts specification and in the
spec policy's own index section, and the declaration those pointed at **was never
written by anything**. The regenerator is told that the tracker policy says which
layout applies; no template gave the tracker policy such a section, and no step of
the configuration stage derived one. Four shipped surfaces filled the gap by
asserting the flat layout outright, including the spec policy three lines above
its own statement that the layout varies.

**The deciding constraint is the copied/derived split.** Eight policies are
installed byte-identical from templates and therefore carry no repository-specific
facts by construction; two are derived per repository. Where a spec lives is a
repository-specific fact, so a copied policy cannot hold it without becoming a
second, wrong home for something the tree already decides — which is the failure
being repaired, reintroduced one file over.

## Considered Options

- **The spec policy declares its own layout.** The strongest option on
  findability: a reader asking where a spec goes opens the spec policy first, and
  one hop is a cost. It loses on the split above — the spec policy is copied, so
  the fact would either be hand-edited into every repository after installation
  (which is how this repository's own copy came to diverge from its template and
  is exactly the drift that hid this bug) or force the policy to become derived,
  which is a much larger change than the problem warrants. Findability is
  recovered instead by a pointer on the spec policy's third line, so that reader
  still gets their answer where they looked.
- **Drop the second layout and pick one for everybody.** The simplest end state,
  and it deletes the branch from the regenerator, the scripts specification and
  the spec policy at once. Rejected because the repository that builds AEP uses
  the per-effort layout and its version-control policy is built on the effort
  being the unit; standardising on flat would break the repository doing the
  standardising, and standardising on per-effort would impose an effort directory
  on repositories that have no efforts.
- **A dedicated field or a new file naming the layout.** Machine-readable, and it
  would let the regenerator read the layout instead of detecting it. Rejected as a
  category nobody named: the layout is one sentence of configuration, and a file
  per sentence is the loose-file failure the tree shape already rules out.
- **Leave the surfaces asserting flat and treat per-effort as undocumented.**
  What the tree does today. Rejected because the regenerator already implements
  both layouts and refuses a tree holding both — the capability exists and only
  its declaration is missing, so this is a documentation gap being described as a
  design.

## Consequences

**The regenerator's existing instruction starts resolving.** It was already
correct; it pointed at a section that did not exist. Nothing about the script
changes, which is the evidence that the hole was in the declaration rather than in
the mechanism.

**The spec policy keeps answering the question it is asked.** Its third line
becomes a pointer rather than an assertion. A pointer is a hop, and the hop is the
price of the fact having one home; the alternative priced at zero hops was a fact
with two.

**`/design` and `/review` were asserting a path in every configured repository,
not only in the templates.** Both name the flat directory directly, so a
repository on the per-effort layout has been running two stages that look for
specs where it does not keep them. That is the half of this defect no audit would
have surfaced, because neither stage is installed content an audit reads back.

**A repository configured before this gains nothing automatically.** Its tracker
policy has no layout section and its copied policies assert flat. Recognition is
by content and the repair is the audit's, under the release that ships this.
