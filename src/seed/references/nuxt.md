---
use-when: "building or running this Nuxt application"
---

# Reference — Nuxt

**This file is yours.** Installed because a Nuxt configuration was detected.
Record the Nuxt major version and whether this app is SSR, SPA, or prerendered.

## Commands

```sh
npx nuxt dev                     # dev server; long-running
npx nuxt build                   # server build, into .output/
npx nuxt generate                # fully prerendered static output
npx nuxt preview                 # serves the build output
npx nuxt typecheck
npx nuxt prepare                 # regenerates .nuxt types after config changes
```

| Purpose | Command |
| --- | --- |
| dev | `npm run dev` |
| build | `npm run build` |
| types | `npm run typecheck` |

## Runtime config

`runtimeConfig` is server-only; `runtimeConfig.public` reaches the browser.
**A secret placed under `public` ships to every visitor** — check which side a
value is on before adding one, and never move a key to `public` to make an error
go away.

## Failure handling

- Auto-imports mean a symbol can resolve at runtime and not in the editor. Run
  `nuxt prepare` before treating that as a real type error.
- A composable called outside a Nuxt context — a plain module, a callback —
  fails with a message about the instance, not about the call site.
- A hydration mismatch is a server/client render difference, most often a date
  or a random value. Suppressing it is not fixing it.
- Never deploy. The build is the boundary.
