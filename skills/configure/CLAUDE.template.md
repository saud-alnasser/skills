# {Repo name}

<!--
  Installed by /configure. The root entrypoint: every turn pays for it, and it
  is committed, so every Claude opening the repository loads it — plugin or
  not. It carries only what holds either way and reaches the rest by pointer;
  what it points at is committed too, so a reader without the plugin follows
  the same pointers — only the slash commands need it.

  Placement is by loading mechanism, not subject:

    boot tier      this file and `.claude/rules/` with no `paths:`, loaded
                   every turn, plus what the framework pushes
    scoped tier    `.claude/rules/` with `paths:` — a pointer the harness fires
    pointer tier   everything else, reached through the store

  A norm is boot tier only if its absence on a turn nobody started causes
  drift. All else is queried. Keep this file under 200 lines.
-->

{One or two sentences: what this repository is.}

## Rules that always apply

`.claude/rules/precedence.md`, `.claude/rules/engineering.md`, `.claude/rules/placement.md`, and `.claude/rules/boundary.md` are always-on and never restated here. They stay files, not records: the harness reaches them in a clone without the plugin, and nothing else does.

## Knowledge layers

| Layer | Answers |
| --- | --- |
| Codebase | what currently exists |
| Context | how this repository thinks |
| Decisions | why this approach was selected |

All three are records below. The order is absolute: where they disagree, the Codebase is right — fix the record, never the reverse.

## Machinery

`.claude/protocol.md` is the router — verification machinery and the stage table — reached by pointer, so a question turn never pays for it. The rest is records: the postures, where tickets live, how work lands, how to type a command.

## The store

`.claude/knowledge/` is the flat store of typed records, and everything outside this tier is reached through it. **How to reach it is stated here rather than served by it** — anything it served would arrive only once the server connects, so a store describing itself goes silent exactly when it goes down.

Two faces over one index: a tool for the model, a command line for the fallback and CI. **A stage that can reach neither rebuilds the index and carries on — and says so in its opening report, running degraded.** It never proceeds as though nothing were wrong: a stage quietly doing the wrong thing is the failure this tier prevents, a slow one is not.

A path-scoped rule is a **pointer only** — query the store for what fires there. The harness alone can notice that a covered file was touched, so the tier survives for that.

## Verification at use

**Never a scan. Never a phase.** A Context statement is checked against the Codebase at the point of use; scope is what the work touches. **Source Pointers are verified before use, always** — a broken one is searched for, never invented; the router has the machinery. Fix drift where you find it, in the same breath — nothing else catches a lapse.

## Which stage a request enters

A question gets an answer: load, answer, stop. A change, every turn, command or not: **state the classification** — what kind of change, how much process, and **which stage it enters** — one line, before touching anything, so the user can disagree — **then enter that stage**; how each is reached is the router's.

Top to bottom, first match wins — the four lower rows are read rather than judged:

| The request | Enters |
| --- | --- |
| it would change another repository | nothing — report, hand back |
| a question about how something works | nothing — answer, stop |
| this tree already holds a claim | the build, resuming it |
| a ticket is ready to build | the build |
| it arrived from outside — an issue, a pull request | triage |
| anything else that would change code | design |

**A loaded norm that settles a question is acted on, citing the line — never re-asked.** Asking is for genuine forks only.

## Framework law

**A record declaring `owner: framework` is followed as written — never edited, healed, or debated.** Variation enters as a `deviates-from` edge, which every build reports until it is removed. Unstamped records are the repository's, healed as ever.

## Writing knowledge

CI never modifies the store: `.claude/knowledge/` changes only through the workflow's commands. Before any write into it, the compression test: *will this improve a future engineering decision?* If not, don't write it.

## Conventions

**The workflow's conventions are defaults for when the repository is silent**: detect before asserting, and where the repository's own is genuinely worse, say so once, with reasoning, then follow it.
