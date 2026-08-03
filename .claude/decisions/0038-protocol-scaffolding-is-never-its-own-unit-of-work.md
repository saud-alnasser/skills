# Protocol scaffolding is never its own unit of work

The second field run left a shared tracker whose top level was mostly the workflow's own bookkeeping: build tickets existing solely to write files under `.claude/`, beside a drift report filed as an issue. The branch-bound test (ADR 0035) separates decisions from work but cannot tell product work from scaffolding — any `docs:` commit produces a branch and passes. We decided: no tracker item and no pull request the workflow creates has its entire effect under the protocol directory, with exactly one exception — the **design PR**, one per design run, whose entire diff is protocol-only and whose approval is approval of the plan. Everything else rides its consumer: evidence gating a map decision lands in that session's design PR, evidence gating a build is a declared increment (ADR 0037) shipping with the code it unblocked. The rule binds workflow-created items on shared trackers, reads the diff and never the commit type, and is vacuous on a local-markdown tracker.

## Considered Options

- **Design output riding the first build PR** — rejected: weeks of plan mixed into one implementation diff, the unreviewable mix the rule exists to kill, and knowledge stranded off the default branch until a build happens.
- **One long-lived design branch per map effort** — rejected: resolved decisions invisible on the default branch for the life of the effort, and every session needs the branch fetched before it can continue. One small design PR per session lands knowledge between sessions instead.
- **Binding the `docs:` commit type** — rejected: the type also carries real documentation; the diff is the fact, the type a label.

## Consequences

Amends the specification's multi-agent bounding (§20) in the same change, per ADR 0029. A repository's existing protocol-only issues are that repository's cleanup, on its own design run.
