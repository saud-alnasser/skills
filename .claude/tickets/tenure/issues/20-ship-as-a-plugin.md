---
title: feat(dist): ship tenure as a plugin, and shorten the names people type
status: resolved
blocked-by: [16, 17, 18, 19]
---

## Problem

Tenure has no distribution form. Ticket 11 assumes the skills are copied into the user's personal skills directory, which loads them in every project — but the requirement is personal *and* per-project: enabled where chosen, absent elsewhere.

Only one install scope expresses that, and it installs from a marketplace this repository does not publish. Plugin skills are also namespaced, which changes what a good skill name is — and makes decision 13's reason obsolete, since the collision it avoided was with a built-in command that a namespace does not shadow.

ADR 0015 decides it. This ticket goes last because the renames touch every file the other four edit.

## Outcome

This repository publishes itself as a plugin marketplace, and Tenure installs at the scope that is per-project and per-person, recorded in a file that is not committed — which makes enabling Tenure in a project an instance of Position.

Skill names follow one stated rule: **short names are for the keyboard, descriptive names are for the model.** A skill the user types wants one word, because the namespace prefix is already there. A skill only Claude invokes keeps an expressive name, because the name is part of how it gets selected and shortening it trades accuracy for brevity nobody types. The rule is written down, not just applied, or the next skill added gets shortened for consistency and loses the signal that selects it.

Three renames follow, each forced by a real problem: the router, which cannot repeat the plugin's own name; review, whose original name avoided a collision that no longer exists; and the architecture survey, whose one-word name comes straight from its own description.

Every cross-reference moves with them — skills, templates, the router's own listing, and the verification suite.

Nothing committed to a repository may assume a Tenure command exists, because a teammate may not have the plugin. What a repository keeps is knowledge that is useful either way.

## Acceptance

- Tenure can be enabled in one project and be absent in another, without copying the framework into either.
- The record of that choice is not committed.
- Every user-invoked skill is one word; every model-invoked skill keeps a name that describes when to use it; and the rule saying so is findable.
- No skill's old name survives anywhere — including in prose, pointers, and assertions.
- A repository configured by Tenure remains useful to a Claude that does not have the plugin.
- The superseded decision records what replaced it rather than being edited to look as though it never said otherwise.

## Comments

**The repository root is both the marketplace and the plugin.**
`.claude-plugin/marketplace.json` lists one plugin with `"source": "./"`, and
`.claude-plugin/plugin.json` sits beside it — the plugin's `skills/` is already
where a plugin's skills are loaded from, so nothing had to move. Neither
manifest carries a `version`, so every commit counts as a new version, which is
right for a framework still being built; pin one when it stabilises.

**Verified against the docs before writing either file**: required marketplace
fields are `name`, `owner` (with `owner.name`) and `plugins[]`, each entry
needing `name` and `source`; `local` scope is `.claude/settings.local.json` and
is gitignored; plugin skills live in `skills/` at the plugin root; and the
plugin's `name` is what namespaces its components. `settings.local.json` was
added to `.claude/.gitignore` through the Position category ticket 16
established, not as a fourth argued-for exception — which is what the category
exists to make possible.

**Judgement call: the skills keep the short command forms in prose.** ADR 0015
notes that plugin commands become `/tenure:<name>`, and the router now says so
once, at the top, and uses `/tenure:` in the install steps. Rewriting every
internal cross-reference to `/tenure:design` was not done: no acceptance
criterion asks for it, it would add a prefix to several hundred lines that only
skills read, and criterion 5 — a repository stays useful without the plugin —
argues against sprinkling namespaced commands through committed prose. Flagging
it because it is a defensible call rather than an obvious one.

**`review` is model-invoked and one word, which reads like a breach of the
naming rule and is not.** The rule bans shortening *for brevity*; `code-review`
was not long, it was disambiguated, and the namespace removed the collision the
prefix existed to avoid. That distinction is written into the rule itself,
because without it the next reader either "fixes" the name or shortens a
primitive to match.

**Two assertions caught prose I had written myself.** The old-name sweep
covers `CLAUDE.md`, `CONTEXT.md` and `README.md` as well as every shipped file,
and it fired twice on my own text — once on the naming rule's worked example,
once on a rename record in the status section. Both were reworded rather than
exempted: the historical record belongs in ADR 0015 and the spec, which the
sweep deliberately does not cover, and an exemption would have been a hole in
the one check that stops a rename half-landing.

**A blanket substitution over `verify.ps1` mangled one sentence in
`CLAUDE.md`** — "Review ships as `/review`, not `/review`" — which the suite
could not catch, because it says nothing about that file's prose. Found by
reading the diff. Worth recording as the limit of the mechanical sweep.

**Ticket 11 is now unblocked**, and its remit is what its own comments say
survives: remove the mattpocock skills, decide on `teach` and `find-skills`,
trim the global `CLAUDE.md`, back up first, and count the context load.

**Both review sub-agents died on a session limit**, as they did in tickets 09
and 14. Both axes were run inline instead. The Standards pass was an `_Avoid_`
sweep of every added line against all of `CONTEXT.md`'s lists (two hits, both
pre-existing text in a different sense — *reconciliation* used to negate the
concept, *lock* about a seam) plus a duplication sweep of added prose against
the existing skills. The Spec pass walked every acceptance bullet of all five
tickets and every `## Consequences` section of the five ADRs.

**The Spec pass found an invented fact, which is the rule this framework exists
to enforce.** `git remote -v` is empty — this repository has no remote — and
the README told the reader to run `/plugin marketplace add saud-alnasser/skills`
while `plugin.json` claimed a `homepage` on GitHub. Both were guesses that
looked like knowledge. The README now uses the local-path form, which is what
works today, and names the shorthand as an alternative for once a remote exists;
the `homepage` field is gone.

**The Standards pass found two restatements.** `/commit`'s stacked row repeated
`gt submit`'s missing flags, which `tools/graphite.md` owns — replaced with the
consequence rather than the flag list. And `tenure.template.md` called Position
"a cache", which is on Position's own `_Avoid_` list in `CONTEXT.md`.

**One criterion was only half asserted.** "Every model-invoked skill keeps a
name that describes when to use it" is a judgement call and is not mechanically
checkable. What is checkable is what the rule protects — a model-invoked skill
is chosen by its description — so the suite now asserts every model-invoked
skill's description carries a selection clause (`Use when` / `Use before` / …).
The name half stays judgement, and this comment is where that is recorded.

**A mutation survived the first pass**: renaming the plugin to `Tenure` did not
fail, because PowerShell's `-ne` and `-contains` are case-insensitive. The
namespace is a literal string in every command a user types, so both comparisons
are now `-cne` / `-ccontains`. Five mutations run in total; the other four were
caught first time.
