---
owner: repository
type: reference
---

# glab — GitLab CLI

Docs: https://gitlab.com/gitlab-org/cli/-/tree/main/docs/source
Fetch the docs when: a subcommand or flag you need is not listed below, **or before the first write of a session**.
Never guess a flag. An unlisted flag is a docs fetch, not an assumption.

> **This file was written without a `glab` on the machine to check against.** The entries below are the shape of the tool, not verified invocations. Confirm each with `glab <command> --help` before running it — that check is local, instant, and correct for the installed version, which is more than this file can promise.

`glab` mirrors `gh` closely enough to be a trap: GitLab's nouns differ. An issue is an **issue**, but a pull request is a **merge request** (`glab mr`), and a label set is managed per-project. Translating a `gh` command by search-and-replace produces plausible commands that don't exist.

## Check availability and auth

```
glab auth status        # non-zero → the tracker is not usable; say so rather than working around it
```

## Work with issues

```
glab issue create --title "<conventional title>"
glab issue list
glab issue view <id>
```

Body-from-stdin is the flag most worth confirming: GitLab calls the field a *description*, so the `gh` habit of `--body-file -` may not transfer. Check `glab issue create --help` for how this build spells it.

## Work with merge requests

```
glab mr create
glab mr view <id>
```

AEP does not open merge requests unasked — creating one publishes work, which is the human's call. Same standing rule as pushing (see [git.md](git.md)).

## Blocking relationships

GitLab models these as **linked issues** with a link type, rather than as sub-issues.

```
glab issue --help       # find the current subcommand for linking
```

Read the docs before using it. Where the link type isn't available, state the edge in the issue body — "Blocked by #12" — which is what the local-file tracker does anyway.
