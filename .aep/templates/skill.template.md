---
use-when: "adding a capability this repository wants alongside the shipped skills"
---

# Template — skill

Copy to `skills/<name>.md`. A skill the repository adds is `owner: repository`.

```markdown
---
use-when: "<the situation that calls for this capability>"
---

# /<name> — <what it does>

One or two lines: what this produces, and when it is the right thing to reach for.

**Posture.** How to think while running this, and **what this gives up** to
think that way. Two sentences, in your own words: a skill that names no
tradeoff is one nobody can tell they are running badly.

## Procedure
Numbered steps, in order. Each one an action, not a principle.

## Output
The artifact this leaves on disk, and where.

## Constraints
What this skill must not do — especially the shortcut that looks reasonable
while running it.

## Done when
The condition that ends it. Checkable, not "when it feels complete".

## Next
The skill that usually follows.
```

## Depth goes beside it, not in it

Knowledge needed only when a run takes a particular branch goes in
`skills/<name>/<note>.md`, linked from the skill. The skill file is read on
**every** invocation; a note is read only by the run that needs it.

```markdown
---
use-when: "<the branch this is for — not its topic>"
---

# <Skill> — <the branch>

What this covers, and the neighbouring branch it is not.
```

A note declares no `mode` — the skill reaching it has already entered one — and
**no `report`**, because it is reached from inside a run rather than invoked and
opens no report of its own (`[[policies/reporting]]`). It never governs. **An unlinked note is unreachable**, so add the link in the same
change. A repository may add one beside a shipped skill: declare
`owner: repository`, and link it from a rule or context the repository owns.

## What a skill is not

**A skill is never governance.** It operates under `[[policies]]` and `[[rules]]`. Where a skill and
a rule would say the same thing, the rule is the one that exists and the skill
links to it — a requirement stated in a skill applies only while that skill is
running, which is exactly when it is least needed.

**A skill does not restate a mode, a reference, or a context.** It points. Every
restatement is a second home, and the copy drifts first.

## Selection

A skill is chosen from its `use-when` and its opening lines. That text is the
entire basis of selection, so it says **when to reach for this**, not what the
skill is about. Say what it is *not* for too, where a neighbouring skill is the
likelier answer.
