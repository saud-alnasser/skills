---
use-when: "authoring a skill for the protocol, or a note beside a shipped one"
---

# Template — skill

**The conforming skill set is fixed, and a repository does not add to it.** What
a repository may add is a **note** beside a shipped skill, whose shape is below;
its own governance goes under `rules/`, orientation under `contexts/`, and how a
tool is operated here under `references/`. A skill is authored in the protocol,
at `.aep/skills/<name>.md`, and this records the shape it takes.

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
`.aep/skills/<name>/<note>.md`, linked from the skill. The skill file is read on
**every** invocation; a note is read only by the run that needs it.

```markdown
---
use-when: "<the branch this is for — not its topic>"
---

# <Skill> — <the branch>

What this covers, and the neighbouring branch it is not.
```

A note **opens no report of its own**: it is reached from inside a run rather
than invoked, so it is a stage of that run (`[[policies/reporting]]`). It never
governs. **An unlinked note is unreachable**, so add the link in the same
change. A repository may add one beside a shipped skill, and link it from a rule
or context the repository owns.

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
