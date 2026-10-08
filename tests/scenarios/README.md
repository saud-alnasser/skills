# Scenario suite

Twelve short prompts, each run by an agent against a throwaway repository
with AEP installed, and judged by what the repository looks like afterwards.
The rule ledgers prove the text of a rewrite survived; these prove the behaviour
did.

Nothing here ships. It runs from a checkout of this repository.

| # | Scenario | Expected |
| --- | --- | --- |
| S1 | typo fix | quick lane, one commit, no issue, PR, ticket or question |
| S2 | feature with 3 independent tickets, lane full | one wave of 3 children, each in its own worktree; orchestrator integrates one at a time |
| S3 | resume after the session dies mid-wave | re-enters the same worktree, re-verifies nothing already ticked |
| S4 | the effort's worktree is dirty on start | stops and lists the paths; builds nothing |
| S5 | a ticket contradicts `spec.md` | trip-wire 3: stops, builds nothing |
| S6 | converge finds unbuilt work | appends tickets, runs round two, never edits the spec |
| S7 | the change touches a public API | trip-wire 2: stops before building |
| S8 | a quick-lane change turns out to cross a contract | raises to standard, says so, continues |
| S9 | a UI change with an open visual question | UI prototype variants before the plan, on a throwaway branch |
| S10 | full-lane run with a handoff and two children | nothing written outside the project; `Outside writes: none` |
| S11 | refine on a vague spec | at most 5 questions, one at a time, each with a recommended answer |
| S12 | tracker set to none | zero network calls to a forge; run log in `log.md` |

## Running one

```
node tests/scenarios/run.mjs setup S4 --src src
```

`setup` makes a directory through the OS temp API holding the fixture
repository (`repo/`), the prompt for the agent (`prompt.md`), and what was
true before the run (`state.json`, including a listing of the home folder and
the drive root). `--src` picks which AEP is installed: `src` for the version
being built, or another checkout's `src/` for a baseline.

Give an agent the prompt, in a fresh context:

```
Read <harness>/prompt.md and carry out exactly what it says.
```

There is no human in a run. Every question the protocol would put to one is
appended to `asks.md` with a recommended answer, and the run proceeds on that
recommendation. The agent ends by writing `report.json`.

Then judge it, and remove it:

```
node tests/scenarios/run.mjs check --harness <harness>
node tests/scenarios/run.mjs clean --harness <harness>
```

`check` writes `result.json` beside the fixture. To record a full run:

```
node tests/scenarios/run.mjs summarize <harness>/result.json ... --version 4.0.0 --out tests/scenarios/results/4.0.0.md
```

## How a result is judged

Each check reads one of three things: the fixture's git state (branches,
commits, worktrees, files on a ref), the run's `report.json`, or its `asks.md`.
None reads a transcript, so a run is judged by what it left rather than by what
it said it did. Where a check has to take the report's word, as for
`reverified` or `dispatched`, the check names that field.

`results/` holds one file per version run, so a rewrite is compared against the
version before it rather than against memory.
