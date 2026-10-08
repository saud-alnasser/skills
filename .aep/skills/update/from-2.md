---
use-when: "upgrading a tree whose artifacts under .aep/ still carry owner:, once the update procedure has run"
---

# Update — coming from 2.x

Run after `[[skills/update]]`'s procedure. The installer has replaced the
protocol files, reported every directory this release stopped shipping, and
printed two lists it did not act on: artifacts still carrying retired
frontmatter, and effort specs still holding an architecture section.

This note goes when no repository the maintainer knows of carries a 2.x layout.

## The frontmatter

Every retired field is **dropped, never converted**; its answer lives elsewhere:

| The 2.x field | Where its answer is now |
| --- | --- |
| `owner:` | the manifest, and the directory lists it is built from |
| `kind:` | the directory the artifact sits in |
| `mode:`, `report:` | the posture each skill states for itself |
| `aep:`, `date:` | `protocol.md`'s `version:` |
| `part-of:` | the effort directory the ticket is filed under |

`use-when` carries unchanged, and `status:` and `blocked-by:` on a ticket.
**Nothing else survives**; a block of only retired fields is removed entirely.
Do this to every file the installer listed, and to no other.

## The specs

`spec.md` holds WHAT and WHY, `plan.md` holds HOW (`[[skills/plan]]`). For each
spec the installer named:

1. move the architecture section into a `plan.md` beside it, **verbatim**;
2. leave the rest of `spec.md` exactly as it stands;
3. **change no wording in either file**: a split is a move.

An empty section, or one line pointing elsewhere, is still split.

## The tracker

Only where `tracker:` is on. Otherwise say the section was skipped and why.
The frontmatter and the specs halves run in full either way.

**A landed effort is a record**: its issues, pull request, and comments are
never reshaped. Read which efforts are in flight from the tracker, and touch
only those.

| The 2.x object | Do |
| --- | --- |
| an in-flight effort's per-task issues | collapse into **one** issue for the effort, and one pull request (`[[policies/tracker]]`) |
| an in-flight effort's labels | re-sync to the projection in `[[policies/tracker]]` |
| a milestone **entirely AEP's** | delete |
| a milestone anything else uses | leave, and say so |
| **any label** | **keep**, even where AEP created it |
| a landed effort's anything | **nothing** |

**Show every tracker write as the exact string it will be** (titles, bodies,
label names, deletions) as one list, before the first is made. Then ask. **On a
refusal, write nothing**, not even the uncontroversial subset.

## Done when

No artifact under `.aep/` carries a retired field, no effort spec holds an
architecture section, every tracker write was shown before it was made, and
every landed effort is byte-identical to what it was.
