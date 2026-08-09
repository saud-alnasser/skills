---
aep-version: 1.14.0
---

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

`.claude/.gitignore` still carries the membership test in prose, because the directory says *where* and only the test says *which*. Read it there. Two paths sit outside, both the harness's rather than this workflow's, and both at locations the harness would not find anywhere else: `settings.local.json`, and `worktrees/`, where it checks out an isolated child.

The invariant that keeps Position from becoming a fourth knowledge layer: **nothing shared may depend on it.** Delete every ignored file under `.claude/` and no other person and no other clone loses information they needed. This clone loses a shortcut and re-earns it.

## Trusting Context — the Marker

The marker file holds **two facts**: the commit drift was last read against, and a fingerprint of the working tree it was read against. `.claude/tools/git.md` names its path, the read, and the invocation that builds the fingerprint, and is the only file that does. It is Position: machine-local and gitignored, because a teammate's verification is not Claude's.

```
marker.json commit == HEAD  AND  marker.json tree == fingerprint of the tree now
  → the two drift reads may be skipped

otherwise
  → read the drift, and verify the statements you are about to rely on
```

**Both comparisons are identity tests, and there is no third condition.** A fingerprint of a dirty tree is the same kind of value as a fingerprint of a clean one, so nothing here asks whether the tree is clean — a dirty tree that has not changed since its drift was read matches, and that is the case the second fact exists for.

**What a match licenses is exactly that, and no more.** It says an earlier run already read this tree's drift and dealt with what it found. It does **not** say any knowledge is correct: verification at use is unaffected either way, and a statement about to be relied on is checked against the Codebase whether the marker matched or not. Reading a match as *Context is correct* is the mistake the second fact makes possible, so it is named rather than left to inference.

The matching path is two `git` reads and no drift reading. That is the whole point of the Marker — it is a cache-validity check, not a task. It never *adds* an obligation: with no marker file at all, the verification-at-use rule applies unchanged and nothing is lost but the shortcut. What a missing file means at check time — and what it does not license — is `.claude/tools/git.md`'s.

**A marker carrying no tree fact means the tree is unknown.** Compare the commit against `HEAD` and read the tree live, exactly as before the second fact existed. Nothing needs converting, and a clone that never gains it loses a shortcut and nothing else.

`/commit` writes both facts, together, so the pair is never half-fresh. **Any stage that reads drift and deals with what it found may re-stamp the tree fact alone**, leaving the commit fact untouched — healed it, or discounted it as outside what the work touches and said which. The permission is conditional on the dealing and never on the reading: a stage that read drift and neither healed nor discounted it has established nothing and re-stamps nothing. That narrowed claim is what makes a second writer safe at all.

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

Every skill that relies on Context opens with a verification report. **Including when there was nothing to verify** — silence is indistinguishable from the check never having run.

**The report has two halves, and they are not the same kind of statement.**

*Position* is computed — the Marker's two facts against the live two, and the drift lists when they differ. A script derived into `.claude/scripts/` produces it, and the stage **quotes that output rather than composing its own**: the invocations are recorded once in `.claude/tools/`, and reproducing them per stage gives one procedure as many homes as there are stages.

*Judgement* is the stage's own — which Domain Contexts the request routes to, whether a Source Pointer still resolves, whether a Context statement is contradicted by source, and what was done about each. **No script can produce it**, and the stage prints it beneath.

**The position half is attested; the judgement half is not.** The run that computes the position also writes a **Receipt** recording what was seen and which mode it was seen in, and `/commit` refuses a position no Receipt attests. Drawing the boundary is what makes any of this enforceable: the half that can be checked was previously not separated from the half that cannot, which is why the whole report read as something nobody could verify.

**What that does not cover, stated rather than left to inference.** A Receipt proves the position was **computed**, never that the stage read it or acted on it. Verification at use is untouched and unenforced by this — a statement about to be relied on is still checked against the Codebase at the moment of reliance, whatever any Receipt says.

**Where drift was read, the report says which happened to it** — healed, or discounted as outside what the work touches. That is not a second obligation: it is the same sentence the stage was already writing, and it is what makes the re-stamp above auditable rather than asserted. A report that says drift was read and stops has not earned the re-stamp, and the gap between the two reads as a stage that looked and moved on.

## The release this protocol was written by

The `aep-version` field above declares which release of the workflow wrote this file. `/configure` sets it, and nothing else changes it.

**Nothing here compares it.** The comparison needs the *running* release, and that is reachable only from what the framework ships — the harness exports the plugin's own root to a hook process and not to a stage's shell. So it is made once per session, by a hook the plugin carries, which says one line when the two differ and nothing when they match. A file declaring no version is **unknown rather than stale**, and a reader without the plugin loses a notification rather than a rule.

## Recovering a broken Source Pointer

A pointer says *start investigating here* — never what exists there. When one no longer resolves, search for where the concept moved and repair the pointer where it stands; **never invent a replacement path**. One that cannot be recovered by searching is reported broken, not guessed at. `.claude/tools/git.md` has the two commands that find where a concept went.

## Modes

A mode is the reasoning posture a stage runs under: what it optimises for, what it deliberately gives up, and what finished means while it holds. The definitions live in `.claude/modes/`, one file per posture and nowhere else, because several stages share one posture and a posture restated per stage drifts at one of them. A skill declares exactly one as `metadata.mode` in its frontmatter, the table below names it per stage, and it holds for exactly as long as the stage runs — read the stage's mode file when the stage starts. Each states what it gives up, because a posture that gives up nothing is not one.

## Which stage a request enters

`CLAUDE.md` requires the entry stage to be stated and then entered. This is the table it states from — read top to bottom, first match wins:

| The request | Enters |
| --- | --- |
| a question about how something works | nothing — answer it, and stop |
| this tree already holds a Claim | `/implement`, resuming that ticket |
| a ticket exists and is ready to build | `/implement` |
| it arrived from outside — an issue, a pull request | `/triage` |
| anything else that would change code | `/design` |

**Four of the five rows are read rather than judged.** The Claim is the branch, a ticket is a file or an issue, and an arrival from outside carries a reference — so the only judgement is the first row, telling a question from a change. That is what makes stating a route affordable on every turn, and it is why the table lives here rather than in the always-on tier: the tier carries the obligation, and this carries the lookup.

**Stated, then taken.** A stage named but not entered is the round trip the rule exists to remove. The statement is not a gate — it is what lets a wrong route be corrected in one line, which is what makes an imperfect route acceptable at all.

## Which guides each stage reads

Every stage also loads `.claude/contexts/repository.md` and routes from its table to the Domain Contexts the request touches. That is knowledge rather than a guide, and it is the same for all eight, so it is stated once here instead of once per row. The mode column names the posture the stage runs under, defined in `.claude/modes/`.

| Stage | Mode | Guides it reads |
| --- | --- | --- |
| `/configure` | maintenance | every guide in `.claude/policies/` — it writes them all, and an audit run reads each one back against the repository |
| `/triage` | review | `.claude/policies/tracker.md`, the forge reference |
| `/design` | design | `.claude/policies/tickets.md`, `.claude/policies/specs.md`, `.claude/policies/maps.md`, `.claude/policies/decisions.md`, `.claude/policies/evidence.md`, `.claude/policies/knowledge.md`, `.claude/policies/tracker.md`, `.claude/tools/git.md`, the forge reference |
| `/implement` | implementation | `.claude/policies/tickets.md`, `.claude/policies/knowledge.md`, `.claude/policies/context.md`, `.claude/policies/tracker.md`, `.claude/policies/version-control.md`, `.claude/policies/sub-agents.md`, `.claude/tools/git.md`, the forge reference |
| `/review` | review | `.claude/policies/decisions.md`, `.claude/policies/sub-agents.md`, `.claude/rules/`, `.claude/decisions/map.md` and the Decisions it routes to, `.claude/tools/git.md`, the forge reference |
| `/research` | research | `.claude/policies/evidence.md`, `.claude/policies/sub-agents.md` |
| `/prototype` | prototype | `.claude/policies/evidence.md`, `.claude/.gitignore` |
| `/commit` | maintenance | `.claude/policies/specs.md`, `.claude/policies/knowledge.md`, `.claude/policies/version-control.md`, `.claude/policies/tracker.md`, `.claude/tools/git.md` |

**The forge reference is whichever of `github.md`, `gitlab.md`, or `graphite.md` this repository's `.claude/tools/` actually holds** — the row names a role because the file filling it is chosen per repository. A stage that finds no reference for an operation has hit a configuration gap and says so; it does not guess the flag.

**`.claude/policies/sub-agents.md` appears on every row whose stage dispatches sub-agents**, and on no other row that names its guides one by one. It is the contract a child is bound by, so a stage that dispatches reads it and restates none of it; a stage that dispatches nobody never pays for it. `/configure` is the exception it always is — its row is the whole directory rather than a list.

A stage reads its row and stops. Reading another stage's guides is the cost this table exists to remove, and a guide reached with no row naming it is either a missing row or a stage doing another stage's job.

**A row is what a stage *may* read, not what it must.** `/design` names five guides and a docs fix opens none of them — the tier selects which, and reading a format while still grilling is the thing the tier gate exists to stop.

Every guide named above is committed markdown in this repository. Following any row needs nothing installed; only running the stages does.
