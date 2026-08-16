---
aep: 2.1.1
owner: repository
date: 2026-08-16
kind: context
use-when: "orienting in this repository for the first time in a session, before reaching for a narrower context"
---

# Context — this repository

**This file is yours, and it is a stub.** AEP seeded it so there is somewhere to
put orientation; nothing here is true until you make it true. Replace every
placeholder, and delete what does not apply.

Keep it **small**. This is the cross-cutting context — vocabulary and shape that
every area needs. Anything that belongs to one area belongs in its own context
with its own `use-when`, so it loads only when that area is touched.

## What this repository is

_One paragraph: what it produces, and for whom._

## Shape

| Directory | Holds |
| --- | --- |
| | |

## Vocabulary

Terms that mean something specific here — especially any that mean something
*different* here than elsewhere. A word the code and the humans use differently
is where the next defect is.

| Term | Means |
| --- | --- |
| | |

## Where to look

Point at the source; never restate it. A pointer says *start reading here* — it
never claims what APIs or behaviour exist there, because that claim goes stale
silently while the pointer stays useful.

| To understand | Start at |
| --- | --- |
| | |

## Areas with their own context

_Add a row when an area grows enough to deserve its own file._

| Area | Context |
| --- | --- |

---

**This file describes; it never instructs.** A requirement belongs in
`[[rules]]`; a procedure belongs in `[[references]]`. And the repository is
authoritative over everything written here — where the source disagrees, the
source is right and this file gets corrected (`[[rules/precedence]]`).
