# The smell baseline

A fallback vocabulary for the Standards axis, from Fowler's _Refactoring_ ch. 3. It applies when this repository documents nothing that covers the case.

Everything about *when* to reach for it — that the repository's own standards come first and always override, and that tooling-enforced findings are skipped — is in [SKILL.md](SKILL.md) §3, which is where the sources are ranked.

One rule belongs to this list alone: **every entry is a judgement call**, reported as *possible Feature Envy*, never as a violation. Only a documented standard can be breached hard.

## The list

Each reads *what it is* → *how to fix*. Match against the diff, not against the file it landed in — a smell that predates the change is not this review's finding.

- **Mysterious Name** — a function, variable, or type whose name does not reveal what it does or holds. → Rename it. If no honest name comes, the design is murky and the naming is a symptom.
- **Duplicated Code** — the same logic shape in more than one hunk or file in the change. → Extract the shared shape; call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → Move the method onto the data it envies.
- **Data Clumps** — the same few fields or parameters keep travelling together. → A type wanting to be born. Bundle them, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → Give the concept its own small type.
- **Repeated Switches** — the same `switch` or `if`-cascade on the same type recurs across the change. → Replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → Gather what changes together into one module.
- **Divergent Change** — one file or module edited for several unrelated reasons. → Split it, so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec does not have. → Delete it. Inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller should not depend on. → Hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → Cut it; call the real target directly.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → Drop the inheritance, use composition.

---

Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for AEP.
