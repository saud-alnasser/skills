---
name: prototype
description: Build throwaway code to answer a design question by feel, then record the answer and delete the code. Use when a state model, an interaction, or a layout has to be driven by hand before it can be judged.
---

# Prototype

A prototype is **throwaway code that answers a question**. Its sibling `/research` answers questions about **facts**; this one answers questions about **feel** — does this state model hold up, does this layout read right. The question decides the shape.

The durable output is not the code. It is a **write-up**, and the code is deleted.

## 0 — Has this already been answered?

Read `.claude/evidence/prototypes/` first. **Reuse operates on the write-up, not on the code** — the code is gone by design, and rebuilding an experiment whose answer is already recorded is the waste this directory exists to prevent.

Same question, assumptions still hold, conclusion recorded: trust it.

## 1 — Pick a branch

Identify the question — from the request, from the surrounding code, or by asking.

- **"Does this logic or state model feel right?"** → [LOGIC.md](LOGIC.md). A small interactive terminal app that pushes the model through cases that are hard to reason about on paper.
- **"What should this look like?"** → [UI.md](UI.md). Several radically different variations on one route, switchable as you look at them.

The two produce very different things, and getting it wrong wastes the whole prototype. If the question is genuinely ambiguous and nobody is reachable, follow the surrounding code — a backend module is a logic question, a page or component is a UI one — and state the assumption at the top of the write-up.

## 2 — Where things live

| What | Where | Fate |
| --- | --- | --- |
| The code | `.claude/position/prototypes/<name>/` | deleted, always |
| The write-up | `.claude/evidence/prototypes/<name>.md` | kept |

The two are deliberately **apart**, because the write-up outlives the code and a document filed next to something that is about to be deleted invites deleting both.

`.claude/position/prototypes/` is **gitignored scratch**, carried by `.claude/.gitignore` so the whole workflow stays one removable directory.

**One exception, and it is the dangerous one.** A UI variant mounted inside the running application cannot live in a scratch directory — the whole reason sub-shape A in [UI.md](UI.md) works is that the variant renders against the real header, real data, real density. That code sits where it renders and is **not** gitignored, which makes it the prototype code most likely to be committed by accident. Deletion applies harder there, not softer: it comes out in the same change that records the answer, along with the switcher.

Rules that hold on both branches:

1. **Throwaway from day one, and named so a reader can tell.**
2. **One command to run it**, on whatever task runner the repository already uses. Never a remembered path.
3. **No persistence** unless persistence is the question. State lives in memory; where the question genuinely involves a database, point at a scratch one named so nobody mistakes it — `PROTOTYPE — wipe me`.
4. **Skip the polish** — no tests, no abstractions, no error handling beyond what makes it run. A prototype that needs tests has stopped being one.
5. **Surface the state.** Show the whole relevant state after every action, or the question cannot be judged.

## 3 — Hand back a way to see it

A prototype that answers a *feel* question is worthless until the user looks at it. End with the command that runs it, or drive the built-in `run` skill.

**Never describe a UI in prose and call the question answered.** Prose is what the prototype exists to replace — if a description were enough, no code needed writing.

The interesting feedback is the moment they say *wait, that shouldn't be possible* or *I want the header from B with the sidebar from C*. That is the bug in the idea, which is the entire point. If they want more cases, add them; prototypes evolve until the question is settled.

## 4 — Write the write-up

**Before deleting anything.** A prototype is not finished until its conclusion is recorded, and that ordering is the whole mechanism — deleting code that took real effort is uncomfortable, and a write-up deferred until after the deletion is a write-up that never gets written.

`.claude/evidence/prototypes/<name>.md`:

```markdown
# <the question tested, as a question>

Verified against: <runtime/library> <version>, <date>
Conclusion: Successful | Partially Successful | Failed | Inconclusive

## Hypothesis

What was expected to happen, written before it was run.

## Method

What was built and how it was driven — enough that someone could
disagree with the method rather than only with the result.

## Result

What actually happened. The cases that behaved unexpectedly, named.

## Limitations

What was not exercised, and what the result therefore does not settle.

## Conclusion

The verdict, with the reasoning that gets to it. Why this conclusion
and not the next one along.
```

The conclusion is **required** for **Failed** and **Inconclusive** — the highest-value case, because a recorded failure stops the same experiment being run again next quarter — and for a **Successful** prototype that was not promoted. It is **optional only when the prototype was promoted**, since the answer is then embodied in shipped code and the rejected alternatives belong in an ADR.

## 5 — Delete the code

Once the question is answered the code is **always deleted**. Promote it first if it can be promoted; delete it either way.

There is **no reusable-harness exception.** That carve-out gets claimed for almost every prototype at the moment of finishing it, which is precisely when reusability is most overestimated and least tested.

**Promotion is a fresh implementation effort** — redesign, integration, tests, documented APIs — and **not a file move**. The prototype's code informs that work and is still deleted. Code written under prototype constraints promoted as-is carries every one of those constraints into production, silently.

## 6 — Evidence is not knowledge

The write-up is **Evidence**: the trail showing how a claim was earned, recording what was verified and when. `.claude/policies/evidence.md` says why that is not a knowledge layer.

**Never write Context directly**, and never promote a write-up yourself. Both rules, and what does happen to a durable result, are in `.claude/policies/evidence.md`.

---

Branch structure and the throwaway discipline derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
