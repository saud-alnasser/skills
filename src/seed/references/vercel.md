---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, review]
use-when: "reproducing this project's Vercel build locally, or reading its deployment configuration"
---

# Reference — Vercel

**This file is yours.** Installed because Vercel configuration was detected.
Record what `vercel.json` actually sets — rewrites, headers, regions, function
runtimes — since those apply in deployment and not in local development.

## Commands

```sh
npx vercel build                 # reproduces the platform build locally, into .vercel/output
npx vercel dev                   # emulates the platform locally; long-running
npx vercel env pull .env.local   # writes real environment values to disk
npx vercel inspect <url>         # reads a deployment
```

| Purpose | Command |
| --- | --- |
| local platform build | `npx vercel build` |

## Never deploy

`vercel deploy`, `vercel --prod`, `vercel promote`, `vercel rollback`, and
`vercel alias` all change what users see. Deployment is the human's
(`[[rules/version-control]]`).

`vercel env pull` writes production or preview secrets into a file in the
working tree. Run it only when asked, and check it is ignored by git before it
exists.

## Failure handling

- A build that passes locally and fails on the platform is usually a
  case-sensitive filesystem, a Node version, or a devDependency that the
  production install omits. `vercel build` reproduces all three.
- A rewrite or header that "does nothing" in `npm run dev` is expected —
  `vercel.json` is applied by the platform, and only `vercel dev` emulates it.
