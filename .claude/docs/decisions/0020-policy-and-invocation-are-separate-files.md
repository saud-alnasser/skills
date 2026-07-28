# Policy and invocation are separate files, and version control gets its missing half

`.claude/version-control.md` is added, holding what this repository does about branches and commits: whether it uses plain git or stacked changes, its branch convention, its commit discipline, and the never-push rule. `.claude/tracker.md` keeps what it is named for and gives up branch naming.

This completes a seam the repository already had on one side. Policy files say what this repository does; `.claude/tools/` says how to type it. The tracker had both halves — a policy file and an invocation file — and version control had only the invocation half, which is why branch naming ended up squatting in the tracker file: it is a version-control fact with no version-control file to live in, and the tracker was the nearest thing that existed. The constraint travelling with it — that the branch must encode the ticket id, because the branch *is* the Claim — moves with it.

Whether the repository uses stacked changes is now stated here by `/configure` rather than probed by `/implement` at build time. It is a Context-shaped statement and is verified at use like any other, which costs the same single command the probe was running — so the fact becomes visible and reviewable instead of being rediscovered silently on every run.

## Considered Options

`version-control.md` rather than `git.md`, because the file has to state *which* version-control model applies and a file named for one of the answers prejudges its own contents; because it would otherwise sit beside a derived `.claude/tools/git.md`, which is two files with one name and different jobs — the exact confusion `0019` exists to remove; and because it generalises to a repository on something that is not git.

Writing the workflow out in `CLAUDE.md` itself was the original request and was rejected because it spends the always-on budget on something conditional, when `CLAUDE.md` pointing at a policy file is already the established pattern for Context. Renaming the tracker file to cover both was rejected as a larger rename that fuses two things worth keeping apart.

## Consequences

`CLAUDE.md` names both policy files. It previously named neither, so a teammate without the plugin had no path to the tracker configuration at all despite every skill reading it — that was a live gap, and pointing at both closes it.
