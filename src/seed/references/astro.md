---
use-when: "building or running this Astro site"
---

# Reference — Astro

**This file is yours.** Installed because an Astro configuration was detected.
Record whether this site is static (`output: 'static'`) or server-rendered, and
which adapter it uses — most of what follows depends on that answer.

## Commands

```sh
npx astro dev                    # dev server; long-running
npx astro build                  # the real check; writes dist/
npx astro preview                # serves the build output
npx astro check                  # types across .astro, .ts, and framework files
npx astro sync                   # regenerates content-collection types
```

| Purpose | Command |
| --- | --- |
| dev | `npm run dev` |
| build | `npm run build` |
| types | `npx astro check` |

## Islands

A framework component renders to static HTML unless it carries a `client:*`
directive. **A component that "does not work" is usually shipping without one** —
its markup is correct and none of its JavaScript ran. Adding `client:load`
everywhere restores interactivity and discards the reason to use Astro; pick the
directive that matches when the component actually needs to be live.

## Failure handling

- A content-collection type error after editing a schema usually needs
  `astro sync`, not a code change.
- A build failure absent from dev is often a component reaching for `window` at
  module scope, which only runs during prerender in the build.
- Never deploy. The build is the boundary.
