# gt — Graphite (stacked changes)

Docs: https://graphite.com/docs
Fetch the docs when: a subcommand or flag you need is not listed below.
Never guess a `gt` command. Graphite's verbs are its own — several read like git's and do something else.

`gt --help --all` lists every command; `gt <command> --help` gives its flags. Check one of those before reaching for a command not listed here.

## Know whether the repo uses Graphite

A repo is on Graphite only if `gt init` has been run **in it**. `gt` being on the machine says nothing.

```
ls .git/.graphite_repo_config      # exists → initialised here. absent → plain git
```

Read the filesystem, not `gt`. **This command initialises the repository as a side effect** — do not use it to probe:

```
gt log --stack          # NOT a probe: initialises the repo, then exits 0
```

Verified on gt 1.8.6 in a repo that had never seen `gt`. It printed `Graphite has not been initialized, attempting to setup now...`, set trunk to `main`, then failed with `ERROR: Cannot perform this operation on untracked branch <name>` — and wrote `.graphite_repo_config`, `.graphite_metadata.db`, `.graphite_pr_info`, and `.gtlocalprinfo` into `.git/`, **and exited 0** — so a probe keyed on a non-zero exit reads an uninitialised repo as initialised, having just made that true. Nothing lands in the tracked tree, so `git status` stays clean and the change is invisible where you would look for it.

On a repo that is not on Graphite, use [git.md](git.md) and don't offer to initialize one unasked.

## The model

A **stack** is a sequence of branches, each built on its parent, each becoming its own PR. **Trunk** is what the stack merges into (`main`). **Downstack** is the ancestors of the current branch, **upstack** its descendants.

The consequence that matters: **one branch is one commit's worth of reviewable change.** Where plain git would add a second commit to a branch, Graphite either amends the branch or stacks a new one on top — and either way every descendant needs rebasing, which `gt` does for you and `git commit` does not.

## Create a branch with the staged changes

```
gt create <name> -m "type(scope): summary"
```

`gt create` branches *and* commits in one step — it is not `git checkout -b`. It commits what is staged; `-a` stages everything tracked first, and carries the same objection as `git commit -a` (see [git.md](git.md)), so stage explicitly instead.

Stacking is implicit: the new branch sits on top of whatever is checked out. To stack on something else, check that out first or pass `-o, --onto <branch>`.

`--onto` is how a ticket is built on its blocker rather than on trunk. The branch name is still Tenure's — `gt create <name>` takes it explicitly, so do not let `gt` generate one from the commit message.

## Amend the current branch

```
gt modify -m "type(scope): summary"     # amend the branch's commit
gt modify -c -m "type(scope): summary"  # add a new commit to this branch instead
```

This is the amend path on a Graphite repo, and the reason to prefer it over `git commit --amend`: **`gt modify` restacks every descendant automatically.** A bare `git commit --amend` in the middle of a stack leaves everything above it pointing at the old commit.

`gt modify` prompts to stage unstaged changes. In a non-interactive session that prompt is a hang — stage first.

## Navigate the stack

```
gt log --stack          # the stack, graphically
gt up / gt down         # one branch upstack / downstack
gt top / gt bottom
gt checkout <branch>
gt info <branch>        # PR title, body, and status for one branch
```

## Repair the stack

```
gt restack              # rebase every branch in the stack onto its parent
gt continue             # after resolving conflicts mid-restack
gt abort                # give up on the in-progress operation
```

`gt restack` is the fix when branches have drifted — most often because a `git` operation edited history that `gt` didn't know about.

## Never submit or sync

```
gt submit               # pushes to GitHub and opens/updates PRs — do not run
gt sync                 # pulls trunk, rebases, and prompts to delete merged branches — do not run
```

`gt submit` publishes. It is a push plus PR creation, so it falls under the same standing rule as `git push`: **Tenure does not publish** — that is the human's call.

`gt sync` is out for a second reason: it rewrites local history against the remote and interactively offers to delete branches. Both are destructive and both need a human at the keyboard.

### What submit cannot be handed

Verified against `gt submit --help` on gt 1.8.6, and against the command reference:

- **There is no `--title`, `--body`, `--body-file`, or stdin.** The metadata flags are prompts (`--edit`, `--edit-title`, `--edit-description`) and their negations, plus `--ai`. A pull request body cannot be pre-written and passed in.
- **Whether it prefills the description from the commit message is not documented** — not in `--help`, not in the command reference. So nothing may depend on it. Treat the body as unknown until a human is looking at the prompt.

That is why the closing keyword goes in the commit body on a stacking repository: it is the only text Tenure controls that reaches the pull request at all.
