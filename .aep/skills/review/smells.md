---
aep: 2.0.0
owner: protocol
date: 2026-08-16
kind: skill
use-when: "the Standards axis finds a design problem this repository documents no standard for"
---

# Review — the fallback smell vocabulary

The Standards axis judges a diff against **this repository's** documented
standards. This list is what it reaches for when the repository documents nothing
that covers the case — a shared vocabulary, so a real design problem is not
dropped merely because nobody wrote a rule about it.

The names are the classical refactoring catalogue, popularised by Martin Fowler's
[*Refactoring*](https://refactoring.com/). Using the standard name is the point:
it makes a finding recognisable to someone who has never read this repository.

## When this applies

**Last, and only in the gap.** `[[skills/review]]` ranks the sources: the
repository's own rules, contexts, and documented conventions come first and
override anything here. A finding a linter, formatter, or type-checker already
makes is skipped there and stays skipped here.

**One rule belongs to this list alone: every entry is a judgement call.** Report
it as *possible Feature Envy*, never as a violation — only a documented standard
can be breached outright. A reviewer that reports taste in the register of law is
why teams stop reading reviews.

**Match against the diff, not the file it landed in.** A smell that predates the
change is not this review's finding; at most it is a task.

## The list

Each reads *what it is* → *what fixes it*.

- **Mysterious Name** — a function, variable, or type whose name does not reveal
  what it does or holds. → Rename it. *If no honest name comes, the design is
  murky and the name is the symptom.*
- **Duplicated Code** — the same logic shape in more than one place in the
  change. → Extract it; call it from both.
- **Feature Envy** — a function that reaches into another object's data more than
  its own. → Move it onto the data it envies.
- **Data Clumps** — the same few fields or parameters keep travelling together. →
  A type wanting to be born. Bundle them and pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain
  concept. → Give the concept its own small type.
- **Repeated Switches** — the same branch on the same type recurs across the
  change. → Replace with polymorphism, or one table both sites read.
- **Shotgun Surgery** — one logical change forces scattered edits across many
  files. → Gather what changes together into one module.
- **Divergent Change** — one module edited for several unrelated reasons. →
  Split it, so each changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs
  the spec does not have. → Delete it. Inline back until a real need appears.
- **Message Chains** — long navigation the caller should not depend on. → Hide
  the walk behind one method on the first object.
- **Middle Man** — a type or function that mostly delegates onward. → Cut it;
  call the real target.
- **Refused Bequest** — an implementer that ignores or overrides most of what it
  inherits. → Drop the inheritance; compose.

## What this list is not

It is not a checklist to run down. Reporting every entry that technically applies
produces a review whose real findings are buried among twelve judgement calls —
which is the failure `[[skills/review]]` caps report length to prevent.
