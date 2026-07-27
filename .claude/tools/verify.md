# verify.ps1 — the test runner

This repository ships markdown, so there is no compiler and no package manifest. `scripts/verify.ps1` is the substitute: one assertion per mechanically-checkable acceptance criterion, named after the ticket demanding it. It is the only thing that catches a broken build here.

Written for PowerShell 7 (`pwsh`). No docs to fetch — the script's comment-based help is the reference:

```
pwsh -NoProfile -Command "Get-Help ./scripts/verify.ps1 -Full"
```

Read that when a parameter's behaviour is in doubt. Everything below is the part the help does not tell you.

## Run everything

```
pwsh -NoProfile -File scripts/verify.ps1
```

Several hundred assertions, one line each. Pipe through `Select-Object -Last 20` when only the summary matters — a failure list is reprinted in the summary, so tailing loses nothing.

## Run one ticket — the single-file equivalent

```
pwsh -NoProfile -File scripts/verify.ps1 -Ticket 09
```

**Two digits, always.** `-Ticket 9` matches no ticket. It does not fall back to running everything and it does not run ticket `09`; it runs nothing, prints the known ids, and exits `2`. That exit code exists specifically so a zero-assertion run cannot read as a pass.

Not every number is a ticket. `11` and `12` are `ready-for-human` and have no assertions, so they are absent from the known list even though the ticket files exist.

## Exit codes

| Code | Meaning |
| --- | --- |
| `0` | every assertion passed |
| `1` | at least one failed; the failures are listed under the summary |
| `2` | `-Ticket` matched nothing — no assertion ran |

Treat `2` as a typo in the invocation, never as a result about the tree.

## Adding an assertion

Assertions live inside `Describe-Ticket` blocks keyed by the two-digit id. `.claude/rules/skills.md` carries the obligation to add one; the thing worth knowing here is that `Assert` swallows exceptions and turns them into failures with the exception message as detail — so `throw "what was wrong"` is how an assertion explains itself, and a bare `$false` return produces a failure with no explanation.
