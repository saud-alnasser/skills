---
use-when: "building a ticket in effort 60, or deciding where a piece of the controlled register goes"
---

# Architecture

The law goes in `[[policies/reporting]]`, which loads on every turn. The craft
goes in a new sub-skill, `.aep/skills/plain.md`, which loads only when its occasion
fires. This is the split `[[skills/prose]]` already uses for public text.

```
  every turn (hot path)                         only when needed
  ╭───────────────────────────────────╮  link  ╭───────────────────────────────╮
  │ policies/reporting.md             │ ─────► │ skills/plain.md   (new)       │
  │  who reads it: 3 registers        │        │  worked pairs, sketch styles, │
  │  how controlled text reads: core  │        │  option-set template, a brief │
  │  sketches and option sets: MUSTs  │        │  and a return, a turn report  │
  ╰───────────────▲───────────────────╯        ╰───────────────────────────────╯
                  │ link, one line each
  ╭───────────────┴───────────────────────────────────────────────────────────╮
  │ refine, plan, specify, install, update, tracker, parallel, dispatch,      │
  │ protocol, the four agents                                                 │
  ╰───────────────────────────────────────────────────────────────────────────╯
```

Chosen by the human on 2026-10-25, from three approaches:

| | Why it lost |
| --- | --- |
| **C. A sub-policy, `policies/reporting/register.md`, with core and craft** | Examples inside a policy break the law and craft split (`specs.md` §35.12), and the whole file loads on every turn: about 600 words more on the hot path |
| **D. Everything in `policies/reporting.md`** | The policy budget (800) and the hot path (4000) both go far over, and every turn pays for examples it rarely uses |
| **B. A note under an existing skill** | Rejected before the vote: a note is the depth of one skill's branch (`specs.md` §15.1), and no skill owns session text |

The name `plain` pairs with `prose`. "STE" is not used as a name: ASD owns it as
a trade mark (`evidence/research/ste100-licence.md`).

# Components

| File | Becomes responsible for |
| --- | --- |
| `src/policies/reporting.md` | the reader test with three registers (spec R1); the core of the controlled register (spec R3, R4); the sketch rule (R6); the option-set rule and the picker fallback (R7, R8). One home for each |
| `src/skills/plain.md` (new) | the craft only: worked pairs, sketch patterns, the option-set template in both forms, one brief, one return, one turn report. It governs nothing and links to the policy for every MUST |
| `src/skills/prose.md` | unchanged catalogue; `use-when`, opening, and constraints narrowed to public text (R9) |
| `src/protocol.md` | the architecture invariant puts choices to the human as an option set, through a link. Net zero words: the file is at 1000/1000 |
| `src/skills/refine.md`, `src/skills/plan.md`, `src/skills/specify.md`, `src/skills/install.md`, `src/skills/update.md`, `src/policies/tracker.md` | each place that puts options to the human links to the option-set rule, and drops any wording that competes with it ("so the human can reply yes or b") |
| `src/policies/execution/parallel.md` | a child's question is recorded as an option set; a brief and a return take the controlled register |
| `src/skills/implement/dispatch.md` | the brief is written in the controlled register |
| `src/agents/implementer.md`, `researcher.md`, `reviewer-correctness.md`, `reviewer-standards.md` | the `## Return` section says the return takes the controlled register, linked to the policy. No agent names `[[skills/prose]]` (an existing assertion) |
| `src/skills/help.md` | one row for `.aep/skills/plain.md`; the `prose` row says public text |
| `src/scripts/contract.mjs` | `SKILLS` gains `plain`; the doc comment says eighteen |
| `src/scripts/check.mjs` | `HOT_PATH.budget` rises from 4000 to 4200, with the reason in its comment |
| `src/scripts/verify.mjs` | the assertions in Testing Strategy |
| `specs.md` | §15 (eighteen skills, four sub-skills, the `plain` row), §15.2 (four registers; the brief is no longer exempt), §28 and §31 where they say seventeen, §35.12 (rationale for the change, replacing the rationale it supersedes) |

# Interfaces

**`policies/reporting.md`, new shape.** The sections, in order:

1. `## Who reads it decides`: one table, `Reader | Register | Worked cases`, three registers (public, controlled, exempt),
   with the rows of spec R1. Then: a case on no row is settled by asking who
   reads it. The `Governed | Exempt` table goes.
2. `## How controlled text reads`: the three-step order of spec R3, the
   technical-name rule of R4, and the 20% sentence. Then one line: load
   `.aep/skills/plain.md` to draw a sketch, put an option set, or write a brief or
   a return.
3. `## Sketches and option sets`: R6, R7, and R8 as MUSTs.
4. `## The turn report`, unchanged, except that the ledger's cells take the
   controlled register instead of "reads as a person wrote it".
5. `## Not covered here`: "the agent's register" leaves the list, because the
   policy now covers it.

Target size: at most 800 words in the body (today 605). The hot path then sits
near 4110/4200.

**`skills/plain.md`, frontmatter:**

```yaml
use-when: "drawing a sketch for the developer, putting an option set to the developer, writing a brief or a return for another agent, or checking that session text reads as the controlled register"
```

Body: a posture and what it gives up (readable flatness over voice); a
procedure that applies the order from the policy; the worked material; and
constraints that say it governs nothing, ships no STE text, and names the
standard only as its source. At most 1200 words. As a stage inside another
skill it reports nothing; invoked on a text, it reports like `prose`.

**`skills/prose.md`, frontmatter:**

```yaml
use-when: "writing or editing public text: a README, a docs page, an API reference, user-interface text, a changelog, a code comment, or a docstring"
```

The pull request body leaves this list (spec R1). The body stays at most 1200
words; it is at 1200 today, so the opening is rewritten at equal length.

**New command.** The adapters render `/aep:plain` from `SKILLS`. No adapter
code changes.

# Technical Approach

Order, and the reason for each step:

1. **Policy first** (`reporting.md`, `check.mjs` budget, the verify
   assertions for the reporting section). Every other file links here, so the
   targets must exist first.
2. **`plain` next** (`contract.mjs`, the skill, `help.md`, the adapters,
   the manifest, `specs.md` §15, §28, §31). It needs the policy to link to.
3. **`prose` narrowed.** Independent of 2, but it needs 1.
4. **Option-set and register links** across the files in Components. They
   need 1, and they may cite 2.
5. **`specs.md` §15.2 and §35.12.** Last among content, because it describes
   what 1 to 4 made true.
6. **Release and reinstall**: `node src/scripts/release.mjs 4.1.0`, then
   reinstall this repository's `.aep/`. Minor, because the change adds a skill
   and changes no command a human types. Publishing stays the human's.

# Migration

An installed repository gets `skills/plain.md` and the new policy on its next
`/aep:update`; nothing it owns changes. Effort artifacts written before 4.1.0
stay as they are (spec, Out of Scope). Its own rules that cite the old
`Governed | Exempt` table still resolve, because the policy keeps its file name.

# Testing Strategy

Each check is a `verify.mjs` assertion unless it says otherwise. Each new
assertion is seen to fail once against a tree with its subject removed
(`[[rules/authoring]]`).

| Spec AC | Check |
| --- | --- |
| 1 | the policy has a `Reader \| Register \| Worked cases` table; each worked case of R1 matches in exactly one row; the old `Governed \| Exempt` header is gone |
| 2 | the three-step order (principles, vocabulary, test) appears in `policies/reporting.md` and in no other payload file; the policy links `.aep/skills/plain.md` |
| 3 | the policy says the 20% never drops a principle; `plain.md` carries a worked pair with one approved-word swap and one kept outside word, matched by their headings |
| 4 | the policy names domain and AEP terms as technical names; `plain.md` has a worked example of one |
| 5 | the existing bootstrap assertions for the four prohibitions still pass, and no new file restates them |
| 6 | the policy states characters only, fenced, Excalidraw style, and split when large; `plain.md` ships at least one sketch in a fenced block with box-drawing characters |
| 7 | each file named in Components for option sets links to the option-set section of `[[policies/reporting]]`; "reply yes or b" appears nowhere in the payload |
| 8 | the picker fallback wording appears in the policy only |
| 9 | `prose.md`'s `use-when` matches public text and does not match "pull request"; its `## The catalogue` section is byte-identical to the 4.0.0 baseline, compared from git |
| 10 | `specs.md` has no sentence that makes a sub-agent brief exempt; §35.12 has a heading for the supersession |
| 11 | `node src/scripts/verify.mjs` and `node .aep/scripts/aep.mjs check` both pass; hot path at most 4200 |

Assertions that change rather than add: the reporting section's
`Governed | Exempt` checks, "loads skills/prose only for human documents",
the ledger's "reads as a person wrote it", the skill count (seventeen to
eighteen, in `specs.md` and `verify.mjs`), and the hot-path budget (4000 to
4200). Each moves deliberately, with the reason in the assertion's comment.

# Technical Risks

- **The policy outgrows 800 words.** First sign: `aep check` reports
  `reporting.md` over budget. Remedy: move a worked case into `plain.md`, never
  a MUST.
- **The prose catalogue drifts while the opening is rewritten.** The
  byte-identical check of AC 9 catches it.
- **A file that puts options is missed.** The list in Components came from a
  search for "options", "recommend", "offer", and "asks once" on 2026-10-25. A
  later file that puts options is caught only by review, not by the suite.
- **The hot-path rise sets a precedent.** The human accepted it with approach
  A, whose description named the raised budget. The other way, splitting the
  core out of the policy, would cost a file load on every turn.
