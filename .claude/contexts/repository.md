# AEP

This repository builds the **AI Engineering Protocol** — a Claude Code skill framework that makes Claude a partner whose understanding of a repository compounds over time, rather than a stateless execution pipeline. It derives from [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering), and its canonical definition is `specs.md` at the root.

It is also configured *by* AEP. Those are two different things, and the boundary below is the one to keep straight.

## Language

**Knowledge Layer**:
One of the three places engineering knowledge lives — Codebase, Context, or Decisions. Each answers a different question and they never duplicate each other.
_Avoid_: tier, level, layer (unqualified)

**Codebase**:
The absolute source of truth. Where conflicts with Context or Decisions are always resolved.
_Avoid_: source, implementation, reality

**Context**:
How this repository thinks — concepts, vocabulary, boundaries, stable constraints. Excludes implementation. Held at `.claude/contexts/`.
_Avoid_: documentation, architecture doc, glossary

**Domain Context**:
A `contexts/*.md` file covering one engineering domain. Earns its existence only when a domain has its own vocabulary, principles, or ownership — never merely because a folder exists.
_Avoid_: sub-context, module doc

**Project Context**:
A directory under `contexts/` grouping the Domain Contexts belonging to one project or package. Earns a directory on the same test a Domain Context earns a file — its own vocabulary or ownership. Domains that span the repository stay flat at `contexts/`.
_Avoid_: namespace, scope, module

**Routing Table**:
The table in `contexts/map.md` naming each Domain Context with the condition for loading it and its Source Pointer. The mechanism that makes context loading demand-driven.
_Avoid_: index, manifest, TOC

**Source Pointer**:
A navigation coordinate — "start investigating here." Never a claim about what APIs, functions, or behavior exist. Every pointer is verified against the Codebase before use.
_Avoid_: reference, path, link

**Decision**:
Why an approach was selected, preserved as an ADR at `.claude/decisions/`. A draft until committed; after that its reasoning is frozen and only its status moves. A changed mind is a new file that supersedes it.
_Avoid_: rationale doc, design doc

**Evidence**:
The trail showing how a claim was earned — research findings, prototype write-ups, the record of a rejected request, and the discussion that produced no decision. Distinct from knowledge: evidence records what was verified and when, and nothing validates it afterwards. That shared property is what earns the four of them one grouping directory. Durable findings graduate out of evidence into Context or a Decision.
_Avoid_: notes, artifacts, output

**Drift**:
Divergence between Context and Codebase caused by changes made outside Claude's sessions — teammate commits, branch switches, or the human's own uncommitted edits.
_Avoid_: staleness, rot

**Healing**:
Repairing Context where it has diverged from the Codebase, done at the moment the divergence is found rather than in a scheduled pass. There is no synchronization stage — verification happens where Context is used.
_Avoid_: sync, reconciliation, refresh, drift repair

**Grill**:
The interrogation of a proposal before it is built. Where most durable understanding is produced, which is why `/design` captures vocabulary and Decisions as they resolve rather than afterwards — and files what did not resolve as a discussion, in evidence.
_Avoid_: interview, review, questioning

## Boundaries

- **`skills/` is what ships; `.claude/` is what this repository runs on.** This repository both builds AEP and is configured by it, and confusing the two is the easiest mistake available here. A change to how AEP behaves for its users goes in `skills/`. A change to how *this* repository is understood goes in `.claude/`. Neither is edited to fix a problem belonging to the other.
- **A rule has exactly one home**, and the home is determined by when the rule must fire, not by what it is about. Restating a rule where it reads well is the failure this framework exists to prevent.
- **The Spine owns stages; Primitives own none.** A Primitive that acquires a stage has become a Spine command and needs a Decision saying so. Both terms are `contexts/skill-authoring.md`'s.
- **AEP's templates are not this repository's configuration.** `skills/configure/*.template.md` describes what gets installed elsewhere; the installed copies here are ordinary files that this repository owns and may heal.

## Constraints

- **Every skill derived from mattpocock/skills carries its attribution.** Licence-derived, not stylistic — see `LICENSE` and `NOTICE`.
- **The root `CLAUDE.md` stays under 200 lines.** It is always-on, so every turn pays for it whether or not a skill runs.
- **Nothing committed may assume AEP is installed.** A teammate who clones this repository without the plugin must be able to follow every rule in `CLAUDE.md` and `.claude/rules/` on their own — the harness loads both without it.
