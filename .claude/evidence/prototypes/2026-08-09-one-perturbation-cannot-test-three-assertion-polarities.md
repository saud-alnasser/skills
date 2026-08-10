---
owner: repository
kind: prototypes
falsifies: []
---

# One perturbation cannot test three assertion polarities

Built 2026-08-09 against `0399053`, on a scratch copy of the tree. The harness was throwaway and is gone; this is what it proved.

## The question

`scripts/verify.ps1` holds 878 `Assert` call sites over 13,336 lines, expanding to 1123 assertions at run time. A design run wanted to know which of them check nothing, without reading the file.

The method proposed was **mechanical vacuity detection**: blank each shipped file in a scratch copy, run the suite against that copy, and record which assertions still pass. An assertion that survives its subject being deleted is provably checking nothing. It generalises the fire-check that is already required for a single guard, and it produces evidence rather than opinion.

The question was whether that works. It does not, for two independent reasons, and both were found by running it rather than by reasoning about it.

## What was built

A scratch copy of the shipped tree, the protocol directory, the scripts, and the root files. All 57 markdown files under `skills/` overwritten with the empty string — the files still present, their content gone. Then the suite, run against the copy.

## Finding one: the suite aborts rather than reporting

The first run produced no result at all. Not failures — a stack trace, no summary, no exit through the reporting path:

```
Line |
 177 |  … f (-not $m.Success) { throw "no section matching '$HeadingPattern'" }
     | no section matching 'A shared tracker never carries protocol-only work'
```

`Assert` catches exceptions from its own condition block and turns them into failures carrying the exception message. Nothing catches a throw from anywhere else. `Describe-Ticket` invokes its body unguarded, and **51 calls to throwing helpers sit outside any `Assert` condition** — 42 to the one that throws when a file is missing, 9 to the one that throws when a section is missing.

So one malformed file takes the whole suite with it. The state of the other 1122 assertions is not reported as unknown; it is not reported at all. On the only guard this repository has against a broken build, an absence is the one thing nobody notices.

This is a live defect independent of the question that surfaced it. It was reproduced by blanking a single file, not only by blanking all of them.

## Finding two: blanking answers only one of three questions

With the abort patched in the scratch copy — `Describe-Ticket` catching and recording a section-level failure — the suite completed against the fully blanked tree. **317 of 1123 assertions still passed.**

That number is not the vacuity count. It decomposes:

| Survivors | Why | Vacuous? |
| --- | --- | --- |
| 120 | read neither tree | no — the perturbation missed them |
| 74 | subject is the protocol directory, not the shipped tree | no — the perturbation missed them |
| 61 | generated inside a loop, name not statically matchable | unknown |
| 62 | read the shipped tree and passed anyway | mixed |

Even the last row is mostly not defects, and the two reasons are the finding:

- *"/design ships as a skill"* survived because **blanking is not deleting**. The file still exists, so a presence check passes. Blanking cannot test a presence claim.
- *"no triage role leaks into a build ticket's Status:"* survived because **an absence guard passes trivially on an empty tree**. There is nothing forbidden present when there is nothing present. Blanking cannot test an absence claim, and it fails in the direction that reads as success.

The suite asserts three different kinds of claim, and each needs its own perturbation:

| The assertion claims | Perturbation that tests it | Vacuous if |
| --- | --- | --- |
| this file *says* X | blank the file | still passes |
| this file *exists* | delete the file | still passes |
| *no* file says X | inject X | still passes |

The third row is the fire-check the repository already requires for a single guard. The generalisation the method was reaching for is real; it generalises to three detectors rather than one.

Run as originally proposed, the detector emits a 317-line list that is mostly false positives, and triaging it by hand is the 13,336-line read the method existed to avoid.

## Cost

One full suite run is **15.2 seconds**. Per-file blanking and per-file deletion are 57 runs each; injection is one run per guard. The three-perturbation sweep is roughly 170 runs — about an hour of wall clock, unattended.

## Static counts taken alongside

Measured by parsing the script with the PowerShell AST rather than by grep, so a multi-line condition counts once:

| Signal | Count |
| --- | --- |
| `Assert` call sites | 878 |
| assertions at run time | 1123 |
| fail with no `throw`, so with no explanation | 132 |
| contain `continue`, so a loop can skip everything | 44 |
| pin a literal over 55 characters of prose | 285 |
| check presence with a bare path test only | 10 |
| duplicate assertion names | 4 names over 8 sites |
| throwing-helper calls outside an `Assert` condition | 51 |

The prose-pin figure is the one worth flagging: a prior count put it at 524. Counting call sites rather than occurrences gives 285.

## What stayed open

**The scratch copy was not faithful.** It produced 14 failures before anything was blanked, because it carried no `.git` and one section shells out to `git worktree list --porcelain`. The composition above is unaffected — those 14 are identifiable and none is in the surviving set — but a real sweep needs a copy that includes the repository's own git directory.

**Whether the 61 loop-generated survivors are attributable at all** was not established. Their names are built at run time, so nothing statically matches them back to a call site. A sweep that wants to name them has to record the site as it runs rather than parse for it afterwards.
