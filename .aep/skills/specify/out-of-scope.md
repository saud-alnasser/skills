---
aep: 2.1.1
owner: protocol
date: 2026-08-16
kind: skill
use-when: "a request is being declined rather than specified, or a new request resembles one declined before"
---

# Specify — recording what was declined

`/specify` turns a request into an effort. Some requests should not become one,
and the decision to decline is worth exactly as much as the decision to build —
**it is re-argued from scratch every time nobody wrote it down.**

There is no rejected-requests directory. AEP has two homes for this, and which
one applies is decided by **how far the decision reaches**.

| The decision is | It goes in |
| --- | --- |
| about **this change** — a boundary drawn around one effort | that effort's `# Out of Scope`, which `[[skills/specify]]` already requires |
| about **this repository** — a thing it does not do, and will not | a `[[contexts]]`, because it orients anyone who arrives with the same idea |

The second is the one that gets skipped, and it is the one that pays. A boundary
recorded only inside a closed effort is invisible to the next person, who opens a
fresh request in different words.

## The repository-level form

One entry per **concept**, never per request. Three requests for the same thing
share one entry, and the entry names the concept in words someone would recognise
without opening it.

Write it as short prose, not a database row — a paragraph, an example, whatever
makes the reasoning land for someone meeting it for the first time:

```markdown
## Theming

This project does not support user-facing theming.

The rendering pipeline resolves one palette at build time. Themes would need a
provider around the whole tree, theme-aware resolution at every component, and
somewhere to persist a preference — a large architectural change against a
project whose focus is content authoring. Theming is a downstream concern for
whoever embeds the output.

Asked before: three times, most recently as "night mode for accessibility".
```

**The reason must be substantive and durable.** Not *we do not want this*, but
why: a scope boundary, a technical constraint, a strategic choice already made.

**Never record a deferral as a rejection.** *We are too busy right now* is a
scheduling fact with a short life, and writing it down as a boundary means the
next person reads something that is no longer true and believes it. Where the
answer is *not now*, that is an unstarted effort or nothing at all.

**Never record something already built as declined.** A request closed because
the feature exists is not a rejection, and filing it as one poisons every later
check with a decision that never happened. Point at where it lives instead.

## Checking, before specifying

At `[[skills/specify]]` step 2 — the check for an existing effort — check for an
existing boundary too. **Match on concept, not keyword:** *night mode* is
*theming*.

On a match, **surface it rather than acting on it:**

> This looks like the theming boundary — declined because the pipeline resolves
> one palette at build time. Still the same view?

Three answers, and all three are the human's:

- **confirmed** — record that it was asked again, and stop.
- **reconsidered** — the boundary is wrong now. **Delete or rewrite the entry**
  in the same change, then specify normally. A boundary left standing beside an
  effort that contradicts it is worse than no boundary.
- **distinct** — related but not the same. Specify normally, and consider whether
  the entry should say more precisely what it covers.

**Never decline a request yourself on the strength of a match.** The entry is
evidence that a human decided this once; it is not standing authority to decide
it again (`[[rules/engineering]]`).
