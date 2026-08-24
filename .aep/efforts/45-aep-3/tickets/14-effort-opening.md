---
status: resolved
blocked-by: [06, 07]
---

# feat(specify): an effort opens as one issue, one branch, one pull request

## Outcome

`/specify` resolves its own uncertainty and performs the opening step: it creates the issue, renames the directory to its tracker number, branches, commits the artifacts as a `docs` commit, and opens a draft pull request, asking once for permission to push and for the effort’s priority. Abandoning closes both objects. The tracker section of the execution policy becomes one issue per effort, and the seeded forge reference is corrected to match.

## Acceptance Criteria

- [x] Criterion 1: a one-line bug fix and a fifteen-ticket feature both produce one issue, one branch, and one pull request, and the bug fix has no plan.
- [x] Criterion 2: the directory exists as `xxxx-<slug>` before the issue and as `<number>-<slug>` after, and the rename does not appear in history.
- [x] Criterion 3: a fresh request ends with an open issue, an open draft pull request, and a branch whose only commit contains the effort’s artifacts.
- [x] Criterion 4: a spec revised three times during grilling produces three `docs` commits, all visible in the pull request.
- [x] Criterion 5: abandoning a draft leaves no open issue and no open pull request, both labelled as not being worked on.
- [x] Criterion 6: the issue body states every requirement with a checkbox beside its criterion; the pull request states every ticket with its criteria, or says tickets are not yet cut.
- [x] Criterion 30: a `/specify` invocation carrying a factual unknown produces a spec and an evidence file in one turn, with no second command required.
- [x] Requirement 35: the seeded forge reference states one issue and one pull request per effort with tickets local, replacing the sub-issue resolution this repository never adopted.

## Relevant areas

`src/skills/specify.md`, `src/skills/research.md`, `src/skills/refine.md`, `src/policies/execution.md`, `src/seed/references/github.md`.

## Constraints

The opening step publishes to a shared workspace. It proposes the whole set with exact strings and stops on a refusal rather than sliding to something it is allowed to do instead.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

**Built.** `section('the effort opens')` in `src/scripts/verify.mjs`, 42 assertions, plus a top-level `headingBlock(text, heading)` so an assertion can be scoped to the step it governs rather than to the whole file.

Ten fire-checks, each confirmed to have removed its subject before the run:

| Broken deliberately | Fired |
| --- | --- |
| opening steps 3 and 4 swapped | order that could actually run — while *every step is present* stayed green |
| the size sentence moved out of the section, still in the file | smallest and largest change — the scoping is real, not a whole-file match |
| `A refusal stops the opening` softened to proceeding locally | a refusal stops the opening |
| `# refine` re-headed as `# /refine` | refine is not headed as a slash command |
| the GitLab effort heading reverted to `Tasks as issues` | the gitlab seed heads its effort section |
| `Exactly two objects per effort` inverted to one issue per ticket | the policy states exactly two tracker objects |
| the inline-resolution sentence replaced by "a command the human runs next" | resolves material uncertainty in the same invocation |
| `tickets are files under efforts/<effort>/tickets/` removed from the runner | computes the frontier from the local ticket files |
| `neither carries a ticket` inverted | neither tracker object carries a ticket |

**One stale guard rewritten rather than left passing.** `skills/implement reads an external frontier from the recorded query` asserted the thing this ticket removes. It is now `computes the frontier from the local ticket files`, which also asserts the old sentence is *gone* — a one-directional check would have stayed green with both sentences in the file.

**The citation on the last criterion was wrong.** It read *Requirement 26*, which is the criterion-ticking requirement; the seeded-forge requirement is 35. Corrected here.

**Carried beyond the stated areas:** `src/seed/references/gitlab.md` got the same three rewrites as the GitHub seed. A seed corrected on one forge and stale on the other is worse than both being stale, because the disagreement is invisible until someone installs into the second one.

**Left for converge.** Requirements 5 and 35 make tickets unconditionally local, and six files outside this ticket's areas still read as though they might not be: `src/scripts/index.mjs` (78, 201, 209), `src/scripts/payload.mjs` (133), `src/skills/help.md` (87), `src/skills/tasks.md` (21-28), `src/templates/ticket.template.md` (8). Only the runner's own citation was corrected here.
