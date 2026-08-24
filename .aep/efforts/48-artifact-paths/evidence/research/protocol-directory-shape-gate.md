---

---

# Question

Does the shape gate in `[[efforts/48-artifact-paths/plan]]` Repair 2 satisfy
spec requirement 4, that a stray is recognised by shape and never by directory
name alone?

# Sources

- `[[efforts/48-artifact-paths/spec]]`, requirement 4 and the constraint "The
  stray check must not fire on a consuming repository's own files", read
  2026-08-24.
- `[[efforts/48-artifact-paths/plan]]`, Repair 2, "The shape gate", read
  2026-08-24.
- `src/scripts/validate.mjs` at `9b6062c`, function `strayEvidence`.
- `src/scripts/contract.mjs` at `9b6062c`, `isProtocolPath`.
- `[[agents/reviewer-correctness]]`, dispatched against the wave 1 integration
  tip, reported 2026-08-24.

# Findings

**source.** The plan fixes the gate in three arms, and states of all three:
"The gate asks a question only an AEP artifact answers yes to." Its middle arm
reads: "a root `policies/`, `skills/`, `agents/`, `templates/`, or `scripts/` is
a finding only where some file inside it satisfies `isProtocolPath` against its
path relative to that directory."

**source.** Spec requirement 4: "The stray check identifies artifacts by shape,
never by directory name alone. A consuming repository may legitimately have its
own `templates/`, `references/`, or `contexts/` at its root. Only a directory
holding AEP-shaped artifacts is a finding." The spec's constraint adds that a
false positive on install "is worse than the defect: it teaches people that the
validator is noise".

**observation.** `isProtocolPath(relative)` is `PROTOCOL_FILES.includes(relative)`.
It compares a path against the shipped manifest and reads no file content.

**observation.** The other two arms do read content. The `efforts/` arm requires
a `spec.md` whose `status:` is in `SPEC_STATUSES`. The `rules/`, `contexts/`,
`references/` arm requires frontmatter carrying a `use-when` at a legal depth.
Only the protocol-directory arm decides on a filename.

**observation.** Reproduced by the correctness reviewer against a fresh
`install.mjs --into` fixture that validated clean beforehand:

```
$ printf 'console.log("our build entrypoint");\n' > repo/scripts/index.mjs
$ node .aep/scripts/validate.mjs
54 artifacts checked, 1 failure(s):
  scripts/: sits at the repository root rather than under .aep/, and scripts/index.mjs
  is a file this release ships. ... so it belongs at .aep/scripts/. Move it there yourself
exit=1
```

It fires on a zero-byte `scripts/index.mjs`, and on a root `agents/researcher.md`
whose content is unrelated to AEP. The shipped names within reach of an ordinary
repository's root include `scripts/contract.mjs`, `scripts/validate.mjs`,
`scripts/index.mjs`, and `policies/execution.md`.

**observation.** The suite does not cover the case. The `strays` section pairs
`skills/deploy.md`, which stays silent, against `skills/plan.md`, which fires,
and never puts an ordinary `scripts/` or `policies/` at a fixture root.

**interpretation.** The implementation is faithful to the plan and to ticket
02's wording, both of which name `isProtocolPath` as the test. The defect is in
the plan rather than in the build: the gate's middle arm was specified as a name
match, and a name match cannot satisfy requirement 4.

**interpretation.** The failure lands on somebody else's install, which is the
least recoverable place for it, and the remediation it prints is actively
harmful. It instructs the reader to move their own `scripts/index.mjs` to
`.aep/scripts/index.mjs`, a protocol-owned path that the next
`install.mjs --update` overwrites.

**conclusion.** Requirement 4 is not met, and the plan's own justification for
the gate is falsified by its own middle arm. Choosing a replacement test is
design rather than implementation, so this is the return-to-plan trip-wire in
`[[policies/execution]]` rather than a defect to patch inside ticket 02.

# What this does not say

The other two arms hold. The correctness reviewer confirmed both fire-checks
pass, that nothing is moved or copied, that the reported path is
repository-relative, that the traversal depths match the specification, and that
the upgrade notice is reachable through `install.mjs --update`. The
false-positive arms that do exist go red when the gate is removed. **Repair 2 is
one arm short, not unsound.**
