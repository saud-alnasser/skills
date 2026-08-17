---
aep: 2.2.0
owner: protocol
date: 2026-08-17
use-when: "adding a rule this repository discovered about how work must be done here"
---

# Template — rule, this repository's own governance

Copy to `rules/<name>.md`. **Every rule is `owner: repository`** — `rules/` holds
what this repository decides for itself, and nothing else.

AEP's own governance ships as `[[policies]]`, which are protocol-owned and never
written or edited in a repository. So this template is the only governance
template there is: a constraint you need that AEP does not impose is a rule.

**Before writing one, check it is a rule at all:**

| If it is | It belongs in |
| --- | --- |
| a requirement on behaviour, decided here | a rule — here |
| a requirement AEP places on every repository | already a `[[policies]]`; do not restate it |
| how a tool is operated here | `[[references]]` |
| what is true about an area | `[[contexts]]` |
| something about one change | that effort's spec |

```markdown
---
aep: <release>
owner: repository
date: <YYYY-MM-DD>
kind: rule
mode: [<modes this is relevant to>]     # omit if it applies regardless
paths:                                   # omit if it is not path-scoped
  - src/<area>/**
use-when: "<the trigger that makes this applicable>"
---

# Rule — <name>

## <The obligation>

State it as a checkable imperative, then give its reason in one line.

*Why: <the failure this prevents>.*
```

## The two things that make a rule work

**`use-when` states a trigger, never a topic.** "Working with database
migrations" is a trigger. "Database standards" is a topic — it satisfies every
mechanical check and cannot be selected on, so the rule ends up loaded always or
never.

**Every norm carries its one-line why.** The reason is a floor, not an opening
argument: a *defended* rule invites re-evaluation instead of application, and an
unreasoned one is misapplied at exactly the edges the reason would have caught.
A rule whose why cannot be stated in one line is not understood well enough to
write down yet.

## Where it must not go

**A rule may tighten a policy; it may never soften one.** Requiring more than a
policy does is yours to decide. Requiring less — or contradicting it outright —
is a **declared deviation**: record what differs, why, and the release it was
declared under (`[[policies/artifacts]]`). Do not edit the policy.
