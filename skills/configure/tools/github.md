# gh — GitHub CLI

Docs: https://cli.github.com/manual/
Fetch the docs when: a subcommand or flag you need is not listed below.
Never guess a flag. An unlisted flag is a docs fetch, not an assumption.

`gh <command> --help` is the fastest check and is always current for the installed version — prefer it over recalling a flag.

## Check availability and auth

```
gh auth status          # non-zero → the tracker is not usable; say so rather than working around it
```

Run this before the first tracker operation of a session, not after a failure.

## Create an issue

```
gh issue create --title "<conventional title>" --body-file -
```

**Creating an issue publishes.** It lands in a workspace other people read, so it is the human's call — the same standing rule as opening a pull request and as pushing, and for the same reason. Propose the set, get it approved, then create. `/design` has the procedure.

`--body-file -` reads the body from stdin, which is how multi-line markdown survives intact — `--body` on a shell line does not. `-` for stdin, a path for a file.

Titles follow Conventional Commits, same as commit subjects: `type(scope): summary`.

## Find work

```
gh issue list --state open --label "ready-for-agent" --json number,title,labels
gh issue view <number> --comments
```

`--json` takes an explicit field list — there is no "all fields". `gh issue list --json` with no value prints the available field names, which is the quickest way to find one. Pair with `--jq` to filter without a second process.

## Comment and label

```
gh issue comment <number> --body-file -
gh issue edit <number> --add-label "in-progress" --remove-label "ready-for-agent"
gh label list                                     # read before creating any
gh label create "<name>" --color <hex> --description "<text>"
```

`gh issue edit` adds and removes labels; it does not replace the set.

`gh label list` is the read that comes before `gh label create`, always — `/triage` has the reuse rule. `create` fails on a name that already exists rather than editing it, so the list is what tells you whether you are adding or colliding. `--color` takes a bare hex with no leading `#`.

## Read and set Assignment

Assignment is which human owns delivering the issue. AEP reads it; it writes it only when asked (`/implement` has the rule).

```
gh issue view <number> --json assignees,state,labels
gh issue edit <number> --add-assignee "@me"       # only when the user asks for it
gh issue edit <number> --remove-assignee <login>
```

`@me` resolves to the authenticated user. `--add-assignee` and `--remove-assignee` adjust the set; neither replaces it.

**`gh issue develop` is not the claim.**

```
gh issue develop <number> --name <branch>         # creates the branch ON THE REMOTE — do not run
gh issue develop <number> --list                  # read-only: branches linked this way
```

`develop` creates the branch in the repository rather than locally, so it publishes — the same standing rule as pushing. It also names the branch by GitHub's convention rather than AEP's, and `--list` sees only branches created through it, so it is not the read that answers whether a ticket is claimed. That read is `git ls-remote` (see [git.md](git.md)).

## Link a parent and its sub-issues

`gh` has **no sub-issue subcommand**. Parent/child goes through the sub-issues REST API with `gh api`:

```
gh api repos/{owner}/{repo}/issues/<parent>/sub_issues \
  -f sub_issue_id=<id>                            # attach a child to the parent
gh api repos/{owner}/{repo}/issues/<parent>/sub_issues
                                                  # list the children
```

**`sub_issue_id` is the issue's `id`, not its number**, and that is the mistake this entry exists to stop — passing `#42`'s number succeeds against some other issue entirely. Read the id first:

```
gh api repos/{owner}/{repo}/issues/<number> --jq .id
```

Note the removal path is singular — `DELETE .../sub_issue`, not `sub_issues`.

Docs: https://docs.github.com/en/rest/issues/sub-issues. Fetch them before anything beyond the two calls above; the payload shape is not stable knowledge.

Where the API is unavailable or refused, a **task list in the parent body** (`- [ ] #42`) is the fallback GitHub renders as a real relationship.

## Record a blocking relationship

`gh` has **no blocking subcommand**, and blocking is not the same edge as parent/child — see the entry above for that one.

**State the edge in the issue body.** "Blocked by #12, #14." Legible to humans, no API surface, and it is what the local-file tracker does anyway.

## Open a pull request

```
gh pr create --title "<conventional title>" --body-file - --base main
```

AEP does not open PRs unasked — creating one publishes work, which is the human's call. Same standing rule as pushing (see [git.md](git.md)).

What the body covers is a convention, not an invocation: `.claude/policies/version-control.md` has it.

## Close an issue by merging

The issue closes when the pull request merges, and nothing before that asserts it did. These are message text, not invocations — there is no `gh` command that does this.

| Where | Form | Effect |
| --- | --- | --- |
| the commit message | `Refs #42` | links, closes nothing |
| the pull request body | `Closes #42` | closes on merge |

`close`/`closes`/`closed`, `fix`/`fixes`/`fixed`, and `resolve`/`resolves`/`resolved` all close; `Refs` is not among them, which is why it is the safe form for a commit.

Two constraints, both easy to get wrong:

- **The keyword only fires against the repository's default branch.** In a PR body targeting any other branch it is ignored entirely — no link, no closure on merge.
- **A closing keyword in a *commit* message still closes the issue** once that commit reaches the default branch, and it does so without listing the PR as linked. That is why the commit carries `Refs` — a cherry-pick or a rebase onto the default branch would otherwise close an issue nobody merged.

Docs: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue
