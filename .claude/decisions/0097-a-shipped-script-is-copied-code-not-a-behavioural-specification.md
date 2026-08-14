---
owner: repository
status: accepted
load-when: how a repository gets an executable AEP depends on, or what language it is written in, is in question
sources: [skills/configure/SCRIPTS.md, .claude/decisions/0060-the-regenerator-is-derived-from-a-behavioural-specification.md, hooks/check-version.js]
supersedes: [0060]
superseded-by: []
---

# A shipped script is copied code, not a behavioural specification

A configured repository gets each script AEP depends on as a **copy of a JavaScript
file the plugin carries**, written once here and copied into `.claude/scripts/` under
the same name. The scripts specification stops describing behaviour for somebody to
re-implement and starts documenting code that exists.

ADR 0060 chose the opposite and rested on three supports. Two have been removed by
this framework's own decisions rather than by argument here. **Plugin independence** —
*"a teammate without AEP would have a `/commit` step naming a file they do not have"* —
is superseded by ADR 0083, which takes the plugin dependency outright. **Regenerate-and-compare**,
which 0060 named as what makes a derivation enforceable in any language, is superseded by
ADR 0090 along with the committed indexes it compared. What is left of 0060 is its third
support, the fork: a copy in every repository diverges the moment the shipped one changes,
and nothing reconciles them.

**The fork is answered rather than accepted, and 2.0 is what makes the answer available.**
ADR 0084 dissolved the byte-lock apparatus on the ground that nothing is copied any more.
A shipped script is now the one thing that *is* copied, so it is the one place that
apparatus keeps a subject — and it comes back scoped to exactly that category rather than
as a general obligation. A copy declares the release it came from, and the `SessionStart`
hook ADR 0064 already installed gains one more comparison: it holds `CLAUDE_PLUGIN_ROOT`,
which a stage's shell never does, so it is the only surface that can see both releases at
once. A stale copy says one line at session start, exactly as a stale protocol file does.

**JavaScript, and it is not a new dependency.** `hooks/check-version.js` already ships and
`hooks/hooks.json` invokes it with bare `node`, so the framework already requires a Node
runtime and already ships executable JavaScript. 0060's stated cost for shipping code —
*"it makes PowerShell a requirement of the framework rather than an implementation detail
of the repository that happens to build it"* — does not transfer to the language the
plugin was already shipping in. One language across every executable thing AEP carries is
what a second one would have to argue for.

**This deletes an obligation rather than moving one.** A derived script could be
mis-derived into something wrong-but-self-consistent that every later check agreed with,
which is why the specification carried a worked fixture per script and `/configure` had to
run each one before trusting it. A copy cannot be mis-derived. The fixtures survive as
tests of the shipped code, in this repository's own build, and `/configure` stops running
anything.

Accepted, and stated because it is the real loss: **a repository whose tooling is Python or
Go now runs a Node script.** 0060 bought polyglot fit with a per-repository re-implementation
of a byte-exact contract, and that trade was priced when the alternative was a fork nothing
could detect. With the fork detectable it is no longer worth a re-implementation per
repository.

## Consequences

`scripts/` at this repository's root becomes the **shipped** script home, copied into
`.claude/scripts/` name for name; this repository's own build moves to `build/`. Every
top-level directory then ships except that one, which is a shorter invariant than the one
it replaces.

ADR 0069 is **unaffected and load-bearing** rather than dissolved with derivation. It pins
the checkout's line ending so a script can emit it; a copy now has to compare byte-identical
against its source, so the pin matters more than it did, not less.

## Considered Options

- **Keep derivation** — rejected: two of its three supports are already superseded, and the
  third has an answer 1.x could not reach.
- **Ship the code and point into the plugin instead of copying** — rejected: the harness
  exports the plugin root to hooks and to skill content, never to a stage's shell, so a
  stage could not resolve the path it was told to run.
- **Ship code and keep the behavioural page as a second contract** — rejected as the
  closest call, on 0060's own reasoning against a reference implementation: two artefacts
  claiming to be the contract get settled by reading whichever one runs.
