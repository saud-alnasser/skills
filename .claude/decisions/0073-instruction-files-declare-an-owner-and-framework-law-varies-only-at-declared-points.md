---
owner: repository
status: accepted
load-when: an installed instruction file is about to be edited, healed, or varied per repository
sources: [specs.md, .claude/policies/, skills/configure/]
supersedes: []
superseded-by: []
---

# Instruction files declare an owner, and framework law varies only at declared points

Every file AEP installs was repository-owned and healable, which licensed
sessions to treat framework law as negotiable — one of the observed causes of
settled questions being re-asked. Decided: every installed instruction file
declares its owner in frontmatter. `framework`-owned files are law — installed
verbatim, release-stamped, audited byte-for-byte, never healed or debated in a
session — and repository variation enters only through extension points the
owning file names: a structured declaration for facts, an ADR for variation
needing reasoning. A variation with no point is a declared deviation, surfaced
by every audit until the framework grows the point or the repository conforms.
Contexts, decisions, evidence, and derived tool guides stay repository-owned.

## Considered Options

- **A fixed directory** instead of frontmatter — visible in the tree, but forces
  a layout migration and splits the rules directory by owner. Rejected.
- **Plugin-only, never installed** — zero drift by construction, but breaks the
  constraint that a plugin-less clone can follow every rule from committed text.
  Rejected.
- **Status quo, all healable** — rejected as the cause under repair.

## Consequences

Ambiguity fixes compound: fixed once in the framework, every repository inherits
on upgrade instead of forking prose. Upgrades become verbatim replacement.
Healing narrows to what a repository genuinely owns. The deviation channel is
load-bearing: without a loud escape hatch, all-fixed pressures repositories to
fork, which is worse than the disease.
