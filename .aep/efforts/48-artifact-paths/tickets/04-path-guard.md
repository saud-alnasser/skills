---
status: resolved
blocked-by: [01, 03]
---

# test(verify): a bare artifact path fails the suite

## Outcome

The suite fails on a multi-segment artifact path in shipped text that does not carry `.aep/`. It lands **before** the sweep, so it is red against the corpus as it stands today, and the sweep in ticket 05 is then verified by watching it go green rather than by reading 37 diffs.

## Acceptance Criteria

- [x] Requirement 5 / criterion 5: adding a bare `efforts/<effort>/…` path to a shipped surface fails `verify.mjs`. Seen to fail with the path present and to pass with it removed. — verified by review: appending ``Copy it to `efforts/<effort>/scratch.md`.`` to `src/skills/domain.md` took `node src/scripts/verify.mjs --section "path convention"` from 65 bare paths to 66, naming `src/skills/domain.md:56  efforts/<effort>/scratch.md`; removing it returned the run to 65. The suite stays red on the other 65 until ticket 05, which is this ticket's stated ordering.
- [x] Requirement 5: the guard is red against the payload as it stands when this ticket lands, and the failure lists the offending sites by file and line. That list is the input to ticket 05. — verified by review, which audited all 65 mechanically rather than by sample: for every site, the named line of the named file holds the reported path, zero mismatches. Two caveats for ticket 05 are recorded in its Notes: seven sites are the migration table's 1.x column and take `.claude/`, and `protocol.md` is four bytes short of the room its own five sites need.
- [x] Requirement 1: the guard matches a backticked path whose first segment is an AEP tree directory and which has a second segment, outside fenced blocks, consuming `outsideFences` from ticket 01. A single-segment area name such as `policies/` is not a finding. — met after a review fix. The first implementation read *any* character after the slash as a second segment, so `` `scripts/*` `` at `migration.md:103` and `:104` was reported although a glob names an area exactly as `scripts/` does. A segment now has to begin with a name character; the corpus fell from 67 sites to 65, losing those two and nothing else, and `an area name is not a finding, bare or globbed` fixes the case in the suite.
- [x] The guard covers `src/adapters/` as well as the payload, since the committed adapters are generated from it and would otherwise carry the old form past the sweep. — verified by review: a bare path added to `src/adapters/claude/skills/specify/SKILL.md` was reported at line 17, and the file restored. The adapters report nothing today, which is what an arm scanning nothing also produces, so each of the four arms now asserts separately that it has surfaces to scan.
- [x] The guard is broken deliberately once in the direction that matters: a site that *does* carry `.aep/` must not be reported, or the sweep would pass by making the check meaningless rather than by fixing anything. — verified by review: deleting the lookbehind takes the corpus from 65 sites to 176, and reading each of the 111 additions back out of its file, every one sits behind a root or an explicit relative prefix — 77 behind `.aep/`, 28 behind `../`, six behind `.` or `.agents/`. The corollary, that a mistaken `../skills/x.md` would never be reported, is accepted: the adapter pointers need that form.

## Relevant areas

`src/scripts/verify.mjs`, consuming `outsideFences` from `src/scripts/contract.mjs`.

## Constraints

**Change no payload text in this ticket.** A guard that lands green because its subject was fixed in the same commit has never been seen to fail, which is the failure mode `[[rules/authoring]]` names.

No allowlist. The exemption a guard carries is where the next drift enters, and the single-segment rule already removes every legitimate case found in the survey.

## Notes

The suite will be red between this ticket and ticket 05. That is the point of the ordering and is why the two are separate tickets rather than one.

`wikiLinks` deliberately does not strip inline code spans, and this guard depends on that: every path it checks is inside backticks. Stripping spans would silently excuse the whole corpus.
