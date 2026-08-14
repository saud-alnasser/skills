---
owner: framework
version: 2.0.0
---

# Workflow protocol

This repository runs the **Agentic Engineering Protocol**; this file is its router — what every stage opens to learn the mode it runs under, the guides it reads, and whether Context can be trusted. It is framework law: nothing below is specific to any one repository — every path it names is protocol machinery identical wherever the protocol is installed, and the forge reference is a role precisely so the table never has to name a repository's choice. **This file names no extension point.** A repository that must depart from it declares a `deviates-from` edge on the record that departs, which every build reports until it is removed — so a deviation is loud by construction rather than by somebody opening the right file, and removing it removes the report with no other edit. A prose section here could only be read by whoever thought to look.

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

The marker file holds **two facts**: the commit drift was last read against, and a fingerprint of the working tree it was read against. The `git` reference names its path, the read, and the fingerprint invocation, and is the only record that does. It is Position: machine-local and gitignored, because a teammate's verification is not Claude's.

```
marker.json commit == HEAD  AND  marker.json tree == fingerprint of the tree now
  → the two drift reads may be skipped

otherwise
  → read the drift, and verify the statements you are about to rely on
```

- **Both comparisons are identity tests, and there is no third condition** — a fingerprint of a dirty tree is the same kind of value as a fingerprint of a clean one, so nothing asks whether the tree is clean; a dirty tree that has not changed since its drift was read matches, which is the case the second fact exists for.
- **What a match licenses is exactly that, and no more** — an earlier run read this tree's drift and dealt with it. It does **not** say any knowledge is correct: verification at use is unaffected either way, and a statement about to be relied on is checked against the Codebase whether the marker matched or not.
- **The Marker is a cache-validity check, not a task** — the matching path is two `git` reads and no drift reading, and it never adds an obligation: with no marker file at all, verification at use applies unchanged and only the shortcut is lost. What a missing file means at check time is the `git` reference's.
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
- The `git` reference has the exact invocations and the `--porcelain` parsing.

## Reported, every time

Every skill that relies on Context opens with a verification report — **including when there was nothing to verify**, because silence is indistinguishable from the check never having run. The report has two halves, and they are not the same kind of statement:

- ***Position* is computed** — the Marker's two facts against the live two, and the drift lists when they differ. A script copied into `.claude/scripts/` produces it, and the stage **quotes that output rather than composing its own** — the invocations live once, in the reference that holds them, and reproducing them per stage gives one procedure as many homes as there are stages.
- ***Judgement* is the stage's own** — which repository governs this request, which Domain Contexts it routes to, whether a Source Pointer still resolves, whether a Context statement is contradicted by source, and what was done about each. No script can produce it; the stage prints it beneath.
- **The governing repository leads the judgement half** — the one line that can make the rest moot. It is judgement because a script can only report the repository it is *standing in*, and which repository a request is *for* is a fact about the request — which is also why it cannot be attested. When the two differ, `.claude/rules/boundary.md` governs what may be produced, and the refusal **names both repositories** — the one governing the request and the one this tree is — where it noticed, not at the end.
- **The position half is attested; the judgement half is not.** The run that computes the position writes a **Receipt** recording what was seen and which mode it was seen in, and `/commit` refuses a position no Receipt attests. A Receipt proves the position was **computed**, never that the stage read it or acted on it — verification at use is untouched and unenforced by it.
- **Where drift was read, the report says which happened to it** — healed, or discounted as outside what the work touches. That sentence is what makes the re-stamp auditable; a report that says drift was read and stops has not earned the re-stamp.

## The release this protocol was written by

The `version` field every framework-owned file declares is the release that last changed that file's content, written where the file is authored and varied by nobody. On this file it is more: every release stamps this template whether or not anything else in it moved, so the entry's stamp is always the release itself and one field speaks for the whole installation. **Nothing here compares it** — the comparison needs the *running* release, reachable only from what the framework ships, so a `SessionStart` hook the plugin carries makes it once per session, saying one line on a mismatch and nothing on a match. A file declaring no version is **unknown rather than stale**, and a reader without the plugin loses a notification rather than a rule.

## Recovering a broken Source Pointer

A pointer says *start investigating here* — never what exists there. When one no longer resolves, search for where the concept moved and repair the pointer where it stands; **never invent a replacement path**. One that cannot be recovered by searching is reported broken, not guessed at. The `git` reference has the two commands that find where a concept went.

## Modes

A mode is the reasoning posture a stage runs under: what it optimises for, what it deliberately gives up, and what finished means while it holds. A posture is defined by the record declaring it, one record per posture and nowhere else — several stages share one posture, and a posture restated per stage drifts at one of them. A skill declares exactly one as `metadata.mode`; the table below names it per stage; and the mode arrives with the row when the stage starts.

## Entering a stage

The entry table — which stage a request enters — lives in the always-on tier, its one home: classification must fire on every turn, and this file is reached only by the turn that already routed. What belongs here is how a named stage is reached:

| Activity | Reached by |
| --- | --- |
| the build | `/implement` |
| triage | `/triage` |
| design | `/design` |

- **Stated, then taken.** A stage named but not entered is the round trip the entry rule exists to remove; the statement is not a gate — it is what lets a wrong route be corrected in one line.

## Which norms each stage receives

The mode column names the posture the stage runs under, and the third column names the norms
its row carries. Both are subjects rather than locations: a record is reached by delivery or
by query, never by opening a file, so there is no path here to follow and none to correct.

| Stage | Mode | Norms it receives |
| --- | --- | --- |
| `/configure` | maintenance | every norm in both stores — it writes the repository's own and an audit run reads each one back against the repository |
| `/triage` | review | `tracker` |
| `/design` | design | `decisions`, `evidence`, `knowledge`, `maps`, `records`, `specs`, `tickets`, `tracker` |
| `/implement` | implementation | `context`, `knowledge`, `records`, `sub-agents`, `tickets`, `tracker`, `version-control` |
| `/review` | review | `decisions`, `sub-agents`, `tracker` |
| `/research` | research | `evidence`, `sub-agents` |
| `/prototype` | prototype | `evidence` |
| `/commit` | maintenance | `knowledge`, `records`, `specs`, `tracker`, `version-control` |

- **A row is mandatory and exact.** A stage receives its whole row and stops — judged selection is the mis-load being removed, and nothing in the corpus tells a stage to choose among its norms. A row that cannot be afforded whole is a row that is too big, and the fix is cutting the corpus, never restoring selection.
- **The column describes the row; it does not produce one.** What a stage receives is computed from each record's own firing condition, and this column is a committed statement of that computation's result. Nothing at run time reads it, which is exactly why it is checked against the store rather than trusted: a column nothing reads is a column whose drift makes no noise.
- **A `reference` is not in any row, and that is its type rather than an omission.** It carries no firing condition, so nothing delivers it; the stage that reaches for an invocation queries for it at the operation, which is a condition and not a judgement. The forge reference — whichever of `github`, `gitlab`, or `graphite` this repository holds — is reached the same way, and a stage that finds none for an operation has hit a configuration gap and says so rather than guessing the flag.
- **A context record is not in a row either.** Every stage reaches the repository's vocabulary and the Domain Contexts the request touches, which is knowledge rather than a norm — the same for all eight, so it is stated once here rather than repeated in eight rows.
- **`sub-agents` appears on every row whose stage dispatches** and on no other listed row — the contract a child is bound by, received by dispatchers, paid for by nobody else. `/configure`'s row is the whole corpus, as ever.
- **A stage receives its row and stops** — reading another stage's norms is the cost this table exists to remove, and a norm reached with no row naming it is either a missing row or a stage doing another stage's job.

Following a row needs the framework running. The store is committed markdown and a teammate without the plugin reads the same records, but reaching one is a query rather than a path — which is the dependency 2.0 takes deliberately, and the promise it retires.
