---
name: research
description: Investigate a question against primary sources and write the findings as one cited file. Use when a decision depends on facts that are not in this repository — an external API's behaviour, a library's guarantees, a specification's wording.
metadata:
  mode: research
  policies: [evidence, sub-agents]
---

# Research

`/research` answers a question with **facts**, from the sources that own them. Its sibling `/prototype` answers questions about **feel** — whether a state model works, what something should look like. Facts here; feel there.

What it produces is **Evidence**: a record of what was checked and when, filed apart from Context and never inside it. `.claude/policies/evidence.md` says why that separation holds.

## 0 — Has this already been answered?

Read `.claude/evidence/research/` before starting new research. A finding whose question matches and whose assumptions still hold is the answer — cite it and move on.

Check its **verified-against line** first. A finding recorded against a version you are no longer on has not aged into being wrong, it has aged into being unknown, and it is re-run rather than trusted.

## 1 — Dispatch a subagent

The research runs in a **subagent**, for **context isolation**: twenty pages of documentation read to extract four facts would otherwise spend the parent's window on nineteen pages nobody needs again. The subagent burns its own window and returns one small cited file.

Dispatch the shipped **`researcher`** role by name rather than describing the job again at the call site. What the brief adds is the question and the paths, and what a dispatched child is bound by is `.claude/policies/sub-agents.md`'s — this stage restates none of it.

**Isolation is not the same as not waiting.** Whether the caller blocks on the answer is a separate axis, and it is the caller's — `/design` decides it at the gate, and the rule is in `/design`. Conflating the two is what turns a load-bearing question into a background one.

Say which it is when dispatching. A subagent cannot tell from the inside whether anything is waiting on it.

## 2 — Primary sources only

What counts as a primary source, what becomes of a claim that cannot be traced to one, and how a secondary source is disclosed are the **`researcher`** role's — dispatched by name, and not retyped here.

The rule against guessing an API — and a CLI counts — is in `.claude/rules/engineering.md`. It applies with full force here: research that establishes a fact by trying flags until something works has established what that build does today, not what the tool guarantees.

## 3 — Write one cited file

One question, one Markdown file, in `.claude/evidence/research/`.

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

**Record what it was verified against — version and date.** A fact about an external API is true at a version, not forever, and an undated finding cannot be aged out.

## 4 — Evidence is not knowledge

The file stays as the trail showing how a claim was earned. `/research` writes that trail and stops there.

**Never write Context directly**, and never promote a finding yourself. Both rules, and what does happen to a durable finding, are in `.claude/policies/evidence.md`.

---

Derived from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for AEP.
