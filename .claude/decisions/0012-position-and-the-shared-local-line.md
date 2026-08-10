---
owner: repository
status: accepted
load-when: a file under .claude/ is about to be committed or ignored
sources: [.claude/.gitignore, .claude/position/]
supersedes: []
superseded-by: []
---

# Knowledge is shared; Position is per-clone

A repository worked by several people, each running several instances, needs one answer to what belongs to the repository and what belongs to a working copy. **Knowledge is committed and reviewed like code. Position is per-clone and never committed.**

**Position** is state describing where *this clone* stands rather than what the repository knows — the commit Context was last verified against, the ticket this working tree has claimed, the prototype code currently on disk. `.claude/.gitignore` is its definition, not a list of exceptions.

Naming the category is the point. The Marker was previously a one-off: the glossary defined the file, and `.gitignore` listed `marker.json` and `prototypes/` as two unrelated entries. Every further local file was another exception for `/configure` to be told about, and the fourth would have been forgotten. With the category named, `/configure` has one rule, and `Marker` becomes an instance of it rather than a special case.

The invariant that keeps Position from becoming a fourth knowledge layer: **nothing shared may depend on it.** Delete `.claude/`'s ignored files and no other person and no other clone loses information they needed.

## Considered Options

- **Make `.claude/` local, so each person builds their own partner.** Rejected: the persistent repository-knowledge layer is the entire reason Tenure exists over the skills it derives from. Machine-local Context dies with the machine, and every teammate's Claude re-derives it from nothing — which is the cost the framework was built to remove. Personal working style is real, but its home is the user's global `CLAUDE.md`, outside any repository.
- **Leave the Marker a documented one-off and add each local file as another.** Cheaper, and defensible while the category has three members. Rejected because the rule is what `/configure` needs; a list is what it forgets.

## Consequences

Committed Context means two people's instances will occasionally conflict on `context.md`. That is correct behaviour, not a defect — knowledge conflicts get reviewed like code, and healing edits are small and land with the change that made them true.

**Root `CLAUDE.md` splits.** It is committed and always-on for *every* Claude reading the repository, including one with no Tenure installed, so it keeps only what applies universally: verify before claiming, the knowledge-layer table, precedence, conventions, and the pointer to `.claude/context.md`. Tenure's own protocol — the Marker, when healing runs, who advances what — moves to a file only Tenure's skills read. ADR 0007's consequence still holds, because the rules that must fire on every turn are exactly the universal ones; what moved was machinery, not rules.

Enabling Tenure in a project is itself Position: `local` scope records it in `.claude/settings.local.json`, which is gitignored (ADR 0015).
