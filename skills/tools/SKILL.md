---
name: tools
description: How to drive the command-line tools the workflow touches — git, GitHub, GitLab, Graphite, and whatever this repository runs. Use before issuing any CLI command, whenever a flag or subcommand is not already certain.
---

# Tools

Tenure's first principle is **never guess an API**, and a CLI is an API. A guessed flag fails loudly at best and does the wrong thing quietly at worst.

This skill is entirely reference. Read the file for the tool you are about to use; if the operation you need is not in it, fetch the tool's docs. Those are the only two options — there is no third one where you try a flag and see.

## What is here

| Tool | File | Covers |
| --- | --- | --- |
| `git` | [git.md](git.md) | Marker checks, drift reads, `--porcelain` parsing, amend discipline, the never-push rule |
| `gh` | [github.md](github.md) | auth, issues, blocking edges, PRs |
| `glab` | [gitlab.md](gitlab.md) | the same on GitLab, where the nouns differ |
| `gt` | [graphite.md](graphite.md) | stacks, `gt create` / `gt modify`, and why they replace `git commit` on a Graphite repo |

These are the tools Tenure itself drives, so they ship with it.

## What is not here

**This repository's own tooling** — package manager, test runner, typechecker, linter, build, deploy — lives in `.claude/tools/*.md`, in the same format. `/configure` writes those files from what it discovers in the repo, and re-checks them on its audit pass, because a repo's tooling changes and a stale command is worse than no command.

That is how `/implement` knows to run this repo's single-file test command rather than assuming `npm test`, and how `tdd` finds the command for one file instead of the whole suite. Read `.claude/tools/` before running anything repo-specific.

If a repo-specific command is needed and `.claude/tools/` has no entry for it, that is a gap in the configuration — say so, and find the answer in the repo's own manifest or docs rather than trying a command.

## The format

Every file: purpose, the docs URL, **and the condition for fetching it** — a URL with no trigger is decoration. Then task-to-command pairs under task-shaped headings.

The question a reader arrives with is always *"how do I do X here"*, never *"what does `-n` mean"*. Write entries that answer the first. A flag catalogue is what the docs are for.

Leave out what is already certain. An entry for `git log` earns nothing; an entry for the exact `--porcelain` column layout, or for a verb whose name lies about what it does, earns its place. Note the gotcha, not the syntax.
