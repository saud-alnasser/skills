---
owner: repository
status: accepted
load-when: the router's stage table is being changed, or something proposes restating what a stage receives
sources: [skills/configure/protocol.template.md, build/verify.js, scripts/assemble-row.js]
supersedes: []
superseded-by: []
---

# The router table keeps a per-stage column, and the build holds it to the store

At 2.0 a stage's row became a filter over norms rather than a list of files, and the row
assembler stopped reading the router table's third column — it resolves only the stage and
its posture. That left the column readable by nobody, describing a directory that no longer
exists. It could have been dropped, leaving the store's `stages` field as the single
statement of what a stage receives. It is kept instead, rewritten to name record subjects,
because the protocol file is where a reader goes to learn what a stage loads and a table
that no longer answers that sends them to run a query.

## Consequences

The cost is accepted rather than avoided: the column and the store's `stages` fields are two
homes for one fact, which is the drift the store was built to remove. **Nothing at runtime
reads the column, so drift in it is silent by construction** — that is what makes the guard
comparing the column against a query over the store load-bearing rather than a nicety, and
why the guard is an acceptance criterion of the change that introduced the column rather
than a follow-up.

Neither the filter's definition nor the table's authority moves. The row delivered to a
stage is still computed from firing conditions and never from this column; the column is a
committed description of that computation's result, held to it by the build.
