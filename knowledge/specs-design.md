---
owner: framework
type: norm
subject: specs
fires-when: stage
stages: [design]
spans:
  - a-spec-is-the-reasoning-behind-the-tickets: 8p9qa6
  - template: gzjgg2
  - sources-is-a-list-one-entry-per-line: 8mg4n0
  - a-spec-with-nothing-to-point-at-declares-an-empty-list: 4mfj76
  - no-file-paths-outside-sources-and-no-code: x7ih7w
  - use-the-repository-s-vocabulary: b0hvh1
  - a-section-with-nothing-to-say-is-deleted: gtmhv3
  - the-spec-is-not-the-decision-record: g8zo89
  - a-spec-written-after-its-effort-landed: at57r1
  - a-reconstruction-declares-itself-twice: xbtfs0
  - derive-every-statement-or-say-it-is-unrecoverable: 48h1c2
---


# Spec Format

Standard and above. **Where a spec is written differs per repository, and the tracker record declares which** — read the path there rather than assuming one.

## A spec is the reasoning behind the tickets

**A spec is the reasoning behind the tickets** — the thing that lets someone judge whether the tickets are the right ones. Tickets say what to build; the spec says why that and not something else.

## Template

```markdown
---
owner: repository
type: spec
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

## `sources` is a list, one entry per line

- **`sources` is a list, one entry per line.** An entry may carry a section reference or a range alongside its path, and those contain commas — in YAML's inline `[a, b]` form the comma would split one pointer into two, silently.

## A spec with nothing to point at declares an empty list

- **A spec with nothing to point at declares `sources: []`**, rather than leaving the field out. Absent and empty are the same fact, and only one of them can be told apart from a spec that lost its sources.

## No file paths outside `sources`, and no code

- **No file paths outside the `sources` field, and no code.** Both go stale, and inside a spec they read as commitments. The exception is a snippet from a prototype that encodes a decision more precisely than prose can — a state machine, a reducer, a schema, a type shape. Inline it, say it came from a prototype, trim it to the decision-rich part.

## Use the repository's vocabulary

- **Use the repository's vocabulary.** Terms come from the cross-domain Context record and the Domain Contexts the work touches; a spec that invents its own words for existing concepts forces every reader to translate.

## A section with nothing to say is deleted

- **A section with nothing to say gets deleted, not padded.** Filler trains the reader to skim, and the sections that matter are the casualty.

## The spec is not the decision record

- **The spec is not the decision record.** When the grill produced something that passes the 3-of-3 test, it becomes an ADR — a `decision` record in the store — and the spec links to it. A spec is superseded by the next spec; an ADR is not.

## A spec written after its effort landed

An effort that landed with no spec leaves nothing behind saying so — the store holds one fewer record than there were efforts, and nothing reports it. Closing that gap means writing a spec for work already done, and such a spec is **reconstruction, not record**.

## A reconstruction declares itself twice

- **It declares `reconstructed: true`, and says so in its opening lines** where a reader who never looks at frontmatter will see it. Both, because they answer different readers: the field is what an assertion acts on, and the prose is what the person who opened the file sees — either one alone leaves the other reader with a reconstruction that looks like a contemporaneous spec.

## Derive every statement, or say it is unrecoverable

- **Derive every statement from the effort's own resolved tickets, the Decisions it produced, and what is in the tree** — and where reasoning is not recoverable from those, say so rather than supplying one. A section whose content is genuinely unrecoverable is kept and marked, the one place the delete-an-empty-section rule above does not apply, because *absent* and *unrecoverable* are different facts and only the second needs stating.
