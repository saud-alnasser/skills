---
use-when: "running this repository's local Supabase stack, or changing its database schema"
---

# Reference — Supabase

**This file is yours.** Installed because `supabase/config.toml` was detected.
Record which project ref, if any, this repository is linked to — a linked CLI
can reach a hosted database, and several commands below then stop being local.

## Commands

```sh
supabase start                   # local stack in Docker; slow on first run
supabase status                  # ports, keys, and whether it is actually up
supabase stop                    # add --no-backup to discard local data
supabase migration new <name>
supabase db diff -f <name>       # captures local changes as a migration
supabase db reset                # DESTROYS local data, replays migrations, reseeds
supabase functions serve <name>
```

| Purpose | Command |
| --- | --- |
| start local stack | `supabase start` |
| new migration | `supabase migration new <name>` |
| replay migrations locally | `supabase db reset` |

## Local and remote are one command apart

`supabase db push` applies migrations to the **linked remote project**, and
`supabase db pull` rewrites local migration history from it. Neither is a local
operation, and neither is run unasked.

Row-level security is the access model. **A policy widened to make a query work
is a security change**, not a fix — raise it with what it exposes
(`[[policies/engineering]]`).

## Failure handling

- `start` failing on a port is usually another Supabase stack still running.
  `supabase stop` before changing ports.
- The local anon and service keys are fixed development values. The service key
  bypasses row-level security entirely and never belongs in client code.
- **Never `db push`, `link`, or `secrets set` against a hosted project.**
