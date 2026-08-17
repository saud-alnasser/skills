---
aep: 2.3.0
owner: repository
date: 2026-08-17
kind: reference
mode: [implement, test, prototype]
use-when: "installing dependencies, running scripts, or running tests with Bun"
---

# Reference — Bun

**This file is yours.** Installed because a Bun lockfile was detected. Fill the
table from `package.json` and CI.

```sh
bun install --frozen-lockfile    # what CI runs
bun run <script>
bun test                         # Bun's own runner
bun test <path>
bun x <tool>                     # run a tool without installing it
```

| Purpose | Command |
| --- | --- |
| build | `bun run build` |
| test | `bun test` |
| lint | `bun run lint` |
| types | `bun run typecheck` |

**Check which test runner this repository actually uses.** A `package.json` with
a `test` script pointing at Vitest or Jest means `bun test` runs a different
suite than CI does — a difference that reads as a passing run.

## Failure handling

- Bun's Node compatibility is close but not total. A failure that looks like a
  missing Node API is worth confirming against the runtime the repository ships
  to, rather than worked around.
- **Never publish.**
