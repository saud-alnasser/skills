---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
use-when: "a survey's findings are ready and the coupling needs to be seen rather than described"
---

# Survey — the visual report

`[[skills/survey]]` produces findings. This is how to render them when the
problem is **structural**, because coupling is the thing prose is worst at: *"the
order pipeline reaches across four modules to price a line item"* is a sentence
you have to hold in your head, and a diagram of it is a thing you look at.

Uses the vocabulary in `[[skills/plan/depth]]`, exactly.

## Choose the format the reader can actually open

In order:

1. **Diagrams inside the report**, in whatever diagram syntax this repository
   already renders — the reader already has a way to view it, and it survives in
   version control.
2. **A self-contained HTML file**, when the comparison needs layout that a
   diagram syntax cannot express: before/after side by side, several candidates
   scanned at once. Self-contained means **no external fetches** — a report that
   silently degrades on a locked-down machine is a report the reader cannot trust
   is complete.
3. **Prose with a table**, when the finding is not structural. Not every finding
   is; do not draw a diagram of a naming problem.

Where it lands is the human's to keep — a survey creates no effort and files
nothing under the effort tree (`[[skills/survey]]`).

## One card per candidate

- **Title** — names the change, not the smell: *"Collapse the order intake
  pipeline"*.
- **Strength** — strong / worth exploring / speculative. Say which; an unranked
  list of nine candidates is a list nobody acts on.
- **Dependency category** — from `[[skills/plan/depth]]`. It is what decides
  whether the candidate is even feasible.
- **Where it lives** — the modules involved.
- **Before and after** — the centrepiece, side by side.
- **Problem** — one sentence. What it costs.
- **Solution** — one sentence. What changes.
- **Wins** — bullets, a few words each, in the vocabulary: *"one interface to
  test against"*, *"pricing stops crossing the seam"*, *"four wrappers deleted"*.

**If a diagram needs a paragraph to be understood, redraw the diagram.**

## Diagram patterns

Pick per candidate, and **vary them** — a report where every candidate looks
identical stops being read after the second one.

- **Dependency or call graph** — the workhorse. *X calls Y calls Z, and look at
  the traffic across the seam.* Colour the leaking edges differently from the
  rest.
- **Cross-section** — for layered shallowness. Stack the layers a call passes
  through. Before: six thin bands each doing almost nothing. After: one thick
  band with the responsibility named on it.
- **Mass** — for *the interface is as complex as the implementation*. Two shapes
  per module, sized for interface surface and implementation volume. Shallow
  reads instantly: the two are the same size.
- **Collapse** — a tree of calls before, one box after, with the now-internal
  calls faded inside it.
- **Sequence** — when the win is round trips. *Before: six. After: one.*

## Language discipline

The report is where survey vocabulary most often leaks into consultancy prose.

**Use:** module, interface, implementation, depth, deep, shallow, seam, adapter,
leverage, locality.

**Do not write** *easier to maintain*, *cleaner*, *more robust*, or *best
practice*. None of them names a cost, none is checkable, and each one is
available to say about any change whatsoever — which is why they get written
when the actual evidence is thin.

Every win names a gain in the vocabulary or a measured cost. *"Changing a payment
method touches nine files across three packages"* is a finding. *"This is messy"*
is not, and `[[skills/survey]]` rejects it before it reaches the report.
