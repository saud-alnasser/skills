---
owner: repository
---

# gh — GitHub CLI

Derived from: aep/github.md

Docs: https://cli.github.com/manual/
Fetch the docs when: a subcommand or flag you need is not listed below.
Never guess a flag. An unlisted flag is a docs fetch, not an assumption.

`gh <command> --help` is the fastest check and is always current for the installed version — prefer it over recalling a flag.

**The issue entries are deliberately absent.** The shipped reference is mostly about GitHub Issues — creating, finding, labelling, assigning, linking parents to children, closing by merge. This repository's tracker is markdown files under `.claude/tickets/`, and `.claude/policies/tracker.md` records that the GitHub issues are enabled and empty on purpose. Those operations cannot arise here, so the whole entries are gone rather than trimmed — and if one ever does, `.claude/rules/engineering.md` says what a missing entry means.

What `gh` is actually for here is the remote: checking it is reachable, and opening a pull request when you ask for one.

## Check availability and auth

```
gh auth status          # non-zero → the tracker is not usable; say so rather than working around it
```

Run this before the first tracker operation of a session, not after a failure.

## Open a pull request

```
gh pr create --title "<conventional title>" --body-file - --base main
```

AEP does not open PRs unasked — creating one publishes work, which is the human's call. Same standing rule as pushing (see [git.md](git.md)).

What the body covers is a convention, not an invocation: `.claude/policies/version-control.md` has it.
