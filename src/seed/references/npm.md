---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "installing dependencies or running this repository's npm scripts"
---

# Reference — npm

**This file is yours.** Installed because `package-lock.json` was detected. Fill
the table from `package.json` and the CI workflow; delete rows that do not exist.

```sh
npm ci                           # what CI runs — honours the lockfile exactly
npm run <script>
npm run <script> --workspace <pkg>
```

| Purpose | Command |
| --- | --- |
| build | `npm run build` |
| test | `npm test` |
| single test file | `npm test -- <path>` |
| lint | `npm run lint` |
| types | `npm run typecheck` |

**Do not invent a script.** A command named here that `package.json` does not
define will be trusted and will fail (`[[policies/engineering]]`).

Adding a dependency (`npm i <pkg>`, `-D` for development) is an architectural
decision put to the human, not a mechanical one.

## Failure handling

- `npm ci` failing means the lockfile and `package.json` disagree — a finding,
  not something to fix by switching to `npm install`.
- **Never `npm publish`**, and never log in to a registry.
