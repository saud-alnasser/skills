# Workflow protocol

This repository runs the **Agentic Engineering Protocol**; this file is its per-repository router — what every stage opens to learn the mode it runs under, the guides it reads, and whether Context can be trusted.

<!--
  Installed by /configure at `.claude/protocol.md`.

  Named for its job rather than for the framework. A file named after the
  product says nothing about when to open it; this one is the router the
  workflow's stages read, and the name says so.

  Two tiers load without a pointer being followed: `CLAUDE.md`, and
  `.claude/rules/` files with no `paths:` frontmatter. Both hold rules that must
  fire whether or not a stage is running. This file holds the machinery those
  rules are *served* by, plus the table saying which committed guide each stage
  reads.

  Nothing here is a rule that must fire on every turn. A rule that must hold
  unconditionally belongs in one of the two always-on tiers; putting one here
  means it fires only when a workflow stage happens to run, which is a silent
  failure. What is here is a cache, the two reads that invalidate it, the report
  that proves the check happened, and a routing table.

  It is reached by pointer, so a turn that answers a question does not pay for
  it — that cheapness is the whole reason it is not a rule. And it is committed,
  so a reader without the plugin follows `CLAUDE.md`'s pointer and reads exactly
  what Claude reads.
-->

## Position

**Position is state describing where *this clone* stands, rather than what the repository knows.** The commit Context was last verified against, the ticket this working tree has claimed, the prototype code currently on disk. It is per-clone and never committed.

**Position has a directory: `.claude/position/`.** That is the category made structural rather than declared — a per-clone file goes there and is covered by the existing ignore rule, instead of arguing for a new exception each time.

`.claude/.gitignore` still carries the membership test in prose, because the directory says *where* and only the test says *which*. Read it there. One file sits outside: `settings.local.json` belongs to the harness rather than to this workflow, and the harness would not find it anywhere else.

The invariant that keeps Position from becoming a fourth knowledge layer: **nothing shared may depend on it.** Delete every ignored file under `.claude/` and no other person and no other clone loses information they needed. This clone loses a shortcut and re-earns it.

## Trusting Context — the Marker

The marker file holds the commit Context was last verified against — `.claude/tools/git.md` names its path and the read, and is the only file that does. It is Position: machine-local and gitignored, because a teammate's verification is not Claude's.

```
marker.json commit == HEAD  AND  working tree clean
  → Context is trusted as-is. No verification, no reading.

otherwise
  → verify the statements you are about to rely on, and only those
```

The clean path is one `git` check and no reading. That is the whole point of the Marker — it is a cache-validity check, not a task. It never *adds* an obligation: with no marker file at all, the verification-at-use rule applies unchanged and nothing is lost but the shortcut. What a missing file means at check time — and what it does not license — is `.claude/tools/git.md`'s.

Only `/commit` advances the Marker, to the new `HEAD` after committing. Nothing else moves it.

### When the Marker does not match

Drift has two sources, and a check that reads only one will miss the other:

```
git diff --name-only <marker>..HEAD -- . ":(exclude).claude/"   # what commits changed
git status --porcelain --untracked-files=all                    # what the human changed, uncommitted
```

Discount files Claude wrote this session — those are not drift, they are this session's own work.

If the Marker is not an ancestor of `HEAD` — a branch switch, a rebase, a reset — the diff between them is meaningless. Do not try to salvage one: treat everything the request touches as unverified.

See `.claude/tools/git.md` for the exact invocations and for how `--porcelain` output is parsed.

## Reported, every time

Every skill that relies on Context opens with a one-line verification report. **Including when there was nothing to verify.** "Marker matches HEAD, tree clean — Context trusted" is a statement; silence is indistinguishable from the check never having run.

That report is the only evidence the discipline ran. Verification is never best-effort; this is what makes a lapse visible rather than silent.

## Recovering a broken Source Pointer

A pointer says *start investigating here* — never what exists there. When one no longer resolves, search for where the concept moved and repair the pointer where it stands; **never invent a replacement path**. One that cannot be recovered by searching is reported broken, not guessed at. `.claude/tools/git.md` has the two commands that find where a concept went.

## Modes

A mode is the reasoning posture a stage runs under: what it optimises for, what it deliberately gives up, and what finished means while it holds. The definitions live in `.claude/modes/`, one file per posture and nowhere else, because several stages share one posture and a posture restated per stage drifts at one of them. A skill declares exactly one on its `Mode:` line, the table below names it per stage, and it holds for exactly as long as the stage runs — read the stage's mode file when the stage starts. Each states what it gives up, because a posture that gives up nothing is not one.

## Which guides each stage reads

Every stage also loads `.claude/contexts/repository.md` and routes from its table to the Domain Contexts the request touches. That is knowledge rather than a guide, and it is the same for all seven, so it is stated once here instead of once per row. The mode column names the posture the stage runs under, defined in `.claude/modes/`.

| Stage | Mode | Guides it reads |
| --- | --- | --- |
| `/configure` | maintenance | every guide in `.claude/policies/` — it writes them all, and an audit run reads each one back against the repository |
| `/design` | design | `.claude/policies/tickets.md`, `.claude/policies/specs.md`, `.claude/policies/maps.md`, `.claude/policies/decisions.md`, `.claude/policies/evidence.md`, `.claude/policies/knowledge.md`, `.claude/policies/tracker.md`, `.claude/tools/git.md`, the forge reference |
| `/implement` | implementation | `.claude/policies/tickets.md`, `.claude/policies/knowledge.md`, `.claude/policies/context.md`, `.claude/policies/tracker.md`, `.claude/policies/version-control.md`, `.claude/tools/git.md`, the forge reference |
| `/review` | review | `.claude/policies/decisions.md`, `.claude/rules/`, `.claude/decisions/`, `.claude/tools/git.md`, the forge reference |
| `/research` | research | `.claude/policies/evidence.md` |
| `/prototype` | prototype | `.claude/policies/evidence.md`, `.claude/.gitignore` |
| `/commit` | maintenance | `.claude/policies/specs.md`, `.claude/policies/knowledge.md`, `.claude/policies/version-control.md`, `.claude/policies/tracker.md`, `.claude/tools/git.md` |

**The forge reference is whichever of `github.md`, `gitlab.md`, or `graphite.md` this repository's `.claude/tools/` actually holds** — the row names a role because the file filling it is chosen per repository. A stage that finds no reference for an operation has hit a configuration gap and says so; it does not guess the flag.

A stage reads its row and stops. Reading another stage's guides is the cost this table exists to remove, and a guide reached with no row naming it is either a missing row or a stage doing another stage's job.

**A row is what a stage *may* read, not what it must.** `/design` names five guides and a docs fix opens none of them — the tier selects which, and reading a format while still grilling is the thing the tier gate exists to stop.

Every guide named above is committed markdown in this repository. Following any row needs nothing installed; only running the stages does.
