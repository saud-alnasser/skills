---
status: implemented
sources:
  - scripts/verify.ps1
  - .claude/tools/verify.md
  - .claude/rules/skills.md
  - .claude/evidence/prototypes/2026-08-09-one-perturbation-cannot-test-three-assertion-polarities.md
---

# refactor(verify): every assertion is proved to fail when what it claims stops being true

## Problem

`scripts/verify.ps1` is the only thing that catches a broken build here. There is no compiler and no package manifest; 1123 assertions over the shipped tree are the whole net.

Nobody has ever checked that the net has no holes in it, and three measurements say it does.

**132 assertions cannot explain themselves.** They return a bare boolean instead of throwing, so when one fails the summary names the assertion and stops. The tool guide forbids this outright and the count says the prohibition is unenforced.

**51 calls to throwing helpers sit outside any `Assert` condition**, where nothing catches them. One missing file or one renamed heading aborts the entire run — no summary, no failure list, no report of the other 1122 assertions. On the one guard against a broken build, the failure mode is silence.

**An unknown number of assertions pass regardless of what they claim.** 44 iterate with a `continue` that can skip every candidate and leave the assertion green; 10 check that a path exists and never read it; 285 pin a literal string of prose, which passes for as long as nobody rewords the sentence and stops meaning anything the moment somebody does. The recurring failure the skills rule already names — a guard anchored to phrasing that travels *with* the thing it checks rather than to the thing itself — has been hand-corrected ten times in one recent session. Nothing distinguishes the sound assertions in these categories from the vacuous ones, and reading 13,336 lines to find out is the cost that has kept anyone from trying.

## Goal

Every assertion in the suite has been shown to fail when what it claims stops being true, and the two categories that can silently regrow are guarded by the suite itself.

## Constraints

- **There is no second net.** Deleting a guard that turns out to be load-bearing is caught by nothing. Every removal is justified by a run that shows the assertion passing while its subject is gone, not by reading it and judging.
- **Comment density is not bloat.** 27% of the file is comments, and they carry the reasoning the assertions cannot. They are not a reduction target.
- **The four duplicate assertion names are not a defect** and are not to be hunted for.
- **A new guard is trusted only after it is fire-checked** — written, confirmed to fail against a deliberate reintroduction, then restored. The skills rule carries this and it applies to every guard this effort adds.
- **The suite must stay green at every point.** Each ticket leaves `pwsh -NoProfile -File scripts/verify.ps1` passing.

## Architecture

**An assertion is tested by perturbing what it claims and watching it fail.** That is the fire-check the repository already requires for a single guard, and the whole of this effort is that move applied to all 1123.

The prototype established that the suite asserts three different kinds of claim, and that one perturbation cannot reach them:

| The assertion claims | Perturbation | Vacuous if |
| --- | --- | --- |
| this file *says* X | blank the file | still passes |
| this file *exists* | delete the file | still passes |
| *no* file says X | inject X | still passes |

Blanking alone was the original proposal. Against a fully blanked shipped tree 317 assertions still passed, and almost none of them were defects: a presence check passes because blanking is not deleting, and an absence guard passes because there is nothing forbidden present when there is nothing present. The second failure is the dangerous one — it reads as success.

**The sweep is a measurement, not a tool.** Its harness is throwaway code and goes where throwaway prototype code goes; its output is an evidence file and is kept. A permanent detector was considered and rejected below.

**What can regrow statically is guarded statically.** Two of the categories are decidable by reading the script rather than by running it: an assertion with no `throw`, and a throwing helper called outside an `Assert` condition. Those become assertions inside the suite, over the suite. Vacuity itself is not statically decidable and gets no guard — only a perturbation run can prove it, which is why the sweep is a measurement someone repeats rather than a check that runs.

## Approach

**Resilience first, because the sweep cannot run without it.** This is not tidiness ordering: the prototype's first run produced no result at all, and the fix had to be applied to a scratch copy before any measurement was possible. It is also worth landing on its own terms — today one malformed file hides the state of the whole build.

**The unambiguous defect runs in parallel with it.** The 132 silent assertions need no measurement to justify: the tool guide already forbids them. That work gates nothing and is gated by nothing.

**Then the sweep, then the repairs it proves.** The sweep produces a per-assertion record of which perturbation it survived. Only what the sweep proves gets repaired — the 285 prose pins are not a defect list, and treating them as one is the 13,336-line judgement pass this method exists to replace. The `continue` and bare-path-test categories need no separate treatment: they are exactly what blanking and deletion detect.

### Considered and rejected

**A permanent detector under the protocol scripts.** It would keep vacuity guarded rather than merely measured. Rejected because it hard-codes the suite's internals — the assertion helper, the section helper, the throwing helpers — so any refactor of the suite silently breaks it, and a detector that has rotted unrun reads as coverage that is not there. The sweep is genuinely a one-off measurement; what can regrow is guarded statically instead.

**Blanking alone, then triaging what survives by hand.** The cheapest path, and the one the prototype falsified: it emits 317 rows of which the great majority are the perturbation missing its target, and hand-triage of that list is the read the method was designed to avoid.

**A systematic re-anchoring pass over all 285 prose pins.** Rejected as opinion at scale on the one file with no second net.

**A fan-out over the repair ticket, one portion per perturbation category.** Refused rather than reordered: all three portions would write `scripts/verify.ps1`, and overlapping file ownership is not a fan-out.

**Treating the sweep as a declared increment on the repair ticket** rather than a ticket of its own. Rejected because the sweep is about an hour of unattended compute plus a harness, it produces a durable evidence file that is useful whether or not the repairs follow, and burying it inside the repair ticket makes that ticket unschedulable. The rule that would forbid a ticket whose whole effect sits under the protocol directory binds shared trackers, and this one is local.

## Acceptance criteria

- A malformed or missing file produces one reported failure naming its section, and the run still reports every other assertion and exits through the summary.
- No assertion in the suite fails without stating what was wrong.
- The suite fails when an assertion with no explanation is added, and when a throwing helper is called where nothing catches it.
- Every guard this effort adds has been confirmed to fail against a deliberate reintroduction and then restored.
- An evidence record states, for every assertion, which perturbation it survived and whether that makes it vacuous.
- No assertion remains that passes while what it claims is absent.
- The comment density and the four duplicate assertion names are unchanged.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Risks

- **A removed assertion was load-bearing in a way the perturbation did not model.** Most likely where an assertion's real subject is not the file the sweep perturbed. Detected by requiring a run that shows the pass, and by removing nothing on judgement alone; bounded by the fact that every removal is a diff a reviewer can re-run.
- **A new guard is self-matching** — it finds its own literal in the script and passes forever. This has happened here before. Detected only by the fire-check, which is why the fire-check is an acceptance criterion rather than a habit.
- **The repair ticket is oversized**, because its scope is unknown until the sweep runs. Detected the moment the sweep's output exists, which is before that ticket starts; the remedy is to re-plan it into batches rather than to press on.
- **The sweep's copy is unfaithful** and reports failures that are artefacts of the copy rather than of the perturbation. This happened in the prototype — 14 of them, from a missing git directory. Detected by requiring the copy to reproduce a clean baseline before any perturbation is applied.
- **A perturbation cannot attribute a loop-generated assertion** back to its call site, leaving 61 unaccounted for. Detected during the sweep; the remedy is to record the site as the run proceeds rather than to match names afterwards.

## Out of scope

- **The 285 prose pins as a category.** Only those the sweep proves vacuous are touched.
- **Comment reduction.** The comments are the reasoning.
- **The four duplicate assertion names.**
- **Any change to what the suite asserts *about*.** This effort changes whether assertions work, never which acceptance criteria the repository holds itself to.
- **A permanent vacuity detector.**
