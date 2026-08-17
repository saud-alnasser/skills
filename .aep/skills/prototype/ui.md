---
aep: 2.2.0
owner: protocol
date: 2026-08-17
kind: skill
use-when: "a prototype's question is what something should look like, and the answer is variants a human flips between"
---

# Prototype — the UI branch

Several **radically different** variations of one screen, switchable from a
floating bar. The human flips between them, picks one — or takes pieces from
several — and the rest are deleted.

Wrong branch if the question is about logic, state, or data shape:
`[[skills/prototype/logic]]`.

## Two shapes. Strongly prefer the first.

A design is judged against the rest of the application — real header, real
sidebar, real data, real density. **A route on its own is a vacuum, and
everything looks fine in a vacuum.**

**Inside an existing screen (preferred).** The screen already exists. Variants
render on it, selected by a parameter the router already understands. Existing
data fetching, params, and auth stay; only the rendering swaps. Something with no
screen of its own that would naturally live inside one — a new dashboard section,
a new step in an existing flow — is still this shape. Mount it in its host.

**A new screen (last resort).** Only when the thing genuinely has nowhere to
live. Follow the repository's routing convention rather than inventing a
structure, name it so it is obviously a prototype, and select variants the same
way. Before choosing this, ask once more whether some screen could host it: an
empty route hides exactly the problems a populated one exposes.

## 1 — Fix the question and the count

**Three variants** by default. Past five they stop disagreeing and start being
noise. One line at the top of the evidence file, before any code:

> Three variants of the settings screen, on the existing settings route,
> selected by a query parameter.

## 2 — Generate variants that actually disagree

Each is held to the screen's purpose, the data it already has, and the
repository's own component and styling system.

**Structurally different** — different layout, different information hierarchy,
different primary affordance. *Three tweaked card grids is not a prototype, it is
wallpaper.* Where two come out similar, redo one under an explicit constraint:
*no card grid*.

Share the shell, never the layout. A shared header is fine; a shared layout
defeats the point, because each variant must be free to throw the layout out.

## 3 — Wire the switcher

One switcher on the route, in whatever shared-UI location the repository already
has, so both shapes use the same one.

- Selecting a variant goes **through the router**, so a variant is shareable by
  URL and survives reload.
- Arrow keys cycle — **but not while a text input or editable element has
  focus.**
- Visually distinct from the page, so it is obviously not part of what is being
  judged.
- **Hidden outside development.** Gate it on the environment, so a stray merge
  cannot ship the bar to users.

## 4 — Close it out

`[[skills/prototype]]` has the write-up, the handback, and the deletion. Two
things belong to this branch alone:

- **Describe the variants in the evidence**, in enough detail that the comparison
  survives the code being deleted. *Which one won is not the finding — what it
  was beating is.*
- **The code is mounted in the application**, so removing it is a real edit rather
  than deleting a directory. The losing variants and the switcher come out in the
  same change that records the answer.

Folding the winner into the real screen is a **fresh implementation effort**, not
a promotion of the variant file. Variant code was written under prototype
constraints — no tests, minimal error handling, state taken wherever convenient —
and every one of those ships with it if it is moved rather than rewritten.

## Anti-patterns

- **Variants differing only in colour or copy.** That is a tweak.
- **Wiring a variant to a real mutation.** Read-only is fine — the question is
  what this should look like, not whether the backend works. Point a variant that
  must write at a stub.
- **Leaving the switcher behind.** Variant components and a dead switcher rot
  fast and mislead the next reader.
