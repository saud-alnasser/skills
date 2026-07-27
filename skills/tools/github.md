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

## Link a blocking relationship

`gh` has no native blocking or sub-issue subcommand. Two options, in order of preference:

1. **State the edge in the body.** "Blocked by #12, #14." Legible to humans, no API surface, and it is what the local-file tracker does anyway.
2. **Use the sub-issues REST API through `gh api`**, when a real parent/child link is wanted:

```
gh api repos/{owner}/{repo}/issues/<number>/sub_issues --help
```

Fetch https://docs.github.com/en/rest/issues/sub-issues before using it — the endpoint's payload shape is not stable knowledge, and this is exactly the case the reference exists to stop you guessing.

## Open a pull request

```
gh pr create --title "<conventional title>" --body-file - --base main
```

Tenure does not open PRs unasked — creating one publishes work, which is the human's call. Same standing rule as pushing (see [git.md](git.md)).

What the body covers is a convention, not an invocation: `CLAUDE.md` has it.
