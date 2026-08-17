---
aep: 2.2.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, prototype]
use-when: "building this repository with webpack, or reading why its bundle is what it is"
---

# Reference — webpack

**This file is yours.** Installed because a webpack configuration was detected.
Correct the scripts from `package.json`, and note which config each one uses.

## Commands

```sh
npx webpack --mode production
npx webpack --mode development --watch
npx webpack --config <file>
npx webpack --profile --json > stats.json   # for analysing size
npx webpack serve                           # dev server; long-running
```

| Purpose | Command |
| --- | --- |
| build | `npm run build` |
| dev | `npm run dev` |

## What the config decides

- **Multiple configs are normal** — one per target, often merged. Editing the
  wrong one changes nothing and looks like a caching problem.
- **`mode`** changes minification, `NODE_ENV`, and which plugins run. A bug that
  only appears in production usually starts here.
- **Loaders are ordered right-to-left.** A rule that appears to be ignored is
  often just ordered after the one that consumed the file.

## Failure handling

- `Module not found` for a path that exists is usually `resolve.alias` or
  `resolve.extensions`, not a missing file.
- A build that succeeds but ships something broken needs the stats output, not
  another build.
- Filesystem caching makes stale output look like a code problem. Clearing the
  cache is a diagnosis; a build that needs it routinely is a finding.
