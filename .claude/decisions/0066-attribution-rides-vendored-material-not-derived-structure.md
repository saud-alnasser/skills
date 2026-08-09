---
status: accepted
load-when: attribution to the upstream project is being added, removed, or questioned
sources: [NOTICE, skills/, agents/, .claude/rules/skills.md]
supersedes: [0001]
superseded-by: []
---

# Attribution rides vendored material, not derived structure

**Supersedes ADR 0001**, whose live conclusions are carried forward here rather than left behind: the upstream is MIT, this repository is Apache-2.0, and `NOTICE` reproduces the upstream terms in full while any vendored text ships. What does not carry forward is 0001's list of which skills were vendored. That list recorded the intent at vendoring time in 2026; the files have been rewritten since, and each one's own line is the current record. Where the two disagree — `prototype` and `research` are on 0001's list and say *derived* in the file — **the file wins**, because it describes what the text is now and the list describes what was planned then.

Twenty-four shipped files carried attribution to mattpocock/skills, but only five are recorded as *vendored* — copied text. The other nineteen say a *structure* was derived: a two-axis review, a core loop, a branch discipline. Copyright protects expression rather than structure, and the upstream licence is MIT, whose condition binds "copies or **substantial portions**" — so those nineteen lines were courtesy, not obligation, and stating an obligation where none exists misrepresents the licence in the other direction.

Attribution therefore follows the vendored set: the five files that carry copied text keep it, `NOTICE` stays in full because substantial portions demonstrably remain, and the nineteen structure-derived files drop the line.

## Considered Options

**Remove all attribution and `NOTICE`**, on the ground that the work has drifted far from upstream. Rejected on the facts: five files are recorded as vendored, so substantial portions remain and MIT's condition is met. Drift is the right test and the answer to it is no, not yet.

**Rewrite the five vendored files** so no substantial upstream expression remains, then remove everything. A genuine route to the same end, and rejected only as scope — it changes what five shipped skills say, which is a content decision rather than a licensing one, and it can be taken later without revisiting this.

**Keep all twenty-four.** Accurate and compliant, and rejected because nineteen of them assert a licence obligation that does not exist. A notice that overstates its own necessity is as misleading as one that is missing, and it teaches the next author that any resemblance requires attribution.

## Consequences

The prior Constraint — *every skill derived from mattpocock/skills carries its attribution* — is narrowed to the vendored set, in `.claude/contexts/repository.md` and `.claude/rules/skills.md` both.

**Whether a file is vendored becomes a load-bearing fact** rather than a description. It decides whether a licence notice is required, so it is asserted rather than trusted: the suite pins the vendored set by name, and adding vendored material without attribution fails the build.

The suite's existing attribution guards were written against the wider set, including one that required at least ten attributed files. That floor was already loose — twenty-one files carried attribution against a floor of ten, so eleven could vanish unnoticed — and under the narrowed rule it is wrong as well as loose. It is replaced by pinning the set exactly.
