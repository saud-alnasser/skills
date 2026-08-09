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
pwsh -NoProfile -File scripts/verify.ps1 -Ticket tenure/09
```

**`<effort>/NN`, and both halves are literal.** Ticket numbers restart at `01` in each effort, so the effort is part of the id rather than context you carry in your head. `-Ticket 09` matches nothing, and neither does `-Ticket tenure/9`. A miss does not fall back to running everything: it runs nothing, prints every declared id, and exits `2`. That exit code exists specifically so a zero-assertion run cannot read as a pass.

The printed list is built from the ids the run itself declares, so it cannot advertise a ticket that has no section — which is what the hand-kept list it replaced had started doing.

Not every ticket appears in it. `tenure/11` and `tenure/12` have files but no section, because neither landed anything under `./skills` — 11 installed the plugin on this machine, 12 migrated `.claude/`.

## Exit codes

| Code | Meaning |
| --- | --- |
| `0` | every assertion passed |
| `1` | at least one failed; the failures are listed under the summary |
| `2` | `-Ticket` matched nothing — no assertion ran |

Treat `2` as a typo in the invocation, never as a result about the tree.

## Adding an assertion

Assertions live inside `Describe-Ticket` blocks keyed by the `<effort>/NN` id. `.claude/rules/skills.md` carries the obligation to add one; the thing worth knowing here is that `Assert` swallows exceptions and turns them into failures with the exception message as detail — so `throw "what was wrong"` is how an assertion explains itself, and a bare `$false` return produces a failure with no explanation.

## Where a throw lands

Both are caught, at different scopes, and the difference is what a failure costs:

| Thrown | Caught by | Costs |
| --- | --- | --- |
| inside an `Assert` condition | that assertion | one failure; the section carries on |
| anywhere else in a section | `Describe-Ticket` | one failure, and **the section's remaining assertions do not run** |

The second case is not rare and is not a mistake. A section reads its file once, above the assertions that share it, and that hoisted read throws when the file is missing — so perturbing the tree, renaming a heading, or deleting a file lands there rather than in a condition.

It used to end the whole run: no summary, no failure list, no report of anything that had already passed. A section-scoped catch is what makes an absent file readable as one failure naming its section, and the summary line says the section aborted so it cannot be mistaken for a single assertion going red.

**Prefer the first scope where the choice is real.** An assertion that reads its own file reports only itself when that file is gone; one that leans on a hoisted read takes its siblings down with it. Hoisting is still right when several assertions share one file — the cost is bounded, and re-reading per assertion buys nothing.

**`./skills` is the tree this asserts against, and `.claude/` appears two ways.** Reading it as *evidence* is ordinary — several sections check that a rule is written down here, or that a rename left no trace. Reading it as the *subject* is the exception, and only the tickets that rebuild this tree do it: `layout/02`, `layout/04`, `layout/06`, and `streamline/01`, each marked by a comment above its block and enumerated in `$subjectSections`. The two are checked against each other, so a fifth cannot appear unlisted. That marking is the point. The boundary between what ships and what this repository runs on is one this script partly exists to hold, so a section that crosses it says why.
