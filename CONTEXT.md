# Tenure

This repo builds **Tenure** — a Claude Code skill framework that makes Claude a partner whose understanding of a repository compounds over time, rather than a stateless execution pipeline. It derives from [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering) and adds a persistent repository-knowledge layer on top.

## Language

**Knowledge Layer**:
One of the three places engineering knowledge lives — Codebase, Context, or Decisions. Each answers a different question and they never duplicate each other.
_Avoid_: tier, level, layer (unqualified)

**Codebase**:
The absolute source of truth. Where conflicts with Context or Decisions are always resolved.
_Avoid_: source, implementation, reality

**Context**:
How this repository thinks — concepts, vocabulary, boundaries, stable constraints. Excludes implementation. A Tenure-configured repo holds it at `.claude/context.md` and `.claude/contexts/`; this repo has not been migrated yet (ADR 0006) and still holds it at the root.
_Avoid_: documentation, architecture doc, glossary

**Domain Context**:
A `contexts/*.md` file covering one engineering domain. Earns its existence only when a domain has its own vocabulary, principles, or ownership — never merely because a folder exists.
_Avoid_: sub-context, module doc

**Project Context**:
A directory under `contexts/` grouping the Domain Contexts belonging to one project or package. Earns a directory on the same test a Domain Context earns a file — its own vocabulary or ownership. Domains that span the repository stay flat at `contexts/`.
_Avoid_: namespace, scope, module

**Routing Table**:
The section at the end of the root Context file naming each Domain Context with the condition for loading it and its Source Pointer. The mechanism that makes context loading demand-driven.
_Avoid_: index, manifest, TOC

**Source Pointer**:
A navigation coordinate — "start investigating here." Never a claim about what APIs, functions, or behavior exist. Every pointer is verified against the Codebase before use.
_Avoid_: reference, path, link

**Decision**:
Why an approach was selected, preserved as an ADR. A draft until committed; after that its reasoning is frozen and only its status moves. A changed mind is a new file that supersedes it. A Tenure-configured repo holds these at `.claude/docs/decisions/`; this repo still uses `docs/adr/` pending migration (ADR 0006).
_Avoid_: rationale doc, design doc

**Evidence**:
The trail showing how a claim was earned — research findings and prototype write-ups. Distinct from knowledge: evidence records what was verified and when, and nothing validates it afterwards. Durable findings graduate out of evidence into Context or a Decision.
_Avoid_: notes, artifacts, output

**Drift**:
Divergence between Context and Codebase caused by changes made outside Claude's sessions — teammate commits, branch switches, or the human's own uncommitted edits.
_Avoid_: staleness, rot

**Position**:
State describing where *this clone* stands, rather than what the repository knows — the commit Context was last verified against, the ticket this working tree has claimed, the prototype code currently on disk. Never committed: `.claude/.gitignore` is Position's definition, not a list of exceptions. Not a Knowledge Layer and not knowledge at all, so nothing shared may depend on it.
_Avoid_: local state, cache, session state, workspace state

**Marker**:
The commit Context was last verified against — a Position, held in `.claude/marker.json`. A cache-validity check: when it matches `HEAD` and the tree is clean, Context can be trusted without re-verification. Per-clone, because a teammate's verification is not Claude's.
_Avoid_: last_sync_commit, checkpoint, baseline

**Healing**:
Repairing Context where it has diverged from the Codebase, done at the moment the divergence is found rather than in a scheduled pass. There is no synchronization stage — verification happens where Context is used.
_Avoid_: sync, reconciliation, refresh, drift repair

**Assignment**:
Which human owns delivering a ticket. Human-to-human, held on the tracker, and never Tenure's to write unasked — how that human delivers it, and with how many instances, is theirs to decide. Because Assignment separates humans, contention exists only ever *within* one Assignment.
_Avoid_: owner, claim, allocation

**Claim**:
The assertion that an instance is building a ticket now, made before any work begins by creating the ticket-named branch. Scoped inside one Assignment, so it coordinates one human's instances and nothing wider. The branch *is* the Claim: git refuses to check one branch out in two worktrees, so exclusion is enforced rather than agreed, and reading the current branch is how an instance that lost its context knows what it was building. On a repository using stacked changes the unit is the whole stack rather than one branch, because restacking rewrites every descendant — see `tools/graphite.md` for the model. Never written to the tracker, which carries human-level facts only.
_Avoid_: lock, lease, assignment, reservation

**Grill**:
The interrogation of a proposal before it is built. Where most durable understanding is produced, which is why `/design` captures vocabulary and Decisions as they resolve rather than afterwards.
_Avoid_: interview, review, questioning

**Gate**:
A checkable yes/no condition that adds a stage to the pipeline. Gates only ever raise rigor.
_Avoid_: check, criterion, flag

**Floor**:
The minimum Tier implied by a change's classification. A judgement call, so it may raise rigor but never lower it.
_Avoid_: baseline, default, minimum

**Tier**:
The depth of engineering process selected for a piece of work — Express, Standard, or Heavyweight. Chosen after the Grill, as `max(Floor, Gates)`. Scales with risk, not with size.
_Avoid_: mode, level, track

**Spine**:
The seven commands that own the workflow's stages — `/configure`, `/design`, `/implement`, `/review`, `/research`, `/prototype`, `/commit`. Distinguished from Primitives, which the Spine composes.
_Avoid_: core, pipeline, main flow

**Primitive**:
A model-invoked skill with no stage of its own, existing to be composed by the Spine (`grilling`, `tdd`, `codebase-design`, `domain-modeling`).
_Avoid_: helper, sub-skill, utility

**Vendored Skill**:
A skill copied from mattpocock/skills into this repo and altered to fit Tenure, rather than invoked in place.
_Avoid_: forked, imported, borrowed

## Domain contexts

None yet. As `skills/` populates, each earns a `contexts/*.md` only under the Domain Context rule above.
