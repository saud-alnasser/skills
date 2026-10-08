---
use-when: "a prototype's question is what something should look like, and the answer is variants a human flips between"
---

# Prototype — the UI branch

Several **radically different** variants of one screen, switchable from a
floating bar. The human flips between them, picks one (or takes pieces from
several), and the rest are deleted. A question about logic, state, or data
shape is `[[skills/prototype/logic]]`'s.

**As a stage.** An open visual question in a UI change runs this after
`[[skills/specify]]` opens the effort and before any plan, on the throwaway
branch `[[skills/prototype]]` creates. Asking the human to pick a variant is the
one question this stage asks.

## Two shapes. Strongly prefer the first.

A design is judged against the rest of the application: real header, sidebar,
data, density. A route on its own is a vacuum, and everything looks fine there.

- **Inside an existing screen (preferred).** Variants render on it, selected by
  a parameter the router already understands. Data fetching, params, and auth
  stay; only the rendering swaps. Something that would naturally live inside a
  screen (a dashboard section, a step in a flow) is mounted in its host.
- **A new screen (last resort)**, only when it genuinely has nowhere to live.
  Follow the repository's routing convention, name it obviously as a prototype,
  and select variants the same way. Ask once more whether a screen could host
  it first.

## 1 — Fix the question and the count

**Three variants** by default, never more than five. Before any code, one line
at the top of the evidence file:

> Three variants of the settings screen, on the existing settings route,
> selected by a query parameter.

## 2 — Variants that actually disagree

Each holds to the screen's purpose, its existing data, and the repository's own
component and styling system. Each is **structurally different**: layout,
information hierarchy, primary affordance. Where two come out similar, redo one
under an explicit constraint (*no card grid*). Share the shell, never the
layout.

## 3 — Wire the switcher

One switcher, in the repository's shared-UI location:

- selecting a variant goes **through the router**, so it is shareable by URL and
  survives reload;
- arrow keys cycle, **but not while a text input or editable element has
  focus**;
- visually distinct from the page being judged;
- **hidden outside development**, gated on the environment.

## 4 — Close it out

`[[skills/prototype]]` has the write-up and the deletion. Here also:

- **Describe every variant in the evidence**, well enough that the comparison
  survives the code; what the winner beat is the finding.
- The losing variants and the switcher come out in the change that records the
  answer.
- Folding the winner into the real screen is **fresh implementation** under
  the effort's tickets, never a promotion of the variant file.

## Never

- variants differing only in colour or copy;
- a variant wired to a real mutation: point one that must write at a stub;
- a switcher left behind.
