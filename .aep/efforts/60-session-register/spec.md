---
status: implemented
lane: full
---

# Problem

AEP has one register for everything a human reads, and none for what an agent
reads.

`[[policies/reporting]]` sorts text by reader. A human reader makes a text
governed; a protocol agent makes it exempt, "written for that reader, never
carelessly". `[[skills/prose]]` is the craft for governed text, and its craft is
the craft of a written document: give it a voice, use *I*, vary the rhythm, let
the structure be slightly uneven. That is right for a README or a docs page that
a stranger reads once and cold. It is wrong for what a developer reads in a
session, where they scan a report mid-task, often in a second language, and need
the fact, the decision, and the next step without decoding style.

The exempt side has no register at all. A sub-agent brief, a child's return, and
a question relayed from a child to the orchestrator are "written for that
reader", which in practice means each agent writes them however it writes. The
brief is the only parent-to-child channel (`[[policies/execution/parallel]]`),
so an ambiguous sentence in it is a defect nobody can recover from.

Two further gaps sit in session output:

- **Structure is described in sentences.** A flow, a tree of surfaces, a
  before-and-after, or two options side by side reach the developer as
  paragraphs, though a text sketch would show them at a glance and costs
  no tool, image, or network call.
- **Options are presented unevenly.** `[[skills/refine]]` asks for options,
  consequences, and a recommendation "so the human can reply yes or b". Nothing
  says how each option is explained, nothing illustrates how options differ, and
  nothing uses a runtime's interactive picker where one exists, so the developer
  types a letter against a wall of text.

# Goal

Each reader gets the register built for it. Public documentation reads as a
person wrote it. Everything an agent says to the developer in a session, and
everything one agent says to another, is written in a controlled register based
on ASD-STE100 Simplified Technical English, at a stated adherence of 80%. Where
structure or a choice is being explained to the developer, a text sketch
shows it, and a choice arrives as explained options with a recommendation,
through the runtime's picker where it has one.

# Scope

- `[[policies/reporting]]`: the reader test grows from two outcomes to three
  registers, and carries the requirement for each.
- `[[skills/prose]]`: its catalogue stays as it is; its `use-when` and its
  stated reach narrow to public text.
- The controlled register: its rules, in AEP's own words, in
  `[[policies/reporting]]`, and its craft in a new sub-skill, `.aep/skills/plain.md`.
- Illustration and option presentation in developer-facing session text, and
  the skills and policies that present options or relay questions
  (`[[skills/refine]]`, `[[policies/execution/parallel]]`, and any other that
  does).
- Briefs and child returns (`[[skills/implement/dispatch]]`,
  `[[policies/execution/parallel]]`).
- `specs.md` §15, §15.2, and the rationale in §35.12, superseding the
  `readable-output` decision that a brief is exempt.
- `verify.mjs` assertions for each claim a script can check.

# Requirements

1. **Three registers, chosen by reader.** `[[policies/reporting]]` states the
   reader test with three outcomes and the worked cases for each:

   | Reader | Register | Worked cases |
   | --- | --- | --- |
   | a person outside the session, reading cold | public: `[[skills/prose]]` | a README, a docs page, an API reference, text in a user interface, a changelog |
   | the developer, in a session | controlled | all session output, the turn report, a question or an option set |
   | another agent | controlled | a brief, a child's return, a question relayed between agents |
   | an agent or a reviewer, through an effort artifact an agent writes | controlled | a new `spec.md`, `plan.md`, ticket, evidence file, or `log.md` cell |
   | an agent, through shipped protocol text | exempt, as today | `[[policies]]`, `[[skills]]`, `[[protocol]]`, `specs.md` |
   | the developer, in review | controlled | a commit message, a pull request title or body |
   | a future maintainer or a user of the code | public: `[[skills/prose]]` | a code comment, a docstring, generated API documentation |

   A commit message and a pull request body are read in review, fast, as part of
   the work; a comment and a docstring become part of the code and are read cold
   by people who were never in the session. `[[skills/prose]]` therefore loses
   the pull request body from its `use-when`. *Decided by the human, refine
   question 2.*

   An effort artifact takes the controlled register because two readers meet in
   it: the agent that runs from it, and the human who reviews it, including as
   the issue body under a tracker (`[[policies/tracker]]`). Shipped protocol text
   stays exempt: it defines the vocabulary, and rewriting it is a separate
   effort. *Decided by the human, refine question 1.*

2. **The controlled register is defined once, and its craft lives apart.** Its
   rules and the requirement to use them are stated in AEP's own words in
   `[[policies/reporting]]`, and no other shipped file restates them. The worked
   craft (examples, sketch patterns, the option-set template) lives in a new
   sub-skill, `.aep/skills/plain.md`, published as `/aep:plain`. It governs nothing
   and links to the policy for every MUST. The skill set grows from seventeen to
   eighteen. *Decided by the human at `/plan`: approach A, and the name.*

3. **80% adherence is judged, in a fixed order.** The policy states the order,
   and the agent applies it to every sentence:

   1. **The core principles first.** One topic per sentence; active voice, with
      the actor named; short sentences, with STE's 20 words for an instruction
      and 25 for a description as the target, not a hard cap; one meaning per
      word, kept for the whole text.
   2. **Then the vocabulary.** Try a word from the STE approved vocabulary of
      about 900 words first. Where a word outside it carries the meaning better,
      use that word.
   3. **Then the test.** The text is direct and easy to read, and it keeps all
      the knowledge it must carry.

   The 20% is the room to depart from strict STE where strict STE would make
   the text hard to read, lose knowledge, or limit what the agent can say. It is
   never room to drop the core principles. A reviewer judges a text by the test
   in step 3, never by counting sentences. *Decided by the human, refine
   question 3, and restated by the human after the first worked examples.*

4. **A domain term is a technical name.** A word this repository's domain
   defines, and every AEP term (`effort`, `lane`, `surface`, `claim`), is used
   as STE uses a technical name: kept exactly, never replaced by an approved
   word, and never counted against adherence.

5. **The four prohibitions hold in every register a human reads.** No em dashes,
   no curly quotes, no decorative emoji, no title-case headings, as
   `[[protocol]]` states them today.

6. **Structure shown to the developer is drawn.** Where session text explains a
   flow, a hierarchy, a sequence of states, a before-and-after, or a comparison,
   it includes a text sketch in a fenced block, drawn in the style of an
   Excalidraw sketch: boxes, arrows, labels on the arrows, and elements laid out
   in space rather than in a table. Characters only: no image, no vector, no
   rendering tool, no network call, readable in any terminal. A sketch stays
   cheap for the model, about a few hundred tokens, and a structure too large
   for that is split into smaller sketches. A turn with no such structure draws
   nothing. *Decided by the human, refine question 5.*

7. **An option set is explained, illustrated, and recommended.** Every set of
   options put to the developer gives each option a short explanation in the
   controlled register, an illustration where the options differ in structure,
   and marks one as recommended with its reason.

8. **The picker is used where the runtime has one, and the content never
   depends on it.** Where the runtime offers an interactive option picker, the
   option set goes through it. Where it does not, the agent writes the same set
   as text: a letter per option, its explanation, its illustration, the
   recommendation marked, and a closing line asking for a letter. The options,
   their words, and their order are the same either way. *Decided by the human,
   refine question 4.*

9. **`[[skills/prose]]` keeps its catalogue and narrows its reach.** Its
   `use-when`, its opening, and its constraints name public text only, and say
   that session text and agent text take the controlled register instead.

10. **The specification follows.** `specs.md` §15.2 states the three registers;
    the exemption of a brief is removed and the rationale that carried it is
    replaced, not left beside the new text; §15's description of `prose` is
    corrected.

11. **The suite moves in the same pass.** Every claim above that a script can
    check gains an assertion in `src/scripts/verify.mjs`, each confirmed to fire
    by a deliberate perturbation (`[[rules/authoring]]`).

# Acceptance Criteria

1. `[[policies/reporting]]` names three registers and lists the worked cases of
   R1 under each; no worked case appears under two.
2. `[[policies/reporting]]` is the only shipped file that states the controlled
   register's rules; a search for each rule's wording finds it there only. The
   policy links to `.aep/skills/plain.md`, which restates no MUST, and the skill set
   in `specs.md` and the suite is eighteen.
3. The policy states the order of R3 (principles, vocabulary, test) and says
   the 20% never drops a core principle. `.aep/skills/plain.md` ships a worked pair:
   one word replaced by an approved word with nothing lost, and one word outside
   the vocabulary kept because no approved word carries its meaning.
4. The policy states that domain and AEP terms are technical names, and
   `.aep/skills/plain.md` has at least one worked example.
5. The four prohibitions are stated once, in `[[protocol]]`, and apply to both
   registers a human reads.
6. The policy states when a sketch is drawn, that it is characters in a fenced
   block in Excalidraw style, and that a large structure is split;
   `.aep/skills/plain.md` ships a worked sketch.
7. `[[skills/refine]]` and every other shipped file that presents options or
   relays a question require explanation, illustration where structure differs,
   and a recommendation.
8. The picker requirement and its fallback are stated in one place and linked
   from each file of AC 7.
9. `[[skills/prose]]`'s `use-when` names public text only; its catalogue section
   is byte-identical to today's apart from cross-references.
10. `specs.md` no longer says a brief is exempt, and §35.12 carries the reason
    for the change.
11. `node src/scripts/verify.mjs` passes, and each new assertion fails when its
    subject is removed.
12. `[[skills/implement/dispatch]]`, `[[policies/execution/parallel]]`, and the
    `## Return` section of every shipped agent require the controlled register
    for a brief and a return, by a link to `[[policies/reporting]]`. Added at
    `/tasks`: R1 places briefs and returns, and no criterion checked the files
    that write them.

# Constraints

- **AEP ships no part of ASD-STE100.** The standard and its dictionary are
  ASD's copyrighted work, and AEP vendors no third-party text (`specs.md`, the
  preamble). The rules are restated in AEP's own words. The approved vocabulary
  is named as the first place to look for a word, and never reproduced.
- **Nothing assumes a runtime** (`specs.md` §15.2). A diagram is plain text for
  that reason; the picker is conditional for that reason.
- **The turn report's shape does not change.** The nine labels, their order,
  and the ledger's columns stay exactly as they are; only the words inside the
  slots take the new register.
- **A skill does not govern** (`specs.md` §15). Every MUST lives in a policy.

# Out of Scope

- Rewriting existing shipped `.aep/` text or `specs.md` into the controlled
  register. A later effort may; this one does not.
- Rewriting effort artifacts that exist before this lands.
- Any change to the catalogue of `[[skills/prose]]`.
- A dictionary check, a shipped word list, a sentence count, or any machine
  translation into STE.
- Images, vector diagrams (SVG, Excalidraw files), rendered diagrams (Mermaid,
  HTML), or any diagram that needs a tool to view. The Excalidraw style is
  borrowed for text sketches; the format is not.
- The turn report's slots, order, and the ledger format.
- A runtime-specific adapter feature beyond calling an existing picker.

# Assumptions

- The developer reading a session may read English as a second language; this
  is STE's own design target and the reason it suits session text.
- What a script prints to a person is session text, so it takes the controlled
  register.
- The agent knows the STE approved vocabulary well enough to try it first,
  because AEP cannot ship the list. If that proves false in practice, the
  vocabulary step degrades to "the simplest common word", and the principles
  still hold.
- ASD-STE100 grants no right to ship its dictionary or rule text. ASD's own
  pages state no licence, and the specification says "All rights reserved"
  (`evidence/research/ste100-licence.md`). The licence text inside Issue 9 was
  not read.

# Risks

- **Two registers blur.** An agent writing a pull request body in a session may
  not know which register applies. The worked cases are the defence; a case on
  no list is settled by the reader test.
- **Controlled text reads flat.** That is accepted for session and agent text,
  and is the reason public text keeps `[[skills/prose]]`.
- **A judged 80% drifts.** Two reviewers can disagree on "easy to read". The
  fixed order and the worked pair are the defence: a reviewer first checks the
  core principles, which are close to binary, and judges only the rest.
