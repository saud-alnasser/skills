---
use-when: "running or building this Cloudflare Workers project locally"
---

# Reference — Wrangler

**This file is yours.** Installed because a Wrangler configuration was detected.
Record the environments it defines and which bindings — KV, D1, R2, Durable
Objects, queues — this Worker actually uses.

## Commands

```sh
npx wrangler dev                 # local, in workerd; long-running
npx wrangler dev --remote        # runs against Cloudflare's edge and REAL bindings
npx wrangler types               # regenerates binding types from the config
npx wrangler d1 execute <db> --local --command "<sql>"
npx wrangler tail                # live logs from a deployed Worker
```

| Purpose | Command |
| --- | --- |
| dev | `npx wrangler dev` |
| types | `npx wrangler types` |

## Local and remote

**`--remote` and any `d1`/`kv`/`r2` command without `--local` touch real
resources**, including real data. The flag is one word and the output looks the
same either way. Default to local, and never reach for `--remote` to make a
local failure go away.

## Never run

`wrangler deploy`, `wrangler versions deploy`, and `wrangler secret put` all
change what is live. Deployment is the human's (`[[rules/version-control]]`).

## Failure handling

- A binding that is undefined at runtime is usually declared for a different
  environment in the config.
- Workers run on workerd, not Node. A missing Node API is a platform difference,
  and `nodejs_compat` is a deliberate configuration change, not a quick fix.
- Local D1 and KV state lives on disk under the project. Deleting it to clear a
  failure also deletes local data.
