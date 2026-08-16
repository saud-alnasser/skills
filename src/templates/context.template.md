---
aep: 2.0.0
owner: protocol
date: 2026-08-16
use-when: "adding orientation for an area of this repository"
---

# Template — context

Copy to `contexts/<area>.md`. Contexts are always `owner: repository`.

```markdown
---
aep: <release>
owner: repository
date: <YYYY-MM-DD>
kind: context
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
corrected the moment the contradiction is found (`[[rules/precedence]]`).

## Keep it small

A context reduces discovery cost. One that restates the code has become
documentation with no rank in the authority order, and it will be believed after
it stops being true.
