# 09 — feat(specs): the stage-dependency set has two homes, and the table wins

Status: resolved
Blocked by: —
Part of: mechanics

## Problem

Which guides a stage reads is stated in two places: the protocol's stage table and each skill's own dependency line. They have already drifted — the table names the tool guides and the forge reference, the skill lines do not — and nobody noticed, because nothing said the two were meant to agree or which one to believe when they did not.

Deleting either is worse than the drift. Delete the table and a repository with no plugin installed has no committed answer to what a stage reads, since its skills live in the plugin rather than in its tree. Delete the skill line and a repository partway through configuration has no dependency set at all, and the specification's own statement that a skill declares its dependencies stops being true.

The specification mandates both and reconciles neither, so the single-home gate is being failed by the specification itself rather than by a careless edit.

## Outcome

The specification names what each home is. A skill's dependency line is the workflow's **default** — shipped in a plugin that cannot know any repository's local guides. The protocol's table is **this repository's actual set**, written by the configuration stage from those defaults plus whatever is local to it.

It states the precedence: where they differ, the table governs, because the table is the one that knows where it is.

It states the obligation that keeps the two from drifting silently — every stage has exactly one row, and a row's guides are a superset of the defaults its skill declares unless the repository dropped one deliberately, in which case the table says so.

The current divergence is repaired as part of this, since it is the drift the rule exists to prevent.

## Acceptance

- The specification names both homes and says what each is for, in terms of who can know what.
- The specification states the precedence rule, and states the reason rather than only the verdict.
- The specification states that the configuration stage derives the table from the skill defaults plus local additions.
- A repository with no plugin installed can still learn what each stage reads, from a committed file — and the specification states that this is why the table cannot be dropped.
- Every stage has exactly one row, asserted.
- A guide named by a skill's default and absent from that stage's row fails the build unless the row records the omission.
- The existing divergence between the table and the skill lines no longer exists.
- The suite's guards are each confirmed to fail against a reworded restatement.
- The suite passes.

## Comments

The Problem above overstates the defect, and the build corrected it rather than the plan. The
skill line is labelled `Policies:` and lists policies; the table's column is `Guides it reads`
and adds tool guides. That is an undeclared **containment**, not a contradiction — checked
across all seven spine stages, and every policy a skill declares was already in its row. The
finding stands as written in every other respect: nothing said how the two related, and nothing
checked that the containment held. What shipped asserts the containment per stage.
