# feat(tools): tool reference — how to drive every tool the workflow touches

Status: ready-for-agent
Blocked by: —

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
