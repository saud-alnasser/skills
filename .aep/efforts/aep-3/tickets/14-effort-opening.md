---
status: open
blocked-by: [06, 07]
---

# feat(specify): an effort opens as one issue, one branch, one pull request

## Outcome

`/specify` resolves its own uncertainty and performs the opening step: it creates the issue, renames the directory to its tracker number, branches, commits the artifacts as a `docs` commit, and opens a draft pull request, asking once for permission to push and for the effort’s priority. Abandoning closes both objects. The tracker section of the execution policy becomes one issue per effort, and the seeded forge reference is corrected to match.

## Acceptance Criteria

- [ ] Criterion 1: a one-line bug fix and a fifteen-ticket feature both produce one issue, one branch, and one pull request, and the bug fix has no plan.
- [ ] Criterion 2: the directory exists as `xxxx-<slug>` before the issue and as `<number>-<slug>` after, and the rename does not appear in history.
- [ ] Criterion 3: a fresh request ends with an open issue, an open draft pull request, and a branch whose only commit contains the effort’s artifacts.
- [ ] Criterion 4: a spec revised three times during grilling produces three `docs` commits, all visible in the pull request.
- [ ] Criterion 5: abandoning a draft leaves no open issue and no open pull request, both labelled as not being worked on.
- [ ] Criterion 6: the issue body states every requirement with a checkbox beside its criterion; the pull request states every ticket with its criteria, or says tickets are not yet cut.
- [ ] Criterion 30: a `/specify` invocation carrying a factual unknown produces a spec and an evidence file in one turn, with no second command required.
- [ ] Requirement 26: the seeded forge reference states one issue and one pull request per effort with tickets local, replacing the sub-issue resolution this repository never adopted.

## Relevant areas

`src/skills/specify.md`, `src/skills/research.md`, `src/skills/refine.md`, `src/policies/execution.md`, `src/seed/references/github.md`.

## Constraints

The opening step publishes to a shared workspace. It proposes the whole set with exact strings and stops on a refusal rather than sliding to something it is allowed to do instead.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.
