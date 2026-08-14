---
owner: repository
kind: prototypes
falsifies: []
---

# What does a stage see when a tool result exceeds the harness cap?

Executed 2026-08-14 against `4c2b085`, on this session's own harness. Resolves item 4 of
`substrate/08`. No code was written to disk; the experiment was four tool calls and the
commands are reproduced below.

Verified against: the running Claude Code harness, 2026-08-14.
Conclusion: **Successful, and it falsifies the number the item was written around.**

## Hypothesis

`substrate/08` item 4 asks whether *"a >25,000-token result becomes a file reference, and
what does a stage see when it does"*, drawn from
`.claude/evidence/research/2026-08-13-what-a-plugin-hosted-tool-can-actually-do.md` —
which states plainly that nothing was executed. The expectation was a cap at
25,000 tokens, with truncation or a reference beyond it.

## Method

Emit outputs of controlled size from a single `Bash` call and observe what returns.
Sizes were chosen descending so that a trip costs the preview only, and each command
writes to stdout **unpiped** — an early attempt piped through `tail`, which shrank the
result before the harness saw it and tested nothing.

```
python -c "line='...'; [print(line % i) for i in range(N)]"
```

Four runs: 230.9 KB, 68.6 KB (exactly `/implement`'s measured row of 69,563 characters),
34.6 KB, and one void run through a pipe.

## Result

**Every run at 34.6 KB and above was withheld from the model.** What returns is not
truncated output — it is a different structure:

```
<persisted-output>
Output too large (230.9KB). Full output saved to: <session>/tool-results/<id>.txt

Preview (first 2KB):
<the first 2048 bytes>
...
</persisted-output>
```

| Emitted | Returned |
| --- | --- |
| 230.9 KB | `persisted-output`, 2 KB preview + path |
| 68.6 KB | `persisted-output`, 2 KB preview + path |
| 34.6 KB | `persisted-output`, 2 KB preview + path |

Three results.

**1 — The cap is bytes, not tokens, and it is roughly a third of the documented figure.**
34.6 KB is about 8,600 tokens and it trips. The item was written around 25,000 tokens,
which would be ~100 KB. The `PowerShell` tool's own description states a 30,000-character
limit, consistent with what was observed. **The floor was not bracketed** — no non-tripping
run was made — so the finding is *≤34.6 KB*, with 30,000 characters the documented and
consistent value.

**2 — A full stage row cannot be delivered as a tool result.** The 68.6 KB run was sized
to `/implement`'s row exactly, 69,563 characters as measured in
`2026-08-14-does-a-fires-when-filtered-row-deliver-what-implement-needs.md`. It was
withheld. **ADR 0088's second face — the CLI fallback for when MCP is unreachable —
cannot hand a stage its row through a tool result.** Nor can the filtered row: at 45,445
characters strict it is still well over. This does not touch ADR 0089's primary path,
which delivers by `` !`command` `` preprocessing into skill content rather than as a tool
result, and whether *that* path has its own cap is item 1 and remains unrun.

**3 — The failure is loud, not silent, and that is the good news.** The stage does not
receive a quietly shortened row. It receives a wrapper naming the size, saying the output
was too large, and giving the path — so a stage can tell that it did not get everything
and can read the file. Against `substrate/08`'s framing of silent-failure surfaces, this
is not one. The cost is a second read rather than a wrong answer.

## Limitations

- **The lower bound was not established.** Only that ≤34.6 KB trips. A bisection would
  cost the full output of every non-tripping run, and the design consequence — a row does
  not fit — is settled without it.
- **`Bash` only.** `PowerShell` documents 30,000 characters and was not tested; other
  tools may differ, and an MCP tool result was not tested at all.
- **One harness, one version, undated by the harness itself.** This is a fact about the
  build running on 2026-08-14, not a guarantee. It is exactly the kind of claim that ages
  into *unknown* rather than into *wrong*.
- **Nothing about preprocessing was tested.** Item 1 is untouched, and it is the one that
  decides whether ADR 0089's delivery half works at all.

## Conclusion

**Successful.** Item 4 is answered and its own premise is corrected: the cap fires at
roughly 30,000 characters rather than 25,000 tokens, and what a stage sees is a 2 KB
preview plus a path inside an explicit `persisted-output` wrapper.

The consequence the design has to absorb is on **ADR 0088**, not ADR 0089: the CLI
fallback face was chosen so an unreachable store is rebuilt rather than fatal, and a
fallback that cannot return a row without spilling to a file is a narrower fallback than
the decision assumes. It still works — the stage reads the file — but that is a
second step the ADR does not currently name, and it should say so while it is still
`proposed`.

Not promoted. No code was written.
