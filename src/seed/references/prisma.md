---
aep: 2.0.0
owner: repository
date: 2026-08-16
kind: reference
mode: [implement, plan, test]
use-when: "changing this repository's Prisma schema, or generating and applying a migration"
---

# Reference — Prisma

**This file is yours.** Installed because a `schema.prisma` was detected. Record
which environment variable supplies the database URL and what it points at
locally — that decides how dangerous the commands below are.

## Commands

```sh
npx prisma generate                      # regenerates the client; touches no database
npx prisma migrate dev --name <name>     # local only: creates and applies a migration
npx prisma migrate deploy                # applies pending migrations, creates none
npx prisma migrate status                # what has and has not run
npx prisma migrate diff --from-... --to-...   # inspect a diff without applying it
npx prisma studio                        # browser UI against the live database
```

| Purpose | Command |
| --- | --- |
| regenerate client | `npx prisma generate` |
| new migration | `npx prisma migrate dev --name <name>` |
| apply migrations | `npx prisma migrate deploy` |

## The destructive commands

- **`migrate dev` can reset the database.** When it detects drift it offers to
  drop and recreate, and in a non-interactive run that prompt is not shown.
- **`db push` applies the schema with no migration file**, and `--accept-data-loss`
  does exactly what it says.
- **`migrate reset` drops everything.**

All three are local-database-only, and none is run against a shared environment.
A migration that would drop a column is data loss even when the schema diff
looks tidy — read the generated SQL before applying it.

## Failure handling

- A client type that does not match the schema means `generate` has not run
  since the last edit.
- Drift detected on a shared database means something changed outside the
  migration history. That is a finding to raise, never something to resolve by
  resetting (`[[rules/engineering]]`).
- Never run any of these against production.
