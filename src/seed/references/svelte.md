---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, prototype]
use-when: "building or running this Svelte or SvelteKit application"
---

# Reference — Svelte / SvelteKit

**This file is yours.** Installed because a `svelte.config.js` was detected.
Record the Svelte major version and, for SvelteKit, the adapter — both change
what the commands below mean.

## Commands

```sh
npx vite dev                     # dev server; long-running
npx vite build                   # production build
npx svelte-kit sync              # regenerates ./$types — run after route changes
npx svelte-check                 # types across .svelte files
```

| Purpose | Command |
| --- | --- |
| dev | `npm run dev` |
| build | `npm run build` |
| types | `npm run check` |

## Server and client

In SvelteKit, `+page.server.ts` runs only on the server and `+page.ts` runs in
both places. **Anything read in a universal load function reaches the browser**,
so a secret belongs in the server file and nowhere else. `$env/static/private`
enforces this; `$env/static/public` does not.

## Runes

Svelte 5 introduces runes (`$state`, `$derived`, `$effect`) and keeps the old
reactivity working. **Check which the file you are editing uses** and stay in
it — mixing the two styles in one component is where the confusing bugs live.

## Failure handling

- A missing `./$types` import is a stale sync, not a broken route.
- A store subscribed at module scope leaks across requests on the server. That
  is a real bug in SSR, not a warning to suppress.
- Never deploy. The build is the boundary.
