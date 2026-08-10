---
aep-version: 1.18.0
owner: framework
---

# Workflow protocol

This repository runs the **Agentic Engineering Protocol**; this file is its router — what every stage opens to learn the mode it runs under, the guides it reads, and whether Context can be trusted. It is framework law: nothing below is specific to any one repository — every path it names is protocol machinery identical wherever the protocol is installed, and the forge reference is a role precisely so the table never has to name a repository's choice. What a repository may vary is the `aep-version` value and the entries of a `## Deviations` section, and nothing else.

<!--
  Installed by /configure at `.claude/protocol.md`, verbatim.

  Nothing here is a rule that must fire on every turn — those live in the two
  always-on tiers. What is here is a cache, the two reads that invalidate it,
  the report that proves the check happened, and the stage table. It is
  reached by pointer — `CLAUDE.md`'s — so a question turn never pays for it;
  committed, so a reader without the plugin follows the same pointer and reads
  exactly what Claude reads.
-->

## Position

- **Position is state describing where *this clone* stands, never what the repository knows** — the commit Context was last verified against, the claimed ticket, the prototype code on disk. Per-clone, never committed.
- **Position has a directory, `.claude/position/`** — the category made structural: a per-clone file goes there under the existing ignore rule instead of arguing for a new exception. `.claude/.gitignore` carries the membership test; two paths sit outside it, both the harness's: `settings.local.json`, and `worktrees/`.
- **Nothing shared may depend on it** — delete every ignored file under `.claude/` and no other clone loses information; this one loses a shortcut and re-earns it. That invariant is what keeps Position from becoming a fourth knowledge layer.

## Trusting Context — the Marker

The marker file holds **two facts**: the commit drift was last read against, and a fingerprint of the working tree it was read against. `.claude/tools/git.md` names its path, the read, and the fingerprint invocation, and is the only file that does. It is Position: machine-local and gitignored, because a teammate's verification is not Claude's.

```
marker.json commit == HEAD  AND  marker.json tree == fingerprint of the tree now
  → the two drift reads may be skipped

otherwise
  → read the drift, and verify the statements you are about to rely on
```

- **Both comparisons are identity tests, and there is no third condition** — a fingerprint of a dirty tree is the same kind of value as a fingerprint of a clean one, so nothing asks whether the tree is clean; a dirty tree that has not changed since its drift was read matches, which is the case the second fact exists for.
- **What a match licenses is exactly that, and no more** — an earlier run read this tree's drift and dealt with it. It does **not** say any knowledge is correct: verification at use is unaffected either way, and a statement about to be relied on is checked against the Codebase whether the marker matched or not.
- **The Marker is a cache-validity check, not a task** — the matching path is two `git` reads and no drift reading, and it never adds an obligation: with no marker file at all, verification at use applies unchanged and only the shortcut is lost. What a missing file means at check time is `.claude/tools/git.md`'s.
- **A marker carrying no tree fact means the tree is unknown** — compare the commit against `HEAD` and read the tree live; nothing needs converting.
- **`/commit` writes both facts, together, so the pair is never half-fresh.** Any stage that reads drift and **deals with what it found** — healed it, or discounted it as outside what the work touches and said which — may re-stamp the tree fact alone, leaving the commit fact untouched. The permission is conditional on the dealing and never on the reading: a stage that read drift and neither healed nor discounted it has established nothing and re-stamps nothing.

### When the Marker does not match

Drift has two sources, and a check that reads only one misses the other:

```
git diff --name-only <marker>..HEAD -- . ":(exclude).claude/"   # what commits changed
git status --porcelain --untracked-files=all                    # what the human changed, uncommitted
```

- **Discount files Claude wrote this session** — those are this session's own work, not drift.
- **A Marker that is not an ancestor of `HEAD` is not a base to diff from** — a branch switch, rebase, or reset makes the range meaningless: treat everything the request touches as unverified rather than salvaging one.
- `.claude/tools/git.md` has the exact invocations and the `--porcelain` parsing.

## Reported, every time

Every skill that relies on Context opens with a verification report — **including when there was nothing to verify**, because silence is indistinguishable from the check never having run. The report has two halves, and they are not the same kind of statement:

- ***Position* is computed** — the Marker's two facts against the live two, and the drift lists when they differ. A script derived into `.claude/scripts/` produces it, and the stage **quotes that output rather than composing its own** — the invocations live once in `.claude/tools/`, and reproducing them per stage gives one procedure as many homes as there are stages.
- ***Judgement* is the stage's own** — which repository governs this request, which Domain Contexts it routes to, whether a Source Pointer still resolves, whether a Context statement is contradicted by source, and what was done about each. No script can produce it; the stage prints it beneath.
- **The governing repository leads the judgement half** — the one line that can make the rest moot. It is judgement because a script can only report the repository it is *standing in*, and which repository a request is *for* is a fact about the request — which is also why it cannot be attested. When the two differ, `.claude/rules/boundary.md` governs what may be produced, and the refusal **names both repositories** — the one governing the request and the one this tree is — where it noticed, not at the end.
- **The position half is attested; the judgement half is not.** The run that computes the position writes a **Receipt** recording what was seen and which mode it was seen in, and `/commit` refuses a position no Receipt attests. A Receipt proves the position was **computed**, never that the stage read it or acted on it — verification at use is untouched and unenforced by it.
- **Where drift was read, the report says which happened to it** — healed, or discounted as outside what the work touches. That sentence is what makes the re-stamp auditable; a report that says drift was read and stops has not earned the re-stamp.

## The release this protocol was written by

The `aep-version` field above declares which release of the workflow wrote this file; `/configure` sets it and nothing else changes it. **Nothing here compares it** — the comparison needs the *running* release, reachable only from what the framework ships, so a `SessionStart` hook the plugin carries makes it once per session, saying one line on a mismatch and nothing on a match. A file declaring no version is **unknown rather than stale**, and a reader without the plugin loses a notification rather than a rule.

## Recovering a broken Source Pointer

A pointer says *start investigating here* — never what exists there. When one no longer resolves, search for where the concept moved and repair the pointer where it stands; **never invent a replacement path**. One that cannot be recovered by searching is reported broken, not guessed at. `.claude/tools/git.md` has the two commands that find where a concept went.

## Modes

A mode is the reasoning posture a stage runs under: what it optimises for, what it deliberately gives up, and what finished means while it holds. Definitions live in `.claude/modes/`, one file per posture and nowhere else — several stages share one posture, and a posture restated per stage drifts at one of them. A skill declares exactly one as `metadata.mode`; the table below names it per stage; read the stage's mode file when the stage starts.

## Entering a stage

The entry table — which stage a request enters — lives in the always-on tier, its one home: classification must fire on every turn, and this file is reached only by the turn that already routed. What belongs here is how a named stage is reached:

| Activity | Reached by |
| --- | --- |
| the build | `/implement` |
| triage | `/triage` |
| design | `/design` |

- **Stated, then taken.** A stage named but not entered is the round trip the entry rule exists to remove; the statement is not a gate — it is what lets a wrong route be corrected in one line.

## Which guides each stage reads

Every stage also loads `.claude/contexts/repository.md` and routes from its table to the Domain Contexts the request touches — knowledge rather than a guide, the same for all eight, so it is stated once here. The mode column names the posture the stage runs under.

| Stage | Mode | Guides it reads |
| --- | --- | --- |
| `/configure` | maintenance | every guide in `.claude/policies/` — it writes them all, and an audit run reads each one back against the repository |
| `/triage` | review | `.claude/policies/tracker.md`, the forge reference |
| `/design` | design | `.claude/policies/tickets.md`, `.claude/policies/specs.md`, `.claude/policies/maps.md`, `.claude/policies/decisions.md`, `.claude/policies/evidence.md`, `.claude/policies/knowledge.md`, `.claude/policies/tracker.md` |
| `/implement` | implementation | `.claude/policies/tickets.md`, `.claude/policies/knowledge.md`, `.claude/policies/context.md`, `.claude/policies/tracker.md`, `.claude/policies/version-control.md`, `.claude/policies/sub-agents.md`, `.claude/tools/git.md`, the forge reference |
| `/review` | review | `.claude/policies/decisions.md`, `.claude/policies/sub-agents.md`, `.claude/policies/tracker.md`, `.claude/rules/`, `.claude/decisions/map.md` and the Decisions it routes to, `.claude/tools/git.md`, the forge reference |
| `/research` | research | `.claude/policies/evidence.md`, `.claude/policies/sub-agents.md` |
| `/prototype` | prototype | `.claude/policies/evidence.md`, `.claude/.gitignore` |
| `/commit` | maintenance | `.claude/policies/specs.md`, `.claude/policies/knowledge.md`, `.claude/policies/version-control.md`, `.claude/policies/tracker.md`, `.claude/tools/git.md` |

- **A row is mandatory and exact.** A stage loads its whole row and stops — judged selection is the mis-load being removed, and nothing in the corpus tells a stage to choose among its guides. A row that cannot be afforded whole is a row that is too big, and the fix is cutting the row, never restoring selection.
- **A tool guide outside a row is reached when an operation needs it** — `/design` claims no branch and commits nothing, so its row carries no tool guide; the stage that reaches for an invocation opens the guide at the operation, which is a condition and not a judgement.
- **The forge reference is whichever of `github.md`, `gitlab.md`, or `graphite.md` this repository's `.claude/tools/` actually holds** — a role, because the file filling it is chosen per repository. A stage that finds no reference for an operation has hit a configuration gap and says so; it does not guess the flag.
- **`.claude/policies/sub-agents.md` appears on every row whose stage dispatches** and on no other listed row — the contract a child is bound by, read by dispatchers, paid for by nobody else. `/configure`'s row is the whole directory, as ever.
- **A stage reads its row and stops** — reading another stage's guides is the cost this table exists to remove, and a guide reached with no row naming it is either a missing row or a stage doing another stage's job.

Every guide named above is committed markdown in this repository. Following any row needs nothing installed; only running the stages does.
