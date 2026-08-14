---
owner: repository
title: "feat(delivery): the boot tier is pushed and the store answers on two faces"
status: resolved
blocked-by: [18, 26]
part-of: substrate
---

## Problem

Everything a stage needs currently arrives the same way — as files loaded whole — so there
is no distinction between what must arrive before any protocol logic runs and what can be
fetched when it is wanted. That collapse is why the corpus is paid for in full on every
turn.

It also leaves the framework with no answer when the store cannot be reached. A stage that
depends on retrieval and gets nothing has no degraded mode to fall back into; it simply
does the wrong thing quietly.

## Outcome

The boot tier is delivered by harness push — the channel that survives compaction and
cannot fail silently — and holds only what must fire on a turn nobody started. Everything
else is reached through the store, which answers on two faces: a tool for the model and a
command line for the fallback. With the store unreachable a stage still starts, says that
it is degraded, and rebuilds what it can rather than proceeding as though nothing is wrong.

The path-scoped tier survives as a pointer only.

## Acceptance

- A stage starts and follows the boot tier with the store stopped, and says in its opening
  report that it is running degraded.
- The same norm is retrievable through both faces and the two answers agree.
- The boot tier's size is reported by the build, and a norm added to it is visible in that
  figure.
- A norm that must fire on a turn the user did not start is served by push, and moving it
  behind the store fails the build.
- A path-scoped norm is reached by pointer, and no path-scoped content sits in the pushed
  tier.
- With the store reachable, a stage's startup cost is no greater than it is today.

## Declared increments

- after the boot tier is delivered by the framework rather than by hand: what disabling
  inline shell execution does to a stage that depends on it, and whether the failure is
  loud — type: prototype
- after the store's tool face answers its first call: whether a tool-call hook's result on
  prompt submission reaches the model's context, or fires and is discarded — type: prototype

## Comments

**Neither declared increment was reached, and under the corrected ordering neither can be
reached from this ticket.** Both steps name a moment that now belongs to conversion: the boot
tier is *delivered by the framework* when `/configure` installs it, and the store's tool face
*answers its first call* only once the migration has derived it. This ticket specifies both in
what ships. The two questions are unanswered and stay declared; the ticket that can reach them
is `24`. Recorded rather than moved — only design writes an increment.

**One acceptance criterion is not met, and the figure is recorded here so nobody meets it by
surprise.** *"With the store reachable, a stage's startup cost is no greater than it is
today"* — the entrypoint template grew **959 characters** to carry the store's two new members
(how to reach it, and what to do when it cannot be reached). Measured against this repository's
boot tier of 9,441 characters and its 9,450 ceiling, conversion will breach that ceiling by
roughly 950 unless the tier loses more than it gained.

It is expected to: 2.0 replaces pushed prose with a store the stage queries, so the credit
lands in `23` and `24` while the debit lands here. That is a claim rather than a measurement,
which is precisely why the debit is written down. **The instrument for settling it is this
ticket's own** — the build now reports the boot tier's size as a figure of its own, so whoever
converts this repository can read the net rather than argue it. The criterion is checkable at
conversion and is not checkable before it.

The other five criteria are met at specification level, on the same terms as `18`, `21` and
`22`: the behaviour is specified in what ships and its fixtures are stated rather than run,
because nothing here can run them until `/configure` derives the scripts.
