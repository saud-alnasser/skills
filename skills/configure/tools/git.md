---
owner: repository
type: reference
---

# git — version control

Docs: https://git-scm.com/docs
Fetch the docs when: a subcommand or flag you need is not listed below.
Never guess a flag. An unlisted flag is a docs fetch, not an assumption.

Everyday git — `add`, `commit`, `log`, `diff`, `checkout` — needs no entry here. This file covers what git does *for AEP*: the drift reads the workflow depends on, the parsing that quietly goes wrong, and the standing rules about writing history.

## Check the Marker

The Marker is what Context was last verified against, and the marker file holds **two facts** about it: the commit drift was last read against, and a fingerprint of the working tree it was read against. `<marker>` and `<fingerprint>` below have exactly one source — that file, read fresh every time:

```
.claude/position/marker.json                   # { "commit": "<marker>", "tree": "<fingerprint>" } — the whole file
```

**Read the path from here, never from memory.** A recalled path that is wrong reads as a missing file — and a missing file is itself an answer, not a prompt to try another path: no marker file means nothing was ever verified in this clone, so treat everything the request touches as unverified and say so.

**A marker carrying no tree fact means the tree is unknown.** That shape is what clones written before the second fact existed still hold; it is not corrupt and nothing needs converting. Read the tree live — fingerprint it with the next entry and take the drift reads — rather than treating it as unchanged.

Two questions about `<marker>`, in order.

```
git cat-file -e "<marker>^{commit}"            # exit 1 → the Marker commit is gone
git merge-base --is-ancestor <marker> HEAD     # exit 1 → HEAD left the Marker's history
```

Either failure means the Marker is not a base you can diff from — a branch switch, rebase, reset, or a rewritten commit moved HEAD off its line. There is no meaningful diff to take: treat everything the request touches as unverified.

Quote `^{commit}` — bare `^` and `{` are metacharacters in PowerShell and in cmd.

`<fingerprint>` takes no git question of its own: it is compared against the value the next entry builds from the tree as it stands now.

## Fingerprint the working tree

The Marker's second fact. It answers *is this the same tree whose drift was already read* — an identity question, which is why it is a value rather than a clean/dirty flag.

Ask git where the index is; never assume the path. In a worktree `.git` is a file pointing elsewhere, so a hardcoded `.git/index` reads the wrong repository's index or none at all — and `--path-format=absolute` removes the remaining dependency on the current directory:

```
git rev-parse --path-format=absolute --git-path index
```

Then build the tree through a **throwaway index seeded from that one**:

```sh
idx="$(git rev-parse --path-format=absolute --git-path index)"
tmp="$(mktemp -u)"
cp "$idx" "$tmp"
GIT_INDEX_FILE="$tmp" git add -A
GIT_INDEX_FILE="$tmp" git write-tree                  # → the fingerprint
rm -f "$tmp"
```

```powershell
$idx = git rev-parse --path-format=absolute --git-path index
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
Copy-Item $idx $tmp
$env:GIT_INDEX_FILE = $tmp
git add -A
git write-tree                                        # → the fingerprint
$env:GIT_INDEX_FILE = $null                           # or it leaks into the next command
Remove-Item $tmp
```

**The seeding is not tidiness — it is what makes the check affordable.** A fresh temporary index has no stat cache, so `git add -A` re-hashes every file in the worktree on every stage. Seeded from the repository's own index, the stat cache comes with it and only genuinely changed files are re-hashed, which puts the cost beside `git status` rather than beside a full checkout.

The real index is never written: the copy is what `GIT_INDEX_FILE` points at. Verified by hashing `.git/index` either side of a run — byte-identical.

**What it covers**: file contents, tracked and untracked, with ignored files excluded because `git add -A` honours the ignore rules. A clean tree yields a value like any other, so there is no sentinel and no clean-versus-dirty branch for a caller to write.

Two cheaper-looking forms, and why neither is used:

- **`git stash create`** cannot see untracked files. Its usage line is `git stash create [<message>]` — there is no `-u`, and that is the whole argument: a newly added file would leave the fingerprint unchanged, which is false trust in exactly the case the drift read exists to catch.
- **A digest of `git status --porcelain` output** records *which* files changed and never *what they now contain*, so editing an already-dirty file a second time leaves the digest byte-identical. Unsound, and unsound in the direction that matters.

## Read the Marker diff

Committed drift: what changed in the Codebase since Context was last verified.

```
git diff --name-only <marker>..HEAD -- . ":(exclude).claude/"
```

Two dots, not three. `<marker>..HEAD` is "what HEAD has that the Marker doesn't"; three dots would fold the Marker's own side back in.

How far HEAD has moved, for the position report's own verdict line — the same range, counted rather than listed:

```
git rev-list --count <marker>..HEAD
```

`--count` is in `git rev-list -h`'s option list, and returns `0` for an empty range rather than printing nothing.

Exclude the knowledge paths. A commit that only edited `.claude/knowledge/` is not drift in the Codebase, and counting it re-verifies Context against its own edits.

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

## Remove a spent worktree

The harness creates a worktree for an isolated child; nothing removes one unless the orchestrator does. When it is spent is `/implement`'s to say — this is only how to type it.

```
git worktree list --porcelain                     # what exists, and which branch each holds
git worktree remove <path>                        # remove a spent one
git worktree prune                                # bookkeeping only — see below
```

**`remove` refuses a worktree that is not clean**, and that refusal is the point: *"Only clean worktrees (no untracked files and no modification in tracked files) can be removed."* A worktree that will not come away is one still holding work, so the refusal is a second opinion on the decision to remove it.

**`--force` exists and is not used here.** It removes an unclean worktree, and doubled (`--force --force`) removes a locked one. Reaching for it discards exactly the evidence that the judgement was wrong.

**`prune` deletes no working directory.** It removes *"worktree information in `$GIT_DIR/worktrees` for worktrees whose working trees are missing"* — bookkeeping for directories already gone, and nothing else. A reader who assumes otherwise will believe stale checkouts were cleaned up when only their metadata was.

## Recover a broken Source Pointer

`.claude/protocol.md` has the rule. These are the two commands that find where the concept went:

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

AEP does not push. Publishing is the human's call, and it is the one action here they cannot undo locally.

If a workflow appears to require a push, stop and say so. (On a Graphite repo, `gt submit` pushes too — the same rule applies; see [graphite.md](graphite.md).)
