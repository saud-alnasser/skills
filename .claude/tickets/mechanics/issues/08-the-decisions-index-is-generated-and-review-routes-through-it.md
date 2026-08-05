# 08 — feat(skills): the decisions index is generated, and the review stage routes through it

Status: resolved
Blocked by: 06, 07
Part of: mechanics

## Problem

The fields exist after tickets 06 and 07 and nothing reads them, so nothing yet changes: the review stage's row still names the decisions directory, and a stage that wants to know which decisions govern an area still has to open all of them.

There is also no mechanism producing an index from the fields, and no assertion that any index matches its directory — which is the whole property the declared-field shape was chosen for.

## Outcome

An index is produced from the declared fields, for Decisions and for Contexts alike, and the suite checks it by regenerating and comparing. A hand edit to a generated index fails in the same pass that made it. A file added without fields fails too, because it cannot appear in a regeneration.

The suite checks the supersession graph is symmetric: every claim to supersede is matched at the other end, and a one-sided one names both files in the failure.

The review stage's dependency row stops naming the decisions directory and names the index instead, so the stage routes to the decisions governing what the diff touches rather than reading the layer whole.

## Acceptance

- Regenerating an index over an unchanged directory produces a byte-identical file.
- A hand edit to a generated index fails the build, naming the file.
- A decision or context file carrying no declared fields fails the build, naming the file.
- A supersession claimed at one end and absent at the other fails the build, naming both files.
- The review stage's declared dependencies name the index rather than the decisions directory.
- Answering which decisions govern a given area requires reading the index and the decisions it names, and no others.
- The suite's guards are each confirmed to fail against a reworded restatement and against the inversion of the rule they guard.
- The suite passes.

## Comments

Two bounds worth stating, both found while building rather than planned.

The review row moves on the **shipped** router only. Adopting it in the installed one would
point `/review` at `.claude/decisions/map.md` before `mechanics/12` generates it — a broken
Source Pointer shipped to gain nothing. ADR 0025's ship-then-adopt order turns out to be load
bearing here rather than procedural, and 13 adopts the row once there is an index to route to.

"Answering which decisions govern an area requires reading the index and no others" is a
property of a reader, not of a file, so it is asserted through its two mechanical halves — the
row names the index, and the format states that a stage opens only the ADRs the index names.
The regenerator, the hand-edit check, and the symmetry check all construct their own failure
cases per run, so they prove themselves rather than needing a fixture committed beside them.
