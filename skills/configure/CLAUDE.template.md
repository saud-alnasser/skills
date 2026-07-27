# {Repo name}

<!--
  Installed by /configure. This is the repository's sole always-on entrypoint:
  every turn pays for it, including turns where no skill runs.

  What belongs here is only what must hold *unconditionally*. A rule that
  applies to one stage belongs in the skill that enforces that stage — a rule
  written into a skill fires only when that skill runs, which is exactly right
  for stage rules and silently wrong for these. A standard discovered in this
  repository belongs in `.claude/rules/`.

  Keep it under 200 lines. Everything else is reached by pointer.
-->

{One or two sentences: what this repository is.}

## Precedence

When instructions conflict, the later source loses:

1. What the user said in this conversation
2. This file
3. `.claude/context.md` and the Domain Contexts
4. `.claude/docs/decisions/` — an accepted ADR
5. `.claude/rules/` and `CONTRIBUTING.md`
6. `README.md` and the rest of the repository's documentation — CONTRIBUTING outranks it because CONTRIBUTING says how this repository is worked on and README says what it is

A user instruction overrides everything here. Say so when it does, and follow it.

`.claude/rules/` holds standards discovered in **this repository** — they belong to it, not to Tenure. A rule that applies to only part of the tree is **path-scoped** to that part; check the scope before applying one.

## Knowledge layers

| Knowledge layer | Answers | Lives in |
| --- | --- | --- |
| Codebase | what currently exists | source |
| Context | how this repository thinks | `.claude/context.md`, `.claude/contexts/**` |
| Decisions | why this approach was selected | `.claude/docs/decisions/` |

The order is a **truth hierarchy, and it is absolute**. Where they disagree, the Codebase is right. Resolve every conflict by changing the documentation to match reality — never the reverse, and never by explaining the code away.

Load `.claude/context.md` at the start of a session. Load a Domain Context only when the request touches it; the routing table at the end of `context.md` says which and when. Loading them all defeats the point.

## Trusting Context — the Marker

`.claude/marker.json` holds the commit Context was last verified against. It is machine-local and gitignored: a teammate's verification is not Claude's.

```
marker.json commit == HEAD  AND  working tree clean
  → Context is trusted as-is. No verification, no reading.

otherwise
  → verify the statements you are about to rely on, and only those
```

The clean path is one `git` check and no reading. That is the whole point of the Marker — it is a cache-validity check, not a task.

Only `/commit` advances the Marker, to the new `HEAD` after committing. Nothing else moves it.

### When the Marker does not match

Drift has two sources, and a check that reads only one will miss the other:

```
git diff --name-only <marker>..HEAD -- . ":(exclude).claude/"   # what commits changed
git status --porcelain --untracked-files=all                    # what the human changed, uncommitted
```

Discount files Claude wrote this session — those are not drift, they are this session's own work.

If the Marker is not an ancestor of `HEAD` — a branch switch, a rebase, a reset — the diff between them is meaningless. Do not try to salvage one: treat everything the request touches as unverified.

See `tools/git.md` for the exact invocations and for how `--porcelain` output is parsed.

## Verify before claiming

**Inspect source before any repository-specific claim** — before implementing, designing, reviewing, or answering a question about this repository. Not sometimes: a claim about what is here is either checked or it is a guess wearing the same words.

**Names are not proof.** A file, directory, symbol, or package name records what someone once intended, not what is there now. Neither is memory, and neither is a plausible-sounding API.

## Verification at use

**Never a scan. Never a phase.** There is no synchronization stage to run and nothing to reconcile up front — a startup scan would be Claude rediscovering what it already knows, and paying for it on every session.

Instead: at the moment a Context statement is about to be relied on, check it against the Codebase. Scope is whatever the work touches. Drift somewhere else is not this request's problem, and chasing it is how a check becomes a phase.

**Source Pointers are verified before use, always.** A pointer says *start investigating here* — never what APIs, functions, or behavior exist there. When a pointer is broken, recover it by searching the repository for where the concept moved. **Never invent a replacement path.** A pointer that cannot be recovered is reported as broken, not guessed at.

## Healing in place

Fix what you find, where you find it. A stale pointer is repaired in the same breath as discovering it is stale; a boundary that moved is corrected then and there. No queue, no deferred pass, no note to come back.

## Strict, and reported

This discipline is **not best-effort**. The safety net — a periodic reconciliation stage — does not exist, so nothing catches a lapse except the reporting.

Every skill that relies on Context opens with a one-line verification report. **Including when there was nothing to verify.** "Marker matches HEAD, tree clean — Context trusted" is a statement; silence is indistinguishable from the check never having run.

## Requests that would change code

A question gets an answer: load what you need to answer it, and stop.

A request that would **change code** takes the cold path, on every turn, whether or not a workflow command was invoked:

1. Marker check.
2. Route, load, verify — as above.
3. **State the classification** before touching anything: what kind of change this is, and the tier it implies. One line.

The point of stating it is that the user can disagree. A classification held silently is a decision made silently.

**Claude never silently decides architecture.** Where more than one reasonable approach exists, put the options on the table — each named, with what it buys, what it costs, and what it risks — recommend one, and let the user choose. A single confident recommendation with the alternatives left unmentioned is a silent decision.

## Writing knowledge

CI never modifies repository knowledge. `.claude/context.md`, `.claude/contexts/**`, and `.claude/docs/decisions/**` change through the workflow's own commands and nothing else.

**The compression test, before anything is written into knowledge:** *will this improve a future engineering decision?* If not, don't write it. This applies on every turn, including the ones where a concept moves and no command was typed — capture is not a licence to accumulate.

What belongs in Context and what never does is the `domain-modeling` skill's business — it is the skill that writes it.

## Conventions

**Tenure's conventions are defaults for when the repository is silent** (ADR 0008), never mandates. Where `CONTRIBUTING.md`, a PR template, an existing label set, or the repository's own history documents or demonstrates a convention, that convention wins — detect it before asserting one. Where the repository's convention is genuinely worse, say so once, with reasoning, and then follow it.

The defaults, applied when nothing else is found:

Conventional Commits — `type(scope): summary` — for commit subjects, PR titles, and issue titles. The scope names an engineering domain; `misc`, `stuff`, and `update` are not domains.

**Never guess an API, and a CLI is an API.** Read the reference or fetch the docs — there is no third option where you try a flag and see. `tools/` covers the workflow's own tools; `.claude/tools/` covers this repository's.

Tenure never pushes and never publishes. Committing is asked for; pushing, opening a PR, and submitting a stack are the human's call.
