# feat(skills): each skill declares the guides it reads

Status: open
Blocked by: 03
Part of: streamline

## Problem

A skill establishes what it needs by restating it. There is no line at the top of a skill saying which guides apply, so the same machinery is rebuilt in each skill's own words — which is both the duplication the framework exists to prevent and the reason understanding is reconstructed on every invocation.

## Outcome

Every skill names the guides it reads, near the top, as pointers. Reading a skill therefore tells you what else to read before acting, and a skill read in isolation still says what it depends on. The declaration is body text rather than frontmatter, because nothing in the harness would act on a frontmatter field and a second place to keep true is the failure mode.

## Acceptance

- Every skill that reads a guide names it, and every guide named by any skill exists — asserted, so a renamed guide breaks the build rather than a run.
- A skill names only guides it actually reads.
- No skill restates the substance of a guide it points at.
- `pwsh -NoProfile -File scripts/verify.ps1` passes.
