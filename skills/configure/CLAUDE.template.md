# {Repo name}

<!--
  Installed by /configure. The root entrypoint: every turn pays for it, and it
  is committed, so every Claude that opens the repository loads it — plugin or
  not. It carries only what holds either way, and reaches the rest by pointer;
  every file it points at is committed too, so a reader without the plugin
  follows the same pointers — only the slash commands need it.

  Placement is by **loading mechanism**, not by subject — the three tiers the
  AEP specification names:

    boot tier      this file, and `.claude/rules/` with no `paths:` frontmatter
                   — always-on, loaded by the harness on every turn
    scoped tier    `.claude/rules/` with `paths:` — loads when a covered file is read
    pointer tier   everything reached by a pointer, including `.claude/protocol.md`

  A rule that must fire unconditionally goes in one of the first two, never
  behind a pointer a stage has to follow — that fires only when the stage
  runs, which is a silent failure. Keep this file under 200 lines.
-->

{One or two sentences: what this repository is.}

## Rules that always apply

`.claude/rules/precedence.md`, `.claude/rules/engineering.md`, and `.claude/rules/placement.md` are always-on and never restated here — a standard with two homes drifts at one of them. The rest of that directory is path-scoped by `paths:` frontmatter.

## Knowledge layers

| Layer | Answers | Lives in |
| --- | --- | --- |
| Codebase | what currently exists | source |
| Context | how this repository thinks | `.claude/contexts/**` |
| Decisions | why this approach was selected | `.claude/decisions/` |

The order is absolute: where they disagree, the Codebase is right — fix the documentation, never the reverse. Load `.claude/contexts/map.md` at session start — routing only; Domain Contexts load on demand, and loading them all defeats the point.

## Where the machinery lives

- `.claude/protocol.md` — the router: the verification machinery and the stage table. Committed, and reached by pointer — a question turn never pays for it.
- `.claude/modes/` — one reasoning posture per file.
- `.claude/policies/tracker.md` — where the tickets live; `.claude/policies/version-control.md` — how work lands. `.claude/tools/` — how to *type* any of it.

## Verification at use

**Never a scan. Never a phase.** Check a Context statement against the Codebase at the moment it is about to be relied on; scope is what the work touches. **Source Pointers are verified before use, always** — a broken one is searched for, never invented; the router has the machinery. Fix drift where you find it, in the same breath; nothing else catches a lapse.

## Requests that would change code

A question gets an answer: load, answer, stop. A change to code, every turn, command or not: route, load, verify, then **state the classification** — what kind of change, how much process, one line — before touching anything, so the user can disagree.

## Writing knowledge

CI never modifies repository knowledge: `.claude/contexts/**` and `.claude/decisions/**` change only through the workflow's commands. Before any write into knowledge, the compression test: *will this improve a future engineering decision?* If not, don't write it. What belongs in Context: `.claude/policies/context.md`.

## Conventions

**The workflow's conventions are defaults for when the repository is silent** (ADR 0008): detect before asserting, and where the repository's own convention is genuinely worse, say so once, with reasoning, then follow it. Defaults: `.claude/policies/version-control.md`.
