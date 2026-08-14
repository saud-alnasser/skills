---
owner: repository
---

# verify — the build

This repository ships markdown, so there is no compiler and no package manifest. `build/verify.js` is the substitute: one assertion per mechanically-checkable acceptance criterion, grouped under the ticket that demanded it. It is the only thing that catches a broken build here.

Written for Node, which the framework already requires — `hooks/hooks.json` invokes its session hook with bare `node`. No docs to fetch: the script's header comment is the reference, and everything below is what the header does not say.

## Run everything

```
node build/verify.js
```

One line per assertion, then a summary. A failing assertion prints every offending path beneath it, never a count — a count says something is wrong and never which one, and which one is the reader's next question.

## Run one ticket — the single-file equivalent

```
node build/verify.js --ticket conversion/01
```

**`<effort>/NN`, and both halves are literal.** Ticket numbers restart at `01` in each effort, so the effort is part of the id rather than context you carry in your head. `--ticket 01` matches nothing, and neither does `--ticket conversion/1`. A miss does not fall back to running everything: it runs nothing, prints every declared group, and exits `2`. That exit code exists specifically so a zero-assertion run cannot read as a pass.

The printed list is built from the groups the run itself declares, so it cannot advertise a ticket that has no assertions.

**Most tickets do not appear in it, and that is a gap rather than a property.** The suite this replaced covered efforts back to the first, and was deleted rather than ported; coverage is being rebuilt one ticket at a time, by the obligation in `.claude/rules/skills.md` that every change to what ships moves this file in the same pass. A missing group means nobody has written those assertions yet — never that the ticket had nothing to assert.

## Exit codes

| Code | Meaning |
| --- | --- |
| `0` | every assertion passed |
| `1` | at least one failed; each failure lists the paths that caused it |
| `2` | `--ticket` matched nothing — no assertion ran |

Treat `2` as a typo in the invocation, never as a result about the tree.

## Adding an assertion

Assertions live inside `ticket()` blocks keyed by the `<effort>/NN` id. `.claude/rules/skills.md` carries the obligation to add one; what is worth knowing here is the shape.

**An assertion returns the list of offending entries, and an empty list is a pass.** It never returns a boolean — a boolean failure has to be explained separately, and the explanation drifts from the condition. Returning the offenders makes the failure message a consequence of the check rather than a second statement of it.

**A throw inside an assertion is caught and reported as that assertion failing**, with the exception message as the detail, and the remaining assertions still run. There is no wider scope that aborts a group: a missing file takes down the one assertion that read it.

## What it may read

**`skills/`, `agents/`, and `specs.md`.** It never reads `.claude/`. Why that boundary exists is `.claude/rules/skills.md`'s and is not restated here.

**Every filesystem call goes through one resolver**, which resolves the path before judging it and throws on anything inside the protocol directory or outside the repository. That is the mechanism worth knowing when adding an assertion: reach for `read`, `entries`, or `markdownUnder` and the boundary is already held; call `fs` directly and it is not.
