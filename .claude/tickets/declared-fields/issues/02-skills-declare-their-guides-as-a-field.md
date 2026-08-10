---
owner: repository
title: refactor(skills): every skill declares its guides as a field, not a body line
status: resolved
blocked-by: [01]
part-of: declared-fields
---

## Problem

Nine skills declare the guides they read as a `Policies:` prose line. ADR 0054 established that this line is *the workflow's default* and the router's stage table is *this repository's actual set*, with the table winning where they differ — and gave the configuration stage a derivation from the former to the latter.

That derivation currently consumes prose. The default and the instance already diverged once before anyone looked, which is the divergence ADR 0054 was written about.

## Outcome

Every shipped skill that names guides declares them under `metadata.policies`. The `Policies:` body line is gone. The configuration stage derives the router's stage table from that field plus whatever is local to the repository, exactly as ADR 0054 assigns it — the input changes form, the ownership does not.

The table remains a committed artefact. Nothing about this makes a repository without the plugin unable to answer what a stage reads, which is the ground ADR 0054 rejected the read-time-derivation option on.

Templates first, per ADR 0025.

## Acceptance

- No file under `skills/` contains a `Policies:` body line, and the suite fails if one returns.
- Each skill that reads guides declares them under `metadata.policies` as a YAML list.
- The suite's existing check — a guide named by a skill's default and missing from that stage's row is a build failure unless the row records the omission deliberately — still holds, reading the field.
- The router's stage table is still committed and still authored by derivation; no ticket in this effort makes it generated at read time.
- The guard is confirmed to fail against a deliberate reintroduction of the old prose line.
- `specs.md` §11 is amended in the same change: *"Dependency declarations are prose lines in the skill body"* is exactly what this ticket falsifies, and ADR 0055's Consequences require the specification to move with it (ADR 0029). Routed here by `/review` during ticket 01, which found the statement while checking whether ticket 01 had already falsified it — it had not.

## Comments

**The conversion preceded the guard here, inverting ticket 01's order.** Ticket 01 was driven red-first: the assertion failed against the tree before a file moved. This one converted first, on a mistaken reading that nothing parsed the old form — `streamline/06` parses it in six places, and the run found out by breaking all of them. The guarantee red-first buys was recovered the way `.claude/rules/skills.md` actually specifies it, by confirming each guard fires against a deliberate reintroduction: a prose `Policies:` line, a guide named that does not ship, and prose smuggled into the field. Each fired, and the tree was restored exactly after each. Recorded because the order is the part that was wrong, not the outcome.

**A CRLF bug in ticket 01's parse surfaced here and is fixed at the root.** `configure/SKILL.md` was normalised to CRLF between the two tickets, and `[ \t]*$` cannot consume the `\r` that sits before the newline — so the mode read as absent on that one file. Tolerating it pattern by pattern would leave the next pattern that forgot to fail only on CRLF input, so carriage returns are now stripped once, where the metadata block is extracted.

**Three shape decisions this ticket had to make, none of them in the plan:**

- **Bare guide names, not paths.** `policies: [tickets, specs]` resolves against the policies directory. Paths would repeat a prefix on every entry and put a second spelling of each guide's location in the tree.
- **`["*"]` for `/configure`.** ADR 0054 already exempts it — its row is the whole directory rather than a list. The quotes are not style: a bare `*` opens a YAML alias, so this is the only spelling a parser survives.
- **The exception's *reason* moved to the body.** It used to ride the prose line, which no longer exists. A field carries what something acts on; a justification is read by people, so it stays prose — the assertion now checks the wildcard in the field and the reason in the body, separately.

**A fourth shape decision was made and initially went unrecorded:** `streamline/06`'s *"a declaration points and does not summarise"* changed the property it tests, from a 120-character bound on leftover prose to a shape check on the field. The old measurement has nothing to measure once the value is a list, so the successor asks instead that the field stayed a bare-name list. It admits a lowercase prose run in brackets, which the shipped-guide assertion then rejects token by token — the property survives across the pair rather than in one assertion.

**What `/review` found, and what happened to it:**

- **A duplicate assertion defended by a false comment — deleted.** The new block's second assertion re-tested what `streamline/06` already covers, and the comment justifying it claimed the existing check was a six-stage equality loop. It is not: `Get-SkillFiles` recurses every `.md` under `skills/`, so the existing check was a strict superset of the new one. Both axes found this independently. A comment that states a *why* which is false on fact is worse than none, so the assertion and its comment are gone rather than reworded.
- **The `/configure` reason-guard was written from this diff's own wording — fixed.** It matched the sentence just added, inside a single-line window that forbade the reason ever wrapping. That is the reflow fragility ADR 0055 exists to escape, reintroduced for the half of the declaration that stays prose. The window now crosses newlines.
- **`specs.md` §11 was amended inaccurately — fixed.** It said mode and dependency declarations alike are "bare guide names that resolve against the policies directory"; a mode is a posture name resolving against the modes directory. Split into the two claims, each true. The citation style was corrected to the bare `(ADR 0055)` this document uses everywhere else.
- **One unasked invariant was removed** rather than kept: a check that the wildcard is never mixed with named guides. It guards a real nonsense state that nothing else catches, but the ticket did not ask for it, and a guard added because it seemed reasonable is how a diff stops being the one that was reviewed.
