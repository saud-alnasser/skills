---
name: research
description: Investigate a question against primary sources and write the findings as one cited file. Use when a decision depends on facts that are not in this repository — an external API's behaviour, a library's guarantees, a specification's wording.
---

# Research

`/research` answers a question with **facts**, from the sources that own them. Its sibling `/prototype` answers questions about **feel** — whether a state model works, what something should look like. Facts here; feel there.

What it produces is **Evidence**: a record of what was checked and when. Nothing validates it afterwards, which is why it is filed apart from Context and never inside it.

## 0 — Has this already been answered?

Read `.claude/docs/research/` before starting new research. A finding whose question matches and whose assumptions still hold is the answer — cite it and move on.

Check its **verified-against line** first. A finding recorded against a version you are no longer on has not aged into being wrong, it has aged into being unknown, and it is re-run rather than trusted.

## 1 — Dispatch a subagent

The research runs in a **subagent**. The reason is **context isolation**: reading twenty pages of documentation to extract four facts would otherwise spend the parent's window on nineteen pages nobody needs again. The subagent burns its own window and returns one small cited file.

**Isolation is not the same as not waiting.** Whether the caller blocks on the answer is a separate axis, and it is the caller's — `/design` decides it at the gate, and the rule is in `/design`. Conflating the two is what turns a load-bearing question into a background one.

Say which it is when dispatching. A subagent cannot tell from the inside whether anything is waiting on it.

## 2 — Primary sources only

A **primary source** is the thing that owns the fact: official documentation, the specification, the library's own source, a first-party API response. A blog post explaining the specification is a secondary write-up, and it is where stale and half-remembered claims enter.

Follow **every claim back to the source that owns it.** A claim that cannot be traced is not a finding — it is reported as an open question instead.

Where a secondary source is the only thing available, say so explicitly in the finding. That is a limitation of the research, not a detail to smooth over.

Reading a CLI or an API means reading its reference, not trying flags to see what happens. `tools/` covers the workflow's own tools; `.claude/tools/` covers this repository's.

## 3 — Write one cited file

One question, one Markdown file, in `.claude/docs/research/`.

```markdown
# <the question, as a question>

Verified against: <library/API> <version>, <date>
Status: <open questions, if any remain>

## Answer

The short version, in a paragraph. What someone deciding can act on.

## Findings

- <claim> — [source](url), <section or line>
- <claim> — [source](url), <section or line>

## Limitations

What was not checked, what was inferred rather than read, and any claim
resting on a secondary source.
```

**Every claim carries its citation on the same line.** A findings list with a sources section at the bottom loses the mapping, and the mapping is the part that makes it checkable.

**Record what it was verified against — version and date.** A fact about an external API is true at a version, not forever, and an undated finding cannot be aged out later because nobody can tell how old it is.

## 4 — Evidence is not knowledge

The file stays as the trail showing how a claim was earned. `/research` writes that trail and stops there.

**Never write Context directly.** A research finding copied into `.claude/context.md` puts a versioned external fact into a layer that has no version and nothing to re-verify it against — and the finding's whole value was that it said what it was true of.

What is durable does graduate out of Evidence, but that is `/design`'s step and `/design` holds the rule for it.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for Tenure.
