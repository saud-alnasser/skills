---
owner: repository
title: feat(tools): tool reference — how to drive every tool the workflow touches
status: resolved
blocked-by: []
---

## Problem

Tenure's first principle is never guess an API. That applies to CLIs too, and nothing currently stops a skill inventing a `gh` flag, a `git` incantation, or a test-runner argument. Guessed flags fail loudly at best and do the wrong thing quietly at worst.

## Outcome

Two tiers, because workflow tools ship with Tenure and repo tools do not.

### Tier 1 — `./skills/tools/` — model-invoked

A skill that is entirely reference, so any other skill can reach it and the material lives in one place rather than being copied into each caller. One file per tool.

Format — purpose, where the real docs are and **when to go there**, then task-to-command pairs:

```markdown
# gh — GitHub CLI

Docs: https://cli.github.com/manual/
Fetch the docs when: a subcommand or flag you need is not listed below.
Never guess a flag. An unlisted flag is a docs fetch, not an assumption.

## Check availability and auth
gh auth status          # fails → the tracker is not usable, say so

## Create an issue
gh issue create --title "<conventional title>" --body-file -

## Link a blocking relationship
...
```

Ships with: `git.md`, `gh.md`, `glab.md`.

`git.md` matters most — it carries the operations Tenure depends on and gets wrong easily: reading the Marker diff, `--porcelain` parsing, amending safely, and the standing rule that **Tenure never pushes** (ticket 04).

### Tier 2 — `.claude/tools/*.md` — per repository

Written by `/configure` from what it discovers: package manager, test runner, typechecker, linter, build, deploy. Same format. This is how `/implement` knows to run `pnpm vitest run path/to/file` rather than guessing, and how `tdd` finds the single-file test command.

`/configure`'s audit branch re-checks these, since a repo's tooling changes.

## Acceptance

- No skill issues a command for a tool that has no entry — it reads the reference, or fetches the docs, first.
- Every file names its docs URL **and** the condition for fetching it. A URL with no trigger is decoration.
- Entries are task-to-command, not flag catalogues — the question is always "how do I do X here", never "what does `-n` mean".
- `/configure` writes `.claude/tools/` for the repo's own tooling and re-checks it on audit.

## Comments

**Files are named for the platform, not the binary.** Shipped as `git.md`,
`github.md`, `gitlab.md`, `graphite.md` rather than `gh.md` / `glab.md`. The
ticket named the binaries; the user asked for platform names while this was
being built, and a consistent axis reads better in the routing table. Each
file's heading still names its binary (`# gh — GitHub CLI`).

**`graphite.md` added.** Not in the ticket. Graphite is the stacking tool the
user drives instead of raw git, so a reference that omits it leaves the most
guessable surface uncovered — `gt`'s verbs read like git's and do something
else. Its command list and flags were read from the installed `gt` 1.8.6, and
it carries the never-publish rule for `gt submit` and `gt sync`.

**`gitlab.md` is unverified.** No `glab` on this machine, so its entries are
the shape of the tool, not confirmed invocations. The file says so at the top
and points every entry at `glab <command> --help`. `verify.ps1` asserts that
disclaimer is present — a reference that exists to stop guessing must not
quietly guess. Re-verify on a machine with `glab` installed.

**Entries are guides, not restatements.** Per the user: these files cover what
is *not* already known — Tenure-specific operations, parsing gotchas, verbs
that lie about what they do — plus the docs URL and its fetch trigger.
Everyday `git add` / `git log` deliberately have no entry.
