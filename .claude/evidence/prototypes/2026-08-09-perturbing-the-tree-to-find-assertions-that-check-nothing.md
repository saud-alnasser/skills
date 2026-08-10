---
owner: repository
kind: prototypes
falsifies: []
---

# Perturbing the tree to find assertions that check nothing

Built 2026-08-09 against `b98835c`, on full copies of the repository. The harness was throwaway and is gone; this is what it recorded.

Supersedes nothing. It is the sweep that [the polarity finding](2026-08-09-one-perturbation-cannot-test-three-assertion-polarities.md) argued for, and it revised that finding's method twice more before producing a number.

## The question

`scripts/verify.ps1` holds 1127 assertions over the shipped tree, and it is the only thing that catches a broken build here. Which of them would still pass if what they claim stopped being true?

Reading 13,336 lines and judging was the one method ruled out: the suspected defects are themselves judgements, and a second pass of judgement over them produces opinion about opinion.

## What was built

A copy of the repository per run, a perturbation applied to the copy, and the suite run against it. An assertion that still passes when what it claims is gone is checking nothing.

**Copies rather than git worktrees.** A worktree failed its baseline three ways: the gitignored Position files are absent from a fresh checkout, `.git/.graphite_repo_config` is not visible through a worktree's `.git` file, and one section shells out to `git worktree list`. A full copy including `.git` is byte-identical to the tree it came from, costs 18 MB and 0.4 seconds, and reproduces the clean baseline exactly. **A copy that does not baseline clean is rejected rather than reported as findings** — the earlier prototype's copy produced 14 failures that were artefacts of the copy, and any of them could have been written up as a defect.

**`Assert` was instrumented in each copy** to print the line it was called from. Without it the 61 assertions whose names are built inside loops cannot be told apart, and the earlier prototype had left that open. With it every assertion is attributed to one call site, and the eight `$legacy` assertions — one call site, eight runtime assertions — are individually accounted for.

**The repository under test was never modified.** Demonstrated rather than intended: the working tree reported zero changes after every run.

## What the method got wrong, three times

Each of these produced output that read as a result, and each is the same defect the sweep exists to find, committed by the sweep itself.

**The forbidden strings were arbitrary.** The first injection set was scraped out of the script by pattern and yielded things like `metadata`, `model`, and a file path. Nothing forbids those, so nothing fired, and a run where nothing fires is indistinguishable from a run where every guard is vacuous. The real forbidden sets are two tables — the retired paths no shipped file may name, and the rules required to have exactly one home.

**Synthesising a match refused two thirds of them.** Generating a string per regex handled 28 of 90; anything with an alternation or a character class has no single literal. A synthesised string that fails to match reads exactly like a guard that held. Replaced by extraction: every one of those rules is stated in its home file, so the string that trips its guard is text already in the tree. That reached 90 of 90 — and established in passing that no guard in the suite is guarding a rule that no file states.

**The injection went to the wrong files.** A guard scans a scope. One reads only `skills/prototype/`; the legacy sweep reads every shipped file; others read one named file. Injecting into a chosen few leaves a guard whose scope excludes them seeing nothing — *not tested*, wearing the costume of *not vacuous*. Fixed by removing the choice: the final pass injects into every shipped file and every protocol surface at once, so nothing can be out of scope. Other assertions break in the process, which is fine, because only the set that still passes is read.

The third one is worth stating plainly: **all three were caught by checking whether individual injections fired their intended guard, and none by looking at the totals.** The totals looked reasonable every time.

## Results

470 runs against 1127 assertions: 57 shipped files blanked and deleted one at a time, the whole tree blanked and deleted, and 354 injections of things the suite forbids.

| Assertions | |
| --- | --- |
| **908** | **proven sound** — at least one perturbation reached the assertion and it failed |
| 219 | not reached by any perturbation built here |
| **0** | **proven vacuous** |

**Nothing was proven vacuous, and that is the result rather than a failure to find one.** Every assertion that survived everything survived for a reason the sweep can name, and in each case the reason is that the perturbation never reached what the assertion reads.

| Why 219 were not reached | |
| --- | --- |
| the subject is the protocol directory, not the shipped tree | 99 |
| the assertion reads neither tree | 105 |
| the claim is that a path does **not** exist — only creation tests that | 5 |
| the claim is universal over the tree's membership — only **adding** a member tests it | some of the last 10 |
| the guard reads frontmatter, and injections append to the end of the file | some of the last 10 |
| no matching string could be generated from the pattern | 4 |

The last ten were individually examined rather than counted, because a number here would have been the thing this record exists not to produce. Two were checked by hand and both are sound:

- *"every skill in the tree belongs to exactly one named category"* enumerates the skill directories that exist and requires each to be named in Context. Delete every skill and the set is empty, so the claim holds vacuously — but adding an uncategorised skill fails it immediately. Its failure mode is **addition**, and nothing here adds.
- *"no skill's metadata is a scalar"* reads frontmatter, which is anchored to the start of the file. Every injection appended to the end, so none could ever reach it. Re-run with the same string placed inside the frontmatter, it fails on the first try.

**So the honest reading is that this sweep establishes soundness and cannot establish vacuity.** A perturbation shows an assertion is attached to something. Nothing here can show an assertion is attached to nothing, because "survived every perturbation I thought to run" and "checks nothing" are different statements, and only the first is evidence.

## What this sweep cannot reach, stated rather than omitted

**A claim that a path does not exist.** Five assertions claim a file or directory is absent. Blanking and deleting leave an absent thing absent; injecting adds text to a file rather than adding a file. Only creation would test one, and that is a fourth polarity the three-row table does not have. They are classified as unreachable, never as vacuous.

That table is therefore incomplete as written:

| The assertion claims | Perturbation that tests it |
| --- | --- |
| this file *says* x | blank the file |
| this file *exists* | delete the file |
| *no* file says x | inject x |
| *no* file exists at p | **create p** — not run here |

**One assertion cannot be injected at all.** Its forbidden pattern is built at run time from a loop variable, so no static string exists to inject. Untested, and counted as neither sound nor vacuous.

**An assertion whose subject is the protocol directory** is untouched by perturbing the shipped tree. Those are reported as unreachable with the reason attached, not folded into either result — conflating them is what made the earlier prototype's raw figure of 317 survivors meaningless.

**Sensitivity is not correctness.** An assertion that fails when its subject is perturbed is attached to something; that it is attached to the *right* thing is not something any perturbation can show. This sweep finds assertions that check nothing. It does not find assertions that check the wrong thing, and a pin anchored to incidental phrasing will pass this sweep while still failing the moment somebody rewords a sentence.

## A fifth polarity, and why the count kept moving

The three-perturbation table was wrong twice more, in the same direction each time. Every correction came from examining an individual assertion, and every one moved assertions **out** of the vacuous column:

| Perturbation | Falsifies | Missing at the time |
| --- | --- | --- |
| blank one file | this file says x | — |
| delete one file | this file exists | — |
| inject x | no file says x | — |
| blank/delete the **whole tree** | claims the tree satisfies redundantly | a floor of ten against twenty-one files; "at least one file names this" |
| **create** a path | this path does not exist | five assertions |
| **add** a member | every member of the tree satisfies p | at least one assertion |

Injection also has a **position**, not just a string. A guard reading frontmatter cannot be reached by appending to the end of a file, and a guard scanning one subtree cannot be reached by writing to another. Both were mistaken for vacuity before being checked.

## What this says about the method

The count went 317, then 36, then 24, then 16, then 13, then 10, then 0. **Every single revision was downward, and every one came from looking at a specific assertion rather than at a total.** No total was ever right, and each looked plausible.

That is the finding worth keeping. A perturbation sweep is sound as a way to *confirm* an assertion is attached to something: a failure is proof. It is unsound as a way to *deny* it, because a survivor is only ever evidence about the perturbations someone thought to run — and the space of things an assertion can be attached to is larger than the space of perturbations, in a way that is invisible until each survivor is read.

The same shape appeared four times in the harness itself: a filter that returned zero because it used the wrong operator names, a text search that returned zero because its parentheses were unbalanced, a generator that silently dropped patterns, and an injection set built from strings nothing forbids. Each produced a confident empty answer. **A tool that reports "nothing found" is making the same claim as a guard that passes, and deserves the same suspicion.**

## What stayed open

**No repair list was produced, because there is nothing on it.** The consuming work assumed this record would hand over a set of assertions to fix; the set is empty, and the reason it is empty is not that the suite is clean but that this method cannot decide the question for the 219 it did not reach.

Deciding them needs perturbations that were not built — creation, member addition, and injection placed where each guard actually reads — and building those is a design question, not a repair.
