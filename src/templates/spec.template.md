---
aep: 2.3.0
owner: protocol
date: 2026-08-17
use-when: "writing or extending an effort's spec.md"
---

# Template — effort spec

Copy to `efforts/<effort>/spec.md`. `<effort>` is a kebab-case slug naming the
change.

**One file, two phases.** `/specify` writes the first block; `/plan` extends the
*same* file with the second. There is no `plan.md`.

**Omit a heading rather than writing "N/A" under it.** An empty section reads as
considered-and-empty; an absent one reads as not yet reached, which is the truth.

```markdown
---
aep: <release>
owner: repository
date: <YYYY-MM-DD>
kind: spec
status: draft            # draft → accepted → implemented
---

# Problem
What is wrong or missing today, and what it costs. Not the solution.

# Goal
What is true once this lands.

# Scope
What this change covers.

# Requirements
Numbered. Each one gets an acceptance criterion below, or it is not a requirement.

# Acceptance Criteria
How anyone would know each requirement was met. Checkable, not aspirational.

# Constraints
What the solution must respect — and why each constraint exists, so a later
reader can tell a requirement from a preference.

# Out of Scope
Mandatory. The nearest things this deliberately does not do. The obvious
exclusion is the one that gets built.

# Assumptions
Things believed but not verified. Naming one costs a line; leaving it implicit
turns it into a requirement nobody agreed to.

# Open Questions
What is still unresolved. A spec that quietly drops a question it could not
answer is worse than one that admits it.

# Risks
What could go wrong, and how it would show up.
```

Added by `/plan`, in the same file:

```markdown
# Architecture
The approach, and — named explicitly — the alternatives that lost and why.

# Components
# Interfaces
# Data Model
# Technical Approach
# Integration
# Migration
# Testing Strategy
How each acceptance criterion gets checked.

# Operational Considerations
# Technical Risks
```
