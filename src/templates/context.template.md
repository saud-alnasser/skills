---
use-when: "adding orientation for an area of this repository"
---

# Template — context

Copy to `contexts/<area>.md` — or to `contexts/<project>/<area>.md` in a
monorepo, when two projects would otherwise fight over the same area name. **One
project directory deep, no more.** Contexts are always `owner: repository`.

**The directory names; `paths:` scopes.** `web/auth` and `api/auth` can both be
called `auth` because the directory holds the name — but a nested context still
declares `paths:`, because nothing derives applicability from a directory. Where
one project has a single context and no name to fight over, flat is right.

```markdown
---
paths:                                   # omit if the area is not path-shaped
  - src/<area>/**
use-when: "<the trigger — working on X, changing Y>"
---

# Context — <area>

## What this area is
One paragraph.

## Vocabulary
Terms specific to this area, especially any that mean something different here
than elsewhere in the repository.

## Where to look
| To understand | Start at |
| --- | --- |

## Relationships
What this area depends on, and what depends on it.

## Related
Links to the rules, references, and other contexts this area needs.
```

## The three rules

**Facts, never instructions.** A context answers *what is true and where is it
found* — never *what should be done*. An instruction here is a rule in the wrong
file.

**A pointer says where to start reading.** It never claims what APIs or behaviour
exist there. *Why: the claim goes stale silently while the pointer stays useful,
and a stale claim is trusted exactly as a fresh one is.*

**The repository wins.** A context contradicted by source is wrong, and is
corrected the moment the contradiction is found (`[[policies/authority]]`).

## Keep it small

A context reduces discovery cost. One that restates the code has become
documentation with no rank in the authority order, and it will be believed after
it stops being true.
