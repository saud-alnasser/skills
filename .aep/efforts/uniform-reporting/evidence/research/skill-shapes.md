---

---

# Question

Does every full-form skill carry a procedure the plan's stage extraction can
read stage names out of?

# Sources

All seventeen shipped skill files under `src/skills/`, read at commit `48ce15d`
on 2026-08-17. Primary — these are the artifacts themselves, not a description
of them.

# Findings

**source** — the plan defines two shapes and nothing else: numbered stage
headings `^## (\d+) — (.+)$`, or a bolded lead on each item under `## Procedure`.
A skill matching neither is a failure, never a skip.

**observation** — the seventeen fall into four shapes, not two:

| Shape | Skills | Count |
| --- | --- | --- |
| numbered `## N — Title` headings | `implement` `review` `commit` | 3 |
| numbered list under `## Procedure` | `specify` `refine` `plan` `tasks` `research` `prototype` `survey` `prune` `install` `update` `domain` | 11 |
| numbered lists under **other** headings | `tdd` — `## The loop` and `## For a bug` | 1 |
| no numbered steps at all | `handoff` `help` | 2 |

**observation** — `handoff` is full-form by the spec's own test: before writing
the handoff it moves durable knowledge into `contexts/`, `rules/`,
`references/`, and the effort's `spec.md`. It writes to the repository.

**observation** — `tdd` carries two independent numbered lists. `## The loop` has
three items, `## For a bug` has four. Two of the latter — *Fix.*, *Watch it
pass.* — carry no bolded lead.

**observation** — `[[protocol]]` states that `tdd` and `domain` are sub-skills,
reached from inside another skill rather than started on their own. `tdd.md`
itself opens with *A sub-skill. Reached from inside `[[skills/implement]]` and
`[[skills/prototype]]`*.

**observation** — the Claude adapter under `src/adapters/claude/skills/`
publishes **all seventeen** as invocable commands, `tdd` and `domain` among
them. Checked directly; `tdd/SKILL.md` carries
`canonical: .aep/skills/tdd.md`.

**conclusion** — a sub-skill can therefore be invoked directly, and when it is,
it is the outermost skill of that turn and opens a report like any other. The
contract's *a nested entry opens no report* governs the entry, not the skill.
A `report:` value on `tdd` or `domain` describes a case that really occurs.

**interpretation** — the extraction rule was derived from the fourteen skills
that have a procedural spine and generalised to seventeen without checking the
remaining three. `help` is short-form so it needs no extraction; `handoff` and
`tdd` are full-form and it cannot serve either.

**interpretation** — for `tdd` the failure is worse than an absence. The parser
would find seven items across two lists and produce a stage sequence that is not
this skill's procedure at all — a guard passing on the wrong content, which
reads exactly like a guard passing.

**conclusion** — the plan's stage extraction does not cover two full-form
skills. The form assignment itself stands: a sub-skill invoked directly opens a
report, so its declared form is load-bearing rather than inert.

# Conclusion

Two full-form skills — `handoff` and `tdd` — cannot satisfy the acceptance
criterion that stage names extract cleanly and non-empty. The cause is not a
defect in either skill: they are shaped the way their content wants. It is that
the extraction rule was generalised from fourteen skills to seventeen.

The sub-skill question raised itself and closed itself: the adapter publishes
both as commands, so both can be the outermost skill of a turn, and the
two-value field is correct as it stands.

What remains undecided is the extraction rule, and it is not decided here. It
goes to `[[skills/plan]]`.

# Not checked

- Whether any repository-owned skill in another installation would hit the same
  gap. Only this distribution's seventeen were read.
- Whether `help`'s section structure would satisfy a short-form `Stages` slot —
  short-form emits no markers, so it was not examined closely.
