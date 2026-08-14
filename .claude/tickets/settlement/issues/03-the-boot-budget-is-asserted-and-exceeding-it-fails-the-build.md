---
owner: repository
title: "feat(verify): the boot budget is asserted, and exceeding it fails the build"
status: resolved
blocked-by: [02]
part-of: settlement
---

## Problem

The canonical specification says the boot budget is asserted rather than
estimated, that exceeding it fails the build, and that it is reported as a figure
of its own — because the tier is paid on every turn where a row is paid once. The
scripts page files the same figure under what the builder reports and never fails
on, and the builder implements that: it measures the tier and thresholds nothing.

No budget exists to assert. The specification requires the check and no document
names the number, so the requirement has never been implementable in either
direction.

## Outcome

The boot tier is measured against a stated budget. A store whose tier exceeds it
fails the build, naming the figure and the budget; one under it reports the figure
and exits zero, so the margin is visible on every run rather than only at the
crossing. The budget carries its basis in words — the measurement it was set from
and the headroom allowed — so that a later crossing can be told apart from a bound
that was set too tight to begin with.

The other two figures are unchanged and stay unthresholded, and the pages say why
the treatments differ: the boot tier is entirely authored prose that should not
grow, where the corpus's instruction count and a row's total mix content that must
grow with content that must not, and a threshold over a mixed figure cannot tell
regression from accumulation.

## Acceptance

- A store whose boot tier exceeds the budget fails the build, and the failure
  names both the measured figure and the budget.
- A store whose boot tier is under the budget reports the figure and exits zero.
- The reported figure counts the entrypoint and every unconditionally loaded rule,
  and excludes a rule that declares a path scope.
- Adding a path-scoped rule does not move the figure; adding an unconditional one
  does.
- The corpus's instruction count and each row's authored and generated sizes are
  still reported and still fail on nothing.
- The budget's basis is stated where the budget is, and no figure is committed as
  a baseline.
- The canonical specification and the scripts page agree on which figures fail the
  build and which do not, and the build asserts that they agree.
- Every assertion added is confirmed to fail against a deliberate reintroduction
  of the fault it names, with the reintroduction taken from the violation rather
  than from the implementation.
