# `specs.md` is the normative specification, and every change conforms to it or amends it

The framework is the **AI Engineering Protocol**, and its canonical definition lives at `specs.md` in the repository root — self-contained, written like a language specification, covering every system the framework has including the ones nothing implements yet.

The evolution rule comes with it: every change to the framework either conforms to the specification or amends it **in the same change**. Where implementation and specification disagree, the divergence is either a defect in the implementation or an evolution the document has not caught up with — a human decides which, and neither is resolved silently. Amendments are ADRs referencing the section they amend.

This gives the specification a different contract from Context. The truth hierarchy stays absolute for *knowledge* — a context describing the Codebase loses to it. The specification *prescribes*, so it does not lose automatically; it forces the decision instead.

Two earlier positions are amended. ADR 0006 put everything under `.claude/` with the root entrypoint as the only exception; `specs.md` is now the second exception, at the root deliberately, because it is the document the repository exists to implement and burying it under machinery says otherwise. And the precedence rule's line naming `.claude/tickets/tenure/spec.md` as authoritative for what is built here now points at `specs.md`; the effort specs under `.claude/tickets/` are execution plans, not the definition.

## Considered Options

**A concept map that only points** — vision and vocabulary with every rule reached by pointer — was rejected by the user. It is the drift-proof shape, but it makes the specification unreadable standalone, and the point of this document is that a reader with only it understands the whole framework. The drift risk is answered by the evolution rule and by conformance assertions in the suite (aep ticket 08), not by thinning the document.

**Housing it in `.claude/tickets/aep/`** was rejected because the specification is not effort-scoped. Efforts end; the specification is what they leave behind.

## Consequences

The specification restates rules that also live in shipped files — the deliberate cost of self-containment, and the first standing exception to single-home. The exception is bounded: shipped files remain the operative home, the specification is the definition, and a `$rulePattern` guard never treats `specs.md` as a duplicate site.

Every future effort starts from `specs.md` rather than from its own spec alone, and an effort whose work diverges from it inherits the obligation to amend it visibly.
