# 07 — feat(skills): contexts declare their sources and their load condition

Status: resolved
Blocked by: 05
Part of: mechanics

## Problem

A Domain Context's sources are stated twice — as a prose line at the top of the file and as a column in the routing table — and its load condition is stated once, in the table only. So the file that owns a domain cannot say when it should be loaded, and the two statements of its sources have nothing keeping them equal.

Neither statement is checked. A Source Pointer that stops resolving is found at use, by whoever relied on it, which is the moment the protocol's recovery machinery exists for and also the most expensive moment to find it.

## Outcome

A Domain Context declares its sources and its load condition as fields, and the routing table is generated from them. The prose source line and the table's columns stop being two statements of one fact, because there is only one statement left.

The context policy states that a declared source is still a navigation coordinate and never a claim about what is there — the field changes where the pointer is written, not what it means, and the verify-before-use rule is untouched.

Every declared source resolves, and the suite says so, so a pointer breaks the build at the moment it breaks rather than at the moment somebody needs it.

## Acceptance

- The context policy names the fields a Domain Context declares and says the table is generated from them.
- The policy states that a declared source remains a navigation coordinate, and the verify-before-use rule is stated exactly where it already is and nowhere new.
- The policy's format example shows the fields rather than the prose line, and no prose source line survives in it.
- The repository context's place in the table is unchanged — every file under contexts still has exactly one row, including that one.
- A declared source path that does not resolve fails the build.
- A context file present in the directory and absent from a regenerated table fails the build.
- The suite's guards are each confirmed to fail against a reworded restatement.
- The suite passes.

## Comments

"A context file present in the directory and absent from a regenerated table fails the build"
needs a regenerator, and that is ticket 08's — it builds one for Decisions and Contexts alike.
This ticket states the rule and proves the field validator against synthetic input, so the check
is working now rather than passing vacuously until this repository's contexts gain fields in 12.
