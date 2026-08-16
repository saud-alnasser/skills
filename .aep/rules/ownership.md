---
aep: 2.1.1
owner: protocol
date: 2026-08-17
kind: rule
use-when: "about to change, upgrade, prune, or install anything under .aep/"
---

# Rule — ownership

Every AEP artifact declares `owner:`, and the owner is read off that field —
**never inferred from a directory**. A directory tells you where a file sits; the
field tells you whose it is, and the two diverge the moment a repository adds a
rule beside a shipped one.

## `owner: protocol`

The artifact defines AEP itself.

- **MUST NOT be edited in a repository.** Not improved, not healed, not
  corrected in passing.
- Installed verbatim from the release; replaced or migrated by an upgrade.
- Its `aep:` field is the release it ships in, and **every release stamps every
  protocol-owned artifact** — not only the ones it changed. An upgrade compares
  that field against the release the tree declares; a stamp that disagrees means
  the file did not come from this release.
- A protocol-owned file that differs from its release is a **defect to
  reinstall**, never drift to heal. *Why: healing it locally makes the next
  upgrade a merge conflict against a file nobody agreed to fork.*

## `owner: repository`

The artifact describes this repository.

- Evolve it freely. It is yours.
- **An upgrade MUST preserve it** and MUST NEVER silently overwrite
  repository-owned governance.

## When the protocol does not fit

Variation enters a protocol-owned artifact only through an extension point that
artifact names. Variation with nowhere to enter is a **declared deviation**:

1. Record it in a repository-owned rule under `[[rules]]`.
2. State what differs, **why**, and the release it was declared under.
3. Expect `[[skills/update]]` to report it on every run until the protocol grows
   the point or the repository conforms.

*Why the escape hatch is loud rather than absent: fixed protocol text with no
declared way to differ pressures a repository into editing it quietly, and a
silent fork is worse than a recorded disagreement.*

## Which is which

| Path | Owner |
| --- | --- |
| `protocol.md`, `modes/`, `skills/`, `agents/`, `scripts/` | `protocol` |
| `rules/` | `protocol` for the shipped set, `repository` for what you add |
| `contexts/`, `references/`, `efforts/` | `repository` |
| `index.md` | derived — regenerate with `scripts/index.mjs`, never hand-edit |

See `[[rules/artifacts]]` for the shape every artifact must have.
