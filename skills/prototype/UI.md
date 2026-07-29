# UI Prototype

Generate **several radically different variations** on one route, switchable from a floating bar. The user flips between them, picks one — or steals pieces from each — and the rest are thrown away.

If the question is about logic or state rather than what something looks like — wrong branch. Use [LOGIC.md](LOGIC.md).

## When this is the right shape

- "What should this page look like?"
- "I want to see a few options for this dashboard before committing."
- "Try a different layout for the settings screen."
- Any time the alternative is a day spent choosing between three vague mockups nobody can see.

## Two sub-shapes — strongly prefer A

A UI prototype is far easier to judge when it is **butting up against the rest of the application** — real header, real sidebar, real data, real density. A route on its own is a vacuum, and every variant looks fine in a vacuum.

### Sub-shape A — inside an existing page (preferred)

The route already exists. Variants render **on that same route**, gated by a `?variant=` search param. Existing data fetching, params, and auth all stay; only the rendering swaps.

Something that has no page yet but would naturally live inside one — a new section of the dashboard, a new step in an existing flow — is still sub-shape A. Mount the variants inside the host page.

### Sub-shape B — a new page (last resort)

Only when the thing genuinely has no existing page to live in. Follow whatever routing convention the repository already uses; do not invent a top-level structure. Name it so it is obviously a prototype, and use the same `?variant=` pattern.

Before choosing B, ask once more whether there is really no page this could be embedded in. An empty route hides the design problems a populated one exposes.

## 1 — State the question and pick N

**Three variants** by default. Past five they stop being radically different and start being noise.

Write the plan in one line at the top of the write-up in `.claude/evidence/prototypes/<name>.md`:

> Three variants of the settings page, switchable via `?variant=`, on the existing `/settings` route.

## 2 — Generate variants that actually disagree

Hold each to the page's purpose, the data it has access to, the repository's own component and styling system, and a clearly exported component name — `VariantA`, `VariantB`, `VariantC`.

Variants must be **structurally different** — different layout, different information hierarchy, different primary affordance. Three tweaked card grids is not a prototype, it is wallpaper. If two come out similar, redo one under an explicit constraint: *no card grid*.

## 3 — Wire them together

One switcher on the route:

```tsx
// pseudo-code — adapt to the repository's framework
const variant = searchParams.get('variant') ?? 'A';
return (
  <>
    {variant === 'A' && <VariantA {...data} />}
    {variant === 'B' && <VariantB {...data} />}
    {variant === 'C' && <VariantC {...data} />}
    <PrototypeSwitcher variants={['A','B','C']} current={variant} />
  </>
);
```

Sub-shape A keeps all existing data fetching above the switcher; only the rendered subtree changes.

## 4 — Build the floating switcher

A small fixed bar at the bottom centre: previous arrow, the current variant key and its name (`B — Sidebar layout`), next arrow, both wrapping.

- Clicking updates the search param through the framework's own router, so a variant is shareable and survives reload.
- `←` and `→` cycle too — but not while an `<input>`, `<textarea>`, or `[contenteditable]` has focus.
- Visually distinct from the page, so it is obviously not part of the design being judged.
- **Hidden outside development.** Gate it on the environment, so a stray merge cannot ship the bar to users.

Put the switcher in one shared component, wherever shared UI already lives, so both sub-shapes use the same one.

## 5 — Close it out

Surface the URL and the variant keys; the handback rule is in [SKILL.md](SKILL.md).

Two things are specific to this branch:

- **Describe the variants in the write-up**, in enough detail that the comparison survives the code. Which one won is not a finding on its own — what it was beating is.
- **The code is mounted in the application**, not in `.claude/position/prototypes/`, so deleting it is a real edit rather than removing a directory. The losing variants and the switcher come out wherever they were mounted, in the same change that records the answer.

Folding the winner into the real page is a **fresh implementation effort**, not a promotion of the variant file. Variant code was written under prototype constraints — no tests, minimal error handling, shared state taken wherever convenient — and every one of those ships with it if it is moved rather than rewritten.

## Anti-patterns

- **Variants differing only in colour or copy.** That is a tweak. Real variants disagree about structure.
- **Sharing too much between variants.** A shared header is fine; a shared layout defeats the point. Each variant must be free to throw the layout out.
- **Wiring variants to real mutations.** Read-only is fine — the question is what this should look like, not whether the backend works. Point a variant that must mutate at a stub.
- **Leaving the switcher behind.** Variant components and a switcher left in the codebase rot fast and confuse the next reader.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
