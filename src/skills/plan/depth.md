---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: skill
use-when: "an approach turns on where a module boundary goes, or the plan will merge, split, or hide something behind an interface"
---

# Plan — module depth

The vocabulary for reasoning about where a boundary goes, and the rules for
moving one safely. `[[skills/survey]]` finds these costs; `[[skills/plan]]`
designs the fix; both use these words, and using them precisely is what keeps a
design discussion from becoming a taste discussion.

## The words

| Term | Means |
| --- | --- |
| **module** | a unit with an interface and an implementation behind it |
| **interface** | everything a caller must understand to use it — names, types, ordering, invariants, error modes |
| **implementation** | everything the caller does not have to understand |
| **depth** | how much implementation one interface hides. **Deep** = small interface, large implementation. **Shallow** = the interface is nearly as complex as what it hides |
| **seam** | a place a real alternative can be substituted |
| **adapter** | one concrete implementation behind a seam |
| **leverage** | implementation hidden per unit of interface — what depth buys |
| **locality** | how concentrated the edits for one conceptual change are |

**Never substitute.** *Component*, *service*, or *unit* for module; *API* or
*signature* for interface; *boundary* for seam; *layer* or *wrapper* for module.
The substitutes are near-synonyms in ordinary speech and different things here,
and a design argument conducted in near-synonyms cannot be settled.

**A shallow module is not a small one.** Small and deep is the ideal; the cost is
in the *ratio*, and a one-line wrapper that adds nothing has the worst ratio
available.

## Seam discipline

**Two adapters make a real seam.** Do not define one unless at least two are
justified — typically production plus test. *A single-adapter seam is indirection
wearing a seam's clothes: all of the cost, none of the substitutability.*

**An internal seam is not part of the interface.** Splitting the implementation
behind a stable interface is free; exposing that split to callers spends the
depth you just built.

## Classify the dependencies before proposing a merge

The category decides how the merged module can be tested across its seam, and
therefore whether the merge is safe at all.

| Category | What it is | What the plan says |
| --- | --- | --- |
| **in-process** | pure computation and in-memory state | always mergeable. Test through the new interface; no seam needed |
| **local-substitutable** | has a real local stand-in that runs in the suite | mergeable where the stand-in exists. The seam is internal and stays out of the interface |
| **remote but owned** | your own services across a network | define a seam. The module owns the logic; transport is an injected adapter — real in production, in-memory in tests |
| **true external** | a third party you do not control | inject it as a seam and provide a test adapter. `[[skills/tdd/mocking]]` has the shape |

## Replace the tests. Never layer them.

A deepening is **not finished** until the old tests are gone.

Write the new tests at the merged module's interface — that is now the test
surface — then **delete the unit tests on the pieces underneath.** They assert
internals now.

*Layering the new suite on top of the old one is the failure mode. Two suites
cover the same behaviour, the old one breaks on every subsequent refactor, and
the pressure that creates is pressure to undo the deepening. A change that makes
testing feel worse gets reverted, however good it was.*

Deleting those tests is a real coverage change, so it is **named in the spec** —
which tests go, and what now covers their behaviour.

## The one that is not worth doing

A deepening with no cost behind it. `[[skills/survey]]` ranks by cost ×
frequency for exactly this reason: a shallow module nobody touches costs nothing,
and merging it spends review attention to buy a tidier diagram.
