---
aep: 2.1.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, plan, test]
use-when: "changing this repository's database schema, or generating and applying a migration"
---

# Reference — drizzle-kit

**This file is yours.** Installed because a `drizzle.config.*` was detected.
Read it for the dialect, the schema path, and the migrations directory — and
record **which database URL it resolves to**, because that is what decides how
dangerous the commands below are.

## Commands

```sh
npx drizzle-kit generate         # writes a migration from the schema diff; touches no database
npx drizzle-kit migrate          # applies pending migrations
npx drizzle-kit check            # detects conflicting or broken migration history
npx drizzle-kit up               # upgrades migration snapshot format
npx drizzle-kit studio           # opens a browser against the live database
```

| Purpose | Command |
| --- | --- |
| generate a migration | `npx drizzle-kit generate` |
| apply migrations | `npx drizzle-kit migrate` |

## The schema is the source, and `push` is not a migration

The workflow is: edit the schema, `generate`, **read the generated SQL**, then
`migrate`. A generated migration is not automatically correct — a renamed column
usually generates as a drop and an add, which is data loss that reviews cleanly.

**`drizzle-kit push` applies the schema diff straight to a database with no
migration file.** It is for a throwaway local database and nothing else. Never
run it against anything shared, and never run it to skip generating a migration.

## Failure handling

- A generated migration that is empty means the schema file the config points at
  is not the one you edited.
- `check` reporting a conflict means two branches generated migrations from the
  same parent. Resolving that by deleting a migration discards whatever already
  ran against a real database — raise it (`[[rules/engineering]]`).
- **Never point any of these at a production or shared database**, and never run
  a migration outside a local environment unasked.
