---
use-when: "the repository carries a 1.x layout — a protocol file, policies, decisions, designs, or a map.md in every directory, under the runtime's own directory rather than .aep/"
---

# Update — migrating a 1.x repository

1.x kept AEP inside the runtime's own directory and selected knowledge by
stage. The running release keeps it in `.aep/` and selects by applicability. No
1.x file upgrades in place, so this is a **conversion**: install fresh, then
rewrite everything that has a representation into its shape.

## Recognise it by content

Any of these is 1.x, whatever the directory is called: a `protocol.md`, or a
`policies/`, `decisions/`, or `designs/` directory, **outside `.aep/`**; a
`map.md` in several directories; frontmatter declaring `owner: framework`. **A
bare `version:` is evidence of nothing**, and `.aep/policies/` means a current
tree.

**Confirm with the human before starting**: this rewrites where their knowledge
lives.

## The three outcomes

Every 1.x file gets exactly one, by **what it holds**, never who owned it:

- **Converted**: the release has a representation; rewrite it into that shape.
- **Superseded**: the file is framework text the release replaces; drop it.
- **Unrepresented**: the concept was retired; report it, leave it, delete
  nothing.

**`owner: framework` does not mean superseded.** 1.x put repository content
inside framework files at extension points (a declared deviation in the protocol
file, the two per-repository policies, the entrypoint's description of the
repository). That content has a home, and dropping it with its file is the
largest silent loss this operation can make.

## 0 — Inventory first, move nothing

Write down every file, its outcome, and its target before touching anything.
Read framework files too, for the extension points. **A file that fits no
outcome is a finding**: list it and ask.

## 1 — Install

```
node <distribution>/scripts/install.mjs --into <repository> --migrate
```

Without `--migrate` the installer refuses a 1.x repository. Seeds install as
usual, as drafts that step 2 overwrites with what 1.x already documented.

## 2 — Convert, and 3 — its fields

`[[skills/update/conversion]]` maps every 1.x path, and every field, to its
destination.

## 4 — Stop the old layer governing

Whatever the runtime auto-loaded in 1.x **must not still load 1.x governance**:
convert it, or move it out of the auto-loaded location. This step is not the
human's to defer. **Nothing is deleted**: once the human is satisfied,
`[[skills/prune]]` removes the rest.

## 5 — Finish, and prove it

```
node .aep/scripts/index.mjs
node .aep/scripts/validate.mjs
```

**`validate.mjs` passes with no exemption.** A converted artifact that fails it
is fixed here or reported as unconverted.

## 6 — Report

- every file with its outcome: converted (to where), superseded (by which
  shipped file), or unrepresented;
- every proposed `use-when`, as one list to confirm in a single pass;
- every deviation converted from the old protocol file, with its reason;
- every collision that stopped: two specs for one effort, evidence with no
  effort, a policy that could be a rule or already covered;
- every decision record left in place, with its judged kind;
- every repository script moved out of the old AEP directory.

**Do not commit.** It is read before it lands.

## Done when

Every 1.x file has a recorded outcome, nothing was deleted, every proposed
`use-when` is listed for confirmation, and the old layer no longer governs.
