---
owner: repository
status: accepted
load-when: work would touch a repository other than the one the session is for, or a finding is about another repository
sources: [.claude/rules/, .claude/protocol.md, skills/configure/protocol.template.md, .claude/tickets/downstream/spec.md]
supersedes: []
superseded-by: []
---

# Work for another repository leaves as a report, never as a change

Reading another repository is permitted. Writing in one, planning in one, or
entering a stage for one is not, and a finding about another repository is handed
back as a report rather than offered as an options list. The prohibition is
always-on; the fact it depends on — which repository governs this request — is
computed by the router.

**The rule is in the always-on tier because of when it must fire.** A path-scoped
rule arrives once a covered file has been read, which is after the decision it
exists to inform; the boundary decision is made before the first read in the other
repository. That is the same argument the placement rule makes for itself, one
scope wider. `engineering.md`'s *never push and never publish* is the nearest
existing analogue and the model followed here: an absolute prohibition on a class
of act only the human may authorise.

**A finding is a report and not a menu, and that clause is the load-bearing one.**
The design stage is told never to decide architecture silently — present the
options, recommend one — and that instruction has no carve-out for a diagnosis
whose subject is outside the repository. Applied there it converts a finding into
a proposal the session then owns, which is precisely the escalation that put a
session in the wrong repository. The boundary rule supplies the carve-out.

**Authorization does not transfer across the boundary.** *Do the upstream fix
first* was a real instruction, and it should still have produced a handoff: a user
authorising work cannot thereby authorise this session to be the place it happens.
Without this clause the rule is satisfiable by asking, and asking is what
happened.

**The machinery is separated from the rule for the reason the Marker already is.**
The prohibition must fire on every turn and so lives where every turn pays for it;
the computation is a lookup and lives in the router, which a question turn never
loads. Putting the computation in the rule would charge every turn for a fact
almost no turn needs, and putting the prohibition in the router would make it fire
only when a stage happens to run — which the router's own comment names as a
silent failure.

**A clean position report was being read as jurisdiction.** It answers *has this
repository moved under me*, never *is this repository mine to change*, and every
configured repository answers the first cleanly to anyone who asks. The report
gains the second question so that the first stops being mistaken for it.

## Considered Options

- **State the rule and add no machinery.** One always-on file, nothing computed.
  Rejected: the crossing that produced this was a chain of individually authorised
  steps, and what failed was not knowledge of the rule but noticing that the
  boundary had been reached. A rule with nothing watching is what the framework
  already had.
- **Put the rule in the router beside the machinery.** Keeps one subject in one
  file and costs nothing on a question turn. Rejected on the router's own stated
  design: a rule that must hold unconditionally, placed there, fires only when a
  stage runs.
- **Scope it to a skill — the design stage, where the escalation happened.**
  Rejected because the reading came first: the session read another repository's
  files before any stage was entered, and a rule that arrives with the stage
  arrives after the decision.
- **Forbid reading another repository as well.** Simplest to state and to check.
  Rejected as false to the work: diagnosing a claim about the framework requires
  reading what the framework ships, and a rule that forbids it would be broken
  routinely and correctly, which is how a rule stops being read at all.

## Consequences

**The entry rule gains an exception it did not have.** *Enter that stage rather
than answering with something for the user to run* reads as a general prohibition
on reporting instead of acting, and one session cited exactly that while crossing.
Where the subject is another repository, reporting **is** the action, and the
boundary rule is what says so.

**A refusal must name both repositories.** The computed answer can be wrong, and a
stage that refuses without saying which repository it believes governs leaves a
reader with a wall instead of a claim they can check.

**Every configured repository gains a fourth always-on rule**, and the always-on
tier is charged to every turn. That cost is accepted here and is the reason the
two standards in the same effort became clauses in an existing file rather than
files of their own.
