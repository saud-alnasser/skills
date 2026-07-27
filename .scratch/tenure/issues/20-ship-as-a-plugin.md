# feat(dist): ship tenure as a plugin, and shorten the names people type

Status: ready-for-agent
Blocked by: 16, 17, 18, 19

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
