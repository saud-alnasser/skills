# git — version control

Docs: https://git-scm.com/docs
Fetch the docs when: a subcommand or flag you need is not listed below.
Never guess a flag. An unlisted flag is a docs fetch, not an assumption.

Everyday git — `add`, `commit`, `log`, `diff`, `checkout` — needs no entry here. This file covers what git does *for Tenure*: the drift reads the workflow depends on, the parsing that quietly goes wrong, and the standing rules about writing history.

## Check the Marker

The Marker in `.claude/marker.json` is the commit Context was last verified against. Two questions, in order.

```
git cat-file -e "<marker>^{commit}"            # exit 1 → the Marker commit is gone
git merge-base --is-ancestor <marker> HEAD     # exit 1 → HEAD left the Marker's history
```

Either failure means the Marker is not a base you can diff from — a branch switch, rebase, reset, or a rewritten commit moved HEAD off its line. There is no meaningful diff to take: treat everything the request touches as unverified.

Quote `^{commit}` — bare `^` and `{` are metacharacters in PowerShell and in cmd.

## Read the Marker diff

Committed drift: what changed in the Codebase since Context was last verified.

```
git diff --name-only <marker>..HEAD -- . ":(exclude).claude/"
```

Two dots, not three. `<marker>..HEAD` is "what HEAD has that the Marker doesn't"; three dots would fold the Marker's own side back in.

Exclude the knowledge paths. A commit that only edited `.claude/context.md` is not drift in the Codebase, and counting it re-verifies Context against its own edits.

## Read uncommitted drift

The human's own edits since the last commit — the second drift source, and the one a diff against HEAD cannot see.

```
git status --porcelain --untracked-files=all
```

`--porcelain` is the stable machine format; default output is for humans and changes between releases. Untracked directories collapse to a single `?? dir/` line unless `--untracked-files=all` is passed.

The parsing is the part that goes wrong. Each line is `XY<space><path>`: status in columns 1–2, path from column 4. **Split on the first space and you mis-read ` M` (modified, unstaged) as a one-character status.** `X` is the index, `Y` the working tree — so `MM` is staged-then-modified-again, ` D` is deleted but unstaged, `??` is untracked. A rename's path field is `old -> new`, and paths with spaces or non-ASCII come back quoted; `-z` gives NUL-separated raw paths when that matters.

## Read a review diff

`/code-review` has the rules. These are the reads it depends on, against a fixed point the human supplied.

```
git rev-parse --verify "<fixed-point>^{commit}"   # exit 1 → bad ref
git diff <fixed-point>...HEAD                     # committed, vs the merge-base
git log <fixed-point>..HEAD --oneline             # the commits in it
git diff HEAD                                     # uncommitted, staged and not
git ls-files --others --exclude-standard          # untracked, not in any diff
```

**Three dots for the diff, two for the log** — the opposite pairing to the Marker read above, so it is worth being deliberate. `A...HEAD` diffs against the *merge-base*, leaving out what landed on `A` after the work started. `A..HEAD` is a commit range and already means "what HEAD has that A doesn't"; three dots there would fold A's own commits back in.

`git diff HEAD` covers staged and unstaged together; `git diff` alone silently omits anything already staged. Neither shows an untracked file, which is why the last line is not optional — a review that reads only the diffs cannot see a newly added file at all.

## Recover a broken Source Pointer

`CLAUDE.md` has the rule. These are the two commands that find where the concept went:

```
git log --diff-filter=D --name-only -- <path>     # which commit deleted it
git log --follow --name-only -- <path>            # follow it through renames
```

If neither finds it, search the Codebase for the concept by name.

## Commit

```
git commit -F <file>                              # multi-line message from a file
```

Name paths explicitly when staging. **Never `git commit -a`** — it sweeps in every tracked modification in the tree, including edits the human made for their own reasons and never asked to ship.

## Amend

Post-commit changes amend rather than stacking a fixup, so one logical change stays one commit.

```
git log -1 --format="%H %s"                       # confirm what you are about to rewrite, first
git commit --amend --no-edit
```

Amend only a commit created in this session. Confirm before amending anything else — rewriting a commit someone else may have pulled is not something they can recover from locally.

## Never push

```
git push                            # do not run
git push --force / --force-with-lease
git push --set-upstream <remote>    # pushes as a side effect
```

Tenure does not push. Publishing is the human's call, and it is the one action here they cannot undo locally.

If a workflow appears to require a push, stop and say so. (On a Graphite repo, `gt submit` pushes too — the same rule applies; see [graphite.md](graphite.md).)
