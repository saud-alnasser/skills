---
status: resolved
blocked-by: [09]
---

# fix(validate): a repository's own skill note stops being refused

## Outcome

`specs.md` §15.1 says in bold that a repository MAY add its own note beside a shipped skill, and calls it the extension point that keeps *this is how we prototype here* out of a protocol-owned file. `validate.mjs` has refused exactly that file since AEP 3. The validator moves, because the specification is normative and it argues the case at length.

## Acceptance Criteria

- [x] Requirement 11 / criterion 11: a repository-owned note at `.aep/skills/<skill>/<note>.md`, beside a skill the release ships, validates. Seen refused before and accepted after, with the note carrying the frontmatter §15.1 requires. — verified by the orchestrator. Probed against this repository's own tree before the change: `.aep/skills/plan/house-style.md` failed with "skills/ holds only what the protocol ships". The assertion runs against the install fixture's live tree, and removing `isRepositoryNote` from the guard reproduces the refusal by name: `refused the extension point: 56 artifacts checked, 1 failure(s)`.
- [x] Requirement 11 / criterion 11: **a skill the release does not ship is still refused.** The conforming set is exactly seventeen, so `.aep/skills/<name>.md` outside the manifest fails as it did, and the failure still names where repository-owned governance, orientation and tool operation belong. — verified by the orchestrator. Fire-checked by widening `isRepositoryNote` to any Markdown file below a directory: `a skill the release does not ship is still refused: validate accepted a skill outside the manifest`. The assertion matches the failure text as well as the exit, so a refusal for some other reason does not read as this one.
- [x] Requirement 11 / criterion 11: a note beside a directory that is not a shipped skill is refused, and so is one nested deeper than `skills/<skill>/<note>.md`. §15.1 makes a note a branch **of a skill**, so a path answering to no skill is not one. — verified by the orchestrator, two assertions, both seen failing under the same widening: `validate accepted a note beside no skill` and `validate accepted a note nested two levels deep`. The first writes `skills/house/style.md`, the second `skills/plan/house/style.md`, so the two differ only in whether the parent is a shipped skill.
- [x] Requirement 11 / criterion 11: every other protocol directory is unchanged. `policies/`, `agents/`, `templates/` and `scripts/` hold only what the release ships, and nothing here widens them. — verified by the orchestrator. The section already asserted `policies/`; this adds `templates/`, so a widening that reached every protocol directory fails on the second rather than passing on the one that happened to be checked. Under the widened guard both fail, `templates/` by name.
- [x] Requirement 11 / criterion 11: `verify.mjs` asserts all four, each seen failing with the right name before it was trusted, and the specification's own permission is quoted as the reason in the code rather than cited by section number. — verified by the orchestrator: five assertions, `105 passed, 0 failed`, and two perturbations between them fire all five. `isRepositoryNote`'s comment states why a note exists and why the permission stops where it does, and names no section, which `[[rules/authoring]]` requires of a file that ships.
- [x] Requirement 11 / criterion 11: **an upgrade preserves the note without offering it for pruning.** `validate.mjs` accepting a path while `install.mjs` names it to the human as protocol residue is the two disagreeing about who owns it, and a human following the installer's own advice deletes the extension point. — verified by the orchestrator, added after review round two found it. `isRepositoryNote` moved to `contract.mjs` so both scripts read one definition rather than two copies. Two assertions run a real upgrade against the fixture tree and read what it printed, because the printed list is what the human acts on. Fire-checked by removing the installer's half: `an upgrade does not offer a repository note for pruning: named it to the human: .aep/skills/plan/house-style.md`.
- [x] Requirement 11 / criterion 11: a note carries the `use-when` §15.1 requires of it. Before this permission the requirement was enforced by refusing the path outright, and admitting the path removed the only thing enforcing it. — verified by the orchestrator, also from round two. `skills` joins `USE_WHEN_REQUIRED_DIRS`, which costs the payload nothing because every shipped skill and note already carries one, and `validate.mjs` reports 215 artifacts with no failures either side of the change.
- [x] The release is re-cut over the result and a fresh clone of the branch is green, since the working tree is not the thing that ships. — verified by the orchestrator, and it is the check that caught the defect this round: `git clone --no-local` of the branch, then the suite inside the clone.

## Relevant areas

`src/scripts/validate.mjs`, the protocol-directory check; `src/scripts/verify.mjs` for the assertions; `specs.md` §15.1 as the authority.

## Constraints

The permission is exactly as wide as §15.1 makes it: one note, beside a shipped skill, one level deep. Nothing here lets a repository add a skill, and nothing here reaches another protocol directory.

The reason goes in the code as a reason, not as `§15.1`. `[[rules/authoring]]` forbids shipped text citing a section number that resolves only in this repository, and `validate.mjs` ships.

## Notes

Found by review, outside this effort's spec as it then stood, and the human chose to fix it here rather than specify it separately. **Requirement 11 and criterion 11 record that choice**, added on 2026-08-26 after a second review round found all five criteria here citing requirement 7, which is ticket 08's and is about the entrypoint's claims. A ticket that traces to nothing is scope nobody asked for or a requirement the spec is missing, and this was the second; a number borrowed from a neighbour is what stopped the traceability check saying so. The alternative recorded and declined: amend §15.1 to drop the permission, which is a design reversal rather than a repair, against a passage that argues the extension point's value at length.

`topLevel()` in `contract.mjs` already exists because "a skill is a top-level file, and `skills/<skill>/<note>.md` is depth reached from it". The distinction this ticket needs is one the contract already draws.
