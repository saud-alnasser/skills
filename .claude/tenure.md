# Tenure protocol

<!--
  Installed by /configure at `.claude/tenure.md`.

  This is the other half of the split root `CLAUDE.md` describes. `CLAUDE.md`
  is always-on and read by every Claude that opens this repository, with or
  without Tenure, so it carries only rules that hold either way. This file
  carries the machinery those rules are *served* by — machinery that exists
  only where the plugin does.

  Nothing here is a rule that must fire on every turn. A rule that must hold
  unconditionally belongs in `CLAUDE.md`; putting one here means it fires only
  when a Tenure skill happens to run, which is a silent failure. What is here
  is a cache, the two reads that invalidate it, and the report that proves the
  check happened.

  Only Tenure's skills read this file, and they reach it by pointer. Nothing
  committed reads it to learn a fact about the repository.
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

The clean path is one `git` check and no reading. That is the whole point of the Marker — it is a cache-validity check, not a task. It never *adds* an obligation: with no marker file at all, `CLAUDE.md`'s verification-at-use rule applies unchanged and nothing is lost but the shortcut.

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

## Reported, every time

Every skill that relies on Context opens with a one-line verification report. **Including when there was nothing to verify.** "Marker matches HEAD, tree clean — Context trusted" is a statement; silence is indistinguishable from the check never having run.

That report is the only evidence the discipline ran. `CLAUDE.md` says verification is never best-effort; this is what makes a lapse visible rather than silent.
