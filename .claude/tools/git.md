# git — version control

Derived from: tenure/git.md

Docs: https://git-scm.com/docs
Fetch the docs when: a subcommand or flag you need is not listed below.
Never guess a flag. An unlisted flag is a docs fetch, not an assumption.

Everyday git — `add`, `commit`, `log`, `diff`, `checkout` — needs no entry here. This file covers what git does *for Tenure*: the drift reads the workflow depends on, the parsing that quietly goes wrong, and the standing rules about writing history.

Every entry below is carried over intact, cross-references included. One of them — the Graphite note under **Never push** — links to a reference this repository has no reason to derive, so it points at nothing. That is the derivation showing through rather than a pointer to chase: the sentence is conditional on a repository this one is not.

## Check the Marker

The Marker is the commit Context was last verified against. Two questions, in order.

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

Exclude the knowledge paths. A commit that only edited `.claude/contexts/` is not drift in the Codebase, and counting it re-verifies Context against its own edits.

## Read uncommitted drift

The human's own edits since the last commit — the second drift source, and the one a diff against HEAD cannot see.

```
git status --porcelain --untracked-files=all
```

`--porcelain` is the stable machine format; default output is for humans and changes between releases. Untracked directories collapse to a single `?? dir/` line unless `--untracked-files=all` is passed.

The parsing is the part that goes wrong. Each line is `XY<space><path>`: status in columns 1–2, path from column 4. **Split on the first space and you mis-read ` M` (modified, unstaged) as a one-character status.** `X` is the index, `Y` the working tree — so `MM` is staged-then-modified-again, ` D` is deleted but unstaged, `??` is untracked. A rename's path field is `old -> new`, and paths with spaces or non-ASCII come back quoted; `-z` gives NUL-separated raw paths when that matters.

## Read a review diff

`/review` has the rules. These are the reads it depends on, against a fixed point the human supplied.

```
git rev-parse --verify "<fixed-point>^{commit}"   # exit 1 → bad ref
git diff <fixed-point>...HEAD                     # committed, vs the merge-base
git log <fixed-point>..HEAD --oneline             # the commits in it
git diff HEAD                                     # uncommitted, staged and not
git ls-files --others --exclude-standard          # untracked, not in any diff
```

**Three dots for the diff, two for the log** — the opposite pairing to the Marker read above, so it is worth being deliberate. `A...HEAD` diffs against the *merge-base*, leaving out what landed on `A` after the work started. `A..HEAD` is a commit range and already means "what HEAD has that A doesn't"; three dots there would fold A's own commits back in.

`git diff HEAD` covers staged and unstaged together; `git diff` alone silently omits anything already staged. Neither shows an untracked file, which is why the last line is not optional — a review that reads only the diffs cannot see a newly added file at all.

## Bisect to the first bad commit

`diagnosing-bugs` builds the harness; this runs it. The harness must exit `0`
for good and non-zero for bad, and must be non-interactive.

```
git bisect start <bad> <good>                     # bad first, then a known-good
git bisect run <script>                           # drives it to the first bad commit
git bisect reset                                  # ALWAYS — restores the original HEAD
```

`git bisect run` leaves the tree checked out at the culprit and the repository
**in a bisect state**. Without `reset`, every later command in the session runs
against a detached HEAD somewhere in history, and the next `git status` reads as
catastrophic drift that is not real.

A harness that exits non-zero for a reason unrelated to the bug — a build
failure at an old commit, a missing dependency — marks that commit bad and
sends the search down the wrong half. Use `git bisect skip` for a commit that
cannot be tested rather than letting it fail.

## Read the current branch — which ticket this tree is building

The branch is the Claim (`/implement` has the rule), so this is the read that tells an instance which ticket it was on.

```
git branch --show-current                         # empty output → detached HEAD
```

**Empty output is a real answer, not a failure.** On a detached HEAD there is no branch, so there is no Claim — treat the tree as building nothing, whatever else it contains.

## Claim a ticket, or find the claim already held

Creating the branch *is* the claim, so it is one command and it comes before any work.

```
git switch -c <branch>                            # claim: create it and move onto it
git switch -c <branch> <start-point>              # ... based on something other than HEAD
git switch <branch>                               # resume a claim this clone already holds
```

`git switch -c` fails on a name that already exists rather than moving onto it, which is what makes the claim an exclusion rather than a request. Check first, and check both sides:

```
git show-ref --verify --quiet refs/heads/<branch> # exit 0 → claimed in this clone
git fetch --prune <remote>                        # refresh before believing the remote read
git ls-remote --heads <remote> <branch>           # any output → claimed in another clone
```

`git ls-remote` goes to the network every time and does not need a prior fetch; `git fetch --prune` is for the local remote-tracking refs, which go stale silently and will otherwise report a claim that was released days ago.

**Git enforces the rest.** A branch checked out in one worktree cannot be checked out in another:

```
fatal: '<branch>' is already used by worktree at '<path>'
```

That is exit 128 and it is the mechanism, not an error to work around. Report the path and stop — `/implement` has what to do next.

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
