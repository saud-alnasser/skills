<#
.SYNOPSIS
  Asserts the acceptance criteria of the Tenure build tickets against ./skills.

.DESCRIPTION
  Tenure ships as markdown, so there is no compiler to catch a broken build.
  This script is the substitute: every mechanically checkable acceptance
  criterion in .claude/tickets/<effort>/issues/ gets one assertion here, named
  after the ticket that demands it.

  A criterion that cannot be checked mechanically (does the grill actually
  grill?) is out of scope by design — those are settled by the Phase 2
  dogfood run, not by a script.

.PARAMETER Ticket
  Run only the assertions for one ticket, addressed the way the tracker
  addresses it: <effort>/NN, e.g. -Ticket layout/01. Omit to run all.

  Ticket numbers restart at 01 in each effort, so the effort is part of the
  id rather than a comment beside it. Where a comment in this file says a
  bare "ticket NN", it means the effort that comment's own section belongs
  to; a cross-effort reference is written out in full.

.EXAMPLE
  pwsh scripts/verify.ps1
  pwsh scripts/verify.ps1 -Ticket tenure/03
  pwsh scripts/verify.ps1 -Ticket layout/01
#>
[CmdletBinding()]
param(
  [string]$Ticket
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$skills = Join-Path $repo 'skills'

$script:Failures = @()
$script:Passes = 0
$script:CurrentTicket = ''
$script:Ran = @()
# Every id declared, filtered or not — the error message for an unknown
# -Ticket is built from this rather than from a hand-kept list, which had
# already drifted from the sections in the file.
$script:Known = @()

function Describe-Ticket {
  param([string]$Id, [string]$Name, [scriptblock]$Body)
  $script:Known += $Id
  if ($Ticket -and $Ticket -ne $Id) { return }
  $script:Ran += $Id
  $script:CurrentTicket = $Id
  Write-Host ""
  Write-Host "ticket $Id — $Name" -ForegroundColor Cyan
  & $Body
}

function Assert {
  param([string]$Because, [scriptblock]$Condition)
  $ok = $false
  $detail = ''
  try { $ok = [bool](& $Condition) }
  catch { $ok = $false; $detail = $_.Exception.Message }

  if ($ok) {
    $script:Passes++
    Write-Host "  PASS  $Because" -ForegroundColor DarkGray
  } else {
    $script:Failures += "[$script:CurrentTicket] $Because$(if ($detail) { " — $detail" })"
    Write-Host "  FAIL  $Because" -ForegroundColor Red
    if ($detail) { Write-Host "        $detail" -ForegroundColor DarkRed }
  }
}

# --- helpers -----------------------------------------------------------------

# Every markdown file shipped as part of a skill.
function Get-SkillFiles {
  if (-not (Test-Path $skills)) { return @() }
  Get-ChildItem $skills -Recurse -File -Filter *.md
}

# Throws rather than returning $null, so an assertion about a file's *content*
# fails loudly when the file is absent instead of passing on an empty string.
function Get-SkillFile {
  param([string]$RelativePath)
  $p = Join-Path $skills $RelativePath
  if (-not (Test-Path $p)) { throw "skills/$RelativePath is missing" }
  Get-Content $p -Raw
}

function Get-Frontmatter {
  param([string]$Content)
  if ($Content -match '(?s)\A---\r?\n(.*?)\r?\n---\r?\n') { return $Matches[1] }
  return $null
}

# One `## ` section: from its heading to the next heading at the same level or
# higher. A rule is checked where it is supposed to be stated, not anywhere in
# the file — a file-wide search passes on unrelated prose that happens to use
# the same words, which is how a deleted step keeps its assertion green.
#
# Fenced code is stripped first: a `## ` inside a fence is sample content, not
# a heading, and letting it terminate a section silently truncates the search.
# `##(?!#)` so a `### ` subsection cannot be mistaken for the section itself,
# and `^#{1,2}\s` in the lookahead so a `# ` heading ends the section too —
# without it a section runs to end-of-file and the scoping is decorative.
function Get-Section {
  param([string]$Content, [string]$HeadingPattern)
  # Fenced regions are masked, not removed: same length, no `#`, so offsets
  # into the mask are offsets into the original. Removing them would also
  # remove the content a section is being searched for — /configure's whole
  # detection list is a fenced block.
  $mask = [regex]::Replace($Content, '(?ms)^```.*?^```', {
    param($f) ($f.Value -replace '[^\r\n]', '.')
  })
  $m = [regex]::Match($mask, "(?ims)^##(?!#)[^\r\n]*$HeadingPattern.*?(?=^#{1,2}\s|\z)")
  if (-not $m.Success) { throw "no section matching '$HeadingPattern'" }
  $Content.Substring($m.Index, $m.Length)
}

# `disable-model-invocation: true` on its own frontmatter line. Unanchored,
# a commented-out or quoted mention passes — and for the primitives the
# assertion runs in the negative direction, where a false positive is silent.
function Test-UserInvoked {
  param([string]$RelativePath)
  $fm = Get-Frontmatter (Get-SkillFile $RelativePath)
  if (-not $fm) { throw "$RelativePath has no frontmatter" }
  [bool]($fm -match '(?m)^disable-model-invocation:\s*true\s*$')
}

# --- ticket tenure/01 — vendor the primitives ---------------------------------------

Describe-Ticket 'tenure/01' 'vendor the primitives and rewrite their paths' {

  $primitives = @('grilling', 'tdd', 'codebase-design', 'domain-modeling')

  foreach ($p in $primitives) {
    Assert "$p is vendored into ./skills" {
      Test-Path (Join-Path $skills "$p/SKILL.md")
    }
  }

  # The headline criterion: no legacy path survives anywhere under ./skills.
  # `CONTEXT.md` is matched case-sensitively so Tenure's lowercase
  # `.claude/context.md` does not trip it.
  #
  # Two files are exempt, and they have to be: /configure is the skill that
  # *detects and converts* these paths, so it cannot do its job without naming
  # them. Named individually rather than by prefix — `configure/` also holds
  # CLAUDE.template.md and tracker.template.md, which are installed into the
  # user's repository and must stay guarded like any other shipped file.
  # Ticket 08 asserts every legacy reference inside the two exempt files is a
  # detection entry or a migration row, so the exemption is not a hole.
  # Separator-normalised: `FullName` uses `\` on Windows and `/` elsewhere, and
  # a hardcoded `\` here silently un-exempts both files everywhere else — which
  # fails every assertion in this loop rather than passing one, but on someone
  # else's machine.
  #
  # `.claude/docs/` joins the table for layout/01 rather than in a table of its
  # own. It is a different *kind* of legacy path — Tenure's own superseded
  # layout, not another workflow's — but the guard is identical and the
  # exemption it needs is the same two files, so a second table would be two
  # places to add the next one.
  $legacyExempt = @('configure/SKILL.md', 'configure/MIGRATION.md')
  $legacy = @{
    'CONTEXT\.md'     = 'CONTEXT.md (use .claude/context.md)'
    'CONTEXT-MAP\.md' = 'CONTEXT-MAP.md (use the routing table)'
    'docs/adr/'       = 'docs/adr/ (use .claude/decisions/)'
    '\.scratch/'      = '.scratch/ (use .claude/tickets/)'
    '\.claude/docs/'  = '.claude/docs/ (ADR 0018 dissolved it — use .claude/{decisions,designs,evidence}/)'
  }
  foreach ($pattern in $legacy.Keys) {
    $label = $legacy[$pattern]
    Assert "no file under ./skills references $label" {
      $hits = Get-SkillFiles |
        Where-Object { ($_.FullName.Substring($skills.Length + 1) -replace '\\', '/') -notin $legacyExempt } |
        Select-String -Pattern $pattern -CaseSensitive |
        ForEach-Object { "$(Split-Path -Leaf $_.Path):$($_.LineNumber)" }
      if ($hits) { throw ($hits -join ', ') }
      $true
    }
  }

  Assert "domain-modeling writes the Tenure context.md shape, including the routing table" {
    $fmt = Get-SkillFile 'domain-modeling/CONTEXT-FORMAT.md'
    if (-not $fmt) { throw 'domain-modeling/CONTEXT-FORMAT.md is missing' }
    $required = @('Routing Table', 'Source Pointer', 'Boundaries', 'Constraints')
    $missing = $required | Where-Object { $fmt -notmatch [regex]::Escape($_) }
    if ($missing) { throw "CONTEXT-FORMAT.md never mentions: $($missing -join ', ')" }
    $true
  }

  Assert "domain-modeling groups multi-context repos as directories under contexts/" {
    $fmt = Get-SkillFile 'domain-modeling/CONTEXT-FORMAT.md'
    $fmt -match 'contexts/'
  }

  Assert "ADR-FORMAT keeps the strict 3-of-3 test" {
    $adr = Get-SkillFile 'domain-modeling/ADR-FORMAT.md'
    if (-not $adr) { throw 'domain-modeling/ADR-FORMAT.md is missing' }
    ($adr -match 'Hard to reverse') -and
    ($adr -match 'Surprising without context') -and
    ($adr -match 'real trade-off')
  }

  Assert "ADR-FORMAT states the supersession rule — reasoning frozen, only status moves" {
    $adr = Get-SkillFile 'domain-modeling/ADR-FORMAT.md'
    ($adr -match 'superseded by') -and ($adr -match '(?i)frozen')
  }

  Assert "attribution to mattpocock/skills is present in every vendored primitive" {
    $missing = $primitives | Where-Object {
      $c = Get-SkillFile "$_/SKILL.md"
      $c -notmatch 'mattpocock/skills'
    }
    if ($missing) { throw "no attribution in: $($missing -join ', ')" }
    $true
  }

  Assert "the four primitives are model-invoked — the spine composes them" {
    $userInvoked = $primitives | Where-Object { Test-UserInvoked "$_/SKILL.md" }
    if ($userInvoked) { throw "user-invoked but must be reachable: $($userInvoked -join ', ')" }
    $true
  }
}

# --- ticket tenure/15 — tool reference ----------------------------------------------

Describe-Ticket 'tenure/15' 'tool reference — how to drive every tool the workflow touches' {

  # file → the binary its entries invoke. The file is named for the platform,
  # the commands are named for the executable, and they are not the same word.
  $tools = [ordered]@{
    'git'      = 'git'
    'github'   = 'gh'
    'gitlab'   = 'glab'
    'graphite' = 'gt'
  }

  # ADR 0019 reversed this ticket's two-tier model, so what it asserted about
  # the *shipping shape* — a model-invoked skill, and a second tier for the
  # repository's own tooling — moved to ticket layout/03, which asserts the
  # skill's absence and the single tier that replaced it. What survives here is
  # everything about the reference's *content*, which 0019 did not touch: it is
  # the same text, now source material rather than a skill.
  foreach ($f in $tools.Keys) {
    Assert "$f.md ships as /configure's source material" {
      Test-Path (Join-Path $skills "configure/tools/$f.md")
    }
  }

  # "A URL with no trigger is decoration." Both halves, in every tool file.
  foreach ($f in $tools.Keys) {
    Assert "$f.md names its docs URL and the condition for fetching it" {
      $c = Get-SkillFile "configure/tools/$f.md"
      if (-not $c) { throw "configure/tools/$f.md is missing" }
      if ($c -notmatch '(?m)^Docs:\s*https?://') { throw 'no `Docs:` URL' }
      if ($c -notmatch '(?m)^Fetch the docs when:\s*\S') { throw 'no fetch condition' }
      $true
    }
  }

  # Task-to-command, not a flag catalogue. An *entry* is a section that shows
  # commands — it must show this tool's, task-shaped. A section of pure prose
  # (the stack model, a standing rule) is not an entry and is not held to it.
  foreach ($f in $tools.Keys) {
    $bin = $tools[$f]
    Assert "$f.md entries are task-to-command — every command block carries a $bin invocation" {
      $lines = (Get-SkillFile "configure/tools/$f.md") -split '\r?\n'
      $section = $null
      $inFence = $false
      $hasFence = $false
      $hasCommand = $false
      $bad = @()
      foreach ($line in $lines) {
        if ($line -match '^\s*```') { $inFence = -not $inFence; if ($inFence -and $section) { $hasFence = $true }; continue }
        if (-not $inFence -and $line -match '^##\s+(.+)$') {
          if ($section -and $hasFence -and -not $hasCommand) { $bad += $section }
          $section = $Matches[1]
          $hasFence = $false
          $hasCommand = $false
        } elseif ($inFence -and $section -and $line -match "^\s*$bin\s+\S") {
          $hasCommand = $true
        }
      }
      if ($section -and $hasFence -and -not $hasCommand) { $bad += $section }
      if ($bad) { throw "command blocks with no $bin invocation: $($bad -join '; ')" }
      $true
    }
  }

  # The reference exists to stop guessing, so it must not itself carry an
  # unverifiable claim silently. A file written without the tool present says so.
  Assert "gitlab.md declares that its entries were not verified against an installed glab" {
    $c = Get-SkillFile 'configure/tools/gitlab.md'
    $c -match '(?i)not verified|without a `?glab`? on the machine'
  }

  Assert "git.md carries the operations Tenure depends on and gets wrong easily" {
    $c = Get-SkillFile 'configure/tools/git.md'
    $required = @{
      'the Marker diff'   = 'Marker'
      '--porcelain'       = '--porcelain'
      'amending safely'   = '--amend'
      'the never-push rule' = '(?i)never push'
    }
    $missing = $required.Keys | Where-Object { $c -notmatch $required[$_] }
    if ($missing) { throw "git.md never covers: $($missing -join ', ')" }
    $true
  }

  # The headline criterion. Every invocation a skill issues has to be an entry
  # somewhere in the reference — a skill that writes `gh issue develop` without
  # `gh.md` listing it has guessed.
  Assert "no skill issues a command for a tool with no entry" {
    # binary → the reference text that must list it
    $reference = @{}
    foreach ($f in $tools.Keys) { $reference[$tools[$f]] = Get-SkillFile "configure/tools/$f.md" }
    $binaries = ($tools.Values | ForEach-Object { [regex]::Escape($_) }) -join '|'

    # Both forms a skill writes a command in. Fenced blocks are the dominant
    # one, so scanning only inline backticks would leave the criterion unchecked
    # exactly where it matters.
    $unlisted = @()
    foreach ($file in Get-SkillFiles) {
      if ($file.FullName -match '[\\/]tools[\\/]') { continue }
      $inFence = $false
      $lineNo = 0
      foreach ($line in ((Get-Content $file.FullName -Raw) -split '\r?\n')) {
        $lineNo++
        if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
        $found = if ($inFence) {
          [regex]::Matches($line, "^\s*($binaries) ([a-z][a-z-]+)")
        } else {
          [regex]::Matches($line, "``($binaries) ([a-z][a-z-]+)")
        }
        foreach ($m in $found) {
          $bin = $m.Groups[1].Value
          $sub = $m.Groups[2].Value
          if ($reference[$bin] -notmatch "$bin\s+$sub") {
            $unlisted += "$(Split-Path -Leaf $file.FullName):${lineNo}: $bin $sub"
          }
        }
      }
    }
    if ($unlisted) { throw (($unlisted | Select-Object -Unique) -join ', ') }
    $true
  }

  # The dot count is the whole content of this entry and it is invisible when
  # wrong: `..HEAD` still produces a plausible diff, just one that blames the
  # work for commits that landed on the base branch after it started.
  Assert "the review-diff entry pairs three dots with the diff and two with the log" {
    $c = Get-SkillFile 'configure/tools/git.md'
    if ($c -notmatch '(?m)^git diff <fixed-point>\.\.\.HEAD') { throw 'the review diff is not three-dot' }
    if ($c -notmatch '(?m)^git log <fixed-point>\.\.HEAD') { throw 'the commit list is not a two-dot range' }
    $c -match '(?i)merge-?base'
  }

  # A review that reads only the diffs cannot see a newly added file, and a
  # `git diff` without `HEAD` silently drops whatever is already staged.
  # `diagnosing-bugs` builds a bisection harness, so the invocation has to be
  # here rather than guessed there. The reset is the load-bearing half: without
  # it the session continues against a detached HEAD, and the next status read
  # looks like catastrophic drift that is not real.
  Assert "the bisect entry pairs run with the reset that has to follow it" {
    $c = Get-SkillFile 'configure/tools/git.md'
    if ($c -notmatch '(?m)^git bisect run') { throw 'bisect cannot be driven unattended' }
    if ($c -notmatch '(?m)^git bisect reset') { throw 'the reset is missing' }
    $c -match '(?i)detached HEAD|bisect state'
  }

  Assert "the review reads staged, unstaged, and untracked — not just the commit range" {
    $c = Get-SkillFile 'configure/tools/git.md'
    if ($c -notmatch '(?m)^git diff HEAD\b') { throw 'staged changes are not read' }
    $c -match '(?m)^git ls-files --others --exclude-standard'
  }
}

# --- ticket tenure/02 — verification at use, healing where the break is found --------

# The always-on half of the discipline. ADR 0007: a rule that must hold
# unconditionally has to live in CLAUDE.md, because a rule inside a skill only
# fires when that skill runs. /configure (ticket 08) installs this template.
$claudeTemplate = 'configure/CLAUDE.template.md'

# The sections whose *subject* is this repository's own `.claude/` rather than
# `./skills` — the adoption tickets, where the deliverable is this tree. Reading
# `.claude/` as evidence is ordinary and several sections do it; reading it as
# the thing under test is what the ships/runs-on boundary otherwise holds apart.
#
# Declared once and checked both ways in `layout/04`: every id here is marked at
# its own section, and every section marked as one appears here. The list on its
# own would be a comment; the reverse direction is what makes widening the
# exception fail the build instead of passing silently.
$subjectSections = @('layout/02', 'layout/04', 'layout/06')

# Ticket 16 split the always-on file. `CLAUDE.md` is committed and read by every
# Claude that opens the repository, so it keeps only rules that hold with or
# without the plugin; the machinery serving them — the Marker, the drift reads,
# the verification report — moved here, where only Tenure's skills look.
# Assertions follow the rule they are about, so the Marker ones below read this.
$tenureTemplate = 'configure/tenure.template.md'

# A rule's *pattern* gets one home too, for the reason the rule does. Ticket 02
# asserts each rule is stated once; ticket 13 asserts where, and which skills
# reach it by pointer. Those are three uses of the same regex, and a second copy
# means rewording a rule needs coordinated edits — with the copy that gets
# missed still passing.
#
# Deliberately loose. These are "is this rule stated here at all" probes, which
# is what duplication detection needs; an assertion that the rule is stated
# *properly* is a different, stronger pattern and belongs at its own site.
$rulePattern = [ordered]@{
  'verify before claiming'             = '(?i)before any repository-specific claim'
  # ADR 0019 collapsed the two tiers this rule used to route between, so the
  # rule it now states is which *one* directory covers everything. Repointed
  # rather than deleted: a skill restating where tool references live is still
  # a second home, and that was always what the guard was for.
  'the tools routing rule'             = '(?i)covers every tool this repository uses'
  'never guess an API'                 = '(?i)a CLI is an API'
  'conventions are defaults'           = '(?i)defaults? for when the repository is silent'
  'one concept per file'               = '(?i)one concept per file'
  'the test-layout rule'               = '(?i)unnecessary test structure'
  'self-explanatory code'              = '(?i)self-explanatory'
  'the compression test'               = '(?i)will this improve (a )?future engineering decision'
  'the knowledge-layer table'          = '(?im)^\|\s*Codebase\s*\|'
  # `tdd` owns the loop, so it owns why a guessed test command wrecks it. This
  # reasoning had reached four files before the guard existed.
  'the guessed-test-command cost'      = '(?i)full-suite run per cycle'
  'the stale-command rule'             = '(?i)stale command is worse than no command'
  'the worse-convention escape'        = '(?i)say so\s*\**\s*once, with reasoning'
  # TICKETS.md owns the ticket format, so it owns which tracker expresses
  # a state which way. /implement claims tickets and pointed at the config,
  # but restated the mapping too.
  'the local-markdown status form'    = '(?i)the same states are labels'
  # ADR 0008 classes the PR description shape as a Tenure convention, so it
  # lives with the others in CLAUDE.md rather than as prose inside one
  # CLI's task-to-command reference.
  'the PR body shape'                 = '(?i)architectural impact'
  # The router tells the human the tier is theirs; /design enforces it. Both
  # are legitimate, but the enforcement clause is one sentence and drifts.
  'the tier-override enforcement'      = '(?i)(their|your) override stands'
  # Ticket 17. /implement makes the Claim, so it owns how. TICKETS.md has to
  # say a `claimed` status does not exist, which is a pointer; restating the
  # naming or the never-take rule there is a second home, and the naming is
  # the half that breaks silently — two tools disagreeing on a name means
  # neither sees the other's claim.
  'the branch-name convention'         = '(?i)ticket.?id[^\r\n]{0,24}slug'
  'a claim held elsewhere is not taken' = '(?i)claim held elsewhere is \*{0,2}never\*{0,2} taken'
  # layout/01. ADR-FORMAT.md owns ADR numbering, so it owns the rule that a
  # number survives a move; MIGRATION.md reaches it by pointer. That direction
  # was got wrong first time round — MIGRATION.md restated the rule, and the
  # guard written alongside it matched only the restatement's wording, so it
  # passed with both copies in the tree. This pattern matches the *subject*
  # rather than either phrasing, which is what makes it detect a second home.
  #
  # A file may say "unchanged in content" freely, and MIGRATION.md has to.
  # Number and slug spoken about together is what means the rule lives here.
  'ADR numbers survive a move'         = '(?i)numbers? and slug|numbers and slugs'
  # MIGRATION.md's own: the layout move is mechanical, so the classification
  # step that governs every other row on that page does not run.
  'a migrated file is not reclassified' = '(?i)classification does not apply'
  # layout/03. TOOLS.md owns derivation, so it owns the rule that an entry is
  # dropped whole or carried whole. Restating it in /configure's SKILL.md is
  # the likeliest second home, since that is where the reader is sent from.
  'derivation never summarizes'        = '(?i)never summarize'
  # The reader's half of the gap rule is `CLAUDE.md`'s, because it must hold
  # with no plugin installed; TOOLS.md carries only the part that names
  # /configure as the remedy, which is meaningless without Tenure. The router
  # points at both and restates neither.
  'the never-guess fallback'           = '(?i)fall back to the tool'
}

Describe-Ticket 'tenure/02' 'verification at use, healing where the break is found' {

  Assert "the always-on rules ship as the CLAUDE.md template /configure installs" {
    Test-Path (Join-Path $skills $claudeTemplate)
  }

  Assert "CLAUDE.md stays an entrypoint, not a manual — under 200 lines" {
    $n = ((Get-SkillFile $claudeTemplate) -split '\r?\n').Count
    if ($n -ge 200) { throw "$n lines" }
    $true
  }

  Assert "the Marker rule states the trusted path — matching HEAD plus a clean tree costs no reading" {
    $c = Get-SkillFile $tenureTemplate
    if (-not $c) { throw 'template is missing' }
    ($c -match 'marker\.json') -and
    ($c -match '(?i)clean') -and
    ($c -match '(?i)HEAD')
  }

  Assert "the clean path costs one git check and no reading" {
    $c = Get-SkillFile $tenureTemplate
    $c -match '(?i)(no reading|without reading|read nothing)'
  }

  Assert "both drift sources are named, with the command that reads each" {
    $c = Get-SkillFile $tenureTemplate
    $missing = @()
    if ($c -notmatch 'git diff --name-only') { $missing += 'committed drift' }
    if ($c -notmatch 'git status --porcelain') { $missing += 'uncommitted drift' }
    if ($missing) { throw "unreadable: $($missing -join ', ')" }
    $true
  }

  Assert "the non-ancestor case is covered — a moved HEAD makes the diff meaningless" {
    $c = Get-SkillFile $tenureTemplate
    ($c -match '(?i)ancestor') -and ($c -match '(?i)rebase|branch switch|switched branch')
  }

  Assert "verification is at use — never a startup scan, never a phase" {
    $c = Get-SkillFile $claudeTemplate
    ($c -match '(?i)never a scan|no startup scan|never scan') -and
    ($c -match '(?i)about to (rely|be relied)|at the point of use|where it is used')
  }

  Assert "a broken Source Pointer is recovered by searching, never invented" {
    $c = Get-SkillFile $claudeTemplate
    ($c -match 'Source Pointer') -and ($c -match '(?i)never invent|not invent|rather than invent')
  }

  Assert "healing happens in place — no queue, no deferred pass" {
    $c = Get-SkillFile $claudeTemplate
    $c -match '(?i)where you find it|in the same breath|no deferred|no queue'
  }

  Assert "only /commit advances the Marker" {
    $c = Get-SkillFile $tenureTemplate
    ($c -match '/commit') -and ($c -match '(?i)nothing else (moves|advances)|only `?/commit`?')
  }

  Assert "the Marker is machine-local — a teammate's verification is not Claude's" {
    $c = Get-SkillFile $tenureTemplate
    $c -match '(?i)gitignored|machine-local|per-clone|not committed'
  }

  # "Every rule here has exactly one home." Duplication is the failure mode
  # this whole framework exists to prevent, and a rule stated twice drifts as
  # soon as one copy is edited. Each pattern below matches a *statement* of the
  # rule, not a mention of it — a file may name the Marker while documenting
  # how to read it, or forbid a specific command without re-arguing why.
  # The Marker pattern matches the *decision procedure* — the equality plus what
  # it entitles you to skip. A skill stating the bare postcondition it leaves
  # behind ("the Marker equals HEAD after this") is not a second home for the
  # rule, and /commit has to be able to state exactly that. `equals` is in the
  # alternation because word choice is not a licence: without it, a verbatim
  # restatement slips through by spelling `==` differently.
  $singleHome = [ordered]@{
    'the Marker cache-validity rule'  = '(?is)marker.{0,80}(==|equals|matches).{0,40}HEAD.{0,200}(trusted|no reading|no verification)'
    'the commit scope vocabulary'     = '(?i)`misc`.{0,40}`stuff`'
    'the evidence graduation rule'    = '(?i)owns that graduation'
    'the evidence gating rule'        = '(?i)ungated[^\r\n]{0,120}background'
    'the never-invent-a-pointer rule' = '(?i)(never|not|rather than) invent(ing)?( a)? (replacement|path)'
    # Ticket 13's two rules whose single-home probe is looser than the pattern
    # that asserts they are stated *properly*, so they are not in $rulePattern:
    # the placement checks demand all three recorded items and the worked
    # example respectively, and neither shape is what duplication detection
    # wants — a partial restatement elsewhere is still a second home.
    'root-cause over workaround'      = '(?i)removal condition'
    'directories over verbose filenames' = '(?i)verbose filename'
  }
  foreach ($rule in $rulePattern.Keys) { $singleHome[$rule] = $rulePattern[$rule] }
  foreach ($rule in $singleHome.Keys) {
    $pattern = $singleHome[$rule]
    Assert "$rule has exactly one home under ./skills" {
      $homes = Get-SkillFiles |
        Where-Object { (Get-Content $_.FullName -Raw) -match $pattern } |
        ForEach-Object { $_.FullName.Substring($skills.Length + 1) }
      if ($homes.Count -eq 0) { throw 'stated nowhere' }
      if ($homes.Count -gt 1) { throw "restated in: $($homes -join ', ')" }
      $true
    }
  }

  # ADR 0007: a rule that must hold unconditionally has to be in CLAUDE.md,
  # because a rule inside a skill fires only when that skill runs. Misplacing
  # one is a silent failure, so the always-on set is asserted explicitly.
  $alwaysOn = [ordered]@{
    'Claude never silently decides architecture' = '(?i)never silently decid'
    'the instruction precedence chain'           = '(?i)precedence'
    'the cold-request path states a classification' = '(?i)classification'
  }
  foreach ($rule in $alwaysOn.Keys) {
    $pattern = $alwaysOn[$rule]
    Assert "CLAUDE.md carries an always-on rule: $rule" {
      (Get-SkillFile $claudeTemplate) -match $pattern
    }
  }
}

# --- ticket tenure/03 — /design, the whole planning surface -------------------------

Describe-Ticket 'tenure/03' 'the whole planning surface' {

  Assert "/design ships as a skill" {
    Test-Path (Join-Path $skills 'design/SKILL.md')
  }

  Assert "/design is user-invoked — planning starts because the user asked for it" {
    Test-UserInvoked 'design/SKILL.md'
  }

  foreach ($f in @('SPEC-FORMAT.md', 'TICKETS.md', 'MAP.md')) {
    Assert "$f is disclosed behind a pointer, not inlined" {
      if (-not (Test-Path (Join-Path $skills "design/$f"))) { throw "design/$f is missing" }
      (Get-SkillFile 'design/SKILL.md') -match [regex]::Escape($f)
    }
  }

  # Ordering is the acceptance criterion, so assert on position, not presence.
  $stepOrder = {
    param([string]$Pattern)
    $c = Get-SkillFile 'design/SKILL.md'
    $m = [regex]::Match($c, $Pattern, 'IgnoreCase')
    if (-not $m.Success) { throw "not found: $Pattern" }
    $m.Index
  }

  Assert "an understanding is stated before any scope assessment" {
    $understanding = & $stepOrder 'State your understanding'
    $scope = & $stepOrder 'Scope assessment'
    if ($understanding -ge $scope) { throw 'scope is assessed first' }
    $true
  }

  Assert "scope is never assessed before the refine step has run" {
    $refine = & $stepOrder 'Refine'
    $scope = & $stepOrder 'Scope assessment'
    if ($refine -ge $scope) { throw 'scope is assessed before refining' }
    $true
  }

  Assert "verification is scoped by routing, so it comes after routing" {
    $c = Get-SkillFile 'design/SKILL.md'
    $route = [regex]::Match($c, '\b(route|routing table)\b', 'IgnoreCase')
    $verify = [regex]::Match($c, '\bverif(y|ication)\b', 'IgnoreCase')
    if (-not $route.Success) { throw 'the routing step is missing' }
    if (-not $verify.Success) { throw 'the verification step is missing' }
    if ($route.Index -ge $verify.Index) { throw 'verification precedes routing' }
    $true
  }

  Assert "/design plans; it never builds — and never invokes /implement" {
    $c = Get-SkillFile 'design/SKILL.md'
    if ($c -notmatch '(?i)(does not|never) invoke') { throw 'the rule is not stated' }
    $calls = [regex]::Matches($c, '(?im)^\s*[-*>]?\s*(run|invoke|call|then run|now run)\s+`?/implement')
    if ($calls.Count -gt 0) { throw "$($calls.Count) instruction(s) to invoke /implement" }
    $true
  }

  Assert "options carry advantages, disadvantages, risks, and maintenance impact — and the user chooses" {
    $c = Get-SkillFile 'design/SKILL.md'
    $required = @('advantage', 'disadvantage', 'risk', 'maintenance')
    $missing = $required | Where-Object { $c -notmatch $_ }
    if ($missing) { throw "options never mention: $($missing -join ', ')" }
    if ($c -notmatch '(?i)user chooses|the user decides|the choice is the user') { throw 'the user is not given the choice' }
    $true
  }

  Assert "options are presented whenever more than one reasonable approach exists, not only on request" {
    (Get-SkillFile 'design/SKILL.md') -match '(?i)more than one (reasonable )?approach'
  }

  Assert "every run leaves at least one ticket on disk" {
    $c = Get-SkillFile 'design/SKILL.md'
    ($c -match '(?i)at least one ticket|always .{0,20}one ticket') -and
    ($c -match '(?i)(nothing|never) lives only in the conversation')
  }

  Assert "the tier is max(Floor, Gates) and gates only raise" {
    $c = Get-SkillFile 'design/SKILL.md'
    $missing = @('Express', 'Standard', 'Heavyweight') | Where-Object { $c -notmatch $_ }
    if ($missing) { throw "tiers missing: $($missing -join ', ')" }
    if ($c -notmatch '(?i)raise|never lower') { throw 'gates are not stated as raise-only' }
    $true
  }

  # Ticket 14 defines the build lifecycle and is explicit that it is NOT the
  # triage vocabulary: a ticket /design created is agent-ready by construction
  # and is never triaged. Conflating the two sets makes a status answer two
  # questions at once, so both halves are asserted.
  Assert "tickets carry the build lifecycle, not triage roles" {
    $tickets = Get-SkillFile 'design/TICKETS.md'
    $lifecycle = @('open', 'blocked', 'resolved', 'obsolete')
    $absent = $lifecycle | Where-Object { $tickets -notmatch "(?m)^$_\s" }
    if ($absent) { throw "lifecycle states undefined: $($absent -join ', ')" }
    $true
  }

  Assert "no triage role leaks into a build ticket's Status:" {
    $roles = 'needs-triage|needs-info|ready-for-agent|ready-for-human|wontfix'
    $leaked = @()
    foreach ($f in @('design/TICKETS.md', 'design/MAP.md')) {
      foreach ($m in [regex]::Matches((Get-SkillFile $f), "(?m)^Status:\s*($roles)")) {
        $leaked += "${f}: $($m.Groups[1].Value)"
      }
    }
    if ($leaked) { throw ($leaked -join ', ') }
    $true
  }

  Assert "a re-plan marks superseded tickets obsolete — never deletes, never leaves them open" {
    $c = Get-SkillFile 'design/SKILL.md'
    ($c -match '(?i)obsolete') -and ($c -match '(?i)never deleted|not deleted')
  }

  # "SKILL.md carries no deliverable-format detail." MAP.md is the clearest
  # test: everything about maps lives there, and SKILL.md says only that the
  # branch exists.
  Assert "SKILL.md carries no deliverable-format detail — the map vocabulary lives in MAP.md" {
    $skill = Get-SkillFile 'design/SKILL.md'
    $map = Get-SkillFile 'design/MAP.md'
    $vocabulary = @('fog of war', 'frontier', 'destination', 'not yet specified')
    $leaked = $vocabulary | Where-Object { $skill -match [regex]::Escape($_) }
    if ($leaked) { throw "leaked into SKILL.md: $($leaked -join ', ')" }
    $absent = $vocabulary | Where-Object { $map -notmatch [regex]::Escape($_) }
    if ($absent) { throw "missing from MAP.md: $($absent -join ', ')" }
    $true
  }

  Assert "SKILL.md carries no spec-format detail — the section list lives in SPEC-FORMAT.md" {
    $skill = Get-SkillFile 'design/SKILL.md'
    $spec = Get-SkillFile 'design/SPEC-FORMAT.md'
    $sections = @('Acceptance criteria', 'Constraints')
    $leaked = $sections | Where-Object { $skill -match "(?m)^#+\s*$([regex]::Escape($_))" }
    if ($leaked) { throw "spec sections templated in SKILL.md: $($leaked -join ', ')" }
    $absent = $sections | Where-Object { $spec -notmatch [regex]::Escape($_) }
    if ($absent) { throw "missing from SPEC-FORMAT.md: $($absent -join ', ')" }
    $true
  }

  # Ticket 02's placement rule, checked where the second file could restate it.
  Assert "/design points at the verification discipline rather than restating the Marker rule" {
    $c = Get-SkillFile 'design/SKILL.md'
    if ($c -match '(?i)marker.{0,80}(==|matches).{0,40}HEAD') { throw 'the Marker rule is restated' }
    $c -match '(?i)marker'
  }
}

# --- ticket tenure/04 — /implement, build and record what moved ---------------------

Describe-Ticket 'tenure/04' 'build, and record what moved' {

  Assert "/implement ships as a skill" {
    Test-Path (Join-Path $skills 'implement/SKILL.md')
  }

  # Spec, Scope: the spine is model-invoked. Not, as ticket 04 claims, so
  # /design can reach it — ticket 03 forbids exactly that. The router (10) is
  # the caller this is actually for.
  Assert "/implement is model-invoked — the spine is reachable" {
    -not (Test-UserInvoked 'implement/SKILL.md')
  }

  # Ticket 02 deferred this criterion to here: the discipline is only real if
  # something emits proof of it. The report is the enforcement.
  Assert "step 0 is a verification report, emitted on every invocation without exception" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)verification report') { throw 'no verification report named' }
    if ($c -notmatch '(?i)every invocation|no exceptions') { throw 'the report is left conditional' }
    $c -match '(?ms)^```\s*$.*?Verification.*?^```\s*$'
  }

  # A pointer says where to start looking, never what is there. Reading source
  # through an unchecked one is how a stale belief becomes a wrong edit.
  Assert "no source is read through a Source Pointer that has not been verified this session" {
    $c = Get-SkillFile 'implement/SKILL.md'
    ($c -match '(?i)source pointer') -and ($c -match '(?i)before (it is |it.s )?relied on|verified this session')
  }

  # A filename is not a contract. This is the half of the pointer rule that
  # bites during a build, and it is /implement's — CLAUDE.md owns recovery.
  Assert "an API is never inferred from a filename" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)never infer an API from a filename'
  }

  # The whole point of a deterministic frontier is that two sessions on the same
  # effort make the same choice. "Pick a sensible ticket" is not that.
  Assert "the frontier is defined and the choice is deterministic — lowest number wins" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)frontier') { throw 'the frontier is never named' }
    if ($c -notmatch '(?i)unblocked') { throw 'the frontier does not exclude blocked tickets' }
    if ($c -notmatch '(?i)unclaimed') { throw 'the frontier does not exclude claimed tickets' }
    $c -match '(?i)lowest number wins'
  }

  Assert "claiming is the first write, before any work — that is what stops a double claim" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)(claim[a-z]*).{0,60}before any work|before any work.{0,60}claim'
  }

  Assert "one ticket per invocation — never a second, never a blocked one" {
    $c = Get-SkillFile 'implement/SKILL.md'
    ($c -match '(?i)one ticket per invocation') -and
    ($c -match '(?i)never (take |start )')
  }

  # The headline acceptance criterion. A prohibition a reader can only find by
  # already knowing it is there is not a prohibition.
  Assert "/implement never runs git push, and says so where a reader looking for it lands" {
    $lines = (Get-SkillFile 'implement/SKILL.md') -split '\r?\n'
    if (($lines -join "`n") -notmatch '(?i)never (runs |run )?`?git push') { throw 'no explicit never-push rule' }
    $inFence = $false
    $lineNo = 0
    $invocations = @()
    foreach ($line in $lines) {
      $lineNo++
      if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
      # A fenced `git push` with no marker of prohibition reads as an instruction.
      # A `#` alone does not make a line a prohibition — `git push  # when the
      # ticket is done` is a comment and an instruction. The comment has to say
      # not to run it.
      if ($inFence -and $line -match '^\s*git\s+push' -and $line -notmatch '(?i)\b(never|do not|don.t|forbidden)\b') {
        $invocations += "line ${lineNo}: $($line.Trim())"
      }
    }
    if ($invocations) { throw ($invocations -join '; ') }
    $true
  }

  # The two rules hold each other up: amending rewrites history, which is only
  # safe because nothing was pushed. Either one alone is a defect.
  Assert "post-commit changes amend, and the amend is justified by the push guard" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)amend') { throw 'amending is never mentioned' }
    if ($c -notmatch '(?i)one ticket.{0,40}one commit') { throw 'no one-ticket-one-commit rule' }
    $c -match '(?i)(amend|rewrit).{0,200}(push|publish)|(push|publish).{0,200}(amend|rewrit)'
  }

  Assert "the Marker re-advances on every amend, not only on the first commit" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)marker.{0,120}(every |each )amend|(every |each )amend.{0,120}marker'
  }

  # Ticket 06: "/commit is the shared implementation both paths use", and the
  # always-on rule is "Only /commit advances the Marker. Nothing else moves it."
  # A close-out that commits directly breaks that on the ticketed path.
  Assert "the close-out routes through /commit, which owns the Marker" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)(close out|closes out) through `?/commit') { throw 'the close-out does not route through /commit' }
    $c -match '(?i)/implement`?\*{0,2} never writes the Marker directly'
  }

  Assert "a ticket resolves only when the user says so" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)resolve') { throw 'resolution is never described' }
    $c -match '(?i)(ask|asks|the user.s call|user says).{0,200}(resolve|commit)|(resolve|commit).{0,200}(ask|asks|the user.s call)'
  }

  Assert "a not-yet keeps the ticket claimed and the loop open" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)not yet.{0,160}claimed'
  }

  # Improvising past a wrong plan silently discards the grill, the options the
  # user chose, and the tier that was assessed.
  Assert "/implement never redesigns — a wrong plan is handed back, not worked around" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)never redesign') { throw 'no never-redesign rule' }
    # `blocked`, not `open`. An open ticket with no blocker is back on the
    # frontier, and the next /implement claims it into the same wall. Ticket 17
    # split the two halves of a hand-back — the status keeps it off the
    # frontier, releasing the branch stops this clone holding a dead Claim — so
    # both are required, and neither alone counts.
    if ($c -notmatch '(?i)Status:\s*blocked') { throw 'the ticket is not left blocked on hand-back' }
    if ($c -match '(?i)hand.?back[^\r\n]{0,80}Status:\s*open') { throw 'hand-back returns the ticket to the frontier' }
    if ($c -notmatch '(?i)release the claim') { throw 'the claim survives a plan that cannot be built' }
    if ($c -notmatch '## Blocked') { throw 'no ## Blocked note' }
    $c -match '(?i)(leave|leaving) the (working )?tree'
  }

  Assert "harder than expected is not a wrong plan" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)harder than expected\*{0,2} is not a wrong plan'
  }

  Assert "a deviation that changes architecture goes back to /design, not into the diff" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)changes architecture.{0,60}/design'
  }

  # ADR 0007 places these in /implement and /review both — the skill that
  # writes them and the skill that catches a breach. Ticket 13 distributes the
  # rest of that row; these two are already home and must not be placed twice.
  Assert "the comment and public-API rules ADR 0007 places here are carried" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)comments? explain \*{0,2}why') { throw 'the comment rule is missing' }
    if ($c -notmatch '(?i)public (interface|api) is documented') { throw 'the public-API rule is missing' }
    $c -match '(?i)ADR 0007|0007'
  }

  # Ticket 14: /implement marks a ticket obsolete when it claims one and finds
  # the work already done — "it sets the state, gives the reason, and stops
  # rather than inventing work."
  Assert "a ticket whose work is already done is marked obsolete, not filled with invented work" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)obsolete') { throw 'the obsolete branch is missing' }
    $c -match '(?i)(reason|one-line).{0,200}(do not|never|stop)|stop there'
  }

  Assert "a ticket left claimed is resumed, not skipped" {
    $c = Get-SkillFile 'implement/SKILL.md'
    ($c -match '(?i)resum') -and ($c -match '(?i)claimed')
  }

  Assert "work with no ticket is /commit's, not /implement's" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)(no ticket|without a ticket).{0,140}/commit'
  }

  # matt's core, retained: the loop is the point, and the full suite runs once.
  Assert "tdd drives the build at pre-agreed seams, with the full suite once at the end" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)\btdd\b') { throw 'tdd is never invoked' }
    if ($c -notmatch '(?i)seam') { throw 'no pre-agreed seams' }
    if ($c -notmatch '(?i)typecheck') { throw 'typechecking is never run' }
    $c -match '(?i)(full|whole) suite'
  }

  # Ordering, not presence. Approval given for reviewed work is not approval
  # for work that is about to be reviewed.
  Assert "/review closes the work out before the commit question" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $review = $c.IndexOf('/review')
    $ask = $c.IndexOf('commit and resolve this ticket')
    if ($review -lt 0) { throw '/review is never invoked' }
    if ($ask -lt 0) { throw 'the close-out question is never asked' }
    if ($review -gt $ask) { throw 'review comes after the commit question' }
    $c -match '(?i)/review.{0,40}before\*{0,2} the commit question'
  }

  # Context stores concepts. An implementation walkthrough in context is
  # sediment: it goes stale on the next commit and nothing points at it.
  Assert "knowledge writing is scoped to concepts and boundaries, never implementation detail" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '\.claude/context\.md') { throw 'context.md is never written' }
    if ($c -notmatch '(?i)concept') { throw 'concepts are not named as what belongs' }
    $c -match '(?i)(never|not).{0,60}implementation|implementation.{0,60}(never|does not)'
  }

  Assert "a change that moves no concept writes nothing — silence is the correct output" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $c -match '(?i)silence is the correct output'
  }

  # ADR 0005: vocabulary and decisions crystallise in conversation, and that
  # conversation is /design's.
  Assert "/implement writes no vocabulary and no ADRs — those belong to /design" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)(does\s+\*{0,2}not\*{0,2}|never)\s+writes?\s+vocabulary') {
      throw 'the prohibition is not stated'
    }
    $c -match '(?i)(vocabulary|adrs?).{0,140}/design'
  }

  # Ticket 02's placement rule, checked where the third file could restate it.
  Assert "/implement points at the verification discipline rather than restating the Marker rule" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -match '(?i)marker.{0,80}(==|matches).{0,40}HEAD') { throw 'the Marker rule is restated' }
    $c -match '(?i)marker'
  }
}

# --- ticket tenure/05 — /review, two axes --------------------------------------

Describe-Ticket 'tenure/05' 'review axes for Tenure' {

  Assert "/review ships as a skill" {
    Test-Path (Join-Path $skills 'review/SKILL.md')
  }

  # Decision 13 chose `code-review` so the skill would not shadow the built-in
  # `/review`. ADR 0015 supersedes it: inside a plugin namespace the command is
  # `/tenure:review`, which cannot shadow anything, so the prefix bought nothing
  # and cost a word. The name is still load-bearing, so it is still asserted.
  Assert "it ships as /review, and the old name survives nowhere under ./skills" {
    if (Test-Path (Join-Path $skills 'code-review')) { throw 'skills/code-review/ still exists' }
    $fm = Get-Frontmatter (Get-SkillFile 'review/SKILL.md')
    if (-not $fm) { throw 'review/SKILL.md has no frontmatter' }
    $fm -match '(?m)^name:\s*review\s*$'
  }

  # Spec, Scope: model-invoked, because /implement closes out through it and
  # /commit confirms it ran.
  Assert "/review is model-invoked — /implement and /commit can reach it" {
    -not (Test-UserInvoked 'review/SKILL.md')
  }

  Assert "two axes — Spec and Standards" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?im)^##+\s.*\bSpec\b') { throw 'no Spec axis' }
    $c -match '(?im)^##+\s.*\bStandards\b'
  }

  # The acceptance criterion, and the reason: an axis that reads the other's
  # findings starts agreeing with them.
  # Scoped to the step that launches them, not the whole file — "parallel" and
  # "subagent" both appear in the rationale that follows, so a file-wide
  # presence check stays green even when the instruction says to run them one
  # after the other in this context.
  Assert "the axes run in parallel subagents, and the reason is stated" {
    $c = Get-SkillFile 'review/SKILL.md'
    $m = [regex]::Match($c, '(?ims)^#{2,}\s.*\baxes\b.*?(?=^#{2}\s|\z)')
    if (-not $m.Success) { throw 'running the axes is not its own step' }
    $step = $m.Value
    if ($step -match '(?i)(one after the other|sequentially|in turn|one at a time)') {
      throw 'the axes are run sequentially'
    }
    if ($step -notmatch '(?i)in parallel.{0,60}sub-?agents|sub-?agents.{0,60}in parallel') {
      throw 'the launch instruction does not bind parallel to subagents'
    }
    # The reason belongs to the step too. Stated anywhere else in the file it
    # is a fact about reviews; stated here it is why this launch is shaped
    # this way, which is the thing a reader about to "simplify" it needs.
    $step -match "(?i)(pollut|contaminat|each other's context|one another's context)"
  }

  # Ticket 05: architecture "folds into Standards rather than earning its own
  # subagent". A third axis is the failure this decision exists to prevent.
  Assert "architecture folds into Standards — there is no third axis" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)architecture') { throw 'architecture is never reviewed' }
    if ($c -match '(?i)three (axes|sub-?agents)') { throw 'a third axis was introduced' }
    # "two axes" alone does not carry this — it is in the description and the
    # opening either way. The absence of a third has to be stated, because
    # architecture is the thing that would otherwise become one.
    if ($c -notmatch '(?i)(no third|not a third|no separate)') { throw 'the absence of a third axis is never stated' }
    $c -match '(?i)architecture.{0,200}(folds? into|part of|belongs to|within) (the )?Standards|Standards.{0,120}architecture'
  }

  # The three architecture questions the ticket names. Each is checkable
  # separately, so each gets asserted separately — a block that reaches two of
  # three is a partial implementation, not a pass.
  # Scoped to the question itself. `.claude/context.md` and "boundaries" both
  # appear elsewhere in the file, so a presence check stays green with the whole
  # architecture block deleted — which is the one thing this must catch.
  Assert "architecture reaches ownership boundaries, read from this repo's Context" {
    $c = Get-SkillFile 'review/SKILL.md'
    $c -match '(?i)ownership boundar[a-z]+ in `?\.claude/context\.md'
  }

  Assert "architecture reaches abstraction the change did not require" {
    $c = Get-SkillFile 'review/SKILL.md'
    $c -match '(?i)abstraction.{0,120}(did ?n.t|did not|does ?n.t|does not|no[t]? .{0,20}require|unnecessary)|(unnecessary|speculative).{0,40}abstraction'
  }

  # Headline acceptance criterion: "A diff contradicting an existing ADR is
  # surfaced explicitly, not silently accepted."
  Assert "a diff contradicting an ADR is surfaced explicitly, never silently accepted" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '\.claude/decisions') { throw 'the decisions are never read' }
    $c -match '(?i)(contradict|conflict).{0,160}(surfac|report|explicit|say|flag)|(surfac|report|explicit|flag).{0,160}(contradict|conflict)'
  }

  # Decision 33. Without the third outcome the same finding is re-raised on
  # every future review, and the reader learns to skim.
  Assert "every finding is fixed, ticketed, or accepted-and-recorded" {
    $c = Get-SkillFile 'review/SKILL.md'
    foreach ($outcome in @('fixed', 'ticketed', 'accepted')) {
      if ($c -notmatch "(?i)\b$outcome\b") { throw "the '$outcome' outcome is missing" }
    }
    $c -match '(?i)(re-?raise|raised again|every future review|again on every)'
  }

  # An acceptance goes to an ADR only when it passes the 3-of-3 test — and that
  # test has one home, in domain-modeling. Restating it here is the duplication
  # ADR 0007 exists to stop.
  Assert "an acceptance is recorded, and the ADR bar points at its one home" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)3-of-3') { throw 'the ADR bar is never named' }
    if ($c -match '(?i)hard to reverse') { throw 'the 3-of-3 test is restated instead of referenced' }
    $c -match '(?i)(ADR-FORMAT|domain-modeling)'
  }

  Assert "acceptance is the user's call, never the reviewer's" {
    $c = Get-SkillFile 'review/SKILL.md'
    $c -match "(?i)accept.{0,80}(user's call|user decides|never the reviewer)|the user.{0,60}accept"
  }

  # Decision 21. A review is about a diff; once merged its subject is gone.
  Assert "reviews are never persisted, and no skill writes a reviews directory" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)never persist') { throw 'the no-persistence rule is not stated' }
    # Stating that the directory does not exist is the rule, not a breach of it.
    # Flag only a mention that reads as somewhere to write.
    $offenders = @()
    foreach ($f in Get-SkillFiles) {
      foreach ($line in ((Get-Content $f.FullName -Raw) -split '\r?\n')) {
        if ($line -match 'docs/reviews' -and $line -notmatch '(?i)\b(no|never|not|dropped|without)\b') {
          $offenders += "$($f.Name): $($line.Trim())"
        }
      }
    }
    if ($offenders) { throw "a reviews directory is written by — $($offenders -join '; ')" }
    $true
  }

  # Acceptance criterion: "Findings are reported against the repo's own
  # documented standards, not generic ones." The baseline is a fallback the
  # repo overrides — inverting that ordering is the defect.
  Assert "the repo's own documented standards come first, and override the baseline" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)\.claude/rules') { throw "this repo's own discovered standards are never read" }
    if ($c -notmatch '(?i)(cite|quote|name).{0,120}(standard|rule)') { throw 'a finding need not cite the standard it breaches' }
    $c -match '(?i)the repo(sitory)? (always )?(overrides|wins)|repo(sitory)?.{0,40}outrank'
  }

  # Progressive disclosure: the baseline is a dozen entries only the Standards
  # subagent needs, so it is a file that subagent opens — not context every
  # caller of /review pays for.
  Assert "the smell baseline is disclosed progressively, not inlined in SKILL.md" {
    $baseline = Get-SkillFile 'review/SMELLS.md'
    foreach ($smell in @('Feature Envy', 'Data Clumps', 'Primitive Obsession', 'Shotgun Surgery', 'Speculative Generality')) {
      if ($baseline -notmatch [regex]::Escape($smell)) { throw "the baseline is missing '$smell'" }
    }
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -match '(?i)feature envy') { throw 'the baseline is inlined in SKILL.md as well' }
    $c -match 'SMELLS\.md'
  }

  Assert "a baseline smell is a judgement call, never a hard violation" {
    $baseline = Get-SkillFile 'review/SMELLS.md'
    if ($baseline -notmatch '(?i)judgement call') { throw 'the baseline does not label itself a judgement call' }
    # The distinction has to reach the finding, not just the baseline file —
    # an unmarked finding reads as a standard to whoever receives it.
    $c = Get-SkillFile 'review/SKILL.md'
    $c -match '(?i)hard violation.{0,40}judgement call|judgement call.{0,40}hard violation'
  }

  # ADR 0007 places these two here by name: "comment and public-API rules in
  # /implement and /review". They are Tenure's own, applied even where the
  # repository documents neither — so they are not covered by the repo-first
  # ordering above, and nothing else in ./skills carries them.
  Assert "the comment and public-API rules ADR 0007 places here are carried" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)comments? explain \*{0,2}why') { throw 'the comment rule is missing' }
    if ($c -notmatch '(?i)public (interface|api)') { throw 'the public-API rule is missing' }
    $c -match '(?i)ADR 0007|0007'
  }

  # The primary caller reviews before committing (implement/SKILL.md §4), so
  # the whole change is uncommitted. A review that diffs only a commit range
  # sees nothing and reports a clean pass on it.
  Assert "the subject includes uncommitted work — /implement reviews before the commit" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)uncommitted') { throw 'uncommitted work is never reviewed' }
    if ($c -notmatch '(?i)untracked') { throw 'untracked files are never reviewed' }
    $c -match '(?i)(before|prior to) the commit|working tree, not just'
  }

  # A bad ref or an empty diff must fail before two subagents are spawned on
  # nothing — the failure is invisible once it is inside them.
  Assert "the fixed point is pinned and proven before any subagent is spawned" {
    $c = Get-SkillFile 'review/SKILL.md'
    # Structural, not textual: pinning has to be an earlier *step* than running
    # the axes. Naming subagents in the description is not spawning them.
    if (-not [regex]::IsMatch($c, '(?im)^#{2,}\s.*fixed point')) { throw 'pinning the fixed point is not its own step' }
    if (-not [regex]::IsMatch($c, '(?im)^#{2,}\s.*\baxes\b')) { throw 'running the axes is not its own step' }
    $pin = [regex]::Match($c, '(?im)^#{2,}\s.*fixed point').Index
    $run = [regex]::Match($c, '(?im)^#{2,}\s.*\baxes\b').Index
    if ($run -lt $pin) { throw 'the axes run before the fixed point is pinned' }
    # `(?s)` — the emptiness check and the stop it triggers are on separate
    # lines, and `.` does not cross a newline in .NET.
    $c -match '(?si)(empty|non-empty).{0,200}(before|stop|fail)'
  }

  # Three-dot, so the comparison is against the merge-base. Two-dot silently
  # reviews whatever landed on the base branch since the work started.
  Assert "the diff is taken against the merge-base, and the invocation is not guessed" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)merge-?base') { throw 'the merge-base is never named' }
    $c -match '.claude/tools/git.md'
  }

  Assert "the two axes are reported separately, never merged or reranked" {
    $c = Get-SkillFile 'review/SKILL.md'
    $c -match '(?i)(never|not|do not|don.t) (merge|rerank|re-rank)|(merge|rerank|re-rank).{0,60}(defeats|masks|is the)'
  }

  Assert "the Spec axis reaches missing requirements, scope creep, and wrong implementations" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)(missing|partial)') { throw 'missing requirements are not reached' }
    if ($c -notmatch '(?i)scope creep|was ?n.t asked for|not asked for') { throw 'scope creep is not reached' }
    $c -match '(?i)(implemented but|looks? implemented|wrong).{0,120}(wrong|incorrect|does not)|(wrong|incorrectly).{0,60}implement'
  }

  Assert "a missing spec is reported, never invented" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)no spec') { throw 'the missing-spec case is not handled' }
    $c -match '(?i)(never|do not|don.t) (invent|guess|reconstruct|infer)'
  }

  # Ticket 02 / CLAUDE.template.md: /review reads Context for boundaries
  # and Decisions for ADRs, so it is a skill that relies on Context and owes a
  # report. Silence is indistinguishable from the check never having run.
  Assert "/review opens with a verification report, because it relies on Context" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)verification report') { throw 'no verification report' }
    $c -match '(?ms)^```\s*$.*?Verification.*?^```\s*$'
  }

  # Ticket 02's placement rule, checked where a fourth file could restate it.
  # A paraphrase is duplication too — "when the Marker equals HEAD and the tree
  # is clean" restates CLAUDE.template.md's rule without repeating its symbols.
  Assert "/review does not restate the Marker rule" {
    $c = Get-SkillFile 'review/SKILL.md'
    $c -notmatch '(?i)marker.{0,80}(==|matches|equals|is the same as).{0,40}HEAD'
  }

  # ADR 0001. Every skill derived from matt's says so.
  Assert "attribution to mattpocock survives" {
    $c = Get-SkillFile 'review/SKILL.md'
    $c -match '(?i)mattpocock/skills'
  }
}

# --- ticket tenure/06 — /commit, the transaction boundary ---------------------------

Describe-Ticket 'tenure/06' 'the transaction boundary' {

  Assert "/commit ships as a skill" {
    Test-Path (Join-Path $skills 'commit/SKILL.md')
  }

  # Spec, Scope: "/commit is model-invoked because /implement closes out
  # through it. Typed directly, it handles work with no ticket."
  Assert "/commit is model-invoked — /implement closes out through it" {
    $fm = Get-Frontmatter (Get-SkillFile 'commit/SKILL.md')
    if ($fm -notmatch '(?m)^name:\s*commit\s*$') { throw 'the skill is not named commit' }
    -not (Test-UserInvoked 'commit/SKILL.md')
  }

  Assert "work with no ticket is /commit's — the direct-invocation path is stated" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $c -match '(?i)(no ticket|without a ticket|hand-written)'
  }

  # It reads Context to ask the diff-vs-knowledge question, so the always-on
  # rule applies: every skill relying on Context opens with a report.
  Assert "step 0 is a verification report" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)verification report') { throw 'no verification report named' }
    $c -match '(?ms)^```\s*$.*?Verification.*?^```\s*$'
  }

  # --- confirm, don't repeat -------------------------------------------------

  # The headline acceptance criterion. Re-running the suite here is the
  # rediscovery ADR 0010 removed from sync — /implement already ran it.
  Assert "/commit never runs tests, never reviews, never researches" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)never runs?( the)? (tests|suite)') { throw 'running tests is not forbidden' }
    if ($c -notmatch '(?i)never reviews?') { throw 'reviewing is not forbidden' }
    if ($c -notmatch '(?i)never research') { throw 'researching is not forbidden' }
    # An imperative at the start of a line is an instruction to do it, whatever
    # the prose elsewhere says. A question about state is not.
    $imperatives = ((Get-SkillFile 'commit/SKILL.md') -split '\r?\n') |
      Where-Object { $_ -match '(?i)^\s*[-*]?\s*(run|re-?run) the (full )?(test )?suite' }
    if ($imperatives) { throw "the suite is run here — $($imperatives -join '; ')" }
    $true
  }

  Assert "all three confirmations are asked — tests, review findings, and finished against the ticket" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $m = [regex]::Match($c, '(?ims)^#{2,}\s.*confirm.*?(?=^#{2}\s|\z)')
    if (-not $m.Success) { throw 'confirming the prior stages is not its own step' }
    $step = $m.Value
    if ($step -notmatch '(?i)(tests|suite)') { throw 'the test question is missing' }
    if ($step -notmatch '(?i)/review') { throw 'the review question is missing' }
    $step -match '(?i)(finished|complete|done).{0,80}(ticket|spec)'
  }

  # Decision 33: fixed, ticketed, or accepted-and-recorded. A finding with no
  # outcome walking into a commit is the silent pass this check exists to stop.
  Assert "an unresolved review finding blocks the commit — never a silent pass" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*confirm.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'confirming the prior stages is not its own step' }
    if ($step -notmatch '(?i)finding') { throw 'review findings are never mentioned' }
    # Grouped. `(never|not) a silent pass|silent pass` binds as
    # `((never|not) a silent pass)` OR `(silent pass)`, so the bare branch
    # passes on "a silent pass is fine" — the one sentence this has to reject.
    if ($step -notmatch '(?i)\b(never|not)\b[^.]{0,40}silent pass') {
      throw 'a silent pass is not forbidden'
    }
    # And the finding has to go somewhere, per decision 33.
    $step -match '(?i)blocker|ticket'
  }

  # Acceptance: "A validation failure names the incomplete stage rather than
  # reporting a generic refusal." A refusal the user cannot act on is a wall.
  Assert "a refusal names the incomplete stage rather than refusing generically" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)name[sd]? (the|which) (incomplete )?stage|says which stage') {
      throw 'the refusal does not name the stage'
    }
    $c -match '(?i)(reported|refus).{0,120}(not fixed|never fixed|does not fix)|(not fixed|never fixed|does not fix).{0,120}(report|refus)'
  }

  # --- the diff against knowledge --------------------------------------------

  # Not rediscovery: /implement sees one ticket, /commit sees the change entire.
  # That is what makes this /commit's and nobody else's.
  # Scoped to the step, not the file — the frontmatter description says "the
  # whole diff" too, so a file-wide check stays green with the entire rationale
  # for why this belongs to /commit deleted from the body.
  Assert "the knowledge check is a whole-diff question no earlier stage could ask" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '\.claude/context\.md') { throw 'context.md is never read' }
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*knowledge.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'the knowledge check is not its own step' }
    $step -match '(?i)whole[- ]diff|the change entire|one ticket at a time'
  }

  Assert "a diff that contradicts Context blocks the commit until Context is corrected" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $c -match '(?i)(contradict|disagree)[a-z]*.{0,200}(block|stop|not commit|before commit)|(block|stop)[a-z]*.{0,200}contradict'
  }

  # ADR 0005 leaves authorship with /implement and /design. What /commit does
  # here is healing — correcting what the diff falsified — not writing new
  # knowledge, and the boundary has to be stated or it erodes into authorship.
  Assert "/commit heals what the diff falsified and authors nothing new" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)compression test') { throw 'the compression test does not gate what is written' }
    $c -match '(?i)(does not|never) (author|write) (new )?(concepts|vocabulary)|authors? nothing new'
  }

  # --- the message -----------------------------------------------------------

  # ADR 0008: every Tenure convention is a default that applies when the
  # repository is silent, and detection reads three sources, not two.
  Assert "the convention is detected before it is applied, from all three sources" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*message.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'the message is not its own step' }
    if ($step -notmatch '(?i)default') { throw 'the convention is stated as a mandate, not a default' }
    foreach ($src in @('CONTRIBUTING\.md', 'PULL_REQUEST_TEMPLATE', 'git log')) {
      if ($step -notmatch $src) { throw "detection does not read $src" }
    }
    # Ordering, and actually compared. The first draft computed both indices
    # under a comment about ordering and then returned an unrelated regex.
    $detect = [regex]::Match($step, 'CONTRIBUTING\.md')
    $wins = [regex]::Match($step, '(?i)(where|when) the repo[a-z]*[^.]{0,140}(wins|follow)')
    if (-not $detect.Success) { throw 'CONTRIBUTING.md is not read' }
    if (-not $wins.Success) { throw "the repository's own convention does not win" }
    $detect.Index -lt $wins.Index
  }

  # ADR 0007. CLAUDE.template.md:114 is the always-on home for this — it covers
  # PR and issue titles too, which /commit never writes. The first draft
  # restated the scope vocabulary here, and the assertion that came with it
  # required the breach to be present in order to pass.
  Assert "the scope vocabulary is not restated here — CLAUDE.md owns it" {
    $c = Get-SkillFile 'commit/SKILL.md'
    foreach ($bad in @('misc', 'stuff')) {
      if ($c -match "(?i)``$bad``") { throw "the scope vocabulary is restated: $bad" }
    }
    $c -match 'CLAUDE\.md'
  }

  Assert "the message says what capability changed, never a file-by-file account" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*message.*?(?=^#{2}\s|\z)').Value
    if ($step -notmatch '(?i)capabilit') { throw 'the message does not say what capability changed' }
    # Unnegated and file-wide, this passes on "give a file-by-file account".
    $step -match '(?i)\b(never|not|no)\b[^.]{0,30}file-by-file'
  }

  # --- the spec status -------------------------------------------------------

  # Decision 23: a document's reasoning is frozen; only its status moves.
  Assert "a completed spec is marked implemented, and only the status line moves" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)implemented') { throw 'the spec is never marked implemented' }
    $c -match '(?i)only the status line|content is never rewritten|reasoning is frozen'
  }

  # Cross-file: /commit writes a status SPEC-FORMAT has to recognise, and the
  # freeze rule has one home — the format file, not the actor. Before this,
  # SPEC-FORMAT listed draft/accepted/superseded and knew nothing of the status
  # /commit writes.
  Assert "the status /commit writes is one SPEC-FORMAT defines, and the freeze rule stays there" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $fmt = Get-SkillFile 'design/SPEC-FORMAT.md'
    # Against the enumeration line, not the section. SPEC-FORMAT names
    # `implemented` again further down when saying who writes it, so a
    # section-wide check survives the term being cut from the vocabulary itself.
    $vocab = (($fmt -split '\r?\n') | Where-Object { $_ -match '`draft`' }) -join ' '
    if (-not $vocab) { throw 'SPEC-FORMAT has no status vocabulary line' }
    # Only the spec step. `Status: resolved` elsewhere in the file is a
    # *ticket* status and answers to the build lifecycle, not to this format.
    $specStep = [regex]::Match($c, '(?ims)^#{2,}[^\n]*mark the spec.*?(?=^#{2}\s|\z)').Value
    if (-not $specStep) { throw 'marking the spec is not its own step' }
    foreach ($written in [regex]::Matches($specStep, '(?i)Status:\s*([a-z-]+)')) {
      $s = $written.Groups[1].Value
      if ($vocab -notmatch "``$s``") { throw "/commit writes Status: $s, which SPEC-FORMAT does not define" }
    }
    if ($fmt -notmatch '(?i)only the status line') { throw 'the freeze rule is not in SPEC-FORMAT' }
    if ($c -notmatch 'SPEC-FORMAT\.md') { throw '/commit does not point at the format' }
    # The rationale belongs to the format file. /commit carries the imperative.
    $c -notmatch '(?i)stops being evidence'
  }

  # Ordering, not presence. The spec file is tracked, so marking it after the
  # commit leaves the tree dirty — and a dirty tree defeats the Marker's clean
  # path on the very next turn, which is the whole reason the Marker exists.
  Assert "the spec status is staged into the commit, not left dirty behind it" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $spec = [regex]::Match($c, '(?im)^#{2,}\s.*mark the spec')
    $make = [regex]::Match($c, '(?im)^#{2,}\s.*make the commit')
    if (-not $spec.Success) { throw 'marking the spec is not its own step' }
    if (-not $make.Success) { throw 'making the commit is not its own step' }
    $spec.Index -lt $make.Index
  }

  # --- the Marker ------------------------------------------------------------

  # ADR 0005: a commit cannot contain its own SHA. This ordering is the reason
  # the Marker is machine-local at all, so getting it backwards undoes the ADR.
  Assert "the Marker is written after the commit exists, and the reason is given" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $make = [regex]::Match($c, '(?im)^#{2,}\s.*make the commit')
    $mark = [regex]::Match($c, '(?im)^#{2,}\s.*advance the marker')
    # Both guarded: .Index is 0 on a failed match, so an unguarded $make turns
    # a renamed heading into a passing ordering check.
    if (-not $make.Success) { throw 'making the commit is not its own step' }
    if (-not $mark.Success) { throw 'advancing the Marker is not its own step' }
    if ($mark.Index -lt $make.Index) { throw 'the Marker is written before the commit exists' }
    $c -match '(?i)cannot contain its own SHA'
  }

  # /commit is the Marker's only writer, so the file's shape is /commit's to
  # define. Nowhere else in Tenure says what is in it.
  Assert "the Marker's shape is defined, since /commit is its only writer" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '\.claude/marker\.json') { throw 'the Marker path is never named' }
    $c -match '(?ms)^```\s*json\s*$.*?commit.*?^```\s*$'
  }

  # A Marker that is not ignored gets committed, and then it points at the
  # parent of the commit it describes — the phantom-verification loop ADR 0005
  # made the file machine-local to avoid.
  Assert "the Marker is confirmed gitignored before it is written" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $c -match '(?i)(ignored|gitignore).{0,200}(before|check|confirm)|(before|check|confirm)[a-z]*.{0,200}(ignored|gitignore)'
  }

  # Acceptance: "The Marker equals HEAD after a successful commit, so the next
  # verification is a single git check and nothing more."
  Assert "the Marker equals HEAD after a successful commit" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $c -match '(?i)marker.{0,120}(==|equals|matches).{0,40}HEAD|HEAD.{0,40}(==|equals|matches).{0,120}marker'
  }

  # Ticket 04: "the Marker re-advances on every amend — through /commit,
  # exactly as the first commit did." /commit is the shared implementation, so
  # the amend path has to exist here or /implement's rule has no home.
  Assert "an amend re-advances the Marker, because the SHA changed" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)amend') { throw 'the amend path is missing' }
    $c -match '(?i)amend.{0,200}(new SHA|marker)|(new SHA|marker).{0,200}amend'
  }

  # --- boundaries ------------------------------------------------------------

  Assert "/commit never pushes, and no fenced git push reads as an instruction" {
    $lines = (Get-SkillFile 'commit/SKILL.md') -split '\r?\n'
    if (($lines -join "`n") -notmatch '(?i)never (runs |run )?`?git push|never pushes') {
      throw 'no explicit never-push rule'
    }
    $inFence = $false
    $offenders = @()
    foreach ($line in $lines) {
      if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
      if ($inFence -and $line -match '^\s*git\s+push' -and $line -notmatch '(?i)\b(never|do not|don.t|forbidden)\b') {
        $offenders += $line.Trim()
      }
    }
    if ($offenders) { throw ($offenders -join '; ') }
    $true
  }

  # /implement sets Status: resolved after /commit returns (ticket 04). Two
  # writers for one field is how a ticket ends up resolved for a commit that
  # was refused.
  Assert "/commit does not resolve tickets — that stays /implement's" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $c -match '(?i)(does not|never) (resolve|set).{0,80}(ticket|status: resolved)|resolv[a-z]*.{0,80}(stays|remains|is) /implement'
  }

  # This repository is the case: no .claude/ at all until ticket 12 runs.
  # A skill that assumes the layout exists refuses every commit in a repo that
  # has not been configured, which is every repo before /configure.
  Assert "a repository with no .claude/ still commits, and says what it skipped" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)(no|without|absent) `?\.claude') { throw 'the unconfigured repository is never considered' }
    # Both steps that read .claude/ have to say what they do without it. A
    # file-wide check passes when one of them drops its branch, because the
    # other still names the case.
    foreach ($h in @('knowledge', 'advance the marker')) {
      $step = [regex]::Match($c, "(?ims)^#{2,}[^\n]*$h.*?(?=^#{2}\s|\z)").Value
      if (-not $step) { throw "no step matching '$h'" }
      if ($step -notmatch '(?i)(no|without|unconfigured)[^.]{0,60}(\.claude|Context to contradict|Marker to advance)') {
        throw "the '$h' step does not say what it does in an unconfigured repository"
      }
    }
    # Naming the case is not handling it — the commit still has to happen.
    $c -match '(?i)carry on'
  }

  # Ticket 15 owns the invocations. A third copy of the staging and amend
  # commands is the duplication ADR 0007 exists to stop.
  Assert "the git invocations are pointed at, not restated" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '.claude/tools/git.md') { throw '.claude/tools/git.md is never referenced' }
    if ($c -match '(?m)^git status --porcelain') { throw 'the uncommitted drift read is restated' }
    if ($c -match '(?m)^git diff --name-only') { throw 'the Marker diff read is restated' }
    $c -notmatch '(?im)^\s*never\s+`?git commit -a'
  }
}

# --- ticket tenure/07 — /research and /prototype, the evidence commands -------------

Describe-Ticket 'tenure/07' 'vendor /research and /prototype' {

  foreach ($s in @('research', 'prototype')) {
    Assert "/$s ships as a skill" {
      Test-Path (Join-Path $skills "$s/SKILL.md")
    }

    # Acceptance: "Neither is user-invoked — /design must be able to reach both."
    Assert "/$s is model-invoked — /design reaches it at the Heavyweight gate" {
      $fm = Get-Frontmatter (Get-SkillFile "$s/SKILL.md")
      if ($fm -notmatch "(?m)^name:\s*$s\s*$") { throw "the skill is not named $s" }
      -not (Test-UserInvoked "$s/SKILL.md")
    }
  }

  # --- /research -------------------------------------------------------------

  # Scoped to the step that writes it. "one small cited file" appears up in the
  # dispatch rationale, so a file-wide check stays green with the one-file rule
  # deleted from the place it governs.
  Assert "findings are written to .claude/evidence/research/, as one cited file" {
    $c = Get-SkillFile 'research/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*write one cited file.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'writing the findings is not its own step' }
    if ($step -notmatch '\.claude/evidence/research/') { throw 'the findings location is wrong or missing' }
    $step -match '(?i)one question, one[^\n]{0,40}file'
  }

  # "Follow every claim back to the source that owns it" — a claim with no
  # source is the thing research exists to replace. The citation has to sit on
  # the claim: a sources section at the bottom loses the mapping, and the
  # mapping is what makes the finding checkable.
  Assert "every claim is traced to its source, on the line that makes the claim" {
    $c = Get-SkillFile 'research/SKILL.md'
    if ($c -notmatch '(?i)(every|each) claim[^\n]{0,120}source') { throw 'claims are not traced to a source' }
    $c -match '(?i)carries its citation'
  }

  Assert "primary sources only — a secondary write-up is rejected, not just named" {
    $c = Get-SkillFile 'research/SKILL.md'
    if ($c -notmatch '(?i)primary source') { throw 'primary sources are never required' }
    # Naming secondary sources is not rejecting them — the skill says elsewhere
    # what to do when one is unavoidable, which satisfies a bare presence check.
    $c -match '(?i)secondary write-?up[^\n]{0,140}(stale|half-remembered)'
  }

  # The distinction the ticket draws explicitly: isolation is why a subagent is
  # used; whether /design waits is a separate axis. Conflating them turns every
  # gated question into a background one.
  Assert "the subagent is for context isolation, not for skipping the wait" {
    $c = Get-SkillFile 'research/SKILL.md'
    if ($c -notmatch '(?i)sub-?agent') { throw 'no subagent' }
    $c -match '(?i)context isolation|isolat[a-z]+[^.]{0,80}context'
  }

  # ADR 0007. design/SKILL.md §4 owns gating — it is /design that decides at the
  # gate and /design that waits. /research states only which of the two this
  # dispatch is, because a subagent cannot tell from the inside.
  Assert "whether the caller blocks is /design's rule, not restated here" {
    $c = Get-SkillFile 'research/SKILL.md'
    if ($c -match '(?i)ungated[^\n]{0,120}background') { throw 'the gating rule is restated here' }
    $c -match '(?i)(caller blocks|blocks on the answer)[^\n]{0,120}/design'
  }

  # A fact about an external API is true at a version, not forever. Checked in
  # the template, because that is the thing that gets filled in — the words
  # "version" and "date" appear in the surrounding prose either way.
  Assert "findings record what they were verified against — version and date" {
    $c = Get-SkillFile 'research/SKILL.md'
    $tpl = [regex]::Match($c, '(?ms)^```markdown\s*$.*?^```\s*$').Value
    if (-not $tpl) { throw 'there is no findings template' }
    if ($tpl -notmatch '(?i)verified against') { throw 'the template has no verified-against line' }
    if ($tpl -notmatch '(?i)version') { throw 'the template records no version' }
    if ($tpl -notmatch '(?i)date') { throw 'the template records no date' }
    # And the reason, outside it. A template field with no rule behind it gets
    # filled with whatever is to hand.
    $c -match '(?i)true at a version, not forever'
  }

  # ADR 0005 and the layering: a versioned external fact copied into Context
  # lands in a layer that has no version and nothing to re-verify it against.
  # The prohibition itself is asserted for both skills below. What is specific
  # to research is the reason: Context has no version, so a fact that was only
  # ever true of one lands there stripped of the thing that made it checkable.
  Assert "the reason /research never writes Context is given, not just the rule" {
    $c = Get-SkillFile 'research/SKILL.md'
    $c -match '(?i)version[^\n]{0,120}(layer|context)[^\n]{0,80}no version|no version[^\n]{0,120}re-verify'
  }

  # `[^\n]` rather than `[^.]` — the directory this has to name is full of dots,
  # so a sentence-scoped pattern can never span it.
  Assert "existing research is read before new research is started" {
    $c = Get-SkillFile 'research/SKILL.md'
    if ($c -notmatch '\.claude/evidence/research/') { throw 'the findings directory is never read back' }
    $c -match '(?i)before (starting|beginning)[^\n]{0,40}research|(existing|recorded)[^\n]{0,60}before[^\n]{0,40}research'
  }

  # --- /prototype ------------------------------------------------------------

  foreach ($branch in @('LOGIC.md', 'UI.md')) {
    Assert "the $branch branch is disclosed behind a pointer, not inlined" {
      $skill = Get-SkillFile 'prototype/SKILL.md'
      if (-not (Test-Path (Join-Path $skills "prototype/$branch"))) { throw "prototype/$branch is missing" }
      $skill -match [regex]::Escape($branch)
    }
  }

  # The distinction the ticket calls out: throwaway *code* and its *write-up*
  # live apart, and the write-up outlives the code.
  # Against the table that declares them, not the file. Both paths are named
  # several times over, so a file-wide check survives either one being moved
  # out of .claude/ where it is actually specified.
  Assert "code lives in .claude/prototypes/, the write-up in .claude/evidence/prototypes/" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    $table = [regex]::Match($c, '(?ms)^\|\s*What\s*\|.*?(?=\r?\n\r?\n)').Value
    if (-not $table) { throw 'the two locations are not declared in one table' }
    if ($table -notmatch '`\.claude/prototypes/') { throw 'the code location is wrong or missing' }
    if ($table -notmatch '`\.claude/evidence/prototypes/') { throw 'the write-up location is wrong or missing' }
    $c -match '(?i)deliberately \*{0,2}apart'
  }

  # A UI variant has to render against the real application to be judged, so it
  # cannot live in a gitignored scratch directory. That exception is real and
  # the skill has to name it — unnamed, the two files simply disagree about
  # where prototype code lives, and the un-ignored one gets committed.
  Assert "the in-application UI variant is named as the exception, and still deleted" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    # Bound to the case. "no reusable-harness exception" two sections down
    # satisfies a bare `exception` match with this whole paragraph deleted.
    if ($c -notmatch '(?i)(exception|the one case)[^\n]{0,200}(mounted|renders|running application)') {
      throw 'the in-application variant is not named as the exception'
    }
    if ($c -notmatch '(?i)not\*{0,2} gitignored|\*{0,2}not\*{0,2} gitignored') { throw 'it is not said to be un-ignored' }
    $c -match '(?i)(harder|not softer|same change that records)'
  }

  # ADR 0009. The carve-out would be claimed for almost every prototype at the
  # moment of finishing it, which is when reusability is most overestimated.
  Assert "prototype code is always deleted — there is no reusable-harness exception" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    if ($c -notmatch '(?i)always deleted') { throw 'deletion is not unconditional' }
    # Ungrouped, `no ... exception|reusable harness` passes on "a reusable
    # harness may be kept" — the one sentence this exists to reject.
    $c -match '(?i)no reusable[- ]harness exception'
  }

  Assert ".claude/prototypes/ is gitignored scratch" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    # Bound to the directory. `.claude/.gitignore` is named in the same
    # paragraph, so a bare `gitignor` match survives the rule being cut.
    $c -match '(?i)`\.claude/prototypes/`[^\n]{0,40}\*{0,2}gitignored'
  }

  # The ordering is the whole mechanism: deleting code that took real effort is
  # resisted in the moment, and the discipline holds only because the write-up
  # comes first.
  Assert "the write-up is written before the code is deleted" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    $c -match '(?i)(written|write it|record[a-z]*)[^.]{0,80}before[^.]{0,60}delet|not finished until'
  }

  # Against the template, not the file. Every one of these words also occurs in
  # the surrounding prose, so a file-wide loop passes with the template gutted.
  Assert "the write-up template carries every field the ticket names" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    $tpl = [regex]::Match($c, '(?ms)^```markdown\s*$.*?^```\s*$').Value
    if (-not $tpl) { throw 'there is no write-up template' }
    $missing = @()
    foreach ($field in @('question', 'hypothesis', 'method', 'limitation', 'result', 'conclusion')) {
      if ($tpl -notmatch "(?i)$field") { $missing += $field }
    }
    if ($missing) { throw "missing from the template: $($missing -join ', ')" }
    # Same rule as a research finding: a result is true of a version, on a date.
    if ($tpl -notmatch '(?i)verified against') { throw 'the template has no verified-against line' }
    if ($tpl -notmatch '(?i)version') { throw 'the template records no version' }
    $tpl -match '(?i)date'
  }

  # Against the template's own Conclusion line. Three of the four verdicts are
  # named again in the prose below, so a file-wide check stays green with one
  # of them dropped from the field a writer actually fills in.
  Assert "the conclusion is one of the four, with reasoning" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    $line = (($c -split '\r?\n') | Where-Object { $_ -match '(?i)^Conclusion:' }) -join ' '
    if (-not $line) { throw 'the write-up template has no Conclusion field' }
    foreach ($v in @('Successful', 'Partially Successful', 'Failed', 'Inconclusive')) {
      if ($line -notmatch [regex]::Escape($v)) { throw "conclusion missing from the template: $v" }
    }
    $c -match '(?i)with the reasoning'
  }

  # Required for Failed and Inconclusive — the highest-value case, because a
  # recorded failure stops the experiment being run again — and for an
  # unpromoted Successful one. Named for what it checks: the ticket scopes the
  # exemption to the *conclusion*, and the write-up itself is never skippable.
  Assert "the conclusion is exempt only when the prototype was promoted" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    if ($c -notmatch '(?i)optional only when') { throw 'the exemption is not stated as the only one' }
    foreach ($required in @('Failed', 'Inconclusive')) {
      if ($c -notmatch "(?i)required[^\n]{0,120}$required") { throw "$required does not require a conclusion" }
    }
    # `-match '(?i)promot'` cannot fail here — the whole of step 5 is about
    # promotion. The exemption has to be bound to it.
    $c -match '(?i)optional only when[^\n]{0,60}promot'
  }

  # A prototype answering a feel question is worthless until the user looks at
  # it, and prose describing a UI is not looking at it.
  Assert "a feel question hands back a way to see it, never prose alone" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    if ($c -notmatch '(?i)(command that runs|run skill|`run`)') { throw 'no way to run it is handed back' }
    $c -match '(?i)(describe|prose)[^.]{0,100}(not|never)|(not|never)[^.]{0,100}(describe .{0,20}in prose|prose)'
  }

  Assert "reuse operates on the write-up, not on code that no longer exists" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    $c -match '(?i)reuse[^.]{0,120}write-?up'
  }

  Assert "promotion is a fresh implementation effort, not a file move" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    # Both halves. The name claimed the first and only ever checked the second.
    if ($c -notmatch '(?i)fresh implementation effort') { throw 'promotion is not a fresh effort' }
    $c -match '(?i)(not|never)[^\n]{0,60}(a file move|moving files)'
  }

  # --- both: evidence, and how it graduates ----------------------------------

  # Decision 18 / ADR 0009. Evidence records what was verified and when;
  # nothing validates it afterwards, which is exactly why it is not knowledge.
  foreach ($s in @('research', 'prototype')) {
    # ADR 0007 again. design/SKILL.md §4 states the graduation rule and both its
    # destinations. What belongs in an evidence-producing skill is the boundary
    # it must not cross — it writes evidence, and never writes knowledge.
    Assert "/$s writes Evidence and never writes knowledge itself" {
      $c = Get-SkillFile "$s/SKILL.md"
      # Bound to the claim, not the word. "Evidence" also appears in the
      # section heading and in the graduation pointer, so a bare \bEvidence\b
      # survives the skill calling its own output knowledge.
      if ($c -notmatch '(?i)is \*{0,2}Evidence\*{0,2}:') { throw 'what it produces is never called Evidence' }
      if ($c -match '(?i)owns that graduation') { throw 'the graduation rule is restated here' }
      if ($c -notmatch '(?i)never write Context directly') { throw 'the boundary is not stated' }
      $c -match '(?i)graduat[a-z]*[^\n]{0,120}/design'
    }
  }

  # matt's originals end by committing the prototype to a throwaway branch and
  # leaving a pointer to it — a primary source to come back to. ADR 0009 says
  # the opposite and wins: the code is deleted, and the write-up is the artifact.
  # Vendoring this unaltered is the failure the alteration checklist exists for.
  Assert "no prototype file keeps the code on a branch — ADR 0009 supersedes that" {
    $offenders = @()
    foreach ($f in (Get-ChildItem (Join-Path $skills 'prototype') -File -Filter *.md)) {
      foreach ($line in ((Get-Content $f.FullName -Raw) -split '\r?\n')) {
        if ($line -match '(?i)(throwaway|prototype) branch|branch.{0,40}primary source') {
          $offenders += "$($f.Name): $($line.Trim())"
        }
      }
    }
    if ($offenders) { throw ($offenders -join '; ') }
    $true
  }

  # ADR 0001, checked across every file both skills ship.
  Assert "attribution to mattpocock survives in both skills" {
    foreach ($f in @('research/SKILL.md', 'prototype/SKILL.md', 'prototype/LOGIC.md', 'prototype/UI.md')) {
      if ((Get-SkillFile $f) -notmatch '(?i)mattpocock/skills') { throw "no attribution in $f" }
    }
    $true
  }
}

# --- ticket tenure/09 — the gap-fillers, and the tracker's one home -----------------

Describe-Ticket 'tenure/09' 'vendor the gap-fillers' {

  $onramps = @('triage', 'diagnosing-bugs', 'handoff', 'resolving-merge-conflicts',
               'survey')

  foreach ($s in $onramps) {
    Assert "$s is vendored into ./skills" {
      Test-Path (Join-Path $skills "$s/SKILL.md")
    }
  }

  # Alteration checklist item 3. Kept from matt's, because his axes already
  # satisfy the rule: the two that must fire from a description of the problem
  # are model-invoked, and the three a human types are not.
  $axis = @{
    'triage'                        = $true
    'handoff'                       = $true
    'survey' = $true
    'diagnosing-bugs'               = $false
    'resolving-merge-conflicts'     = $false
  }
  foreach ($s in $axis.Keys) {
    $userInvoked = $axis[$s]
    Assert "$s is $(if ($userInvoked) { 'user' } else { 'model' })-invoked" {
      $disabled = Test-UserInvoked "$s/SKILL.md"
      if ($userInvoked -ne $disabled) {
        throw "$s is $(if ($disabled) { 'user' } else { 'model' })-invoked, which is the wrong axis"
      }
      $true
    }
  }

  # Acceptance: "No vendored skill references a mattpocock path." The
  # attribution URL is not a path — a setup command that does not exist in
  # Tenure is, and it is how a vendored skill silently stops working.
  Assert "no skill points at matt's installer or his skill directory" {
    $offenders = Get-SkillFiles |
      Select-String -Pattern 'setup-matt-pocock-skills|ask-matt|\.claude[\\/]skills[\\/](triage|prototype|research)' |
      ForEach-Object { "$(Split-Path -Leaf $_.Path):$($_.LineNumber)" }
    if ($offenders) { throw ($offenders -join ', ') }
    $true
  }

  Assert "every vendored gap-filler keeps its attribution" {
    $missing = @()
    foreach ($s in $onramps) {
      foreach ($f in (Get-ChildItem (Join-Path $skills $s) -File -Filter *.md -ErrorAction SilentlyContinue)) {
        if ((Get-Content $f.FullName -Raw) -notmatch '(?i)mattpocock/skills') { $missing += "$s/$($f.Name)" }
      }
    }
    if ($missing) { throw ($missing -join ', ') }
    $true
  }

  # --- the tracker's one home ------------------------------------------------

  # Acceptance: "The issue-tracker configuration has exactly one home, and every
  # skill reading it agrees." /configure writes the file; ticket 09 places the
  # template, exactly as ticket 02 placed CLAUDE.template.md before ticket 08.
  Assert "the tracker template ships, and names .claude/tracker.md as its home" {
    $t = Get-SkillFile 'configure/tracker.template.md'
    $t -match '\.claude/tracker\.md'
  }

  # Decision 35: GitHub and local markdown are both first-class. A template
  # that documents one and mentions the other is not two first-class trackers.
  Assert "both trackers are first-class — GitHub and local markdown" {
    $t = Get-SkillFile 'configure/tracker.template.md'
    if ($t -notmatch '(?i)github') { throw 'GitHub is not covered' }
    if ($t -notmatch '(?i)local markdown') { throw 'local markdown is not covered' }
    if ($t -notmatch '\.claude/tickets/') { throw 'the local ticket location is not given' }
    $t -match '(?i)both[^\n]{0,80}first-class|first-class[^\n]{0,80}both'
  }

  # Decision 34 / alteration checklist item 4: the commands are in tools/, and
  # a guessed `gh` flag here is the duplication ticket 15 exists to stop.
  Assert "tracker operations point at tools/github.md rather than inlining gh" {
    $t = Get-SkillFile 'configure/tracker.template.md'
    if ($t -notmatch '.claude/tools/github.md') { throw 'the gh reference is missing or guessed' }
    # Ticket 09 says `tools/gh.md`; the file ticket 15 shipped is github.md.
    if ($t -match '\.claude/tools/gh\.md') { throw 'points at .claude/tools/gh.md, which does not exist' }
    $true
  }

  # Ticket 09: "Triage label vocabulary folds into the same file rather than
  # getting one of its own."
  Assert "the triage label vocabulary lives in the tracker file, not its own" {
    $t = Get-SkillFile 'configure/tracker.template.md'
    $roles = @('needs-triage', 'needs-info', 'ready-for-agent', 'ready-for-human', 'wontfix')
    $absent = $roles | Where-Object { $t -notmatch [regex]::Escape($_) }
    if ($absent) { throw "roles missing from the tracker file: $($absent -join ', ')" }
    # And nowhere else under ./skills may define a competing mapping.
    $rivals = Get-SkillFiles |
      Where-Object { $_.Name -match '(?i)label' } |
      ForEach-Object { $_.Name }
    if ($rivals) { throw "a second home for labels: $($rivals -join ', ')" }
    $true
  }

  Assert "every skill that reads tracker config reads .claude/tracker.md" {
    # Ticket 09 names three readers. Listing only the one that happens to
    # comply makes the assertion pass *because* of the gap it should catch.
    # /design's half is ticket 14's (its Comments say so); /implement is 09's.
    # /design's half landed in ticket 14, which is why it is here now: the
    # criterion passed on a two-name list while the third named reader had
    # nothing.
    $readers = @('triage/SKILL.md', 'implement/SKILL.md', 'design/TICKETS.md')
    foreach ($r in $readers) {
      $c = Get-SkillFile $r
      if ($c -notmatch '\.claude/tracker\.md') { throw "$r does not read the tracker config" }
      # Naming the file once in passing is not reading it as the source. It has
      # to be the only place, or a skill infers the half it did not look up.
      if ($c -notmatch '(?i)\.claude/tracker\.md[^\n]{0,200}(only place|one home|read it first)') {
        throw "$r does not treat the tracker file as the single source"
      }
    }
    $true
  }

  # --- triage ----------------------------------------------------------------

  # Against the Roles section. Every one of these words appears again in the
  # outcome step, so a file-wide loop passes with the vocabulary itself gutted.
  Assert "triage carries both category roles and all five state roles" {
    $c = Get-SkillFile 'triage/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*\bRoles\b.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'the roles are not defined in their own section' }
    # Each role must be *defined*, not merely named. The transitions paragraph
    # lists all five, so a presence check passes with a role's meaning deleted
    # — and a role nobody can define is one that gets applied by guesswork.
    foreach ($r in @('bug', 'enhancement', 'needs-triage', 'needs-info',
                     'ready-for-agent', 'ready-for-human', 'wontfix')) {
      if ($step -notmatch "(?m)``$r``\s+—\s+\S") { throw "role has no definition: $r" }
    }
    $true
  }

  # An AI-written comment on someone else's issue that does not say so is the
  # one thing here a maintainer cannot undo after the fact.
  Assert "every comment triage posts carries the AI disclaimer" {
    $c = Get-SkillFile 'triage/SKILL.md'
    if ($c -notmatch '(?i)generated by AI') { throw 'no disclaimer text' }
    # `(must|every) ... start with` passes on "Every comment ... may start with
    # a note" — the sentence that makes it optional. The obligation is the word
    # that has to survive.
    if ($c -notmatch '(?i)\*{0,2}must\*{0,2} start with') { throw 'the disclaimer is not mandatory' }
    $c -match '(?i)not optional'
  }

  foreach ($ref in @('AGENT-BRIEF.md', 'OUT-OF-SCOPE.md')) {
    Assert "triage discloses $ref behind a pointer, not inlined" {
      if (-not (Test-Path (Join-Path $skills "triage/$ref"))) { throw "triage/$ref is missing" }
      (Get-SkillFile 'triage/SKILL.md') -match [regex]::Escape($ref)
    }
  }

  # ADR 0003/0006: everything the workflow owns lives under .claude/.
  Assert "the out-of-scope knowledge base moved under .claude/" {
    $c = Get-SkillFile 'triage/OUT-OF-SCOPE.md'
    if ($c -notmatch '\.claude/evidence/out-of-scope/') { throw 'the location is not under .claude/evidence/' }
    $stray = Get-SkillFiles |
      Select-String -Pattern '(?<![\w/.])\.out-of-scope/' |
      ForEach-Object { "$(Split-Path -Leaf $_.Path):$($_.LineNumber)" }
    if ($stray) { throw "root-level .out-of-scope/ survives in: $($stray -join ', ')" }
    $true
  }

  # Recording an already-built feature as a rejection poisons the dedup check
  # that the whole knowledge base exists for.
  Assert "only a rejected enhancement is recorded — never one already built" {
    $c = Get-SkillFile 'triage/OUT-OF-SCOPE.md'
    if ($c -notmatch '(?i)already implemented') { throw 'the already-built case is not distinguished' }
    $c -match '(?i)(do\s+\*{0,2}not\*{0,2}|never) write'
  }

  # A brief may sit unclaimed for weeks; paths and line numbers do not survive
  # that, and a brief that has gone stale is worse than none.
  # Against the durability section. The bad-brief example at the bottom names
  # both failures too, so a file-wide check stays green with the rules deleted.
  Assert "an agent brief describes behaviour, never file paths or line numbers" {
    $c = Get-SkillFile 'triage/AGENT-BRIEF.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*durab.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'durability is not its own section' }
    if ($step -notmatch '(?i)(don.t|never|not)[^\n]{0,60}reference file paths') { throw 'file paths are not ruled out' }
    $step -match '(?i)(don.t|never|not)[^\n]{0,60}reference line numbers'
  }

  # --- diagnosing-bugs -------------------------------------------------------

  # The whole discipline: no red loop, no theory. This is the rule /implement
  # cites when it refuses to redesign, so it has to survive vendoring intact.
  Assert "no hypothesis is allowed before a loop that goes red" {
    $c = Get-SkillFile 'diagnosing-bugs/SKILL.md'
    # Both statements. Each survives the other being deleted, and the gate is
    # the one that fires while there is still time to obey it.
    if ($c -notmatch '(?i)(do not|don.t) proceed to hypothesise without a loop') {
      throw 'hypothesising without a loop is not forbidden'
    }
    $c -match '(?i)no red-capable command, no phase 2'
  }

  Assert "the completion criterion is a command already run, asserting the symptom" {
    $c = Get-SkillFile 'diagnosing-bugs/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*completion criterion.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'the completion criterion is not its own section' }
    if ($step -notmatch '(?i)already run') { throw 'the command need not have been run' }
    # Red-capable has to be defined here, not merely named — "it runs" is
    # exactly what the definition exists to reject.
    $step -match "(?i)red-capable[^\n]{0,240}(exact symptom|catch this specific bug)"
  }

  # matt's criterion allows a human in the loop, but only through a script that
  # drives them. Dropping the escape entirely makes every bug needing a click
  # unloopable, which sends the skill straight to the hypothesising it forbids.
  Assert "a human in the loop is allowed, but only a driven one" {
    $c = Get-SkillFile 'diagnosing-bugs/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*completion criterion.*?(?=^#{2}\s|\z)').Value
    if ($step -notmatch '(?i)human') { throw 'the human-in-the-loop case is dropped from the criterion' }
    $step -match '(?i)unstructured one is not|script that tells them'
  }

  # Context loading is demand-driven (ADR 0002): context.md, then the Domain
  # Contexts the routing table points at — never everything.
  Assert "diagnosing-bugs loads Context through the routing table" {
    $c = Get-SkillFile 'diagnosing-bugs/SKILL.md'
    if ($c -notmatch '\.claude/context\.md') { throw 'Context is never read' }
    $c -match '(?i)routing table|\.claude/contexts/'
  }

  # --- handoff ---------------------------------------------------------------

  Assert "a handoff is written outside the workspace" {
    $c = Get-SkillFile 'handoff/SKILL.md'
    $c -match '(?i)(temp|temporary)[^\n]{0,60}director|not[^\n]{0,40}(workspace|repository)'
  }

  # In Tenure most of the state a next session needs is already on disk. A
  # handoff that copies it creates a second, immediately-stale copy.
  Assert "a handoff points at artifacts rather than copying them" {
    $c = Get-SkillFile 'handoff/SKILL.md'
    if ($c -notmatch '(?i)(do not|don.t|never) duplicat') { throw 'duplication is not ruled out' }
    $c -match '(?i)(reference|point)[^\n]{0,60}(path|url|instead)'
  }

  Assert "a handoff redacts secrets before it is written" {
    $c = Get-SkillFile 'handoff/SKILL.md'
    $c -match '(?i)redact'
  }

  # --- survey ----------------------------------------------------------------

  # ADR 0011: /design is the whole planning surface. matt's runs its own
  # grilling and domain-modeling loop, which is exactly that surface rebuilt
  # inside a survey command.
  Assert "the chosen candidate goes to /design — the survey does not plan" {
    $c = Get-SkillFile 'survey/SKILL.md'
    # A step, not a mention. /design is named in the rationale either way, so a
    # presence check survives the hand-off step turning into a grill.
    if (-not [regex]::IsMatch($c, '(?im)^#{2,}[^\n]*(hand|pass)[a-z]* it to `?/design')) {
      throw 'handing the candidate to /design is not a step'
    }
    if ([regex]::IsMatch($c, '(?im)^#{2,}[^\n]*grill')) { throw 'the survey runs its own grill' }
    $c -match '(?i)(do not|don.t) grill here'
  }

  Assert "the architecture vocabulary comes from codebase-design, used exactly" {
    $c = Get-SkillFile 'survey/SKILL.md'
    if ($c -notmatch '(?i)codebase-design') { throw 'the vocabulary skill is not invoked' }
    # In the step that explores, where it is applied. Naming it in the
    # vocabulary list is not using it.
    $explore = [regex]::Match($c, '(?ims)^#{2,}[^\n]*explore.*?(?=^#{2}\s|\z)').Value
    if ($explore -notmatch '(?i)deletion test') { throw 'the deletion test is never applied' }
    $c -match '(?i)(exactly|don.t drift|do not drift)'
  }

  Assert "the report is written outside the repository" {
    $c = Get-SkillFile 'survey/SKILL.md'
    if (-not (Test-Path (Join-Path $skills 'survey/HTML-REPORT.md'))) {
      throw 'HTML-REPORT.md is missing'
    }
    $c -match '(?i)temp[^\n]{0,60}(dir|director)|nothing lands in the repo'
  }

  # --- resolving-merge-conflicts ---------------------------------------------

  Assert "a conflict is always resolved, never aborted" {
    $c = Get-SkillFile 'resolving-merge-conflicts/SKILL.md'
    if ($c -notmatch '(?i)never[^\n]{0,20}`?--abort') { throw 'aborting is not ruled out' }
    $c -match '(?i)primary source|original intent'
  }

  Assert "its git invocations point at tools/git.md rather than being guessed" {
    $c = Get-SkillFile 'resolving-merge-conflicts/SKILL.md'
    # Both ends — reading the conflict state, and finishing the operation. One
    # reference standing in for the other step is how a guessed flag gets in.
    if (([regex]::Matches($c, '.claude/tools/git.md')).Count -lt 2) {
      throw 'only one step defers to the tool reference'
    }
    $true
  }
}

# --- ticket tenure/08 — /configure, initialize or migrate a repository --------------

Describe-Ticket 'tenure/08' 'initialize or migrate a repository onto Tenure' {

  $cfg = 'configure/SKILL.md'

  Assert "/configure ships as a skill" {
    Test-Path (Join-Path $skills $cfg)
  }

  Assert "/configure is user-invoked — a repository joins Tenure because the user asked" {
    Test-UserInvoked $cfg
  }

  # Both halves of the name. Existence plus a mention is not disclosure — the
  # failure it guards against is the branch being written out in the skill
  # *and* in the file, which costs the greenfield run the context the pointer
  # exists to save.
  Assert "the migration branch is disclosed behind a pointer, not inlined" {
    if (-not (Test-Path (Join-Path $skills 'configure/MIGRATION.md'))) { throw 'configure/MIGRATION.md is missing' }
    $c = Get-SkillFile $cfg
    if ($c -notmatch 'MIGRATION\.md') { throw 'the branch is unreachable' }
    foreach ($inlined in @('(?im)^\|\s*From\s*\|', '(?im)^\|\s*Converts', '(?i)\bsorted\b[^.]{0,40}not duplicated')) {
      if ($c -match $inlined) { throw 'the migration is written out here as well' }
    }
    # And skipped where it does not apply, or the disclosure buys nothing.
    $c -match '(?i)(skip[^\r\n]{0,80}greenfield|greenfield[^\r\n]{0,40}skip)'
  }

  foreach ($t in @('CLAUDE.template.md', 'tenure.template.md', 'tracker.template.md')) {
    Assert "$t is reached from the skill that installs it" {
      if (-not (Test-Path (Join-Path $skills "configure/$t"))) { throw "configure/$t is missing" }
      (Get-SkillFile $cfg) -match [regex]::Escape($t)
    }
  }

  # --- decision 30: one job, three starting states --------------------------

  # "Onboarding and auditing are not two responsibilities bolted together —
  # they are the same job against different starting states." The behaviour is
  # chosen by what it finds, and a flag is the specific thing ruled out: a flag
  # lets the caller assert a starting state instead of detecting one.
  # Both halves, and both stated where the branch is chosen. "One job" without
  # "same job against different starting states" is a slogan; the second
  # sentence is the one that makes onboarding and audit the same code path.
  Assert "onboarding and audit are one job, chosen by what it finds and never by a flag" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch '(?i)one job') { throw 'the two are treated as separate responsibilities' }
    if ($c -notmatch '(?i)same job[^\r\n]{0,80}different starting state') { throw 'they are one job in name only' }
    $c -match '(?i)never by a flag|not by a flag|no flag'
  }

  # Read out of the branch table itself. Every one of these phrases also occurs
  # in the prose that follows — "another AI workflow" in step 3, "Tenure is
  # already here" as a heading — so a file-wide search passes with the row
  # deleted, which is exactly the branch going missing.
  Assert "all three starting states are rows in the branch table, each with what it does" {
    $c = Get-SkillFile $cfg
    $table = [regex]::Match($c, '(?ms)^\|[^\r\n]*\|[\r\n]+\|[\s\-|]+\|[\r\n]+((?:\|[^\r\n]*\|[\r\n]+)+)')
    if (-not $table.Success) { throw 'there is no branch table' }
    $rows = $table.Groups[1].Value -split '\r?\n' | Where-Object { $_ -match '\S' }
    $branches = @{
      'greenfield'          = '(?i)no Tenure[^|]*no (AI )?workflow'
      'another AI workflow' = '(?i)no Tenure[^|]*another'
      'Tenure already here' = '(?i)Tenure already'
    }
    foreach ($b in $branches.Keys) {
      $row = @($rows | Where-Object { $_ -match $branches[$b] })
      if ($row.Count -eq 0) { throw "no branch for: $b" }
      # The action cell has to name an action. A one-word cell satisfies any
      # non-empty check while saying nothing a reader could follow.
      $cells = @($row[0] -split '\|' | Where-Object { $_ -match '\S' })
      if ($cells.Count -lt 2) { throw "$b is named but the row says nothing it does" }
      if ($cells[1] -notmatch '(?i)(analys|generat|migrat|audit)\w*\b.*\w') {
        throw "$b routes to no described action"
      }
    }
    $true
  }

  # The audit branch is the one that looks redundant next to verification at
  # use, so its reason has to be in the branch itself: verification fires on
  # loading, and nothing loads knowledge nobody references.
  Assert "the audit branch states why it exists — verification at use cannot reach what nothing loads" {
    $s = Get-Section (Get-SkillFile $cfg) 'Audit'
    if ($s -notmatch '(?i)verification at use') { throw 'the gap it fills is not named' }
    $s -match '(?is)(never|cannot|nobody|nothing)[^\r\n]{0,120}(relied on|checked|reach)'
  }

  # --- detect ---------------------------------------------------------------

  # Scoped to the detect step. MIGRATION.md names most of these too, as things
  # it converts — so a marker dropped from the search list is still findable in
  # the file while nothing ever looks for it.
  Assert "detection covers every workflow marker the ticket names" {
    $s = Get-Section (Get-SkillFile $cfg) 'Detect'
    $markers = @('\.claude/', 'CLAUDE\.md', 'AGENTS\.md', 'docs/agents/', 'CONTEXT\.md',
                 'CONTEXT-MAP\.md', 'docs/adr/', '\.scratch/', '\.cursor', 'copilot-instructions',
                 '\.windsurf', '\.clinerules', '\.ai/')
    $missing = $markers | Where-Object { $s -notmatch $_ }
    if ($missing) { throw "never looked for: $($missing -join ', ')" }
    $true
  }

  Assert "the analysis covers everything the ticket lists, architectural style included" {
    $s = Get-Section (Get-SkillFile $cfg) 'Detect'
    $facets = @('languages', 'build', 'test', 'deploy', 'architectural style', 'module boundaries', 'domains')
    $missing = $facets | Where-Object { $s -notmatch "(?i)$_" }
    if ($missing) { throw "never analysed: $($missing -join ', ')" }
    $true
  }

  # The input the classification step consumes. Ordinary documentation is not
  # an AI workflow and none of the markers above finds it — so without this,
  # MIGRATION.md sorts a pile that was never gathered, and a repository whose
  # architecture was already written down gets it invented from scratch.
  Assert "documentation already written down is found before anything is generated" {
    $s = Get-Section (Get-SkillFile $cfg) 'Detect'
    $find = [regex]::Match($s, '(?s)\*\*Find the knowledge that is already written down\*\*.*?(?=\r?\n\r?\n)')
    if (-not $find.Success) { throw 'nothing goes looking for it' }
    $kinds = @('architecture', 'guide', 'decision record', 'standard', 'convention')
    $missing = $kinds | Where-Object { $find.Value -notmatch "(?i)$_" }
    if ($missing) { throw "existing knowledge never discovered: $($missing -join ', ')" }
    $true
  }

  # --- plan, confirm, apply -------------------------------------------------

  Assert "the full move list is confirmed before anything is touched" {
    $s = Get-Section (Get-SkillFile $cfg) 'Plan'
    $s -match '(?i)before (touching|changing|writing|moving) anything|nothing is (touched|moved|written) (until|before)'
  }

  # "No documentation is deleted without appearing in the confirmed plan."
  # Negated and in the plan step: MIGRATION.md's classification table says
  # temporary notes are "discarded, and named in the plan first", which satisfies
  # any loose deleted-near-plan pattern while the rule itself is gone.
  Assert "nothing is deleted that did not appear in the confirmed plan" {
    $s = Get-Section (Get-SkillFile $cfg) 'Plan'
    $s -match '(?is)\b(nothing|never|no)\b[^.]{0,60}delet[^.]{0,80}(confirmed|approved) plan'
  }

  # --- migration ------------------------------------------------------------

  # Each legacy path names the target it converts to.
  $conversions = [ordered]@{
    'CONTEXT\.md'     = '\.claude/context\.md'
    'CONTEXT-MAP\.md' = '(\.claude/contexts/|deleted)'
    'docs/adr/'       = '\.claude/decisions/'
    'docs/agents/'    = '(CLAUDE\.md|\.claude/)'
    '\.scratch/'      = '\.claude/tickets/'
    # layout/01. The one row whose source is Tenure's own superseded layout;
    # it belongs here because the sweep below derives its candidate list from
    # this table, and a legacy path the exempt files name without converting
    # is exactly what that sweep exists to catch.
    '\.claude/docs/'  = '(\.claude/(decisions|designs|evidence)/|deleted)'
  }
  foreach ($from in $conversions.Keys) {
    $to = $conversions[$from]
    Assert "the migration converts $($from -replace '\\','') and names where it goes" {
      $c = Get-SkillFile 'configure/MIGRATION.md'
      if ($c -notmatch "(?m)^.*$from.*$to.*$") { throw 'the source is named without its target' }
      $true
    }
  }

  # This is what makes ticket 01's exemption safe, and it has to be a sweep
  # rather than a checklist: checking that four conversions exist somewhere
  # says nothing about a fifth reference that is simply stale. Every legacy
  # path in the two exempt files must be a detection entry or a table row —
  # those are the only two shapes that mean "a path this repository might
  # have" rather than "a path Tenure uses".
  Assert "every legacy path the exempt files name is one the migration converts" {
    # Case-sensitive throughout, exactly as ticket 01's guard is: `-match` is
    # case-insensitive in PowerShell, and Tenure's own lowercase `context.md`
    # would otherwise read as a reference to matt's `CONTEXT.md`.
    # Derived from $conversions rather than restated — a third copy of this
    # list is one more place for the two to disagree.
    $candidates = @($conversions.Keys)
    $mig = Get-SkillFile 'configure/MIGRATION.md'
    $both = (Get-SkillFile 'configure/SKILL.md') + $mig

    $named = $candidates | Where-Object { $both -cmatch $_ }
    if ($named.Count -eq 0) { throw 'the exempt files name no legacy path at all' }

    # A path may be named freely in prose — explaining a conversion needs to
    # say what is being converted. What makes it a stale reference rather than
    # a migration source is the absence of a row saying where it goes.
    $stale = $named | Where-Object {
      -not ($mig -cmatch "(?m)^\|[^\r\n]*$_[^\r\n]*\|[^\r\n]*(\.claude/|deleted)")
    }
    if ($stale) { throw "named but never converted: $($stale -join ', ')" }
    $true
  }

  # Read out of the classification table, not the file. Every one of these
  # words recurs in the surrounding prose — the ADR 0008 table names decision
  # records, the closing section talks about what could not be classified — so
  # a deleted row leaves a file-wide pattern matching happily.
  Assert "existing documentation is classified, never copied" {
    $c = Get-SkillFile 'configure/MIGRATION.md'
    # The rule in the body, not the heading above it. `## Classify, never copy`
    # matches any classify-near-copy pattern while the sentence that actually
    # forbids duplication is gone.
    if ($c -notmatch '(?im)^[^#\r\n].*\bsorted\b[^.]{0,40}not duplicated') {
      throw 'documentation is copied rather than sorted'
    }
    $rows = ($c -split '\r?\n') | Where-Object { $_ -match '^\|' }
    $destinations = @{
      'implementation stays in source'   = '(?i)implementation[^|]*\|[^|]*source'
      'principles become context'        = '(?i)principle[^|]*\|[^|]*context'
      'reasoning becomes a decision'     = '(?i)(reasoning|historical)[^|]*\|[^|]*decision'
      'instructions become CLAUDE.md'    = '(?i)instruction[^|]*\|[^|]*CLAUDE\.md'
      'temporary notes are discarded'    = '(?i)temporary note[^|]*\|[^|]*discard'
    }
    $missing = $destinations.Keys | Where-Object { -not ($rows -match $destinations[$_]) }
    if ($missing) { throw "unsorted: $($missing -join ', ')" }
    $true
  }

  # ADR 0008's boundary. Both halves, because either alone is a failure mode:
  # convert everything and Tenure tramples the repository; adopt everything and
  # the repository ends up running two workflows.
  Assert "the AI workflow layer converts wholesale while the repository's own engineering is adopted" {
    $c = Get-SkillFile 'configure/MIGRATION.md'
    if ($c -notmatch '(?i)ADR 0008') { throw 'the decision is not cited' }
    if ($c -notmatch '(?i)two (competing )?workflows|both workflows') { throw 'the convert-wholesale reason is missing' }
    # The principle itself lives in CLAUDE.md (ADR 0007). This file applies it
    # to a migration, so it reaches it rather than arguing it a second time.
    if ($c -notmatch '(?i)`CLAUDE\.md` carries') { throw 'the principle is argued here instead of reached' }
    # The split itself, read out of the two-column table. "a table row exists
    # and the word adopt appears somewhere" passes on almost any file.
    $rows = ($c -split '\r?\n') | Where-Object { $_ -match '^\|' }
    $header = $rows | Where-Object { $_ -match '(?i)converts?[^|]*\|[^|]*adopted' }
    if (-not $header) { throw 'the two columns are not converts-vs-adopted' }
    $converts = $rows | Where-Object { $_ -match '(?i)agent (instruction|workflow|ticket)|repository knowledge' }
    if ($converts.Count -lt 3) { throw 'the AI workflow layer is only partly converted' }
    $true
  }

  # The instruction, not the heading that introduces it, and the alternative it
  # replaces — a broken link is the failure, so the rule has to name it.
  Assert "a converted file still referenced elsewhere leaves a pointer at the old path" {
    $s = Get-Section (Get-SkillFile 'configure/MIGRATION.md') 'pointer'
    $s -match '(?is)leave[^.]{0,60}pointer[^.]{0,60}old path[^.]{0,60}broken link'
  }

  # --- generate -------------------------------------------------------------

  # /configure writes context.md; domain-modeling owns its shape. Restating the
  # format here is the duplication this framework exists to prevent, and the
  # copy that drifts would be the one a fresh repository is generated from.
  Assert "the context format is reached by pointer to domain-modeling, never restated" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch 'CONTEXT-FORMAT\.md') { throw 'the format is not pointed at' }
    if ($c -match '(?i)_Avoid_') { throw 'the context format is restated here' }
    $true
  }

  # ADR 0007 moved the compression test to CLAUDE.md in ticket 13. /configure
  # is the biggest single writer of Context, so a pointer at the old owner
  # sends the highest-volume caller to a file that forwards on.
  Assert "the compression test is cited where it lives, not where it used to" {
    $c = Get-SkillFile $cfg
    $c -match '(?is)compression test[^.]{0,60}`CLAUDE\.md`'
  }

  Assert "CLAUDE.md is written from the template, and the user's existing sections survive" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch 'CLAUDE\.template\.md') { throw 'the template is not used' }
    $c -match '(?i)(preserve|keep|leave)[^\r\n]{0,100}(existing|user''s own) section'
  }

  Assert "repo-discovered standards are emitted as path-scoped .claude/rules/*.md" {
    $c = Get-SkillFile $cfg
    ($c -match '\.claude/rules/') -and ($c -match '(?i)path-scoped|scoped to')
  }

  # The mapping, not the word "remote". And the ambiguous case explicitly: a
  # repository with several remotes is the one where guessing looks reasonable.
  Assert "the tracker is chosen from the remote, and asked for when that is ambiguous" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch '\.claude/tracker\.md') { throw 'the tracker config is never written' }
    $choice = [regex]::Match($c, '(?is)Choose from the \*\*remote\*\*.*?(?=\r?\n\r?\n)')
    if (-not $choice.Success) { throw 'the remote does not select the tracker' }
    # All three, in the one sentence that does the choosing. A repository with
    # no remote is the case that otherwise falls through to a guess.
    # Ticket 08: "GitHub when a remote points there, local markdown otherwise."
    # `otherwise` is load-bearing — a remote on a host Tenure drives no tracker
    # for must land somewhere, and enumerating only "no remote" leaves it in no
    # branch at all.
    foreach ($t in @('GitHub', 'GitLab', 'local markdown', 'otherwise')) {
      if ($choice.Value -notmatch [regex]::Escape($t)) { throw "the remote never maps to: $t" }
    }
    $c -match '(?i)ask[^\r\n]{0,60}ambiguous'
  }

  # Decision 34. The format is ticket 15's, and this is the writer — so it
  # points at the format rather than carrying a second copy of it.
  Assert "the repo's own tooling is written into .claude/tools/ in the format tools/ owns" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch '\.claude/tools/') { throw 'repo tooling is never written' }
    # The path, not the word. "the `tools` skill" survives the link being cut,
    # and a named skill with no route to it is not progressive disclosure.
    if ($c -notmatch 'TOOLS\.md') { throw 'the format is not pointed at' }
    # The six the ticket names, read off the `.claude/tools/` bullet itself.
    # Step 1's analysis list already contains most of these words, so a
    # file-wide check passes with the tooling bullet gutted.
    $bullet = [regex]::Match($c, '(?s)\*\*`\.claude/tools/\*\.md`\*\*.*?(?=\r?\n\r?\n)')
    if (-not $bullet.Success) { throw 'no tooling bullet to read' }
    $kinds = @('package manager', 'test runner', 'typecheck', 'lint', 'build', 'deploy')
    $missing = $kinds | Where-Object { $bullet.Value -notmatch "(?i)$_" }
    if ($missing) { throw "never discovered: $($missing -join ', ')" }
    $true
  }

  # --- validate -------------------------------------------------------------

  # In the validate step. Both also appear in the audit branch, which runs on
  # exactly one of the three starting states — so a greenfield run would ship
  # unvalidated while a file-wide pattern stayed green.
  Assert "validation resolves every Source Pointer and every context's routing row" {
    $s = Get-Section (Get-SkillFile $cfg) 'Validate'
    if ($s -notmatch '(?i)Source Pointer') { throw 'pointers are never checked' }
    $s -match '(?is)contexts/[^\r\n]{0,120}routing table|routing table[^\r\n]{0,120}contexts/'
  }

  # ADR 0006: `.claude/.gitignore` is what makes "one directory" literal, so
  # both entries and the hands-off rule for the repo's own ignore file are the
  # criterion — writing to the root ignore file is the failure it prevents.
  # Ticket 16 kept the entries and added the category above them; both are
  # asserted, because a category with nothing under it ignores nothing.
  Assert ".claude/.gitignore covers marker.json and prototypes/, and the root ignore file is left alone" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch '\.claude/\.gitignore') { throw 'the workflow leaks into the repo root' }
    foreach ($entry in @('marker\.json', 'prototypes/')) {
      if ($c -notmatch $entry) { throw "not ignored: $entry" }
    }
    $c -match '(?i)root[^\r\n]{0,60}\.gitignore|repository''s own ignore|leav[^\r\n]{0,40}root'
  }

  # ADR 0006's tree, minus the directories nothing has content for yet.
  # domain-modeling creates files lazily; pre-creating `evidence/research/`
  # would assert that research happened. So the rest of the layout is named,
  # with who fills it — not created empty.
  #
  # layout/01 replaced the single `docs/` entry with the four directories it
  # dissolved into. All four are checked: after a change that moved every one
  # of them, a list naming three is the likeliest way this goes wrong.
  Assert "the rest of the .claude tree is created lazily, not pre-created empty" {
    $gen = Get-Section (Get-SkillFile $cfg) 'Generate'
    $lazy = [regex]::Match($gen, '(?s)The rest of the tree.*?(?=\r?\n\r?\n)')
    if (-not $lazy.Success) { throw 'the rest of the tree is never accounted for' }
    if ($lazy.Value -notmatch '(?i)lazil|when[^\r\n]{0,40}something to put') { throw 'directories are pre-created' }
    # Read off that sentence, not the section: `.claude/prototypes/` is named
    # again by the .gitignore bullet a few lines down, so a file-wide check
    # passes with the path dropped from the layout it is supposed to describe.
    $missing = @('decisions/', 'designs/', 'evidence/', 'tickets/', 'prototypes/') |
      Where-Object { $lazy.Value -notmatch [regex]::Escape($_) }
    if ($missing) { throw "the layout never names: $($missing -join ', ')" }
    $true
  }

  # --- idempotence ----------------------------------------------------------

  # The claim and the mechanism. Asserting only the claim is what let the audit
  # branch skip generation entirely while this stayed green: a run that decides
  # "already configured" and stops is idempotent and also wrong.
  Assert "a second run reports what already exists rather than duplicating it" {
    $s = Get-Section (Get-SkillFile $cfg) 'again'
    if ($s -notmatch '(?i)(no|never|without|rather than|instead of) duplicat') { throw 'the claim is not made' }
    $s -match '(?i)by content, not by presence|content rather than presence'
  }

  # The mechanism the criterion actually needs. Every step runs on every
  # branch; detection changes what is *found*, not which steps execute. A
  # half-finished first run detects as "Tenure already present", so a branch
  # that audits instead of generating can never complete it.
  Assert "generation is not skipped on the branch that finds Tenure already here" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch '(?is)audit[^.|\r\n]{0,60}(and|plus)[^.|\r\n]{0,60}(generat|missing)') {
      throw 'the audit branch never generates what is missing'
    }
    # The row says the branch generates; this says no branch can skip a step.
    # Without it, a later edit that reads the table as three separate pipelines
    # is not contradicted anywhere.
    if ($c -notmatch '(?is)branch changes what is[^.]{0,40}found[^.]{0,40}never which steps run') {
      throw 'the branches are three pipelines, not one'
    }
    $gen = Get-Section $c 'Generate'
    $gen -match '(?is)write what is missing[^.]{0,80}check what is'
  }
}

# --- ticket tenure/10 — /tenure, the router over the skill set ----------------------

Describe-Ticket 'tenure/10' 'router over the Tenure skill set' {

  $router = 'help/SKILL.md'
  # Read once. Eight assertions want the same file, and re-reading it in each
  # is the Duplicated Code this repo flags in prose.
  $rt = Get-SkillFile $router
  # An entry is a bullet whose bolded lead is a skill name. Extracted once,
  # because the marker is the shape every coverage assertion depends on and a
  # change to it should touch one line.
  $entries = @(($rt -split '\r?\n') | Where-Object { $_ -match '^- \*\*' })
  # Backtick is PowerShell's escape character inside a double-quoted string, so
  # a literal one has to arrive as a char rather than be typed.
  $tick = [char]0x60

  # ADR 0015: `/tenure:tenure` is unusable, so the router is `help` and the
  # plugin supplies the name. It is the one skill whose name cannot be the
  # framework's, which is why it gets its own assertion rather than riding on
  # the naming rule below.
  Assert "the router ships as /help — 'ask the tenured engineer'" {
    if (-not (Test-Path (Join-Path $skills $router))) { throw 'skills/help/SKILL.md is missing' }
    $fm = Get-Frontmatter $rt
    if (-not $fm) { throw 'help/SKILL.md has no frontmatter' }
    $fm -match '(?m)^name:\s*help\s*$'
  }

  Assert "/help is user-invoked — it is the human's index, and nothing else should load it" {
    Test-UserInvoked $router
  }

  # "Every skill in ./skills appears exactly once." Counted as *entries* — the
  # bullet that indexes a skill — not as mentions. A router cross-references
  # constantly and has to; what must not happen twice is a skill being filed
  # under two groups, because then the answer to "where does this belong"
  # depends on which one you read.
  #
  # The router itself is the one exemption and cannot be otherwise: a router
  # that indexes itself is circular, and it is the one skill reachable
  # without an index.
  Assert "every other skill has exactly one entry in the router" {
    if ($entries.Count -lt 5) { throw 'the router is not a list of entries' }
    $all = Get-ChildItem $skills -Directory |
      Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
      ForEach-Object { $_.Name } |
      Where-Object { $_ -ne 'help' }
    $missing = @(); $repeated = @()
    foreach ($s in $all) {
      $pattern = '^- \*\*' + $tick + '?/?' + [regex]::Escape($s) + $tick + '?\*\*'
      $n = @($entries | Where-Object { $_ -match $pattern }).Count
      if ($n -eq 0) { $missing += $s }
      elseif ($n -gt 1) { $repeated += "$s x$n" }
    }
    if ($missing) { throw "no entry for: $($missing -join ', ')" }
    if ($repeated) { throw "filed under two groups: $($repeated -join ', ')" }
    $true
  }

  # "The router explains *when* to reach for each, not what each contains."
  # The negative half: a router that names another skill's disclosed file is
  # describing contents. Cheap, and it holds the line against the crudest form.
  Assert "the router never reaches into a skill's disclosed files" {
    $disclosed = Get-SkillFiles |
      Where-Object { $_.Name -ne 'SKILL.md' } |
      ForEach-Object { $_.Name } |
      Sort-Object -Unique
    $leaked = $disclosed | Where-Object { $rt -match [regex]::Escape($_) }
    if ($leaked) { throw "describes contents, not timing: $($leaked -join ', ')" }
    $true
  }

  # The positive half, which is the criterion itself. An entry earns its place
  # by naming the *situation* you are in — that is what you know at the moment
  # you consult a router — and it has to do so in its opening clause, before
  # the em-dash, or the reader has already had to parse a description.
  Assert "every entry opens by naming a situation, not by describing the skill" {
    $trigger = '(?i)^\s*(when(ever)?\b|once\b|before\b|not feature work\b|issues you|start here|run it\b|two situations)'
    $triggerless = @($entries | Where-Object {
      $tail = ($_ -split [char]0x2014, 2)[1]
      -not ($tail -and $tail -match $trigger)
    })
    if ($triggerless) {
      throw "no situation on: $(($triggerless | ForEach-Object { ($_ -split [char]0x2014)[0].Trim() }) -join '; ')"
    }
    $true
  }

  # --- the Spine -------------------------------------------------------------

  # Both the diagram and the entries under it. Matching first occurrences only
  # finds the diagram — every one of these names appears there first — so the
  # entries could be listed in any order and this would still pass.
  Assert "the Spine runs design, implement, review, commit, in that order" {
    $spine = @('design', 'implement', 'review', 'commit')
    foreach ($where in @('diagram', 'entries')) {
      $last = -1
      foreach ($step in $spine) {
        $pattern = if ($where -eq 'diagram') { '/' + [regex]::Escape($step) + '\b' }
                   else { '(?m)^- \*\*' + $tick + '/' + [regex]::Escape($step) + $tick + '\*\*' }
        $m = [regex]::Match($rt, $pattern)
        if (-not $m.Success) { throw "/$step is not in the $where" }
        if ($m.Index -lt $last) { throw "/$step comes out of order in the $where" }
        $last = $m.Index
      }
    }
    $true
  }

  # "Spine commands stay bare (/design, /implement, /commit), so the name
  # appears only here and in prose." A `tenure-` prefixed skill would put the
  # router's name in front of every command the user types.
  Assert "the router's name prefixes nothing — the Spine stays bare" {
    $prefixed = Get-ChildItem $skills -Directory |
      Where-Object { $_.Name -ne 'help' -and $_.Name -like 'tenure*' } |
      ForEach-Object { $_.Name }
    if ($prefixed) { throw "namespaced onto the router: $($prefixed -join ', ')" }
    $announced = Get-SkillFiles |
      Where-Object { $_.Directory.Name -ne 'help' } |
      Where-Object { (Get-Content $_.FullName -Raw) -match '(?m)^name:\s*tenure' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) -replace '\\', '/' }
    if ($announced) { throw "claims the router's name: $($announced -join ', ')" }
    $true
  }

  # Ticket 07 and ADR 0011: evidence is a detour off the Spine, and whether it
  # blocks is a gate. A router that lists them as ordinary steps sends the user
  # to research every change.
  Assert "research and prototype are gated detours, not steps in the Spine" {
    # The rule, not the heading above it. `### The two detours` sits directly
    # over these entries and satisfies any detour-near-name pattern while the
    # sentence that keeps them off the Spine is gone.
    if ($rt -notmatch '(?i)detours,? not steps') { throw 'evidence reads as a step in the Spine' }
    $rt -match '(?is)gate[^.]{0,160}(load-bearing|stop for)'
  }

  # ADR 0011. The failure this prevents is the user going looking for a
  # to-spec or a wayfinder that no longer exists.
  Assert "/design is the whole planning surface — spec, tickets, and the foggy map" {
    # Read off /design's own entry. File-wide, `ticket` is satisfied by
    # /implement's entry and `spec` by any prose, so the coverage sentence
    # could be deleted outright and this would still pass.
    $entry = @($entries | Where-Object { $_ -match '^- \*\*' + $tick + '/design' + $tick })
    if ($entry.Count -ne 1) { throw '/design has no single entry' }
    $covers = @('spec', 'ticket', '(map|fog)')
    $missing = $covers | Where-Object { $entry[0] -notmatch "(?i)$_" }
    if ($missing) { throw "/design's coverage is not stated: $($missing -join ', ')" }
    $entry[0] -match '(?i)nothing else[^\r\n]{0,60}plan|no other[^\r\n]{0,60}plan'
  }

  # --- the other groups ------------------------------------------------------

  Assert "the on-ramps say what arrived, not what they do" {
    $triage = @($entries | Where-Object { $_ -match '/triage' })
    if ($triage.Count -ne 1) { throw '/triage has no single entry' }
    if ($triage[0] -notmatch '(?i)(incoming|arrive|did \*\*not\*\* create|raw)') { throw '/triage has no trigger' }
    $bugs = @($entries | Where-Object { $_ -match '/diagnosing-bugs' })
    if ($bugs.Count -ne 1) { throw '/diagnosing-bugs has no single entry' }
    # The situation, not the examples. `regression` and `flake` are examples of
    # what it handles; the trigger is that something is broken — and on their
    # own the examples kept this green with the trigger deleted.
    $bugs[0] -match '(?i)(broken|failing|does ?n.t work)'
  }

  # Decision 30 and ADR 0010 together: /configure is the only knowledge command
  # and there is no second one. A router that leaves a hole where a sync stage
  # would have been is where a user invents one.
  Assert "the knowledge group states the audit re-run and that verification has no command" {
    $s = Get-Section $rt 'Knowledge'
    if ($s -notmatch '(?i)once per repo') { throw 'the first run is not scoped to once' }
    if ($s -notmatch '(?i)\bagain\b|re-run') { throw 'the audit re-run is not stated' }
    $s -match '(?is)(verif\w+|repairing)[^.]{0,140}(no command|not a command|never a command)'
  }

  # /configure writes what everything else reads, so a router that files it
  # fourth without saying so sends a first-time user into /design against an
  # unconfigured repository.
  Assert "/configure is stated as the precondition, before the Spine" {
    $pre = [regex]::Match($rt, '(?i)(first|before anything|to begin)[^\r\n]{0,40}/configure')
    if (-not $pre.Success) { throw '/configure is not stated as a precondition' }
    $spine = [regex]::Match($rt, '(?im)^##\s.*Spine')
    if (-not $spine.Success) { throw 'there is no Spine section' }
    if ($pre.Index -gt $spine.Index) { throw 'the precondition comes after the Spine it precedes' }
    $true
  }

  # Four, not five: ADR 0019 deleted `tools`, so the router routing to it would
  # be a pointer at a skill that no longer exists. layout/03 asserts what
  # replaced the entry.
  Assert "the primitives are grouped as what runs underneath" {
    $s = Get-Section $rt 'What runs underneath'
    $primitives = @('grilling', 'tdd', 'codebase-design', 'domain-modeling')
    # `(?m)` or `^` anchors to the start of the whole section rather than to
    # each line, and only the first primitive could ever match.
    $missing = $primitives | Where-Object { $s -notmatch ('(?m)^- \*\*' + $tick + [regex]::Escape($_) + $tick) }
    if ($missing) { throw "not placed underneath: $($missing -join ', ')" }
    $true
  }

  # Scoped, and as a contrast rather than two independent mentions: the whole
  # point is that they are alternatives, and either one alone is not a choice.
  Assert "crossing sessions contrasts /handoff with /compact, and says what forces the choice" {
    $s = Get-Section $rt 'Crossing sessions'
    foreach ($opt in @('/handoff', '/compact')) {
      if (-not (@($entries | Where-Object { $_ -match [regex]::Escape($opt) }).Count)) {
        throw "$opt is not one of the two options"
      }
      if ($s -notmatch [regex]::Escape($opt)) { throw "$opt is not in this section" }
    }
    if ($s -notmatch '(?i)forks') { throw 'the fork/continue contrast is missing' }
    if ($s -notmatch '(?i)continues') { throw 'the fork/continue contrast is missing' }
    $s -match '(?i)smart zone'
  }

  # --- the tier model --------------------------------------------------------

  Assert "the tier model is stated: max(Floor, Gates), after the grill, the user overrides either way" {
    if ($rt -notmatch '(?i)max\(\s*Floor\s*,\s*Gates\s*\)') { throw 'the tier is not computed' }
    if ($rt -notmatch '(?is)(after|follows)[^.]{0,80}grill') { throw 'the tier could be chosen before the grill' }
    $rt -match '(?is)overrid\w+[^.]{0,80}(either direction|up or down)'
  }

  # ADR 0007. The router carries the *shape* of the decision, because a human
  # deciding whether to type /design needs it. The tables are /design's, and
  # they are what would drift — a floor row copied here and changed there is
  # two different answers to the same question.
  Assert "the Floor and Gate tables stay in /design alone" {
    $tables = [ordered]@{
      'the floor table' = '(?im)^\|[^|\r\n]*\|\s*(Express|Standard|Heavyweight)\s*\|'
      'the gate table'  = '(?im)^\|[^|\r\n]*\|\s*(evidence first|spec|many tickets|a map)\s*\|'
    }
    foreach ($t in $tables.Keys) {
      $homes = @(Get-SkillFiles |
        Where-Object { (Get-Content $_.FullName -Raw) -match $tables[$t] } |
        ForEach-Object { $_.FullName.Substring($skills.Length + 1) -replace '\\', '/' })
      if ($homes.Count -eq 0) { throw "$t is stated nowhere" }
      # `-ne` on an array filters rather than compares, so the obvious spelling
      # of this check is a silent no-op that also reports the legitimate home.
      $strays = @($homes | Where-Object { $_ -ne 'design/SKILL.md' })
      if ($strays) { throw "$t is also in: $($strays -join ', ')" }
    }
    $true
  }
}

# --- ticket tenure/14 — tracker hierarchy, relationships, labels, titles ------------

Describe-Ticket 'tenure/14' 'hierarchy, relationships, labels, and title conventions' {

  $tickets = 'design/TICKETS.md'
  $map     = 'design/MAP.md'
  $tracker = 'configure/tracker.template.md'

  # --- tracking only ---------------------------------------------------------

  # "Issues track work. Engineering knowledge lives in the codebase, context,
  # and decisions — never in an issue body." The failure is a tracker that
  # slowly becomes the place people look things up, which nothing verifies.
  Assert "a ticket tracks work and never becomes a knowledge store" {
    $c = Get-SkillFile $tickets
    if ($c -notmatch '(?i)(implementation|engineering) (diar|log|journal)|no diar') { throw 'nothing forbids an implementation diary' }
    $c -match '(?is)\.claude/designs/[^.]{0,160}(referenc|link|point)|(?is)(referenc|link|point)[^.]{0,160}\.claude/designs/'
  }

  # --- anti-booming ----------------------------------------------------------

  # The one checkable rule against a tracker filling with micro-tickets:
  # closing it has to produce something someone can see.
  Assert "a ticket must have an outcome someone can observe when it closes" {
    $c = Get-SkillFile $tickets
    if ($c -notmatch '(?is)(observ|visible)[^.]{0,120}(when it closes|on clos)') { throw 'the closure test is not stated' }
    # `not a ticket` as a bare third branch subsumes the other two: it is
    # the tail of the same sentence, so deleting the redirect leaves it
    # matching. The redirect is the half that says where the work goes.
    $c -match '(?is)(step inside|part of) another ticket, not a ticket'
  }

  Assert "structure deepens rather than widens, and the never-ticket-this list is concrete" {
    $c = Get-SkillFile $tickets
    if ($c -notmatch '(?i)deepen') { throw 'nothing says to deepen rather than widen' }
    # The sentence, not the file. `renam` also matches the wide-refactor
    # section's "rename a column", and `comment` matches almost any prose.
    $line = [regex]::Match($c, '(?i)Never create a ticket[^.]*\.').Value
    if (-not $line) { throw 'nothing is ruled out of being a ticket' }
    $never = @('renam', 'mov\w* a file', 'comment')
    $missing = $never | Where-Object { $line -notmatch "(?i)$_" }
    if ($missing) { throw "the never-ticket list omits: $($missing -join ', ')" }
    $true
  }

  # Decision 37's checkable half. Requiring an edge on every ticket buys
  # nothing unless something says to go and look for the ones without.
  Assert "the edges are scanned for strays, which is what makes the rule checkable" {
    $c = Get-SkillFile $tickets
    $c -match '(?is)scan the set[^.]{0,160}(stray|edgeless|neither the root)'
  }

  # --- relationships, on both trackers --------------------------------------

  # Decision 35: GitHub and local markdown are both first-class, so an edge
  # has to be expressible on both. A format that only describes the local
  # form makes GitHub a second-class tracker by omission.
  Assert "part-of and blocks are expressible on both trackers" {
    $c = Get-SkillFile $tickets
    $rows = @(($c -split '\r?\n') | Where-Object { $_ -match '^\|' })
    foreach ($t in @('local markdown', 'GitHub')) {
      if (-not ($rows -match "(?i)$t")) { throw "no representation for: $t" }
    }
    # Per edge, per tracker, out of the table. A single alternation is
    # satisfied by whichever column happens to survive, and the obvious
    # closer — `Part of:` and `Blocked by:` anywhere — matches the format
    # block above with the table deleted entirely.
    $gh = @($rows | Where-Object { $_ -match '(?i)GitHub' })
    if ($gh.Count -ne 1) { throw 'no single GitHub row' }
    foreach ($edge in @('sub-issue', 'Blocked by', 'body')) {
      if ($gh[0] -notmatch [regex]::Escape($edge)) { throw "the GitHub row omits: $edge" }
    }
    $lm = @($rows | Where-Object { $_ -match '(?i)local markdown' })
    if ($lm.Count -ne 1) { throw 'no single local-markdown row' }
    foreach ($edge in @('Part of:', 'Blocked by:', 'Related:')) {
      if ($lm[0] -notmatch [regex]::Escape($edge)) { throw "the local-markdown row omits: $edge" }
    }
    # Decision 34. `gh` has no blocking subcommand, and a table promising a
    # native one sends /design to invent an invocation.
    if ($c -match '(?i)native blocking') { throw 'the table promises a subcommand gh does not have' }
    $true
  }

  # Ticket 09: `.claude/tracker.md` is the one home for which tracker a
  # repository uses, "read by every skill that touches the tracker — /design,
  # /implement, /triage". /design was the last of the three with nothing.
  # Named *and* used to branch. A single mention passed while every `Status:`
  # instruction below it stayed local-markdown-only, which is the half that
  # actually makes GitHub a second-class tracker.
  $trackerReaders = [ordered]@{
    $tickets = '(?is)`Status:`[^.]{0,160}(local[- ]markdown|on GitHub)'
    $map     = '(?i)Record it:[^\r\n]{0,240}(tracker\.md|on GitHub|label)'
  }
  foreach ($f in $trackerReaders.Keys) {
    $branch = $trackerReaders[$f]
    Assert "$f reads .claude/tracker.md rather than assuming local markdown" {
      $c = Get-SkillFile $f
      if ($c -notmatch '\.claude/tracker\.md') { throw 'the config is never named' }
      if ($c -notmatch $branch) { throw 'named, but the status form is still local-markdown-only' }
      $true
    }
  }

  # --- the lifecycle ---------------------------------------------------------

  Assert "the build lifecycle carries blocked alongside the ticket's four states" {
    $c = Get-SkillFile $tickets
    # The lifecycle fence, not the file. `-match` is case-insensitive, so a
    # file-wide `^blocked\s` is satisfied by the `Blocked by:` edge line and
    # the state could be deleted with the check still green.
    $fence = [regex]::Match($c, '(?ms)^```\r?\n(open\s.*?)^```')
    if (-not $fence.Success) { throw 'there is no lifecycle block' }
    $states = @('open', 'blocked', 'resolved', 'obsolete')
    $missing = $states | Where-Object { $fence.Groups[1].Value -notmatch "(?m)^$_\s+\S" }
    if ($missing) { throw "not in the lifecycle: $($missing -join ', ')" }
    $true
  }

  # `obsolete` is the state that stops a ticket an earlier one made
  # unnecessary from being built anyway, so the reason is not optional.
  Assert "obsolete requires a reason and is never deleted" {
    $s = Get-Section (Get-SkillFile $tickets) 'obsolete'
    ($s -match '(?i)one-line reason') -and ($s -match '(?i)never delet')
  }

  # ADR 0007. /implement selects from the frontier, so it owns what the
  # frontier is; TICKETS.md described it too, and differently — it omitted
  # unclaimed and the lowest-number rule, which is the half that keeps two
  # sessions deterministic.
  Assert "the frontier is defined once, by the skill that picks from it" {
    $homes = Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match '(?i)frontier[^\r\n]{0,80}(unclaimed|lowest number)' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) -replace '\\', '/' }
    if ($homes.Count -eq 0) { throw 'the frontier is defined nowhere' }
    $strays = @($homes | Where-Object { $_ -ne 'implement/SKILL.md' })
    if ($strays) { throw "also defined in: $($strays -join ', ')" }
    $true
  }

  # --- labels: reuse first ---------------------------------------------------

  # Ticket 09 placed the label *vocabulary* in tracker.template.md as a
  # per-repository mapping. The *procedure* is Tenure's and belongs in the
  # skill that creates labels, not in a config file a user can edit.
  Assert "labels are listed, mapped onto, and only then created" {
    # Scoped to the procedure. `/triage` reads labels all over — "Read the
    # whole thing: body, comments, labels" — so a file-wide check for
    # list-near-label passes with the first step of the procedure deleted.
    $c = [regex]::Match((Get-SkillFile 'triage/SKILL.md'),
                        '(?ms)^### Reuse a label.*?(?=^#{2,3}\s|\z)').Value
    if (-not $c) { throw 'there is no reuse procedure' }
    $steps = [ordered]@{
      'list what exists'          = '(?i)(list|read)[^\r\n]{0,60}(label)'
      'map onto an existing one'  = '(?is)(map|reuse)[^.]{0,120}exist'
      'create only when nothing fits' = '(?is)creat[^.]{0,120}(nothing fits|no[^.]{0,20}fits|last resort)'
      # The dimensions, not the word. Step 3 already says "match the style
      # already there", which satisfies any pattern containing `style` while
      # the list telling you what to match is gone.
      "match the repository's style"  = '(?is)prefix.{0,120}casing.{0,120}(separator|colour|color)'
    }
    $missing = $steps.Keys | Where-Object { $c -notmatch $steps[$_] }
    if ($missing) { throw "the reuse procedure omits: $($missing -join ', ')" }
    # And the one label that must never be created: workflow state is already
    # carried by the ticket's own status, and a label for it is a second
    # answer to the same question.
    $c -match '(?is)(never|not) creat[^.]{0,140}(workflow state|status)'
  }

  # --- titles and PRs --------------------------------------------------------

  # ADR 0007: Conventional Commits and the scope vocabulary are CLAUDE.md's.
  # What is left here is the *PR body shape*, which has no other home — and
  # `gh pr create` is where someone drafting one is standing.
  Assert "a PR description covers the six things, and never a commit-by-commit account" {
    $c = Get-Section (Get-SkillFile $claudeTemplate) 'Conventions'
    $covers = @('problem', 'solution', 'architectur', 'testing', 'related issue', 'breaking change')
    $missing = $covers | Where-Object { $c -notmatch "(?i)$_" }
    if ($missing) { throw "the PR body omits: $($missing -join ', ')" }
    $c -match '(?i)(never|not)[^\r\n]{0,40}commit-by-commit'
  }

  # ADR 0007. Ticket 13 gave Conventional Commits and the detect-before-
  # asserting rule one home apiece; this ticket's Titles section must reach
  # them, not re-argue them.
  Assert "the commit convention is not restated here — CLAUDE.md owns it" {
    $banned = [ordered]@{
      'the scope vocabulary'      = '(?i)`misc`'
      'the convention as a rule'  = '(?i)Conventional Commits\s*(—|-|is|are)'
      'the defaults-not-mandates' = $rulePattern['conventions are defaults']
    }
    foreach ($f in @($tickets, 'configure/tools/github.md')) {
      $c = Get-SkillFile $f
      foreach ($b in $banned.Keys) {
        if ($c -match $banned[$b]) { throw "$b is restated in $f" }
      }
    }
    $true
  }

  # Acceptance: "Conventional Commits is applied only after confirming the repo
  # documents nothing else." The principle is CLAUDE.md's; the procedure — what
  # to actually read — has one home, and it is the step that does the applying.
  Assert "the detection procedure has one home, and names what to read" {
    $homes = Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match '(?i)CONTRIBUTING\.md[^\r\n]{0,80}PULL_REQUEST_TEMPLATE[^\r\n]{0,80}git log' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) -replace '\\', '/' }
    if ($homes.Count -eq 0) { throw 'nothing says what to read before asserting a convention' }
    $strays = @($homes | Where-Object { $_ -ne 'commit/SKILL.md' })
    if ($strays) { throw "also in: $($strays -join ', ')" }
    $true
  }

  # --- nothing forks the triage vocabulary -----------------------------------

  # "Nothing in this ticket contradicts triage's existing role vocabulary."
  Assert "no build-lifecycle state collides with a triage role" {
    $c = Get-SkillFile $tickets
    foreach ($role in @('needs-triage', 'needs-info', 'ready-for-agent', 'ready-for-human', 'wontfix')) {
      if ($c -match "(?m)^$role\s") { throw "a triage role appears in the build lifecycle: $role" }
    }
    # And the distinction is stated, not merely observed.
    $c -match '(?is)not the triage vocabulary'
  }

  Assert "the tracker template still holds the label strings, not the procedure" {
    $c = Get-SkillFile $tracker
    if ($c -notmatch '(?i)Label in this repository') { throw 'the per-repository mapping is gone' }
    if ($c -match '(?is)creat[^.]{0,80}only when nothing fits') { throw 'the procedure was copied into the config' }
    $true
  }
}

# --- ticket tenure/13 — the engineering rules, distributed --------------------------

Describe-Ticket 'tenure/13' 'distribute the engineering rules across the workflow' {

  # "Every one of the nineteen principles is accounted for — placed, cut, or
  # identified as embodied elsewhere. None silently dropped." The three tables
  # below are that accounting, and they are the reason it is checkable at all:
  # a principle that falls out of the build fails here rather than going quiet.

  # 1 — placed, each in the one file ADR 0007 assigns it.
  $placed = [ordered]@{
    # The hierarchy plus its direction. "never the reverse" alone is an
    # incidental phrase that unrelated prose could carry.
    '01 the codebase is the source of truth' = @{ file = $claudeTemplate
                                                  pattern = '(?is)codebase is right.{0,200}never the reverse' }
    # Both halves. The obligation without "names are not proof" leaves the
    # commonest way of satisfying it dishonestly — reading a filename and
    # calling that inspection.
    '04 verify before claiming'              = @{ file = $claudeTemplate
                                                  pattern = '(?is)before any repository-specific claim.{0,400}names are not proof' }
    '05 never guess an API'                  = @{ file = $claudeTemplate; pattern = '(?i)never guess an API' }
    # All three, or the rule is decorative: "why it exists" alone is what every
    # workaround already carries, and the removal condition is the only one that
    # makes "temporary" a state something can leave.
    '06 root-cause over workaround'          = @{ file = 'design/SKILL.md'
                                                  pattern = '(?is)why it exists.{0,80}alternatives.{0,80}removal condition' }
    '08 one concept per file'                = @{ file = 'codebase-design/SKILL.md'
                                                  pattern = $rulePattern['one concept per file'] }
    # The rule plus a worked pair. Stated bare it reads as a preference; the
    # example is what shows the path carrying the qualifier the name would
    # otherwise repeat. Matched by shape — a path and a long hyphenated name —
    # so rewording the example does not break the build.
    '09 directories over verbose filenames'  = @{ file = 'codebase-design/SKILL.md'
                                                  pattern = '(?is)verbose filename.{0,400}`[^`\r\n]*/[^`\r\n]*`.{0,300}`[^`\r\n]*(-[^`\r\n]*){3,}`' }
    '10 clear naming'                        = @{ file = 'codebase-design/SKILL.md'; pattern = '(?i)unnecessary abbreviation' }
    '11 self-explanatory code'               = @{ file = 'implement/SKILL.md'
                                                  pattern = $rulePattern['self-explanatory code'] }
    '12 document public APIs'                = @{ file = 'implement/SKILL.md'; pattern = '(?i)private implementation is not' }
    '13 test layout matches the repository'  = @{ file = 'tdd/SKILL.md'
                                                  pattern = $rulePattern['the test-layout rule'] }
    '14 knowledge is compressed'             = @{ file = $claudeTemplate
                                                  pattern = $rulePattern['the compression test'] }
    '15 knowledge has layers'                = @{ file = $claudeTemplate
                                                  pattern = $rulePattern['the knowledge-layer table'] }
    '18 the user owns decisions'             = @{ file = $claudeTemplate; pattern = '(?i)never silently decid' }
  }
  foreach ($principle in $placed.Keys) {
    $where = $placed[$principle]
    Assert "principle $principle is placed in $($where.file)" {
      (Get-SkillFile $where.file) -match $where.pattern
    }
  }

  # /implement points at a *section* of codebase-design. A pointer at a heading
  # that does not exist is a broken Source Pointer, which is the failure this
  # framework spends most of its always-on budget preventing.
  Assert "the section /implement points at exists in codebase-design" {
    (Get-SkillFile 'codebase-design/SKILL.md') -match '(?m)^## Files and names\s*$'
  }

  # 2 — cut. Neither is checkable, and both are no-ops against the model's own
  # default. An assertion that passes today is still worth having: it is what
  # stops a later pass reinstating them because they sound like principles.
  $cut = [ordered]@{
    '07 architecture over convenience' = '(?i)architecture over convenience'
    '19 leave the repository better'   = '(?i)leave (the |this )?(repository|repo|codebase) better|reduce engineering entropy'
  }
  foreach ($principle in $cut.Keys) {
    $pattern = $cut[$principle]
    Assert "principle $principle stays cut — reinstate only if made checkable" {
      $homes = Get-SkillFiles |
        Where-Object { (Get-Content $_.FullName -Raw) -match $pattern } |
        ForEach-Object { $_.FullName.Substring($skills.Length + 1) }
      if ($homes.Count -gt 0) { throw "reinstated in: $($homes -join ', ')" }
      $true
    }
  }

  # 3 — embodied elsewhere, so stating them again is the duplication ADR 0007
  # exists to stop. Each is asserted through the thing that embodies it.
  Assert "principle 16 synchronize understanding is embodied by verification at use — /sync stays dissolved" {
    $c = Get-SkillFile $claudeTemplate
    if ($c -notmatch '(?i)never a scan|no startup scan|never scan') { throw 'nothing embodies it' }
    $resurrected = Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match '(?i)/sync\b|`sync`' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) }
    if ($resurrected.Count -gt 0) { throw "a sync stage reappeared in: $($resurrected -join ', ')" }
    $true
  }

  # Principles 02 and 03 are definitions, not rules: what Context is for and
  # what Decisions are for. They are the knowledge-layer table's two lower rows
  # and `context.md`'s glossary, so restating them as principles inside a skill
  # is sediment — the definition would then exist twice and drift once.
  $definitions = [ordered]@{
    '02 context provides orientation' = @{ table = '(?im)^\|\s*Context\s*\|[^\r\n]*contexts'
                                           asRule = '(?i)context provides orientation' }
    '03 decisions preserve reasoning' = @{ table = '(?im)^\|\s*Decisions\s*\|[^\r\n]*decisions/'
                                           asRule = '(?i)decisions preserve reasoning' }
  }
  foreach ($principle in $definitions.Keys) {
    $d = $definitions[$principle]
    Assert "principle $principle stays a definition — carried by the layer table, never restated as a rule" {
      if ((Get-SkillFile $claudeTemplate) -notmatch $d.table) { throw 'the layer table does not define it' }
      $restated = Get-SkillFiles |
        Where-Object { (Get-Content $_.FullName -Raw) -match $d.asRule } |
        ForEach-Object { $_.FullName.Substring($skills.Length + 1) }
      if ($restated.Count -gt 0) { throw "restated as a rule in: $($restated -join ', ')" }
      $true
    }
  }

  Assert "principle 17 scale process with risk is embodied by the tier gates" {
    $c = Get-SkillFile 'design/SKILL.md'
    # Anchored to the tier table's own rows — a bare `Express` would match any
    # prose that happens to name a tier. And `only raise` alone would subsume
    # any alternation put beside it, so the pattern carries the half that makes
    # the gate one-way.
    ($c -match '(?im)^\|[^|\r\n]*\|\s*Express\s*\|') -and
    ($c -match '(?im)^\|[^|\r\n]*\|\s*Heavyweight\s*\|') -and
    ($c -match '(?i)only raise[^\r\n]{0,20}never lower')
  }

  # A rule reached by pointer is not a second home. These two skills lost a
  # restatement in this ticket, and the pointer is what has to be left behind —
  # cutting the rule without leaving the route is how it stops firing at all.
  # Two-sided on purpose, and the positive half is anchored to the site the
  # restatement was cut from. A file-wide search for `CLAUDE.md` proves nothing:
  # every one of these already names it, for unrelated rules, so the pointer
  # could be deleted outright and the check would still pass.
  $pointers = @(
    @{ f = 'design/SKILL.md';    rule = 'verify before claiming'
       restatement = $rulePattern['verify before claiming']
       route       = '(?i)\*\*Read the code\.\*\*[^\r\n]{0,80}`CLAUDE\.md`' }
    @{ f = 'research/SKILL.md';  rule = 'never guess an API'
       restatement = $rulePattern['the tools routing rule']
       route       = '(?i)a CLI counts[^\r\n]{0,80}`CLAUDE\.md`' }
    @{ f = 'implement/SKILL.md'; rule = 'never guess an API'
       restatement = $rulePattern['the tools routing rule']
       route       = '(?is)guessing an API is in `CLAUDE\.md`.{0,200}version.{0,40}signature.{0,40}limits' }
    @{ f = 'implement/SKILL.md'; rule = 'files and names'
       restatement = $rulePattern['one concept per file']
       route       = '(?i)`codebase-design`[^\r\n]{0,120}Files and names' }
    @{ f = 'configure/TOOLS.md'; rule = 'never guess an API'
       restatement = $rulePattern['never guess an API']
       route       = '(?i)never-guess rule in `CLAUDE\.md`' }
    @{ f = 'commit/SKILL.md';    rule = 'conventions are defaults'
       restatement = $rulePattern['conventions are defaults']
       route       = '(?i)`CLAUDE\.md` carries the convention' }
  )
  foreach ($p in $pointers) {
    Assert "$($p.f) reaches '$($p.rule)' by pointer, at the site it was cut from" {
      $c = Get-SkillFile $p.f
      if ($c -match $p.restatement) { throw 'still restated here' }
      if ($c -notmatch $p.route) { throw 'cut without leaving the route' }
      $true
    }
  }

  # Outcome 3. A standard discovered in the repository belongs to the
  # repository, not to Tenure, and it is path-scoped where it applies to only
  # part of the tree — otherwise a rule about one directory is paid for on
  # every turn against every other.
  Assert "a standard discovered in this repository is placed in .claude/rules/, path-scoped" {
    $c = Get-SkillFile $claudeTemplate
    # Naming the path in the precedence list is not placing the rule — the
    # placement is the sentence that says what goes there and why it is the
    # repository's rather than Tenure's.
    if ($c -notmatch '(?is)`\.claude/rules/`[^\r\n]{0,120}(discovered|standards)') {
      throw 'the path is listed but nothing is placed in it'
    }
    if ($c -notmatch '(?i)path-scoped|scoped to that (path|part)') { throw 'not path-scoped' }
    $true
  }

  # ADR 0007 settles this one explicitly, and it is the one ordering in the
  # chain that is not obvious: CONTRIBUTING says how the repository is worked
  # on, README says what it is. Checked as an ordering, not as prose — a
  # sentence claiming the ranking while the list encodes the opposite is worse
  # than neither.
  Assert "CONTRIBUTING.md outranks README.md in the precedence chain" {
    $lines = (Get-SkillFile $claudeTemplate) -split '\r?\n'
    $contributing = ($lines | Select-String -Pattern '^\d+\.\s.*CONTRIBUTING\.md' | Select-Object -First 1).LineNumber
    $readme       = ($lines | Select-String -Pattern '^\d+\.\s.*README\.md' | Select-Object -First 1).LineNumber
    if (-not $contributing) { throw 'CONTRIBUTING.md is not in the numbered chain' }
    if (-not $readme) { throw 'README.md is not in the numbered chain' }
    if ($contributing -ge $readme) { throw "README ranks at or above CONTRIBUTING" }
    $true
  }

  # ADR 0008's general form. /commit carries the commit-message procedure; the
  # principle it is an instance of has to hold on turns where no skill runs —
  # naming a branch, picking a label, following a layout.
  Assert "repository conventions outrank Tenure's defaults — detect before asserting" {
    $c = Get-SkillFile $claudeTemplate
    if ($c -notmatch $rulePattern['conventions are defaults']) { throw 'the defaults are stated as mandates' }
    if ($c -notmatch 'ADR 0008') { throw 'the decision is not cited' }
    # The instruction, not just the principle. Knowing the repository wins does
    # nothing unless something says to go and look before writing.
    if ($c -notmatch '(?i)detect (it |them )?before asserting') { throw 'nothing says to look first' }
    $true
  }

  Assert "the CLAUDE.md template is still under 200 lines with every rule placed" {
    $n = ((Get-SkillFile $claudeTemplate) -split '\r?\n').Count
    if ($n -ge 200) { throw "$n lines" }
    $true
  }
}

# --- ticket tenure/16 — Position, and the line between shared and local -------------

Describe-Ticket 'tenure/16' 'position, and the line between shared and local' {

  # Criterion 1, and criterion 4 with it. Both reduce to the same mechanical
  # question: does the committed always-on file name anything the ignore file
  # matches? A rule about `marker.json` in `CLAUDE.md` is an instruction a
  # Claude without the plugin cannot follow and cannot know to skip.
  #
  # Read off the ignore block rather than hardcoded, so an entry added there
  # later is checked here without anyone remembering to.
  Assert "the always-on file names no per-clone file — nothing committed reads Position" {
    $ignore = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n(.*?)^```')
    if (-not $ignore.Success) { throw 'no ignore block to read the category from' }
    $entries = $ignore.Groups[1].Value -split '\r?\n' |
      Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' } |
      ForEach-Object { $_.Trim() }
    if (-not $entries) { throw 'the category has no members' }
    $c = Get-SkillFile $claudeTemplate
    $found = $entries | Where-Object { $c -match [regex]::Escape($_) }
    if ($found) { throw "always-on instruction about Position: $($found -join ', ')" }
    $true
  }

  # Criterion 5's readable half: a reader of either file can see which one they
  # are in and why the other exists. Two-sided, because a pointer out of
  # `CLAUDE.md` with nothing acknowledging the split at the far end leaves the
  # protocol file looking like a stray duplicate of the rules.
  Assert "each half names the other and says why the split exists" {
    $claude = Get-SkillFile $claudeTemplate
    $tenure = Get-SkillFile $tenureTemplate
    if ($claude -notmatch '\.claude/tenure\.md') { throw 'CLAUDE.md never points at the protocol' }
    if ($claude -notmatch '(?i)with or without|plugin or not|either way') {
      throw 'CLAUDE.md never says why it is the half that holds universally'
    }
    if ($tenure -notmatch 'CLAUDE\.md') { throw 'the protocol never names the file it split from' }
    if ($tenure -notmatch '(?i)only[^\r\n]{0,60}Tenure.{0,20}skills read|only Tenure.{0,20}skills') {
      throw 'the protocol never says who reads it'
    }
    $true
  }

  # Criterion 3, and ADR 0007's consequence held visibly. A rule inside the
  # moved file fires only when a Tenure skill runs — correct for machinery,
  # a silent failure for anything unconditional. `$rulePattern` is the set
  # ticket 13 placed in `CLAUDE.md` precisely because it must always hold.
  Assert "no rule that must hold on every turn moved into the protocol file" {
    $c = Get-SkillFile $tenureTemplate
    $leaked = $rulePattern.Keys | Where-Object { $c -match $rulePattern[$_] }
    $alwaysOn = @{
      'Claude never silently decides architecture' = '(?i)never silently decid'
      'the instruction precedence chain'           = '(?im)^##[^\r\n]*precedence'
      'the cold-request path'                      = '(?i)state the classification'
    }
    $leaked += $alwaysOn.Keys | Where-Object { $c -match $alwaysOn[$_] }
    if ($leaked) { throw "unconditional rule in a file only skills read: $($leaked -join ', ')" }
    $true
  }

  # The Marker had to survive the move as machinery, not vanish with it. It is
  # only safe out of the always-on file because it never *adds* an obligation:
  # with no marker at all, CLAUDE.md's verification rule applies unchanged.
  Assert "the Marker is stated as a shortcut whose absence costs nothing but the shortcut" {
    $c = Get-SkillFile $tenureTemplate
    if ($c -notmatch '(?i)cache-validity') { throw 'the Marker is not framed as a cache' }
    # Bounded to one line rather than one sentence: the clause names
    # `CLAUDE.md`, and `[^.]` stops dead on the dot in the filename.
    $c -match '(?i)(no marker|without[^\r\n]{0,30}marker)[^\r\n]{0,160}(unchanged|still applies)'
  }

  # Criterion 2. The category has to carry a test, or `/configure` is back to
  # being told about each new file one at a time — which is the failure ADR
  # 0012 names: a list is what it forgets.
  Assert "the ignore file states the category with a test a reader can apply, not a list" {
    $block = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n.*?^```')
    if (-not $block.Success) { throw 'the ignore file is described but never written out' }
    $b = $block.Value
    if ($b -notmatch '(?i)Position') { throw 'the category is unnamed' }
    if ($b -notmatch '(?i)wrong in another clone') { throw 'no membership test a reader can apply' }
    if ($b -notmatch '(?i)knowledge is committed|committed and reviewed') { throw 'the other side of the test is missing' }
    $true
  }

  # The invariant is what keeps Position from becoming a fourth knowledge
  # layer, and it belongs with the concept rather than in the ignore file,
  # which carries the membership test. Stated as a deletion, because that is
  # the form that can actually be checked against a repository.
  Assert "the Position invariant is stated — nothing shared may depend on it" {
    $c = Get-SkillFile $tenureTemplate
    if ($c -notmatch '(?i)nothing shared may depend on it') { throw 'the invariant is never stated' }
    $c -match '(?i)delete[^\r\n]{0,120}(no other person|no other clone)'
  }

  # Criterion 5. Both files or neither: `/configure` writing only the always-on
  # half leaves every pointer in it dangling, and writing only the protocol
  # leaves nothing loading it.
  Assert "/configure writes both halves, and says they go together" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -notmatch 'tenure\.template\.md') { throw 'the protocol template is never installed' }
    if ($c -notmatch '\.claude/tenure\.md') { throw 'the destination is never named' }
    $c -match '(?i)both or neither|write both'
  }

  # The pointers that moved with the rules. Cutting a rule out of `CLAUDE.md`
  # without repointing the skills that reached it there is how a rule stops
  # firing at all — and every one of these files still names `CLAUDE.md` for
  # unrelated rules, so a file-wide search proves nothing.
  $moved = @(
    @{ f = 'design/SKILL.md';      what = 'the drift reads' }
    @{ f = 'implement/SKILL.md';   what = 'the drift reads' }
    @{ f = 'review/SKILL.md'; what = 'the verification report' }
    @{ f = 'commit/SKILL.md';      what = 'the verification report' }
    @{ f = 'configure/SKILL.md';   what = 'the verification report' }
  )
  foreach ($m in $moved) {
    Assert "$($m.f) reaches $($m.what) at its new home" {
      $c = Get-SkillFile $m.f
      if ($c -notmatch '\.claude/tenure\.md') { throw 'still pointed at the always-on file, or nowhere' }
      $true
    }
  }
}

# --- ticket tenure/17 — assignment, and the branch as the lock ----------------------

Describe-Ticket 'tenure/17' 'assignment, claim, and the branch as the lock' {

  $imp = 'implement/SKILL.md'
  $tix = 'design/TICKETS.md'

  # The Claim lives in a `### ` subsection of step 1, and Get-Section only
  # scopes `## `. Scoping matters more than usual here: step 1 also carries the
  # frontier and the obsolete branch, both of which use the word "claim", so a
  # whole-section search passes on prose that has nothing to do with the rule.
  $claimSection = {
    $m = [regex]::Match((Get-SkillFile $imp), '(?ims)^###\s[^\r\n]*\bClaim\b.*?(?=^#{2,3}\s|\z)')
    if (-not $m.Success) { throw 'the Claim has no section of its own' }
    $m.Value
  }

  # Criterion 3, and the whole point of the mechanism. Scoped to the claim
  # section rather than the file: "before any work" also appears in the step
  # diagram, so a file-wide check stays green with the discipline deleted.
  Assert "the Claim is the branch, created before the first read and the first edit" {
    $s = & $claimSection
    if ($s -notmatch '(?i)first act of the run') { throw 'claiming is not stated as the first act' }
    if ($s -notmatch '(?i)first edit') { throw 'editing first is not named as the failure' }
    $s -match '(?i)not a claim|is not a claim'
  }

  # Criterion 5. A tracker carries human-level facts; a `claimed` status is
  # agent bookkeeping on that surface, and a file write cannot exclude anyone
  # anyway — two instances write it in the same moment and both proceed.
  Assert "no tracker state records which instance is working" {
    $c = Get-SkillFile $tix
    if ($c -notmatch '(?i)no `?claimed`? state') { throw 'the removed state is not accounted for' }
    if ($c -match '(?m)^claimed\s+\S') { throw '`claimed` is still a lifecycle state' }
    if ($c -match '(?i)Status:\s*claimed') { throw 'the claim is still written to the ticket' }
    $true
  }

  # Criterion 4. `never taken` is the whole rule — a claim that can be taken
  # under some condition is a request, and the conditions are what get argued.
  Assert "a claim held elsewhere is reported and never taken" {
    $s = & $claimSection
    if ($s -notmatch $rulePattern['a claim held elsewhere is not taken']) { throw 'the rule is not stated' }
    # The escape hatches, named individually, because each is a plausible
    # workaround someone reaches for while believing they kept the rule.
    foreach ($out in @('renamed around', 'branched from', 'force-created')) {
      if ($s -notmatch [regex]::Escape($out)) { throw "the workaround is not closed off: $out" }
    }
    # Git's refusal is the backstop, not the check. Arriving at it means the
    # read was skipped, and a run that treats it as a normal outcome has no
    # reason to do the read at all.
    $s -match '(?i)(fatal|refuses)[^\r\n]{0,120}(bug in the run|not a result)|(bug in the run|not a result)'
  }

  # Criterion 2, both halves: no file the repository does not carry, and no
  # question asked. The branch is already there, and it is git's, not Tenure's.
  Assert "an instance that lost its context recovers the ticket from the branch alone" {
    $c = Get-SkillFile $imp
    $s = [regex]::Match($c, '(?ims)^###\s.*resum.*?(?=^#{2,3}\s|\z)')
    if (-not $s.Success) { throw 'recovery is not its own step' }
    if ($s.Value -notmatch '(?i)current branch|branch it is standing on') { throw 'the branch is not the read' }
    # Detached HEAD is the case that has no answer, and inventing one there is
    # exactly the guess the mechanism exists to remove.
    if ($s.Value -notmatch '(?i)detached HEAD') { throw 'the no-branch case is unhandled' }
    $s.Value -match '(?i)(do not guess|never guess)'
  }

  # Criterion 1 rests on this. Two tools that name the same ticket differently
  # produce two branches, neither of which sees the other's claim — so the
  # convention is Tenure's own, and it has to be reproducible from the ticket.
  Assert "branch naming is Tenure's own convention and encodes the ticket" {
    $s = & $claimSection
    if ($s -notmatch $rulePattern['the branch-name convention']) { throw 'the shape is not given' }
    if ($s -notmatch "(?i)not the default of whichever tool|Tenure'?s own convention") {
      throw 'the convention is left to the tool that creates the branch'
    }
    # ADR 0008 still applies: a repository that already has a convention wins.
    $s -match '(?i)repository already has a branch convention|already has a branch convention'
  }

  # ADR 0013's separation. Assignment is what makes a light claim safe, so the
  # reason has to travel with it — otherwise the branch looks like an
  # under-engineered lock rather than a correctly sized one.
  Assert "Assignment is human-level, read but never written unasked" {
    foreach ($f in @($imp, $tix)) {
      $c = Get-SkillFile $f
      if ($c -notmatch '(?i)never writes? it unasked|never written unasked') {
        throw "$f does not protect Assignment"
      }
    }
    # The invariant, stated where the mechanism is chosen.
    (Get-SkillFile $imp) -match '(?i)Assignment already separates humans'
  }

  # Criterion 6. Ticket 15's global check catches an invocation with no entry
  # at all; this one names the reads the Claim actually depends on, so dropping
  # one from the reference is caught here rather than by nothing.
  Assert "every read the Claim depends on is an entry in the tool reference" {
    $g = Get-SkillFile 'configure/tools/git.md'
    $required = @{
      'the current branch'   = '(?m)^git branch --show-current'
      'creating the branch'  = '(?m)^git switch -c <branch>'
      'the local claim read' = '(?m)^git show-ref --verify --quiet refs/heads/'
      'the remote claim read' = '(?m)^git ls-remote --heads'
      'the stale-ref refresh' = '(?m)^git fetch --prune'
    }
    $missing = $required.Keys | Where-Object { $g -notmatch $required[$_] }
    if ($missing) { throw "guessed rather than referenced: $($missing -join ', ')" }
    # Detached HEAD returns empty, and empty reads as a failed command unless
    # the reference says otherwise. That misreading is a silent wrong claim.
    $g -match '(?i)empty output is a real answer'
  }

  # `gh issue develop` is the invocation someone reaches for on a GitHub repo,
  # and it is wrong twice over — it publishes, and it names the branch GitHub's
  # way. Both have to be in the reference, or it gets used.
  Assert "gh issue develop is documented as publishing, and as not the claim" {
    $c = Get-SkillFile 'configure/tools/github.md'
    if ($c -notmatch 'gh issue develop') { throw 'the trap is undocumented' }
    if ($c -notmatch '(?i)ON THE REMOTE|creates the branch in the repository') { throw 'it is not marked as publishing' }
    $c -match '(?i)not the read that answers whether a ticket is claimed|is not the claim'
  }

  # A hand-back releases the branch; a hand-back with work on it does not.
  # Deleting a branch carrying a commit destroys the evidence the hand-back
  # exists to preserve.
  Assert "releasing a claim keeps the branch when there is a commit on it" {
    $c = Get-SkillFile $imp
    $c -match '(?i)partial commit exists[^\r\n]{0,80}keep the branch'
  }
}

# --- ticket tenure/18 — what tenure may write to a shared tracker -------------------

Describe-Ticket 'tenure/18' 'what tenure may write to a tracker other people read' {

  $gh  = 'configure/tools/github.md'
  $tix = 'design/TICKETS.md'

  # Criterion 1. The gate has to be on the invocation, not only in the skill
  # that usually issues it — the reference is what a reader opens when they are
  # about to run the command, and it already gates `gh pr create` this way.
  Assert "creating an issue is gated as publishing, where the invocation lives" {
    $s = Get-Section (Get-SkillFile $gh) 'Create an issue'
    if ($s -notmatch '(?i)publish') { throw 'issue creation is not named as publishing' }
    $s -match "(?i)human'?s call"
  }

  # And the procedure the gate needs to be actionable. A gate with no route
  # through it becomes a thing to apologise for and then do anyway.
  Assert "the ticket set is proposed and approved before anything is created" {
    $c = Get-SkillFile 'design/SKILL.md'
    $s = [regex]::Match($c, '(?ims)^###\s[^\r\n]*approved before it is created.*?(?=^#{2,3}\s|\z)')
    if (-not $s.Success) { throw 'there is no approval step' }
    $v = $s.Value
    # Criterion 1's second half: the set survives a context reset, which is the
    # only reason it is safe for approval to take as long as it takes.
    if ($v -notmatch '(?i)design document') { throw 'the proposal lives only in the conversation' }
    if ($v -notmatch '(?i)context reset') { throw 'survival across a reset is not claimed' }
    # Ordering, not presence — approval after creation is not approval.
    $approve = $v.IndexOf('approved')
    $create  = $v.LastIndexOf('only then create')
    if ($create -lt 0) { throw 'creation is never sequenced' }
    if ($approve -gt $create) { throw 'the set is created before it is approved' }
    $true
  }

  # Criterion 2. One root per run whatever the count, and the degenerate case
  # stated — wrapping a single ticket in a parent is the reading that makes the
  # top level grow by two.
  Assert "a design run adds exactly one top-level ticket, whatever the ticket count" {
    $c = Get-SkillFile $tix
    if ($c -notmatch '(?i)one design run, one root') { throw 'the rule is not stated' }
    if ($c -notmatch '(?i)single ticket makes that one the root|yields exactly one ticket makes that one the root') {
      throw 'the one-ticket case is unhandled'
    }
    $c -match '(?i)(top level|tracker).{0,80}(grows|grow) by one'
  }

  # Criterion 3. On a shared tracker the triage queue and the frontier are one
  # list, so this is not a rare case — and the failure it prevents is worse
  # than stopping: filling in someone else's issue is designing without a grill.
  Assert "an incoming issue is refused by /implement with the reason, and routed" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)frontier is build tickets only') { throw 'the frontier still admits raw issues' }
    if ($c -notmatch '(?i)no acceptance criteria|acceptance criteria') { throw 'the reason is not given' }
    if ($c -notmatch '(?i)/design') { throw 'it is refused without being routed' }
    $c -match '(?i)do not fill the gaps in yourself|never fill the gaps'
  }

  # And the far end of that route: /design has to accept the entry point, or
  # the refusal points at a door nobody opens.
  Assert "/design accepts an incoming issue and makes it the root" {
    $c = Get-SkillFile 'design/SKILL.md'
    $s = [regex]::Match($c, '(?ims)^##\s[^\r\n]*incoming issue.*?(?=^#{2}\s|\z)')
    if (-not $s.Success) { throw 'the entry point does not exist' }
    $s.Value -match '(?i)becomes\*{0,2} the root'
  }

  # Criterion 4. Tenure never pushes, opens a PR, or merges, so resolving a
  # shared ticket asserts an outcome it does not control.
  Assert "the merge resolves a shared ticket, and /implement never closes one" {
    $c = Get-SkillFile $tix
    if ($c -notmatch '(?i)merge resolves the ticket, not Tenure') { throw 'the rule is not stated' }
    # The reason, not just the rule: a closed issue whose PR is rejected is a
    # lie the tracker tells everyone, and that is what stops it being reversed.
    if ($c -notmatch '(?i)later rejected|is a lie') { throw 'the reason is missing' }
    # The criterion: no new tracker state is needed in between, because the
    # branch is still the Claim.
    if ($c -notmatch '(?i)branch still exists') { throw 'the gap between commit and merge is unaccounted for' }
    (Get-SkillFile 'implement/SKILL.md') -match '(?i)never closes an issue other people read'
  }

  # The split, and the hazard that forces it. `Closes` in a commit is live
  # forever — a cherry-pick onto the default branch closes an issue nobody
  # merged — which is why the commit gets the non-closing form.
  Assert "the commit references without closing, and the PR body carries the keyword" {
    $c = Get-SkillFile $gh
    $s = Get-Section $c 'Close an issue by merging'
    if ($s -notmatch '(?m)\|[^|\r\n]*commit message[^|\r\n]*\|\s*`Refs #') { throw 'the commit form is not the non-closing one' }
    if ($s -notmatch '(?m)\|[^|\r\n]*pull request body[^|\r\n]*\|\s*`Closes #') { throw 'the PR form does not close' }
    # Verified against the docs, and both are counter-intuitive enough that
    # leaving either out is how the split gets "simplified" back together.
    if ($s -notmatch '(?i)default branch') { throw 'the default-branch constraint is missing' }
    if ($s -notmatch '(?i)cherry-pick') { throw 'the hazard behind the split is not recorded' }
    # /commit is where the form is chosen, so the non-closing one has to be
    # reachable there and not only in the CLI reference.
    (Get-SkillFile 'commit/SKILL.md') -match '(?i)a reference that closes nothing'
  }

  # Criteria 5 and 6. Parent/child is a different edge from blocking, and it
  # was previously reachable only through a section titled for blocking.
  Assert "parent/child is findable as parent/child, not only under blocking" {
    $c = Get-SkillFile $gh
    if ($c -notmatch '(?im)^##[^\r\n]*(parent|sub-issue)') { throw 'no section a reader looking for parent/child would open' }
    if ($c -notmatch '(?im)^##[^\r\n]*block') { throw 'blocking lost its own entry' }
    # The trap the docs fetch actually turned up: the API wants the issue's
    # id, and passing its number succeeds against a different issue.
    if ($c -notmatch '(?i)`?sub_issue_id`? is the issue') { throw 'the id/number distinction is not recorded' }
    $c -match '(?i)not its number'
  }

  # Nothing in the ticket format may promise an invocation gh does not have.
  # Read the table's GitHub row and require each mechanism it names to be in
  # the reference — the format is where a promise gets made, and the reference
  # is the only thing that can honour it.
  Assert "every relationship the ticket format promises is documented in the reference" {
    $row = [regex]::Match((Get-SkillFile $tix), '(?m)^\|\s*GitHub\s*\|(.+)$')
    if (-not $row.Success) { throw 'the edge table has no GitHub row' }
    $r = $row.Groups[1].Value
    $c = Get-SkillFile $gh
    $promises = @{
      'the sub-issues API'   = @{ inRow = '(?i)sub-issues API'; inRef = '(?i)sub_issues' }
      'the task-list fallback' = @{ inRow = '(?i)task list';    inRef = '(?i)task list in the parent' }
      'a body-text blocker'  = @{ inRow = '(?i)Blocked by';     inRef = '(?i)state the edge in the issue body' }
    }
    $broken = $promises.Keys | Where-Object {
      ($r -match $promises[$_].inRow) -and ($c -notmatch $promises[$_].inRef)
    }
    if ($broken) { throw "promised but undocumented: $($broken -join ', ')" }
    $true
  }
}

# --- ticket tenure/19 — on a stack, blocked means stacked ---------------------------

Describe-Ticket 'tenure/19' 'on a stack, blocked means stacked' {

  $imp = 'implement/SKILL.md'
  $gt  = 'configure/tools/graphite.md'

  # The stacking branch of step 1, scoped like the Claim's — step 1 is long and
  # says "branch", "blocked" and "commit" throughout for other reasons.
  $stackSection = {
    $m = [regex]::Match((Get-SkillFile $imp), '(?ims)^###\s[^\r\n]*stacking repository.*?(?=^#{2,3}\s|\z)')
    if (-not $m.Success) { throw 'the stacking branch has no section of its own' }
    $m.Value
  }

  # Criterion 1. `committed`, not merged and not resolved — the distinction is
  # the whole ticket, because Tenure never merges, so a merge-gated frontier
  # on a stacking repository empties and stays empty.
  Assert "a ticket whose blockers are committed but unmerged is buildable" {
    $s = & $stackSection
    if ($s -notmatch '(?i)COMMITTED') { throw 'the new gate is not stated' }
    if ($s -notmatch '(?i)not merged') { throw 'the old gate is not excluded' }
    $s -match '(?i)frontier empties|frontier[^\r\n]{0,40}empt'
  }

  # And the branch goes on the blocker, not on trunk — which is the half that
  # makes the earlier frontier safe rather than just faster.
  Assert "the branch is created on the blocker rather than on trunk" {
    $s = & $stackSection
    if ($s -notmatch "(?i)check out the blocker'?s branch") { throw 'the base is never changed' }
    if ($s -notmatch '(?i)on top of it') { throw 'the new branch is not stacked on it' }
    # Ticket 17's convention has to survive: gt generates a name from the
    # commit message if it is not given one, and two naming schemes for one
    # ticket means neither tool sees the other's claim.
    $s -match "(?i)name is still Tenure'?s"
  }

  # Criterion 2. Both readings exist, and which applies is read rather than
  # assumed — a guess is wrong in a way that looks like nothing happening.
  #
  # `layout/05` moved *where* the read points, from a build-time probe to
  # `.claude/version-control.md`, which states the model and carries the check
  # for its own claim. The criterion is unchanged and so is this assertion's
  # subject: determination must have a stated source. Naming that file is the
  # second alternative, so dropping the file and going back to guessing fails
  # here as well as in `layout/05`.
  Assert "which meaning applies is read off the repository, never guessed" {
    $s = & $stackSection
    if ($s -notmatch '(?i)never guess it|version-control\.md') { throw 'the detection is not required' }
    # Both failure directions, because only one of them is loud.
    if ($s -notmatch '(?i)assume plain git on a stacking') { throw 'the stalling direction is unstated' }
    $s -match '(?i)assume stacking on a plain'
  }

  # Criterion 3. A bare `git commit --amend` mid-stack leaves every descendant
  # on a commit that no longer exists — silent, and only visible later as a
  # conflict nobody caused.
  Assert "the mid-stack amend leaves no descendant on a replaced commit" {
    $s = & $stackSection
    if ($s -notmatch '(?i)never with a bare `?git commit --amend`?') { throw 'the plain amend is not ruled out' }
    if ($s -notmatch '(?i)descendant') { throw 'the consequence is not named' }
    # The invocation itself stays in the reference, with what it restacks.
    $g = Get-SkillFile $gt
    ($g -match '(?m)^gt modify') -and ($g -match '(?i)restacks every descendant')
  }

  # Criterion 4. Both are costs accepted on the user's behalf, so both are said
  # before the stack exists rather than when one of them bites.
  Assert "the one-instance-per-stack rule and the rejected-review cost are both stated up front" {
    $s = & $stackSection
    if ($s -notmatch '(?i)a stack belongs to one instance') { throw 'the constraint is missing' }
    if ($s -notmatch '(?i)separate stacks off trunk') { throw 'parallel instances have nowhere to go' }
    if ($s -notmatch '(?i)invalidates every branch above it') { throw 'the cost is missing' }
    $s -match '(?i)when the stack is created|before the stack exists|in the same breath'
  }

  # Criterion 5, and the point of the whole verification discipline. The
  # question the ticket left open was whether submit prefills the description;
  # the answer the fetch produced is that nothing documents it — so the
  # reference has to record the absence, not stay silent and let a later reader
  # assume the check was never needed.
  Assert "nothing relies on the submit path's prefill, and the reference says why" {
    $g = Get-SkillFile $gt
    if ($g -notmatch '(?i)not documented') { throw 'the unverified behaviour is not marked unverified' }
    if ($g -notmatch '(?i)nothing may depend on it') { throw 'reliance is not forbidden' }
    # The half that IS verified, and the reason the keyword had to move.
    if ($g -notmatch '(?i)no `?--title`?, `?--body`?, `?--body-file`?, or stdin') {
      throw 'the absence of a non-interactive body is not recorded'
    }
    $g -match '(?i)verified against `?gt submit --help'
  }

  # The reversal, and the reason it is safe here — stated where the form is
  # chosen. Both rows, because a table with one row is a rule with no contrast.
  Assert "the closing keyword moves into the commit body on a stack, and only there" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?m)\|[^|\r\n]*stack[^|\r\n]*\|\s*the closing keyword\s*\|') { throw 'the stacked case does not close' }
    if ($c -notmatch '(?i)only by merging that branch'){ throw 'the reason the hazard vanishes is missing' }
    # /implement selects the case; it does not restate the rule.
    $s = & $stackSection
    if ($s -notmatch '(?i)/commit` has the rule|`/commit` has the rule') { throw '/implement does not route to the rule' }
    $true
  }

  # ADR 0016 ties the Claim's unit to the stack because restacking rewrites
  # other tickets' branches. ADR 0013 is where the Claim is defined, so the
  # widening has to be visible from the Claim's own section, not only here.
  Assert "the Claim's unit widens to the stack, reachable from the Claim itself" {
    $c = Get-SkillFile $imp
    $claim = [regex]::Match($c, '(?ims)^###\s[^\r\n]*\bClaim\b.*?(?=^#{2,3}\s|\z)')
    $stack = [regex]::Match($c, '(?ims)^###\s[^\r\n]*stacking repository.*?(?=^#{2,3}\s|\z)')
    if (-not ($claim.Success -and $stack.Success)) { throw 'one of the two sections is gone' }
    if ($stack.Index -lt $claim.Index) { throw 'the stack case is stated before the Claim it widens' }
    $stack.Value -match "(?i)Claim'?s unit becomes the whole stack"
  }
}

# --- ticket tenure/20 — ship tenure as a plugin -------------------------------------

Describe-Ticket 'tenure/20' 'ship tenure as a plugin, and shorten the names people type' {

  # Both manifests are read as JSON rather than grepped: a file that does not
  # parse is not a manifest, and every field below is only meaningful if it
  # does. `-Raw` because ConvertFrom-Json on an array of lines is a different
  # object on Windows PowerShell than on pwsh.
  $readJson = {
    param([string]$Relative)
    $p = Join-Path $repo $Relative
    if (-not (Test-Path $p)) { throw "$Relative is missing" }
    try { (Get-Content $p -Raw) | ConvertFrom-Json }
    catch { throw "$Relative is not valid JSON — $($_.Exception.Message)" }
  }

  # Criterion 1. The marketplace is what makes `local` scope reachable at all:
  # it is the only scope that is per-project and per-person, and it installs
  # from a marketplace, so without this file the scope cannot be chosen.
  Assert "this repository publishes itself as a plugin marketplace" {
    $m = & $readJson '.claude-plugin/marketplace.json'
    foreach ($f in @('name', 'owner', 'plugins')) {
      if (-not $m.$f) { throw "marketplace.json has no $f" }
    }
    if (-not $m.owner.name) { throw 'owner.name is required and absent' }
    $entry = @($m.plugins | Where-Object { $_.name -eq 'tenure' })
    if ($entry.Count -ne 1) { throw 'the marketplace does not publish exactly one tenure plugin' }
    if (-not $entry[0].source) { throw 'the plugin entry has no source' }
    $true
  }

  # The plugin's own manifest, and the `name` that becomes the command
  # namespace — every command in the framework is typed through it, so it is
  # the one string here that cannot drift.
  Assert "the plugin manifest names the namespace every command is typed through" {
    $p = & $readJson '.claude-plugin/plugin.json'
    # Case-sensitive: `-ne` is not, and the namespace is a literal string that
    # ends up in every command the user types. `Tenure` is a different plugin.
    if ($p.name -cne 'tenure') { throw "the namespace is '$($p.name)', not 'tenure'" }
    if (-not $p.description) { throw 'plugin.json has no description' }
    # The marketplace entry keys `enabledPlugins`, so the two names must agree
    # or an install enables nothing.
    $m = & $readJson '.claude-plugin/marketplace.json'
    if (-not (@($m.plugins.name) -ccontains $p.name)) { throw 'the marketplace does not list this plugin' }
    $true
  }

  # The plugin's skills have to be where a plugin's skills are loaded from,
  # or the manifest describes a plugin with nothing in it.
  Assert "the plugin's source resolves to the directory the skills are actually in" {
    $m = & $readJson '.claude-plugin/marketplace.json'
    $src = @($m.plugins | Where-Object { $_.name -eq 'tenure' })[0].source
    if ($src -isnot [string]) { throw 'the source is not a repository-relative path' }
    $root = Join-Path $repo ($src -replace '^\./', '')
    if (-not (Test-Path (Join-Path $root 'skills'))) { throw "no skills/ under the plugin source '$src'" }
    Test-Path (Join-Path $root '.claude-plugin/plugin.json')
  }

  # Criterion 2. Enabling Tenure in a project is Position (ADR 0012), so the
  # record of it is ignored like every other per-clone file — and it goes
  # through the category rather than being argued for as a fourth exception,
  # which is the whole point of naming the category.
  Assert "the record of enabling Tenure is not committed" {
    $block = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n.*?^```')
    if (-not $block.Success) { throw 'there is no ignore block' }
    $block.Value -match '(?m)^settings\.local\.json'
  }

  # Criterion 3, checked against each skill's own frontmatter rather than a
  # hand-kept list — a skill added later is held to the rule without anyone
  # remembering to add it here.
  Assert "every user-invoked skill is one word" {
    $long = @()
    foreach ($f in (Get-ChildItem $skills -Directory)) {
      $skill = Join-Path $f.FullName 'SKILL.md'
      if (-not (Test-Path $skill)) { continue }
      $rel = "$($f.Name)/SKILL.md"
      if ((Test-UserInvoked $rel) -and $f.Name -match '-') { $long += $f.Name }
    }
    if ($long) { throw "typed, but not one word: $($long -join ', ')" }
    $true
  }

  # The other half of criterion 3 — "every model-invoked skill keeps a name
  # that describes when to use it" — is a judgement call and is not machine
  # checkable. What *is* checkable is the thing the rule protects: a
  # model-invoked skill is chosen by its description, so a description with no
  # selection condition in it cannot be chosen correctly whatever the name is.
  Assert "every model-invoked skill states when to use it, which is how it is selected" {
    $silent = @()
    foreach ($f in (Get-ChildItem $skills -Directory)) {
      $skill = Join-Path $f.FullName 'SKILL.md'
      if (-not (Test-Path $skill)) { continue }
      $rel = "$($f.Name)/SKILL.md"
      if (Test-UserInvoked $rel) { continue }
      $fm = Get-Frontmatter (Get-SkillFile $rel)
      # `Use when`, `Use before`, `Use for` — the clause, not the word, so a
      # description that merely contains "use" somewhere does not pass.
      if ($fm -notmatch '(?im)^description:.*\bUse (when|before|after|for|while)\b') { $silent += $f.Name }
    }
    if ($silent) { throw "model-invoked with no selection condition: $($silent -join ', ')" }
    $true
  }

  # The other half, and the one that decays quietly: a model-invoked skill is
  # selected *by its description*, so shortening its name for consistency
  # costs selection accuracy and buys brevity nobody types. Asserted as the
  # rule being written down, because the rule is what stops the next skill
  # being shortened to match.
  #
  # Its home is `.claude/rules/skills.md`, not the always-on `CLAUDE.md`: it
  # is a standard discovered in this repository and it fires only when a skill
  # is being authored. Ticket 12 moved it there, and this assertion moved with
  # it — a guard left pointing at the old home would have passed on a stale
  # copy and failed on the real one.
  Assert "the naming rule is written down, not just applied" {
    $c = Get-Content (Join-Path $repo '.claude/rules/skills.md') -Raw
    if ($c -notmatch '(?i)short names are for the keyboard') { throw 'the rule is stated nowhere' }
    if ($c -notmatch '(?i)descriptive names are for the model') { throw 'only half the rule is stated' }
    # And why a model-invoked `review` is not a breach of it.
    $c -match '(?i)shortening \*{0,2}for brevity\*{0,2}|bans shortening \*{0,2}for brevity'
  }

  # Criterion 4. Checked over everything shipped plus the repository's own
  # docs — prose and pointers included, which is where a rename usually
  # survives, because nothing breaks when it does.
  Assert "no renamed skill's old name survives anywhere" {
    $old = @('code-review', 'improve-codebase-architecture')
    $files = @(Get-SkillFiles) +
             @('CLAUDE.md', '.claude/context.md', 'README.md' | ForEach-Object { Get-Item (Join-Path $repo $_) })
    $hits = @()
    foreach ($file in $files) {
      $lines = (Get-Content $file.FullName -Raw) -split '\r?\n'
      for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($o in $old) {
          if ($lines[$i] -match [regex]::Escape($o)) {
            $hits += "$($file.Name):$($i + 1): $o"
          }
        }
      }
    }
    if ($hits) { throw ($hits -join ', ') }
    $true
  }

  # And the directories themselves, so a rename that copied instead of moving
  # is caught rather than passing because the old file is no longer referenced.
  Assert "the renamed skills exist under their new names and nowhere else" {
    $renames = [ordered]@{
      'tenure'                        = 'help'
      'code-review'                   = 'review'
      'improve-codebase-architecture' = 'survey'
    }
    $wrong = @()
    foreach ($before in $renames.Keys) {
      $after = $renames[$before]
      if (Test-Path (Join-Path $skills $before)) { $wrong += "skills/$before still exists" }
      if (-not (Test-Path (Join-Path $skills "$after/SKILL.md"))) { $wrong += "skills/$after is missing" }
    }
    if ($wrong) { throw ($wrong -join ', ') }
    $true
  }

  # Criterion 5. A teammate without the plugin still gets a useful repository,
  # which means nothing in the always-on file may assume a Tenure command
  # exists. Ticket 16 kept Position out of it; this keeps the commands out.
  Assert "nothing committed assumes a Tenure command exists" {
    $c = Get-SkillFile $claudeTemplate
    # The comment header names /configure as the thing that installed the
    # file, which is a fact about provenance rather than an instruction. Body
    # only.
    $body = ($c -replace '(?s)<!--.*?-->', '')
    $commands = @()
    foreach ($d in (Get-ChildItem $skills -Directory)) {
      foreach ($m in [regex]::Matches($body, "(?<![\w:])/$([regex]::Escape($d.Name))(?![\w-])")) {
        $commands += $d.Name
      }
    }
    if ($commands) { throw "the always-on file instructs a command: $(($commands | Select-Object -Unique) -join ', ')" }
    $true
  }

  # Criterion 6. A superseded decision keeps what it said and gains a pointer
  # to what replaced it — editing it to read as though it never said otherwise
  # destroys the reasoning the record exists for.
  Assert "decision 13 records what superseded it rather than being rewritten" {
    $spec = Get-Content (Join-Path $repo '.claude/tickets/tenure/spec.md') -Raw
    $row = [regex]::Match($spec, '(?m)^\|\s*13\s*\|(.+)$')
    if (-not $row.Success) { throw 'decision 13 is gone from the spec' }
    $r = $row.Groups[1].Value
    if ($r -notmatch '(?i)supersede') { throw 'the supersession is not recorded' }
    # What it originally said has to still be readable, or the row is a
    # rewrite wearing a supersession note.
    if ($r -notmatch 'code-review') { throw 'the original decision was edited away' }
    # And the ADR that replaced it, reachable from the row.
    $r -match '0015'
  }
}

# --- ticket layout/01 — dissolve the docs level ------------------------------

Describe-Ticket 'layout/01' 'dissolve the docs level in the shipped layout' {

  # The headline criterion — "no file under ./skills names a .claude/docs/
  # path" — is asserted by the $legacy sweep in ticket tenure/01, where the
  # other superseded paths already are. What is here is the other half: the
  # new homes are actually named, by the skill that writes to each. Without
  # this, deleting every mention of a location passes the sweep.

  # skill that owns writing it → where it now writes.
  $homes = [ordered]@{
    'domain-modeling/ADR-FORMAT.md' = '\.claude/decisions/'
    'design/SPEC-FORMAT.md'         = '\.claude/designs/'
    'research/SKILL.md'             = '\.claude/evidence/research/'
    'prototype/SKILL.md'            = '\.claude/evidence/prototypes/'
    'triage/OUT-OF-SCOPE.md'        = '\.claude/evidence/out-of-scope/'
  }
  foreach ($file in $homes.Keys) {
    $path = $homes[$file]
    Assert "$file writes to $($path -replace '\\','')" {
      (Get-SkillFile $file) -match $path
    }
  }

  # ADR 0018's actual claim, and the only one a path rewrite can satisfy
  # accidentally: Decisions are a *peer* of Context, so the tree domain-modeling
  # draws has to show them at the same depth. Matched structurally — a
  # `decisions/` at the top level of the fence, with no `docs/` above it —
  # because the prose around it could say "peer" while the diagram says
  # otherwise, and the diagram is what a reader copies.
  Assert "domain-modeling's tree puts decisions/ beside contexts/, not below docs/" {
    $c = Get-SkillFile 'domain-modeling/SKILL.md'
    $fence = [regex]::Match($c, '(?ms)^```\r?\n\.claude/\r?\n(.*?)^```')
    if (-not $fence.Success) { throw 'the .claude/ tree is gone' }
    $tree = $fence.Groups[1].Value
    if ($tree -match '(?m)^[^\r\n]*\bdocs/') { throw 'the docs level is still in the tree' }
    # A top-level entry is one whose box-drawing prefix is the first thing on
    # the line; a nested one is indented behind its parent's `│` or spaces.
    if ($tree -notmatch '(?m)^[├└]──\s*decisions/') { throw 'decisions/ is not at the top level' }
    if ($tree -notmatch '(?m)^[├└]──\s*contexts/') { throw 'contexts/ is not at the top level' }
    $true
  }

  # The ignore pattern has to be anchored, and this is not cosmetic: a bare
  # `prototypes/` matches at every depth, so it swallows `evidence/prototypes/`
  # — the write-ups, which are kept. ADR 0018 says moving the write-up resolves
  # the collision "as a side effect"; against git's matching rules it does not,
  # and the anchor is what actually resolves it. Verified against git rather
  # than reasoned about: the two directories differ only in depth, which is
  # exactly what an unanchored pattern ignores.
  Assert "the shipped .gitignore anchors /prototypes/ so evidence write-ups survive" {
    $block = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n(.*?)^```')
    if (-not $block.Success) { throw 'the .gitignore block is gone' }
    $entries = $block.Groups[1].Value -split '\r?\n' | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' }
    if ($entries -notcontains '/prototypes/') {
      throw "unanchored — would also ignore evidence/prototypes/: $($entries -join ', ')"
    }
    $true
  }

  # The consequence ADR 0018 names: throwaway prototype code and the write-up
  # stop being one word apart at the same depth with opposite gitignore status.
  # Both halves — asserting only the move leaves the code silently relocated.
  Assert "prototype code stays at .claude/prototypes/ while the write-up moves under evidence/" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    if ($c -notmatch '\.claude/prototypes/') { throw 'the throwaway-code location is gone' }
    if ($c -notmatch '\.claude/evidence/prototypes/') { throw 'the write-up did not move' }
    $true
  }

  # `evidence/` earns its existence by grouping things that share a property —
  # nothing revalidates them. A Knowledge Layer filed under it would make it
  # the `docs/` this ticket just deleted, wearing a better name.
  Assert "no Knowledge Layer is filed under evidence/" {
    $bad = Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match '\.claude/evidence/(decisions|designs|contexts)/' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) }
    if ($bad) { throw "a knowledge layer is under evidence/ in: $($bad -join ', ')" }
    $true
  }

  # --- the migration --------------------------------------------------------

  # "The shipped migration branch converts an existing Tenure repository's
  # layout." Each old location needs a row naming where it goes — the same
  # shape the mattpocock rows use, which is what ticket tenure/08's sweep over
  # the exempt files reads.
  # Keys are the *superseded* paths — this is the one table in the file that
  # has to keep naming them, because it asserts they are converted rather than
  # merely absent.
  $layoutRows = [ordered]@{
    '\.claude/docs/decisions/'    = '\.claude/decisions/'
    '\.claude/docs/designs/'      = '\.claude/designs/'
    '\.claude/docs/research/'     = '\.claude/evidence/research/'
    '\.claude/docs/prototypes/'   = '\.claude/evidence/prototypes/'
    '\.claude/docs/out-of-scope/' = '\.claude/evidence/out-of-scope/'
  }
  foreach ($from in $layoutRows.Keys) {
    $to = $layoutRows[$from]
    Assert "the migration carries $($from -replace '\\','') across, and names where it goes" {
      $mig = Get-SkillFile 'configure/MIGRATION.md'
      if ($mig -notmatch "(?m)^\|[^\r\n]*$from[^\r\n]*\|[^\r\n]*$to") {
        throw 'no row, or the row does not name the destination'
      }
      $true
    }
  }

  # "Preserving each decision record's number and slug." Asserted where the
  # rule lives, not where this ticket happened to need it — ADR-FORMAT.md owns
  # ADR numbering, and the single-home check in ticket tenure/02 is what stops
  # MIGRATION.md growing a second copy.
  #
  # The reason is what makes it a rule rather than a preference: inbound
  # references resolve by number, so renumbering breaks all of them at once.
  # Without it stated, the next person to see a gap in the sequence closes it.
  Assert "ADR-FORMAT preserves numbers and slugs across a move, and says why" {
    $adr = Get-SkillFile 'domain-modeling/ADR-FORMAT.md'
    if ($adr -notmatch $rulePattern['ADR numbers survive a move']) {
      throw 'the preservation rule is not stated'
    }
    if ($adr -notmatch '(?is)(referenc|resolve)[^.]{0,200}number') {
      throw 'stated without the reason inbound references depend on'
    }
    # It has to cover *this* move, not only a migration in from someone else's
    # layout — which is all it said before layout/01, and would have read as
    # not applying to Tenure's own change.
    if ($adr -notmatch '(?is)whenever|(in from another layout, or|as well as)') {
      throw 'scoped to migrations in from elsewhere, so it misses this one'
    }
    $true
  }

  # And MIGRATION.md reaches that rule rather than restating it. A pointer is
  # what keeps the rule in one place; the assertion is here because this is the
  # ticket that introduced the second site.
  Assert "the layout migration points at the numbering rule instead of restating it" {
    $mig = Get-SkillFile 'configure/MIGRATION.md'
    $mig -match '(?i)ADR-FORMAT\.md'
  }

  # The layout migration's risk is the opposite of the mattpocock migration's:
  # not a wrong classification, but a reference left pointing at a directory
  # that is gone. A page that converts files and never repairs what named them
  # leaves the repository half-migrated and passing.
  Assert "the migration repairs what pointed at the old locations" {
    $mig = Get-SkillFile 'configure/MIGRATION.md'
    $mig -match '(?is)(Source Pointer|referenc)[^.]{0,300}(broken|update|repair)'
  }

  # /configure has to *find* a repository on the old layout, or the branch it
  # gained is unreachable. Scoped to the detect step for ticket tenure/08's
  # reason: MIGRATION.md names the path too, as something it converts, so a
  # file-wide search passes while nothing ever looks for it.
  Assert "detection finds a Tenure repository still on the superseded layout" {
    $s = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Detect'
    $s -match '\.claude/docs/'
  }

  # --- still lazy -----------------------------------------------------------

  # "/configure still pre-creates none of these directories." The rewrite ran
  # through the sentence that says so, and a rewrite is exactly how a rule gets
  # dropped while its neighbours survive. Both halves: the new paths, and the
  # laziness that still governs them.
  Assert "the new directories are still created lazily, never pre-created" {
    $s = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Generate'
    $named = @('\.claude/decisions/', '\.claude/designs/', 'evidence/')
    $missing = $named | Where-Object { $s -notmatch $_ }
    if ($missing) { throw "not covered by the lazy rule: $($missing -join ', ')" }
    if ($s -notmatch '(?i)created lazily') { throw 'the laziness rule is gone' }
    if ($s -notmatch '(?i)does not pre-create') { throw 'nothing forbids pre-creating them' }
    $true
  }
}

# --- ticket layout/02 — adopt the layout here --------------------------------

# A section whose *subject* is `.claude/` rather than `./skills`, and it has to
# be: this ticket moved this repository's own tree. Corroborating reads of
# `.claude/` are ordinary and several sections make them — `tenure/20` checks a
# rule is written down here and that a rename left no trace — but reading it as
# the thing under test is what `skills/` is what ships, `.claude/` is what this
# repository runs on holds apart, so it is marked where it happens rather than
# left to be inferred. `$subjectSections` is where they are enumerated.
Describe-Ticket 'layout/02' 'move this repository onto the dissolved layout' {

  function Get-RepoFile {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  Assert "decisions sit beside Context, and the docs level is gone" {
    if (-not (Test-Path (Join-Path $repo '.claude/decisions'))) { throw '.claude/decisions/ does not exist' }
    if (Test-Path (Join-Path $repo '.claude/docs')) { throw '.claude/docs/ is still here' }
    $true
  }

  # "Every number and slug unchanged." Numbers are what inbound references
  # resolve by, so a gap or a duplicate is what breaking them looks like —
  # checked as a sequence rather than a count, because losing 0007 and gaining
  # 0021 keeps the count identical.
  Assert "every ADR number survives the move, contiguous and unique" {
    $adrs = Get-ChildItem (Join-Path $repo '.claude/decisions') -Filter '*.md' | Sort-Object Name
    if ($adrs.Count -eq 0) { throw 'no decision records at the new location' }
    $numbers = $adrs | ForEach-Object {
      if ($_.Name -notmatch '^(\d{4})-.+\.md$') { throw "not numbered-and-slugged: $($_.Name)" }
      [int]$Matches[1]
    }
    $dupes = $numbers | Group-Object | Where-Object Count -gt 1
    if ($dupes) { throw "duplicated: $(($dupes.Name) -join ', ')" }
    $expected = 1..$adrs.Count
    $gaps = Compare-Object $expected $numbers | Where-Object SideIndicator -eq '<='
    if ($gaps) { throw "missing: $(($gaps.InputObject | ForEach-Object { '{0:d4}' -f $_ }) -join ', ')" }
    $true
  }

  # Scoped to the files that *navigate*. Three kinds of file are deliberately
  # excluded and each for its own reason: an accepted ADR is frozen (0018
  # records the supersession rather than editing 0006), `.claude/rules/` states
  # the legacy-path rule and has to name what it rejects, and the tickets are
  # the build record — rewriting a resolved ticket makes it describe a decision
  # nobody made. The ticket's criterion allows exactly this: "except where it
  # is deliberately recording the migration."
  $navigational = @('CLAUDE.md', 'README.md', '.claude/context.md', '.claude/contexts/skill-authoring.md')
  foreach ($file in $navigational) {
    Assert "$file names no pre-change path" {
      $c = Get-RepoFile $file
      if ($c -match '\.claude/docs/') { throw 'still points into the dissolved docs level' }
      $true
    }
  }

  # A pointer is verified before use, always — so the ones Context ships with
  # are verified here rather than at the moment something trips over them.
  Assert "every Source Pointer in Context and the Domain Contexts resolves" {
    $files = @(Join-Path $repo '.claude/context.md') +
             (Get-ChildItem (Join-Path $repo '.claude/contexts') -Recurse -Filter '*.md' | ForEach-Object FullName)
    $broken = @()
    foreach ($f in $files) {
      foreach ($m in [regex]::Matches((Get-Content $f -Raw), '`(\.claude/[^`\r\n]+|skills/[^`\r\n]*)`')) {
        $target = $m.Groups[1].Value.TrimEnd('*')
        if (-not (Test-Path (Join-Path $repo $target))) {
          $broken += "$(Split-Path -Leaf $f) → $($m.Groups[1].Value)"
        }
      }
    }
    if ($broken) { throw ($broken -join '; ') }
    $true
  }

  # Every Domain Context has exactly one row, and every row a file. The audit
  # branch of /configure owns this for a configured repository; here it is the
  # one thing that catches a context file nothing loads.
  Assert "the routing table and contexts/ agree, one row per file" {
    $table = Get-RepoFile '.claude/context.md'
    $files = Get-ChildItem (Join-Path $repo '.claude/contexts') -Recurse -Filter '*.md' |
      ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_.Name) }
    $missing = $files | Where-Object { $table -notmatch "\[$([regex]::Escape($_))\]" }
    if ($missing) { throw "no routing-table row for: $($missing -join ', ')" }
    $true
  }

  # Two guarantees, and they need two assertions anchored to two sites. Written
  # as one, it passed with the banner deleted — the decision-1 annotation
  # carried both "0018" and the wording, so the check matched text travelling
  # with a different claim than the one it existed to make. That is the failure
  # `.claude/rules/skills.md` warns about, caught here by deliberate deletion.

  # A reader arriving at the top must learn the whole document predates 0018.
  # Scoped to the preamble — everything before the first `##` — because that is
  # the only region a reader is guaranteed to cross.
  Assert "the closed effort's spec warns up front that its paths predate ADR 0018" {
    $spec = Get-RepoFile '.claude/tickets/tenure/spec.md'
    $preamble = ($spec -split '(?m)^##\s', 2)[0]
    if ($preamble -notmatch '0018') { throw 'the preamble never names the ADR that superseded the layout' }
    if ($preamble -notmatch '(?is)(predate|after this effort closed|built and closed)') {
      throw 'the preamble names 0018 without saying the spec came first'
    }
    $true
  }

  # And the one decision that still spells a superseded path says so on its own
  # line, for the reader who arrives by search rather than from the top.
  Assert "the decision naming a superseded path is annotated in place" {
    $spec = Get-RepoFile '.claude/tickets/tenure/spec.md'
    $line = ($spec -split '\r?\n') | Where-Object { $_ -match '\*\*Paths\*\*' }
    if (-not $line) { throw 'the paths decision is gone from the spec' }
    if ($line -notmatch '\.claude/docs/decisions/') { throw 'the decision was rewritten rather than annotated' }
    if ($line -notmatch '0018') { throw 'the superseded path is stated with nothing marking it superseded' }
    $true
  }
}

# --- ticket layout/03 — derive tool references per repository -----------------

# Sections keyed by heading. A tool file's entries *are* its `## ` sections —
# ticket tenure/15 already treats them that way — so the heading is the entry's
# identity, and that is what makes derivation checkable without markers in the
# committed file.
function Get-ToolSections {
  param([string]$Content)
  $sections = [ordered]@{}
  $heading = $null
  $body = [Collections.Generic.List[string]]::new()
  foreach ($line in ($Content -split '\r?\n')) {
    if ($line -match '^##\s+(.+?)\s*$') {
      if ($heading) { $sections[$heading] = ($body -join "`n").Trim() }
      $heading = $Matches[1]
      $body.Clear()
    } elseif ($heading) {
      $body.Add($line)
    }
  }
  if ($heading) { $sections[$heading] = ($body -join "`n").Trim() }
  $sections
}

# The whole mechanism. A derived entry either matches its source exactly or it
# does not exist — those are the only two passing states, and "roughly the same
# but shorter" is the failure this returns.
#
# Interior whitespace is deliberately NOT normalised. A summarized entry is
# most often a reflowed one, and normalising away the reflow is normalising
# away the evidence.
function Get-DivergentEntries {
  param([string]$Derived, [string]$Source)
  $d = Get-ToolSections $Derived
  $s = Get-ToolSections $Source
  @($d.Keys | Where-Object { $s.Contains($_) -and $d[$_] -ne $s[$_] })
}

Describe-Ticket 'layout/03' 'derive tool references per repository, and delete the tools skill' {

  $toolSources = @('git', 'github', 'gitlab', 'graphite')

  # --- the skill is gone, the source material is not ------------------------

  Assert "the model-invoked tools skill is absent" {
    if (Test-Path (Join-Path $skills 'tools')) { throw 'skills/tools/ still exists' }
    $true
  }

  Assert "the reference survives as /configure's source material" {
    $missing = $toolSources | Where-Object { -not (Test-Path (Join-Path $skills "configure/tools/$_.md")) }
    if ($missing) { throw "lost in the move: $($missing -join ', ')" }
    $true
  }

  # Criterion 4. The point of the change is one place to look, and a shipped
  # skill still naming the plugin's own copy is a second place. Scoped to a
  # path *outside* `.claude/tools/` — naming `.claude/tools/git.md` is the
  # correct new form and must not trip this.
  Assert "no shipped skill points at a tool file outside .claude/tools/" {
    $bad = Get-SkillFiles |
      Where-Object { ($_.FullName -replace '\\', '/') -notmatch '/configure/tools/' } |
      Select-String -Pattern '(?<!\.claude/)(?<![\w/])tools/(git|github|gitlab|graphite|SKILL)\.md' |
      ForEach-Object { "$(Split-Path -Leaf $_.Path):$($_.LineNumber)" }
    if ($bad) { throw ($bad -join ', ') }
    $true
  }

  # --- what /configure is told to do ----------------------------------------

  # Criterion 1, and the half that is easy to lose: writing a file only for a
  # detected tool. `gt` is the case that matters — it is the one where being
  # installed and being in use come apart, and a stacking reference in a
  # non-stacking repository reads as permission to start stacking.
  Assert "TOOLS.md ties each tool file to detecting that tool, gt included" {
    $c = Get-SkillFile 'configure/TOOLS.md'
    foreach ($t in @('git', 'gh', 'glab', 'gt')) {
      if ($c -notmatch "``$t``") { throw "no detection condition for $t" }
    }
    if ($c -notmatch '(?is)initialised here|initialized here|`gt init` having been run') {
      throw 'gt is detected by presence on the machine rather than in the repository'
    }
    $true
  }

  Assert "TOOLS.md states that derivation filters whole entries and never summarizes" {
    $c = Get-SkillFile 'configure/TOOLS.md'
    if ($c -notmatch '(?i)never summarize') { throw 'the rule is not stated' }
    # The reason, not just the rule: filtering is visible and summarizing is
    # not, which is the whole argument for preferring one failure to the other.
    if ($c -notmatch '(?is)filtering[^.]{0,120}visible') { throw 'stated without why it is the safer failure' }
    $true
  }

  Assert "TOOLS.md defines the provenance line the check depends on" {
    $c = Get-SkillFile 'configure/TOOLS.md'
    if ($c -notmatch '(?m)^Derived from:') { throw 'no `Derived from:` line is specified' }
    if ($c -notmatch '(?is)heading[^.]{0,160}(exactly|identity)') { throw 'headings are not pinned as the entry identity' }
    $true
  }

  # Criterion 6. Naming /configure is what makes the report actionable — "there
  # is no entry" without it is a dead end, and a dead end is where guessing
  # starts.
  Assert "a missing entry is a configuration gap naming /configure, never a guess" {
    $c = Get-SkillFile 'configure/TOOLS.md'
    if ($c -notmatch '(?i)configuration gap') { throw 'the gap is not named as such' }
    if ($c -notmatch '/configure') { throw 'nothing says what fills it' }
    if ($c -notmatch '(?i)not licence to guess|never a guess|never guess') { throw 'guessing is not ruled out' }
    $true
  }

  # Criterion 3 — unchanged by this ticket, which is exactly why it is checked:
  # the sentence carrying it was rewritten, and a rewrite is how a rule gets
  # dropped while its neighbours survive.
  Assert "the single-file test command is still the one entry that must not be missing" {
    $s = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Generate'
    $s -match '(?is)single-file test command[^.]{0,120}(must not be missing|not be missing)'
  }

  # Criterion 5. The gap this whole ticket exists to close: the always-on file
  # used to admit that the workflow's reference existed only with the plugin,
  # in the same breath as forbidding a guessed CLI.
  Assert "the always-on template no longer conditions the tool reference on the plugin" {
    $c = Get-SkillFile $claudeTemplate
    if ($c -match '(?i)Where Tenure is installed, its ``?tools/') {
      throw 'the plugin-conditional wording survives'
    }
    if ($c -notmatch '(?i)with or without the plugin') { throw 'nothing says the rule is followable either way' }
    $true
  }

  # --- criterion 7: the check is mechanical, and proven so ------------------

  # A comparison that runs over zero files is trusted, not checked — and until
  # ticket layout/04 derives this repository's own files there are zero. So the
  # function is exercised against a fixture here, which is what makes the
  # criterion true in the ticket that states it rather than the one after.
  Assert "the entry comparison passes a filtered derivation and fails a summarized one" {
    $source = @"
# git

## Read uncommitted drift

``````
git status --porcelain --untracked-files=all
``````

Each line is ``XY<space><path>``: status in columns 1-2, path from column 4.
Split on the first space and you mis-read `` M`` as a one-character status.

## Bisect to the first bad commit

``````
git bisect start <bad> <good>
``````
"@
    # Filtering: the bisect entry is dropped whole, the kept entry is intact.
    $filtered = @"
# git
Derived from: tenure/git.md

## Read uncommitted drift

``````
git status --porcelain --untracked-files=all
``````

Each line is ``XY<space><path>``: status in columns 1-2, path from column 4.
Split on the first space and you mis-read `` M`` as a one-character status.
"@
    if ((Get-DivergentEntries $filtered $source).Count -ne 0) {
      throw 'a correctly filtered derivation was reported as divergent'
    }

    # Summarizing: the entry is kept, and the column-layout gotcha is gone.
    # This is the exact failure ADR 0019 says filtering is preferred for.
    $summarized = @"
# git
Derived from: tenure/git.md

## Read uncommitted drift

``````
git status --porcelain --untracked-files=all
``````

Parse the status columns carefully.
"@
    $divergent = Get-DivergentEntries $summarized $source
    if ($divergent -notcontains 'Read uncommitted drift') {
      throw 'a summarized entry was not detected'
    }
    $true
  }

  # And it runs over the real thing. Zero derived files today; four once
  # layout/04 lands, at which point this starts asserting rather than idling —
  # so the count is reported, because a silent zero is how this would rot.
  Assert "every derived tool file in this repository matches its source" {
    $dir = Join-Path $repo '.claude/tools'
    if (-not (Test-Path $dir)) { return $true }
    $problems = @()
    foreach ($f in (Get-ChildItem $dir -Filter '*.md')) {
      $c = Get-Content $f.FullName -Raw
      if ($c -notmatch '(?m)^Derived from:\s*tenure/(\S+\.md)\s*$') { continue }
      $srcName = $Matches[1]
      $srcPath = Join-Path $skills "configure/tools/$srcName"
      if (-not (Test-Path $srcPath)) { $problems += "$($f.Name) names a source that does not exist: $srcName"; continue }
      $divergent = Get-DivergentEntries $c (Get-Content $srcPath -Raw)
      if ($divergent) { $problems += "$($f.Name) diverges from $srcName in: $($divergent -join '; ')" }
    }
    if ($problems) { throw ($problems -join ' | ') }
    $true
  }
}

# --- ticket layout/04 — derive this repository's own tool references ---------

# A section whose subject is `.claude/` rather than `./skills`, for the reason
# `layout/02` gives: this ticket's deliverable *is* this repository's own tree.
# See that section's comment for why the crossing is marked rather than assumed.
Describe-Ticket 'layout/04' "derive this repository's own tool references" {

  $toolDir = Join-Path $repo '.claude/tools'

  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  # --- detection is read off the repository, never off a list ----------------

  # A hardcoded expectation would keep passing after the repository stopped
  # matching it. Each row reads the same fact TOOLS.md keys the tool on, so
  # adding a GitLab remote or running `gt init` here turns this red instead of
  # leaving a reference that describes somebody else's repository.
  Assert "a file exists for each tool this repository is detected to use, and none for the rest" {
    $config = Get-RepoText '.git/config'
    $expected = [ordered]@{
      'git.md'      = $true
      'github.md'   = [bool]($config -match '(?im)^\s*url\s*=.*github\.com')
      'gitlab.md'   = [bool]($config -match '(?im)^\s*url\s*=.*gitlab\.com')
      'graphite.md' = Test-Path (Join-Path $repo '.git/.graphite_repo_config')
    }
    $wrong = @()
    foreach ($name in $expected.Keys) {
      $present = Test-Path (Join-Path $toolDir $name)
      if ($expected[$name] -and -not $present) { $wrong += "$name — detected, but no file" }
      if (-not $expected[$name] -and $present)  { $wrong += "$name — a file, but not detected" }
    }
    if ($wrong) { throw ($wrong -join '; ') }
    $true
  }

  # --- what keeps the byte-identity check alive ------------------------------

  # `layout/03`'s comparison skips any file without a `Derived from:` line, so
  # losing the line silently exempts that file from the only check that catches
  # a summarized entry. One assertion per file, because an aggregate one passes
  # while a single file drops out.
  foreach ($derived in @('git.md', 'github.md')) {
    Assert "$derived names the shipped entry it was derived from" {
      $c = Get-RepoText ".claude/tools/$derived"
      if ($c -notmatch "(?m)^Derived from:\s*tenure/$([regex]::Escape($derived))\s*$") {
        throw 'no provenance line — the divergence check skips this file'
      }
      $true
    }
  }

  # "The entries this repository already had for its own tooling survive
  # unchanged." Named one by one: a count survives one being replaced by
  # another. Neither may claim a shipped source, because nothing upstream
  # describes this repository's verifier or its own plugin distribution.
  foreach ($own in @('verify.md', 'plugin.md')) {
    Assert "$own is still here, and still this repository's own" {
      $c = Get-RepoText ".claude/tools/$own"
      if ($c -match '(?m)^Derived from:') { throw 'claims a shipped source it cannot have' }
      $true
    }
  }

  # --- every pointer into the directory resolves -----------------------------

  # Scoped to the files that navigate. The tickets are excluded for the reason
  # `layout/02` gives — they are the build record, and one of them names a tool
  # file that was correct when it was written.
  Assert "every tools/ pointer in this repository's knowledge resolves" {
    $files = @('CLAUDE.md', 'README.md') +
             (Get-ChildItem (Join-Path $repo '.claude') -Filter '*.md' |
               ForEach-Object { ".claude/$($_.Name)" })
    $broken = @()
    foreach ($f in $files) {
      foreach ($m in [regex]::Matches((Get-RepoText $f), '(?<![\w/])(?:\.claude/)?tools/([a-z0-9.-]+\.md)')) {
        if (-not (Test-Path (Join-Path $toolDir $m.Groups[1].Value))) { $broken += "$f → $($m.Value)" }
      }
    }
    if ($broken) { throw ($broken -join '; ') }
    $true
  }

  # Carrying an entry byte-for-byte means carrying its cross-references, and
  # git.md's never-push entry links graphite.md — which a repository with no
  # stack has no reason to derive. The link is kept and the file says so above
  # its first entry, rather than the entry being edited: editing inside a kept
  # entry is the one thing the derivation rule forbids. Asserted so the
  # exemption stays singular instead of becoming the general case.
  Assert "graphite.md is the only unresolvable sibling link, and the file carrying it says so" {
    $dangling = @()
    foreach ($f in (Get-ChildItem $toolDir -Filter '*.md')) {
      foreach ($m in [regex]::Matches((Get-Content $f.FullName -Raw), '\]\((?!https?:|#)([a-z0-9.-]+\.md)\)')) {
        if (-not (Test-Path (Join-Path $toolDir $m.Groups[1].Value))) {
          $dangling += "$($f.Name) → $($m.Groups[1].Value)"
        }
      }
    }
    $unexpected = @($dangling | Where-Object { $_ -ne 'git.md → graphite.md' })
    if ($unexpected) { throw "undocumented dangling link: $($unexpected -join '; ')" }
    if ($dangling -contains 'git.md → graphite.md') {
      $preamble = ((Get-RepoText '.claude/tools/git.md') -split '(?m)^##\s')[0]
      if ($preamble -notmatch '(?i)graphite') { throw 'git.md links graphite.md without saying so above its first entry' }
    }
    $true
  }

  # --- what ticket layout/03 left for this one -------------------------------

  # Two assertions, not one with two clauses: deleting the stale sentence and
  # stating the replacement are separate failures, and a single assertion that
  # covers both reports whichever it hits first.
  Assert "CLAUDE.md no longer routes the workflow's tools through the plugin" {
    $c = Get-RepoText 'CLAUDE.md'
    if ($c -match '(?i)where Tenure is installed') { throw 'still conditions the tool reference on the plugin' }
    $true
  }

  Assert "CLAUDE.md states that one committed directory covers every tool" {
    $c = Get-RepoText 'CLAUDE.md'
    if ($c -notmatch '(?i)covers every tool this repository uses') { throw 'the replacement claim is not stated' }
    $true
  }

  # verify.md described a CLI that `layout/01` replaced — bare two-digit ids.
  # A tool reference naming a form the tool rejects is worse than no entry.
  #
  # Scoped to the fenced blocks, which is what gets copied. Rejected forms are
  # named in the prose deliberately — `-Ticket 09` is the whole point of the
  # entry — so a guard over the whole file fails on the counterexample it
  # asked for and pushes the next author to delete the teaching.
  Assert "every runnable -Ticket example in verify.md uses the form the script accepts" {
    $c = Get-RepoText '.claude/tools/verify.md'
    foreach ($f in [regex]::Matches($c, '(?ms)^```\r?\n(.*?)^```')) {
      if ($f.Groups[1].Value -match '-Ticket\s+(?!\w+/)') { throw "a copy-pasteable example omits the effort: $($f.Groups[1].Value.Trim())" }
    }
    if ($c -notmatch '-Ticket\s+tenure/09') { throw 'no worked example in <effort>/NN form' }
    $true
  }

  # `$subjectSections` names the sections whose subject is `.claude/`, and
  # verify.md tells a reader which those are. Checked in both directions: the
  # forward one keeps the marking present, the reverse one is what makes the
  # exception fail the build when it widens.
  #
  # A marker is a column-0 comment block directly above `Describe-Ticket` that
  # names both `subject` and `.claude/`. Indented comments inside a block are
  # not markers, which is what keeps the several sections discussing subjects
  # for other reasons out of this.
  Assert "every section marked as reading .claude/ by subject is declared, and vice versa" {
    $script = Get-RepoText 'scripts/verify.ps1'
    $marked = @()
    foreach ($m in [regex]::Matches($script, "(?m)((?:^#[^\r\n]*\r?\n)+)Describe-Ticket '([^']+)'")) {
      if ($m.Groups[1].Value -match '(?i)subject' -and $m.Groups[1].Value -match '\.claude/') {
        $marked += $m.Groups[2].Value
      }
    }
    $undeclared = @($marked | Where-Object { $_ -notin $subjectSections })
    if ($undeclared) { throw "marked but not in `$subjectSections: $($undeclared -join ', ')" }
    $unmarked = @($subjectSections | Where-Object { $_ -notin $marked })
    if ($unmarked) { throw "declared but not marked at its own section: $($unmarked -join ', ')" }
    $true
  }

  Assert "verify.md names every section that reads .claude/ by subject" {
    $doc = Get-RepoText '.claude/tools/verify.md'
    $missing = @($subjectSections | Where-Object { $doc -notmatch [regex]::Escape($_) })
    if ($missing) { throw "verify.md does not name: $($missing -join ', ')" }
    $true
  }
}

# --- ticket layout/05 — give version control its own policy file -------------

Describe-Ticket 'layout/05' 'give version control its own policy file' {

  $vcTemplate = 'configure/version-control.template.md'
  $trackerTemplate = 'configure/tracker.template.md'

  Assert "the policy file ships as a template /configure installs" {
    if (-not (Test-Path (Join-Path $skills $vcTemplate))) { throw "skills/$vcTemplate is missing" }
    $true
  }

  # Criterion 1, one assertion per section. A single assertion demanding all
  # four reports whichever it reaches first and goes green again the moment
  # that one is restored, which is how a template loses a section quietly.
  foreach ($section in @('Which model', 'Branch naming', 'Commit discipline', 'How work lands')) {
    Assert "the policy template answers: $section" {
      Get-Section (Get-SkillFile $vcTemplate) $section | Out-Null
      $true
    }
  }

  # Criterion 1's fourth item is worded "the never-push rule", and `CLAUDE.md`
  # carries that unconditionally — restating it here would be a second home for
  # a rule that must fire on every turn. What the policy file owns instead is
  # how work lands in *this* repository, which is a fact about the repository
  # and about its humans. Asserted in both directions so the deviation cannot
  # quietly relax back into a copy.
  Assert "the landing section reaches the standing rule rather than restating it" {
    $s = Get-Section (Get-SkillFile $vcTemplate) 'How work lands'
    if ($s -notmatch 'CLAUDE\.md') { throw 'does not reach the standing rule at all' }
    if ($s -match '(?i)cannot undo locally') { throw "restates CLAUDE.md's never-push rule verbatim" }
    $true
  }

  # --- criterion 2: the tracker template gives it up entirely ----------------

  Assert "the tracker template no longer carries branch naming" {
    if ((Get-SkillFile $trackerTemplate) -match '(?im)^##\s+Branch naming') { throw 'the section is still there' }
    $true
  }

  # Checked at both ends. A move that drops the constraint on the way looks
  # exactly like one that never carried it, and only the destination check
  # tells them apart.
  Assert "the ticket-id constraint travelled to the policy template" {
    $s = Get-Section (Get-SkillFile $vcTemplate) 'Branch naming'
    if ($s -notmatch '(?i)ticket id') { throw 'the constraint did not arrive with the convention' }
    $true
  }

  Assert "the tracker template states no version-control policy at all" {
    $c = Get-SkillFile $trackerTemplate
    $subjects = [ordered]@{
      'the branch/ticket-id constraint' = '(?i)encode the ticket id'
      'which model applies'             = '(?i)plain git|stacked changes'
      'how work lands'                  = '(?i)never push'
    }
    $held = @($subjects.Keys | Where-Object { $c -match $subjects[$_] })
    if ($held) { throw "still states: $($held -join ', ')" }
    $true
  }

  # --- criterion 3: the always-on file names both ----------------------------

  # The 200-line budget is asserted in tenure/02 against the same template, so
  # this is only the naming half. Per file, because one pointer landing and the
  # other not is the likely half-failure.
  foreach ($policy in @('.claude/tracker.md', '.claude/version-control.md')) {
    Assert "the always-on template names $policy" {
      if ((Get-SkillFile $claudeTemplate) -notmatch [regex]::Escape($policy)) { throw 'not named' }
      $true
    }
  }

  # --- criteria 4 and 5: read the statement, verify it, heal it --------------

  # Anchored to the subsection that owns the question. `Get-Section` handles
  # `## ` only, and widening this to the whole of step 1 would let the branch
  # convention's own mention of the same file satisfy it.
  Assert "/implement reads the stated model rather than discovering it" {
    $m = [regex]::Match((Get-SkillFile 'implement/SKILL.md'), '(?ms)^###[^\r\n]*blocked means stacked.*?(?=^#{1,3}\s|\z)')
    if (-not $m.Success) { throw 'the stacking subsection is gone' }
    if ($m.Value -notmatch 'version-control\.md') { throw 'does not reach the file that states the model' }
    $true
  }

  # The probe is gone as the *source* of the answer, which means /implement must
  # not carry the invocation either — a skill that still runs it will run it,
  # whatever the prose above says.
  #
  # Deliberately not a $rulePattern entry: the check appears in the policy
  # template and in the Graphite tool reference, and those are two audiences
  # rather than two homes — one says what this repository is, the other says
  # how to drive a CLI. A duplication guard on the subject would fail on a
  # correct tree.
  Assert "no build-time probe survives inside /implement" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -match '(?i)graphite_repo_config|gt log') { throw 'still carries the probe invocation' }
    $true
  }

  # The whole point of the chosen placement: the check travels with the claim,
  # so it is followable in a repository with no plugin installed.
  Assert "the policy template carries the check for its own claim" {
    $s = Get-Section (Get-SkillFile $vcTemplate) 'Which model'
    if ($s -notmatch '\.graphite_repo_config') { throw 'states the model with no way to confirm it' }
    $true
  }

  Assert "a stale model is healed where it is found, and the read wins" {
    $s = Get-Section (Get-SkillFile $vcTemplate) 'Which model'
    if ($s -notmatch '(?i)the read is\s*\**\s*right') { throw 'does not say which side wins' }
    if ($s -notmatch '(?i)correct this file') { throw 'does not say to repair it here' }
    $true
  }

  # The trap the previous design fell into: a probe that shells out to the
  # stacking tool makes its own answer true. Stated where the check is given,
  # or the next reader reaches for the obvious command.
  Assert "the check warns against asking the stacking tool" {
    $s = Get-Section (Get-SkillFile $vcTemplate) 'Which model'
    if ($s -notmatch '(?i)initialise|initialize') { throw 'does not say why the tool is not the probe' }
    $true
  }
}

# --- ticket layout/06 — state this repository's version-control policy -------

# A section whose subject is `.claude/` rather than `./skills`, for the reason
# `layout/02` gives: this ticket's deliverable *is* this repository's own tree.
Describe-Ticket 'layout/06' "state this repository's version-control policy" {

  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  Assert "this repository has its own version-control policy file" {
    Get-RepoText '.claude/version-control.md' | Out-Null
    $true
  }

  # One per section, for the reason `layout/05` gives about the template: a
  # single assertion demanding all four goes green the moment the first one it
  # reaches is restored.
  foreach ($section in @('Which model', 'Branch naming', 'Commit discipline', 'How work lands')) {
    Assert "the policy file answers: $section" {
      Get-Section (Get-RepoText '.claude/version-control.md') $section | Out-Null
      $true
    }
  }

  # The statement is only worth having while it is true, and this is the same
  # read the file itself prescribes. A repository that adopted a stacking tool
  # and did not heal the file fails here rather than misleading the next run.
  Assert "the stated model still matches the repository" {
    $stated = Get-Section (Get-RepoText '.claude/version-control.md') 'Which model'
    $stacked = Test-Path (Join-Path $repo '.git/.graphite_repo_config')
    if ($stacked -and $stated -notmatch '(?im)^\*\*Stacked changes\.\*\*') { throw 'a stack is initialised here and the file says otherwise' }
    if (-not $stacked -and $stated -notmatch '(?im)^\*\*Plain git\.\*\*') { throw 'no stack is initialised here and the file does not say plain git' }
    $true
  }

  # Criterion 1's fourth item, resolved the way `layout/05` resolved it in the
  # template: pointed at, never restated, because `CLAUDE.md` must carry it
  # unconditionally. Both directions, so it cannot relax into a copy.
  Assert "the landing section reaches the standing rule rather than restating it" {
    $s = Get-Section (Get-RepoText '.claude/version-control.md') 'How work lands'
    if ($s -notmatch 'CLAUDE\.md') { throw 'does not reach the standing rule at all' }
    if ($s -match '(?i)cannot undo locally') { throw "restates CLAUDE.md's never-push rule verbatim" }
    $true
  }

  Assert "the branch convention is stated with an example a reader can copy" {
    $s = Get-Section (Get-RepoText '.claude/version-control.md') 'Branch naming'
    if ($s -notmatch '(?i)ticket') { throw 'does not tie the name to the ticket' }
    if ($s -notmatch '(?m)^\d{2}-[a-z0-9-]+$|\s\d{2}-[a-z0-9-]+') { throw 'no worked example of the form' }
    $true
  }

  Assert "the tracker configuration carries no branch naming" {
    if ((Get-RepoText '.claude/tracker.md') -match '(?im)^##\s+Branch naming') { throw 'the section is here' }
    $true
  }

  # --- criteria 3 and 4: the always-on file is a complete starting point -----

  foreach ($policy in @('.claude/tracker.md', '.claude/version-control.md')) {
    Assert "the root always-on file names $policy" {
      if ((Get-RepoText 'CLAUDE.md') -notmatch [regex]::Escape($policy)) { throw 'not named' }
      $true
    }
  }

  Assert "the root always-on file stays an entrypoint, not a manual — under 200 lines" {
    $n = ((Get-RepoText 'CLAUDE.md') -split '\r?\n').Count
    if ($n -ge 200) { throw "$n lines" }
    $true
  }

  # "A reader with no plugin installed can reach every instruction this
  # repository depends on starting from the root always-on file." Every path it
  # names has to exist, or that reader hits a dead end on their first hop.
  #
  # `CONTRIBUTING.md` is named conditionally — "where CONTRIBUTING.md documents
  # a convention" — and this repository has none, so it is excluded by name
  # rather than by a pattern that would also excuse a genuine break.
  Assert "every file the root always-on file points at exists" {
    $conditional = @('CONTRIBUTING.md')
    $broken = @()
    foreach ($m in [regex]::Matches((Get-RepoText 'CLAUDE.md'), '`(\.claude/[^`\r\n]+|[A-Za-z0-9_.-]+\.(?:md|ps1))`')) {
      $target = $m.Groups[1].Value.TrimEnd('*', '/')
      if ($target -in $conditional) { continue }
      if (-not (Test-Path (Join-Path $repo $target))) { $broken += $m.Groups[1].Value }
    }
    if ($broken) { throw "named but absent: $(($broken | Sort-Object -Unique) -join ', ')" }
    $true
  }
}

# --- summary -----------------------------------------------------------------

# A -Ticket that matches nothing must not read as a pass. Silently running zero
# assertions and exiting 0 is the one failure a CI job cannot notice.
if ($Ticket -and $script:Ran.Count -eq 0) {
  Write-Host ""
  Write-Host "no ticket '$Ticket' — nothing ran" -ForegroundColor Red
  # Listed from the ids the run actually declared, so an effort added later
  # cannot be missing from its own error message.
  Write-Host "known tickets: $($script:Known -join ', ')" -ForegroundColor DarkGray
  exit 2
}

Write-Host ""
if ($script:Failures.Count -gt 0) {
  Write-Host "$($script:Failures.Count) failed, $script:Passes passed" -ForegroundColor Red
  Write-Host ""
  $script:Failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
  exit 1
}
Write-Host "$script:Passes passed" -ForegroundColor Green
exit 0
