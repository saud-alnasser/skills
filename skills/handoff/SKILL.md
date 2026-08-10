---
name: handoff
description: Compact this conversation into a handoff document a fresh agent can start from.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
metadata:
  mode: maintenance
---

# Handoff

A bridge between context windows. Write a document that lets a fresh agent continue this work, and save it to **this session's own scratchpad directory — never into the workspace, and never into a repository**. A handoff is scaffolding for one session; committed, it becomes a stale account of a repository that has since moved.

The scratchpad specifically, rather than the temporary directory as a category: the next session is handed one path to open, and *somewhere under the system temp* is not a path. Where that directory is comes from the session itself.

**Do not duplicate anything already captured elsewhere.** Reference it by path or URL instead. In a AEP repository most of what a next session needs is already on disk and already current:

| What the next session needs | Where it already is |
| --- | --- |
| What is being built, and why | the ticket, and the spec it references |
| Why the approach was chosen | `.claude/decisions/` |
| How this repository thinks | `.claude/contexts/repository.md` and its Domain Contexts |
| What has landed | the commits |
| What was verified, and against what | the marker file — `.claude/tools/git.md` names its path |

Copying any of that produces a second version that goes stale the moment the first one changes, and nothing points at the copy to update it.

What is genuinely worth writing down is the part that only exists in this conversation:

- What was tried and **rejected**, with the reason — otherwise it gets tried again.
- Decisions taken but not yet recorded anywhere.
- What is in the working tree right now and why it is unfinished.
- The thing you would warn a colleague about before they touched this.

Include a **suggested skills** section naming what the next agent should invoke, and which ticket it should be holding.

**Redact secrets** before writing — API keys, tokens, passwords, anything personally identifying. The file lands outside the repository, where none of the repository's own protections reach it.

If arguments were passed, treat them as what the next session is for, and write to that.

## End with the line that starts the next session

**The document's last section is a resume prompt, and it is not optional.** A handoff nobody can open is scaffolding that reached no one, and the next session begins with an empty context — it cannot find a file it was never told the path to.

It is the handoff's **own** absolute path, in a block the user copies verbatim into a new session and nothing more:

```
> read <the absolute path of this document>
```

One line, because the user is pasting it rather than reading it. Anything else in that block — a summary, an instruction, a reminder of what to do first — is content the document already carries, and it is being pasted into a session that is about to read the document anyway.

**Report the same path in the reply that finishes the run.** The user is looking at the conversation, not at the file, and a document that only names itself inside itself has told nobody where it is.
