# Workflow protocol

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

`.claude/.gitignore` is Position's **definition**, not a list of exceptions: it states the category and the test for membership in it, so a new per-clone file is covered by the rule rather than needing a new entry argued for. Read it there.

The invariant that keeps Position from becoming a fourth knowledge layer: **nothing shared may depend on it.** Delete every ignored file under `.claude/` and no other person and no other clone loses information they needed. This clone loses a shortcut and re-earns it.

## Trusting Context — the Marker

`.claude/marker.json` holds the commit Context was last verified against. It is Position: machine-local and gitignored, because a teammate's verification is not Claude's.

```
marker.json commit == HEAD  AND  working tree clean
  → Context is trusted as-is. No verification, no reading.

otherwise
  → verify the statements you are about to rely on, and only those
```

The clean path is one `git` check and no reading. That is the whole point of the Marker — it is a cache-validity check, not a task. It never *adds* an obligation: with no marker file at all, the verification-at-use rule applies unchanged and nothing is lost but the shortcut.

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

## Which guides each stage reads

Every stage also loads `.claude/context.md` and routes from its table to the Domain Contexts the request touches. That is knowledge rather than a guide, and it is the same for all seven, so it is stated once here instead of once per row.

| Stage | Guides it reads |
| --- | --- |
| `/configure` | `.claude/policies/context.md`; writes them all, and on an audit run reads each one back against the repository |
| `/design` | `.claude/policies/tickets.md`, `.claude/policies/specs.md`, `.claude/policies/maps.md`, `.claude/policies/decisions.md`, `.claude/policies/evidence.md`, `.claude/policies/tracker.md`, `.claude/tools/git.md`, the forge reference |
| `/implement` | `.claude/policies/tickets.md`, `.claude/policies/knowledge.md`, `.claude/policies/context.md`, `.claude/policies/tracker.md`, `.claude/policies/version-control.md`, `.claude/tools/git.md`, the forge reference |
| `/review` | `.claude/policies/decisions.md`, `.claude/rules/`, `.claude/decisions/`, `.claude/tools/git.md`, the forge reference |
| `/research` | `.claude/policies/evidence.md` |
| `/prototype` | `.claude/policies/evidence.md`, `.claude/.gitignore` |
| `/commit` | `.claude/policies/specs.md`, `.claude/policies/knowledge.md`, `.claude/policies/version-control.md`, `.claude/policies/tracker.md`, `.claude/tools/git.md` |

**The forge reference is whichever of `github.md`, `gitlab.md`, or `graphite.md` this repository's `.claude/tools/` actually holds** — the row names a role because the file filling it is chosen per repository. A stage that finds no reference for an operation has hit a configuration gap and says so; it does not guess the flag.

A stage reads its row and stops. Reading another stage's guides is the cost this table exists to remove, and a guide reached with no row naming it is either a missing row or a stage doing another stage's job.

**A row is what a stage *may* read, not what it must.** `/design` names five guides and a docs fix opens none of them — the tier selects which, and reading a format while still grilling is the thing the tier gate exists to stop.

Every guide named above is committed markdown in this repository. Following any row needs nothing installed; only running the stages does.
