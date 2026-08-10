---
owner: repository
status: implemented
sources:
  - skills/configure/policies/tracker.template.md
  - skills/configure/policies/specs.template.md
  - skills/configure/policies/tickets.template.md
  - skills/configure/SKILL.md
  - skills/configure/SCRIPTS.md §The designs index has two layouts
  - skills/design/SKILL.md
  - skills/review/SKILL.md
  - scripts/verify.ps1
  - .claude/decisions/0068-where-a-spec-lives-is-declared-in-the-derived-tracker-policy.md
---

# fix(configure): give the spec layout a declared home, and stop four surfaces asserting one

## Problem

A spec lives in one of two layouts, and nothing records which one a repository
uses.

The scripts specification tells the derived index regenerator that the tracker
policy says which layout applies. No template gives the tracker policy such a
section, and no step of the configuration stage derives one. The instruction
points at a declaration that nothing writes.

Four shipped surfaces filled that hole by asserting the flat layout outright. The
spec format policy is the sharpest case: three lines in it state that a spec is
written to the designs directory, and eighty lines later the same file states that
the index sits in whichever of two layouts the repository uses. A reader cannot
satisfy both.

Two of those surfaces are the configuration stage's own templates, so the wrong
answer is installed into every repository AEP configures. **The other two are
worse, because nothing installs them and no audit reads them back**: the design
stage and the review stage each name the flat directory directly, so a repository
on the per-effort layout is running two stages that look for specs where it does
not keep them. The repository that builds AEP is such a repository. Its installed
policy copies were healed by hand — which is why they diverge from their own
templates — and the two stages were never healed at all.

## Goal

Where a spec lives is stated once, in the guide that already carries this
repository's other per-repository facts, and every surface that needs the answer
reads it there. No shipped file asserts a spec location.

## Constraints

- **The copied/derived split holds.** Eight policies install byte-identical from
  templates and carry no repository-specific facts; only the tracker and
  version-control policies are derived. The layout is a repository-specific fact,
  so a copied policy cannot hold it.
- **Both layouts stay.** The regenerator already implements both and refuses a
  tree holding both. Only the declaration is missing.
- **A shipped file cites only what resolves where it is read**, so none of this
  may reference a record belonging to the repository that builds AEP.
- **Nothing installs the design or review stage**, so their repair reaches a
  configured repository through the plugin and not through an audit.

## Architecture

The tracker policy grows a section naming the layout, and the configuration stage
grows the step that derives it — detected from the tree, the same way that file's
other facts are detected rather than asked about.

Every other surface becomes a pointer to it. The spec format policy's third line
is the one that matters for findability: a reader asking where a spec goes opens
the spec policy first and must get their answer there, one hop away rather than
not at all.

The audit branch gains the layout to its list of things re-checked, since a
repository whose tracker policy predates the section has a declaration nothing
wrote.

## Approach

The declaration comes first, because every other change defers to it and a
deferral written before its target exists is the same dangling pointer being
repaired.

Then the four assertions become deferrals, in one pass — they are the same edit
four times and splitting them would leave the tree self-contradictory in between.

Options weighed and rejected are recorded in the Decision rather than here.

## Acceptance criteria

- A repository configured from scratch declares which spec layout it uses, in the
  guide that carries its other derived facts, and the declaration is detected from
  the tree rather than asked about.
- No file under the shipped surfaces asserts where a spec is written. Every one
  that needs the answer names the declaration instead.
- A reader who opens the spec format policy learns where a spec goes without
  opening a second file first.
- The spec format policy no longer contradicts itself about whether the layout
  varies.
- The design stage and the review stage locate a spec correctly in a repository
  using either layout.
- The audit re-checks the declaration, and a repository whose tracker policy
  predates it gains one.
- The suite fails when any shipped surface regains an asserted spec location,
  confirmed against a deliberate reintroduction and then restored.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Risks

**The guard matches the wrong thing.** A pattern written from the new wording
catches only the new wording, and the existing assertions elsewhere go unseen —
the failure mode the authoring rule names explicitly. Detection: write the guard,
then confirm it fails against a deliberate reintroduction of each of the four
original sentences before trusting it.

**The pointer reads as indirection nobody follows.** If the spec policy's line
merely names another file, a reader may not make the hop and will assume the flat
default. Detection: the line has to state that the answer is repository-specific,
not merely where it is kept — a reader who stops at the pointer must at least know
not to guess.

**A configured repository is left half-converted.** Its templates repair by
audit; its design and review stages repair by plugin update. A repository that
updates one and not the other is in a state neither change tested. Detection: the
audit reports the declaration as missing rather than assuming the stages agree.

## Out of scope

- Choosing a default layout for new repositories, which stays flat and unchanged.
- Making the regenerator read the layout instead of detecting it. It already
  detects correctly and refuses ambiguity; changing that is a second design.
- Converting any existing repository's specs from one layout to the other.
