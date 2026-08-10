# Spec Format

Standard and above. **Where a spec is written differs per repository, and `.claude/policies/tracker.md` declares which** — read the path there rather than assuming one.

A spec is the reasoning behind the tickets — the thing that lets someone judge whether the tickets are the right ones. Tickets say what to build; the spec says why that and not something else.

## Template

```markdown
---
status: draft
sources:
  - <a path worth starting from>
  - <another>
---

# type(scope): summary

## Problem

What is wrong or missing now, from the perspective of whoever feels it.
State the problem, not a solution wearing a problem's clothes — "we have
no caching layer" is a solution; "the dashboard takes nine seconds to
load" is a problem.

## Goal

What becomes true when this is done. One or two sentences.

## Constraints

What the solution has to live within, and that a reader would not guess:
compatibility promises, latency or cost budgets, data that cannot move,
deadlines that shape the approach. Not preferences.

## Architecture

The shape of the solution in this repository's vocabulary — the modules
involved, the seams between them, what crosses each seam. Enough that a
reader can picture it, not enough to be a substitute for reading code.

## Approach

How the work gets done, and in what order. Where the risky part is, and
what is done first to find out whether it is really risky.

Name the options that were considered and rejected, with the reason.
Otherwise the first reviewer proposes one of them again.

## Acceptance criteria

- Checkable statements about observable behaviour, by someone who did
  not write the code.
- The same standard as a ticket's, at the scope of the whole change.

## Risks

What could go wrong, how likely, and how you would find out early.
A risk with no detection plan is a wish.

## Out of scope

What this deliberately does not do. The explicit no-s stop the scope
creeping back in during review.
```

## The index

`map.md` beside the specs, generated from the fields above — one row per spec, in name order:

```md
# Design map

| Design | Status | Sources |
| --- | --- | --- |
| [caching](caching.md) | accepted | `src/cache/` |
| [retries](retries.md) | implemented | — |
```

The status column is what makes the index answer *which of these is live* without opening one, which is the question a reader of a directory of accumulated specs asks first.

**It is generated, never hand-edited**, and the prohibition is enforced by regenerating and comparing rather than requested of whoever opens it. A spec declaring no status stops the regeneration and is named, so a row is never a second statement of the directory's contents.

The index sits beside the specs it indexes, in whichever of the two layouts this repository uses: flat in the designs directory, or one spec per effort beside the tickets it governs. **The two layouts are exclusive** — a tree holding both is refused rather than having one silently preferred, because preferring one drops every row of the other and reports it as a stale index.

## Rules

- **`sources` is a list, one entry per line.** An entry may carry a section reference or a range alongside its path, and those contain commas — in YAML's inline `[a, b]` form the comma would split one pointer into two, silently.
- **A spec with nothing to point at declares `sources: []`**, rather than leaving the field out. Absent and empty are the same fact, and only one of them can be told apart from a spec that lost its sources.
- **No file paths outside the `sources` field, and no code.** Both go stale, and inside a spec they read as commitments. The exception is a snippet from a prototype that encodes a decision more precisely than prose can — a state machine, a reducer, a schema, a type shape. Inline it, say it came from a prototype, trim it to the decision-rich part.
- **Use the repository's vocabulary.** Terms come from `.claude/contexts/repository.md` and the Domain Contexts the work touches. A spec that invents its own words for existing concepts forces every reader to translate.
- **A section with nothing to say gets deleted, not padded.** Filler trains the reader to skim, and the sections that matter are the casualty.
- **The spec is not the decision record.** When the grill produced something that passes the 3-of-3 test, it becomes an ADR in `.claude/decisions/` and the spec links to it. A spec is superseded by the next spec; an ADR is not.

## Status

`draft` while the grill is still running, `accepted` when the user approves it and the tickets are cut, `implemented` when a commit completes the last acceptance criterion, `superseded by <path>` when a later spec replaces it, `abandoned` when the work is dropped. A spec that shipped stays on disk — it is the record of why the tickets looked like that.

**Only the status field ever moves.** The reasoning is frozen the moment the spec is accepted: a spec edited afterwards to match what shipped stops being evidence of what was intended, which is the only thing it was kept for. Correct a spec by superseding it, never by rewriting it.

`implemented` is the one status set outside conversation — `/commit` writes it, because only the last commit of a change knows every criterion is met.

It is a field rather than a line because a stage writes it, and a stage that writes by matching running text breaks the first time somebody reflows the paragraph around it — the same reason contexts and decisions declare theirs.

## A spec written after its effort landed

An effort that landed with no spec produces no row in the generated index, and the generation succeeds — so the index spans fewer efforts than exist and nothing reports it. Closing that gap means writing a spec for work already done, and such a spec is **reconstruction, not record**.

It declares `reconstructed: true`, and says so in its opening lines where a reader who never looks at frontmatter will see it. **Both, because they answer different readers**: the field is what an assertion acts on, and the prose is what the person who opened the file sees. Either one alone leaves the other reader with a reconstruction that looks like a contemporaneous spec, which is worse than the missing row — it invites decisions to be traced to reasoning nobody had.

**Derive every statement from the effort's own resolved tickets, the Decisions it produced, and what is in the tree.** Where reasoning is not recoverable from those, say so rather than supplying one; a section whose content is genuinely unrecoverable is kept and marked, which is the one place the delete-an-empty-section rule above does not apply, because *absent* and *unrecoverable* are different facts and only the second needs stating.

The frozen-reasoning rule still holds from the moment it is written: a reconstruction is corrected by superseding it, never by rewriting.
