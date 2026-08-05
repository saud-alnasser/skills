# 05 — feat(specs): a routing table is generated from declared fields

Status: resolved
Blocked by: —
Part of: mechanics

## Problem

The specification gives Contexts a routing table and gives Decisions nothing, so the layer that grows without bound is the one with no demand-loading mechanism. It also leaves the table's authorship unstated, which is how the contexts table acquired a documented drift risk that an audit was expected to catch.

Adding a table for Decisions by hand would reproduce that risk on a directory that only ever gets larger. Adding frontmatter instead looks like the thing an accepted decision already rejected, so the specification has to say what the difference is or the next reader will read it as a reversal.

## Outcome

The specification states that a routing table is **generated from fields the routed files declare**, and that the fields are the table's own columns — when to load this, and where its subject lives. The trigger sentence stays exactly what it was; what changes is that it is written once, at the file it describes, instead of twice.

It states the property this buys: the table cannot disagree with the directory, because it is not a second statement of the directory's contents. That replaces an audit obligation with an impossibility.

It states that Decisions are routed on the same mechanism as Contexts, and that a Decision additionally declares its status and its supersession, so the relationship reads from either end and can be checked from either end.

It states that a generated file is never hand-edited, and that this is enforced rather than requested.

## Acceptance

- The specification states that routing tables are generated from declared fields, and names the two fields a routed file declares.
- The specification states that the trigger condition is a sentence about when to load, not a description of subject matter — the distinction the earlier decision turned on.
- The specification states that a generated table cannot drift from its directory, and that this replaces the audit obligation rather than supplementing it.
- The specification states that Decisions are routed, on the same mechanism, and that they declare supersession in both directions.
- The specification states that a generated file is not hand-edited and that the prohibition is enforced.
- A decision records why declared fields plus generation is not the pattern the earlier decision rejected, quoting what that decision actually turned on, and what it would cost to be wrong.
- The suite asserts each statement above, and each guard is confirmed to fail against a reworded restatement and against its own inversion.
- The suite passes.
