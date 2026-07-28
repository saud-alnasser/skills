---
name: help
description: Ask which command fits the situation you are in. A router over Tenure's skills, organised by how work arrives.
disable-model-invocation: true
---

# Help

Ask the tenured engineer. Say what you are trying to do; this says where to start. Everything is grouped by **how the work arrived**, because that is what you know at the moment you need to choose.

Tenure ships as a plugin, so every command below is namespaced to it — `/tenure:design`, `/tenure:implement`, and this one as `/tenure:help`. The short forms are used throughout for readability.

**First, once: `/configure`.** Nothing below works properly until it has run — it writes the tracker configuration, this repository's own tool commands, and the knowledge everything else reads. See **Knowledge** for what a later run does.

## The Spine

Most work travels this route.

```
/design ──▶ /implement ──▶ /review ──▶ /commit
```

- **`/design`** — start here whenever the work is not already planned. It is the **whole planning surface**: discovery, the grill, the spec, the tickets, and the map for a foggy multi-session effort. There is nothing else to reach for while planning.
- **`/implement`** — when a ticket exists and is ready to build. One per invocation, and it reads the ticket rather than the conversation, so you can clear context between any two.
- **`/review`** — when you want a diff reviewed against a fixed point you name. The Spine runs it for you before it asks to commit; reach for it directly for a branch or a PR.
- **`/commit`** — when work is finished and ready to land. Reach for it directly when the work arrived without a ticket.

Only `/design` and `/help` are typed by habit. The rest are reachable, and the Spine pulls them in on its own.

### The two detours

- **`/research`** — when a decision turns on a fact that is not in this repository: an external API's behaviour, a library's guarantee, a specification's wording.
- **`/prototype`** — when a design question will not settle on paper: does this state model feel right, what should this actually look like.

Both are **detours, not steps.** A **gate** decides whether the answer is load-bearing enough to stop for, and most changes never fire one. Reaching for either on every change is how a config edit acquires a research phase.

### How much process this gets

Ceremony scales to risk rather than one process applying to everything. The tier is `max(Floor, Gates)` — the floor your change classifies into, raised by any gate that fires.

It is chosen **after the grill**, never before: sizing a change before you understand it anchors the whole conversation to the guess. `/design` holds the classifications and the gates, and reports which fired.

**The tier is yours to override**, in either direction — up or down. Say so and `/design` takes it.

## When something has already gone wrong

- **`/triage`** — issues you did **not** create: bug reports, incoming feature requests, anything that arrived raw. Tickets `/design` produced are already agent-ready, so running them through triage is work for nothing.
- **`/diagnosing-bugs`** — when something is broken and did not yield to a first look: the intermittent flake, the regression between two known-good commits.
- **`/resolving-merge-conflicts`** — when a merge or rebase has stopped with conflicts. Reach for it before resolving any by hand.

## Keeping the repository worth working in

- **`/survey`** — not feature work. Two situations: when you have a spare moment and want to know where the codebase is costing you, and when a diagnosis has just concluded that the real problem was **no seam to lock the bug down**. It finds candidates; picking one gives you something to take into `/design`.

## Knowledge

- **`/configure`** — once per repository, to join it to Tenure; and **again** whenever you want the audit pass over what is already written down.

**Verifying what is written down, and repairing it where it is wrong, has no command at all.** It happens continuously, at the moment a statement is about to be relied on, inside whatever command is running. There is nothing to schedule. If you are looking for the command that reconciles everything, it does not exist, and that is deliberate.

## What runs underneath

Vocabulary and discipline the commands above pull in. Reach for one directly when the **words**, or the **method**, are the problem rather than the process.

- **`grilling`** — when you want an idea attacked rather than accepted.
- **`tdd`** — when you want to build one concrete behaviour test-first.
- **`codebase-design`** — when you are deciding a module's *shape*: where the seam goes, how much sits behind the interface.
- **`domain-modeling`** — when the problem's *words* are the trouble: a fuzzy term, one word doing three jobs, or a choice you are unsure is worth recording.

**How to type a command is not a skill.** `.claude/tools/` holds one file per tool this repository uses — the workflow's own and yours — written by `/configure` and committed, so it is there with or without Tenure installed. `CLAUDE.md` has the rule about reading it, and what to do when an entry is missing.

## Crossing sessions

A thread that has run too long stops reasoning well before it stops working, and the tell is subtle: it keeps answering, just worse. The [smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone) is the window where it still reasons sharply, and reaching the end of it is what forces this choice.

- **`/handoff`** — when you want a **fresh session** but need this conversation preserved. It writes the thread to a file you open the next session against. **It forks.**
- **`/compact`** (built-in) — when you want to **stay here** and can afford to lose the verbatim history. **It continues.**

Compact at a deliberate break between phases, never mid-phase. Hand off when the next thing is genuinely new work, or when you are near the end of the zone with a phase still open.
