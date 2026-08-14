---
owner: framework
type: norm
subject: decisions
fires-when: stage
stages: [design, review]
spans:
  - declared-fields: ilmqbe
  - an-adr-s-reasoning-freezes-on-commit: 2x8fk2
  - a-changed-mind-is-a-new-file: k44hq3
  - writing-only-the-new-end-is-the-tempting-half: 163ocy
  - a-contradicted-adr-names-what-contradicted-it: dhnx67
  - a-contradiction-is-not-always-a-changed-mind: pvsmez
---


# ADR Format

A Decision is a `decision` record in the knowledge store, its file named `0001-slug.md` onward and numbered sequentially. The whole file is one record, keyed on its title heading, because a frozen account's sections are one record's parts rather than separate statements.

## Declared fields

Every ADR declares these eight, and no others — a field nothing acts on is deleted rather than maintained.

| Field | Holds | Read by |
| --- | --- | --- |
| `owner` | `repository` — a decision record is the repository's to write | the build |
| `type` | `decision` — what admits the record to the store | the build, and precedence |
| `status` | `proposed \| accepted \| deprecated \| superseded` | a reader deciding whether this is live |
| `load-when` | the condition under which to open this file | the query |
| `sources` | where the subject of this decision lives | the query, and anyone navigating |
| `supersedes` | the ADRs this one replaces | the supersession graph |
| `superseded-by` | the ADRs that replace this one | the supersession graph |
| `falsified-by` | the findings that contradict this one | the falsification graph |

## An ADR's reasoning freezes on commit

- An ADR is a draft until committed. Once committed its reasoning is **frozen**: of the declared fields only `status`, `superseded-by`, and `falsified-by` move, and never the prose — an ADR records what was decided and why *at the time*, and rewriting it destroys the only record of the reasoning actually applied. The three that move are pointers rather than reasoning, which is what admits them: saying that a record is retired, replaced, or contradicted changes nothing about what it decided. `load-when` and `sources` describe the file rather than the decision, and are corrected like any other pointer.

## A changed mind is a new file

- **A changed mind is a new file, and supersession is written at both ends, in the same change** — the new ADR lists the old under `supersedes`; the old lists the new under `superseded-by` and its `status` becomes `superseded`. A claim made at one end and absent at the other is a **defect**, not a stylistic preference — it is what lets the graph be checked rather than trusted.

## Writing only the new end is the tempting half

- **Writing only the new end is the tempting half, because that is the file being edited** — it leaves a reader who opens the old ADR with no way to learn it is dead, and that reader is the exact one this rule exists for.

## A contradicted ADR names what contradicted it

- **A finding that falsifies a committed ADR is named on that ADR in `falsified-by`, written at both ends in the same change** — the prose is frozen, so a correction can only live in another record, and a correction unreachable from what it corrects reaches nobody: the reader it exists for is the one who opened the ADR rather than the one who read the index.

## A contradiction is not always a changed mind

- **Reach for `falsified-by` where the argument holds and a clause is wrong, and for supersession where the decision itself is wrong** — retiring a live decision to fix one sentence moves every surviving paragraph into a new file, which loses the record of what was actually decided that freezing exists to protect.
