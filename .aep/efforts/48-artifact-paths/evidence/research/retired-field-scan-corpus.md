---

---

# Question

Does the retired-field scan the plan specifies — the field with its colon,
outside fences, allowed only inside five named files — pass over the corpus it
would ship against?

# Sources

- `src/scripts/contract.mjs:20`, `RETIRED_FIELDS`, read 2026-08-26. Seven fields:
  `aep`, `date`, `kind`, `mode`, `report`, `owner`, `part-of`.
- `src/scripts/validate.mjs:82-93`, the frontmatter check that rejects them, read
  2026-08-26.
- `.aep/efforts/48-artifact-paths/plan.md`, "Repair 3 — the entrypoint's claims",
  the paragraph beginning "The retired-field scan (general)".
- `.aep/efforts/48-artifact-paths/tickets/07-retired-fields.md`, its acceptance
  criteria and its constraint "No allowlisting of `AGENTS.md`."
- The payload itself, scanned with the plan's own rule: every Markdown file under
  `src/protocol.md`, `src/policies/`, `src/skills/`, `src/agents/`,
  `src/templates/`, plus `src/seed/`, `src/adapters/`, `src/scripts/`, and
  `AGENTS.md`, matched for a retired field followed by a colon outside fenced
  blocks.

# Findings

**observation — the scan reports the corrected `AGENTS.md`.** Line 58 reads "The
`aep:` frontmatter field this used to work through was retired in 3.0.0, so an
artifact no longer carries the release it last changed in; the baseline does."
That is a hit for `aep:`, outside fences, in a file the ticket forbids
allowlisting.

**interpretation — the plan's rule and the ticket's constraint cannot both hold.**
The plan allows a hit only inside `skills/update.md`,
`skills/update/migration.md`, `scripts/contract.mjs`, `scripts/validate.mjs`, and
`specs.md`. The ticket forbids adding `AGENTS.md` to that list, because
`AGENTS.md` is the file that failed. So the sentence written by requirement 9's
own hand-correction is a finding under requirement 8's own check.

**interpretation — the rule does not distinguish the two claims it has to.**
"`aep:` is the release an artifact's content last changed in" and "the `aep:`
field was retired in 3.0.0" are the same token in the same position. One is the
defect and one is its repair, and a file-scoped allowlist can only excuse both or
neither.

**observation — ten sites in eight shipped files describe `owner:` as live.**
None is inside an allowlisted file, none mentions retirement, and each reads as
current instruction:

| Site | Says |
| --- | --- |
| `src/skills/install.md:171` | "MUST preserve every existing `owner: repository` artifact" |
| `src/skills/prune.md:74` | "Never delete a `owner: repository` artifact without the human's word" |
| `src/agents/reviewer-standards.md:37` | "whether a `owner: protocol` file was edited" |
| `src/templates/context.template.md:9` | "Contexts are always `owner: repository`" |
| `src/templates/protocol.template.md:7` | "`protocol.md` is `owner: protocol`, installed verbatim" |
| `src/templates/reference.template.md:7` | "References are always `owner: repository`" |
| `src/templates/rule.template.md:7` | "**Every rule is `owner: repository`**" |
| `src/templates/skill.template.md:8` | "A skill the repository adds is `owner: repository`" |
| `src/templates/skill.template.md:60` | "declare `owner: repository`, and link it from a rule or context" |
| `src/seed/rules/version-control.md:8` | "it is `owner: repository` so an upgrade will never overwrite it" |

**observation, corrected — the retired field is the smaller of two problems in
`skill.template.md`.** The first reading was that declaring `owner: repository`
on a skill note would fail `validate.mjs:89`, which rejects a retired field on a
protocol path. It does not: `isProtocolPath` is an exact match against the
manifest, so a file the release does not ship is not a protocol path and the
retired-field arm never reaches it. Probed, 2026-08-26, by writing
`.aep/skills/scratch-owner-probe.md` carrying `owner: repository`.

**observation — the validator rejects the template's whole premise, not its
field.** The same probe returned:

```
skills/scratch-owner-probe.md: skills/ holds only what the protocol ships, and
this release ships no such file. Repository-owned governance belongs under
rules/, orientation under contexts/, and tool operation under references/
```

A second probe at `.aep/skills/plan/scratch-note-probe.md`, a skill note rather
than a skill, returned the same failure. `git log -S` puts that check in `6f72af5`,
AEP 3 itself. So `skill.template.md` — whose `use-when` is "adding a capability
this repository wants alongside the shipped skills", whose first line says to
copy it to `.aep/skills/<name>.md`, and which says a repository may add a note
beside a shipped skill — guides the reader into three acts the validator that
shipped in the same release refuses. Both probes were removed.

**interpretation — the plan's premise that "retirement is discussed in few
places" measured the wrong thing.** It counted the places retirement is
*discussed*, which is few, and not the places a retired field is *described*,
which is ten across eight files. The scan's corpus is dirty, and the ticket's
criterion that the suite pass with the `aep:` sentence removed cannot be met
until those ten move.

**observation — the seeds hold a tenth live site, and it is the worst-placed
one.** `src/seed/rules/version-control.md:8` reads "it is `owner: repository` so
an upgrade will never overwrite it". A seed is written once into a consuming
repository and never touched again by any upgrade, so a stale claim there has no
route by which it is ever corrected.

**observation — a colon is not enough to identify a field.**
`src/seed/references/github.md:134` reads "A tracker labelled `area/api` and
`type: bug` does not want `aep:effort/x` beside them." That is a tracker label
namespace, outside fences, in backticks, and it matches `aep:` exactly as the
frontmatter field does. The plan's stated discriminator — "the token with its
colon, which is what distinguishes the field from the English word" — separates
the field from the word and does not separate it from a label prefix.

**observation — the payload scripts are a different corpus and collide.** With
`src/scripts/` in the scan, `scope.mjs` reports five hits for `kind:` and
`validate.mjs` one more, every one of them a JavaScript object key rather than a
frontmatter field. `scope.mjs` is not on the plan's allowlist; it did not exist
when the plan was written.

# Conclusion

The plan's mechanism, applied to the corpus it would ship against, reports the
one sentence requirement 9 exists to protect and cannot be made to stop without
either allowlisting the file the ticket names as the one that failed, or scoping
the rule to something narrower than the file.

Choosing what that narrower thing is — the sentence, the section, or a named
exception — is design rather than build. The ten `owner:` sites are work rather
than design: they are stale on their own terms and they move
whichever scoping is chosen.

A second discriminator is needed either way. `aep:effort/x` is a label prefix and
not a field, so the rule has to say what follows the colon as well as what
precedes it.

**Whether a repository may add a skill at all is a question for the
specification** and not for a sweep that removes a retired field's name. It is
recorded here and raised at converge.

# Not checked

- Whether any of the other five retired fields — `date`, `mode`, `report`,
  `part-of` — is described as live somewhere the colon rule does not reach, for
  instance named without its colon.
- The generated adapters under `src/adapters/`, which hold no hit. They are
  derived from each artifact's heading and `use-when`, so nothing there would
  carry a field name unless a heading did.
- `specs.md` beyond confirming it holds retirement tables at §30 and §32. It is
  the specification rather than shipped text, so whether it is scanned at all
  depends on the same scoping question.
