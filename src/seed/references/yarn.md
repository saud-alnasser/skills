---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "installing dependencies or running this repository's yarn scripts"
---

# Reference — Yarn

**This file is yours.** Installed because `yarn.lock` was detected. Yarn 1 and
Yarn 2+ (Berry) differ enough to matter — **check `yarn --version` and delete the
half that does not apply.**

```sh
yarn install --immutable         # Berry; fails rather than updating the lockfile
yarn install --frozen-lockfile   # Yarn 1, the equivalent
yarn run <script>
yarn workspace <pkg> run <script>
yarn workspaces foreach run <script>   # Berry only
```

| Purpose | Command |
| --- | --- |
| build | `yarn build` |
| test | `yarn test` |
| single test file | `yarn test <path>` |
| lint | `yarn lint` |
| types | `yarn typecheck` |

**Do not invent a script.** Read `package.json` (`[[policies/engineering]]`).

## Failure handling

- Under Berry with Plug'n'Play, a tool that cannot resolve a module is usually a
  PnP issue rather than a missing dependency — check before adding anything.
- An immutable-install failure is a lockfile finding, not a flag to drop.
- **Never publish.**
