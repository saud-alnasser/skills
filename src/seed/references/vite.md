---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, prototype, test]
use-when: "building or serving this repository with Vite"
---

# Reference — Vite

**This file is yours.** Installed because a Vite configuration was detected.
Correct the scripts from `package.json`.

## Commands

```sh
npx vite                         # dev server; long-running, never exits
npx vite build                   # production build
npx vite build --mode <mode>     # picks the matching .env.<mode>
npx vite preview                 # serves the built output, not the source
```

| Purpose | Command |
| --- | --- |
| dev | `npm run dev` |
| build | `npm run build` |
| preview built output | `npm run preview` |

**Dev and build do not resolve identically.** The dev server serves modules
unbundled; the build runs Rollup with tree-shaking and a different environment.
A change that works in dev has not been shown to build (`[[policies/engineering]]`).

## Environment variables

Only variables carrying the configured prefix — `VITE_` unless the config says
otherwise — reach client code, and **they are inlined into the bundle**. Never
put a secret behind that prefix; it ships to every visitor.

## Failure handling

- A build failing where dev passed is usually an import that only resolves
  case-insensitively, or a dependency with no ESM build.
- `Failed to resolve import` for a package that is installed usually means it
  needs `optimizeDeps` or `ssr.noExternal`, depending on where it is used.
- The dev server does not exit. In an automated run, build.
