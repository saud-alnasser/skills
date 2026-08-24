---
status: resolved
blocked-by: [04, 05, 06]
---

# feat(protocol): the bootstrap names seven primitives and states ownership once

## Outcome

The bootstrap describes what tickets 01 to 06 built: seven primitives, the ownership table, four workflow commands, and `version:` as the single release of record.

## Acceptance Criteria

- [x] Requirement 40 / criterion 29: the primitives table has seven rows, and evidence, tasks, worktrees, and position are described where they are used rather than given rows.
- [x] Requirement 56 / criterion 40: the bootstrap states which directories the protocol owns and which the repository owns, naming the bootstrap itself and the index individually.
- [x] Requirement 58: the bootstrap carries `version:` and is the only file naming a release.
- [x] The workflow line reads four commands, and the capability sentence beneath it names what is now a stage.
- [x] The suite’s `protocol.md` section asserts the row count, the ownership table, and the version field.

## Relevant areas

`src/protocol.md` and the `protocol.md` section of `src/scripts/verify.mjs`.

## Constraints

The bootstrap describes; it does not govern. Anything that reads as a requirement belongs in a policy, and anything already in a policy is not repeated here.

## Notes

The suite moves in the same pass as whatever this ticket asserts, never at the end (`[[rules/authoring]]`). Write the guard, then break the thing deliberately and watch it fail with the right name.

## Implementation notes

Seven rows, and the four that left are prose in the same section rather than
deleted: a reader who never hears of evidence again has lost a primitive, not a
table row. `efforts/<e>/` now names the directory rather than `spec.md`, because
the effort is the primitive and the spec is one of its parts.

**Ownership is a two-by-two table under the invariants**, replacing the
`owner: protocol` / `owner: repository` paragraph. Both root files are named,
since no directory rule reaches either: `protocol.md` is AEP's, `index.md` is
the repository's because it is derived and regenerated in place.

**The workflow line was already four commands.** What changed is the sentence
beneath it, which called `research` and `prototype` capabilities and said
nothing about `review` or `converge`. It now separates the two: `refine`,
`research`, `review`, and `converge` are stages the four commands run, and
`prototype`, `survey`, and `prune` are capabilities to reach for.

**`mode:` was still listed as a discovery field**, with a paragraph explaining
that an artifact's mode is applicability and yours is set by the skill. Modes
were removed in ticket 04. Both are gone.

**One contradiction resolved, and it came from ticket 19 landing an hour
earlier.** The bootstrap's `Humans decide` invariant read "Never push. Never
publish", and the bootstrap also states that a rule may tighten a policy but
never soften it. That made this repository's new push permission illegal by the
bootstrap's own ordering. The invariant now keeps merging, releasing, and
publishing with the human and defers what may be pushed to
`[[rules/version-control]]`. It grants nothing at protocol level: requirement 6's
issue-and-pull-request opening is ticket 14's, and the shipped seed still reads
"never push" for a repository that has not said otherwise.

**Budget:** 8041 of 8192 bytes. The rewrite added more than the cut removed, so
two paragraphs were tightened to buy the margin back.

**Deferred to ticket 08, correctly:** `specs.md` line 53 still reads "AEP defines
twelve primitives". That file is 08's whole subject and 08 is blocked by this
ticket, so the edge was cut right.

**Fire-checks, five, each confirmed to have changed the subject first:**

| Perturbation | Failure |
| --- | --- |
| an eighth row, `Decisions` | `8 rows: Policies, Rules, References, Contexts, Efforts, Agents, Skills, Decisions` |
| `templates/` dropped from the ownership table | `the ownership table names templates/ as the protocol's` |
| `decisions/` added to the ownership table | `claims decisions` |
| `/review` appended to the workflow line | `the line reads specify → plan → tasks → implement → review` |
| `version: 3.0.0` added to `policies/artifacts.md` | `also named by: policies/artifacts.md` |

The row count is counted off the table and the names compared in order, rather
than matched as prose: a regex for the seven names passes while an eighth row
sits beside them, which is how a cut grows back.

The ownership assertions run in both directions. The forward one reads
`PROTOCOL_DIRS` and `REPOSITORY_DIRS`, so it cannot catch a directory dropped
from the lookup and the bootstrap together, which is correct: those two moving
together is the change, not the drift. The reverse assertion is what catches the
other direction, a directory the table claims and the lookup has never heard of.
