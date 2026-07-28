# The templates change before this repository adopts them

Structural work in the streamline effort lands in `skills/` first. This repository moves onto the new layout in one later ticket, by running `/configure`'s migration branch, rather than being edited directly as each structural ticket goes by.

This reverses how the effort was originally cut. Tickets 01–07 changed `.claude/` here and ticket 08 updated the templates afterward; ticket 01 was built that way and is partly reverted as a consequence.

## Why

**The migration had no test case.** Ticket 08's second criterion is that a repository on the superseded layout is migrated to the new one. Under repo-first, this repository is already on the new layout by the time that ticket runs, so the only repository available to convert has nothing left to convert. The migration would ship exercised by nothing — and ticket 08 is the one place where an error is invisible here and appears in somebody else's repository. Ship-first makes this repository the before-state the migration is proven against.

**It is what this repository already does.** `layout/01` changed the shipped layout; `layout/02` moved this repository onto it. Two tickets, ship first, adoption second. Streamline inverted that without recording a reason, and `0008` holds that a convention this repository demonstrates outranks a default.

**The dogfooding argument turned out to be weaker than it looked.** ADR `0017` closed the phase-2 gate by adopting the workflow for real work, and that reasoning was carried into cutting streamline repo-first. But the one empirical result ticket 01 produced — that `paths:` frontmatter scopes loading on the installed version — came from a throwaway fixture in a scratch directory, not from this repository's `.claude/`. Early adoption was not what made it testable, so it was not buying what it appeared to buy.

## The root cause, which is worth naming separately

No ticket said which tree it targeted, because `TICKETS.md` forbids naming file paths — a rule that exists so a ticket stays portable and does not rot when a file moves. The cost is that the axis this repository most needs to be explicit about, `skills/` is what ships and `.claude/` is what this repository runs on, was the one axis the format could not express.

The fix is not to start naming paths. It is that a ticket states **whose tree changes** in its outcome — shipped behaviour, or this repository's own configuration — which is a statement about audience rather than about location, and survives a file move intact.

## Consequences

**Nothing is verifiable here until adoption runs.** Between the first structural ticket and adoption, this repository keeps running the old layout while the templates describe a new one. Token savings are unmeasurable for most of the effort, and the budget ticket moves after adoption. That is the cost being accepted, and it is the mirror of the cost repo-first was accepting in the other direction.

**Ticket 08 narrows to the migration alone.** The template work distributes into the structural tickets that own each file, so the widest-blast-radius ticket in the effort loses most of its radius.

**Adoption is placed before the suite is re-anchored, not after.** Re-anchoring asserts against the new layout, and asserting against a tree that exists is worth more than asserting against one that is planned.

**Ticket 01's scope fix stays.** `.claude/rules/skills.md` is a standard about authoring Tenure and has no template counterpart — `/configure` already instructs that repository-discovered rules be path-scoped, and this repository was not following it. That was a defect here, independent of which tree leads, so only the entrypoint split reverts.
