---
use-when: "writing an effort's plan.md, the technical approach behind a settled spec"
---

# Template — effort plan

Copy to `.aep/efforts/<effort>/plan.md`. Written by `/plan`, and **only where the
approach is not obvious** — a change with one reasonable shape does not need a
file saying so.

`spec.md` holds what is changing and why. This holds how. The split is what lets
the two travel separately: the spec is what a reviewer agrees to, and the plan is
what an implementer follows, and they are read by different people at different
moments.

**Omit a heading rather than writing "N/A" under it.** An empty section reads as
considered-and-empty; an absent one reads as not yet reached, which is the truth.

**`status` is the spec's, and is illegal here.** An effort has one state, the
spec declares it, and a plan declaring a second one gives the effort two answers
that can disagree. What this file carries is a `use-when` naming the occasion to
read it, like any other artifact.

```markdown
---
use-when: "building a ticket in this effort and the approach is not obvious from the spec"
---

# Architecture
The approach, and — named explicitly — the alternatives that lost and why. An
alternative dismissed without a reason gets proposed again in six weeks.

# Components
What changes, and what each part becomes responsible for.

# Interfaces
The signatures, payloads, and commands another part of the system sees. Where a
caller has to change, say so here rather than leaving it to be discovered.

# Data Model
Only where data shape changes.

# Technical Approach
The order the work lands in, and why that order. A step that has to precede
another for a reason says the reason.

# Integration
What this touches that it does not own.

# Migration
What happens to what already exists, including the trees you cannot edit.

# Testing Strategy
How each acceptance criterion in `spec.md` gets checked. A criterion with no
check named here is one nobody will check.

# Operational Considerations
Rollout, failure modes, what a person has to do by hand.

# Technical Risks
What could go wrong in the building, and how it would first show up.
```

**Never restate the spec.** Requirements, acceptance criteria, and scope live in
`spec.md` and are referenced from here. A plan that copies them creates a second
place they can change, and the two diverge on the first surprise.

**A plan that would work in a clean repository and not in this one is not a
plan.** Read the seams you intend to cut before proposing where to cut them.
