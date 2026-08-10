---
owner: repository
status: implemented
sources:
  - skills/
  - agents/
  - scripts/verify.ps1
  - .claude/protocol.md
  - .claude/evidence/research/2026-08-05-frontmatter-extension-points-for-skills-and-agents.md
---

# refactor(skills): declare AEP's own facts as fields, not prose

## Problem

Two facts AEP's own machinery reads off a shipped skill — the reasoning posture it runs under, and the guides it declares — are written as prose lines in the skill body. A third, the same posture on a dispatched role, is written as a bare frontmatter key that the harness's own reference does not list.

Nothing reads any of them structurally. The suite recovers them with regular expressions over running text, and the file carrying those expressions already documents the failure in a comment beside a different one: a literal-space match survives only until somebody reflows the paragraph. The same fact is therefore declared in three shapes across two shipped surfaces, and the mechanism that keeps them consistent is an audit rather than a property.

The evidence directory has a related but distinct gap: its findings are surfaced either by a hand-written line on a live effort's map, or by a design run reading the whole directory. An accepted Decision records the consequence plainly — a finding can sit unread.

## Goal

Every fact AEP's own tooling reads off something it ships is declared in one machine-readable place, under the namespace the harness sanctions for exactly that purpose; and the evidence kind that has no index gains one on the mechanism the other knowledge families already use.

## Constraints

- The harness accepts a **closed set** of skill frontmatter fields and one free-form map for third-party data. A field outside that set is outside the contract, whatever it appears to do today. The map is dropped silently when its value is not a map, and its keys must not collide with the reserved field names — one of which this repository already uses, for a different purpose, on its rules.
- The dispatched-role surface has **no documented equivalent**. AEP already depends on that gap and this work does not remove the dependency; it consolidates it.
- **Nothing committed may assume the plugin is installed.** In every repository but this one the shipped skills are absent from the tree, which is why the router's stage table stays a committed artefact rather than becoming something derived at read time.
- The workflow's templates change **before** this repository adopts the result, so a configured repository and this one never hold two versions of the format.
- A change that adds a checkable claim and no assertion is untested by construction — there is no test runner here besides the suite.

## Architecture

Three surfaces, one rule: **a fact something acts on is a declared field; a fact only a human reads stays prose.**

The shipped skills and the dispatched roles both carry AEP's facts under the harness's free-form map. That map is the seam — on one side the harness, which ignores its contents by documented promise; on the other AEP's own readers, which are the configuration stage and the suite.

The router's stage table does **not** move. An accepted Decision already settled that it has two homes with declared precedence — the skill's line is the workflow's default, the table is this repository's actual set — and already assigns the configuration stage a derivation from the former to the latter. This work changes what that derivation consumes, from prose to a field. Ownership, precedence, and the committed-artefact guarantee are untouched.

The knowledge-adjacent families gain the same treatment, reusing the mechanism accepted for the two that already have an index: a table produced from what the indexed files declare cannot disagree with its directory, which is why it replaces an audit obligation rather than adding to one.

Specs are the clearest of them, because one of their prose lines is already machine-written — the commit stage moves a spec's status when the last acceptance criterion lands, by matching running text. Evidence is the widest: five kinds, one governing sentence — *read the directory before producing more* — and therefore **one** index at the family root rather than one beneath each kind (ADR 0056). That width is what makes a declared kind load-bearing here: a field restates the path only while the index is scoped to that path, and widening the index turns the same field into the column that makes it readable.

Tickets take the same treatment on one tracker form only. Their title, status, edges, and effort are all machine-read — the title is the commit subject and the branch name, the edges are what the frontier computation consumes — so on a local-markdown tracker they become fields and the heading is dropped. On a shared forge nothing moves: the forge owns the lifecycle natively, and duplicating it into a body would be the second home this whole effort is organised against. The asymmetry is the design (ADR 0058), and it is the one place where the same fact legitimately takes two shapes, because the two trackers are two different owners rather than two homes for one owner.

Declaring those fields makes an index over tickets *possible* and leaves it *forbidden* — the maps policy's ban stands, for reasons recorded under Out of scope.

None of the indexes is maintained by anybody. One deterministic script produces all of them and the suite regenerates and compares, so a hand-edited or stale index fails the build (ADR 0057). That is what the existing format's never-hand-edited rule has always asserted and nothing has ever enforced.

## Approach

The posture field goes first, alone, because it is the smallest complete instance of the pattern: one fact, one map, one parser change, one assertion flipped from prose-matching to field-reading. Whatever is wrong with the shape shows up there cheaply, before twelve more files and a second surface are committed to it.

The guides field follows, on the same files and through the same parser, and is the one that touches the configuration stage's derivation.

The dispatched roles move third. They are the surface with no documented namespace, so they are sequenced after the pattern has been proven where the documentation is unambiguous — if anything about the map turns out to be wrong, it is discovered on the surface that can be checked against a reference.

The index half runs on its own line. The regenerator is built first and against the two indexes that already exist, because they are the only ones with a known-correct answer to check against — reproducing them byte-for-byte is both the acceptance test and the de-risking for everything downstream of it. The spec fields are independent of everything and gate only the designs index, which cannot be generated from fields that do not yet exist.

Rejected, with reasons, so they are not proposed again:

- **A bare top-level key on skills**, matching what the roles do today — outside the accepted set, and it would extend an undocumented dependency rather than contain it.
- **Deriving the router's table from the fields at read time** — rejected by an accepted Decision on a fact outside the session: a teammate without the plugin would have no committed answer to what a stage reads.
- **An index beneath each evidence kind** — it multiplies the read an index exists to remove, and leaves the cross-kind question answerable only by reading all five. A declared kind would be sediment under that shape and is load-bearing under the one chosen; ADR 0056 has the distinction.
- **A declared kind, type, or subject on families nothing routes to** — the policy, mode, and tool guides are reached by pointer from a known path, nobody asks a question spanning them, and unread fields rot in the direction nothing catches.
- **A sub-agent role, or a harness hook, maintaining the indexes** — deterministic work has the wrong executor in a model, and a hook rewrites files mid-session while living outside what AEP ships. ADR 0057 has both rejections.
- **Leaving the facts as prose and hardening the expressions** — it treats a format problem as a matching problem, and the next reflow reopens it.

## Acceptance criteria

- No shipped skill or dispatched role states its posture or its guides anywhere but under the sanctioned map; the suite fails if one does.
- The suite reads both facts as fields rather than by matching running text, and fails when the map is present but not a map.
- No key inside the map collides with a name the harness reserves.
- The router's stage table remains committed, and the configuration stage still derives it — a guide named by a skill's default and absent from that stage's row still fails the build unless the row records the omission deliberately.
- The workflow's templates carry the format before this repository's own copies do.
- A spec declares its status and its sources as fields, and the commit stage sets the status field rather than rewriting a line.
- One script produces every index; running it over an unchanged tree twice yields identical output, and running it against the two indexes that already exist reproduces them byte-for-byte.
- The suite fails when any committed index differs from what regeneration produces, and the assertion is confirmed against a deliberate hand-edit before it is trusted.
- Every waiting finding in evidence appears in one index spanning all five kinds; a file that declares no fields cannot appear in a regeneration.
- Designs are indexed by the same mechanism, exercised in a tree where that directory is flat rather than partitioned by effort.
- On a local-markdown tracker, no ticket states its title, status, edges, or type as anything but a field, and every existing file is converted by a verified script rather than by hand.
- The shared-forge ticket form is provably unchanged, and the suite fails if the tickets policy describes frontmatter on one.
- The specification is amended in the same change as the Decisions it follows.

## Risks

- **The free-form map is dropped where it is malformed, silently.** Detection: an assertion on the shape, not only on the presence — written to fail against a deliberate scalar before it is trusted.
- **The dispatched-role surface is undocumented and could tighten in a future harness version.** Detection: the roles fail to load at all, which is loud rather than silent; the Decision records where to look.
- **A guard written from the new wording matches only the new wording**, leaving an old prose line elsewhere unseen. This repository's own rule names this as the recurring failure and requires confirming the guard fails against a deliberate reintroduction. Detection: do that, per ticket.
- **The evidence index could become a second home** for what a live effort's map already carries as a task line. Mitigation: the two answer different questions — repository-wide inventory versus this effort's live checklist — and the ticket states which, or the index is not built.

## Out of scope

- Any declared field on the policy, mode, or tool guides. They are reached by pointer from a known path; nothing routes to them and nothing would read a field.
- Frontmatter on the always-on rules. That tier is charged to every turn and holds a measured ceiling.
- **Any change to the shared-forge ticket form.** A forge owns the lifecycle and the edges natively; frontmatter there would be a second home for what the forge already knows, and would render as noise in its issue UI. The asymmetry between the two tracker forms is deliberate and recorded in ADR 0058.
- **Indexing tickets, and the contradiction that leaves standing.** The maps policy forbids listing open tickets because such a list goes stale — the exact ground ADR 0053 dissolved for generated files. The contradiction is real, it is recorded here rather than resolved quietly, and reopening it is its own Decision. The frontier computation that reads every ticket file today keeps doing so.
- Any change to what the router's stage table is, who owns it, or which home wins where the two disagree.
