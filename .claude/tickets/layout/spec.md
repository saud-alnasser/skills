# refactor(layout): one lookup path for knowledge, tools, and version control

Status: implemented
Sources: `skills/configure/`, `skills/tools/`, `.claude/context.md`, `.claude/tracker.md`, `scripts/verify.ps1`

**On paths in this spec.** `SPEC-FORMAT.md` bans file paths outside `Sources:`, because a path in prose goes stale and reads as a commitment. Here the paths *are* the decision — the whole change is where a file lives and who owns it — so the trees below are inlined for the same reason a prototype's state machine is: prose cannot encode them more precisely. Everything else obeys the rule.

## Problem

Three places in a configured repository make a reader look twice, and each of them costs something different.

**A grouping level with one occupant.** `.claude/docs/` groups four artifact kinds — decisions, designs, research, prototype write-ups — of which only decisions exists in a repository that has not yet run `/design` or `/research`. So the level reads as redundant on nearly every repository, and it buries Decisions one directory below Context even though `CLAUDE.md`'s own table presents them as peers. The filesystem contradicts the model on the very first page.

**Two tiers of tool reference.** Workflow tools are documented in a shipped, model-invoked skill; the repository's own tooling is documented in `.claude/tools/`. Someone about to run a command has to know which tier owns it before they can look it up. Worse, the shipped tier only exists where the plugin is installed — so a teammate who clones the repository without Tenure has no tool reference at all, and `CLAUDE.md` currently admits this in the same sentence that forbids guessing a CLI. That is the one place the "nothing committed may assume Tenure is installed" constraint leaks.

**No home for version-control policy.** Whether the repository uses plain git or stacked changes is discovered at build time by `/implement` running a probe. Branch naming lives in the tracker configuration, which is named for the ticket tracker and describes itself as being about the tracker. There is no file that answers "how does work move from a ticket to a merged change here", so the answer is split across a skill, a probe, and a file whose name does not suggest it.

## Goal

Every instruction a configured repository needs has exactly one file to look in, that file is committed, and its name says what is in it. A teammate without the plugin can follow every rule in the repository.

## Constraints

- **`CLAUDE.md` stays under 200 lines** and must hold with or without the plugin. It is always-on, so anything added there is paid for on every turn of every session.
- **Nothing committed may assume Tenure is installed.** This is what makes the derived-tools change worth doing and also what bounds it: the derived files must be self-sufficient, not pointers into a plugin cache.
- **`skills/` is what ships; `.claude/` is what this repository runs on.** This repository is configured by Tenure, so every change lands twice — once in the shipped shape, once in this repository's adoption of it. They are separate work and separate tickets.
- **Accepted ADRs are frozen.** ADR 0006 states the layout being changed. It is superseded, not edited.
- **`scripts/verify.ps1` is the only test runner.** Every checkable claim added here needs an assertion, and the `$legacy` and `$rulePattern` tables have to move with the change or they will pass while asserting nothing.

## Architecture

### The tree

```
before                          after
.claude/                        .claude/
  context.md                      context.md          } Context
  contexts/                       contexts/           }
  docs/                           decisions/          } Decisions
    decisions/                    designs/              specs
    designs/                      evidence/
    research/                       research/         } Evidence
    prototypes/                     prototypes/       }
  prototypes/                     prototypes/           throwaway code, gitignored
  tracker.md                      tracker.md            policy — tickets
  tools/                          version-control.md    policy — branches, commits
                                  tools/                invocation — how to type it
```

The `docs/` grouping dissolves into the vocabulary `.claude/context.md` already defines. **Codebase, Context, Decisions** are the three Knowledge Layers, and after this change the first two and the third sit at the same depth, so the tree states the model instead of contradicting it. **Evidence** is a defined term too — explicitly *not* a Knowledge Layer, because nothing validates it after it is written — and it earns the one remaining grouping directory precisely because it groups things that share that property.

The prototype collision resolves as a side effect. Throwaway code and its write-up currently sit at `prototypes/` and `docs/prototypes/`, one gitignored and one committed, distinguished by a level whose name says nothing about the difference. Afterwards the write-up is under `evidence/`, which is exactly what distinguishes it.

### Policy and invocation

The second and third problems have one shape between them, and it is a seam this repository already has on one side only:

```
policy — what this repository does        invocation — how to type it
.claude/tracker.md          ─────────►    .claude/tools/github.md
.claude/version-control.md  ─────────►    .claude/tools/git.md
```

The tracker row existed. The version-control row did not, which is why branch naming ended up in the tracker file: it is a version-control fact with no version-control file to live in, and the tracker was the nearest thing. Adding the missing left cell puts it where it belongs and lets the tracker file be about the tracker again.

`version-control.md` rather than `git.md` for three reasons. It has to state *whether* the repository is on plain git or a stacking tool, and a file named for one of the answers prejudges its own contents. It would otherwise sit beside a derived `tools/git.md` — two files, one name, different jobs, which is the confusion this change exists to remove. And the name generalises to a repository on something that is not git without anybody having to rename it.

### Tool references are derived, not copied

`/configure` detects which tools the repository actually uses and writes one file per tool into `.claude/tools/`, shaped for that repository. The shipped reference becomes source material for `/configure` in the same way the `CLAUDE.md` and tracker templates already are, and the model-invoked tool skill is deleted.

**Derivation filters whole entries; it never summarizes.** `/configure` decides which tools apply and which entries within them apply, but an entry it keeps is carried over intact. This is the load-bearing rule of the whole change: a tool reference's value is concentrated in gotchas — the exact column layout of a porcelain read, a verb whose name lies about what it does — and those are exactly what a rewrite smooths away. Filtering loses whole entries, which is visible; summarizing loses clauses, which is not.

A needed entry that is missing is therefore a **configuration gap**, not a licence to guess: say so, re-run `/configure` to derive it, and fall back to the tool's own documentation under the never-guess rule if it still is not there.

## Approach

Six tickets, in three pairs. Each pair is one change, shipped then adopted:

1. **Ship the layout, adopt the layout.** The shipped half moves the paths across `skills/` and `scripts/verify.ps1`, and adds the migration row that carries an existing Tenure repository across. The adopting half moves this repository's own tree.
2. **Ship the derived tool references, adopt them.** The shipped half teaches `/configure` to detect and derive, deletes the tool skill, and repoints every skill that referenced it. The adopting half derives this repository's files.
3. **Ship the version-control file, adopt it.** The shipped half adds the template, moves branch naming out of the tracker template, points `CLAUDE.md` at both policy files, and replaces `/implement`'s build-time probe with a read of the file verified at use. The adopting half writes this repository's copy.

The pairs are separable and mostly parallel; only the third depends on the second, because the policy/invocation split it describes is only true once the invocation side is a per-repository file.

**The risky part is the derivation, and it goes second rather than first** so that the layout move — which is mechanical and high-volume — is not competing with it for review attention. Derivation is where the change can silently lose information, so it wants a reviewer who is not also checking several hundred path rewrites.

### Options considered and rejected

**On the grouping level.** Flattening all four kinds to the top forces renaming the gitignored throwaway-code directory, and produces four sibling directories with no statement of how they relate. Flattening only decisions leaves the inconsistency the complaint was about, relocated. Leaving it alone was defensible — the level stops looking redundant once the other three are populated — but that argues the redundancy is temporary, not that the depth is right, and the depth is what contradicts the layers table.

**On the tool references.** Copying verbatim and re-syncing on audit was the first proposal: it keeps a diffable relationship to the shipped version. Rejected because a per-repository file should carry that repository's tooling in the same document as the workflow's, and a verbatim copy cannot. Keeping the two tiers and sharpening the pointer was rejected because it leaves the plugin-less-teammate gap open, which is the strongest single reason to make the change at all. A derived file with a pointer back to the full shipped reference was rejected because it reintroduces the second place to look.

**On the version-control home.** Writing the workflow out in `CLAUDE.md` itself was the original request and is the most direct reading of "one place to look" — rejected because it spends the always-on budget on something conditional, and because `CLAUDE.md` pointing at a policy file is the pattern already established for Context. Folding it into the tracker file and renaming that file to cover both was rejected as a larger rename that fuses two things this repository has good reason to keep apart.

## Acceptance criteria

- A repository configured by `/configure` has no `.claude/docs/` directory, and its ADRs, specs, and evidence are reachable at the three named locations.
- A repository already running Tenure on the old layout is carried across by `/configure` without an ADR losing its number or slug.
- No skill that ships references a tool file outside `.claude/tools/`, and the model-invoked tool skill does not exist.
- `/configure` writes a tool file only for tools the repository is detected to use, and every entry in a written file is identical to the shipped entry it came from or is newly derived from this repository's own manifest, scripts, or CI.
- `.claude/version-control.md` states whether the repository uses plain git or stacked changes, its branch convention, its commit discipline, and the never-push rule; the tracker file states none of them.
- `CLAUDE.md` names both policy files, and a reader with no plugin installed can reach every instruction the repository depends on from it.
- `scripts/verify.ps1` passes, with assertions covering each criterion above, and its legacy-path table rejects the pre-change paths.

## Risks

- **Derivation quietly summarizes anyway.** The rule is prose, and prose is what a model smooths. Detection: the verifier compares each derived entry against the shipped entry it names and fails on divergence, so the check is mechanical rather than a matter of the deriving run's discipline.
- **A path is missed in the rewrite.** Roughly three dozen files reference the old locations, and a missed one is a broken Source Pointer that only fires when something loads it. Detection: the legacy-path table in the verifier, extended with the pre-change paths, which turns every survivor into a build failure rather than a surprise months later.
- **`CLAUDE.md` grows past its budget.** Two more pointers is small, but this change is exactly the kind that invites "while we're here". Detection: a line-count assertion, which does not exist yet and should.
- **Cached version-control policy goes stale.** A repository that adopts a stacking tool after being configured has a file that now lies, where the build-time probe could never be wrong. Accepted deliberately: the statement is verified at use like any Context statement, and verifying it is the same one command the probe was running — so the cost is unchanged and the fact becomes visible and reviewable instead of being rediscovered silently on every run.

## Out of scope

- Renaming the tracker configuration file, or merging it with the new version-control file.
- Changing what `/implement` does once it knows which version-control model applies. Only where it learns that changes.
- Adding tool references for tools Tenure does not already ship one for.
- Any change to the throwaway-code directory's name or its gitignored status.
