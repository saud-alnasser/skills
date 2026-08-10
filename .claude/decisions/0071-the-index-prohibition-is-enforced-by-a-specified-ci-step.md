---
owner: repository
status: accepted
load-when: the enforcement of a generated index is in question, or what `.claude/scripts/` may hold
sources: [skills/configure/SCRIPTS.md, skills/configure/SKILL.md, specs.md, .claude/tickets/downstream/spec.md]
supersedes: []
superseded-by: []
---

# The generated-index prohibition is enforced by a specified step, not a third script

Regenerating and failing on any resulting difference is the enforcement, it is
specified on the page that specifies the derived scripts, and `/configure`
installs it. No new derived script is added.

**The claim already existed and the mechanism did not.** The specification says
the prohibition *is enforced* by comparing against a regeneration; the scripts
page says *the suite* does it. The scripts page specifies two scripts and neither
compares anything, and the only suite that exists is this repository's private
one, which is not shipped. Every configured repository inherited an assertion and
no mechanism.

**The comparison needs no code.** Regenerating and then failing on a difference is
two lines. It was proven downstream to exit clean on an untouched tree and to fail
naming the file on a staged tamper — so the missing piece was a specified home,
not an implementation.

**The all-derived model stays.** `.claude/scripts/` holds only what the page
specifies, and the audit checks that in both directions. That constraint is
deliberate and is not what was wrong; adding a script would have been the larger
change and would have put a new surface in every configured repository to do what
an existing script plus a comparison already does.

**The fixture is the part that matters most, and it must say the tamper is
staged.** The regenerator overwrites its output before any comparison runs, so a
tamper left in the working tree erases itself and the check reports clean. A
session testing it that way concluded the mechanism misses hand edits and reported
that. Every other derived surface here is proved against a fixture; the
enforcement is the claim three policy files actually assert and was the one thing
built on those scripts that nothing proved.

## Considered Options

- **Specify a third derived script.** Symmetric with the regenerator and the
  position report, and it could carry declared-pointer resolution as well.
  Rejected: it adds a surface every configured repository must carry and
  `/configure` must prove, to perform a comparison that needs no code — and the
  pointer half is asserted by no policy file, so the script's second job has no
  claim demanding it.
- **Weaken the three claims instead.** Reword the specification and the page to
  say the prohibition is enforced where a repository runs the comparison. Cheap
  and honest. Rejected: it leaves every configured repository with an unenforced
  prohibition and a sentence admitting it, which is the same gap with better
  manners.
- **Let each repository add its own comparison locally.** Rejected because the
  audit refuses anything `.claude/scripts/` was not specified to hold, and that
  refusal is correct — the model is all-derived on purpose.
- **Teach the regenerator to refuse rather than overwrite.** Rejected: the
  regenerator's own shipped fixture declares sources over directories that do not
  exist and expects the run to succeed, so a resolution refusal would fail the
  script's own proof.

## Consequences

**Declared-pointer resolution is not covered, and that is stated rather than
implied.** It is asserted by no policy file, it entered a configured repository
through one ticket's outcome sentence, and it cannot live in the regenerator for
the fixture reason above. The two halves of the original gap were never equally
motivated, and only the asserted half is closed here.

**The derived-only rationale must ship downstream.** The constraint is enforced in
every configured repository and justified only in the plugin's specification, so a
repository that hits it sees a prohibition with no reason and reads the framework
as self-contradicting. One session did exactly that. The reason lands in the
installed specification policy.

**A specified step nobody wires up would reproduce the gap one layer along.** The
audit re-checks it, and the fixture is run rather than described.
