---
owner: repository
title: 'test(verify): the sweep records what each assertion survives'
status: resolved
blocked-by: [01]
part-of: probe
---

## Problem

Nobody knows which of the eleven hundred assertions would still pass if what they
claim stopped being true. Three categories are suspected — a loop that can skip
every candidate, a path test that never reads the file, a pin on a sentence's
phrasing rather than on its subject — and within each of them the sound
assertions are indistinguishable from the vacuous ones by reading.

Reading is also the one method ruled out. Thirteen thousand lines of judgement on
the only file guarding this build produces opinion, and opinion is what the
suspected defects are already made of.

The prototype that established the method also established that one perturbation
is not enough: blanking a file cannot test a claim that the file exists, and
cannot test a claim that no file says something — the second passes trivially,
which reads as success.

## Outcome

A record exists saying, for every assertion, which perturbations it survived and
whether surviving makes it vacuous. Someone who did not run the sweep can read it
and act on it, and can re-run any single row to check it.

Three perturbations, because the suite makes three kinds of claim: a file is
blanked to test what it says, deleted to test that it exists, and the forbidden
thing is injected to test a guard against its absence. The last is the fire-check
the repository already requires of a single guard, run over all of them.

The harness is throwaway and does not survive the ticket. The record does.

## Acceptance

- The sweep reproduces a clean baseline on its copy before perturbing anything;
  a copy that fails on its own is rejected rather than reported as findings.
- Every assertion is attributed to the perturbations it survived, including the
  ones whose names are generated inside a loop.
- Each of the three perturbations is applied: blanked, deleted, and injected.
- The record distinguishes an assertion that survived because it is vacuous from
  one that survived because the perturbation did not touch its subject.
- The record is evidence, carries its declared fields, and appears in the
  evidence index by regeneration rather than by hand.
- The harness is gone from the tree when the ticket closes, and the record says
  what it was and what it proved.
- The repository under test is not modified by the sweep, and this is
  demonstrated rather than intended.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.

## Comments

**The sweep proved 908 assertions sound and none vacuous.** That is the result,
not a failure to find one. Every assertion that survived every perturbation
survived for a reason the record names, and in each case the reason is that the
perturbation never reached what the assertion reads.

**The count went 317, 36, 24, 16, 13, 10, 0 — every revision downward, and every
one came from reading a specific assertion rather than a total.** No total was
ever right and each looked plausible. Two more polarities surfaced that way: a
claim universal over the tree's membership fails only when a member is *added*,
and a guard reading frontmatter cannot be reached by an injection appended to the
end of a file. Both were mistaken for vacuity until checked by hand.

**So the method confirms and cannot deny.** A failure under perturbation is proof
an assertion is attached to something. A survival is only ever evidence about the
perturbations somebody thought to run, which is a smaller set than the things an
assertion can be attached to.

**The workspace is a copy, not a worktree.** A worktree fails its own baseline
three ways: the gitignored Position files are absent from a fresh checkout, the
stacking config is not visible through a worktree's `.git` file, and one section
shells out to `git worktree list`. A full copy including `.git` is byte-identical
to the tree it came from and baselines clean, at 18 MB and 0.4 seconds.

**The injection perturbation was rebuilt three times**, and each wrong version
produced output that read as a result. Arbitrary strings fired nothing, which is
indistinguishable from every guard being vacuous. Synthesising a match per regex
covered a third of them, and a synthesised string that fails to match reads
exactly like a guard that held. Injecting into chosen files left every guard
whose scan scope excluded them untested and looking sound. The final pass injects
into every shipped file and protocol surface at once, so nothing is out of scope.
All three were caught by checking whether individual injections fired their
intended guard; none by looking at the totals, which looked reasonable each time.

**A fourth polarity exists and this ticket does not cover it.** Five assertions
claim a path does *not* exist. Blanking and deleting leave an absent thing absent,
and injecting adds text to a file rather than a file. Only creation would test
one. They are classified as unreachable rather than vacuous, and the perturbation
was not built: adding one is a design change, not a build decision.

**One assertion cannot be injected at all** — its forbidden pattern is built at
run time from a loop variable, so no static string exists. Reported as untested
rather than counted either way.
