---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, prototype, test]
use-when: "building or running this Next.js application"
---

# Reference — Next.js

**This file is yours.** Installed because a Next configuration was detected.
Correct the scripts from `package.json`, and record whether this app uses the
App Router, the Pages Router, or both.

## Commands

```sh
npx next dev                     # dev server; long-running, never exits
npx next build                   # the real check — type errors and prerender failures surface here
npx next start                   # serves the build output; requires a build first
npx next lint
```

| Purpose | Command |
| --- | --- |
| dev | `npm run dev` |
| build | `npm run build` |
| start (production) | `npm run start` |

**`next dev` passing is weak evidence.** Static generation, route-level type
checking, and server/client boundary violations are enforced at build time, not
in dev. Build before claiming a change works (`[[rules/evidence]]`).

## Server and client

The server/client split is the source of most confusing failures here. A
component without `"use client"` runs on the server, where browser APIs do not
exist and where **anything it closes over can be serialised into the response**.
Never read a secret in a component that could be a client component.

`NEXT_PUBLIC_`-prefixed variables are inlined into the browser bundle at build
time. Nothing sensitive goes behind that prefix.

## Failure handling

- A hydration mismatch is a difference between server and client render —
  usually a date, a random value, or `window` read during render. It is not
  fixed by suppressing the warning.
- A route that 404s in production but works in dev is usually a dynamic segment
  that was never generated. Check the build output.
- Never deploy. `next build` is the boundary.
