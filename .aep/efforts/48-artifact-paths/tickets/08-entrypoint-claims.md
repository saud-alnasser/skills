---
status: resolved
blocked-by: [10]
---

# feat(verify): the entrypoint's claims are asserted

## Outcome

`AGENTS.md` stops being exempt from everything but a substring match. Each factual claim it makes about the implementation is checked against the thing it describes, and every path it names must exist. It keeps its exemption from the four prose prohibitions, which is a different exemption and is now a different constant.

## Acceptance Criteria

- [x] Requirement 7 / criterion 7: `AGENTS.md` is no longer exempt from claim checking, and the suite asserts more about it than that it contains `.aep/protocol.md`. — verified by the orchestrator. The new `entrypoint claims` section is `16 passed, 0 failed`, and the file is also scanned by `retired fields` from ticket 07, so the old single substring match is now one assertion among eighteen. The split is asserted as the two facts it is: the entrypoint keeps its place in `EXEMPT_FROM_PROSE_RULES` and is present in `ENTRYPOINTS`, which is what stops the second exemption being quietly reabsorbed into the first.
- [x] Requirement 7: every backticked token in an entrypoint that names a repository path must exist. This is the general net and it costs no maintenance. — verified by the orchestrator. A path is a token with a slash or a shipped extension, read from inline spans outside fences, so `use-when` and a flag shown with its argument are not tokens. Fire-checked in a scratch checkout by naming `src/stamps/baseline.json` and `src/scripts/gone.mjs`: `every path AGENTS.md names exists: src/stamps/baseline.json, src/scripts/gone.mjs`. Each entrypoint separately asserts it has paths to check, so an arm that stopped matching cannot read as a clean one.
- [x] Requirement 7: the named claims are asserted against what they describe. The adapter sentence must not name a single runtime while `TARGETS` holds more than one; `src/stamps.json` must exist and be what `release.mjs` writes; each command shown must name a script that exists. — verified by the orchestrator, and **the flag half of it found a false claim this effort's own first commit introduced.** `AGENTS.md` said `--only <runtime>` narrows the generator; the flag is `--target`, at `adapters.mjs:386`. Corrected, and `node src/scripts/adapters.mjs --target claude` now runs as the sentence says. The baseline claim is asserted against `STAMPS_SOURCE` rather than against the string the file carries, and the command net was fire-checked with `node src/scripts/gone.mjs`, which fails naming the script.
- [x] Requirement 9 / criterion 9: reverting the "the Claude adapter" hand-correction made in this effort's first commit fails the suite. Seen to fail before being restored. — verified by the orchestrator in a detached worktree outside the repository, with both halves of that correction put back, the table row and the *Regenerate* line, after confirming the corrected text was gone. `the entrypoint names no single runtime as the adapter: names claude`. The assertion is written against `TARGETS` rather than against the word, so it stays true as runtimes are added and fails the moment one is singled out. The branch was never perturbed and the worktree was removed.
- [x] `EXEMPT_DOCS` splits rather than being deleted. The prose-prohibition exemption keeps both `specs.md` and `AGENTS.md`; claim checking stops consulting it. The two constants are named so neither can be mistaken for the other. — verified by the orchestrator. `EXEMPT_FROM_PROSE_RULES` holds both files and is read only by `governed text`; claim checking reads `ENTRYPOINTS`, which is a different constant with a different subject. No use of the old name survives, checked by regex over the file rather than by eye.
- [x] The seed `AGENTS.md` gets the same path net and no more. A consuming repository's own entrypoint is theirs after install and nothing here reaches it. — verified by the orchestrator, **with one assertion more than the criterion asks for**: the seed's paths must all start with `.aep/`, because a seeded entrypoint naming `src/` would be describing this repository to somebody who does not have it. That is a narrowing of the net rather than a claim about the consuming repository, and none of the named claims above reads the seed.

## Relevant areas

`src/scripts/verify.mjs` (`EXEMPT_DOCS` at line 90, the entrypoint assertion near line 2707), `AGENTS.md`, and `src/seed/` for the shipped entrypoint.

## Constraints

**An assertion is written for a claim about the implementation, never for wording.** The bound exists so that editing the entrypoint does not become a fight with the suite, which is how people start working around it.

Prose-quality checks on entrypoints are out of scope. Whether `AGENTS.md` should also lose its exemption from the four prohibitions is a separate question with a separate answer.

Generation was considered and rejected: the seeded entrypoint is handed over on install and never touched again, so generating would apply to one file and split the two copies' natures. The reasoning is in `[[efforts/48-artifact-paths/plan]]` and is worth leaving findable, because it is the obvious idea and will be proposed again.

## Notes

Renaming rather than flagging is deliberate. One file ended up exempt from claim checking by inheriting an exemption written for prose, and a boolean parameter on one constant would leave the same confusion available.

Criterion 9 is the only evidence that these assertions cover what actually occurred rather than what was easy to write. Run both reverts in a scratch checkout, watch each fail by name, and record which assertion fired.
