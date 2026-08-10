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
  # `Assert` catches what its own condition throws. Nothing caught what the rest
  # of a section threw, and a section is where a file is read once and asserted
  # against many times — so a missing file or a renamed heading raised from that
  # hoisted read, outside any condition, ended the entire run: no summary, no
  # failure list, and no word about the assertions that had already passed. On
  # the only guard this repository has against a broken build, one bad file made
  # the other eleven hundred assertions silent rather than failing.
  #
  # Caught here rather than by rewriting those reads into the conditions that
  # use them: reading a file once per section is the right shape, and pushing
  # the read inside every `Assert` would re-read it per assertion to buy nothing.
  try { & $Body }
  catch {
    $script:Failures += "[$Id] section aborted, its remaining assertions did not run — $($_.Exception.Message)"
    Write-Host "  ABORT $($_.Exception.Message)" -ForegroundColor Red
  }
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

# The two files that may name a superseded path, because naming one is the whole
# of their job: `SKILL.md` detects them and `MIGRATION.md` converts them. Hoisted
# to one home by `streamline/08` — it was declared inside the first sweep that
# needed it, so a later sweep silently exempted nothing and reported the two
# files it was supposed to spare.
$legacyExempt = @('configure/SKILL.md', 'configure/MIGRATION.md', 'configure/migration-changelog.md')

# The sweeps iterate `Get-SkillFiles` and read each one. `-Raw` yields $null for
# an empty file, and the regex call that follows then throws a null-reference —
# which reports as an exception rather than as the assertion that failed, so the
# one file that is catastrophically wrong is the one whose failure is unreadable.
function Get-SkillText {
  param([System.IO.FileInfo]$File)
  $c = Get-Content $File.FullName -Raw
  if ($null -eq $c) { '' } else { $c }
}

# Throws rather than returning $null, so an assertion about a file's *content*
# fails loudly when the file is absent instead of passing on an empty string.
function Get-SkillFile {
  param([string]$RelativePath)
  $p = Join-Path $skills $RelativePath
  if (-not (Test-Path $p)) { throw "skills/$RelativePath is missing" }
  # `-Raw` yields $null for an empty file, and every caller then throws a
  # null-reference from inside a regex call — which reports as an exception
  # rather than as the assertion that failed. An empty file is a real failure
  # and should read like one.
  $c = Get-Content $p -Raw
  if ($null -eq $c) { '' } else { $c }
}

# Carriage returns are stripped here, at the one place frontmatter is extracted,
# rather than tolerated pattern by pattern. `$` sits before the `\n` and so
# *after* the `\r`, which means every trailing-whitespace class in every caller
# would need `\r?` and the one that forgot would fail only on a CRLF file. That
# is not hypothetical twice over: a formatter normalised a skill and its mode
# read as absent, and a spec sweep later reported eight files as missing a field
# they declared.
function Get-Frontmatter {
  param([string]$Content)
  if ($Content -match '(?s)\A---\r?\n(.*?)\r?\n---\r?\n') { return ($Matches[1] -replace "`r", '') }
  return $null
}

# Everything the harness injects without a pointer being followed: the root
# `CLAUDE.md`, plus every rule file with no `paths:` key in its frontmatter.
#
# Derived from the frontmatter rather than from a list, because the list is
# the thing that goes wrong — a rule added without `paths:` is a new charge on
# every turn, and a hand-kept set would not notice it. Confirmed empirically
# against Claude Code 2.1.220 via the `InstructionsLoaded` hook: an unscoped
# rule reports `session_start`, a scoped one reports `path_glob_match` only
# when a covered file is read, and reports nothing otherwise.
function Get-RuleFiles {
  $rules = Join-Path $repo '.claude/rules'
  if (-not (Test-Path $rules)) { return @() }
  # Relative to the rules root, not `$_.Name`. Claude Code discovers rules
  # recursively and the reference shows them organised into subdirectories, so
  # a name-only path would silently address the wrong file the first time one
  # is nested — and every assertion built on it would read a file that is not
  # the one it named.
  Get-ChildItem $rules -Recurse -File -Filter *.md | ForEach-Object {
    '.claude/rules/' + ($_.FullName.Substring($rules.Length + 1) -replace '\\', '/')
  }
}

function Get-AlwaysOnFiles {
  $unscoped = @(Get-RuleFiles | Where-Object {
    $fm = Get-Frontmatter (Get-Content (Join-Path $repo $_) -Raw)
    -not ($fm -and $fm -match '(?m)^paths:')
  })
  @('CLAUDE.md') + $unscoped
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

# ADR 0055 puts AEP's fields *inside* the harness's `metadata:` map, and that
# containment is the decision — a `mode:` indented under any other key is not
# declared where the ADR says it is. One reader for the block, because the first
# version of this asked only whether some indented `mode:` existed: renaming
# `metadata:` to `aep:` left every assertion green, which is the guard-that-
# cannot-fire failure `.claude/rules/skills.md` says to assume you have written.
function Get-MetadataBlock {
  param([string]$Content)
  $fm = Get-Frontmatter $Content
  if (-not $fm) { return $null }
  $m = [regex]::Match($fm, '(?ms)^metadata:[ \t]*$(.*?)(?=^\S|\z)')
  if (-not $m.Success) { return $null }
  $m.Groups[1].Value
}

# The guides a skill declares, as bare names — `tickets`, not the path. The
# wildcard `*` is /configure's, which reads the whole directory; a caller that
# cares about the difference tests for it rather than being handed a list that
# quietly means "all of them".
# The configuration stage's migration content spans two shipped files since
# `changelog/01`: `MIGRATION.md` converts a *shape* and fires on detection,
# `migration-changelog.md` catches a repository up on a *release* and fires on a
# version. Earlier tickets asserted their repair was "in MIGRATION.md" because
# that was the only place it could be, and what those criteria wanted was that
# the repair is described — never which file describes it. These span both, so a
# relocation does not falsify a criterion it did not change. Each repair kept its
# original heading for the same reason.
function Get-MigrationText {
  # `Get-Section` matches `##` and not `###`. Each repair sits one level under its
  # release heading in the changelog, so the depth is normalised here rather than
  # by flattening the file — the nesting is what groups repairs by release, and
  # it is the grouping the cursor reads.
  $log = (Get-SkillFile 'configure/migration-changelog.md') -replace '(?m)^###\s', '## '
  (Get-SkillFile 'configure/MIGRATION.md') + "`n`n" + $log
}

# What the audit can reach, which is its own section plus the file it delegates
# the dated repairs to. An assertion that a repair is reachable from the audit is
# still answered here; one that it is *written in the audit list* is not, and that
# is the distinction `changelog/01` drew.
function Get-AuditReach {
  $log = (Get-SkillFile 'configure/migration-changelog.md') -replace '(?m)^###\s', '## '
  (Get-Section (Get-SkillFile 'configure/SKILL.md') '5 — Audit') + "`n`n" + $log
}

function Get-DeclaredPolicies {
  param([string]$Content)
  $block = Get-MetadataBlock $Content
  if ($null -eq $block) { return $null }
  $line = [regex]::Match($block, '(?m)^[ \t]+policies:[ \t]*\[(.*?)\][ \t]*$')
  if (-not $line.Success) { return $null }
  ,@([regex]::Matches($line.Groups[1].Value, '[a-z*-]+') | ForEach-Object { $_.Value })
}

# The posture, read only from inside that map. `$null` when absent, so a caller
# distinguishes "no metadata" from "metadata without a mode" by asking again.
function Get-DeclaredMode {
  param([string]$Content)
  $block = Get-MetadataBlock $Content
  if ($null -eq $block) { return $null }
  $m = [regex]::Matches($block, '(?m)^[ \t]+mode:[ \t]*(\S+)[ \t]*$')
  if ($m.Count -ne 1) { return $null }
  $m[0].Groups[1].Value
}

# `/commit`'s step 3, from its heading to the next. Scoped rather than file-wide
# because `/commit` also sets a *ticket* status, which answers to the build
# lifecycle and not to the spec format. One home because two assertions read this
# step, and a copied matcher is one rewording away from a check that stops
# finding its subject and reports nothing.
function Get-SpecStep {
  $m = [regex]::Match((Get-SkillFile 'commit/SKILL.md'), '(?ims)^#{2,}[^\n]*mark the spec.*?(?=^#{2}\s|\z)')
  if (-not $m.Success) { throw 'marking the spec is not its own step' }
  $m.Value
}

# --- ticket tenure/01 — vendor the primitives ---------------------------------------

Describe-Ticket 'tenure/01' 'vendor the primitives and rewrite their paths' {

  $primitives = @('grilling', 'tdd', 'codebase-design', 'domain-modeling')

  foreach ($p in $primitives) {
    Assert "$p is vendored into ./skills" {
      if (-not (Test-Path (Join-Path $skills "$p/SKILL.md"))) { throw ('nothing at ' + (Join-Path $skills "$p/SKILL.md")) }
      $true
    }
  }

  # The headline criterion: no legacy path survives anywhere under ./skills.
  # `CONTEXT.md` is matched case-sensitively so Tenure's lowercase
  # `.claude/context.md` does not trip it.
  #
  # Two files are exempt, and they have to be: /configure is the skill that
  # *detects and converts* these paths, so it cannot do its job without naming
  # them. Named individually rather than by prefix — `configure/` also holds
  # CLAUDE.template.md and the policy templates, which are installed into the
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
  $legacy = @{
    'CONTEXT\.md'     = 'CONTEXT.md (use .claude/contexts/)'
    'CONTEXT-MAP\.md' = 'CONTEXT-MAP.md (use the routing table)'
    'docs/adr/'       = 'docs/adr/ (use .claude/decisions/)'
    '\.scratch/'      = '.scratch/ (use .claude/tickets/)'
    '\.claude/docs/'  = '.claude/docs/ (ADR 0018 dissolved it — use .claude/{decisions,designs,evidence}/)'
    '\.claude/tenure\.md' = '.claude/tenure.md (streamline/02 renamed it — use .claude/protocol.md)'
    # The two guides that predate the policies directory. Their new paths
    # contain a `/policies/` segment, so neither pattern can match its own
    # replacement and the guard cannot go quietly green on the fix.
    '\.claude/tracker\.md'         = '.claude/tracker.md (streamline/03 — use .claude/policies/tracker.md)'
    '\.claude/version-control\.md' = '.claude/version-control.md (streamline/03 — use .claude/policies/version-control.md)'
  }
  # `.claude/tickets/map.md` deliberately does *not* join this table. Every path
  # here was **retired** — nothing may name it again — and that one was
  # **reassigned**: ADR 0059 gives it to the design index in the same breath as
  # it takes it from the map. A blanket ban would forbid the new tenant from
  # being named anywhere shipped, and the label would offer the wrong
  # replacement to whoever tripped it. The map's own move is guarded where the
  # claim actually is, in `declared-fields/10`, and its conversion row is in
  # `$conversions` below, which asks a question this table cannot.
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
    $fmt = Get-SkillFile 'configure/policies/context.template.md'
    if (-not $fmt) { throw 'configure/policies/context.template.md is missing' }
    $required = @('Routing Table', 'Source Pointer', 'Boundaries', 'Constraints')
    $missing = $required | Where-Object { $fmt -notmatch [regex]::Escape($_) }
    if ($missing) { throw "CONTEXT-FORMAT.md never mentions: $($missing -join ', ')" }
    $true
  }

  Assert "domain-modeling groups multi-context repos as directories under contexts/" {
    $fmt = Get-SkillFile 'configure/policies/context.template.md'
    if (-not ($fmt -match 'contexts/')) { throw 'configure/policies/context.template.md does not match: contexts/' }
    $true
  }

  Assert "ADR-FORMAT keeps the strict 3-of-3 test" {
    $adr = Get-SkillFile 'configure/policies/decisions.template.md'
    if (-not $adr) { throw 'configure/policies/decisions.template.md is missing' }
    ($adr -match 'Hard to reverse') -and
    ($adr -match 'Surprising without context') -and
    ($adr -match 'real trade-off')
  }

  # Repointed by mechanics/06, which changed the rule this guarded: two declared
  # fields move after a commit now, not one. Anchored on what survived — that
  # supersession is stated and the reasoning is frozen — because the literal it
  # used to pin (`superseded by`, unhyphenated) was the old field syntax, and a
  # guard pinned to syntax fails on every rewording that leaves the rule intact.
  # Which fields move is `mechanics/06`'s to assert; enumerating them here too
  # would be the second home this table exists to prevent.
  Assert "ADR-FORMAT states the supersession rule, with the reasoning frozen" {
    $adr = Get-SkillFile 'configure/policies/decisions.template.md'
    if (-not ($adr -match '(?i)supersed')) { throw 'configure/policies/decisions.template.md does not match: (?i)supersed' }
    if (-not ($adr -match '(?i)frozen')) { throw 'configure/policies/decisions.template.md does not match: (?i)frozen' }
    $true
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
      if (-not (Test-Path (Join-Path $skills "configure/tools/$f.md"))) { throw ('nothing at ' + (Join-Path $skills "configure/tools/$f.md")) }
      $true
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
    if (-not ($c -match '(?i)not verified|without a `?glab`? on the machine')) { throw 'configure/tools/gitlab.md does not match: (?i)not verified|without a `?glab`? on the machine' }
    $true
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
$subjectSections = @('layout/02', 'layout/04', 'layout/06', 'streamline/01')

# Ticket 16 split the always-on file. `CLAUDE.md` is committed and read by every
# Claude that opens the repository, so it keeps only rules that hold with or
# without the plugin; the machinery serving them — the Marker, the drift reads,
# the verification report — moved here. `streamline/02` renamed it from
# `tenure.template.md`, for its job rather than for the framework, and added the
# stage-to-guides routing table.
# Assertions follow the rule they are about, so the Marker ones below read this.
$protocolTemplate = 'configure/protocol.template.md'

# The always-on tier below `CLAUDE.md` (ADR 0021). These two ship without
# `paths:` frontmatter, which is what makes the harness inject them on every
# turn — `streamline/02` moved the standards here so the entrypoint could become
# a pointer without any of them dropping to pointer-read, where they would fire
# only when something followed the pointer.
$precedenceTemplate  = 'configure/precedence.template.md'
$engineeringTemplate = 'configure/engineering.template.md'

# What a configured repository loads with no pointer followed. The order is the
# order a reader meets them in, and the list is what `streamline/02`'s pointer
# and placement assertions iterate — adding a template here without adding the
# file is caught by the first of them.
$alwaysOnTemplates = @($claudeTemplate, $precedenceTemplate, $engineeringTemplate)

# Where the two derived guides land in a *configured* repository. `streamline/03`
# moved them under `policies/`, and the destination appears in assertion titles
# as well as in patterns — so it gets a name rather than a search-and-replace,
# which is what left seven assertions stranded when the move was made.
#
# Not to be confused with this repository's own `.claude/version-control.md`,
# which has not moved: the adoption tickets read that path directly and are
# supposed to, because their subject is this tree rather than what ships.
$trackerPolicy = '.claude/policies/tracker.md'
$vcPolicy      = '.claude/policies/version-control.md'

# The two guides `streamline/03` wrote rather than moved. They consolidate rules
# that were stated across several skills, so assertions about those rules read
# the guide, and the skill that used to hold one is checked for the pointer —
# both halves, because a rule cut without a route left behind is a rule nobody
# reaches, and a route left behind with the rule still beside it is two homes.
$knowledgeTemplate = 'configure/policies/knowledge.template.md'
$evidenceTemplate  = 'configure/policies/evidence.template.md'

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
  # The context format owns what a generated row may contain. `declared-fields/05`
  # had this reasoning in the regenerator's own doc-comment as well, which is a
  # home no reader of the format would think to check for a contradiction.
  'the label-row rule'                 = '(?i)a claim its directory never made'
  # The placement rule. Added after review appended a restatement of it to
  # `configure/SKILL.md` and every assertion in the `placement` block stayed
  # green — the rule was shipped unguarded against the one failure this table
  # exists to catch. Anchored on the removal question, which is the rule's test
  # rather than a phrase that would travel with a summary of it.
  'the placement rule'                 = '(?i)were AEP removed'
  # `tdd` owns the loop, so it owns why a guessed test command wrecks it. This
  # reasoning had reached four files before the guard existed.
  'the guessed-test-command cost'      = '(?i)full-suite run per cycle'
  'the stale-command rule'             = '(?i)stale command is worse than no command'
  # mechanics/11. The evidence policy owns what a consumed finding records and
  # who writes it; `/design` reads the answer and points. Anchored on the
  # obligation rather than on the field name, because the reading stage has a
  # legitimate reason to mention the field and no reason to restate the duty.
  'the finding-consumption rule'       = '(?i)records its own consumption'
  # mechanics/07. The context format owns the routing mechanism, so it owns what
  # a load condition has to be; the decisions format adopts it and points. Both
  # stated it independently at first, which is how one rule acquires two homes
  # that agree today. Anchored on the topic-versus-trigger claim rather than on
  # the field name, since both files have a legitimate reason to name the field.
  'the load-condition rule'            = '(?i)never what it is about|never a description of what'
  # axis/01. What keeps a skill on the typed side, phrased as a test so it can be
  # failed rather than joined. The router explains it to a human and is the one
  # home under `./skills`; ADR 0063 records why it was chosen and `specs.md`
  # states it normatively, and neither is a second home for the same reason the
  # spec and a Decision are never one — they answer *why* and *what conforms*.
  # Anchored on the test itself, because a guard written from the two exempt
  # names would go green the moment a third borrowed the reasoning.
  'the axis exemption test'            = '(?i)subject is not the repositor'
  'the worse-convention escape'        = '(?i)say so\s*\**\s*once, with reasoning'
  # entry/01. The always-on tier owns the rule that a route is entered rather than
  # named for the user to type (ADR 0061); every stage obeys it and none restates
  # it. Anchored on the obligation — entering the stage — rather than on the
  # destination list, since a stage naming its own destination is applying the
  # rule and not a second home. `/implement` does exactly that two files away.
  'the entry-route rule'               = '(?i)enters? that stage'
  # aep/11. The always-on tier owns the workaround-comment test; design's
  # root-cause section is about the *plan* and carries its own anchor.
  'the workaround-comment test'        = '(?i)workaround[^\r\n]{0,80}fix the code'
  # TICKETS.md owns the ticket format, so it owns which tracker expresses
  # a state which way. /implement claims tickets and pointed at the config,
  # but restated the mapping too. fieldwork/03 rewrote the mapping — labels
  # out, native issue state in — so the guard tracks the subject: any
  # restatement needs the term, whatever verb carries it there.
  'the local-markdown status form'    = '(?i)native (issue )?state'
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
  # `streamline/03`'s consolidations. Each was stated in two or three skills
  # before it had a guide, so each gets a guard — criterion 5, and the reason
  # the ticket asked for one per moved rule rather than one for the move.
  #
  # Anchored to the *reasoning*, not to the imperative. Each producing skill
  # still says "never write Context directly" about itself, which is its own
  # constraint and correctly local; what may not be restated is the argument
  # for it, and the argument is what drifts when it is copied.
  'the knowledge-authorship table'     = '(?im)^\|\s*Stage\s*\|\s*May write\s*\|'
  'the silence rule'                   = '(?i)silence is the correct output'
  'the research-finding version argument' = '(?i)no version[^\n]{0,160}re-verify'
  'the prototype-result argument'      = '(?i)true of the thing that was built'
  # `(re)?validates` because the guide and the skill spelled it differently, and
  # a guard written from only the new spelling passed while the old one sat two
  # files away — which is the failure the authoring standards name by example.
  'the evidence-is-not-knowledge property' = '(?i)nothing (re)?validates it afterwards'
  # `streamline/04` placed this one. Anchored to the discriminator the rule
  # turns on — where a term is *used* — rather than to the heading, so a
  # restatement that reaches the same conclusion in different words is still
  # a second home.
  'the term-placement rule'            = '(?i)only while one workflow stage runs'
  # fieldwork/01. The tracker template owns the detect test for what a ticket
  # is — the maps policy and /configure reach it by pointer. Anchored to the
  # subject's verbs — tying, binding, mapping a ticket to a branch — rather
  # than to one file's wording; ADR 0035's own phrasing ("binds every ticket
  # to one branch") is the likeliest restatement and has to match too.
  'the ticket-branch detect test'      = '(?i)(tie|bind|map)s? (one|a|every) ticket to (one|a) branch'
  # fieldwork/02. The maps policy owns both: what a decision edge means, and
  # what happens to local numbering when the tracker assigns ids. The first is
  # anchored to the term the rule coins — any restatement needs the vocabulary
  # to mean the same thing; the second to the subject, dropping the NN prefix.
  'the answer-gating edge rule'        = '(?i)answer.gating'
  'the tracker-assigned-id rule'       = '(?i)(no|drop(s|ping)?) (the )?`?<?NN>?`? prefix'
  # fieldwork/03. The tickets template owns what `obsolete` becomes on GitHub;
  # the forge reference carries only the invocation, and stays free of the
  # state's name so a restatement there is caught rather than blessed.
  # Anchored to the mapping itself — the state to its closure reason.
  'the obsolete-closure form'          = '(?i)obsolete[^\r\n]{0,80}not[ -]planned'
  # fieldwork/06. Four placed rules, one home each: the declaration and its
  # timing in the tickets template; what reaching an increment does — the hold
  # and the guardrail — in the implement stage; the relaxed exit in the maps
  # template. Each anchored to the phrase any faithful restatement needs.
  'the increment-declaration timing rule' = '(?i)design time only|never added during the build|build never (adds|writes) one'
  'the increment hold rule'               = '(?i)hold(ing|s)? the claim'
  'the increment never-invented guardrail' = '(?i)never invents? an increment'
  'the map settled-or-declared exit'      = '(?i)settled,? or declared'
  # scaffolding/01. The tickets template owns the tracker-side rule (ADR 0038):
  # a workflow-created ticket on a shared tracker states an outcome outside the
  # protocol directory. Two alternations, because a restatement arrives in one
  # of two subjects: the outcome's side of the directory, with slack for the
  # words that may sit between; or the ADR's own phrasing — work whose whole
  # effect sits under it — which has to match too.
  'the protocol-only tracker rule'        = '(?i)outcome[^\r\n]{0,30}(outside|beyond)[^\r\n]{0,60}(protocol directory|`?\.claude`?)|(entire|whole) effect[^\r\n]{0,40}(under|inside)[^\r\n]{0,30}(protocol directory|`?\.claude`?)'
  # scaffolding/02. The version-control template owns the PR-side exception
  # (ADR 0038): a pull request whose entire diff sits under the protocol
  # directory is a design PR, one per design run. Anchored to both subjects a
  # restatement needs — the diff's side of the directory, or the one-per-run
  # bound tied to the term. The maps policy names the term and points, which
  # matches neither. Dotall with bounded gaps, because the template hard-wraps
  # its lines and a rule may break anywhere in the sentence.
  'the design-PR exception'               = '(?is)entire\s+diff.{0,50}under.{0,40}(protocol\s+directory|`?\.claude`?)|design\s+PR.{0,60}one\s+per\s+(design\s+)?run|design\s+PR\s+per\s+session'
  # scaffolding/03. Three placed rules, one home each (ADR 0039): what a drift
  # finding holds, in the evidence template; the map's index line, in the maps
  # template; the never-inline exception for a falsified Decision, in the
  # knowledge template. Each anchored to the subject a restatement needs —
  # the commit the check ran against, the checked-off line, and a Decision
  # spoken of beside inline healing.
  'the drift-finding contents'            = '(?is)against\s+which\s+commit'
  'the drift-finding index line'          = '(?is)task.list\s+line|checked\s+off\s+when\s+the\s+healing'
  'the decision-drift never-inline rule'  = '(?is)(decision|adr)s?\b.{0,60}heal(ed|s|ing)?\s+inline|heal(ed|s|ing)?\s+inline.{0,60}\b(decision|adr)s?\b'
  # orchestration/02. The sub-agent policy owns the dispatch contract, so each
  # rule it places gets one home and the dispatching stages point rather than
  # restate.
  #
  # Every one of these was written twice. The first set was transcribed from the
  # policy's own sentences, and a review planted six restatements in a spawner's
  # voice that all six guards let through — the exact failure the authoring
  # standards describe, produced while believing the opposite. What killed the
  # first set is that its mutation test was written *from* the patterns, so the
  # plants matched by construction. These are anchored on the subject each rule
  # turns on: whose consent, which conduit, what a missing part means, what the
  # record is checked against. Each carries an alternation because a faithful
  # restatement reorders the subject as often as it rewords it.
  'the consent boundary'                  = '(?i)another agent.?s consent|\b(sub-?agent|child|agent)\b[^.]{0,100}(consent|approv\w+)[^.]{0,60}(another|other|behalf|parent|session)'
  'the brief completeness rule'           = '(?i)brief[^.]{0,80}(missing|omits|lacks|without)[^.]{0,60}\b(one|any)\b|(missing|omit\w*|lack\w*)[^.]{0,40}(part|six)[^.]{0,60}(incomplete|defect)'
  'the only parent-to-child channel'      = '(?i)(only|sole|single)\s+(channel|route|conduit|way|means|path)[^.]{0,60}(parent|child|sub-?agent)|(parent|child|sub-?agent)[^.]{0,40}(only|sole)\s+(channel|route|conduit)'
  'a child records a decision and stops'  = '(?i)\b(child|sub-?agent)\b[^.]{0,100}decision[^.]{0,100}(stop|halt|never (takes|decides))|decision[^.]{0,60}\b(child|sub-?agent)\b[^.]{0,100}(stop|halt)'
  'the record-is-a-manifest rule'         = '(?i)(manifest|enumerat\w+)[^.]{0,80}(not|rather than|never)[^.]{0,40}(report|summary|narrative)|(not|rather than)[^.]{0,30}an? (report|summary|narrative)[^.]{0,60}(manifest|enumerat)'
  # The record subject is required in two of the three branches: without it,
  # `resolving-merge-conflicts` ("a text diff could not reconcile") is a second
  # home for a rule it has nothing to do with.
  'the record reconciliation bar'         = '(?i)(record|manifest)[^.]{0,80}reconcil\w+[^.]{0,60}diff|reconcil\w+[^.]{0,60}(record|manifest)[^.]{0,60}diff|reconcil\w+ against[^.]{0,60}diff'
  # These three are sentence-scoped conjunctions rather than sequences. A
  # restatement reorders a rule at least as often as it rewords one, and an
  # alternation per ordering is a combinatorial way of saying "unordered" — the
  # lookaheads say it directly, and stay anchored to the subject because the
  # match itself is the child, or the record.
  'a child writes no knowledge layer'     = '(?is)\b(child|sub-?agent)\b(?=[^.]{0,160}(writes?|records?|adds?))(?=[^.]{0,160}\b(no|nothing|never|not)\b)(?=[^.]{0,160}(knowledge|Context|Decision))'
  # The negation has to govern the verb. As a sentence-scoped conjunction this
  # also matched "a child based on anything but the claim is not integrated" —
  # a rule about what the *orchestrator* refuses, in the passive, which is a
  # different rule in a different file and not a second home for this one.
  # Two shapes of negation, because English has two: the negation after the
  # verb ("claims nothing") and before it ("never claims", "does not claim").
  # Keyed to the first alone it lost "never claims a ticket and never lands its
  # own work"; keyed to a sentence-scoped conjunction it gained the passive "a
  # child … is not integrated", which is the orchestrator's rule and not this
  # one. The bounded gap before the verb is what separates them.
  # The subject governs both shapes. Lifted out of the group, the second one
  # matched "never push" in the always-on rules and nine files besides — a
  # probe for a rule about children that had stopped mentioning children.
  # `integrates?` with a closing boundary is also what keeps the passive "is
  # not integrated" out: that sentence says *integrated*, and the rule here is
  # about a child that does not integrate.
  'a child claims and integrates nothing' = '(?i)\b(child|sub-?agent)\b[^.]{0,120}((claims?|commits?|pushes|integrates?|merges?|lands?)\s+(nothing|no\b|none)|\b(no|never|not)\s+(\w+\s+){0,2}(claims?|commits?|push(es)?|integrates?|merges?|lands?)\b)'
  'the change record is Position'         = '(?is)(change )?record\b(?=[^.]{0,160}\bPosition\b)|\bPosition\b(?=[^.]{0,120}change record)'
  # Adjacency is load-bearing here, unlike its neighbours: the negation has to
  # attach to the dispatching verb. Written as a sentence-scoped conjunction it
  # matches `/review`'s "before two subagents are spawned to review nothing",
  # which is a warning about an empty diff and not a second home for this rule.
  'a child dispatches nobody'             = '(?i)\b(child|sub-?agent)\b[^.]{0,80}(dispatch(es)?|spawn(s)?)\s+(nobody|no one|no-one|nothing|none)|(never|not|no)\s+(dispatch|spawn)\w*[^.]{0,60}\b(child|sub-?agent)'
  # parallel-tickets/02. The broker's rules, each anchored on the thing that
  # would have to change for the rule to stop holding: the menu's closure, the
  # direction each obligation runs in, the budget a request draws on, and the
  # outcome that is not an ending.
  # Written twice, and the second time from the rule rather than from my own
  # sentence. The first set transcribed the policy's new wording — `travels
  # attributed`, `costs what work costs` — and a review restated all six in
  # other words with every one staying green. The comment block above records
  # the same failure from an earlier ticket, which is the reason these are
  # keyed on what each rule is *about*: which things may be asked, who learns
  # who asked, what may not happen to a reply, what asking draws on, and what a
  # return of waiting does not mean.
  'the request menu is closed'            = '(?i)(menu|list|set)[^.]{0,60}(request|ask)\w*[^.]{0,60}(closed|fixed|bounded|two)|(request|ask)\w*[^.]{0,60}(menu|list)[^.]{0,40}(closed|fixed|bounded)|(refused|declined|turned down)[^.]{0,50}(without being weighed|without being considered|flat|outright)'
  'the question travels attributed'       = '(?i)(question|ask\w*)[^.]{0,80}(attributed|which child|who is asking|names the (child|ticket))|(human|reader)[^.]{0,60}(sees|knows|learns)[^.]{0,50}(which child|who asked|who is asking|raised it)'
  'the answer travels verbatim'           = '(?i)(answer|reply|response)[^.]{0,80}(verbatim|word for word|as given|unchanged)|(answer|reply|response)[^.]{0,60}(not|never|may not)[^.]{0,50}(summaris|summariz|condens|paraphras|reword)|(not|never|may not)[^.]{0,50}(summaris|summariz|condens|paraphras|reword)\w*[^.]{0,40}(answer|reply|response)'
  'a request spends the cap'              = '(?i)(request|ask\w*)[^.]{0,80}(spends?|costs?|draws on|counts against)[^.]{0,50}(cap|budget|allowance)|(cap|budget|allowance)[^.]{0,60}(a request|asking)'
  'waiting is not an ending'              = '(?i)waiting[^.]{0,80}(not an ending|not finished|has not finished|mid-conversation|still)|(not|never)[^.]{0,40}(an ending|finished)[^.]{0,50}waiting'
  # parallel-tickets/04. The build stage owns both, because it is the stage that
  # would breach either: which frontier tickets make up a dispatched set, and
  # that the plan it states is not a gate. The tickets template is the likeliest
  # second home for the first — it owns the edges the rule reads — so each is
  # anchored on what the rule turns on rather than on the sentence written here:
  # the edges as the sole input, and approval as the thing not waited for.
  # Sentence-scoped conjunctions, like the record and consent rules above: a
  # restatement reorders the subject as readily as it rewords it, so ordering the
  # alternations would be a combinatorial way of saying "unordered". Three
  # subjects have to co-occur for the first — the set, the edges, and the
  # exclusivity that is the whole rule — because the maps template speaks of a
  # set of tickets and their edges in one sentence while stating something else
  # entirely, and that sentence is not a second home for this.
  # The exclusivity alternation carries `alone`, `nothing else` and `follows
  # from` because a review restated the rule without any of the first six —
  # "membership follows from the edges alone, and from nothing else about a
  # ticket" — and the entry let it through.
  'the set is computed from edges'        = '(?is)\b(set|members?(hip)?)\b(?=[^.]{0,200}\bedges?\b)(?=[^.]{0,200}(comput\w+|read off|determin\w+|follows? from|exactly|permit|only what|never widen|\balone\b|nothing else|solely|sole input))'
  # `gated` is deliberately not in the second: a set's tickets *gate* each other,
  # which is the edge relation and not approval, and keying on the word made the
  # ticket-builder role a second home for a rule about the human.
  # `agree` and `confirm` for the same reason: the restatement that got through
  # was "the plan is told, not asked: nothing waits on the human agreeing before
  # the branches exist", which names no approval at all.
  'the stated plan is not a gate'         = '(?is)\b(plan|set)\b(?=[^.]{0,160}\b(not|never|without|nothing)\b)(?=[^.]{0,160}(approval|approved|sign-?off|agree\w*|confirm\w*|told, not asked))|(does not|never|nothing)\s+\w*\s?(stop|wait|pause)\w*[^.]{0,40}(approval|agree\w*|confirm\w*)'

  # parallel-tickets/05. Integration is the dispatching stage's, so both rules
  # about a collision are homed there. Each requires the collision subject
  # explicitly: `resolving-merge-conflicts` is a whole skill about reconciling
  # two versions of a file, and a pattern keyed on merging alone would make that
  # skill a second home for a rule about two children of one set.
  # Both were written sentence-scoped with `[^.]`, and both were wrong for it:
  # every pointer in this workflow is a path with dots in it, so the scope ended
  # at `.claude` and the lookahead never reached the policy it was looking for.
  # The mechanism entry matched *nothing* in the file that owns the rule — its
  # one home was an unrelated sentence in /configure, so the single-home sweep
  # was green and the mutation that planted a restatement elsewhere was killed
  # for making it two homes rather than for finding the restatement. Line-scoped
  # now, and the second alternation of each carries the subject spelled out,
  # because a faithful restatement says "two children wrote the same path"
  # without ever using the word.
  'a collision is the orchestrator to resolve' = '(?is)\bcollision\b(?=[^\r\n]{0,300}(orchestrator|parent|this stage))(?=[^\r\n]{0,300}(resolv|settl|reconcil))|(?is)(two|both) children[^\r\n]{0,120}(same|one) path(?=[^\r\n]{0,200}(orchestrator|parent|this stage))'
  'the collision mechanism is the repository own' = '(?is)(names? no merge strateg|no merge strateg\w+ of its own|merge strateg\w+[^\r\n]{0,100}(comes from|from the|taken from|the repositor)|(never|not|no)[^\r\n]{0,40}(name|choose|pick|state)\w*[^\r\n]{0,40}merge strateg)'
  # parallel-tickets/06. Failure and review both invert between the axes, and
  # the dispatching stage owns both inversions. Line-scoped from the start, for
  # the reason the 05 pair had to be repaired: a sentence-scoped lookahead dies
  # at the first dot, and every pointer here is a path full of them.
  # Both alternations first required the author's own nouns, and a review
  # restated the rule without any of them — "when one ticket of a set cannot be
  # finished, every other ticket that did finish is still integrated" — so the
  # subject groups carry the paraphrases a restatement actually reaches for.
  'failure in a set is per ticket'  = '(?is)(fail\w*|stop(s|ped|ping)?|cannot be finished|broke|breaks)[^\r\n]{0,160}(sibling|the rest|other members|every other|the others|that did finish)[^\r\n]{0,100}(land|stay|remain|in place|unaffected|integrat)|(sibling|the rest|other members|the others)[^\r\n]{0,80}(land|stay|remain|integrat)[^\r\n]{0,100}(fail|stop)'
  # `you` in the subject group because a role is written in the second person,
  # and that is the register a restatement arrives in there: "you request your
  # own review, and the findings return to you" says the whole rule without ever
  # using the word `child`. `asks for` and `what comes back` for the same reason
  # — a review reached both without using `requests` or `findings`.
  'a set child requests its own review' = '(?is)\b(child|member|you)\b[^\r\n]{0,60}(requests?|asks? for)[^\r\n]{0,40}((its|your) own )?review|\breview\b[^\r\n]{0,80}request\w*[^\r\n]{0,40}by[^\r\n]{0,30}(the )?child|(findings|the review)[^\r\n]{0,80}(back to|reach|return to|goes? to)[^\r\n]{0,60}(the )?(child|requester|you\b|one that wrote)'
  # Deliberately absent from this table: what bounds a ticket child, and what it
  # does with a declaration it cannot execute. Both are homed in
  # `agents/ticket-builder.md`, and this table is swept two ways — tenure/02
  # requires one home under `skills/`, orchestration/07 requires that no role
  # match any entry at all. A rule homed in a role fails both at once: stated
  # nowhere, and restated by the file that states it. Naming one here needs the
  # sweeps to accept `agents/` as a home, which is shared machinery and no
  # ticket's yet. parallel-tickets/03 asserts them literally instead.
  'a ticket child owns its ticket'        = '(?i)(ticket child|whole ticket)[^.]{0,60}owns?[^.]{0,40}ticket|owns?[^.]{0,80}(the files, for a portion|files for a portion)|what (it|a child) owns[^.]{0,80}(portion|ticket)'
  # orchestration/04. The declaration's home is the tickets template; the
  # guardrail's is the stage that would breach it, exactly as the increment
  # pair is split.
  #
  # Written twice, like the 02 set and for the same reason. The first three
  # keyed on the templates' own verbs — `invent`, `design time only`,
  # `overlapping ownership` — and a review paragraph restating all three in
  # other words ("may not conjure a fan-out of its own", "settled while the
  # ticket is still being planned", "two roles never touch the same file")
  # passed every one. These pair the subject with any verb that carries it.
  'the fan-out never-invented guardrail'  = '(?i)(never|not|no)[^.]{0,60}(invent|conjur|creat|devis|make|cut)\w*[^.]{0,40}fan.out|fan.out[^.]{0,60}(never|not)[^.]{0,40}(invent|conjur|creat|devis)'
  'the fan-out declaration timing rule'   = '(?i)(design time|planning|planned)[^.]{0,140}(never|not|nothing)[^.]{0,60}(during the build|once the build|after the build|mid-build)|(never|not|nothing)[^.]{0,60}(during the build|once the build)[^.]{0,100}(design time|planned)'
  # Deliberately does NOT match the fenced placeholder `<the files this portion
  # owns>`. It did, and deleting the ownership rule outright left the guard
  # green on the template block alone — the rule travelling with its own
  # example.
  'the portion ownership rule'            = '(?i)overlapping ownership|(two|both)[^.]{0,30}(portions?|roles?|children)[^.]{0,50}(never|not|no)[^.]{0,40}(touch|writ|own|claim)\w*[^.]{0,30}same file|(never|no)[^.]{0,40}(two|another)[^.]{0,40}(portion|role|child)[^.]{0,60}same file'
  # Both placed by 04 with no guard until review found them stated twice.
  # Verb-free on purpose. Keyed to "dividing" and its synonyms, it missed
  # "Carving a ticket into portions… is an architecture decision" — the subject
  # is the pairing of a split with the word architecture, not the verb chosen
  # to describe it.
  'the parallel-split-is-architecture rationale' = '(?i)(portions?|parallel)[^.]{0,80}architecture decision|architecture decision[^.]{0,80}(portions?|parallel)'
  'the fan-out increment ordering rule'   = '(?i)(resolves?|resolved)[^.]{0,60}before anything is dispatched|before anything is dispatched[^.]{0,60}(resolv|parent)'
  # orchestration/05. The setting and its reasoning belong to /configure; the
  # check that does not trust the setting belongs to the integrator. Anchored
  # on the silent-default subject — a worktree taking the default branch where
  # the parent's head was meant — rather than on either file's verbs.
  # Both were written from my own sentences and both were nearly blind. The
  # base-ref probe caught one restatement in six and fired on an unrelated
  # rebase instruction; the base check caught none of five. What each rule is
  # actually about is a pairing — an isolated branch's origin against the
  # parent's position, and a child's base against the moment of integration —
  # so the vocabulary on each side is what varies and the pairing is what does not.
  # `main` is excluded only where it is not a branch. Requiring `off|from|onto`
  # before it was the first fix and it cost the probe four of five restatements
  # — "defaults to main", "starts at main rather than at the claim". The
  # exclusion belongs on the noun that follows, which is the thing that made
  # "the main checkout" a different subject.
  # The `/` exclusion is not decoration: `main` inside a docs URL sat 80
  # characters from an unrelated "not", and the probe read a link as a
  # statement about where a worktree starts.
  'the worktree base-ref obligation'      = '(?i)(isolat\w+|worktree|baseRef)[^.]{0,120}(default branch|trunk|\bmain\b(?!\s*/)(?!\s+(checkout|thread|process|session|conversation)))|(default branch|trunk|\bmain\b(?!\s*/)(?!\s+checkout))[^.]{0,80}(not|rather than|instead of)[^.]{0,60}(parent|session|head|claim|working)'
  # Placed by the sub-agent policy; orchestration/06 restated it in the stage
  # and nothing caught it, because no entry existed. Keyed to the definitional
  # form — how far the claim reaches — so that announcing the widening, which
  # is the stage's own business, is not mistaken for redefining it.
  'the claim widens over children'        = '(?i)claim[^.]{0,60}widens? to cover|widen\w*[^.]{0,40}(to )?cover[^.]{0,40}(child|children|beneath)|claim[^.]{0,60}covers? (every |each |all )?(child|children)|covers every child beneath'
  'the child base check at the integrator' = '(?i)(confirm|check|verif\w+|establish|determin\w+)[^.]{0,60}(child|children)[^.]{0,40}(base|built on|branched)|(base|built on|branched)[^.]{0,60}(before|prior to)\s+(integrat|merg)\w*|claim[^.]{0,40}ancestor[^.]{0,60}(child|produced|built)'
  # orchestration/06. The stage owns what it does with the artifacts; the policy
  # owns what they contain, and the format owns what is declared. Each of these
  # is a behaviour, which is why none of them reads like a restatement of either.
  # All three were written from my own sentences and ten review restatements
  # missed all three. The negation vocabulary is the recurring hole — `not`,
  # `rather than`, `instead of`, `never` are one idea and a probe that knows
  # only two of them is blind to half the ways the rule gets written. The
  # one-commit probe was worse: its second branch was the diff's own sentence,
  # verbatim, which is the failure the authoring standards name by example.
  'integration is record-driven'          = '(?i)(integrat\w+|work\w*|proceed\w*)[^.]{0,60}(record|manifest)[^.]{0,80}(not|never|rather than|instead of)[^.]{0,40}(branch|diff)|(record|manifest)[^.]{0,80}(not|never|rather than|instead of)[^.]{0,40}(its |the )?branch'
  # Both needed the subject putting back. Unanchored, "integrates nothing"
  # matched the policy's rule about a *child*, and "stays one commit" matched
  # git.md's rule about *amending* — two different rules that happen to share
  # a phrase with this one.
  'a partial fan-out integrates nothing'  = '(?i)(fan.out|children|portions?|sibling\w*|whole set)[^.]{0,120}(integrates? nothing|nothing (is |ever )?(integrated|lands|merges)|none of the work|no part)|(nothing (is )?integrated|none of the work|no part of it)[^.]{0,120}(sibling|portion|fan.out)|(one|any) (child|portion)[^.]{0,80}(fail|stop)\w*[^.]{0,80}(nothing|none)|all children or none'
  'the fanned-out ticket is one commit'   = '(?i)(squash\w*|fan.out|fanned.out|children)[^.]{0,120}(one commit|single commit|indistinguishable)|(one commit|single commit)[^.]{0,100}(squash|fan.out|fanned.out|children)'
  # orchestration/07 placed these two. Both were deferred by 02 because each
  # had a second home the policy could not remove on its own: the inheritance
  # fact was stated *backwards* in `codebase-design/DESIGN-IT-TWICE.md`, and
  # the paths-not-pasted rule sat in `review/SKILL.md` with its argument.
  # Anchored to the subject, so the false statement of the first would count as
  # a second home exactly as the true one does — a rule contradicted elsewhere
  # is not single-homed, it is disputed.
  # The verb is not the subject. Keyed to inherit/arrive/hold, the first missed
  # "starts with no Context of its own" and "come with the always-on tier
  # already applied" — a one-word edit of the sentence this ticket deleted, and
  # a plain restatement. What identifies the rule is a child paired with the
  # tier it does or does not come holding, whichever verb carries it.
  'what a child inherits'                 = '(?i)\b(child|sub-?agent)s?\b[^.]{0,140}(inherit\w*|arriv\w+|start\w*|come[sd]?|begin\w*|has no|have no|hold\w*|carr\w+|receiv\w+)[^.]{0,100}(entrypoint|always-on|unconditional tier|hierarchy|Context loaded|Context of its own|no Context|conversation)'
  # Two sentences is the common shape — "Hand it a path. Never dump the file
  # in." — so the negative half has to stand alone as well as paired.
  'inputs by path, never pasted'          = '(?i)(paths?|by path)[^.]{0,60}(not|never|rather than|instead of)[^.]{0,40}(pasted|pasting|quoted|quoting|dump\w*|inlin\w+)|(not|never|rather than)[^.]{0,40}(paste|quote|dump|inline)\w*[^.]{0,60}(into the brief|in the brief|file|content|terms|vocabulary)'
}

Describe-Ticket 'tenure/02' 'verification at use, healing where the break is found' {

  Assert "the always-on rules ship as the CLAUDE.md template /configure installs" {
    if (-not (Test-Path (Join-Path $skills $claudeTemplate))) { throw ('nothing at ' + (Join-Path $skills $claudeTemplate)) }
    $true
  }

  Assert "CLAUDE.md stays an entrypoint, not a manual — under 200 lines" {
    $n = ((Get-SkillFile $claudeTemplate) -split '\r?\n').Count
    if ($n -ge 200) { throw "$n lines" }
    $true
  }

  Assert "the Marker rule states the trusted path — matching HEAD plus a clean tree costs no reading" {
    $c = Get-SkillFile $protocolTemplate
    if (-not $c) { throw 'template is missing' }
    ($c -match 'marker\.json') -and
    ($c -match '(?i)clean') -and
    ($c -match '(?i)HEAD')
  }

  # Repointed by mechanics/03: the matching path is now two reads rather than
  # one, because the Marker compares two facts. What it still buys — and what
  # this asserts — is that no *drift* is read on that path.
  Assert "the matching path costs git reads and no drift reading" {
    $c = Get-SkillFile $protocolTemplate
    if (-not ($c -match '(?i)(no drift reading|no reading|without reading|read nothing)')) { throw ($protocolTemplate + ' does not match: (?i)(no drift reading|no reading|without reading|read nothing)') }
    $true
  }

  Assert "both drift sources are named, with the command that reads each" {
    $c = Get-SkillFile $protocolTemplate
    $missing = @()
    if ($c -notmatch 'git diff --name-only') { $missing += 'committed drift' }
    if ($c -notmatch 'git status --porcelain') { $missing += 'uncommitted drift' }
    if ($missing) { throw "unreadable: $($missing -join ', ')" }
    $true
  }

  Assert "the non-ancestor case is covered — a moved HEAD makes the diff meaningless" {
    $c = Get-SkillFile $protocolTemplate
    if (-not ($c -match '(?i)ancestor')) { throw ($protocolTemplate + ' does not match: (?i)ancestor') }
    if (-not ($c -match '(?i)rebase|branch switch|switched branch')) { throw ($protocolTemplate + ' does not match: (?i)rebase|branch switch|switched branch') }
    $true
  }

  Assert "verification is at use — never a startup scan, never a phase" {
    $c = Get-SkillFile $claudeTemplate
    if (-not ($c -match '(?i)never a scan|no startup scan|never scan')) { throw ($claudeTemplate + ' does not match: (?i)never a scan|no startup scan|never scan') }
    if (-not ($c -match '(?i)about to (rely|be relied)|at the point of use|where it is used')) { throw ($claudeTemplate + ' does not match: (?i)about to (rely|be relied)|at the point of use|where it is used') }
    $true
  }

  Assert "a broken Source Pointer is recovered by searching, never invented" {
    $c = Get-SkillFile $claudeTemplate
    if (-not ($c -match 'Source Pointer')) { throw ($claudeTemplate + ' does not match: Source Pointer') }
    if (-not ($c -match '(?i)never invent|not invent|rather than invent')) { throw ($claudeTemplate + ' does not match: (?i)never invent|not invent|rather than invent') }
    $true
  }

  Assert "healing happens in place — no queue, no deferred pass" {
    $c = Get-SkillFile $claudeTemplate
    if (-not ($c -match '(?i)where you find it|in the same breath|no deferred|no queue')) { throw ($claudeTemplate + ' does not match: (?i)where you find it|in the same breath|no deferred|no queue') }
    $true
  }

  # Rewritten by mechanics/03 rather than repointed: the rule itself changed.
  # `/commit` was the only writer because the old claim — Context is trusted —
  # could only be earned by a stage that verified everything. The claim is now
  # narrowed to "this tree's drift was read", which a drift-reading stage does
  # earn, so the single-writer rule is gone and a bounded second writer replaced
  # it. Asserting the old rule here would contradict the specification.
  Assert "/commit writes both facts, and only the tree fact has a second writer" {
    $c = Get-SkillFile $protocolTemplate
    if ($c -notmatch '(?is)/commit.{0,40}writes both facts') { throw '/commit is not named as the writer of both' }
    if ($c -notmatch '(?is)re-stamp the tree fact alone') { throw 'the second writer is unbounded or absent' }
    if ($c -notmatch '(?is)leaving the commit fact untouched') { throw 'nothing keeps the second writer off the commit fact' }
    $true
  }

  Assert "the Marker is machine-local — a teammate's verification is not Claude's" {
    $c = Get-SkillFile $protocolTemplate
    if (-not ($c -match '(?i)gitignored|machine-local|per-clone|not committed')) { throw ($protocolTemplate + ' does not match: (?i)gitignored|machine-local|per-clone|not committed') }
    $true
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
    # Repointed by mechanics/03. The old pattern required the match to license
    # *trust*; the rule now licenses skipping the drift reads and explicitly
    # refuses the trust reading, so a pattern demanding the old wording reported
    # the rule as stated nowhere while it sat two lines away.
    'the Marker cache-validity rule'  = '(?is)marker.{0,80}(==|equals|matches).{0,60}HEAD.{0,240}(drift reads may be skipped|trusted|no reading|no verification)'
    # mechanics/04. Here rather than in `$rulePattern` for the same reason the
    # Marker rule is: it is router machinery, not a rule that must fire on every
    # turn, and `$rulePattern` membership asserts the latter. The router owns it
    # because the router owns the Marker; every stage reads the router, so a
    # stage restating it gains nothing and drifts on the condition — which is
    # the half that makes the permission safe.
    'the tree re-stamp permission'    = '(?i)re-stamp the tree fact alone'
    # mechanics/16. The build stage owns when a worktree is spent, because it is
    # the only party that knows the work landed. The git guide carries the
    # invocation and no judgement, so it is not a second home — the pattern
    # matches the determination, not the verb.
    'the spent-worktree rule'         = '(?i)spent when the work it held has landed'
    'the commit scope vocabulary'     = '(?i)`misc`.{0,40}`stuff`'
    # `that` optional: `streamline/03` moved this into its guide, where the
    # sentence no longer needs the demonstrative. Anchored to the subject —
    # who owns graduation — rather than to one file's phrasing of it.
    'the evidence graduation rule'    = '(?i)owns (that )?graduation'
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

  # ADR 0007: a rule that must hold unconditionally has to be somewhere the
  # harness injects without a pointer being followed, because a rule inside a
  # skill fires only when that skill runs. Misplacing one is a silent failure,
  # so the always-on set is asserted explicitly.
  #
  # Asserted over the *tier* rather than over `CLAUDE.md`, since `streamline/02`
  # moved two of the three into rule templates. Naming the file would have made
  # this fail on a move that kept every rule always-on — which is the opposite
  # of what it exists to catch, and would have taught the next reader to relax
  # it. ADR 0021: the tier is the mechanism, and the mechanism is what to check.
  #
  # Presence only, not exactly-one. These probes are deliberately loose for the
  # reason `$rulePattern` gives, and `precedence` now matches both the ladder
  # and the pointer at it — which is correct. The strict single-home checks are
  # `$singleHome` above and `streamline/02`'s, where the patterns are tight
  # enough to tell a statement of a rule from a mention of one.
  $alwaysOn = [ordered]@{
    'Claude never silently decides architecture' = '(?i)never silently decid'
    'the instruction precedence chain'           = '(?i)precedence'
    'the cold-request path states a classification' = '(?i)classification'
    # entry/01. Presence in the *tier* is the whole point: a router that had to be
    # selected could not fix a stage failing to be selected, so this rule is only
    # correct where it loads without being chosen. Asserting it over the tier
    # rather than over a filename keeps it true if the paragraph moves between
    # unconditional files, exactly as the classification probe above does.
    'the cold-request path enters the stage it names' = '(?i)enters? that stage'
  }
  foreach ($rule in $alwaysOn.Keys) {
    $pattern = $alwaysOn[$rule]
    Assert "the always-on tier carries: $rule" {
      $homes = @($alwaysOnTemplates | Where-Object { (Get-SkillFile $_) -match $pattern })
      if ($homes.Count -eq 0) { throw 'stated in nothing that loads unconditionally' }
      $true
    }
  }
}

# --- ticket tenure/03 — /design, the whole planning surface -------------------------

Describe-Ticket 'tenure/03' 'the whole planning surface' {

  Assert "/design ships as a skill" {
    if (-not (Test-Path (Join-Path $skills 'design/SKILL.md'))) { throw ('nothing at ' + (Join-Path $skills 'design/SKILL.md')) }
    $true
  }

  # entry/01 moved planning across the invocation axis (ADR 0061). The reason the
  # old assertion carried — "planning starts because the user asked for it" — was
  # the only record of that choice anywhere, which is how it read as an unexamined
  # convention until this suite was searched; it lives in the ADR now. Asserted in
  # the negative direction deliberately: a false pass here leaves planning
  # unreachable, which is the exact defect the entry rule exists to remove.
  Assert "/design is model-invoked — a described change reaches planning unasked" {
    if (Test-UserInvoked 'design/SKILL.md') { throw 'still user-invoked' }
    $true
  }

  # For a model-invoked skill the description is the entire basis of selection, so
  # the guard against planning firing on a question lives in that string and
  # nowhere else. Both directions are checked: what selects it, and what excludes
  # it. Checking only the first would pass a description that grills every
  # question asked of the repository.
  Assert "/design's description states what selects it and what does not" {
    $fm = Get-Frontmatter (Get-SkillFile 'design/SKILL.md')
    if ($fm -notmatch '(?i)would change code') { throw 'does not name a change to code as the condition' }
    if ($fm -notmatch '(?i)no ticket') { throw 'does not exclude work a ticket already covers' }
    if ($fm -notmatch '(?i)not for a question') { throw 'does not exclude a question' }
    $true
  }

  # `streamline/03` moved these out of the skill and into guides the configured
  # repository holds, so the pointer is now a path in the user's tree rather
  # than a sibling filename. The criterion is unchanged — the branch is reached,
  # not inlined — and the pair is checked so a pointer at a template that was
  # never written fails here instead of at the reader.
  $designFormats = [ordered]@{
    'the spec format'   = @{ template = 'configure/policies/specs.template.md';   installed = '.claude/policies/specs.md' }
    'the ticket format' = @{ template = 'configure/policies/tickets.template.md'; installed = '.claude/policies/tickets.md' }
    'the map format'    = @{ template = 'configure/policies/maps.template.md';    installed = '.claude/policies/maps.md' }
  }
  foreach ($f in $designFormats.Keys) {
    $g = $designFormats[$f]
    Assert "$f is disclosed behind a pointer, not inlined" {
      if (-not (Test-Path (Join-Path $skills $g.template))) { throw "$($g.template) is missing" }
      (Get-SkillFile 'design/SKILL.md') -match [regex]::Escape($g.installed)
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
    if (-not ((Get-SkillFile 'design/SKILL.md') -match '(?i)more than one (reasonable )?approach')) { throw 'design/SKILL.md does not match: (?i)more than one (reasonable )?approach' }
    $true
  }

  Assert "every run leaves at least one ticket on disk" {
    $c = Get-SkillFile 'design/SKILL.md'
    if (-not ($c -match '(?i)at least one ticket|always .{0,20}one ticket')) { throw 'design/SKILL.md does not match: (?i)at least one ticket|always .{0,20}one ticket' }
    if (-not ($c -match '(?i)(nothing|never) lives only in the conversation')) { throw 'design/SKILL.md does not match: (?i)(nothing|never) lives only in the conversation' }
    $true
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
    $tickets = Get-SkillFile 'configure/policies/tickets.template.md'
    $lifecycle = @('open', 'blocked', 'resolved', 'obsolete')
    $absent = $lifecycle | Where-Object { $tickets -notmatch "(?m)^$_\s" }
    if ($absent) { throw "lifecycle states undefined: $($absent -join ', ')" }
    $true
  }

  Assert "no triage role leaks into a build ticket's Status:" {
    $roles = 'needs-triage|needs-info|ready-for-agent|ready-for-human|wontfix'
    $leaked = @()
    foreach ($f in @('configure/policies/tickets.template.md', 'configure/policies/maps.template.md')) {
      foreach ($m in [regex]::Matches((Get-SkillFile $f), "(?m)^Status:\s*($roles)")) {
        $leaked += "${f}: $($m.Groups[1].Value)"
      }
    }
    if ($leaked) { throw ($leaked -join ', ') }
    $true
  }

  Assert "a re-plan marks superseded tickets obsolete — never deletes, never leaves them open" {
    $c = Get-SkillFile 'design/SKILL.md'
    if (-not ($c -match '(?i)obsolete')) { throw 'design/SKILL.md does not match: (?i)obsolete' }
    if (-not ($c -match '(?i)never deleted|not deleted')) { throw 'design/SKILL.md does not match: (?i)never deleted|not deleted' }
    $true
  }

  # "SKILL.md carries no deliverable-format detail." MAP.md is the clearest
  # test: everything about maps lives there, and SKILL.md says only that the
  # branch exists.
  Assert "SKILL.md carries no deliverable-format detail — the map vocabulary lives in MAP.md" {
    $skill = Get-SkillFile 'design/SKILL.md'
    $map = Get-SkillFile 'configure/policies/maps.template.md'
    $vocabulary = @('fog of war', 'frontier', 'destination', 'not yet specified')
    $leaked = $vocabulary | Where-Object { $skill -match [regex]::Escape($_) }
    if ($leaked) { throw "leaked into SKILL.md: $($leaked -join ', ')" }
    $absent = $vocabulary | Where-Object { $map -notmatch [regex]::Escape($_) }
    if ($absent) { throw "missing from MAP.md: $($absent -join ', ')" }
    $true
  }

  Assert "SKILL.md carries no spec-format detail — the section list lives in SPEC-FORMAT.md" {
    $skill = Get-SkillFile 'design/SKILL.md'
    $spec = Get-SkillFile 'configure/policies/specs.template.md'
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
    if (-not (Test-Path (Join-Path $skills 'implement/SKILL.md'))) { throw ('nothing at ' + (Join-Path $skills 'implement/SKILL.md')) }
    $true
  }

  # Spec, Scope: the spine is model-invoked. Not, as ticket 04 claims, so
  # /design can reach it — ticket 03 forbids exactly that. The router (10) is
  # the caller this is actually for.
  Assert "/implement is model-invoked — the spine is reachable" {
    if (-not (-not (Test-UserInvoked 'implement/SKILL.md'))) { throw 'implement/SKILL.md still satisfies Test-UserInvoked, and must not' }
    $true
  }

  # Ticket 02 deferred this criterion to here: the discipline is only real if
  # something emits proof of it. The report is the enforcement.
  Assert "step 0 is a verification report, emitted on every invocation without exception" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)verification report') { throw 'no verification report named' }
    if ($c -notmatch '(?i)every invocation|no exceptions') { throw 'the report is left conditional' }
    # Anchored to the report's own lines rather than to the word "Verification"
    # standing at the top of the block. The report gained a computed half whose
    # first line is the script's, so the literal it used to match moved out of
    # the fence while the thing being asserted — that step 0 shows a report —
    # stayed exactly as true.
    if ($c -notmatch '(?ms)^```\s*$.*?^  marker\s.*?^  mode\s.*?^```\s*$') {
      throw 'step 0 shows no verification report'
    }
    $true
  }

  # A pointer says where to start looking, never what is there. Reading source
  # through an unchecked one is how a stale belief becomes a wrong edit.
  Assert "no source is read through a Source Pointer that has not been verified this session" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if (-not ($c -match '(?i)source pointer')) { throw 'implement/SKILL.md does not match: (?i)source pointer' }
    if (-not ($c -match '(?i)before (it is |it.s )?relied on|verified this session')) { throw 'implement/SKILL.md does not match: (?i)before (it is |it.s )?relied on|verified this session' }
    $true
  }

  # A filename is not a contract. This is the half of the pointer rule that
  # bites during a build, and it is /implement's — CLAUDE.md owns recovery.
  Assert "an API is never inferred from a filename" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if (-not ($c -match '(?i)never infer an API from a filename')) { throw 'implement/SKILL.md does not match: (?i)never infer an API from a filename' }
    $true
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
    if (-not ($c -match '(?i)(claim[a-z]*).{0,60}before any work|before any work.{0,60}claim')) { throw 'implement/SKILL.md does not match: (?i)(claim[a-z]*).{0,60}before any work|before any work.{0,60}claim' }
    $true
  }

  Assert "one ticket per invocation — never a second, never a blocked one" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if (-not ($c -match '(?i)one ticket per invocation')) { throw 'implement/SKILL.md does not match: (?i)one ticket per invocation' }
    if (-not ($c -match '(?i)never (take |start )')) { throw 'implement/SKILL.md does not match: (?i)never (take |start )' }
    $true
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
    if (-not ($c -match '(?i)marker.{0,120}(every |each )amend|(every |each )amend.{0,120}marker')) { throw 'implement/SKILL.md does not match: (?i)marker.{0,120}(every |each )amend|(every |each )amend.{0,120}marker' }
    $true
  }

  # Ticket 06: "/commit is the shared implementation both paths use", and the
  # always-on rule is "Only /commit advances the Marker. Nothing else moves it."
  # A close-out that commits directly breaks that on the ticketed path.
  Assert "the close-out routes through /commit, which owns the Marker" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)(close out|closes out) through `?/commit') { throw 'the close-out does not route through /commit' }
    $c -match '(?i)/implement`?\*{0,2} never writes the Marker directly'
  }

  # ADR 0024 retired the prompt, so what used to be "resolves only when the user
  # says so" is now "resolves when /commit returns". The old assertion did not
  # fail on the change — it passed on the word "asked" occurring in an unrelated
  # sentence about further changes, which is the loose-pattern failure this file
  # warns about, found by rewriting rather than by the suite.
  Assert "a ticket resolves when /commit returns, and only /implement writes that field" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?is)close out through `?/commit`?[^.]{0,80}Status:\s*resolved') {
      throw 'resolution is not tied to /commit returning'
    }
    $c -match '(?i)shared tracker, do not'
  }

  # The prompt is gone and stays gone. Asserted as an absence *and* as the
  # reason, because an absence alone would pass on a file that simply stopped
  # describing the close-out at all.
  Assert "there is no commit prompt, and the skill says why there is not" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -match '(?i)commit and resolve this ticket\?') { throw 'the prompt is back' }
    if ($c -notmatch '(?i)without asking|no prompt') { throw 'the absence is not stated' }
    # The argument, not just the behaviour: both routes reach the same tree.
    $c -match '(?i)identical tree|same place|same tree'
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
    if (-not ($c -match '(?i)harder than expected\*{0,2} is not a wrong plan')) { throw 'implement/SKILL.md does not match: (?i)harder than expected\*{0,2} is not a wrong plan' }
    $true
  }

  Assert "a deviation that changes architecture goes back to /design, not into the diff" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if (-not ($c -match '(?i)changes architecture.{0,60}/design')) { throw 'implement/SKILL.md does not match: (?i)changes architecture.{0,60}/design' }
    $true
  }

  # ADR 0007 places these in /implement and /review both — the skill that
  # writes them and the skill that catches a breach. Ticket 13 distributes the
  # rest of that row; these two are already home and must not be placed twice.
  Assert "the comment and public-API rules ADR 0007 places here are carried" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)comments? explain \*{0,2}why') { throw 'the comment rule is missing' }
    if ($c -notmatch '(?i)public (interface|api) is documented') { throw 'the public-API rule is missing' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    $true
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
    if (-not ($c -match '(?i)resum')) { throw 'implement/SKILL.md does not match: (?i)resum' }
    if (-not ($c -match '(?i)claimed')) { throw 'implement/SKILL.md does not match: (?i)claimed' }
    $true
  }

  Assert "work with no ticket is /commit's, not /implement's" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if (-not ($c -match '(?i)(no ticket|without a ticket).{0,140}/commit')) { throw 'implement/SKILL.md does not match: (?i)(no ticket|without a ticket).{0,140}/commit' }
    $true
  }

  # matt's core, retained: the loop is the point, and the full suite runs once.
  Assert "tdd drives the build at pre-agreed seams, with the full suite once at the end" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)\btdd\b') { throw 'tdd is never invoked' }
    if ($c -notmatch '(?i)seam') { throw 'no pre-agreed seams' }
    if ($c -notmatch '(?i)typecheck') { throw 'typechecking is never run' }
    $c -match '(?i)(full|whole) suite'
  }

  # Ordering, not presence, and it survived the prompt's removal — what lands
  # must be work that has been reviewed rather than work about to be. With no
  # prompt to order against, the fixed point is the commit itself.
  Assert "/review and its fixes come before anything is committed" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $closeOut = Get-Section $c 'Close out'
    if (-not $closeOut) { throw 'there is no close-out step' }
    $review = $closeOut.IndexOf('/review')
    $commit = $closeOut.IndexOf('through `/commit`')
    if ($review -lt 0) { throw '/review is never invoked in the close-out' }
    if ($commit -lt 0) { throw 'the close-out never reaches /commit' }
    if ($review -gt $commit) { throw 'review comes after the commit' }
    # `\*{0,2}` because the word carries emphasis: the prose reads
    # "**before** anything is committed", and a pattern that assumes the two
    # words are adjacent fails on the file it was written from.
    $closeOut -match '(?i)before\*{0,2}\s+(anything is committed|it commits)'
  }

  # Context stores concepts. An implementation walkthrough in context is
  # sediment: it goes stale on the next commit and nothing points at it.
  # `streamline/03` consolidated these three into the knowledge guide, so each
  # is now asserted where it lives and the skill is checked for the route. The
  # criterion never changed — /implement writes concepts and not vocabulary —
  # only which file is answerable for saying so.
  Assert "knowledge writing is scoped to concepts and boundaries, never implementation detail" {
    $c = Get-SkillFile $knowledgeTemplate
    if ($c -notmatch '(?i)concept') { throw 'concepts are not named as what belongs' }
    if ((Get-SkillFile 'implement/SKILL.md') -notmatch '\.claude/contexts/repository\.md') { throw 'the vocabulary file is never written' }
    $c -match '(?i)(never|not).{0,60}implementation|implementation.{0,60}(never|does not)'
  }

  Assert "a change that moves no concept writes nothing — silence is the correct output" {
    if (-not ((Get-SkillFile $knowledgeTemplate) -match '(?i)silence is the correct output')) { throw ($knowledgeTemplate + ' does not match: (?i)silence is the correct output') }
    $true
  }

  # ADR 0005: vocabulary and decisions crystallise in conversation, and that
  # conversation is /design's. Read off the guide's table rather than prose —
  # the row is the statement, and a row that loses its cell fails here.
  Assert "/implement writes no vocabulary and no ADRs — those belong to /design" {
    $c = Get-SkillFile $knowledgeTemplate
    $row = [regex]::Match($c, '(?im)^\|\s*`?/implement`?\s*\|([^|\r\n]*)\|([^|\r\n]*)\|')
    if (-not $row.Success) { throw 'the knowledge guide has no row for /implement' }
    if ($row.Groups[2].Value -notmatch '(?i)vocabulary') { throw 'the prohibition is not stated' }
    if ((Get-SkillFile 'implement/SKILL.md') -notmatch [regex]::Escape('.claude/policies/knowledge.md')) {
      throw 'the skill does not reach the rule it stopped stating'
    }
    $c -match '(?i)(vocabulary|decisions?).{0,200}/design'
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
    if (-not (Test-Path (Join-Path $skills 'review/SKILL.md'))) { throw ('nothing at ' + (Join-Path $skills 'review/SKILL.md')) }
    $true
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
    if (-not (-not (Test-UserInvoked 'review/SKILL.md'))) { throw 'review/SKILL.md still satisfies Test-UserInvoked, and must not' }
    $true
  }

  # orchestration/07 moved each axis's instructions out of this file and into
  # the role the stage now dispatches by name. The guarantee is unchanged — the
  # stage still runs both axes and both still state what they report — so these
  # read the surface the behaviour lives on rather than the stage alone.
  # Checking the stage by itself would fail on text that moved exactly as the
  # ticket required, which is a guard punishing the change it asked for.
  # One axis per helper, never both. Unioning the stage with *both* roles let a
  # Standards guarantee be satisfied by the Spec role — a review proved it by
  # deleting the smell-marking rule from the stage and from
  # `standards-reviewer` and watching the assertion stay green on
  # `spec-reviewer`'s copy. That is the failure this whole block exists to
  # catch: the axes are supposed to stay apart, and a union cannot see one
  # crossing.
  $axisSurface = {
    param([string]$Role)
    $p = Join-Path $repo "agents/$Role.md"
    if (-not (Test-Path $p)) { throw "agents/$Role.md is missing — the stage dispatches a role that does not ship" }
    (Get-SkillFile 'review/SKILL.md') + "`n" + (Get-Content $p -Raw)
  }

  # The axes were `### ` headings until their content moved; what makes them two
  # axes now is that the stage names two roles and each role ships. Asserted on
  # the dispatch rather than on the layout, because the layout was never the
  # claim.
  Assert "two axes — Spec and Standards" {
    $c = Get-SkillFile 'review/SKILL.md'
    foreach ($axis in 'Spec', 'Standards') {
      # Anchored to the definition list: a bare word boundary matched "a spec
      # under .claude/designs/" and "this repository's own standards", so
      # both axis bullets could be deleted with the guard still green.
      if ($c -notmatch "(?m)^-\s+\*\*$axis\*\*") { throw "the $axis axis is not defined" }
    }
    foreach ($role in 'spec-reviewer', 'standards-reviewer') {
      if ($c -notmatch [regex]::Escape($role)) { throw "the stage does not dispatch $role" }
      if (-not (Test-Path (Join-Path $repo "agents/$role.md"))) { throw "$role does not ship" }
    }
    $true
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
    $c = & $axisSurface 'standards-reviewer'
    if (-not ($c -match '(?i)ownership boundar[a-z]+ in `?\.claude/contexts/repository\.md')) { throw '$c does not match: (?i)ownership boundar[a-z]+ in `?\.claude/contexts/repository\.md' }
    $true
  }

  Assert "architecture reaches abstraction the change did not require" {
    $c = & $axisSurface 'standards-reviewer'
    if (-not ($c -match '(?i)abstraction.{0,120}(did ?n.t|did not|does ?n.t|does not|no[t]? .{0,20}require|unnecessary)|(unnecessary|speculative).{0,40}abstraction')) { throw '$c does not match: (?i)abstraction.{0,120}(did ?n.t|did not|does ?n.t|does not|no[t]? .{0,20}require|unnecessary)|(unnecessary|speculative).{0,40}abstraction' }
    $true
  }

  # Headline acceptance criterion: "A diff contradicting an existing ADR is
  # surfaced explicitly, not silently accepted."
  Assert "a diff contradicting an ADR is surfaced explicitly, never silently accepted" {
    $c = & $axisSurface 'standards-reviewer'
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
    $c -match '\.claude/policies/decisions\.md'
  }

  Assert "acceptance is the user's call, never the reviewer's" {
    $c = Get-SkillFile 'review/SKILL.md'
    if (-not ($c -match "(?i)accept.{0,80}(user's call|user decides|never the reviewer)|the user.{0,60}accept")) { throw 'review/SKILL.md does not match: "(?i)accept.{0,80}(user''s call|user decides|never the reviewer)|the user.{0,60}accept"' }
    $true
  }

  # Decision 21. A review is about a diff; once merged its subject is gone.
  Assert "reviews are never persisted, and no skill writes a reviews directory" {
    $c = Get-SkillFile 'review/SKILL.md'
    if ($c -notmatch '(?i)never persist') { throw 'the no-persistence rule is not stated' }
    # Stating that the directory does not exist is the rule, not a breach of it.
    # Flag only a mention that reads as somewhere to write.
    $offenders = @()
    foreach ($f in Get-SkillFiles) {
      foreach ($line in ((Get-SkillText $f) -split '\r?\n')) {
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
    $c = & $axisSurface 'standards-reviewer'
    $c -match '(?i)hard violation.{0,40}judgement call|judgement call.{0,40}hard violation'
  }

  # ADR 0007 places these two here by name: "comment and public-API rules in
  # /implement and /review". They are Tenure's own, applied even where the
  # repository documents neither — so they are not covered by the repo-first
  # ordering above, and nothing else in ./skills carries them.
  Assert "the comment and public-API rules ADR 0007 places here are carried" {
    $c = & $axisSurface 'standards-reviewer'
    if ($c -notmatch '(?i)comments? explain \*{0,2}why') { throw 'the comment rule is missing' }
    if ($c -notmatch '(?i)public (interface|api)') { throw 'the public-API rule is missing' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    $true
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
    if (-not ($c -match '(?i)(never|not|do not|don.t) (merge|rerank|re-rank)|(merge|rerank|re-rank).{0,60}(defeats|masks|is the)')) { throw 'review/SKILL.md does not match: (?i)(never|not|do not|don.t) (merge|rerank|re-rank)|(merge|rerank|re-rank).{0,60}(defeats|masks|is the)' }
    $true
  }

  Assert "the Spec axis reaches missing requirements, scope creep, and wrong implementations" {
    $c = & $axisSurface 'spec-reviewer'
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
    if (-not ($c -notmatch '(?i)marker.{0,80}(==|matches|equals|is the same as).{0,40}HEAD')) { throw 'review/SKILL.md still matches what it must not: (?i)marker.{0,80}(==|matches|equals|is the same as).{0,40}HEAD' }
    $true
  }

}

# --- ticket tenure/06 — /commit, the transaction boundary ---------------------------

Describe-Ticket 'tenure/06' 'the transaction boundary' {

  Assert "/commit ships as a skill" {
    if (-not (Test-Path (Join-Path $skills 'commit/SKILL.md'))) { throw ('nothing at ' + (Join-Path $skills 'commit/SKILL.md')) }
    $true
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
    if (-not ($c -match '(?i)(no ticket|without a ticket|hand-written)')) { throw 'commit/SKILL.md does not match: (?i)(no ticket|without a ticket|hand-written)' }
    $true
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
    if ($c -notmatch '\.claude/contexts/') { throw 'Context is never read' }
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*knowledge.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'the knowledge check is not its own step' }
    $step -match '(?i)whole[- ]diff|the change entire|one ticket at a time'
  }

  Assert "a diff that contradicts Context blocks the commit until Context is corrected" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if (-not ($c -match '(?i)(contradict|disagree)[a-z]*.{0,200}(block|stop|not commit|before commit)|(block|stop)[a-z]*.{0,200}contradict')) { throw 'commit/SKILL.md does not match: (?i)(contradict|disagree)[a-z]*.{0,200}(block|stop|not commit|before commit)|(block|stop)[a-z]*.{0,200}contradict' }
    $true
  }

  # ADR 0005 leaves authorship with /implement and /design. What /commit does
  # here is healing — correcting what the diff falsified — not writing new
  # knowledge, and the boundary has to be stated or it erodes into authorship.
  # The rule moved into the knowledge guide with `streamline/03`; what stays in
  # /commit is the step that obeys it. Both ends, because "corrects what the
  # diff falsified" reads identically whether or not the authorship half
  # survived the move.
  Assert "/commit heals what the diff falsified and authors nothing new" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)blocked until Context is corrected') { throw 'the healing step is gone' }
    if ($c -notmatch [regex]::Escape('.claude/policies/knowledge.md')) { throw 'the authorship rule is not reached' }
    $guide = Get-SkillFile $knowledgeTemplate
    $row = [regex]::Match($guide, '(?im)^\|\s*`?/commit`?\s*\|([^|\r\n]*)\|([^|\r\n]*)\|')
    if (-not $row.Success) { throw 'the knowledge guide has no row for /commit' }
    $row.Groups[2].Value -match '(?i)anything new'
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

  # Decision 23: a document's reasoning is frozen; only its status moves. The
  # status became a declared field in `declared-fields/04`, so the wording moved
  # with it — and deliberately does not also accept the retired `status line`,
  # which would leave this green against the very reversion it now guards.
  Assert "a completed spec is marked implemented, and only the status field moves" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch '(?i)implemented') { throw 'the spec is never marked implemented' }
    $c -match '(?i)only the status field|content is never rewritten|reasoning is frozen'
  }

  # Cross-file: /commit writes a status SPEC-FORMAT has to recognise, and the
  # freeze rule has one home — the format file, not the actor. Before this,
  # SPEC-FORMAT listed draft/accepted/superseded and knew nothing of the status
  # /commit writes.
  Assert "the status /commit writes is one SPEC-FORMAT defines, and the freeze rule stays there" {
    $c = Get-SkillFile 'commit/SKILL.md'
    $fmt = Get-SkillFile 'configure/policies/specs.template.md'
    # Against the enumeration line, not the section. SPEC-FORMAT names
    # `implemented` again further down when saying who writes it, so a
    # section-wide check survives the term being cut from the vocabulary itself.
    $vocab = (($fmt -split '\r?\n') | Where-Object { $_ -match '`draft`' }) -join ' '
    if (-not $vocab) { throw 'SPEC-FORMAT has no status vocabulary line' }
    # Only the spec step — `Status: resolved` elsewhere in the file is a
    # *ticket* status. The scoping and its reason live in `Get-SpecStep`.
    $specStep = Get-SpecStep
    foreach ($written in [regex]::Matches($specStep, '(?i)Status:\s*([a-z-]+)')) {
      $s = $written.Groups[1].Value
      if ($vocab -notmatch "``$s``") { throw "/commit writes Status: $s, which SPEC-FORMAT does not define" }
    }
    if ($fmt -notmatch '(?i)only the status field') { throw 'the freeze rule is not in SPEC-FORMAT' }
    if ($c -notmatch '\.claude/policies/specs\.md') { throw '/commit does not point at the format' }
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
  # define. The *path* is not: fieldwork/05 moved its single home to the git
  # reference, and the writer reaches it by pointer while keeping the payload.
  Assert "the Marker's shape is defined, since /commit is its only writer" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if (-not ($c -match '(?ms)^```\s*json\s*$.*?commit.*?^```\s*$')) { throw 'commit/SKILL.md does not match: (?ms)^```\s*json\s*$.*?commit.*?^```\s*$' }
    $true
  }

  # A Marker that is not ignored gets committed, and then it points at the
  # parent of the commit it describes — the phantom-verification loop ADR 0005
  # made the file machine-local to avoid.
  Assert "the Marker is confirmed gitignored before it is written" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if (-not ($c -match '(?i)(ignored|gitignore).{0,200}(before|check|confirm)|(before|check|confirm)[a-z]*.{0,200}(ignored|gitignore)')) { throw 'commit/SKILL.md does not match: (?i)(ignored|gitignore).{0,200}(before|check|confirm)|(before|check|confirm)[a-z]*.{0,200}(ignored|gitignore)' }
    $true
  }

  # Acceptance: "The Marker equals HEAD after a successful commit, so the next
  # verification is a single git check and nothing more."
  Assert "the Marker equals HEAD after a successful commit" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if (-not ($c -match '(?i)marker.{0,120}(==|equals|matches).{0,40}HEAD|HEAD.{0,40}(==|equals|matches).{0,120}marker')) { throw 'commit/SKILL.md does not match: (?i)marker.{0,120}(==|equals|matches).{0,40}HEAD|HEAD.{0,40}(==|equals|matches).{0,120}marker' }
    $true
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
    if (-not ($c -match '(?i)(does not|never) (resolve|set).{0,80}(ticket|status: resolved)|resolv[a-z]*.{0,80}(stays|remains|is) /implement')) { throw 'commit/SKILL.md does not match: (?i)(does not|never) (resolve|set).{0,80}(ticket|status: resolved)|resolv[a-z]*.{0,80}(stays|remains|is) /implement' }
    $true
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
      if (-not (Test-Path (Join-Path $skills "$s/SKILL.md"))) { throw ('nothing at ' + (Join-Path $skills "$s/SKILL.md")) }
      $true
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

  # orchestration/07 moved the source discipline into the `researcher` role the
  # stage dispatches, so the surface is the stage plus that one role — not the
  # stage alone, which would fail on the move, and not every role, which would
  # let another role's text stand in for this one's.
  Assert "primary sources only — a secondary write-up is rejected, not just named" {
    $role = Join-Path $repo 'agents/researcher.md'
    if (-not (Test-Path $role)) { throw 'the role /research dispatches does not ship' }
    $c = (Get-SkillFile 'research/SKILL.md') + "`n" + (Get-Content $role -Raw)
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
  # In the evidence guide since `streamline/03`, alongside /prototype's reason —
  # which is a different argument for the same rule, and was the half most
  # likely to be dropped when the two were merged. Both are asserted.
  Assert "the reason /research never writes Context is given, not just the rule" {
    $c = Get-SkillFile $evidenceTemplate
    if ($c -notmatch '(?i)true of the thing that was built') { throw "the prototype's own reason was lost in the merge" }
    $c -match '(?i)version[^\n]{0,160}(layer|context)[^\n]{0,80}no version|no version[^\n]{0,160}re-verify'
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
    if ($table -notmatch '`\.claude/position/prototypes/') { throw 'the code location is wrong or missing' }
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

  Assert "the throwaway-code directory is gitignored scratch" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    # Bound to the directory. `.claude/.gitignore` is named in the same
    # paragraph, so a bare `gitignor` match survives the rule being cut.
    if (-not ($c -match '(?i)`\.claude/position/prototypes/`[^\n]{0,40}\*{0,2}gitignored')) { throw 'prototype/SKILL.md does not match: (?i)`\.claude/position/prototypes/`[^\n]{0,40}\*{0,2}gitignored' }
    $true
  }

  # The ordering is the whole mechanism: deleting code that took real effort is
  # resisted in the moment, and the discipline holds only because the write-up
  # comes first.
  Assert "the write-up is written before the code is deleted" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    if (-not ($c -match '(?i)(written|write it|record[a-z]*)[^.]{0,80}before[^.]{0,60}delet|not finished until')) { throw 'prototype/SKILL.md does not match: (?i)(written|write it|record[a-z]*)[^.]{0,80}before[^.]{0,60}delet|not finished until' }
    $true
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
    if (-not ($c -match '(?i)reuse[^.]{0,120}write-?up')) { throw 'prototype/SKILL.md does not match: (?i)reuse[^.]{0,120}write-?up' }
    $true
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
      if ($c -match '(?i)owns (that )?graduation') { throw 'the graduation rule is restated here' }
      if ($c -notmatch '(?i)never write Context directly') { throw 'the boundary is not stated' }
      # `streamline/03` moved the destination out of this skill and into the
      # guide, so what stays here is the route. Checked against the guide too:
      # a route at a file that dropped the rule is the same dead end as no route.
      if ((Get-SkillFile $evidenceTemplate) -notmatch '(?i)owns (that )?graduation') {
        throw 'the guide this points at no longer holds the rule'
      }
      $c -match [regex]::Escape('.claude/policies/evidence.md')
    }
  }

  # matt's originals end by committing the prototype to a throwaway branch and
  # leaving a pointer to it — a primary source to come back to. ADR 0009 says
  # the opposite and wins: the code is deleted, and the write-up is the artifact.
  # Vendoring this unaltered is the failure the alteration checklist exists for.
  Assert "no prototype file keeps the code on a branch — ADR 0009 supersedes that" {
    $offenders = @()
    foreach ($f in (Get-ChildItem (Join-Path $skills 'prototype') -File -Filter *.md)) {
      foreach ($line in ((Get-SkillText $f) -split '\r?\n')) {
        if ($line -match '(?i)(throwaway|prototype) branch|branch.{0,40}primary source') {
          $offenders += "$($f.Name): $($line.Trim())"
        }
      }
    }
    if ($offenders) { throw ($offenders -join '; ') }
    $true
  }

}

# --- ticket tenure/09 — the gap-fillers, and the tracker's one home -----------------

Describe-Ticket 'tenure/09' 'vendor the gap-fillers' {

  $onramps = @('triage', 'diagnosing-bugs', 'handoff', 'resolving-merge-conflicts',
               'survey')

  foreach ($s in $onramps) {
    Assert "$s is vendored into ./skills" {
      if (-not (Test-Path (Join-Path $skills "$s/SKILL.md"))) { throw ('nothing at ' + (Join-Path $skills "$s/SKILL.md")) }
      $true
    }
  }

  # Alteration checklist item 3. Kept from matt's, because his axes already
  # satisfy the rule. The test that decides the axis is stated in
  # `.claude/contexts/skill-authoring.md` and deliberately not restated here —
  # it was recorded only in this comment until entry/01 gave it a home.
  # ADR 0063 moved `triage` and `survey` onto the selected side, leaving `handoff`
  # as the only on-ramp a human types. What separates it is not how expensive it
  # is but what it acts on — the conversation rather than the repository — so no
  # description of a repository problem could select it correctly.
  $axis = @{
    'triage'                        = $false
    'handoff'                       = $true
    'survey'                        = $false
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


  # --- the tracker's one home ------------------------------------------------

  # Acceptance: "The issue-tracker configuration has exactly one home, and every
  # skill reading it agrees." /configure writes the file; ticket 09 places the
  # template, exactly as tenure/02 placed CLAUDE.template.md before tenure/08.
  Assert "the tracker template ships, and names $trackerPolicy as its home" {
    $t = Get-SkillFile 'configure/policies/tracker.template.md'
    if (-not ($t -match [regex]::Escape($trackerPolicy))) { throw 'configure/policies/tracker.template.md does not match: [regex]::Escape($trackerPolicy)' }
    $true
  }

  # Decision 35: GitHub and local markdown are both first-class. A template
  # that documents one and mentions the other is not two first-class trackers.
  Assert "both trackers are first-class — GitHub and local markdown" {
    $t = Get-SkillFile 'configure/policies/tracker.template.md'
    if ($t -notmatch '(?i)github') { throw 'GitHub is not covered' }
    if ($t -notmatch '(?i)local markdown') { throw 'local markdown is not covered' }
    if ($t -notmatch '\.claude/tickets/') { throw 'the local ticket location is not given' }
    $t -match '(?i)both[^\n]{0,80}first-class|first-class[^\n]{0,80}both'
  }

  # Decision 34 / alteration checklist item 4: the commands are in tools/, and
  # a guessed `gh` flag here is the duplication ticket 15 exists to stop.
  Assert "tracker operations point at tools/github.md rather than inlining gh" {
    $t = Get-SkillFile 'configure/policies/tracker.template.md'
    if ($t -notmatch '.claude/tools/github.md') { throw 'the gh reference is missing or guessed' }
    # Ticket 09 says `tools/gh.md`; the file ticket 15 shipped is github.md.
    if ($t -match '\.claude/tools/gh\.md') { throw 'points at .claude/tools/gh.md, which does not exist' }
    $true
  }

  # Ticket 09: "Triage label vocabulary folds into the same file rather than
  # getting one of its own."
  Assert "the triage label vocabulary lives in the tracker file, not its own" {
    $t = Get-SkillFile 'configure/policies/tracker.template.md'
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

  Assert "every skill that reads tracker config reads $trackerPolicy" {
    # Ticket 09 names three readers. Listing only the one that happens to
    # comply makes the assertion pass *because* of the gap it should catch.
    # /design's half is ticket 14's (its Comments say so); /implement is 09's.
    # /design's half landed in ticket 14, which is why it is here now: the
    # criterion passed on a two-name list while the third named reader had
    # nothing.
    $readers = @('triage/SKILL.md', 'implement/SKILL.md', 'configure/policies/tickets.template.md')
    foreach ($r in $readers) {
      $c = Get-SkillFile $r
      if ($c -notmatch [regex]::Escape($trackerPolicy)) { throw "$r does not read the tracker config" }
      # Naming the file once in passing is not reading it as the source. It has
      # to be the only place, or a skill infers the half it did not look up.
      if ($c -notmatch ([regex]::Escape($trackerPolicy) + '[^\n]{0,200}(?i:only place|one home|read it first)')) {
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
    if ($c -notmatch '\.claude/contexts/map\.md') { throw 'the routing table is never read' }
    $c -match '(?i)routing table|\.claude/contexts/'
  }

  # --- handoff ---------------------------------------------------------------

  Assert "a handoff is written outside the workspace" {
    $c = Get-SkillFile 'handoff/SKILL.md'
    if (-not ($c -match '(?i)(temp|temporary)[^\n]{0,60}director|not[^\n]{0,40}(workspace|repository)')) { throw 'handoff/SKILL.md does not match: (?i)(temp|temporary)[^\n]{0,60}director|not[^\n]{0,40}(workspace|repository)' }
    $true
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
    if (-not ($c -match '(?i)redact')) { throw 'handoff/SKILL.md does not match: (?i)redact' }
    $true
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
    if (-not (Test-Path (Join-Path $skills $cfg))) { throw ('nothing at ' + (Join-Path $skills $cfg)) }
    $true
  }

  Assert "/configure is user-invoked — a repository joins Tenure because the user asked" {
    if (-not (Test-UserInvoked $cfg)) { throw ($cfg + ' does not declare disable-model-invocation: true, so the model can select it') }
    $true
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

  # Path-relative from `configure/`, because `streamline/03` moved the policy
  # templates into a subdirectory and the link in the skill has to match. The
  # link is what a reader follows, so checking the bare filename would pass on a
  # link that resolves nowhere.
  foreach ($t in @('CLAUDE.template.md', 'protocol.template.md',
                   'precedence.template.md', 'engineering.template.md', 'placement.template.md',
                   'policies/tracker.template.md', 'policies/version-control.template.md')) {
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
      'greenfield'          = '(?i)no AEP[^|]*no (AI )?workflow'
      'another AI workflow' = '(?i)no AEP[^|]*another'
      'AEP already here'    = '(?i)AEP already'
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
    if (-not ($s -match '(?i)before (touching|changing|writing|moving) anything|nothing is (touched|moved|written) (until|before)')) { throw ($cfg + ' does not match: (?i)before (touching|changing|writing|moving) anything|nothing is (touched|moved|written) (until|before)') }
    $true
  }

  # "No documentation is deleted without appearing in the confirmed plan."
  # Negated and in the plan step: MIGRATION.md's classification table says
  # temporary notes are "discarded, and named in the plan first", which satisfies
  # any loose deleted-near-plan pattern while the rule itself is gone.
  Assert "nothing is deleted that did not appear in the confirmed plan" {
    $s = Get-Section (Get-SkillFile $cfg) 'Plan'
    if (-not ($s -match '(?is)\b(nothing|never|no)\b[^.]{0,60}delet[^.]{0,80}(confirmed|approved) plan')) { throw ($cfg + ' does not match: (?is)\b(nothing|never|no)\b[^.]{0,60}delet[^.]{0,80}(confirmed|approved) plan') }
    $true
  }

  # --- migration ------------------------------------------------------------

  # Each legacy path names the target it converts to.
  $conversions = [ordered]@{
    'CONTEXT\.md'     = '\.claude/contexts/repository\.md'
    'CONTEXT-MAP\.md' = '(\.claude/contexts/|deleted)'
    'docs/adr/'       = '\.claude/decisions/'
    'docs/agents/'    = '(CLAUDE\.md|\.claude/)'
    '\.scratch/'      = '\.claude/tickets/'
    # layout/01. The one row whose source is Tenure's own superseded layout;
    # it belongs here because the sweep below derives its candidate list from
    # this table, and a legacy path the exempt files name without converting
    # is exactly what that sweep exists to catch.
    '\.claude/docs/'  = '(\.claude/(decisions|designs|evidence)/|deleted)'
    # ADR 0059. Same kind as the row above — this workflow's own superseded
    # layout — and the target carries an effort segment, so neither pattern can
    # match the other and the row cannot satisfy itself.
    '\.claude/tickets/map\.md' = '<effort>/map\.md'
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
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
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
    $s = Get-Section (Get-MigrationText) 'pointer'
    if (-not ($s -match '(?is)leave[^.]{0,60}pointer[^.]{0,60}old path[^.]{0,60}broken link')) { throw '$s does not match: (?is)leave[^.]{0,60}pointer[^.]{0,60}old path[^.]{0,60}broken link' }
    $true
  }

  # --- generate -------------------------------------------------------------

  # /configure writes context.md; domain-modeling owns its shape. Restating the
  # format here is the duplication this framework exists to prevent, and the
  # copy that drifts would be the one a fresh repository is generated from.
  Assert "the context format is reached by pointer to its guide, never restated" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch 'policies/context\.template\.md') { throw 'the format is not pointed at' }
    if ($c -match '(?i)_Avoid_') { throw 'the context format is restated here' }
    $true
  }

  # ADR 0007 moved the compression test to CLAUDE.md in ticket 13. /configure
  # is the biggest single writer of Context, so a pointer at the old owner
  # sends the highest-volume caller to a file that forwards on.
  Assert "the compression test is cited where it lives, not where it used to" {
    $c = Get-SkillFile $cfg
    if (-not ($c -match '(?is)compression test[^.]{0,60}`CLAUDE\.md`')) { throw ($cfg + ' does not match: (?is)compression test[^.]{0,60}`CLAUDE\.md`') }
    $true
  }

  Assert "CLAUDE.md is written from the template, and the user's existing sections survive" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch 'CLAUDE\.template\.md') { throw 'the template is not used' }
    $c -match '(?i)(preserve|keep|leave)[^\r\n]{0,100}(existing|user''s own) section'
  }

  Assert "repo-discovered standards are emitted as path-scoped .claude/rules/*.md" {
    $c = Get-SkillFile $cfg
    if (-not ($c -match '\.claude/rules/')) { throw ($cfg + ' does not match: \.claude/rules/') }
    if (-not ($c -match '(?i)path-scoped|scoped to')) { throw ($cfg + ' does not match: (?i)path-scoped|scoped to') }
    $true
  }

  # The mapping, not the word "remote". And the ambiguous case explicitly: a
  # repository with several remotes is the one where guessing looks reasonable.
  Assert "the tracker is chosen from the remote, and asked for when that is ambiguous" {
    $c = Get-SkillFile $cfg
    if ($c -notmatch [regex]::Escape($trackerPolicy)) { throw 'the tracker config is never written' }
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
    foreach ($entry in @('/position/', 'settings\.local\.json')) {
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
    $missing = @('decisions/', 'designs/', 'evidence/', 'tickets/', 'position/') |
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

  # Was "/help is user-invoked — it is the human's index". ADR 0063 crossed it:
  # the index became an explanation once routing moved to the boot tier, and a
  # question about the workflow is a description like any other. What the
  # criterion was protecting — that nothing *else* loads it as a router — is now
  # held by axis/02's exclusion assertion instead.
  Assert "/help is model-invoked — asking how the workflow is used reaches it" {
    if (Test-UserInvoked $router) { throw 'still withheld from selection' }
    $true
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

  $tickets = 'configure/policies/tickets.template.md'
  $map     = 'configure/policies/maps.template.md'
  $tracker = 'configure/policies/tracker.template.md'

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
    if (-not ($c -match '(?is)scan the set[^.]{0,160}(stray|edgeless|neither the root)')) { throw ($tickets + ' does not match: (?is)scan the set[^.]{0,160}(stray|edgeless|neither the root)') }
    $true
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
  # Named *and* used to branch. A single mention passed while every lifecycle
  # instruction below it stayed local-markdown-only, which is the half that
  # actually makes GitHub a second-class tracker.
  #
  # `declared-fields/08` turned the local form into frontmatter, so the anchor
  # moved off the retired `Status:` token and onto the property: the format says
  # which form is local-markdown's, and says what the forge does instead. The
  # window crosses sentences because those two facts are two sentences.
  $trackerReaders = [ordered]@{
    $tickets = '(?is)local[- ]markdown form.{0,400}on GitHub'
    $map     = '(?i)Record it:[^\r\n]{0,240}(tracker\.md|on GitHub|label)'
  }
  foreach ($f in $trackerReaders.Keys) {
    $branch = $trackerReaders[$f]
    Assert "$f reads $trackerPolicy rather than assuming local markdown" {
      $c = Get-SkillFile $f
      if ($c -notmatch [regex]::Escape($trackerPolicy)) { throw 'the config is never named' }
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
    if (-not ($s -match '(?i)one-line reason')) { throw ($tickets + ' does not match: (?i)one-line reason') }
    if (-not ($s -match '(?i)never delet')) { throw ($tickets + ' does not match: (?i)never delet') }
    $true
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

  # ADR 0007 placed the conventions in CLAUDE.md; aep/09 slice 2 moved the
  # defaults themselves into the version-control policy, leaving the entrypoint
  # the defaults-not-mandates umbrella. The PR body shape moved with them, and
  # the covers list is read from spec section 23 rather than hard-coded, per
  # aep/10 — amending the spec's list fails this until the policy follows.
  Assert "a PR description covers what section 23 lists, and never a commit-by-commit account" {
    $spec = Get-Content (Join-Path $repo 'specs.md') -Raw
    $m = [regex]::Match($spec, '(?i)PR descriptions cover ([^—]+)—')
    if (-not $m.Success) { throw 'spec section 23 no longer states the PR description defaults' }
    $covers = @($m.Groups[1].Value -split ',| and ' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    if ($covers.Count -lt 4) { throw "section 23 lists only $($covers.Count) items" }
    $c = Get-SkillFile 'configure/policies/version-control.template.md'
    $missing = $covers | Where-Object { $c -notmatch "(?i)$([regex]::Escape($_))" }
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
    # Moved to the rules tier by `streamline/02`, still always-on. The file each
    # names is the point of the accounting: a principle that drifts to a
    # pointer-read guide fails here rather than going quiet.
    '04 verify before claiming'              = @{ file = $engineeringTemplate
                                                  pattern = '(?is)before any repository-specific claim.{0,400}names are not proof' }
    '05 never guess an API'                  = @{ file = $engineeringTemplate; pattern = '(?i)never guess an API' }
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
    '18 the user owns decisions'             = @{ file = $engineeringTemplate; pattern = '(?i)never silently decid' }
  }
  foreach ($principle in $placed.Keys) {
    $where = $placed[$principle]
    Assert "principle $principle is placed in $($where.file)" {
      if (-not ((Get-SkillFile $where.file) -match $where.pattern)) { throw ($where + ' does not match: $where.pattern') }
      $true
    }
  }

  # /implement points at a *section* of codebase-design. A pointer at a heading
  # that does not exist is a broken Source Pointer, which is the failure this
  # framework spends most of its always-on budget preventing.
  Assert "the section /implement points at exists in codebase-design" {
    if (-not ((Get-SkillFile 'codebase-design/SKILL.md') -match '(?m)^## Files and names\s*$')) { throw 'codebase-design/SKILL.md does not match: (?m)^## Files and names\s*$' }
    $true
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
    if (-not ($c -match '(?im)^\|[^|\r\n]*\|\s*Express\s*\|')) { throw 'design/SKILL.md does not match: (?im)^\|[^|\r\n]*\|\s*Express\s*\|' }
    if (-not ($c -match '(?im)^\|[^|\r\n]*\|\s*Heavyweight\s*\|')) { throw 'design/SKILL.md does not match: (?im)^\|[^|\r\n]*\|\s*Heavyweight\s*\|' }
    if (-not ($c -match '(?i)only raise[^\r\n]{0,20}never lower')) { throw 'design/SKILL.md does not match: (?i)only raise[^\r\n]{0,20}never lower' }
    $true
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
       route       = '(?i)\*\*Read the code\.\*\*[^\r\n]{0,80}`\.claude/rules/engineering\.md`' }
    @{ f = 'research/SKILL.md';  rule = 'never guess an API'
       restatement = $rulePattern['the tools routing rule']
       route       = '(?i)a CLI counts[^\r\n]{0,80}`\.claude/rules/engineering\.md`' }
    @{ f = 'implement/SKILL.md'; rule = 'never guess an API'
       restatement = $rulePattern['the tools routing rule']
       route       = '(?is)guessing an API is in `\.claude/rules/engineering\.md`.{0,200}version.{0,40}signature.{0,40}limits' }
    @{ f = 'implement/SKILL.md'; rule = 'files and names'
       restatement = $rulePattern['one concept per file']
       route       = '(?i)`codebase-design`[^\r\n]{0,120}Files and names' }
    @{ f = 'configure/TOOLS.md'; rule = 'never guess an API'
       restatement = $rulePattern['never guess an API']
       route       = '(?i)never-guess rule in `\.claude/rules/engineering\.md`' }
    @{ f = 'commit/SKILL.md';    rule = 'conventions are defaults'
       restatement = $rulePattern['conventions are defaults']
       route       = '(?i)`\.claude/policies/version-control\.md` carries the convention' }
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
  # Reads the precedence template since `streamline/02`: the ladder is what
  # ranks `.claude/rules/`, so the sentence placing rules in it travelled with
  # the ranking rather than staying behind in the entrypoint.
  Assert "a standard discovered in this repository is placed in .claude/rules/, path-scoped" {
    $c = Get-SkillFile $precedenceTemplate
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
    $lines = (Get-SkillFile $precedenceTemplate) -split '\r?\n'
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
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
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
  #
  # `streamline/02` changed what the far end has to say. It used to be "only
  # Tenure's skills read this"; ADR 0022 replaced that with the property that
  # actually matters — the file is pointer-read rather than always-on, which is
  # why it is cheap, and it is committed, so a reader without the plugin follows
  # the same pointer to it.
  Assert "each half names the other and says why the split exists" {
    $claude = Get-SkillFile $claudeTemplate
    $protocol = Get-SkillFile $protocolTemplate
    if ($claude -notmatch '\.claude/protocol\.md') { throw 'CLAUDE.md never points at the protocol' }
    if ($claude -notmatch '(?i)with or without|plugin or not|either way') {
      throw 'CLAUDE.md never says why it is the half that holds universally'
    }
    if ($protocol -notmatch 'CLAUDE\.md') { throw 'the protocol never names the file it split from' }
    if ($protocol -notmatch '(?i)reached by pointer|pointer-read') {
      throw 'the protocol never says how it is reached, which is the whole reason it is not a rule'
    }
    $true
  }

  # Criterion 3, and ADR 0007's consequence held visibly. A rule inside the
  # moved file fires only when a Tenure skill runs — correct for machinery,
  # a silent failure for anything unconditional. `$rulePattern` is the set
  # ticket 13 placed in `CLAUDE.md` precisely because it must always hold.
  Assert "no rule that must hold on every turn moved into the protocol file" {
    $c = Get-SkillFile $protocolTemplate
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
    $c = Get-SkillFile $protocolTemplate
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
    $c = Get-SkillFile $protocolTemplate
    if ($c -notmatch '(?i)nothing shared may depend on it') { throw 'the invariant is never stated' }
    $c -match '(?i)delete[^\r\n]{0,120}(no other person|no other clone)'
  }

  # Criterion 5. All of them or none: `/configure` writing only the entrypoint
  # leaves every pointer in it dangling, and writing only what it points at
  # leaves nothing loading any of it. `streamline/02` widened this from two
  # files to four, which is why the phrasing it accepts had to widen too — the
  # old `both or neither` would now be a *wrong* promise rather than a partial
  # one, since there are no longer two halves to write.
  Assert "/configure writes the whole always-on set, and says they go together" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -notmatch 'protocol\.template\.md') { throw 'the protocol template is never installed' }
    if ($c -notmatch '\.claude/protocol\.md') { throw 'the destination is never named' }
    $c -match '(?i)(whole set or none|all of (them|it) or none)'
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
      if ($c -notmatch '\.claude/protocol\.md') { throw 'still pointed at the always-on file, or nowhere' }
      $true
    }
  }
}

# --- ticket tenure/17 — assignment, and the branch as the lock ----------------------

Describe-Ticket 'tenure/17' 'assignment, claim, and the branch as the lock' {

  $imp = 'implement/SKILL.md'
  $tix = 'configure/policies/tickets.template.md'

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
    if (-not ($c -match '(?i)partial commit exists[^\r\n]{0,80}keep the branch')) { throw ($imp + ' does not match: (?i)partial commit exists[^\r\n]{0,80}keep the branch') }
    $true
  }
}

# --- ticket tenure/18 — what tenure may write to a shared tracker -------------------

Describe-Ticket 'tenure/18' 'what tenure may write to a tracker other people read' {

  $gh  = 'configure/tools/github.md'
  $tix = 'configure/policies/tickets.template.md'

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
    if ($c -notmatch '(?i)merge resolves the ticket, not AEP') { throw 'the rule is not stated' }
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
    $s -match "(?i)name is still AEP'?s"
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
    $entry = @($m.plugins | Where-Object { $_.name -eq 'aep' })
    if ($entry.Count -ne 1) { throw 'the marketplace does not publish exactly one aep plugin' }
    if (-not $entry[0].source) { throw 'the plugin entry has no source' }
    $true
  }

  # The plugin's own manifest, and the `name` that becomes the command
  # namespace — every command in the framework is typed through it, so it is
  # the one string here that cannot drift.
  Assert "the plugin manifest names the namespace every command is typed through" {
    $p = & $readJson '.claude-plugin/plugin.json'
    # Case-sensitive: `-ne` is not, and the namespace is a literal string that
    # ends up in every command the user types. `AEP` is a different plugin.
    if ($p.name -cne 'aep') { throw "the namespace is '$($p.name)', not 'aep'" }
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
    $src = @($m.plugins | Where-Object { $_.name -eq 'aep' })[0].source
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
             @('CLAUDE.md', '.claude/contexts/repository.md', 'README.md' | ForEach-Object { Get-Item (Join-Path $repo $_) })
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
    'configure/policies/decisions.template.md' = '\.claude/decisions/'
    'configure/policies/specs.template.md'         = '\.claude/designs/'
    'research/SKILL.md'             = '\.claude/evidence/research/'
    'prototype/SKILL.md'            = '\.claude/evidence/prototypes/'
    'triage/OUT-OF-SCOPE.md'        = '\.claude/evidence/out-of-scope/'
  }
  foreach ($file in $homes.Keys) {
    $path = $homes[$file]
    Assert "$file writes to $($path -replace '\\','')" {
      if (-not ((Get-SkillFile $file) -match $path)) { throw ($file + ' does not match: $path') }
      $true
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
    if ($entries -notcontains '/position/') {
      throw "unanchored — would also ignore evidence/prototypes/: $($entries -join ', ')"
    }
    $true
  }

  # The consequence ADR 0018 names: throwaway prototype code and the write-up
  # stop being one word apart at the same depth with opposite gitignore status.
  # Both halves — asserting only the move leaves the code silently relocated.
  Assert "prototype code stays at .claude/prototypes/ while the write-up moves under evidence/" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    if ($c -notmatch '\.claude/position/prototypes/') { throw 'the throwaway-code location is gone' }
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
    $adr = Get-SkillFile 'configure/policies/decisions.template.md'
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
    if (-not ($mig -match '\.claude/policies/decisions\.md')) { throw 'configure/MIGRATION.md does not match: \.claude/policies/decisions\.md' }
    $true
  }

  # The layout migration's risk is the opposite of the mattpocock migration's:
  # not a wrong classification, but a reference left pointing at a directory
  # that is gone. A page that converts files and never repairs what named them
  # leaves the repository half-migrated and passing.
  Assert "the migration repairs what pointed at the old locations" {
    $mig = Get-SkillFile 'configure/MIGRATION.md'
    if (-not ($mig -match '(?is)(Source Pointer|referenc)[^.]{0,300}(broken|update|repair)')) { throw 'configure/MIGRATION.md does not match: (?is)(Source Pointer|referenc)[^.]{0,300}(broken|update|repair)' }
    $true
  }

  # /configure has to *find* a repository on the old layout, or the branch it
  # gained is unreachable. Scoped to the detect step for ticket tenure/08's
  # reason: MIGRATION.md names the path too, as something it converts, so a
  # file-wide search passes while nothing ever looks for it.
  Assert "detection finds a Tenure repository still on the superseded layout" {
    $s = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Detect'
    if (-not ($s -match '\.claude/docs/')) { throw 'configure/SKILL.md does not match: \.claude/docs/' }
    $true
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
    # `map.md` is the generated index (mechanics/12), not a Decision — it is
    # deliberately unnumbered, and counting it would also break the contiguity
    # check below by one.
    $adrs = Get-ChildItem (Join-Path $repo '.claude/decisions') -Filter '*.md' |
      Where-Object { $_.Name -ne 'map.md' } | Sort-Object Name
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
  $navigational = @('CLAUDE.md', 'README.md', '.claude/contexts/map.md', '.claude/contexts/repository.md', '.claude/contexts/skill-authoring.md')
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
    $files = Get-ChildItem (Join-Path $repo '.claude/contexts') -Recurse -Filter '*.md' | ForEach-Object FullName
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
    $table = Get-RepoFile '.claude/contexts/map.md'
    $files = Get-ChildItem (Join-Path $repo '.claude/contexts') -Recurse -Filter '*.md' |
      Where-Object { $_.Name -ne 'map.md' } |
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
    if (-not ($s -match '(?is)single-file test command[^.]{0,120}(must not be missing|not be missing)')) { throw 'configure/SKILL.md does not match: (?is)single-file test command[^.]{0,120}(must not be missing|not be missing)' }
    $true
  }

  # Criterion 5. The gap this whole ticket exists to close: the always-on file
  # used to admit that the workflow's reference existed only with the plugin,
  # in the same breath as forbidding a guessed CLI.
  # Follows the rule rather than the file: `streamline/02` moved the never-guess
  # standard into the rules tier, and it is still always-on there.
  Assert "the always-on template no longer conditions the tool reference on the plugin" {
    $c = Get-SkillFile $engineeringTemplate
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
      $c = Get-SkillText $f
      if ($c -notmatch '(?m)^Derived from:\s*aep/(\S+\.md)\s*$') { continue }
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
  foreach ($derived in @('git.md', 'github.md', 'graphite.md')) {
    Assert "$derived names the shipped entry it was derived from" {
      $c = Get-RepoText ".claude/tools/$derived"
      if ($c -notmatch "(?m)^Derived from:\s*aep/$([regex]::Escape($derived))\s*$") {
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
  # `.claude/rules/` is included from `streamline/01` on: it is loaded by the
  # harness, so a broken tool pointer there is one Claude reads without ever
  # following a link. The top-level scan alone would not have seen it.
  Assert "every tools/ pointer in this repository's knowledge resolves" {
    $files = @('CLAUDE.md', 'README.md') +
             (Get-ChildItem (Join-Path $repo '.claude') -Filter '*.md' |
               ForEach-Object { ".claude/$($_.Name)" }) +
             (Get-RuleFiles)
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
      foreach ($m in [regex]::Matches((Get-SkillText $f), '\]\((?!https?:|#)([a-z0-9.-]+\.md)\)')) {
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
    } else {
      # The exemption note dies with the exemption — a preamble still claiming
      # the link dangles is drift from the moment graphite.md is derived.
      $preamble = ((Get-RepoText '.claude/tools/git.md') -split '(?m)^##\s')[0]
      if ($preamble -match '(?i)points at nothing|no reason to derive') {
        throw 'git.md still documents a dangling link that now resolves'
      }
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

  # `streamline/01` moved the never-guess rule out of `CLAUDE.md` into an
  # unscoped rule file, so this guard moved with it rather than being relaxed:
  # a check still pointed at the old home would pass on a stale copy and fail
  # on the real one. What the criterion demands is that the claim is reachable
  # without a pointer being followed, which is the always-on set — not one
  # named file — so the set is what is searched, and it must hold exactly once.
  Assert "the always-on set states that one committed directory covers every tool, exactly once" {
    $homes = @(Get-AlwaysOnFiles | Where-Object { (Get-RepoText $_) -match '(?i)covers every tool this repository uses' })
    if ($homes.Count -eq 0) { throw 'the replacement claim is not stated in anything loaded unconditionally' }
    if ($homes.Count -gt 1) { throw "stated in more than one always-on home: $($homes -join ', ')" }
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

  $vcTemplate = 'configure/policies/version-control.template.md'
  $trackerTemplate = 'configure/policies/tracker.template.md'

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
    if ($s -notmatch '`\.claude/rules/engineering\.md`') { throw 'does not reach the standing rule at all' }
    if ($s -match '(?i)cannot undo locally') { throw "restates the never-push rule verbatim" }
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
  foreach ($policy in @($trackerPolicy, $vcPolicy)) {
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
    Get-RepoText '.claude/policies/version-control.md' | Out-Null
    $true
  }

  # One per section, for the reason `layout/05` gives about the template: a
  # single assertion demanding all four goes green the moment the first one it
  # reaches is restored.
  foreach ($section in @('Which model', 'Branch naming', 'Commit discipline', 'How work lands')) {
    Assert "the policy file answers: $section" {
      Get-Section (Get-RepoText '.claude/policies/version-control.md') $section | Out-Null
      $true
    }
  }

  # The statement is only worth having while it is true, and this is the same
  # read the file itself prescribes. A repository that adopted a stacking tool
  # and did not heal the file fails here rather than misleading the next run.
  Assert "the stated model still matches the repository" {
    $stated = Get-Section (Get-RepoText '.claude/policies/version-control.md') 'Which model'
    $stacked = Test-Path (Join-Path $repo '.git/.graphite_repo_config')
    if ($stacked -and $stated -notmatch '(?im)^\*\*Stacked changes\.\*\*') { throw 'a stack is initialised here and the file says otherwise' }
    if (-not $stacked -and $stated -notmatch '(?im)^\*\*Plain git\.\*\*') { throw 'no stack is initialised here and the file does not say plain git' }
    $true
  }

  # Criterion 1's fourth item: pointed at, never restated, because the rule
  # must hold unconditionally. Both directions, so it cannot relax into a copy.
  #
  # `streamline/01` moved the never-push rule from `CLAUDE.md` into an unscoped
  # rule file. The guard follows it, and is strengthened while it is being
  # touched: the old form matched the literal string `CLAUDE.md`, which would
  # have stayed green against a pointer at a file that no longer held the rule.
  # This resolves the pointer instead — the named file must exist and must
  # actually state the rule.
  Assert "the landing section reaches the standing rule rather than restating it" {
    $s = Get-Section (Get-RepoText '.claude/policies/version-control.md') 'How work lands'
    if ($s -match '(?i)cannot undo locally') { throw 'restates the never-push rule verbatim' }
    $named = [regex]::Matches($s, '`((?:\.claude/)?[A-Za-z0-9_./-]+\.md)`') | ForEach-Object { $_.Groups[1].Value }
    if (-not $named) { throw 'does not reach the standing rule at all' }
    $resolved = @($named | Where-Object {
      (Test-Path (Join-Path $repo $_)) -and ((Get-RepoText $_) -match '(?i)never push and never publish')
    })
    if (-not $resolved) { throw "points at $($named -join ', '), and none of those states the never-push rule" }
    $true
  }

  # ADR 0051 moved the unit from the ticket to the effort, so the name this
  # checks for moved with it: `NN-slug` was the old form and is now the thing a
  # correct file must *not* be demonstrating. The criterion is unchanged — the
  # convention is stated, and stated with an example a reader can copy — so the
  # guard tracks the subject rather than the wording it used to have.
  Assert "the branch convention is stated with an example a reader can copy" {
    $s = Get-Section (Get-RepoText '.claude/policies/version-control.md') 'Branch naming'
    if ($s -notmatch '(?i)effort') { throw 'does not tie the name to the effort' }
    if ($s -match '(?m)^\s*\d{2}-[a-z0-9-]+\s*$') { throw 'still demonstrates the per-ticket form ADR 0051 replaced' }
    $example = [regex]::Match($s, '(?ms)^```\r?\n(.*?)^```')
    if (-not $example.Success) { throw 'no worked example of the form' }
    # The sample must name an effort that exists. A shape match would accept
    # `my-effort`, which teaches the form without demonstrating that the name
    # is read off `.claude/tickets/` — the whole of what makes it reproducible.
    $efforts = @(Get-ChildItem (Join-Path $repo '.claude/tickets') -Directory | ForEach-Object { $_.Name })
    $tokens = @([regex]::Matches($example.Groups[1].Value, '[a-z][a-z0-9-]+') | ForEach-Object { $_.Value })
    if (-not ($tokens | Where-Object { $_ -in $efforts })) {
      throw "the example names no effort that exists: $($tokens -join ', ')"
    }
    $true
  }

  Assert "the tracker configuration carries no branch naming" {
    if ((Get-RepoText '.claude/policies/tracker.md') -match '(?im)^##\s+Branch naming') { throw 'the section is here' }
    $true
  }

  # --- criteria 3 and 4: the always-on file is a complete starting point -----

  foreach ($policy in @('.claude/policies/tracker.md', '.claude/policies/version-control.md')) {
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

# --- ticket streamline/01 — split the rules directory ------------------------

# Another section whose subject is `.claude/` rather than `./skills`, for the
# reason `layout/02` gives.
#
# This landed before the effort was re-cut ship-first (ADR 0025), so for one
# commit the shipped templates described the previous placement while this tree
# held the new one. `streamline/02` closed that gap by moving the templates, and
# `streamline/16` adopts whatever else the templates gained. The assertions
# below are unaffected either way: their subject is this repository's own
# `.claude/`, which is the same tree it was.
Describe-Ticket 'streamline/01' 'split the rules directory and make a scoped rule actually scoped' {

  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  # --- criterion 2: the unconditional rules load unconditionally -------------

  foreach ($rule in @('.claude/rules/precedence.md', '.claude/rules/engineering.md')) {
    Assert "$rule loads on every turn — no paths: in its frontmatter" {
      if ($rule -notin (Get-AlwaysOnFiles)) { throw 'scoped, or absent — it would not fire on a turn that opens no file' }
      $true
    }
  }

  Assert "the precedence ladder is stated where it loads, with every rank" {
    $c = Get-RepoText '.claude/rules/precedence.md'
    foreach ($rank in 1..6) {
      if ($c -notmatch "(?m)^$rank\.\s") { throw "rank $rank is missing" }
    }
    if ($c -notmatch '(?i)user instruction overrides everything') { throw 'the user override is not stated' }
    $true
  }

  # The ladder now ranks the directory it lives in, at two different ranks. A
  # ladder that did not say why would read as a contradiction to the next
  # reader, who would then "fix" it by collapsing the two back together.
  Assert "the ladder says why the same directory appears at two ranks" {
    $c = Get-RepoText '.claude/rules/precedence.md'
    if ($c -notmatch '(?i)how a rule loads|loading mechanism') { throw 'the discriminator is not named' }
    if ($c -notmatch '(?i)`paths:`') { throw 'the mechanical test is not given' }
    $true
  }

  # --- criteria 2 and 3: each standard has exactly one always-on home --------
  #
  # One assertion per standard, anchored to that standard. A single assertion
  # demanding all four goes green the moment the first one it reaches is found,
  # which is the failure `.claude/rules/skills.md` warns about by name.
  $standards = [ordered]@{
    'verify before claiming'                    = '(?i)before any repository-specific claim'
    'never guess an API'                        = '(?i)covers every tool this repository uses'
    'never push and never publish'              = '(?i)cannot undo locally'
    'Claude never silently decides architecture' = '(?i)is a silent decision'
  }
  foreach ($standard in $standards.Keys) {
    $pattern = $standards[$standard]
    Assert "'$standard' is stated in exactly one always-on file" {
      $homes = @(Get-AlwaysOnFiles | Where-Object { (Get-RepoText $_) -match $pattern })
      if ($homes.Count -eq 0) { throw 'stated in nothing that loads unconditionally' }
      if ($homes.Count -gt 1) { throw "two homes: $($homes -join ', ')" }
      if ($homes[0] -eq 'CLAUDE.md') { throw 'still in the entrypoint the effort exists to empty' }
      $true
    }
  }

  # --- criterion 4: every scope is machine-readable --------------------------

  # The defect this ticket was cut for: a scope announced in prose is a scope
  # the harness does not enforce, so the file loads everywhere while reading as
  # though it does not. Checked over the directory, not over the one file that
  # had it, or the next one written this way passes.
  Assert "no rule states its scope in prose" {
    $prose = @()
    foreach ($f in (Get-RuleFiles)) {
      $body = (Get-RepoText $f) -replace '(?s)\A---\r?\n.*?\r?\n---\r?\n', ''
      if ($body -match '(?im)^\s*(scope|applies to)\s*:') { $prose += $f }
    }
    if ($prose) { throw "prose scope in: $($prose -join ', ')" }
    $true
  }

  Assert "the authoring standards are scoped rather than charged to every turn" {
    if ('.claude/rules/skills.md' -in (Get-AlwaysOnFiles)) { throw 'still loads unconditionally' }
    $fm = Get-Frontmatter (Get-RepoText '.claude/rules/skills.md')
    if ($fm -notmatch '(?m)^paths:') { throw 'no paths: key' }
    $true
  }

  # A scope that matches nothing is worse than no scope: the rule silently
  # never fires, and every inspection of the frontmatter says it is fine. The
  # globs are resolved against the tree rather than eyeballed.
  Assert "every scoped rule's globs match at least one file that exists here" {
    $tracked = (& git -C $repo ls-files) -replace '\\', '/'
    $dead = @()
    foreach ($f in (Get-RuleFiles)) {
      $fm = Get-Frontmatter (Get-RepoText $f)
      if (-not ($fm -and $fm -match '(?m)^paths:')) { continue }
      foreach ($m in [regex]::Matches($fm, '(?m)^\s*-\s*"?([^"\r\n]+?)"?\s*\r?$')) {
        $glob = $m.Groups[1].Value
        # `**` is parked under a token first: a replacement string is literal
        # text, so a regex escape written there would be matched literally by
        # the pass that follows and the two would never meet.
        $rx = '\A' + ([regex]::Escape($glob) `
                -replace '\\\*\\\*', 'DOUBLESTAR' `
                -replace '\\\*', '[^/]*' `
                -replace 'DOUBLESTAR', '.*') + '\z'
        if (-not ($tracked | Where-Object { $_ -match $rx })) { $dead += "$($f.Name): $glob" }
      }
    }
    if ($dead) { throw "matches nothing in the tree: $($dead -join '; ')" }
    $true
  }

  # A pointer is verified before use, always — and these files are read on
  # every turn without any pointer being followed to reach them, so a broken
  # one here is the most-read broken pointer in the repository.
  #
  # This caught a real defect on the pass that added it: a rule file named
  # `.claude/protocol.md`, which is a later ticket's deliverable and does not
  # exist yet. A forward reference reads exactly like a working pointer.
  Assert "every pointer in an always-on file resolves" {
    $broken = @()
    foreach ($f in (Get-AlwaysOnFiles)) {
      foreach ($m in [regex]::Matches((Get-RepoText $f), '`(\.claude/[^`\r\n]+)`')) {
        $target = $m.Groups[1].Value.TrimEnd('*', '/')
        if (-not (Test-Path (Join-Path $repo $target))) { $broken += "$f → $($m.Groups[1].Value)" }
      }
    }
    if ($broken) { throw ($broken -join '; ') }
    $true
  }

  # --- criterion 3, the other direction: the entrypoint still routes ---------

  # Emptying `CLAUDE.md` of the standards is only safe if it still names where
  # they went. Without this, a reader who opens the entrypoint alone concludes
  # the repository has no precedence rule.
  foreach ($rule in @('.claude/rules/precedence.md', '.claude/rules/engineering.md')) {
    Assert "the entrypoint names $rule" {
      if ((Get-RepoText 'CLAUDE.md') -notmatch [regex]::Escape($rule)) { throw 'not named' }
      $true
    }
  }
}

# --- ticket streamline/02 — the protocol routes, the entrypoint points --------

# `streamline/01` reached this shape in this repository first. This section is
# about the templates that hand the same shape to everybody else, so every
# assertion below reads `./skills` and none of them reads this tree.
Describe-Ticket 'streamline/02' 'the protocol becomes the router, and the entrypoint becomes a pointer' {

  # --- criterion 1: every pointer out of the always-on set is generated ------

  # The entrypoint is only allowed to shrink because it routes. A pointer at a
  # file `/configure` never writes is worse than the inlined prose it replaced:
  # the prose was at least there. Checked over the whole always-on tier, not
  # just `CLAUDE.md`, because the rules templates point outward too.
  Assert "every .claude path the always-on set points at is one /configure writes" {
    $cfg = Get-SkillFile 'configure/SKILL.md'
    $dangling = @()
    foreach ($t in $alwaysOnTemplates) {
      foreach ($m in [regex]::Matches((Get-SkillFile $t), '`(\.claude/[^`\r\n]+)`')) {
        # Trailing glob and slash come off so `contexts/**` and `contexts/` are
        # the same destination. A bare `.claude` after trimming is the directory
        # itself, which names no file and would match anything.
        $target = $m.Groups[1].Value.TrimEnd('*', '/')
        if ($target -eq '.claude') { continue }
        if ($cfg -notmatch [regex]::Escape($target)) { $dangling += "$t → $target" }
      }
    }
    if ($dangling) { throw ($dangling -join '; ') }
    $true
  }

  # ADR 0022 restated plugin independence rather than dropping it: it never
  # meant "`CLAUDE.md` contains everything", it means every rule is reachable by
  # someone without the plugin. That is now a property of the pointers, so the
  # entrypoint has to say it — a reader who cannot tell whether following a
  # pointer needs the plugin will not follow it.
  Assert "the entrypoint says its pointers are followable without the plugin" {
    $c = Get-SkillFile $claudeTemplate
    if ($c -notmatch '(?i)(committed|generated)[^\r\n]{0,120}without the plugin|without the plugin[^\r\n]{0,120}(committed|same file|same pointer)') {
      throw 'nothing says a plugin-less reader reaches the same files'
    }
    if ($c -notmatch '(?i)only the slash commands') { throw 'the one thing that does need the plugin is not named' }
    $true
  }

  # Criterion 1's other half, and the one a path check cannot reach: a *skill*
  # named in an always-on file is machinery a reader without the plugin cannot
  # follow, and it reads exactly like an ordinary pointer. This caught the
  # `domain-modeling` delegation that had been in the entrypoint since tenure/02
  # — inherited rather than introduced, and in scope here because this is the
  # ticket whose criterion forbids it.
  Assert "no always-on template routes a rule through something only the plugin has" {
    $plugin = @{
      'a Primitive skill' = '(?i)`?\b(grilling|tdd|codebase-design|domain-modeling)\b`?'
      'a Spine command'   = '`/(configure|design|implement|review|research|prototype|commit)`'
    }
    $found = @()
    foreach ($t in $alwaysOnTemplates) {
      $c = Get-SkillFile $t
      foreach ($kind in $plugin.Keys) {
        if ($c -match $plugin[$kind]) { $found += "$t names $kind" }
      }
    }
    if ($found) { throw ($found -join '; ') }
    $true
  }

  # --- criterion 2: the protocol routes, and routes in one place ------------

  # Not in `$rulePattern`, deliberately. That table feeds tenure/16's check that
  # no always-on rule leaked into the protocol — and this one belongs there, so
  # adding it would fail the build for the file being correct. Routing is not a
  # rule; it is the thing a rule is reached *through*.
  $routingHeading = '(?im)^##\s+Which guides each stage reads\s*$'

  Assert "the protocol carries the stage routing table, and nothing else does" {
    $homes = @(Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match $routingHeading } |
      ForEach-Object { ($_.FullName.Substring($skills.Length + 1) -replace '\\', '/') })
    if ($homes.Count -eq 0) { throw 'no shipped file routes stages to guides' }
    if ($homes.Count -gt 1) { throw "routed in two places: $($homes -join ', ')" }
    if ($homes[0] -ne $protocolTemplate) { throw "routed from $($homes[0]), not the protocol" }
    $true
  }

  # Every Spine command, or the table is a partial answer that reads as a total
  # one — and a stage missing its row is a stage that goes back to rediscovering
  # its guides, which is the cost this table was added to remove. `/research`
  # reading nothing is a row saying so, not an absence.
  Assert "every Spine stage has a row in the routing table" {
    $section = Get-Section (Get-SkillFile $protocolTemplate) 'Which guides each stage reads'
    if (-not $section) { throw 'the routing section is missing' }
    $missing = @()
    foreach ($stage in @('/configure', '/design', '/implement', '/review', '/research', '/prototype', '/commit')) {
      if ($section -notmatch ('(?im)^\|\s*`' + [regex]::Escape($stage) + '`\s*\|')) { $missing += $stage }
    }
    if ($missing) { throw "no row for: $($missing -join ', ')" }
    $true
  }

  # The rows name a *role* for the forge because which file fills it is chosen
  # per repository. Without that, a template shipping `github.md` in every row
  # hands a GitLab repository a table of pointers it does not have.
  Assert "the routing table names the forge by role, not by a fixed filename" {
    $section = Get-Section (Get-SkillFile $protocolTemplate) 'Which guides each stage reads'
    if ($section -notmatch '(?i)forge reference') { throw 'the role is never named' }
    if ($section -notmatch '(?i)whichever[^\r\n]{0,200}this repository') { throw 'nothing says the file is chosen per repository' }
    $true
  }

  # --- criterion 3: nothing unconditional dropped to pointer-read ------------

  # The failure this criterion exists for is silent by construction: a standard
  # moved into `protocol.md` still reads correctly and still gets followed —
  # just only on the turns a stage happens to run. One assertion per standard,
  # anchored to that standard, for the reason `.claude/rules/skills.md` gives.
  $standards = [ordered]@{
    'verify before claiming'                     = '(?i)before any repository-specific claim'
    'never guess an API'                         = '(?i)covers every tool this repository uses'
    'never push and never publish'               = '(?i)cannot undo locally'
    'Claude never silently decides architecture'  = '(?i)is a silent decision'
    'the precedence ladder'                      = '(?im)^1\.\s+What the user said'
  }
  foreach ($standard in $standards.Keys) {
    $pattern = $standards[$standard]
    Assert "'$standard' ships in the always-on tier, not behind a pointer" {
      $homes = @($alwaysOnTemplates | Where-Object { (Get-SkillFile $_) -match $pattern })
      if ($homes.Count -eq 0) { throw 'stated in no template the harness injects' }
      if ($homes.Count -gt 1) { throw "two always-on homes: $($homes -join ', ')" }
      if ((Get-SkillFile $protocolTemplate) -match $pattern) { throw 'also in the protocol, where it fires only when a stage runs' }
      $true
    }
  }

  # What makes the two rule templates always-on is the *absence* of `paths:`.
  # A scope added here would look like tidying and would silently stop the
  # standard firing on turns that open no matching file — which is most of them.
  foreach ($t in @($precedenceTemplate, $engineeringTemplate)) {
    Assert "$t ships unscoped, so the harness injects it every turn" {
      $fm = Get-Frontmatter (Get-SkillFile $t)
      if ($fm -and $fm -match '(?m)^paths:') { throw 'scoped — it would fire only when a covered file is read' }
      $true
    }
  }

  # And says so, because the next maintainer's instinct on seeing an unscoped
  # rule is to scope it. ADR 0021: adding to this tier is a permanent always-on
  # cost, which is the fact that has to travel with the files.
  Assert "the rules templates say why they carry no scope" {
    foreach ($t in @($precedenceTemplate, $engineeringTemplate)) {
      if ((Get-SkillFile $t) -notmatch '(?i)no `paths:` frontmatter, deliberately') {
        throw "$t does not say the absence is deliberate"
      }
    }
    $true
  }

  # --- criterion 4: the rename is complete -----------------------------------

  # `.claude/tenure.md` is covered by the `$legacy` sweep in tenure/01, which
  # exempts the two files whose job is converting it. The *template's* filename
  # gets no exemption: nothing detects or migrates a path inside this repository.
  Assert "nothing shipped names the old protocol template" {
    if (Test-Path (Join-Path $skills 'configure/tenure.template.md')) { throw 'the old template is still there' }
    $named = @(Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match 'tenure\.template\.md' } |
      ForEach-Object { ($_.FullName.Substring($skills.Length + 1) -replace '\\', '/') })
    if ($named) { throw "named in: $($named -join ', ')" }
    $true
  }

  # --- criterion 6: the entrypoint stays inside a budget it states -----------

  # Read out of the template's own comment rather than hardcoded. A budget the
  # file announces and the suite checks separately is two numbers that drift,
  # and the one a maintainer reads is the one that is not enforced.
  Assert "the entrypoint's stated line budget is the one enforced, and it holds" {
    $c = Get-SkillFile $claudeTemplate
    $stated = [regex]::Match($c, '(?i)under (\d+) lines')
    if (-not $stated.Success) { throw 'the template states no budget' }
    $budget = [int]$stated.Groups[1].Value
    $n = ($c -split '\r?\n').Count
    if ($n -ge $budget) { throw "$n lines against a stated budget of $budget" }
    $true
  }
}

# --- ticket streamline/03 — one guide per workflow concern -------------------

Describe-Ticket 'streamline/03' 'one guide per workflow concern, reached by pointer' {

  # The whole shipped set, and which side of ADR 0019's line each falls on.
  # Declared once here rather than derived from the directory listing: a guide
  # appearing on disk with nothing claiming it is exactly the drift this table
  # exists to catch, and a listing would absorb it silently.
  $policies = [ordered]@{
    'knowledge'       = 'copied'
    'context'         = 'copied'
    'decisions'       = 'copied'
    'tickets'         = 'copied'
    'specs'           = 'copied'
    'maps'            = 'copied'
    'evidence'        = 'copied'
    'tracker'         = 'derived'
    'version-control' = 'derived'
  }

  # --- criterion 1: reachable, and reachable from the one index --------------

  foreach ($p in $policies.Keys) {
    Assert "the $p guide ships and is routed from the protocol" {
      $t = "configure/policies/$p.template.md"
      if (-not (Test-Path (Join-Path $skills $t))) { throw "$t is missing" }
      $section = Get-Section (Get-SkillFile $protocolTemplate) 'Which guides each stage reads'
      if (-not $section) { throw 'the routing section is gone' }
      if ($section -notmatch [regex]::Escape(".claude/policies/$p.md")) { throw 'no stage names it' }
      $true
    }
  }

  # The reverse direction, which is the one that goes wrong quietly: a row
  # naming a guide nobody wrote is a pointer at nothing, and it reads exactly
  # like a working one until somebody follows it.
  Assert "every guide the routing table names is one that ships" {
    $section = Get-Section (Get-SkillFile $protocolTemplate) 'Which guides each stage reads'
    $missing = @()
    foreach ($m in [regex]::Matches($section, '\.claude/policies/([a-z-]+)\.md')) {
      $name = $m.Groups[1].Value
      if (-not (Test-Path (Join-Path $skills "configure/policies/$name.template.md"))) { $missing += $name }
    }
    if ($missing) { throw "routed but never written: $(($missing | Sort-Object -Unique) -join ', ')" }
    $true
  }

  Assert "/configure installs every guide it ships" {
    $c = Get-SkillFile 'configure/SKILL.md'
    $unwritten = @($policies.Keys | Where-Object { $c -notmatch [regex]::Escape("$_.md") })
    if ($unwritten) { throw "shipped but never installed: $($unwritten -join ', ')" }
    $true
  }

  # --- criterion 4: the derived guides stay derived --------------------------

  # ADR 0019's line, drawn per guide rather than once for the directory. A
  # copied `tracker.md` would tell every repository it uses whichever tracker
  # this one does, which is the specific harm the derivation exists to prevent.
  Assert "the copied and derived guides are distinguished where they are installed" {
    $c = Get-SkillFile 'configure/SKILL.md'
    foreach ($p in $policies.Keys) {
      $row = [regex]::Match($c, '(?im)^\|\s*`' + [regex]::Escape("$p.md") + '`\s*\|([^|\r\n]*)\|')
      if (-not $row.Success) { throw "$p has no row saying how it is written" }
      $stated = if ($row.Groups[1].Value -match '(?i)derived') { 'derived' } else { 'copied' }
      if ($stated -ne $policies[$p]) { throw "$p is installed as $stated, expected $($policies[$p])" }
    }
    $true
  }

  # --- criterion 3: the moved guides kept what they said ---------------------

  # Location and name changed; substance did not. Checked by section, because a
  # move that quietly drops a section is indistinguishable from one that did
  # not — the file exists either way and every pointer at it still resolves.
  $keptSections = [ordered]@{
    'configure/policies/version-control.template.md' = @('Which model', 'Branch naming', 'Commit discipline', 'How work lands')
    'configure/policies/tracker.template.md'         = @('Which tracker', 'Assignment', 'Roles')
  }
  foreach ($f in $keptSections.Keys) {
    $sections = $keptSections[$f]
    Assert "$f kept every section it had before the move" {
      $c = Get-SkillFile $f
      $lost = @($sections | Where-Object { $c -notmatch ('(?im)^##\s+' + [regex]::Escape($_) + '\s*$') })
      if ($lost) { throw "lost: $($lost -join ', ')" }
      $true
    }
  }

  # --- criterion 2: consolidated means stated once, and reached from the rest -

  # `$rulePattern`'s single-home sweep already proves each moved rule is stated
  # once. What it cannot see is whether the skill that gave the rule up can
  # still reach it — a rule with one home and no inbound route is not
  # consolidated, it is lost.
  $routes = [ordered]@{
    'design/SKILL.md'    = @('.claude/policies/evidence.md', '.claude/policies/knowledge.md')
    'implement/SKILL.md' = @('.claude/policies/knowledge.md', '.claude/policies/context.md')
    'commit/SKILL.md'    = @('.claude/policies/knowledge.md', '.claude/policies/specs.md')
    'research/SKILL.md'  = @('.claude/policies/evidence.md')
    'prototype/SKILL.md' = @('.claude/policies/evidence.md')
    'review/SKILL.md'    = @('.claude/policies/decisions.md')
  }
  foreach ($f in $routes.Keys) {
    $targets = $routes[$f]
    Assert "$f reaches every guide it stopped stating" {
      $c = Get-SkillFile $f
      $dead = @($targets | Where-Object { $c -notmatch [regex]::Escape($_) })
      if ($dead) { throw "no route to: $($dead -join ', ')" }
      $true
    }
  }

  # The formats left the plugin entirely. A sibling filename left behind reads
  # as a working link and resolves to nothing once the skill is the only file
  # in its directory.
  #
  # `-cmatch`, for the reason the `$legacy` sweep matches `CONTEXT.md` case
  # sensitively: the new guide is `tickets.md` and PowerShell's `-match` is
  # case-insensitive, so the default comparison flags every correct pointer as
  # the stale one it replaced.
  Assert "no skill still points at a format document as a sibling file" {
    $gone = @('TICKETS.md', 'SPEC-FORMAT.md', 'ADR-FORMAT.md', 'CONTEXT-FORMAT.md')
    $hits = @()
    foreach ($f in (Get-SkillFiles)) {
      $rel = ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/')
      if ($rel -like 'configure/policies/*') { continue }
      $c = Get-SkillText $f
      foreach ($g in $gone) { if ($c -cmatch [regex]::Escape($g)) { $hits += "$rel → $g" } }
    }
    if ($hits) { throw ($hits -join '; ') }
    $true
  }
}

# --- ticket streamline/04 — routing splits from vocabulary --------------------

Describe-Ticket 'streamline/04' 'split routing from vocabulary, and re-home the terms' {

  $ctx = 'configure/policies/context.template.md'

  # --- criterion 1: routing is readable without the vocabulary ---------------

  # The whole point of the split, and the one thing a reader cannot verify by
  # looking at the format — they would have to notice an absence. Asserted as
  # the absence: the map's own example carries no Language section, because a
  # format that demonstrates the wrong shape teaches it.
  # Spanned between two headings by index rather than read with Get-Section.
  # A section ends at the next heading of the same level, so a leaked `## Language`
  # *terminates* the region a section-scoped check would look at — the guard goes
  # green precisely because the thing it hunts is present. Caught by mutation;
  # the section-scoped version of this assertion missed it.
  Assert "the routing file is specified as the table and nothing else" {
    $c = Get-SkillFile $ctx
    $from = [regex]::Match($c, '(?im)^##\s+`?contexts/map\.md`?\s*$')
    $to   = [regex]::Match($c, '(?im)^##\s+`?contexts/repository\.md`?\s*$')
    if (-not $from.Success) { throw 'the routing file has no section of its own' }
    if (-not $to.Success -or $to.Index -le $from.Index) { throw 'the vocabulary file does not follow it' }
    $span = $c.Substring($from.Index, $to.Index - $from.Index)
    foreach ($leak in @('(?im)^##\s+Language', '(?im)^##\s+Boundaries', '(?im)^##\s+Constraints')) {
      if ($span -match $leak) { throw 'the routing file is specified carrying vocabulary' }
    }
    $span -match '(?i)nothing else goes in this file|routing table alone|and nothing else'
  }

  Assert "the three files are named, each with what it holds and when it is read" {
    $c = Get-SkillFile $ctx
    foreach ($f in @('map\.md', 'repository\.md', '<domain>\.md|domain.{0,3}\.md')) {
      if ($c -notmatch $f) { throw "the format never names $f" }
    }
    # A table, not prose: the reader's question is "which file", and a table is
    # what answers it without being read end to end.
    $c -match '(?im)^\|[^|\r\n]*`?contexts/map\.md`?[^|\r\n]*\|'
  }

  # --- criterion 2: term placement is mechanical ----------------------------

  # "Mechanically enough that two people placing the same term agree." A rule
  # that says terms go "where they belong" satisfies nothing; what makes this
  # checkable is that it reads off a property of the term rather than asking
  # for a judgement about it.
  Assert "the placement rule decides from where a term is used, not from what it is about" {
    $c = Get-SkillFile $ctx
    $section = Get-Section $c 'Where a term belongs'
    if (-not $section) { throw 'there is no placement rule' }
    foreach ($row in @('(?i)one workflow stage', '(?i)one domain', '(?i)across stages|across domains')) {
      if ($section -notmatch $row) { throw "the rule does not cover: $row" }
    }
    # The tie-break. Without it the rule is silent on the only case that is
    # genuinely hard, which is the case people will actually bring to it.
    $section -match '(?i)two senses|two rows'
  }

  # --- criterion 3: a stage's term lives with the stage ---------------------

  Assert "a stage-owned term is defined in that stage's guide and not restated in the vocabulary" {
    $section = Get-Section (Get-SkillFile $ctx) 'Where a term belongs'
    if ($section -notmatch [regex]::Escape('.claude/policies/')) { throw 'stage-owned terms are not routed to their guide' }
    $section -match '(?i)(and nowhere else|second home)'
  }

  # --- criterion 4: every context file has exactly one row ------------------

  # Both directions, and `repository.md` explicitly — it is the row most likely
  # to be forgotten, because it is the file the author is standing in when they
  # write the table.
  Assert "the routing table covers every context file, including the vocabulary itself" {
    $c = Get-SkillFile $ctx
    if ($c -notmatch '(?i)exactly one row') { throw 'the one-row rule is gone' }
    if ($c -notmatch '(?i)including `?repository\.md`?') { throw 'the vocabulary file is not required to have a row' }
    $c -match '(?i)row with no file|pointer at nothing'
  }

  # --- criterion 5: onboarding generates and recognises the split -----------

  Assert "/configure generates all three, and the routing table is written last" {
    $c = Get-SkillFile 'configure/SKILL.md'
    foreach ($p in @('.claude/contexts/map.md', '.claude/contexts/repository.md')) {
      if ($c -notmatch [regex]::Escape($p)) { throw "$p is never generated" }
    }
    # Ordering matters and is not obvious: a table written before the domains
    # are known is a list of intentions, and every row has to resolve.
    $c -match '(?i)write `?map\.md`? last|map\.md`? last'
  }

  Assert "the audit recognises a repository already on the split shape" {
    $s = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Audit, where AEP is already here'
    if (-not $s) { throw 'the audit branch is gone' }
    if ($s -notmatch '(?i)exactly one row') { throw 'the audit does not validate the routing table' }
    $s -match '(?i)routing and nothing else|orientation prose'
  }

  # --- criterion 6: the split admits nothing the test excluded --------------

  Assert "the compression test still gates all three files" {
    $c = Get-SkillFile $ctx
    if ($c -notmatch '(?i)compression test') { throw 'the gate is gone' }
    # Named because splitting a file is exactly when someone concludes the new
    # one has different rules.
    $c -match '(?i)split changes where a line goes|does not admit a line'
  }

  # --- the superseded path stays gone --------------------------------------

  # `.claude/context.md` is now a pre-migration path. It is not in the `$legacy`
  # sweep because that sweep matches `CONTEXT.md` case-sensitively to avoid this
  # very file, and adding a lowercase sibling there would be two rules in one
  # table. Asserted here instead, with the same two exemptions.
  Assert "nothing shipped names the superseded root context file" {
    $exempt = @('configure/SKILL.md', 'configure/MIGRATION.md')
    $hits = @()
    foreach ($f in (Get-SkillFiles)) {
      $rel = ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/')
      if ($rel -in $exempt) { continue }
      if ((Get-SkillText $f) -cmatch '\.claude/context\.md') { $hits += $rel }
    }
    if ($hits) { throw "still named in: $($hits -join ', ')" }
    $true
  }
}

# --- ticket streamline/05 — directories at the root, Position in one place ----

Describe-Ticket 'streamline/05' 'every main directory at the root, and per-clone state in one place' {

  $layout = { Get-Section (Get-SkillFile 'configure/SKILL.md') 'Generate' }

  # --- criterion 1: exactly one loose file ----------------------------------

  # Read off the generated tree itself. A count taken across the whole skill
  # would find every `.claude/x.md` it mentions in passing, most of which are
  # inside directories, and pass while the tree grew a second loose file.
  # The criterion was "exactly one loose file", and it held while everything
  # loose belonged to this workflow. ADR 0045 put `settings.json` in the layout:
  # the harness reads it from that exact path, the same reason `.gitignore` sits
  # there. So the criterion is now exactly one loose file *this workflow owns* —
  # which is what it always meant, and what the count was standing in for. The
  # exemption is a named list rather than a predicate, so adding to it is a
  # decision somebody makes rather than a count quietly going up.
  $harnessOwned = @('settings.json')
  Assert "the generated layout has exactly one file loose that this workflow owns" {
    $tree = [regex]::Match((& $layout), '(?ms)^```\r?\n\.claude/\r?\n(.*?)^```')
    if (-not $tree.Success) { throw 'the generated layout is not shown' }
    $loose = @()
    foreach ($line in ($tree.Groups[1].Value -split '\r?\n')) {
      # Top level only: a nested entry is indented past the tree glyphs.
      if ($line -notmatch '^[├└]──\s+(\S+)') { continue }
      $entry = $Matches[1]
      if ($entry -match '/$' -or $entry -like '.*') { continue }
      $loose += $entry
    }
    $owned = @($loose | Where-Object { $_ -notin $harnessOwned })
    if ($owned.Count -ne 1) { throw "loose at the root: $($owned -join ', ')" }
    if ($owned[0] -ne 'protocol.md') { throw "the loose file is $($owned[0]), not the router" }
    $true
  }

  Assert "a second loose file is named as a finding rather than tolerated" {
    if (-not ((& $layout) -match '(?i)second loose file|category nobody named')) { throw '& $layout does not match: (?i)second loose file|category nobody named' }
    $true
  }

  # --- criterion 2: per-clone state has one directory -----------------------

  foreach ($p in @('.claude/position/marker.json', '.claude/position/prototypes/')) {
    Assert "$p is where the generated layout puts it" {
      $named = @(Get-SkillFiles | Where-Object { (Get-Content $_.FullName -Raw) -match [regex]::Escape($p) })
      if (-not $named) { throw 'nothing shipped names it' }
      $true
    }
  }

  # The superseded locations, swept rather than spot-checked. `/prototypes/` at
  # the workflow root and `marker.json` beside it are the two the move retires,
  # and either surviving anywhere means a reader is sent to a file that is not
  # written.
  #
  # Both `configure/` files are exempt, which is the same pair `$legacyExempt`
  # carries and for the same reason: one detects these paths and the other
  # converts them, and neither can do its job without naming them. This guard
  # exempted only the migration until `streamline/08` added the detection
  # entries — a narrower exemption than the rule it was copying.
  Assert "nothing shipped still puts per-clone state at the workflow root" {
    $hits = @()
    foreach ($f in (Get-SkillFiles)) {
      $rel = ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/')
      if ($rel -in $legacyExempt) { continue }
      $c = Get-SkillText $f
      foreach ($old in @('\.claude/marker\.json', '\.claude/prototypes/')) {
        if ($c -match $old) { $hits += "$rel → $old" }
      }
    }
    if ($hits) { throw ($hits -join '; ') }
    $true
  }

  # --- criterion 3: the definition is a category and a test, not a list -----

  $ignoreBlock = { [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n(.*?)^```').Groups[1].Value }

  Assert "the ignore file still states the category and a test a reader can apply" {
    $b = & $ignoreBlock
    if (-not $b) { throw 'the ignore file is described but never written out' }
    if ($b -notmatch '(?i)Position') { throw 'the category is unnamed' }
    # One line, deliberately: the test was split across a wrapped comment once
    # and the guard for it went red, which is the only reason anyone noticed.
    if ($b -notmatch '(?i)wrong in another clone') { throw 'no membership test a reader can apply' }
    $b -match '(?i)knowledge is committed'
  }

  # --- criterion 4: the write-ups survive the move --------------------------

  # The hazard changed shape. `/prototypes/` and `evidence/prototypes/` used to
  # be one word apart at different depths, so the anchor was what kept an ignore
  # rule off the write-ups. They now sit under different parents, which removes
  # the collision rather than guarding it — so this asserts the outcome, and the
  # anchor separately, instead of asserting the old mechanism.
  Assert "no ignore entry can reach the evidence write-ups" {
    $entries = @((& $ignoreBlock) -split '\r?\n' | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' })
    if (-not $entries) { throw 'nothing is ignored at all' }
    foreach ($e in $entries) {
      $pattern = $e.Trim().TrimStart('/').TrimEnd('/')
      if ('evidence/prototypes' -match [regex]::Escape($pattern)) {
        throw "'$e' reaches the write-ups"
      }
    }
    $true
  }

  Assert "the per-clone directory is anchored, and says why" {
    $b = & $ignoreBlock
    $entries = @($b -split '\r?\n' | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' })
    if ($entries -notcontains '/position/') { throw "unanchored: $($entries -join ', ')" }
    $b -match '(?i)leading slash'
  }

  # The one per-clone file that cannot move, and the reason — established by
  # reading the tree rather than assumed: the harness writes it at that exact
  # path, so relocating it would leave the harness unable to find it.
  Assert "the harness-owned settings file is ignored where it is, and says why it stays" {
    $b = & $ignoreBlock
    $entries = @($b -split '\r?\n' | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' })
    if ($entries -notcontains 'settings.local.json') { throw 'it would be committed' }
    $b -match '(?i)harness writes it|not the workflow''s'
  }

  # --- criterion 5: directories stay lazy -----------------------------------

  Assert "the per-clone directory is created lazily like the rest" {
    $lazy = [regex]::Match((& $layout), '(?ms)The rest of the tree.*?(?=\r?\n\r?\n)').Value
    if (-not $lazy) { throw 'the lazy-creation rule is gone' }
    if ($lazy -notmatch 'position/') { throw 'the per-clone directory is not covered by it' }
    $true
  }

  # --- criterion 6: the repository's own ignore file is untouched -----------

  Assert "the root ignore file is still left alone" {
    if (-not ((Get-SkillFile 'configure/SKILL.md') -match '(?i)root[^\r\n]{0,60}\.gitignore|repository''s own ignore|leav[^\r\n]{0,40}root')) { throw 'configure/SKILL.md does not match: (?i)root[^\r\n]{0,60}\.gitignore|repository''''s own ignore|leav[^\r\n]{0,40}root' }
    $true
  }
}

# --- ticket streamline/06 — skills declare the guides they read ---------------

Describe-Ticket 'streamline/06' 'each skill declares the guides it reads' {

  # This was a body line until ADR 0055, on the ground that nothing in the
  # harness would act on a frontmatter field. That premise was checked and found
  # false: the skills reference documents a `metadata:` map for exactly this, so
  # the field is load-bearing in the sense `contexts/skill-authoring.md` requires
  # — the configuration stage's derivation and this suite both read it.
  function Get-Declared {
    param([string]$Relative)
    Get-DeclaredPolicies (Get-SkillFile $Relative)
  }

  function Get-RoutedFor {
    param([string]$Stage)
    $section = Get-Section (Get-SkillFile $protocolTemplate) 'Which guides each stage reads'
    $row = [regex]::Match($section, '(?im)^\|\s*`?/' + [regex]::Escape($Stage) + '`?\s*\|([^\r\n]*)\|\s*$')
    if (-not $row.Success) { return $null }
    ,@([regex]::Matches($row.Groups[1].Value, '`\.claude/policies/([a-z-]+)\.md`') |
       ForEach-Object { $_.Groups[1].Value })
  }

  # --- criterion 1: every declaration resolves ------------------------------

  Assert "every skill that reads a guide declares it, near the top" {
    $expected = @('commit', 'configure', 'design', 'domain-modeling', 'implement',
                  'prototype', 'research', 'review', 'triage')
    $missing = @($expected | Where-Object { $null -eq (Get-DeclaredPolicies (Get-SkillFile "$_/SKILL.md")) })
    if ($missing) { throw "no declaration: $($missing -join ', ')" }
    $true
  }

  # One declaration per skill. The insertion that produced these matched every
  # `# ` heading in the file, including the ones inside fenced examples, and put
  # a second `Policies:` line into two write-up templates — where it read as
  # part of the template a user is meant to copy.
  Assert "no skill declares twice" {
    $twice = @()
    foreach ($f in (Get-SkillFiles)) {
      $block = Get-MetadataBlock (Get-SkillText $f)
      if ($null -eq $block) { continue }
      $n = ([regex]::Matches($block, '(?m)^[ \t]+policies:')).Count
      if ($n -gt 1) { $twice += ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/') }
    }
    if ($twice) { throw "declared more than once in: $($twice -join ', ')" }
    $true
  }

  Assert "every guide any skill declares exists as a shipped template" {
    $broken = @()
    foreach ($f in (Get-SkillFiles)) {
      $rel = ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/')
      foreach ($g in (Get-Declared $rel)) {
        # `*` is the whole directory, not a guide name — resolving it would let
        # `Test-Path`'s own wildcard matching answer yes for a skill that named
        # nothing checkable.
        if ($g -eq '*') { continue }
        if (-not (Test-Path (Join-Path $skills "configure/policies/$g.template.md"))) { $broken += "$rel → $g" }
      }
    }
    if ($broken) { throw ($broken -join '; ') }
    $true
  }

  # --- criterion 2: a skill declares only what it reads ---------------------

  # The cross-check the routing table has needed since it was written. The table
  # and the declarations are two expressions of one mapping, and nothing stopped
  # them drifting — they already had, in three places, before this assertion
  # existed. Both directions, because each catches a different mistake: a stage
  # that quietly stopped reading a guide, and one that started without saying so.
  #
  # `/configure` is exempt and says why in its own declaration: it reads every
  # guide, so listing them would be a tenth thing to update when a tenth guide
  # is written.
  # `triage` joined this list with ADR 0063. It is not a spine stage, but it
  # declares a guide and is an entry destination, and the gap between those two
  # facts is precisely what let it sit in the table with no row at all.
  foreach ($stage in @('design', 'implement', 'review', 'research', 'prototype', 'commit', 'triage')) {
    Assert "/$stage declares exactly what the routing table routes to it" {
      $declared = Get-Declared "$stage/SKILL.md"
      $routed = Get-RoutedFor $stage
      if ($null -eq $declared) { throw 'the skill declares nothing' }
      if ($null -eq $routed) { throw 'the routing table has no row for it' }
      $undeclared = @($routed | Where-Object { $_ -notin $declared })
      $unrouted   = @($declared | Where-Object { $_ -notin $routed })
      if ($undeclared) { throw "routed but not declared: $($undeclared -join ', ')" }
      if ($unrouted) { throw "declared but not routed: $($unrouted -join ', ')" }
      $true
    }
  }

  # The exception moved house when the declaration became a field. The machine
  # half is the wildcard; the reason is prose and stays prose, in the body —
  # a field carries what something acts on and nothing acts on a justification.
  Assert "/configure declares the whole directory rather than a list, and says why" {
    $c = Get-SkillFile 'configure/SKILL.md'
    $declared = Get-DeclaredPolicies $c
    if ($null -eq $declared) { throw 'no declaration' }
    if ($declared -notcontains '*') { throw 'the whole directory is not declared' }
    # Crossing newlines deliberately. A single-line window would forbid the
    # reason ever wrapping — reintroducing, for the half that stayed prose, the
    # exact reflow fragility ADR 0055 moved the machine-read half to escape.
    if ($c -notmatch '(?is)every guide.{0,200}(writes them|audit)') { throw 'the reason is not stated in the body' }
    $true
  }

  # --- criterion 3: declaring is not restating ------------------------------

  # `$rulePattern`'s single-home sweep already proves each guide's rules are
  # stated once. What it cannot see is a declaration that has quietly grown into
  # a summary of the guide — which reads as helpful and is a second home.
  # The length check this replaces measured prose left over beside the paths.
  # A list of bare names has nowhere for prose to sit, so the successor property
  # is that the field stayed a list of bare names — a path or a sentence smuggled
  # into it is the same failure arriving in the new format.
  Assert "a declaration points and does not summarise" {
    $bad = @()
    foreach ($f in (Get-SkillFiles)) {
      $block = Get-MetadataBlock (Get-SkillText $f)
      if ($null -eq $block) { continue }
      $line = [regex]::Match($block, '(?m)^[ \t]+policies:[ \t]*(.*)$')
      if (-not $line.Success) { continue }
      # Quotes are permitted because the wildcard needs them: a bare `*` opens a
      # YAML alias, so `["*"]` is the only spelling of "the whole directory" that
      # survives a parser.
      if ($line.Groups[1].Value -notmatch '^\[["a-z*, -]*\]$') {
        $bad += ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/')
      }
    }
    if ($bad) { throw "the declaration is not a bare-name list: $($bad -join ', ')" }
    $true
  }
}

# --- ticket streamline/07 — commit follows review, without asking -------------

Describe-Ticket 'streamline/07' 'commit follows review without asking' {

  # Criteria 1 and 3 are asserted in `tenure/04`, where the close-out already
  # had a home — the ordering and the amend rule are the same criteria they
  # always were, and only what they order against changed. What is here is what
  # this ticket added: the account in the always-on tier, and the guard that
  # keeps the prompt from coming back by any of its names.

  # --- criterion 5: the always-on account matches what happens --------------

  # The line that stops being true is the one a reader trusts most, because it
  # loads on every turn whether or not a stage runs. ADR 0024 names it as the
  # consequence to correct, so it is asserted at the tier rather than the file:
  # `streamline/02` moved it once already.
  Assert "the always-on tier no longer says committing is asked for" {
    $stale = @($alwaysOnTemplates | Where-Object { (Get-SkillFile $_) -match '(?i)committing is asked for' })
    if ($stale) { throw "still stated in: $($stale -join ', ')" }
    $true
  }

  Assert "the always-on tier says committing happens without being asked" {
    $homes = @($alwaysOnTemplates | Where-Object { (Get-SkillFile $_) -match '(?i)without being asked' })
    if ($homes.Count -eq 0) { throw 'nothing that loads unconditionally says so' }
    if ($homes.Count -gt 1) { throw "two homes: $($homes -join ', ')" }
    $true
  }

  # Criterion 4, and the reason the change is safe at all. The prohibition was
  # standing before and is load-bearing now: it is the only thing between a
  # commit nobody asked for and a publication nobody asked for.
  Assert "the push prohibition is stated as what makes committing without asking safe" {
    $homes = @($alwaysOnTemplates | Where-Object { (Get-SkillFile $_) -match '(?i)cannot undo locally' })
    if ($homes.Count -ne 1) { throw "the prohibition has $($homes.Count) always-on homes" }
    (Get-SkillFile $homes[0]) -match '(?i)load-bearing|only safe while'
  }

  # --- criterion 1: the prompt is gone from every shape it took -------------

  # Three shapes, because it appeared as prose, as a step in the loop diagram,
  # and as a thing `/review` ordered itself against. Deleting one and leaving
  # the others is how a retired behaviour keeps being described.
  Assert "no skill still describes a commit prompt" {
    $shapes = [ordered]@{
      'the close-out question' = '(?i)commit and resolve this ticket'
      'a step in the loop'     = '(?im)^\s*→\s*ASK\b'
      'an ordering landmark'   = '(?i)the commit question'
    }
    $found = @()
    foreach ($f in (Get-SkillFiles)) {
      $c = Get-SkillText $f
      $rel = ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/')
      foreach ($shape in $shapes.Keys) {
        if ($c -match $shapes[$shape]) { $found += "$rel → $shape" }
      }
    }
    if ($found) { throw ($found -join '; ') }
    $true
  }

  # --- criterion 3: one ticket is still one commit --------------------------

  Assert "further changes amend rather than adding a second commit" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)one ticket stays one commit') { throw 'the invariant is gone' }
    $c -match '(?i)amend'
  }

  # --- criterion 2: /commit still owns the commit and the Marker ------------

  # The prompt's removal moves who *triggers* the commit, not who writes it.
  # A close-out that started committing directly would satisfy every criterion
  # above and quietly give the Marker a second writer.
  Assert "the close-out still routes through /commit, which stays the only Marker writer" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)close out through `?/commit') { throw 'the close-out no longer routes through /commit' }
    if ($c -notmatch '(?i)never writes the Marker directly') { throw 'the single-writer rule is gone' }
    # And a refusal is not routed around, which is the new failure mode: with
    # no prompt, nothing else pauses the close-out.
    $c -match '(?i)refuses[^.]{0,120}(stops|not worked around)'
  }
}

# --- ticket streamline/08 — the migration converts the superseded layout ------

Describe-Ticket 'streamline/08' 'the migration converts the superseded layout' {

  $mig = { Get-SkillFile 'configure/MIGRATION.md' }
  $section = { Get-Section (Get-MigrationText) 'The guides-and-position migration' }

  # --- criterion 1: every superseded path has a destination -----------------

  # Read out of the conversion table itself. Several of these paths also appear
  # in the prose around it — the split is discussed, the entrypoint is discussed
  # — so a file-wide search passes with a row deleted, which is the row going
  # missing rather than the path being handled.
  $conversions = [ordered]@{
    '\.claude/tenure\.md'          = '\.claude/protocol\.md'
    '\.claude/tracker\.md'         = '\.claude/policies/tracker\.md'
    '\.claude/version-control\.md' = '\.claude/policies/version-control\.md'
    '\.claude/marker\.json'        = '\.claude/position/marker\.json'
    '\.claude/prototypes/'         = '\.claude/position/prototypes/'
    '\.claude/context\.md'         = '(split|contexts/)'
  }
  foreach ($from in $conversions.Keys) {
    $to = $conversions[$from]
    Assert "the conversion table sends $($from -replace '\\','') somewhere" {
      $rows = @((& $section) -split '\r?\n' | Where-Object { $_ -match '^\|' -and $_ -match $from })
      if (-not $rows) { throw 'no row converts it' }
      if (-not ($rows | Where-Object { $_ -match $to })) { throw 'the row names the source without its target' }
      $true
    }
  }

  Assert "the two files that are written rather than moved are in the table" {
    $s = & $section
    foreach ($written in @('rules/\{?precedence', 'policies/')) {
      if ($s -notmatch $written) { throw "nothing says what fills $written" }
    }
    $true
  }

  # --- criterion 2: references inside the moved files too -------------------

  # The half a fixture run found missing: a file that has been carried across
  # looks handled, and its own prose still names where it used to be. Asserted
  # because the sweep that catches it is the one nobody thinks to run.
  Assert "the repair covers references inside the files that moved" {
    $s = & $section
    if ($s -notmatch '(?i)inside the files that (just )?moved|sweep the destinations') {
      throw 'only untouched files are swept'
    }
    $s -match '(?i)own comment|where it was installed|repairs everything except what it touched'
  }

  Assert "frozen records are named as history rather than left ambiguous" {
    $s = & $section
    if ($s -notmatch '(?i)frozen') { throw 'nothing distinguishes a record from a pointer' }
    $s -match '(?i)leave the record alone|history, not pointers'
  }

  # --- criteria 3 and 4: recognition, by content ---------------------------

  Assert "recognition is by content, and states every condition it checks" {
    $s = & $section
    foreach ($cond in @('(?i)gone, not merely duplicated|are \*\*gone\*\*',
                        '(?i)states no rule that',
                        '(?i)every row in the map resolves')) {
      if ($s -notmatch $cond) { throw "a recognition condition is missing: $cond" }
    }
    $true
  }

  # The row with no file to move is the one a run finishes without doing, and
  # nothing is left behind to say so. Named in the page for that reason.
  #
  # Both halves, separately. Written first as one alternation, which passed with
  # the consequence deleted because the observation survived — the "a guard
  # covering two claims passes when either holds" failure the authoring
  # standards name. The observation without the consequence is a curiosity.
  Assert "the entrypoint reshape is called out as the row with no leftover" {
    $s = & $section
    if ($s -notmatch '(?i)no file to move') { throw 'the row is not identified' }
    if ($s -notmatch '(?i)without noticing it has not') { throw 'the consequence is not stated' }
    $true
  }

  Assert "an unconverted repository is finished rather than re-converted" {
    $s = & $section
    if ($s -notmatch '(?i)converted, not re-converted') { throw 'a partial run is not distinguished from a fresh one' }
    $s -match '(?i)appends instead of recognising'
  }

  # --- criterion 5: detection names them, and only here --------------------

  Assert "the detection list names every superseded path the table converts" {
    $detect = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Detect'
    $missing = @('\.claude/tenure\.md', '\.claude/tracker\.md', '\.claude/version-control\.md',
                 '\.claude/context\.md', '\.claude/marker\.json', '\.claude/prototypes/') |
      Where-Object { $detect -notmatch $_ }
    if ($missing) { throw "undetectable: $(($missing -replace '\\','') -join ', ')" }
    $true
  }

  # The exemption that lets the two `configure/` files name these paths is not a
  # hole only while every such mention is doing one of those two jobs.
  Assert "every superseded path named in an exempt file is a detection entry or a conversion row" {
    $stray = @()
    foreach ($rel in $legacyExempt) {
      $c = Get-SkillFile $rel
      $allowed = if ($rel -eq 'configure/SKILL.md') { Get-Section $c 'Detect' } else { $c }
      foreach ($p in @('\.claude/tenure\.md', '\.claude/marker\.json', '\.claude/prototypes/')) {
        $total = ([regex]::Matches($c, $p)).Count
        $inside = ([regex]::Matches($allowed, $p)).Count
        if ($total -gt $inside) { $stray += "$rel names $($p -replace '\\','') outside its job" }
      }
    }
    if ($stray) { throw ($stray -join '; ') }
    $true
  }
}

# --- ticket aep/02 — rename the framework from Tenure to AEP ------------------

Describe-Ticket 'aep/02' 'rename the framework from Tenure to AEP' {

  # The reintroduction guard, same shape as the $legacy sweep: the two exempt
  # files are the ones whose job is detecting and converting the old name.
  Assert "nothing shipped names the old framework except the files that detect and convert it" {
    $offenders = @()
    foreach ($f in Get-SkillFiles) {
      $rel = $f.FullName.Substring($skills.Length).TrimStart('\', '/') -replace '\\', '/'
      if ($legacyExempt -contains $rel) { continue }
      if ((Get-SkillText $f) -match '(?i)tenure') { $offenders += $rel }
    }
    if ($offenders) { throw "the old name survives in: $($offenders -join ', ')" }
    $true
  }

  # The exemption is for the job, not the file: SKILL.md may name the old
  # framework only as the lowercase detection path. A capitalised Tenure in its
  # prose would be a rename miss hiding behind the exemption.
  Assert "the detection file names the old framework only as a path" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -cmatch 'Tenure') { throw 'configure/SKILL.md still says Tenure in prose' }
    $c -match '\.claude/tenure\.md'
  }

  Assert "the migration carries the rename, and splits live files from frozen records" {
    # Anchored on `^## `, and the section now sits one level deeper under its
    # release. The helper normalises the depth; the criterion is unchanged.
    $c = Get-MigrationText
    $section = [regex]::Match($c, '(?ms)^## The Tenure[^\r\n]*AEP rename\s*(.+?)(?=^## |\z)')
    if (-not $section.Success) { throw 'the rename section is missing' }
    $s = $section.Groups[1].Value
    if ($s -notmatch '/tenure:[^\r\n]*/aep:') { throw 'the namespace conversion is not stated' }
    if ($s -notmatch '(?i)frozen') { throw 'frozen records are not spared' }
    $s -match '(?i)by content'
  }

  Assert "the plugin installs under the new name end to end" {
    $readme = Get-Content (Join-Path $repo 'README.md') -Raw
    if ($readme -notmatch 'aep@aep-marketplace') { throw 'the README install line does not use the new namespace' }
    if ($readme -cmatch '/tenure:') { throw 'the README still types the old namespace' }
    $readme -match '/aep:configure'
  }
}

# --- ticket aep/03 — the modes ship, and every skill declares exactly one -----

$modeSet = @('discussion', 'research', 'prototype', 'design', 'implementation', 'review', 'maintenance')

Describe-Ticket 'aep/03' 'the modes ship, and every skill declares exactly one' {

  # A skill added later without a mode fails here, which is the acceptance
  # criterion that it cannot ship with its tradeoffs implied.
  #
  # ADR 0055 moved the declaration off a prose body line and under the harness's
  # documented `metadata:` map. The parse is anchored inside the frontmatter
  # block rather than to running text, which is the whole point of the move: the
  # old `^Mode:` match sat in prose and survived only until someone reflowed the
  # paragraph around it.
  Assert "every skill declares exactly one mode, as a field, and the mode exists" {
    $problems = @()
    foreach ($d in (Get-ChildItem $skills -Directory)) {
      $f = Join-Path $d.FullName 'SKILL.md'
      if (-not (Test-Path $f)) { $problems += "$($d.Name) has no SKILL.md"; continue }
      $c = Get-Content $f -Raw
      if (-not (Get-Frontmatter $c)) { $problems += "$($d.Name) has no frontmatter"; continue }
      if ($null -eq (Get-MetadataBlock $c)) { $problems += "$($d.Name) declares no metadata map"; continue }
      $mode = Get-DeclaredMode $c
      if (-not $mode) { $problems += "$($d.Name) does not declare exactly one mode inside metadata"; continue }
      if ($modeSet -notcontains $mode) { $problems += "$($d.Name) declares unknown mode '$mode'" }
    }
    if ($problems) { throw ($problems -join '; ') }
    $true
  }

  # ADR 0032 moved the definitions out of the router: one file per posture,
  # so a stage loads exactly the mode it declared.
  Assert "each of the seven modes ships as its own template, with its tradeoff and its finish line" {
    foreach ($m in $modeSet) {
      $c = Get-SkillFile "configure/modes/$m.template.md"
      if ($c -notmatch "(?m)^# Mode: $m\s*$") { throw "mode '$m' does not name itself" }
      # A posture that gives up nothing is not one, and the build enforces it.
      if ($c -notmatch '(?m)^Gives up:') { throw "mode '$m' gives up nothing" }
      if ($c -notmatch '(?m)^Done:') { throw "mode '$m' does not say what finished means" }
    }
    $true
  }

  Assert "the routing table names each stage's mode, and every named mode is real" {
    $c = Get-SkillFile 'configure/protocol.template.md'
    foreach ($stage in @('configure', 'design', 'implement', 'review', 'research', 'prototype', 'commit')) {
      $row = [regex]::Match($c, "(?m)^\|\s*``/$stage``\s*\|\s*(\S+)\s*\|")
      if (-not $row.Success) { throw "the table has no mode column for /$stage" }
      if ($modeSet -notcontains $row.Groups[1].Value) { throw "/$stage runs under unknown mode '$($row.Groups[1].Value)'" }
    }
    $true
  }

  # Single home. The definition format is the anchor: a `Mode:` heading at any
  # level, or a `Gives up:` line, outside `configure/modes/` is a mode restated
  # elsewhere — including one left behind in the protocol template (ADR 0032).
  Assert "no skill restates a mode's definition" {
    $offenders = @()
    foreach ($f in Get-SkillFiles) {
      $rel = $f.FullName.Substring($skills.Length).TrimStart('\', '/') -replace '\\', '/'
      if ($rel -like 'configure/modes/*') { continue }
      if ((Get-SkillText $f) -match '(?m)^#+ Mode:|^Gives up:') { $offenders += $rel }
    }
    if ($offenders) { throw "a mode definition survives outside configure/modes/, in: $($offenders -join ', ')" }
    $true
  }
}

# --- ticket aep/04 — a discussion is a fourth kind of evidence ----------------

Describe-Ticket 'aep/04' 'a discussion is a fourth kind of evidence' {

  Assert "the evidence guide carries the fourth kind, written by the stage that plans" {
    $c = Get-SkillFile 'configure/policies/evidence.template.md'
    # This ticket's claim is that discussions moved the count off three — not
    # that it stopped there. Pinning the new value broke when scaffolding/03
    # added the fifth kind, so the probe now rejects only the pre-ticket count.
    if ($c -match '(?i)three kinds') { throw 'the count did not move' }
    if ($c -notmatch '(?m)^\|\s*discussions\s*\|\s*`\.claude/evidence/discussions/`\s*\|\s*`/design`\s*\|') { throw 'the discussions row is missing or names another writer' }
    $true
  }

  Assert "the open half is required, and a discussion with nothing open is redirected" {
    $c = Get-SkillFile 'configure/policies/evidence.template.md'
    if ($c -notmatch '(?i)stayed open') { throw 'the record does not carry what stayed open' }
    if ($c -notmatch '(?i)required, not optional') { throw 'the open half reads as optional' }
    $c -match '(?i)nothing open is a decision'
  }

  Assert "a discussion is a record, never a maintained document" {
    $c = Get-SkillFile 'configure/policies/evidence.template.md'
    if ($c -notmatch '(?i)never maintained') { throw 'nothing forbids maintaining one' }
    # The reason it is forbidden, because this rule reads as arbitrary without it.
    $c -match '(?i)fourth knowledge layer'
  }

  Assert "graduation is stated once, and the planning stage points rather than restates" {
    $c = Get-SkillFile 'configure/policies/evidence.template.md'
    if ($c -notmatch '(?i)discussion graduates the same way') { throw 'the guide does not say how one graduates' }
    $d = Get-SkillFile 'design/SKILL.md'
    if ($d -notmatch '(?i)recorded as a discussion') { throw 'the planning stage does not say it may write one' }
    # The format phrase is the single-home anchor: outside the guide it is a
    # restatement.
    $offenders = @()
    foreach ($f in Get-SkillFiles) {
      $rel = $f.FullName.Substring($skills.Length).TrimStart('\', '/') -replace '\\', '/'
      if ($rel -eq 'configure/policies/evidence.template.md') { continue }
      if ((Get-SkillText $f) -match '(?i)what was asked, what was assumed') { $offenders += $rel }
    }
    if ($offenders) { throw "the discussion format is restated in: $($offenders -join ', ')" }
    $true
  }

  Assert "onboarding recognises the directory without pre-creating it" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -notmatch 'out-of-scope, discussions') { throw 'the generated tree does not show the directory' }
    if ($c -notmatch '\{research,prototypes,out-of-scope,discussions\}') { throw 'the lazy-creation list does not include it' }
    $true
  }
}

# --- ticket aep/05 — the protocol file and the entrypoint speak the spec ------

Describe-Ticket 'aep/05' 'the protocol file and the entrypoint speak the spec' {

  Assert "the protocol file names the protocol it implements" {
    if (-not ((Get-SkillFile 'configure/protocol.template.md') -match 'Agentic Engineering Protocol')) { throw 'configure/protocol.template.md does not match: Agentic Engineering Protocol' }
    $true
  }

  Assert "the entrypoint places by the specification's tiers" {
    $c = Get-SkillFile 'configure/CLAUDE.template.md'
    foreach ($tier in @('boot tier', 'scoped tier', 'pointer tier')) {
      if ($c -notmatch [regex]::Escape($tier)) { throw "the entrypoint does not name the $tier" }
    }
    $true
  }

  # The routing table and the skills each declare a mode; conformance is that
  # they agree. A stage rerouted in one place and not the other fails here.
  Assert "the routing table's mode for each spine stage matches the skill's own declaration" {
    $c = Get-SkillFile 'configure/protocol.template.md'
    $problems = @()
    foreach ($stage in @('configure', 'design', 'implement', 'review', 'research', 'prototype', 'commit')) {
      $row = [regex]::Match($c, "(?m)^\|\s*``/$stage``\s*\|\s*(\S+)\s*\|")
      if (-not $row.Success) { $problems += "/$stage has no row"; continue }
      $skill = Get-SkillFile "$stage/SKILL.md"
      # ADR 0054 keeps this table as this repository's actual set and the skill's
      # declaration as the workflow's default; ADR 0055 changed only the form the
      # default is written in. The precedence is untouched — this still compares
      # two homes rather than deriving one from the other.
      $decl = Get-DeclaredMode $skill
      if (-not $decl) { $problems += "/$stage declares no mode inside metadata"; continue }
      if ($row.Groups[1].Value -ne $decl) {
        $problems += "/$stage runs under '$($row.Groups[1].Value)' in the table and '$decl' in the skill"
      }
    }
    if ($problems) { throw ($problems -join '; ') }
    $true
  }
}

# --- ticket aep/06 — the templates and the specification's layout agree -------

Describe-Ticket 'aep/06' 'the templates generate the AEP shape, and the migration converts onto it' {

  # Both documents draw the tree; conformance is that they draw the same one.
  # This is the assertion that found the divergence ADR 0031 records.
  Assert "the generated layout and the specification's canonical layout agree, entry for entry" {
    $spec = Get-Content (Join-Path $repo 'specs.md') -Raw
    $block = [regex]::Match($spec, '(?ms)^```\r?\nCLAUDE\.md.*?^```')
    if (-not $block.Success) { throw 'spec section 21 has no layout block' }
    $specDirs = @([regex]::Matches($block.Value, '(?m)^  (\S+)') | ForEach-Object {
      ($_.Groups[1].Value -replace '/<effort>.*', '') -replace '/$', ''
    })
    $treeDirs = @([regex]::Matches((Get-SkillFile 'configure/SKILL.md'), '(?m)^[├└]── (\S+)') | ForEach-Object {
      $_.Groups[1].Value -replace '/$', ''
    })
    if ($specDirs.Count -eq 0 -or $treeDirs.Count -eq 0) { throw 'one of the two layouts could not be read' }
    foreach ($d in $specDirs) { if ($treeDirs -notcontains $d) { throw "the spec names $d and the generated tree does not" } }
    foreach ($d in $treeDirs) { if ($specDirs -notcontains $d) { throw "the tree generates $d and the spec does not name it" } }
    $true
  }

  Assert "the migration recognises the pre-modes protocol file by content, converts, and re-runs clean" {
    # Anchored on `^## `, and the section now sits one level deeper under its
    # release. The helper normalises the depth; the criterion is unchanged.
    $c = Get-MigrationText
    $s = [regex]::Match($c, '(?ms)^## The pre-modes protocol file\s*(.+?)(?=^## |\z)')
    if (-not $s.Success) { throw 'the pre-modes section is missing' }
    if ($s.Groups[1].Value -notmatch '### Mode:') { throw 'detection is not anchored to content' }
    if ($s.Groups[1].Value -notmatch '(?i)re-run changes nothing') { throw 'idempotence is not stated' }
    $s.Groups[1].Value -match '(?i)preserved'
  }
}

# --- ticket aep/08 — the suite holds the budget, and the boot tier stays small -

Describe-Ticket 'aep/08' 'the suite re-anchored: coverage, conformance, and the boot budget' {

  # The boot tier is measured as loaded: block-level HTML comments are stripped
  # by the harness before injection, so they cost nothing and are excluded.
  function Get-LoadedLength {
    param([string]$RelativePath)
    $c = Get-Content (Join-Path $repo $RelativePath) -Raw
    ([regex]::Replace($c, '(?ms)^<!--.*?-->\r?\n?', '')).Length
  }

  # The ratchet. Started at 9,500 over a measured 9,206; slice one of aep/09
  # brought the tier to 7,729 and the ceiling to 7,800; slice two moved the
  # conventions defaults and the pointer-recovery machinery out of the boot
  # tier and landed the ceiling at 5,000. aep/11 raised it to 5,600 when the
  # user placed the what-gets-written directives in the always-on tier —
  # which is the deliberate act with a diff this comment requires, never drift.
  # 5,800 for the eighth directive, forbidding `.claude/` file references from
  # comments and repository documentation: measured 5,725, and the raise is
  # recorded here rather than absorbed, exactly as the last one was.
  #
  # 7,100 for `placement.md`, a third always-on rule the user asked for: every
  # file AEP owns is in the plugin or under `.claude/`, and only `CLAUDE.md` at
  # the root. It is unconditional because it governs where a file is *created*,
  # and a scoped rule arrives only after a covered file has been read — too late
  # to inform the decision. Measured 7,039. This is the largest single raise the
  # ratchet has taken, and it was paid down twice before being made: the rule was
  # compressed from 1,661 characters, and the paragraph restating ADR 0006's
  # reasoning about the root namespace was cut for deciding nothing the rule
  # above it had not already decided. It is a deliberate act with a diff, and the
  # cost buys a placement answer on the turn a file is created.
  # 7,300 for entry/01's obligation: the classification line gains the entry
  # stage, and the stage is then entered rather than named for the user to run
  # (ADR 0061). Unconditional because the failure it corrects is a stage *not
  # being selected* — anything reached by selection, a router skill above all,
  # cannot fix that, so this is only correct in the tier that loads without being
  # chosen. Measured 7,213.
  #
  # Paid down before the raise, and worth distinguishing from the relocation this
  # ratchet exists to refuse: the first version carried the destination table in
  # the tier too, at ~490 characters. The table moved to the protocol file, which
  # cut the addition to ~170 — but it moved because the always-on tier may name no
  # command (tenure/20, streamline/02), not to fit a budget. The router is where
  # concrete routing already lives; the ceiling relief is a consequence of the
  # correct placement rather than the reason for it. The tier keeps the
  # obligation, which is the part that must fire on every turn.
  Assert "the always-on load is under the stated ceiling, measured rather than described" {
    $ceiling = 7300
    $total = 0
    $unscoped = @('CLAUDE.md')
    foreach ($f in (Get-ChildItem (Join-Path $repo '.claude/rules') -Filter '*.md')) {
      $c = Get-Content $f.FullName -Raw
      if ($c -notmatch '(?ms)\A---\r?\n.*?^paths:') { $unscoped += ".claude/rules/$($f.Name)" }
    }
    foreach ($f in $unscoped) { $total += Get-LoadedLength $f }
    if ($total -gt $ceiling) { throw "the boot tier loads $total chars against a ceiling of $ceiling" }
    $true
  }

  # Adding a rules/ file without paths: frontmatter is a permanent per-turn
  # tax; the three named here are the only ones that earn it. `placement.md`
  # joined them because it governs where a file is *created*, and a scoped rule
  # loads only after a covered file has been read — which is after the placement
  # decision it exists to inform has already been made.
  Assert "every rule beyond the three unconditional ones is path-scoped" {
    $offenders = @()
    foreach ($f in (Get-ChildItem (Join-Path $repo '.claude/rules') -Filter '*.md')) {
      if (@('precedence.md', 'engineering.md', 'placement.md') -contains $f.Name) { continue }
      $c = Get-Content $f.FullName -Raw
      if ($c -notmatch '(?ms)\A---\r?\n.*?^paths:') { $offenders += $f.Name }
    }
    if ($offenders) { throw "unconditionally loaded without earning it: $($offenders -join ', ')" }
    $true
  }

  # Closed by the coverage audit: the report-when-clean rule had no assertion,
  # so compression could have dropped the one sentence that makes a lapse
  # visible. Anchored to the concept, not the wording.
  Assert "the verification report is required even when there is nothing to verify" {
    $c = Get-SkillFile 'configure/protocol.template.md'
    if ($c -notmatch '(?i)including when there was nothing to verify|nothing to verify still') { throw 'the clean path no longer reports' }
    $c -match '(?i)silence is indistinguishable'
  }
}

# --- ticket aep/10 — the suite derives its general assertions from the spec ---

# `specs.md` is normative (ADR 0029). Where it states an enumerable fact about
# what ships, the suite reads the fact from the specification rather than
# hard-coding a copy — amending the spec then fails the build until the skills
# follow, which is the evolution rule with teeth in both directions. The layout
# agreement in aep/06 established the pattern; prose principles keep their
# hand-anchored assertions, because parsing prose for meaning is a guess
# wearing a regex.

Describe-Ticket 'aep/10' 'the suite derives its general assertions from specs.md' {

  function Get-SpecSection {
    param([int]$Number)
    $spec = Get-Content (Join-Path $repo 'specs.md') -Raw
    $m = [regex]::Match($spec, "(?ms)^## $Number\.\s[^\r\n]*\r?\n(.+?)(?=^## |\z)")
    if (-not $m.Success) { throw "spec has no section $Number" }
    $m.Groups[1].Value
  }

  Assert "the mode set ships exactly as section 9 enumerates it, in both directions" {
    $s = Get-SpecSection 9
    $specModes = @([regex]::Matches($s, '(?m)^- \*\*(\w+)\*\*') | ForEach-Object { $_.Groups[1].Value.ToLower() })
    if ($specModes.Count -eq 0) { throw 'section 9 enumerates no modes' }
    foreach ($m in $specModes) {
      if (-not (Test-Path (Join-Path $skills "configure/modes/$m.template.md"))) { throw "the spec names mode '$m' and no template ships it" }
    }
    foreach ($f in (Get-ChildItem (Join-Path $skills 'configure/modes') -Filter '*.template.md')) {
      $name = $f.Name -replace '\.template\.md$', ''
      if ($specModes -notcontains $name) { throw "mode '$name' ships and section 9 does not name it" }
    }
    $true
  }

  Assert "every workflow section 10 names ships as a skill" {
    $s = Get-SpecSection 10
    $named = @([regex]::Matches($s, '\*\*(\w[\w-]*)\*\*') | ForEach-Object { $_.Groups[1].Value })
    if ($named.Count -lt 7) { throw "section 10 names only $($named.Count) workflows" }
    foreach ($w in $named) {
      if (-not (Test-Path (Join-Path $skills "$w/SKILL.md"))) { throw "the spec names workflow '$w' and no skill ships it" }
    }
    $true
  }

  Assert "each evidence kind in the section 21 layout is a row in the evidence policy" {
    $spec = Get-Content (Join-Path $repo 'specs.md') -Raw
    $line = [regex]::Match($spec, '(?m)^.*out-of-scope/.*$')
    if (-not $line.Success) { throw 'section 21 no longer lists the evidence kinds' }
    $kinds = @([regex]::Matches($line.Value, '([\w-]+)/') | ForEach-Object { $_.Groups[1].Value })
    if ($kinds.Count -lt 4) { throw "the layout lists only $($kinds.Count) evidence kinds" }
    $c = Get-SkillFile 'configure/policies/evidence.template.md'
    foreach ($k in $kinds) {
      # The kind column is descriptive prose; the directory column is the
      # invariant the layout shares, so the row is found by its directory.
      if ($c -notmatch "(?m)^\|[^|\r\n]+\|\s*``\.claude/evidence/$([regex]::Escape($k))/``\s*\|") { throw "the spec lists evidence kind '$k' and the policy has no row writing to its directory" }
    }
    $true
  }
}

# --- ticket aep/11 — always-on standards for what gets written ----------------

Describe-Ticket 'aep/11' 'the always-on tier covers what gets written, and close-out invokes the commit skill' {

  # Terse directives in the always-on tier; the elaborations keep their single
  # homes in the skills, which the $placed accounting and the single-home sweep
  # continue to pin. Checked in both copies — the template that ships and the
  # rules file this repository runs on.
  $directives = [ordered]@{
    # Either emphasis marker. The guard exists to catch the directive being
    # deleted, and it once went red because the line was rewritten `*why*` →
    # `_why_` — a markdown detail it was never aimed at.
    'comments say why, never what'   = '(?i)comments say [*_]?why[*_]?'
    'the workaround-comment test'    = '(?i)workaround[^\r\n]{0,80}fix the code'
    'every public API is documented' = '(?i)document every public API'
    'files named for one thing'      = '(?i)directories carry the qualifiers'
    'no needless abbreviations'      = '(?i)abbreviations? in names'
    'tests near the code'            = '(?i)near the code as the (language|tooling)'
  }
  foreach ($d in $directives.Keys) {
    $pattern = $directives[$d]
    Assert "the always-on standards carry: $d" {
      if ((Get-SkillFile 'configure/engineering.template.md') -notmatch $pattern) { throw 'missing from the template' }
      if ((Get-Content (Join-Path $repo '.claude/rules/engineering.md') -Raw) -notmatch $pattern) { throw "missing from this repository's copy" }
      $true
    }
  }

  # The close-out names the skill invocation, so "through /commit" cannot be
  # satisfied by a hand-rolled git commit that mentions the word.
  Assert "/implement's close-out invokes the commit skill, and rules out the hand-rolled commit" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)invok\w+ the `commit` skill') { throw 'the invocation is not named' }
    $c -match '(?i)never a hand-rolled `git commit`'
  }
}

# --- ticket aep/12 — formatters are made to skip the protocol directory -------

Describe-Ticket 'aep/12' 'whatever formats a repository is made to skip .claude/' {

  # Bound to the paragraph, not to the file. Every guard below would otherwise
  # pass on a coincidence somewhere else in a 200-line skill — `.claude/tools/`
  # appears four times in it already, and the routing claim is only true if it
  # is made *here*.
  $formatterSection = {
    $c = Get-SkillFile 'configure/SKILL.md'
    $m = [regex]::Match($c, '(?ms)^\*\*Whatever formats this repository.*?(?=^#{2}\s)')
    if (-not $m.Success) { throw 'the formatter instruction is gone from step 4' }
    $m.Value
  }

  Assert "step 4 makes the detected formatters skip the protocol directory" {
    $s = & $formatterSection
    if ($s -notmatch '(?i)skip `\.claude/`') { throw 'it never says what the formatters must do' }
    $s -match '(?i)step 1'
  }

  # The *how* is a tool guide's, like every other invocation in the framework.
  # Asserted with the gap clause, because an instruction that routes to
  # `.claude/tools/` and stays silent about a missing entry is read as licence
  # to guess the filename — which is the failure the routing exists to stop.
  Assert "the how is routed through .claude/tools/, and a missing entry is a gap" {
    $s = & $formatterSection
    if ($s -notmatch '`\.claude/tools/`') { throw 'the instruction does not route the mechanism anywhere' }
    if ($s -notmatch '(?i)own ignore mechanism') { throw 'it prescribes a mechanism instead of routing to one' }
    $s -match '(?i)configuration gap'
  }

  # Detection is off the repository (ADR 0019's rule, applied to one more tool).
  # A product name appearing here means the next reader edits a hardcoded
  # filename instead of reading the repository, so this is the guard that has to
  # fire on the tempting version of the change rather than on its absence.
  Assert "the instruction names no specific formatter" {
    $named = @('prettier', 'biome', 'dprint', 'eslint', 'rustfmt', 'gofmt', 'black', 'ruff',
               'markdownlint', 'editorconfig', 'clang-format', 'ktlint', 'spotless')
    $s = & $formatterSection
    $hits = @($named | Where-Object { $s -match "(?i)$([regex]::Escape($_))" })
    if ($hits) { throw "hardcodes: $($hits -join ', ')" }
    $true
  }

  # The instruction is only actionable if the detection step collected the
  # thing, and only derivable if the tool list expects a file for it. Two sites,
  # two assertions — folded into one, either could rot while the other held.
  Assert "step 1 reads formatting, and the tool list expects a file for the formatter" {
    $detect = Get-Section (Get-SkillFile 'configure/SKILL.md') '1 — Detect'
    if ($detect -notmatch '(?i)build, test, format') { throw 'step 1 never looks at formatting' }
    # `.*$` rather than `[^\r\n]*$`: under CRLF the negated class stops before
    # the `\r`, where `$` cannot match — it anchors immediately before `\n`.
    $tools = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?m)^\*\*`\.claude/tools/\*\.md`\*\*.*$').Value
    if (-not $tools) { throw 'the tool-derivation paragraph moved' }
    $tools -match '(?i)formatter'
  }

  # The outcome, not the edit. A run that wrote an ignore entry a config file
  # overrides has done the work and not the job.
  Assert "step 6 validates that nothing formatting the repository reaches .claude/" {
    $validate = Get-Section (Get-SkillFile 'configure/SKILL.md') '6 — Validate'
    if (-not ($validate -match '(?i)nothing that formats this repository reaches `\.claude/`')) { throw 'configure/SKILL.md does not match: (?i)nothing that formats this repository reaches `\.claude/`' }
    $true
  }

  # The reasoning is recorded here and the bound travels in the shipped prose,
  # deliberately not as a citation: a skill installed elsewhere would be
  # pointing at a decision record that repository does not have. So the two
  # halves are asserted at their own homes rather than through a cross-reference.
  Assert "the decision is recorded here, and the shipped instruction carries its own bound" {
    $adr = Join-Path $repo '.claude/decisions/0033-configure-writes-the-formatter-exclusion-outside-dot-claude.md'
    if (-not (Test-Path $adr)) { throw 'the decision behind the exception is unrecorded' }
    (& $formatterSection) -match '(?i)only thing `?/configure`? writes outside'
  }

  # ADR 0006 is bounded, not overturned. Asserted here as well as at its own
  # ticket because this is the change that would have overturned it.
  Assert "ADR 0006's root-ignore rule still stands beside the exception" {
    if (-not ((Get-SkillFile 'configure/SKILL.md') -match '(?i)root `?\.gitignore`? is left alone')) { throw 'configure/SKILL.md does not match: (?i)root `?\.gitignore`? is left alone' }
    $true
  }
}

# --- ticket agentic/01 — the expansion is Agentic, and it stops at records ----

Describe-Ticket 'agentic/01' 'the expansion is Agentic, and the rename stops at frozen records' {

  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  $old = 'AI Engineering Protocol'
  $new = 'Agentic Engineering Protocol'

  # The three frozen records the rename deliberately did not touch: a committed
  # ADR's prose does not move and history is not repaired (ADR 0034).
  $frozenRecords = @(
    '.claude/decisions/0029-specs-md-is-the-normative-specification.md'
    '.claude/tickets/aep/spec.md'
    '.claude/tickets/aep/issues/02-rename-tenure-to-aep.md'
  )

  # Everything else that may hold the string, each for a reason that is not "it
  # was missed". The two effort records cannot describe the rename without
  # naming what it renamed; README and NOTICE carry the old name deliberately,
  # as a former name, and are pinned positively below instead; and this file is
  # the guard's own home.
  $namesItLegitimately = $frozenRecords + @(
    '.claude/decisions/0034-the-rename-to-agentic-stops-at-frozen-records.md'
    '.claude/tickets/agentic/issues/01-rename-the-expansion-to-agentic.md'
    'README.md'
    'NOTICE'
    'scripts/verify.ps1'
  )

  # Anchored to the live surface rather than to a list of known sites: any file
  # outside the exemptions above. A file added later is covered the moment it
  # exists, which is the half a named-sites guard cannot do. The extensions are
  # the documentation surface — the only place an expansion can be written.
  Assert "no live file expands AEP as the AI Engineering Protocol" {
    $exempt = $namesItLegitimately | ForEach-Object { (Join-Path $repo $_) }
    $hits = Get-ChildItem $repo -Recurse -File -Include *.md, *.json, *.ps1 |
      Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' } |
      Where-Object { $exempt -notcontains $_.FullName } |
      Where-Object { (Get-Content $_.FullName -Raw) -match [regex]::Escape($old) }
    if ($hits) {
      $names = ($hits | ForEach-Object { $_.FullName.Substring($repo.Length + 1) }) -join ', '
      throw "the old expansion is live in: $names"
    }
    $true
  }

  # The other half, and deliberately a second assertion. One guard covering both
  # directions passes while either holds, so deleting the residue would leave it
  # green — which is the failure this pair exists to make impossible.
  Assert "every frozen record still carries the expansion it was written under" {
    foreach ($f in $frozenRecords) {
      if ((Get-RepoText $f) -notmatch [regex]::Escape($old)) {
        throw "$f lost the name it was written under — history is not repaired"
      }
    }
    $true
  }

  Assert "the entrypoint, the router, and this repository's Context all say Agentic" {
    foreach ($f in @('CLAUDE.md', '.claude/protocol.md', '.claude/contexts/repository.md')) {
      if ((Get-RepoText $f) -notmatch [regex]::Escape($new)) { throw "$f does not name the protocol" }
    }
    $true
  }

  # The residue is only defensible if a reader can tell it from an unfinished
  # rename without opening the history, which is what the trail buys. These two
  # are exempt from the sweep, so the current name is asserted here too —
  # without it a regression to the old expansion as the *current* name would sit
  # in the one place the sweep cannot see.
  Assert "the README and the NOTICE carry the current name and both former ones" {
    foreach ($f in @('README.md', 'NOTICE')) {
      $c = Get-RepoText $f
      if ($c -notmatch [regex]::Escape($new)) { throw "$f does not name the framework" }
      if ($c -notmatch 'Tenure') { throw "$f does not name the first former name" }
      if ($c -notmatch [regex]::Escape($old)) { throw "$f does not name the second former name" }
    }
    $true
  }

  Assert "the acronym did not move" {
    $plugin = Get-RepoText '.claude-plugin/plugin.json' | ConvertFrom-Json
    if ($plugin.name -ne 'aep') { throw "the plugin id moved to '$($plugin.name)'" }
    $true
  }

  # Pinned to the literal deliberately: specs.md makes every version bump a
  # deliberate amendment recorded as a Decision, so a guard that has to be
  # edited alongside one is doing its job rather than getting in the way.
  Assert "the specification is released at 1.14.0, not a draft" {
    $c = Get-RepoText 'specs.md'
    # Read from the manifest rather than pinned. A literal here had to be
    # hand-edited on every release, and twice in one session it was edited in one
    # of its two homes and not the other — so the guard that exists to catch a
    # forgotten bump was itself the thing forgotten. axis/04 asserts the manifest,
    # the specification and the template agree; this asserts the pair is released.
    $running = (Get-Content (Join-Path $repo '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json).version
    if ($running -notmatch '^\d+\.\d+\.\d+$') { throw "the manifest carries no release version: $running" }
    if ($c -notmatch ('(?m)^\*\*Version:\*\*\s*' + [regex]::Escape($running) + '\s*$')) {
      throw "the specification is not at the released $running"
    }
    $true
  }

  # Read off the specification rather than pinned to a literal, so the next
  # amendment cannot bump one of the two and leave this passing.
  Assert "the plugin manifest states the specification's version" {
    $spec = Get-RepoText 'specs.md'
    if ($spec -notmatch '(?m)^\*\*Version:\*\*\s*(\S+)\s*$') { throw 'the specification states no version' }
    $specVersion = $Matches[1]
    $plugin = Get-RepoText '.claude-plugin/plugin.json' | ConvertFrom-Json
    if ($plugin.version -ne $specVersion) {
      throw "the plugin is $($plugin.version) and the specification is $specVersion"
    }
    $true
  }

  Assert "the audit branch heals an installed protocol file that predates the rename" {
    if (-not ((Get-AuditReach) -match "(?s)(?i)framework's name")) { throw 'Get-AuditReach does not match: "(?s)(?i)framework''s name"' }
    $true
  }
}

# --- ticket fieldwork/01 — the tracker declares what a ticket is --------------

Describe-Ticket 'fieldwork/01' 'the tracker declares what a ticket is, and the map reads it' {

  $trackerTemplate = 'configure/policies/tracker.template.md'
  $mapsTemplate    = 'configure/policies/maps.template.md'

  Assert "the tracker template declares what a ticket is, and carries the detect test" {
    $s = Get-Section (Get-SkillFile $trackerTemplate) 'What a ticket is'
    if (-not ($s -match '(?i)branch-bound')) { throw ($trackerTemplate + ' does not match: (?i)branch-bound') }
    if (-not ($s -match '(?i)tracked intent')) { throw ($trackerTemplate + ' does not match: (?i)tracked intent') }
    if (-not ($s -match $rulePattern['the ticket-branch detect test'])) { throw ($trackerTemplate + ' does not match: $rulePattern[''the ticket-branch detect test'']') }
    $true
  }

  Assert "the maps template places decision work by reading the declaration" {
    $s = Get-Section (Get-SkillFile $mapsTemplate) 'Where decision work lives'
    if (-not ($s -match '(?i)what a ticket is')) { throw ($mapsTemplate + ' does not match: (?i)what a ticket is') }
    if (-not ($s -match '(?i)design document')) { throw ($mapsTemplate + ' does not match: (?i)design document') }
    $true
  }

  # The defect that produced the field damage: an unconditional claim that
  # decision work goes on the tracker. The declaration branch replaces it, so
  # its return is a regression even beside a correct branch.
  Assert "the maps template no longer asserts decision tickets unconditionally" {
    $c = Get-SkillFile $mapsTemplate
    if ($c -match '(?i)artifact of \**decision tickets') { throw 'the unconditional claim is back' }
    $true
  }

  Assert "a tracker policy that predates the declaration is a stated configuration gap, not a guess" {
    $s = Get-Section (Get-SkillFile $mapsTemplate) 'Where decision work lives'
    if (-not ($s -match '(?i)predates')) { throw ($mapsTemplate + ' does not match: (?i)predates') }
    if (-not ($s -match '(?i)configuration gap')) { throw ($mapsTemplate + ' does not match: (?i)configuration gap') }
    $true
  }

  Assert "/configure derives the declaration at generate time" {
    $s = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Generate'
    if (-not ($s -match '(?i)what a ticket is')) { throw 'configure/SKILL.md does not match: (?i)what a ticket is' }
    $true
  }

  Assert "/configure's audit re-checks the declaration against the version-control policy" {
    $s = Get-Section (Get-SkillFile 'configure/SKILL.md') 'Audit'
    if (-not ($s -match '(?i)what a ticket is')) { throw 'configure/SKILL.md does not match: (?i)what a ticket is' }
    $true
  }
}

# --- ticket fieldwork/02 — the map template stops contradicting the format ----

Describe-Ticket 'fieldwork/02' 'the map template stops contradicting the ticket format' {

  $mapsTemplate = 'configure/policies/maps.template.md'

  # The prose said two differences while the template silently made a third —
  # a bare-question title where tickets.md demands a Conventional subject.
  Assert "the decision-ticket template's example title is a Conventional Commit subject" {
    $s = Get-Section (Get-SkillFile $mapsTemplate) 'Decision tickets'
    if ($s -match '<the question, as a title>') { throw 'the bare-question title is back' }
    $s -match '(?m)^# <NN> — type\(scope\)'
  }

  Assert "the prose counts three differences, and gives the title its rationale" {
    $s = Get-Section (Get-SkillFile $mapsTemplate) 'Decision tickets'
    if (-not ($s -match '(?i)three differences')) { throw ($mapsTemplate + ' does not match: (?i)three differences') }
    if (-not ($s -match '(?i)records? the answer')) { throw ($mapsTemplate + ' does not match: (?i)records? the answer') }
    $true
  }

  Assert "numbering defers to the tracker where the tracker assigns ids" {
    $s = Get-Section (Get-SkillFile $mapsTemplate) 'Decision tickets'
    if (-not ($s -match '(?i)tracker[^\r\n]{0,60}assigns')) { throw ($mapsTemplate + ' does not match: (?i)tracker[^\r\n]{0,60}assigns') }
    if (-not ($s -match '(?i)only (number|id)')) { throw ($mapsTemplate + ' does not match: (?i)only (number|id)') }
    $true
  }

  Assert "a decision edge is answer-gating, never a stacking instruction" {
    $s = Get-SkillFile $mapsTemplate
    if (-not ($s -match $rulePattern['the answer-gating edge rule'])) { throw ($mapsTemplate + ' does not match: $rulePattern[''the answer-gating edge rule'']') }
    if (-not ($s -match '(?i)never a stacking')) { throw ($mapsTemplate + ' does not match: (?i)never a stacking') }
    $true
  }

  Assert "the design document's fate after the map exists is stated" {
    $s = Get-Section (Get-SkillFile $mapsTemplate) 'The map file'
    if (-not ($s -match '(?i)supersede')) { throw ($mapsTemplate + ' does not match: (?i)supersede') }
    $true
  }

  # ADR 0036: the lifecycle rides native issue state — a decision resolved by
  # label was this file's own contradiction of it.
  Assert "resolving a decision on GitHub closes the issue, not a label" {
    if ((Get-SkillFile $mapsTemplate) -match '(?i)a label on GitHub') { throw 'the label form is back' }
    $true
  }
}

# --- ticket fieldwork/03 — the build lifecycle has a GitHub form --------------

Describe-Ticket 'fieldwork/03' 'the build lifecycle has a GitHub form' {

  $ticketsTemplate = 'configure/policies/tickets.template.md'
  $forge           = 'configure/tools/github.md'

  # ADR 0036: the four states ride the issue's native state. Every mapping
  # clause below is conjoined, so deleting any one of them goes red.
  Assert "open and resolved ride the issue's native state" {
    $s = Get-Section (Get-SkillFile $ticketsTemplate) 'Format'
    if (-not ($s -match '(?i)`open`[^\r\n]{0,40}open issue')) { throw ($ticketsTemplate + ' does not match: (?i)`open`[^\r\n]{0,40}open issue') }
    if (-not ($s -match '(?i)closed as completed')) { throw ($ticketsTemplate + ' does not match: (?i)closed as completed') }
    $true
  }

  Assert "blocked stays open, its reason in the body beside the edges" {
    $s = Get-Section (Get-SkillFile $ticketsTemplate) 'Format'
    if (-not ($s -match '(?i)`blocked`[^\r\n]{0,40}stays open')) { throw ($ticketsTemplate + ' does not match: (?i)`blocked`[^\r\n]{0,40}stays open') }
    if (-not ($s -match '## Blocked')) { throw ($ticketsTemplate + ' does not match: ## Blocked') }
    $true
  }

  Assert "obsolete closes as not planned, and the reason comment is mandatory" {
    $s = Get-Section (Get-SkillFile $ticketsTemplate) 'Format'
    if (-not ($s -match $rulePattern['the obsolete-closure form'])) { throw ($ticketsTemplate + ' does not match: $rulePattern[''the obsolete-closure form'']') }
    if (-not ($s -match '(?i)not[ -]planned[^\r\n]{0,120}mandatory')) { throw ($ticketsTemplate + ' does not match: (?i)not[ -]planned[^\r\n]{0,120}mandatory') }
    $true
  }

  Assert "the GitHub form needs no label the repository does not already have" {
    $s = Get-Section (Get-SkillFile $ticketsTemplate) 'Format'
    if (-not ($s -match '(?i)zero (new )?labels')) { throw ($ticketsTemplate + ' does not match: (?i)zero (new )?labels') }
    $true
  }

  # The claim this ticket removes. Matched by subject — states represented as
  # labels — and over every shipped file, not the one sentence that carried it.
  Assert "the claim that lifecycle states are labels is gone" {
    $back = Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match '(?i)states? (are|is|become|map(s|ped)? (on)?to|correspond to|as) (a |the )?labels?' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) }
    if ($back) { throw "the labels claim is back in: $($back -join ', ')" }
    $true
  }

  Assert "the forge reference has the close-as-not-planned invocation, reason flag included" {
    $s = Get-SkillFile $forge
    if (-not ($s -match 'gh issue close')) { throw ($forge + ' does not match: gh issue close') }
    if (-not ($s -match '--reason "not planned"')) { throw ($forge + ' does not match: --reason "not planned"') }
    if (-not ($s -match '--comment')) { throw ($forge + ' does not match: --comment') }
    $true
  }
}

# --- ticket fieldwork/04 — the forge covers pinning and sub-issue removal -----

Describe-Ticket 'fieldwork/04' 'the forge reference covers pinning and sub-issue removal' {

  $forge = 'configure/tools/github.md'

  Assert "pinning and unpinning are documented invocations" {
    $s = Get-SkillFile $forge
    if (-not ($s -match 'gh issue pin')) { throw ($forge + ' does not match: gh issue pin') }
    if (-not ($s -match 'gh issue unpin')) { throw ($forge + ' does not match: gh issue unpin') }
    $true
  }

  # GitHub's docs cap pinned issues at three, and neither they nor the help
  # text say whether pinning at cap refuses or evicts — so neither may the
  # reference.
  Assert "the at-cap behaviour is marked untested, not guessed" {
    $s = Get-Section (Get-SkillFile $forge) 'Pin'
    if (-not ($s -match '(?i)cap')) { throw ($forge + ' does not match: (?i)cap') }
    if (-not ($s -match '(?i)untested')) { throw ($forge + ' does not match: (?i)untested') }
    $true
  }

  # `sub_issue\b` cannot match the plural, so this only passes on the
  # singular removal path the API actually has.
  Assert "sub-issue removal is an invocable entry on the singular path" {
    $s = Get-SkillFile $forge
    if (-not ($s -match '(?i)--method DELETE[^\r\n]*/sub_issue\b')) { throw ($forge + ' does not match: (?i)--method DELETE[^\r\n]*/sub_issue\b') }
    $true
  }

  # `-cmatch`: the whole point is the case of the flag, which `-match` erases.
  # The flag is bound to the DELETE invocation itself — matched anywhere in the
  # section, the attach call's own `-F` would satisfy it.
  Assert "the removal entry types its id as an integer, with the trap named" {
    $s = Get-Section (Get-SkillFile $forge) 'sub-issues'
    if (-not ($s -cmatch '(?s)--method DELETE[^\r\n]*sub_issue\b.{0,40}-F sub_issue_id=')) {
      throw 'the sub-issues section does not bind an uppercase -F sub_issue_id= to the DELETE invocation'
    }
    if (-not ($s -match '(?i)integer')) { throw 'the sub-issues section does not name the integer-typing trap' }
    $true
  }

  # The field run recorded the typing trap as shared with the attach call —
  # a string-typed `-f` id is the failure the entry exists to prevent, so it
  # may not survive anywhere in the file.
  Assert "no sub-issue invocation sends a string-typed id" {
    if ((Get-SkillFile $forge) -cmatch '(?m)-f sub_issue_id=') { throw 'a string-typed sub_issue_id is back' }
    $true
  }
}

# --- ticket fieldwork/05 — the git reference names where the Marker is read ---

Describe-Ticket 'fieldwork/05' 'the git reference names where the Marker is read' {

  $gitRef = 'configure/tools/git.md'

  # The field failure: the check's placeholder rode on a recalled path, and a
  # wrong recall produced a confident false verification report.
  Assert "the Marker check opens with the read — the path, and the field that yields the commit" {
    $s = Get-Section (Get-SkillFile $gitRef) 'Check the Marker'
    if (-not ($s -match [regex]::Escape('.claude/position/marker.json'))) { throw ($gitRef + ' does not match: [regex]::Escape(''.claude/position/marker.json'')') }
    if (-not ($s -match '"commit"')) { throw ($gitRef + ' does not match: "commit"') }
    $true
  }

  Assert "a missing marker file is an answer — unverified — never a path to re-guess" {
    $s = Get-Section (Get-SkillFile $gitRef) 'Check the Marker'
    if (-not ($s -match '(?i)missing')) { throw ($gitRef + ' does not match: (?i)missing') }
    if (-not ($s -match '(?i)unverified')) { throw ($gitRef + ' does not match: (?i)unverified') }
    $true
  }

  # The single home is the invocation home. The migration table is the one
  # exemption — a rename row cannot point at itself.
  Assert "the marker path has exactly one live home, and no skill restates it" {
    $homes = Get-SkillFiles |
      Where-Object { (Get-Content $_.FullName -Raw) -match 'position/marker' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) -replace '\\', '/' }
    $allowed = @('configure/tools/git.md', 'configure/MIGRATION.md', 'configure/migration-changelog.md')
    $stray = @($homes | Where-Object { $allowed -notcontains $_ })
    if ($stray) { throw "the marker path is restated in: $($stray -join ', ')" }
    if ($homes -notcontains 'configure/tools/git.md') { throw 'named nowhere live' }
    $true
  }

  # The writer still has to find the path — by pointer, from its own section.
  Assert "/commit's Marker section reaches the path through the git reference" {
    $s = Get-Section (Get-SkillFile 'commit/SKILL.md') 'Advance the Marker'
    if (-not ($s -match 'git\.md')) { throw 'commit/SKILL.md does not match: git\.md' }
    $true
  }

  Assert "/handoff reaches the path through the git reference" {
    if (-not ((Get-SkillFile 'handoff/SKILL.md') -match 'tools/git\.md')) { throw 'handoff/SKILL.md does not match: tools/git\.md' }
    $true
  }
}

# --- ticket fieldwork/06 — a build ticket may declare a design increment ------

Describe-Ticket 'fieldwork/06' 'a build ticket may declare a design increment' {

  $ticketsTemplate = 'configure/policies/tickets.template.md'
  $mapsTemplate    = 'configure/policies/maps.template.md'

  Assert "the ticket format declares increments: step, question, and type, at design time only" {
    $s = Get-Section (Get-SkillFile $ticketsTemplate) 'Declared increments'
    if (-not ($s -match '(?i)<step>')) { throw ($ticketsTemplate + ' does not match: (?i)<step>') }
    if (-not ($s -match '(?i)question')) { throw ($ticketsTemplate + ' does not match: (?i)question') }
    if (-not ($s -match '(?i)type')) { throw ($ticketsTemplate + ' does not match: (?i)type') }
    if (-not ($s -match $rulePattern['the increment-declaration timing rule'])) { throw ($ticketsTemplate + ' does not match: $rulePattern[''the increment-declaration timing rule'']') }
    $true
  }

  # The gate conjunct is anchored to the smell sentence itself — 'tier' alone
  # travels with pre-existing §5 text and would survive the clause's deletion.
  Assert "the design stage writes them, and the scope assessment gates the declaration" {
    $s = Get-Section (Get-SkillFile 'design/SKILL.md') 'Plan'
    if (-not ($s -match '(?i)declared increments?')) { throw 'design/SKILL.md does not match: (?i)declared increments?' }
    if (-not ($s -match '(?i)answerable up front')) { throw 'design/SKILL.md does not match: (?i)answerable up front' }
    $true
  }

  # ADR 0037: AFK resolves inline in the same commit; HITL stops at a point
  # the human could schedule, and that stop is not `blocked`.
  Assert "/implement resolves AFK inline and stops at HITL holding the claim, apart from blocked" {
    $s = Get-Section (Get-SkillFile 'implement/SKILL.md') 'Build'
    if (-not ($s -match '(?i)inline')) { throw 'implement/SKILL.md does not match: (?i)inline' }
    if (-not ($s -match '(?i)same commit')) { throw 'implement/SKILL.md does not match: (?i)same commit' }
    if (-not ($s -match $rulePattern['the increment hold rule'])) { throw 'implement/SKILL.md does not match: $rulePattern[''the increment hold rule'']' }
    if (-not ($s -match '(?i)not `?blocked`?')) { throw 'implement/SKILL.md does not match: (?i)not `?blocked`?' }
    $true
  }

  # The load-bearing half, shipped in the same edit as the mechanism —
  # without it, declared increments are a scope-creep vector.
  Assert "the guardrail: never invented, and an undeclared decision still blocks" {
    $s = Get-Section (Get-SkillFile 'implement/SKILL.md') 'Build'
    if (-not ($s -match $rulePattern['the increment never-invented guardrail'])) { throw 'implement/SKILL.md does not match: $rulePattern[''the increment never-invented guardrail'']' }
    if (-not ($s -match '(?i)undeclared[^\r\n]{0,120}`?blocked`?')) { throw 'implement/SKILL.md does not match: (?i)undeclared[^\r\n]{0,120}`?blocked`?' }
    $true
  }

  Assert "the map exits on settled-or-declared, naming the tickets that carry increments" {
    $s = Get-Section (Get-SkillFile $mapsTemplate) 'Leaving the map'
    if (-not ($s -match $rulePattern['the map settled-or-declared exit'])) { throw ($mapsTemplate + ' does not match: $rulePattern[''the map settled-or-declared exit'']') }
    if (-not ($s -match '(?i)which tickets|names[^\r\n]{0,60}tickets')) { throw ($mapsTemplate + ' does not match: (?i)which tickets|names[^\r\n]{0,60}tickets') }
    $true
  }

  # ADR 0029: conform or amend in the same change. The amendment shipped at
  # design capture; this asserts the built behaviour matches its words.
  Assert "the specification's workflow section carries the amendment this conforms to" {
    $spec = Get-Content (Join-Path $repo 'specs.md') -Raw
    if (-not ($spec -match '(?i)design increment')) { throw 'specs.md does not match: (?i)design increment' }
    if (-not ($spec -match 'NEVER invents an increment')) { throw 'specs.md does not match: NEVER invents an increment' }
    $true
  }
}

# --- ticket scaffolding/01 — a shared tracker never carries protocol-only work ----

Describe-Ticket 'scaffolding/01' 'a shared tracker never carries protocol-only work' {

  $ticketsTemplate = 'configure/policies/tickets.template.md'
  $protocolOnly = Get-Section (Get-SkillFile $ticketsTemplate) 'A shared tracker never carries protocol-only work'

  Assert "the rule: a workflow-created ticket on a shared tracker states an outcome outside the protocol directory" {
    if (-not ($protocolOnly -match $rulePattern['the protocol-only tracker rule'])) { throw '$protocolOnly does not match: $rulePattern[''the protocol-only tracker rule'']' }
    if (-not ($protocolOnly -match '(?i)shared tracker')) { throw '$protocolOnly does not match: (?i)shared tracker' }
    $true
  }

  Assert "protocol-only work routes by its consumer: a map session, or a declared increment" {
    if (-not ($protocolOnly -match '(?i)map session')) { throw '$protocolOnly does not match: (?i)map session' }
    if (-not ($protocolOnly -match '(?i)declared increment')) { throw '$protocolOnly does not match: (?i)declared increment' }
    $true
  }

  # Both bounds shipped in the same edit as the rule — without them it reads
  # as banning `docs:` work outright, or as binding what humans may file.
  Assert "both bounds: the diff never the commit type, and workflow-created on a shared tracker only" {
    if (-not ($protocolOnly -match '(?i)diff, never the commit type')) { throw '$protocolOnly does not match: (?i)diff, never the commit type' }
    if (-not ($protocolOnly -match '(?i)humans file what they like')) { throw '$protocolOnly does not match: (?i)humans file what they like' }
    if (-not ($protocolOnly -match '(?i)local-markdown tracker[^\r\n]{0,60}nothing to bind')) { throw '$protocolOnly does not match: (?i)local-markdown tracker[^\r\n]{0,60}nothing to bind' }
    $true
  }
}

# --- ticket scaffolding/02 — the design PR is the only protocol-only landing ------

Describe-Ticket 'scaffolding/02' 'the design PR is the only protocol-only landing' {

  $vcTemplate   = 'configure/policies/version-control.template.md'
  $mapsTemplate = 'configure/policies/maps.template.md'
  $lands = Get-Section (Get-SkillFile $vcTemplate) 'How work lands'

  Assert "the exception: a design PR's entire diff sits under the protocol directory, one per design run" {
    if (-not ($lands -match $rulePattern['the design-PR exception'])) { throw '$lands does not match: $rulePattern[''the design-PR exception'']' }
    if (-not ($lands -match '(?is)one\s+per\s+(design\s+)?run')) { throw '$lands does not match: (?is)one\s+per\s+(design\s+)?run' }
    $true
  }

  Assert "it is the only protocol-only pull request — everything else rides its consuming build PR" {
    if (-not ($lands -match '(?i)the only one')) { throw '$lands does not match: (?i)the only one' }
    if (-not ($lands -match '(?i)rides the build pull request')) { throw '$lands does not match: (?i)rides the build pull request' }
    $true
  }

  Assert "the mechanical test is the diff, not a label or commit type" {
    if (-not ($lands -match '(?is)diff,\s+never\s+a\s+label\s+or\s+commit\s+type')) { throw '$lands does not match: (?is)diff,\s+never\s+a\s+label\s+or\s+commit\s+type' }
    $true
  }

  # The maps policy names the term and points at the exception's home — the
  # single-home sweep proves it restates nothing; this proves the landing
  # path itself moved off the bare docs: commit.
  Assert "the branch-bound landing path names the per-session design PR" {
    $s = Get-SkillFile $mapsTemplate
    if (-not ($s -match '(?i)land as that session.s design PR')) { throw ($mapsTemplate + ' does not match: (?i)land as that session.s design PR') }
    if (-not ($s -notmatch '(?i)lands as its own `?docs:`? commit')) { throw ($mapsTemplate + ' still matches what it must not: (?i)lands as its own `?docs:`? commit') }
    $true
  }
}

# --- ticket scaffolding/03 — a drift finding is evidence, indexed on the live map -

Describe-Ticket 'scaffolding/03' 'a drift finding is evidence, indexed on the live map' {

  $evidenceTemplate  = 'configure/policies/evidence.template.md'
  $mapsTemplate      = 'configure/policies/maps.template.md'
  $knowledgeTemplate = 'configure/policies/knowledge.template.md'

  # The count probe follows aep/04's repaired shape: reject the pre-ticket
  # count rather than pin the new one, so kind six breaks nothing here.
  Assert "the kind: directory row, producer, and what one holds" {
    $c = Get-SkillFile $evidenceTemplate
    if ($c -match '(?i)four kinds') { throw 'the count did not move' }
    ($c -match '(?m)^\|[^|\r\n]+\|\s*`\.claude/evidence/drift/`\s*\|') -and
    ($c -match '(?i)whoever finds the drift') -and
    ($c -match $rulePattern['the drift-finding contents']) -and
    ($c -match '(?is)what\s+it\s+falsifies')
  }

  # The task-list form is conjoined on its own, not left to the sweep pattern's
  # alternation — an OR-shaped probe would stay green if the form were dropped
  # while the check-off timing survived.
  Assert "the index line: task-list form under Drift found, checked when the healing lands" {
    $c = Get-SkillFile $mapsTemplate
    if (-not ($c -match '(?is)task.list\s+line')) { throw ($mapsTemplate + ' does not match: (?is)task.list\s+line') }
    if (-not ($c -match $rulePattern['the drift-finding index line'])) { throw ($mapsTemplate + ' does not match: $rulePattern[''the drift-finding index line'']') }
    if (-not ($c -match '(?is)checked\s+off\s+when\s+the\s+healing\s+lands')) { throw ($mapsTemplate + ' does not match: (?is)checked\s+off\s+when\s+the\s+healing\s+lands') }
    if (-not ($c -match '(?im)^\#\#\s+Drift\s+found')) { throw ($mapsTemplate + ' does not match: (?im)^\#\#\s+Drift\s+found') }
    $true
  }

  Assert "on GitHub the line rides the body, never a comment" {
    $c = Get-SkillFile $mapsTemplate
    if (-not ($c -match '(?is)body,?\s+never\s+a\s+comment')) { throw ($mapsTemplate + ' does not match: (?is)body,?\s+never\s+a\s+comment') }
    if (-not ($c -match '(?is)paginated\s+fetch')) { throw ($mapsTemplate + ' does not match: (?is)paginated\s+fetch') }
    $true
  }

  Assert "the knowledge policy: a falsified Decision is never healed inline, and the finder is pointed at the form" {
    $c = Get-SkillFile $knowledgeTemplate
    if (-not ($c -match $rulePattern['the decision-drift never-inline rule'])) { throw ($knowledgeTemplate + ' does not match: $rulePattern[''the decision-drift never-inline rule'']') }
    if (-not ($c -match '(?is)drift\s+finding')) { throw ($knowledgeTemplate + ' does not match: (?is)drift\s+finding') }
    if (-not ($c -match 'evidence\.md')) { throw ($knowledgeTemplate + ' does not match: evidence\.md') }
    $true
  }

  # Points, not restates: the knowledge template names the form's home and
  # carries none of the kind's contents.
  Assert "the knowledge template points rather than restates the kind" {
    $c = Get-SkillFile $knowledgeTemplate
    if (-not ($c -notmatch $rulePattern['the drift-finding contents'])) { throw ($knowledgeTemplate + ' still matches what it must not: $rulePattern[''the drift-finding contents'']') }
    if (-not ($c -notmatch '`\.claude/evidence/drift/`')) { throw ($knowledgeTemplate + ' still matches what it must not: `\.claude/evidence/drift/`') }
    $true
  }

  # ADR 0029: the layout row and the policy row land in the same change; the
  # aep/10 conformance sweep walks the layout line, so drift/ is checked there
  # from now on.
  Assert "the specification's layout lists drift/ beside the other evidence kinds" {
    $spec = Get-Content (Join-Path $repo 'specs.md') -Raw
    if (-not ($spec -match '(?m)^.*out-of-scope/\s+drift/.*$')) { throw 'specs.md does not match: (?m)^.*out-of-scope/\s+drift/.*$' }
    $true
  }
}

# --- ticket scaffolding/04 — discovery surfaces drift, the set routes it ----------

Describe-Ticket 'scaffolding/04' 'design discovery surfaces drift, and the set routes protocol-only work' {

  $design = 'design/SKILL.md'

  # `declared-fields/06` moved the read from the directory to the index, so the
  # path moved with it. The scoping half is what this assertion is about, and it
  # is anchored on the durable half of the phrase rather than on either
  # ticket's wording — an unscoped read is the whole-directory cost the index
  # was built to remove.
  Assert "discovery names the drift-finding read, scoped to what the request plans" {
    $s = Get-Section (Get-SkillFile $design) 'Discover'
    if (-not ($s -match 'evidence/map\.md')) { throw ($design + ' does not match: evidence/map\.md') }
    if (-not ($s -match '(?i)this request plans')) { throw ($design + ' does not match: (?i)this request plans') }
    $true
  }

  Assert "set-cutting: no protocol-only ticket, routed by the tickets policy" {
    $s = Get-Section (Get-SkillFile $design) 'Plan'
    if (-not ($s -match '(?i)protocol-only')) { throw ($design + ' does not match: (?i)protocol-only') }
    if (-not ($s -match 'tickets\.md')) { throw ($design + ' does not match: tickets\.md') }
    $true
  }

  # This ticket places no rule — it wires pointers. The three rules it
  # enforces stay in their policy homes; the sweep proves that globally, and
  # this anchors the claim to the one file most likely to restate them.
  Assert "the stage points; the rules stay in the policies from 01 and 03" {
    $c = Get-SkillFile $design
    if (-not ($c -notmatch $rulePattern['the protocol-only tracker rule'])) { throw ($design + ' still matches what it must not: $rulePattern[''the protocol-only tracker rule'']') }
    if (-not ($c -notmatch $rulePattern['the drift-finding contents'])) { throw ($design + ' still matches what it must not: $rulePattern[''the drift-finding contents'']') }
    if (-not ($c -notmatch $rulePattern['the decision-drift never-inline rule'])) { throw ($design + ' still matches what it must not: $rulePattern[''the decision-drift never-inline rule'']') }
    $true
  }
}

# --- ticket scaffolding/05 — adopt the changed templates here ---------------------

Describe-Ticket 'scaffolding/05' 'adopt the changed templates here' {

  # The installed comment headers say who installed the file and why; they are
  # not part of the guide, so a copied file is compared on its body alone.
  $stripComments = { param($t) ($t -replace '(?s)<!--.*?-->', '').Trim() -replace '\r\n', "`n" }

  # ADR 0025: ship first, adopt second. The three copied policies this effort
  # touched are asserted body-identical to their templates — a copied guide
  # that merely *mentions* the new rule is the drift the copied/derived line
  # (ADR 0019) exists to prevent. `tickets` is checked by rule instead: two
  # wording divergences predate this effort and are not its to close.
  foreach ($p in @('knowledge', 'evidence', 'maps')) {
    Assert "the installed $p policy matches the template it was copied from" {
      $t = & $stripComments (Get-SkillFile "configure/policies/$p.template.md")
      $i = & $stripComments (Get-Content (Join-Path $repo ".claude/policies/$p.md") -Raw)
      if ($t -ne $i) { throw 'the installed copy has diverged from its template' }
      $true
    }
  }

  Assert "the installed tickets policy carries the protocol-only rule and its local-markdown bound" {
    $c = Get-Content (Join-Path $repo '.claude/policies/tickets.md') -Raw
    if (-not ($c -match $rulePattern['the protocol-only tracker rule'])) { throw '.claude/policies/tickets.md does not match: $rulePattern[''the protocol-only tracker rule'']' }
    if (-not ($c -match '(?is)local-markdown tracker[^\r\n]{0,60}nothing to bind')) { throw '.claude/policies/tickets.md does not match: (?is)local-markdown tracker[^\r\n]{0,60}nothing to bind' }
    $true
  }

  # Derived, not copied — so this asserts the rule is present, never that the
  # text matches. The diff-not-label test is deliberately not conjoined here:
  # it is stated on both the tracker and PR sides by design (recorded on
  # ticket 02), and a third assertion would entrench what was merely accepted.
  Assert "the installed version-control policy carries the design-PR exception" {
    $c = Get-Content (Join-Path $repo '.claude/policies/version-control.md') -Raw
    if (-not ($c -match $rulePattern['the design-PR exception'])) { throw '.claude/policies/version-control.md does not match: $rulePattern[''the design-PR exception'']' }
    if (-not ($c -match '(?is)every other protocol-only change rides')) { throw '.claude/policies/version-control.md does not match: (?is)every other protocol-only change rides' }
    $true
  }
}

# --- ticket orchestration/01 — the specification declares orchestration -------

# Each claim below belongs to one numbered section. A file-wide match would pass
# on the vocabulary that travels between them — §7 points at §20, and §20 points
# back — so every assertion is scoped to the section that owns it.
# The word boundary is load-bearing: Get-Section allows any prefix before the
# pattern, so a bare "7\." also matches the "7." inside "## 17.".
function Get-SpecSection {
  param([string]$Number)
  Get-Section (Get-Content (Join-Path $repo 'specs.md') -Raw) "\b$Number\.\s"
}

Describe-Ticket 'orchestration/01' 'the specification declares orchestration' {

  # If a heading is renumbered or renamed, every assertion below degrades to
  # "the text is missing" rather than to a pass. This one says which it was.
  Assert "the three sections this ticket amends resolve, and to themselves" {
    $expected = @{ 7 = 'Policies'; 20 = 'Multi-agent'; 22 = 'Harness binding' }
    foreach ($n in 7, 20, 22) {
      $s = Get-SpecSection $n
      if ($s -notmatch "(?m)\A##[^\r\n]*$($expected[$n])") { throw "section $n resolved to the wrong heading" }
    }
    $true
  }

  # Each half is anchored to its own predicate. A bare "peer" near a bare
  # "dispatch" is satisfied by the orchestration sentence by itself — it names
  # the peer model in passing — which leaves the peer half deletable.
  Assert "the multi-agent section separates orchestration from peer coordination" {
    $s = Get-SpecSection 20
    if ($s -notmatch '(?is)peer[^.;]{0,120}dispatch\w*\s+(?:nobody|no one|no-one|none)') {
      throw 'the peer relationship is not defined as the one that dispatches nobody'
    }
    if ($s -notmatch '(?is)orchestration[^.]{0,80}dispatch\w*[^.]{0,80}integrat') {
      throw 'orchestration is not defined as dispatching and integrating'
    }
    $true
  }

  Assert "the multi-agent section names the brief, the role, and the change record" {
    $s = Get-SpecSection 20
    foreach ($artifact in 'brief', 'role', 'change record') {
      if ($s -notmatch "(?i)\*\*$artifact\*\*") { throw "the $artifact is not named as an artifact" }
    }
    $true
  }

  # The prohibition's own sentence closes by citing the design increment (§10)
  # as the precedent, so it says "invents" twice. Matching either would keep
  # this green with the fan-out's prohibition gone; the precedent is dropped
  # first so only the fan-out's own can satisfy it.
  Assert "the multi-agent section declares the fan-out and forbids a stage inventing one" {
    $s = Get-SpecSection 20
    if ($s -notmatch '(?i)\*\*fan-out\*\*') { throw 'the fan-out is not declared' }
    $claim = $s -replace '(?i)never invents an? design increment', ''
    if ($claim -notmatch '(?i)never invents') { throw 'nothing forbids a stage inventing a decomposition' }
    $true
  }

  Assert "the multi-agent section makes the orchestrator the only integrator, reconciled against the diff" {
    $s = Get-SpecSection 20
    if ($s -notmatch '(?i)only integrator') { throw 'the integrator is not bounded' }
    if ($s -notmatch '(?is)reconcil.{0,80}diff') { throw 'integration does not reconcile the record against the diff' }
    $true
  }

  # The load-bearing one: the harness withholds the asking surface, so this is a
  # constraint the specification records rather than a policy it chose.
  Assert "the multi-agent section refuses to delegate human authority downward" {
    $s = Get-SpecSection 20
    if ($s -notmatch '(?is)authority is never delegated|never delegated downward') {
      throw 'human authority is not bounded at the child'
    }
    if ($s -notmatch '(?is)records it and stops|reaches a decision.{0,80}stops') {
      throw 'nothing says what a child does on reaching a decision'
    }
    $true
  }

  Assert "the harness binding states what a sub-agent inherits and what it does not" {
    $s = Get-SpecSection 22
    if ($s -notmatch '(?is)inherits the boot tier') { throw 'the inherited half is unstated' }
    if ($s -notmatch '(?is)does not receive') { throw 'the un-inherited half is unstated' }
    $true
  }

  # The falsified instruction this effort found shipped said the opposite. A
  # reader reaching §22 must not be able to conclude a child starts bare.
  Assert "the harness binding names the brief as the only channel, and has the child read" {
    $s = Get-SpecSection 22
    if ($s -notmatch '(?is)only parent-to-child channel') { throw 'the brief is not named as the only channel' }
    if ($s -notmatch '(?is)because a child can read') { throw 'nothing corrects quoting pointer-tier material into a brief' }
    $true
  }

  # Anchored inside the canonical-set sentence, not merely near it. The
  # paragraph below also says "sub-agent contract", and it sits well within any
  # character window wide enough to span the list — so the boundary has to be
  # the sentence itself, or the guard stays green with the set unchanged.
  Assert "the policy section names the sub-agent contract in the canonical set" {
    $s = Get-SpecSection 7
    if ($s -notmatch '(?is)canonical set[^.]{0,400}sub-agent contract') {
      throw 'the canonical policy set omits the sub-agent contract'
    }
    $true
  }

  # The claim in the paragraph beside the canonical set, which the set's own
  # guard cannot see: there is no second router for a child.
  Assert "the policy section says why the contract is a policy and not a second router" {
    $s = Get-SpecSection 7
    if ($s -notmatch '(?is)second (?:protocol file|router|entrypoint|entry point)') {
      throw 'nothing rules out a second protocol file for a dispatched child'
    }
    if ($s -notmatch '(?is)inherits the boot tier|same pointer chain') {
      throw 'the reason — a child reaches the policy the way a session does — is unstated'
    }
    $true
  }

  # ADR 0029: an amendment is recorded as a Decision referencing the section it
  # amends, and the version is bumped. The bump is guarded with the other two
  # version sites; this is the referencing half.
  #
  # Scoped per section, not file-wide. ADR 0040 is cited from three sections, so
  # a file-wide match keeps this green with the §20 citation — the one the ADR
  # itself names as amended — deleted outright.
  Assert "every decision this effort records is cited from each section it amends" {
    $amends = @{ 40 = @(7, 20, 22); 41 = @(20); 42 = @(20); 43 = @(20); 44 = @(20) }
    foreach ($adr in $amends.Keys) {
      foreach ($n in $amends[$adr]) {
        if ((Get-SpecSection $n) -notmatch "ADR 00$adr") {
          throw "ADR 00$adr is not cited from section $n, which it amends"
        }
      }
    }
    $true
  }
}

# --- ticket orchestration/02 — the sub-agent policy ships ---------------------

Describe-Ticket 'orchestration/02' 'the sub-agent policy ships' {

  $subagents = 'configure/policies/sub-agents.template.md'

  Assert "the policy ships as a template /configure copies" {
    if (-not (Get-SkillFile $subagents)) { throw 'the template is missing' }
    $c = Get-SkillFile $subagents
    if ($c -notmatch '(?i)\.claude/policies/sub-agents\.md') { throw 'it does not name where it installs' }
    if ($c -notmatch '(?i)copied as-is') { throw 'it does not say it is copied rather than derived' }
    $true
  }

  # The count in the prose and the rows in the table are two statements of the
  # same fact, and the prose is the half that goes stale silently.
  Assert "the guide table carries it as copied, and the count beside the table moved with it" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -notmatch '(?im)^\|\s*`sub-agents\.md`\s*\|\s*copied\s*\|') { throw 'no row in the guide table' }
    $copied = ([regex]::Matches($c, '(?im)^\|\s*`[a-z-]+\.md`\s*\|\s*copied\s*\|')).Count
    if ($c -notmatch "(?i)eight describe the workflow and are copied") {
      throw 'the prose count does not say eight'
    }
    if ($copied -ne 8) { throw "the table holds $copied copied guides, not 8" }
    $true
  }

  # The row is the whole reachability mechanism: a guide with no row is
  # unreachable, and a row on a stage that dispatches nobody is a cost that
  # stage pays for nothing.
  #
  # The dispatching set is asserted whole, in both directions, rather than as a
  # list of stages to check. Written the other way it hard-coded three stages
  # and never mentioned `/implement` — so the table could claim "every row whose
  # stage dispatches" while omitting the one ADR 0044 names by name, and the
  # guard had nothing to say. `/design` was in that hard-coded list and reaches
  # no spawner at all; `/implement` reaches `codebase-design`, whose design-it-
  # twice fan-out is a dispatch today, before this effort adds another.
  Assert "the router reaches the policy from exactly the stages that dispatch" {
    $c = Get-SkillFile $protocolTemplate
    $dispatches  = @('/implement', '/review', '/research')
    $rows = @{}
    foreach ($line in ($c -split '\r?\n')) {
      if ($line -match '^\|\s*`(/[a-z]+)`\s*\|') { $rows[$Matches[1]] = $line }
    }
    foreach ($stage in @('/configure') + $dispatches + @('/design', '/prototype', '/commit')) {
      if (-not $rows.ContainsKey($stage)) { throw "$stage has no row at all" }
    }
    # /configure is exempt in both directions: its row is the whole directory.
    foreach ($stage in $rows.Keys) {
      if ($stage -eq '/configure') { continue }
      $carries = $rows[$stage] -match 'policies/sub-agents\.md'
      if ($carries -and $stage -notin $dispatches) { throw "$stage dispatches nobody but reaches the policy" }
      if (-not $carries -and $stage -in $dispatches) { throw "$stage dispatches but does not reach the policy" }
    }
    if ($c -notmatch '(?i)every row whose stage dispatches') { throw 'the table does not say which rows carry it' }
    $true
  }

  # The falsified instruction this effort found shipped said the opposite, so
  # both halves are asserted: what a child gets, and what it does not.
  Assert "the policy states what a child inherits and what it does not" {
    $c = Get-SkillFile $subagents
    if ($c -notmatch '(?i)inherits the entrypoint hierarchy') { throw 'the inherited half is unstated' }
    if ($c -notmatch '(?is)does not get the conversation|not the parent.?s messages') { throw 'the un-inherited half is unstated' }
    if ($c -notmatch '(?i)narrows what a child may do') { throw 'the policy does not say it narrows rather than bootstraps' }
    $true
  }

  Assert "the policy says what a child may use, and holds it to verification at use" {
    $c = Get-SkillFile $subagents
    foreach ($layer in 'Codebase', 'Context', 'Decisions') {
      if ($c -notmatch "(?i)\b$layer\b") { throw "$layer is not named as readable" }
    }
    if ($c -notmatch '(?i)verifies at use') { throw 'a child is not held to verification at use' }
    if ($c -notmatch '(?i)drift finding') { throw 'falsified knowledge has no route out of a child' }
    $true
  }

  Assert "the policy closes writing, claiming, committing, pushing, and integrating" {
    $c = Get-SkillFile $subagents
    if ($c -notmatch '(?i)writes no knowledge layer') { throw 'a child is not barred from writing knowledge' }
    foreach ($verb in 'claims nothing', 'commits nothing', 'pushes nothing', 'integrates nothing') {
      if ($c -notmatch "(?i)$verb") { throw "the policy does not say a child $verb" }
    }
    $true
  }

  # The harness permits nesting, so a reader who checks the runtime and not this
  # file would conclude a child may fan out. Both halves are asserted: the bound,
  # and that it is the workflow's choice rather than a limit it inherited.
  Assert "orchestration is one layer deep — a child dispatches nobody" {
    $c = Get-SkillFile $subagents
    if ($c -notmatch $rulePattern['a child dispatches nobody']) { throw 'nothing stops a child fanning out' }
    if ($c -notmatch '(?is)one layer deep') { throw 'the depth is not stated' }
    # Two checks rather than an alternation. As one, inverting the claim — "the
    # harness enforces it" — left the other phrasing standing and the guard
    # green, which is a rule saying the opposite of what it was written to say.
    if ($c -notmatch '(?is)nesting is available') { throw 'the policy does not say the runtime permits nesting' }
    if ($c -notmatch '(?is)this workflow sets rather than') {
      throw 'the bound reads as a harness limit rather than as this workflow choosing it'
    }
    $true
  }

  # Stated as a rule rather than as advice, which is the acceptance criterion:
  # both halves are prohibitions, and the second is the one that gets softened.
  Assert "the consent boundary is a rule — no consent for another, no denial routed around" {
    $c = Get-SkillFile $subagents
    if ($c -notmatch $rulePattern['the consent boundary']) { throw 'consent is not bounded at the agent' }
    if ($c -notmatch '(?is)denial is not routed around') { throw 'a denial may still be worked around' }
    if ($c -notmatch '(?is)not re-asked|not retried') { throw 'the ways around a denial are not closed' }
    $true
  }

  Assert "a decision a child reaches is recorded and stopped on" {
    $c = Get-SkillFile $subagents
    if ($c -notmatch $rulePattern['a child records a decision and stops']) { throw 'the stop is not stated' }
    if ($c -notmatch '(?is)no surface on which to ask') { throw 'the reason a child cannot decide is unstated' }
    $true
  }

  Assert "the brief names all six parts, and a brief missing one is incomplete" {
    $c = Get-SkillFile $subagents
    foreach ($part in 'objective', 'inputs', 'what it owns', 'return shape', 'done-criteria', 'cap') {
      if ($c -notmatch "(?im)^\|\s*$part\s*\|") { throw "the brief template omits: $part" }
    }
    if ($c -notmatch $rulePattern['the brief completeness rule']) { throw 'an incomplete brief is not identifiable' }
    if ($c -notmatch $rulePattern['the only parent-to-child channel']) { throw 'the brief is not named as the only channel' }
    $true
  }

  Assert "the change record names what changed, why, what was not done, and any decision stopped on" {
    $c = Get-SkillFile $subagents
    foreach ($item in 'what changed', 'why', 'what it could not do', 'any decision it stopped on') {
      if ($c -notmatch "(?i)\*\*$([regex]::Escape($item))\*\*") { throw "the record format omits: $item" }
    }
    if ($c -notmatch '(?is)returns only its path and a compressed summary') { throw 'the return shape is not bounded' }
    $true
  }

  # The bar, and what falling under it means. Without the second half a vague
  # record reads as terse rather than as broken, which is the whole failure.
  Assert "the record is a manifest, reconcilable against the diff, and a vague one is a defect" {
    $c = Get-SkillFile $subagents
    if ($c -notmatch $rulePattern['the record-is-a-manifest rule']) { throw 'the record is described as a report' }
    if ($c -notmatch $rulePattern['the record reconciliation bar']) { throw 'the format has no reconciliation bar' }
    if ($c -notmatch '(?is)too vague to reconcile is a \*\*defect') { throw 'an unreconcilable record is not a defect' }
    $true
  }

  # ADR 0012: Position is a directory plus a membership test, so a new per-clone
  # artifact is covered by the test rather than by an entry added for it.
  Assert "the record is Position, and the existing membership test covers it" {
    $c = Get-SkillFile $subagents
    if ($c -notmatch '(?i)change record is Position') { throw 'the record is not classified' }
    if ($c -notmatch '(?i)`?\.claude/position/`?') { throw 'the policy does not say where it lives' }
    if ($c -notmatch '(?is)no new exception') { throw 'the policy does not say the existing test covers it' }
    $true
  }
}

# --- ticket orchestration/03 — roles ship as named definitions -----------------

# The second shipped surface. `Get-SkillFiles` walks `skills/` and stops there,
# so every sweep in this file — single-home included — was blind to `agents/`
# the moment it existed. This is what makes the sweeps below not optional: a
# role restating a policy rule is exactly the drift the policy was written to
# end, and nothing already here would have seen it.
$agents = Join-Path $repo 'agents'
function Get-RoleFiles {
  if (-not (Test-Path $agents)) { return @() }
  Get-ChildItem $agents -Recurse -File -Filter *.md
}
function Get-RoleFrontmatter {
  param([System.IO.FileInfo]$File)
  $fm = Get-Frontmatter (Get-Content $File.FullName -Raw)
  if ($null -eq $fm) { throw "$($File.Name) has no frontmatter" }
  $fm
}

Describe-Ticket 'orchestration/03' 'roles ship as named definitions' {

  # The roster the ticket bounds: the two review axes, the research
  # investigation, the build portion. Asserted as a set rather than a minimum,
  # because "and nothing speculative" is the half that erodes.
  # parallel-tickets/03 added the fifth. The set stays closed — that is the
  # point of it — and grows only when a ticket says which role and why.
  $roster = @('spec-reviewer', 'standards-reviewer', 'researcher', 'portion-builder', 'ticket-builder')

  Assert "the roster is exactly the two review axes, the investigation, the portion, and the ticket" {
    $found = @(Get-RoleFiles | ForEach-Object { $_.BaseName } | Sort-Object)
    $want  = @($roster | Sort-Object)
    if ($found.Count -eq 0) { throw 'no roles ship at all' }
    $extra   = @($found | Where-Object { $_ -notin $want })
    $missing = @($want  | Where-Object { $_ -notin $found })
    if ($extra)   { throw "speculative roles: $($extra -join ', ')" }
    if ($missing) { throw "missing roles: $($missing -join ', ')" }
    $true
  }

  # A plugin's sub-directories become part of the agent's identifier, so a role
  # filed one level down would be named by its path — which is the thing this
  # ticket exists to avoid. Flat is the mechanism, not a tidiness preference.
  Assert "identity comes from the name, so no role sits in a sub-directory" {
    $nested = @(Get-RoleFiles | Where-Object { (Split-Path $_.DirectoryName -Leaf) -ne 'agents' })
    if ($nested) { throw "path would leak into the identifier: $(($nested | ForEach-Object { $_.Name }) -join ', ')" }
    $true
  }

  Assert "every role declares the name it is dispatched by, and it matches its file" {
    foreach ($f in (Get-RoleFiles)) {
      $fm = Get-RoleFrontmatter $f
      $m = [regex]::Match($fm, '(?m)^name:\s*(\S+)\s*$')
      if (-not $m.Success) { throw "$($f.Name) declares no name" }
      if ($m.Groups[1].Value -ne $f.BaseName) { throw "$($f.Name) is dispatched as '$($m.Groups[1].Value)'" }
      if ($fm -notmatch '(?m)^description:\s*\S') { throw "$($f.Name) has no description to select it by" }
    }
    $true
  }

  # A plugin silently ignores these three. A role relying on one would read as
  # constrained and run unconstrained, with no error anywhere — which is why the
  # constraint that needed `permissionMode` lives in the policy as an obligation.
  Assert "no role relies on a frontmatter field a plugin ignores" {
    foreach ($f in (Get-RoleFiles)) {
      $fm = Get-RoleFrontmatter $f
      foreach ($field in 'hooks', 'mcpServers', 'permissionMode') {
        if ($fm -match "(?m)^$field\s*:") { throw "$($f.Name) sets $field, which a plugin's definitions ignore" }
      }
    }
    $true
  }

  # Background is the default and background children keep a narrower built-in
  # set, so a tool outside it means the definition resolves to two different
  # agents depending on how it was dispatched — and nothing reports the
  # difference. Asserted per role rather than once, so the failure names the file.
  Assert "every role's tool list survives being dispatched in the background" {
    $background = @('Read', 'Grep', 'Glob', 'Bash', 'PowerShell', 'Edit', 'Write',
                    'NotebookEdit', 'WebFetch', 'WebSearch', 'TodoWrite', 'Skill',
                    'ToolSearch', 'EnterWorktree', 'ExitWorktree', 'Monitor',
                    'TaskStop', 'SendMessage', 'Artifact')
    foreach ($f in (Get-RoleFiles)) {
      $fm = Get-RoleFrontmatter $f
      $m = [regex]::Match($fm, '(?m)^tools:\s*(.+)$')
      if (-not $m.Success) { throw "$($f.Name) inherits every tool rather than naming its own" }
      foreach ($tool in ($m.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() })) {
        if ($tool -notin $background) { throw "$($f.Name) lists $tool, which a background child does not keep" }
      }
    }
    $true
  }

  # One layer, in the frontmatter rather than in the prose: a sentence telling a
  # role not to dispatch is a second home for the policy's rule, and is advice
  # where this is a denial. `disallowedTools` is applied before `tools`.
  Assert "every role denies itself the tool that would let it dispatch further" {
    foreach ($f in (Get-RoleFiles)) {
      $fm = Get-RoleFrontmatter $f
      $m = [regex]::Match($fm, '(?m)^disallowedTools:\s*(.+)$')
      if (-not $m.Success) { throw "$($f.Name) does not deny anything" }
      $denied = @($m.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() })
      if ('Agent' -notin $denied) { throw "$($f.Name) may spawn children of its own" }
      if ($m.Groups[1].Value -match '\bAgent\s*\(') {
        throw "$($f.Name) uses the Agent(type) form, whose type list is ignored in a definition"
      }
    }
    $true
  }

  Assert "every role points at the sub-agent policy" {
    foreach ($f in (Get-RoleFiles)) {
      if ((Get-Content $f.FullName -Raw) -notmatch 'policies/sub-agents\.md') {
        throw "$($f.Name) never reaches the contract it is bound by"
      }
    }
    $true
  }

  # The single-home sweep in tenure/02 iterates `Get-SkillFiles`, which does not
  # reach here. Without this, `agents/` is the one shipped surface where a rule
  # may be restated for free.
  Assert "no role restates a rule that has a home elsewhere" {
    $restated = @()
    foreach ($f in (Get-RoleFiles)) {
      $c = Get-Content $f.FullName -Raw
      foreach ($rule in $rulePattern.Keys) {
        if ($c -match $rulePattern[$rule]) { $restated += "$($f.Name): $rule" }
      }
    }
    if ($restated) { throw ($restated -join '; ') }
    $true
  }

  # The other sweep `skills/` had and this surface did not. A role naming a
  # pre-migration path is the same bug as a skill naming one, and the exemption
  # that spares /configure's detection list has no analogue here — no role
  # detects a layout, so none may name one.
  Assert "no role references a pre-migration path" {
    $stale = @('CONTEXT\.md', 'CONTEXT-MAP\.md', 'docs/adr/', '\.scratch/',
               '\.claude/docs/', '\.claude/tenure\.md',
               '\.claude/tracker\.md', '\.claude/version-control\.md')
    $hits = @()
    foreach ($f in (Get-RoleFiles)) {
      $c = Get-Content $f.FullName -Raw
      foreach ($p in $stale) { if ($c -cmatch $p) { $hits += "$($f.Name): $p" } }
    }
    if ($hits) { throw ($hits -join '; ') }
    $true
  }


  # The authoring standards are path-scoped, so a shipped surface they do not
  # name is one where they never load — the rules exist and simply do not fire.
  Assert "the authoring standards load when a role is edited" {
    $fm = Get-Frontmatter (Get-Content (Join-Path $repo '.claude/rules/skills.md') -Raw)
    if ($null -eq $fm) { throw 'the authoring rules carry no frontmatter' }
    if ($fm -notmatch '(?m)^\s*-\s*"agents/\*\*"') {
      throw 'agents/ ships but the authoring standards are not scoped to it'
    }
    $true
  }
}

# --- ticket orchestration/04 — a ticket may declare a fan-out ------------------

Describe-Ticket 'orchestration/04' 'a ticket may declare a fan-out' {

  $tickets = 'configure/policies/tickets.template.md'

  # "Both the format and its template" is two files, not prose-plus-fence. The
  # increment section this one parallels moved both in one commit, and an
  # installed policy left a version behind is the drift the pair exists to
  # prevent — this repository would be running a format it ships an amendment to.
  Assert "the installed policy carries the section the template ships" {
    $shipped   = Get-Section (Get-SkillFile $tickets) 'Declared fan-out'
    $installed = Get-Content (Join-Path $repo '.claude/policies/tickets.md') -Raw
    if ($installed -notmatch '(?m)^## Declared fan-out') { throw 'the installed policy never gained the section' }
    # Normalised the way scaffolding/05 compares a copied policy: the two files
    # carry different line endings, and a raw comparison reports drift on every
    # line of an identical section.
    $here = Get-Section $installed 'Declared fan-out'
    $norm = { param($t) ($t -replace '\r\n', "`n").Trim() }
    if ((& $norm $here) -ne (& $norm $shipped)) { throw 'the installed section has drifted from the template' }
    $true
  }

  # Both halves: the prose that says a ticket MAY carry one, and the fenced
  # block a writer copies. The prose alone leaves the shape to be guessed, and
  # the block alone is a snippet with no rule attached to it.
  Assert "the ticket format carries the section, its shape, and its timing" {
    $s = Get-Section (Get-SkillFile $tickets) 'Declared fan-out'
    if ($s -notmatch '(?i)MAY carry one \*\*fan-out\*\*') { throw 'the section is not optional, or is not named' }
    # The row, not just the fence: a block holding only a heading is a shape
    # nobody can copy, and the guard that stopped at the heading passed on one.
    if ($s -notmatch '(?ms)^```markdown\r?\n## Fan-out\r?\n\r?\n- <role>:') {
      throw 'no template block a writer can copy'
    }
    if ($s -notmatch $rulePattern['the fan-out declaration timing rule']) { throw 'the design-time bound is missing' }
    $true
  }

  Assert "the declaration names roles and ownership, and composes no brief" {
    $s = Get-Section (Get-SkillFile $tickets) 'Declared fan-out'
    if ($s -notmatch $rulePattern['the portion ownership rule']) { throw 'file ownership is not part of the declaration' }
    if ($s -notmatch '(?is)does not compose a brief') { throw 'nothing stops the declaration composing a brief' }
    if ($s -notmatch '(?is)at dispatch and not at design time') { throw 'the reason a brief waits for dispatch is unstated' }
    $true
  }

  # The cost claim the ticket makes: a ticket without the section behaves as it
  # did. Asserted as the absence of a requirement, since prose saying "optional"
  # is exactly what a MUST elsewhere would quietly contradict.
  Assert "a ticket with no declaration is unchanged" {
    $s = Get-Section (Get-SkillFile $tickets) 'Declared fan-out'
    if ($s -notmatch '(?is)no `?## Fan-out`? section[^.]{0,80}unchanged') {
      throw 'the no-declaration case is not stated'
    }
    $fmt = Get-Section (Get-SkillFile $tickets) 'Format'
    if ($fmt -match '(?i)fan.out') { throw 'the fan-out leaked into the required format' }
    $true
  }

  # The guardrail lives with the stage that would breach it, not with the
  # section — the same split the increment pair already uses. A guardrail in the
  # format is a rule nobody reads at the moment it would be broken.
  Assert "the build stage is barred from inventing a fan-out, where it would" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch $rulePattern['the fan-out never-invented guardrail']) { throw 'the build stage may invent one' }
    if ($c -notmatch '(?is)not\*{0,2} re-partitioned in flight|never re-partitioned') {
      throw 'a ticket that divides differently may be re-cut mid-build'
    }
    if ((Get-SkillFile $tickets) -match $rulePattern['the fan-out never-invented guardrail']) {
      throw 'the guardrail has a second home in the format'
    }
    $true
  }

  # Scoped to the fan-out's own paragraph. `/design` already says it writes a
  # discussion, in the same file — a file-wide match reported authorship of the
  # declaration while the declaration's own sentence credited nobody.
  Assert "the design stage says it writes the declaration" {
    $para = @((Get-SkillFile 'design/SKILL.md') -split '\r?\n') |
            Where-Object { $_ -match '(?i)\*\*fan-out\*\*' }
    if (-not $para) { throw '/design never mentions a fan-out' }
    if (($para -join ' ') -notmatch '(?is)`?/design`?[^.]{0,30}writes it') {
      throw '/design does not claim authorship of the declaration'
    }
    $true
  }

  # ADR 0041. Both halves: the order, and the refusal — an order alone reads as
  # a scheduling note, and a refusal alone leaves a legal ticket unbuildable.
  Assert "a fan-out and a human-needing increment state which resolves first" {
    $s = Get-Section (Get-SkillFile $tickets) 'Declared fan-out'
    if ($s -notmatch '(?is)resolves first, in the parent, before anything is dispatched') {
      throw 'the order is unstated'
    }
    if ($s -notmatch '(?is)refused rather than reordered') { throw 'the combination is not refused' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    if ($s -notmatch '(?i)research.{0,20}task|AFK') { throw 'the increments that may sit in a portion are not distinguished' }
    $true
  }
}

# --- ticket orchestration/05 — configure writes the isolation obligation -------

Describe-Ticket 'orchestration/05' 'configure writes the isolation obligation' {

  # The value is asserted as JSON, parsed. A regex over the prose would pass on
  # the sentence that names the key while the sample beside it said "fresh" —
  # and the sample is the thing a reader copies.
  Assert "the configure stage writes the setting, with the value that branches from the claim" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -notmatch '(?i)`\.claude/settings\.json`') { throw 'the file /configure writes is not named' }
    $block = [regex]::Match($c, '(?s)```json\r?\n(\{[^`]*?"baseRef"[^`]*?\})\r?\n```')
    if (-not $block.Success) { throw 'no JSON sample carrying baseRef' }
    $parsed = $block.Groups[1].Value | ConvertFrom-Json
    if ($parsed.worktree.baseRef -ne 'head') {
      throw "the sample sets baseRef to '$($parsed.worktree.baseRef)', which branches from trunk"
    }
    $true
  }

  # "so a reader deleting it knows what they are deleting" — the reason is the
  # deliverable here, not decoration. Both halves: where the default branches
  # from, and that nothing reports the failure.
  Assert "the obligation states why it exists — the default, and the silence" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -notmatch $rulePattern['the worktree base-ref obligation']) {
      throw 'nothing says the default branches from somewhere other than the parent'
    }
    if ($c -notmatch '(?is)nothing reports it') { throw 'the failure does not read as silent' }
    if ($c -notmatch '(?is)merge into an existing') { throw 'the harness-owned file may be replaced wholesale' }
    $true
  }

  # ADR 0045. The first answer here was that the file could stay out of both
  # the diagram and §21, on the argument that each lists what this workflow
  # owns — falsified by §21 already listing `.gitignore`, which git owns, and
  # which ADR 0031 put there rather than narrowing the layout to exclude it.
  # `settings.local.json` is out of both because it is Position; a committed
  # file has no such cover. So the file is in the layout, and the two `settings`
  # files are distinguished rather than treated as one exemption.
  Assert "the canonical layout carries the harness file, and says which case it is" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ((Get-Section $c 'Generate') -notmatch '(?m)^├── settings\.json') {
      throw 'the generated tree omits a file /configure writes'
    }
    $spec = Get-Content (Join-Path $repo 'specs.md') -Raw
    if ((Get-Section $spec '\b21\.\s') -notmatch '(?m)^\s+settings\.json\s') {
      throw 'the specification layout omits it, so the two disagree'
    }
    if ($c -notmatch '(?is)still not one case') { throw 'the two settings files are conflated' }
    if ($c -notmatch '(?is)`settings\.local\.json` is per-clone') { throw 'the per-clone half is unstated' }
    if ($c -notmatch '(?is)`settings\.json` is committed') { throw 'the committed half is unstated' }
    $true
  }

  # An amendment is a Decision citing the section, plus the bump (ADR 0029).
  # The bump is guarded with the other version sites; this is the citation half.
  Assert "the layout amendment is recorded as a Decision the specification cites" {
    $adr = Join-Path $repo '.claude/decisions/0045-spec-21-gains-the-harness-settings-file.md'
    if (-not (Test-Path $adr)) { throw 'no Decision records the amendment' }
    $c = Get-Content $adr -Raw
    if ($c -notmatch '(?i)§21') { throw 'the Decision does not name the section it amends' }
    if ($c -notmatch '(?i)1\.6\.0') { throw 'the Decision does not record the version it moved to' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    $true
  }

  # Repairs rather than reports — the acceptance criterion, and the half a
  # migration row loses first, since reporting is always the cheaper write.
  Assert "the migration recognises the gap by content and repairs it" {
    $s = Get-Section (Get-MigrationText) 'Orchestration without its isolation setting'
    if ($s -notmatch '(?is)recognition is by content') { throw 'the row keys on presence rather than content' }
    if ($s -notmatch '(?is)sub-agents\.md.{0,200}(absent|missing|fresh)') { throw 'the two halves of the test are not both stated' }
    if ($s -notmatch '(?is)repairs rather than reports') { throw 'the row reports instead of repairing' }
    $true
  }

  Assert "the integrator confirms a child's base, and refuses by name" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch $rulePattern['the child base check at the integrator']) { throw 'nothing checks a child base' }
    # Emphasis may fall on either word or across both, so the markup is
    # skipped rather than matched — the claim is the refusal, not the bolding.
    if ($c -notmatch '(?is)\bnot\s+\*{0,2}integrated\b') { throw 'a wrong base does not stop integration' }
    if ($c -notmatch '(?is)names what it found') { throw 'the refusal is generic' }
    if ($c -notmatch '(?is)base it has, and the base it should have had') { throw 'the refusal does not say what to name' }
    $true
  }

  # The check exists because the setting cannot be trusted; a check that reads
  # as belt-and-braces is one a later reader deletes as redundant.
  Assert "the check says why configuration alone is not trusted" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?is)configured by hand or by an older version') {
      throw 'the reason the setting is re-checked is unstated'
    }
    if ((Get-SkillFile 'configure/SKILL.md') -match $rulePattern['the child base check at the integrator']) {
      throw 'the integrator check has a second home in /configure'
    }
    $true
  }
}

# --- ticket orchestration/06 — the build stage dispatches and integrates -------

# `Get-Section` matches `##(?!#)` on purpose, so a `###` subsection is invisible
# to it — and this ticket's whole deliverable is one. Fenced regions are masked
# the same way and for the same reason: a `###` inside a fence is sample content,
# and letting it end the subsection would truncate the search silently.
function Get-Subsection {
  param([string]$Content, [string]$HeadingPattern)
  $mask = [regex]::Replace($Content, '(?ms)^```.*?^```', {
    param($f) ($f.Value -replace '[^\r\n]', '.')
  })
  # `(?!#)` for the reason `Get-Section` has it: without it a `#### ` heading
  # matches as though it were the subsection itself.
  $m = [regex]::Match($mask, "(?ims)^###(?!#)[^\r\n]*$HeadingPattern.*?(?=^#{1,3}\s|\z)")
  if (-not $m.Success) { throw "no subsection matching '$HeadingPattern'" }
  $Content.Substring($m.Index, $m.Length)
}

Describe-Ticket 'orchestration/06' 'the build stage dispatches, isolates, and integrates' {

  $run = { Get-Subsection (Get-SkillFile 'implement/SKILL.md') 'Running one' }

  # The brief is composed at dispatch and its parts belong to the policy, so
  # the stage pointing at the template is the correct shape — and listing the
  # six here would be the second home the policy exists to prevent.
  Assert "one child per declared role, briefed from the template rather than from the ticket" {
    $s = & $run
    if ($s -notmatch '(?i)one child per declared role') { throw 'the fan-out does not dispatch per role' }
    if ($s -notmatch '(?is)brief built from the policy.s template') { throw 'the brief is not taken from the template' }
    if ($s -notmatch '(?is)composed now rather than carried on the ticket') { throw 'when the brief is composed is unstated' }
    if ($s -match $rulePattern['the brief completeness rule']) { throw 'the six parts are restated here' }
    $true
  }

  # Isolation is asserted with its enforcement, because "runs in a worktree" is
  # a description and "the harness refuses it" is the reason nothing has to be
  # trusted — which is the whole claim ADR 0044 makes.
  # ADR 0044: where a worktree is based is a configuration obligation "not a
  # sentence in a skill anyone can forget". The first draft wrote that sentence
  # here, which made the stage a third home beside `/configure` and specs §20 —
  # and the base-ref probe was narrowed until it stopped noticing. So the stage
  # states the isolation and defers the base, and the deferral is asserted.
  Assert "each child is isolated, and where it is based is deferred rather than restated" {
    $s = & $run
    if ($s -notmatch '(?is)its own isolated worktree') { throw 'children are not isolated' }
    if ($s -notmatch '(?is)version-control commands fail if they reach the main checkout') {
      throw 'the boundary is unstated, or claims more than the harness enforces'
    }
    # Two shapes, because the base-ref probe only knows the negative form —
    # default-branch-rather-than-parent. The positive one, "branched from the
    # claim", is the sentence ADR 0044 names and it slips past that probe
    # entirely, so it is excluded here on its own terms.
    if ($s -match $rulePattern['the worktree base-ref obligation']) {
      throw 'the stage restates where the worktree is based'
    }
    if ($s -match '(?i)(worktree|isolat\w+)[^.]{0,60}(branched|based)\s+(from|on)') {
      throw 'the stage names what the worktree branches from'
    }
    if ($s -notmatch '(?is)configuration rather than anything this stage states') {
      throw 'the deferral is not stated, so the omission reads as an oversight'
    }
    $true
  }

  # "when it creates them rather than when something breaks" is the criterion,
  # so the timing is the assertion — presence alone would pass on a sentence
  # buried in the failure path.
  # The timing is the stage's; how far the claim widens is the policy's, and
  # the first draft restated it here with no guard to notice.
  Assert "the widened claim is announced as the children are created, and not redefined" {
    $s = & $run
    if ($s -notmatch '(?is)claim has widened') { throw 'the claim widening is not announced' }
    if ($s -notmatch '(?is)as the children are created') { throw 'the timing is unstated' }
    if ($s -match $rulePattern['the claim widens over children']) { throw 'the stage restates how far it widens' }
    $true
  }

  Assert "integration is driven by the record, and the branch is not trusted alone" {
    $s = & $run
    if ($s -notmatch $rulePattern['integration is record-driven']) { throw 'the branch is integrated on trust' }
    if ($s -notmatch '(?is)file-ownership half') { throw 'why the record is what gives ownership force is unstated' }
    $true
  }

  # Both mismatches, both named, and the blast radius. A guard on one of the
  # three passes while the other two are deleted, and each is a different way
  # for the same manifest to be untrustworthy.
  Assert "a mismatch stops the whole fan-out and names which kind it was" {
    $s = & $run
    if ($s -notmatch '(?i)\*\*undeclared\*\*') { throw 'the undeclared-path case is not named' }
    if ($s -notmatch '(?i)\*\*unowned\*\*') { throw 'the unowned-path case is not named' }
    if ($s -notmatch '(?is)stop the \*\*whole\*\* fan-out') { throw 'a mismatch does not stop the siblings' }
    if ($s -notmatch '(?is)reported with the path') { throw 'the mismatch is not named with its path' }
    $true
  }

  Assert "a fanned-out ticket still produces one commit" {
    $s = & $run
    if ($s -notmatch $rulePattern['the fanned-out ticket is one commit']) { throw 'the one-commit rule does not survive a fan-out' }
    if ($s -notmatch '(?is)indistinguishable in history') { throw 'the reason a squash is used is unstated' }
    $true
  }

  # The ticket binds two cases together — a child that fails and a child that
  # stops — and the first draft gave the blast radius only to failure, leaving
  # a reader free to integrate the siblings around a stopped child.
  Assert "losing or stopping one child integrates none of them, and the survivors keep their work" {
    $s = & $run
    if ($s -notmatch $rulePattern['a partial fan-out integrates nothing']) { throw 'a partial set may still land' }
    if ($s -notmatch '(?is)so does one child stopping') { throw 'a stopped child does not stop the set' }
    if ($s -notmatch '(?is)not the failed or stopped portion, and not its siblings') { throw 'the blast radius is unstated' }
    if ($s -notmatch '(?is)worktrees stay where they are') { throw 'the survivors lose their work' }
    if ($s -notmatch '(?is)names the portion that failed and the decision') { throw 'the hand-back names one but not both' }
    $true
  }

  # ADR 0041 from the parent's side, and the criterion asks for a closed path
  # rather than a claim that one is closed. "No path exists" is a sentence; the
  # route out is the enforcement, so the route is what is asserted — including
  # the fence against the inline increment path, which was a live way for this
  # stage to answer a child's question and nothing had shut it.
  Assert "a child's decision has one route out, and the inline path is fenced off from it" {
    $s = & $run
    if ($s -notmatch '(?is)takes the hand-back below') { throw 'the decision has no stated route out' }
    if ($s -notmatch '(?is)same event') { throw 'it is not tied to the undeclared-decision case' }
    if ($s -notmatch '(?is)never one of those') { throw 'the inline resolution path is still open to a child question' }
    if ($s -notmatch '(?is)deciding on a child.s behalf') { throw 'why the inline path is fenced is unstated' }
    $true
  }

  Assert "review runs once, on the integrated result" {
    $s = & $run
    if ($s -notmatch '(?is)runs once, on the integrated result') { throw 'review may run per child' }
    if ($s -notmatch '(?is)seam between them') { throw 'the reason per-child review is wrong is unstated' }
    $true
  }

  # The cost claim: a ticket without a declaration is untouched. Asserted as
  # containment — every sentence this ticket added sits inside its own section,
  # so the path a normal ticket takes cannot have moved.
  Assert "the single-instance path is untouched, because the fan-out is contained" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $s = & $run
    foreach ($phrase in 'one child per declared role', 'isolated worktree branched from the claim',
                        'integrate from each child', 'raised, never resolved here') {
      $all = ([regex]::Matches($c, [regex]::Escape($phrase), 'IgnoreCase')).Count
      $here = ([regex]::Matches($s, [regex]::Escape($phrase), 'IgnoreCase')).Count
      if ($all -ne $here) { throw "dispatch language leaked outside its section: $phrase" }
    }
    # The ordinary loop is the prose before the first subsection. Taking the
    # whole of `## 2` instead sweeps in the fan-out subsections that correctly
    # live under it, and reports the section for containing its own contents.
    $build = (Get-Section $c '2 — Build') -split '(?m)^###\s', 2
    if ($build[0] -match '(?i)fan-out|dispatch|\bchild\b') {
      throw 'the loop a ticket without a declaration takes now mentions the fan-out'
    }
    $true
  }
}

# --- ticket orchestration/07 — the existing spawners conform -------------------

Describe-Ticket 'orchestration/07' 'the existing spawners conform to the policy' {

  $spawners = @('review/SKILL.md', 'research/SKILL.md',
                'codebase-design/DESIGN-IT-TWICE.md', 'survey/SKILL.md')

  Assert "each of the four spawners reaches the sub-agent policy" {
    foreach ($s in $spawners) {
      if ((Get-SkillFile $s) -notmatch 'policies/sub-agents\.md') { throw "$s never reaches the contract" }
    }
    $true
  }

  # The whole point of the policy: reaching it and restating it are opposites.
  # Swept per file so the failure names the spawner rather than the rule.
  Assert "no spawner restates a rule the policy or another file owns" {
    $restated = @()
    foreach ($s in $spawners) {
      $c = Get-SkillFile $s
      foreach ($rule in $rulePattern.Keys) {
        if ($c -match $rulePattern[$rule]) { $restated += "$s : $rule" }
      }
    }
    if ($restated) { throw ($restated -join '; ') }
    $true
  }

  # The reasoning the ticket protects: neither is a dispatch rule, both are
  # claims about that stage's own correctness, and moving either would be the
  # single-home rule misapplied. Asserted where they were, not merely present.
  Assert "the reasoning that is each stage's own stayed with that stage" {
    $r = Get-SkillFile 'review/SKILL.md'
    if ($r -notmatch '(?is)an axis that can see the other') { throw 'why the axes must not converge left /review' }
    if ($r -notmatch '(?is)cannot converge') { throw 'the conclusion of that reasoning is gone' }
    $s = Get-SkillFile 'research/SKILL.md'
    if ($s -notmatch '(?is)Isolation is not the same as not waiting') { throw 'the isolation-vs-blocking distinction left /research' }
    $true
  }

  # The instruction this effort was founded on finding. Two halves: the false
  # claim is gone, and nothing near it tells an author to quote a file's
  # contents into a brief instead of naming the path.
  Assert "the falsified brief-construction instruction is gone" {
    $c = Get-SkillFile 'codebase-design/DESIGN-IT-TWICE.md'
    if ($c -match '(?i)no Context loaded of its own') { throw 'the false claim about what a child holds is still shipped' }
    if ($c -match '(?i)quote the terms it needs into the brief') { throw 'the instruction it justified is still shipped' }
    if ($c -notmatch 'policies/sub-agents\.md') { throw 'nothing replaced it with a pointer at the truth' }
    $true
  }

  # "Spawners covered by a shipped role name the role rather than retyping its
  # brief." Both directions: the role is named, and the retyped brief is gone.
  Assert "a spawner a role covers names the role instead of retyping its brief" {
    $r = Get-SkillFile 'review/SKILL.md'
    foreach ($role in 'spec-reviewer', 'standards-reviewer') {
      if ($r -notmatch [regex]::Escape($role)) { throw "/review does not name $role" }
    }
    if ($r -match '(?im)^Brief:') { throw 'a brief is still typed at the call site' }
    $c = Get-SkillFile 'research/SKILL.md'
    if ($c -notmatch 'researcher') { throw '/research does not name its role' }
    $true
  }

  # The ticket is the effort's own test of whether the design was additive:
  # "If conforming these four requires changing what any of them does, the
  # claim that orchestration is a system stages opt into was wrong." Each
  # spawner still declares the same mode and still dispatches.
  Assert "no spawner changed what it does" {
    $modes = @{ 'review/SKILL.md' = 'review'; 'research/SKILL.md' = 'research'; 'survey/SKILL.md' = 'research' }
    foreach ($f in $modes.Keys) {
      if ((Get-DeclaredMode (Get-SkillFile $f)) -ne $modes[$f]) { throw "$f changed its mode" }
    }
    # Each spawner names the thing it dispatches. A bare `sub-?agent` probe
    # passed on the pointer this ticket just added — `sub-agents.md` contains
    # the word, so a spawner that had stopped dispatching entirely still read
    # as one.
    # Case-sensitive, and the harness agent in the backticks it is written with.
    # Unanchored and case-insensitive, `Explore` matched the word "exploring"
    # two paragraphs earlier — so the guard passed on a survey that had stopped
    # naming the agent entirely.
    $dispatches = @{
      'review/SKILL.md'                    = 'spec-reviewer'
      'research/SKILL.md'                  = 'researcher'
      'codebase-design/DESIGN-IT-TWICE.md' = 'Agent tool'
      'survey/SKILL.md'                    = '`Explore`'
    }
    foreach ($f in $dispatches.Keys) {
      if ((Get-SkillFile $f) -cnotmatch [regex]::Escape($dispatches[$f])) {
        throw "$f no longer names what it dispatches"
      }
    }
    $true
  }

  # Criterion 6, and the reason both were deferred: each rule had a second home
  # only this ticket could remove, so the guards land here with the removals.
  Assert "the two rules deferred from 02 and 03 now carry single-home guards" {
    foreach ($rule in 'what a child inherits', 'inputs by path, never pasted') {
      if (-not $rulePattern.Contains($rule)) { throw "no guard was placed for: $rule" }
    }
    $true
  }
}

# --- ticket orchestration/08 — adopt orchestration here ------------------------

Describe-Ticket 'orchestration/08' 'adopt orchestration here' {

  Assert "the sub-agent policy is installed here, and matches the template it was copied from" {
    $p = Join-Path $repo '.claude/policies/sub-agents.md'
    if (-not (Test-Path $p)) { throw 'the policy is not installed' }
    # Compared on the body: the installed header says who installed it and why,
    # which is not part of the guide — the same comparison scaffolding/05 makes.
    $strip = { param($t) ($t -replace '(?s)<!--.*?-->', '').Trim() -replace '\r\n', "`n" }
    if ((& $strip (Get-SkillFile 'configure/policies/sub-agents.template.md')) -ne (& $strip (Get-Content $p -Raw))) {
      throw 'the installed policy has diverged from its template'
    }
    $true
  }

  # The installed router is this repository's own file, so it is checked
  # independently of the template rather than assumed to have followed it.
  # `/configure` is skipped because its row is the whole directory, not a list —
  # the same exemption the declaration cross-check makes, and the reason the
  # router's own sentence cannot say "only those" without qualification.
  #
  # The dispatching rows are asserted to *exist* before their contents are
  # checked. Iterating the rows that are present passed with the `/research`
  # row deleted outright, because a missing stage never reaches the comparison.
  Assert "the installed router reaches the policy from exactly the stages that dispatch" {
    $c = Get-Content (Join-Path $repo '.claude/protocol.md') -Raw
    $dispatches = @('/implement', '/review', '/research')
    $rows = @{}
    foreach ($line in ($c -split '\r?\n')) {
      if ($line -match '^\|\s*`(/[a-z]+)`\s*\|') { $rows[$Matches[1]] = $line }
    }
    foreach ($stage in @('/configure') + $dispatches + @('/design', '/prototype', '/commit')) {
      if (-not $rows.ContainsKey($stage)) { throw "$stage has no row in the installed router" }
    }
    foreach ($stage in $rows.Keys) {
      if ($stage -eq '/configure') { continue }
      $carries = $rows[$stage] -match 'policies/sub-agents\.md'
      if ($carries -and $stage -notin $dispatches) { throw "$stage dispatches nobody but reaches the policy" }
      if (-not $carries -and $stage -in $dispatches) { throw "$stage dispatches but does not reach the policy" }
    }
    $true
  }

  # ADR 0044: a child branching from trunk builds against the wrong tree and
  # does it silently. The value is parsed rather than matched, because the
  # sentence naming the key stays true while the value flips.
  Assert "the isolation setting is written here, and branches from the claim" {
    $p = Join-Path $repo '.claude/settings.json'
    if (-not (Test-Path $p)) { throw 'this repository dispatches children from trunk' }
    $parsed = Get-Content $p -Raw | ConvertFrom-Json
    if ($parsed.worktree.baseRef -ne 'head') {
      throw "baseRef is '$($parsed.worktree.baseRef)', which branches from the default branch"
    }
    $true
  }

  # The Domain Context decision, checked as a decision rather than as a file:
  # it exists, it is routed, and the vocabulary left the always-loaded surface
  # rather than being copied off it.
  # `Sources:` is the line that makes a Domain Context navigable, and no other
  # assertion in the suite demands one — `skill-authoring.md` has had one since
  # it was written, so nothing ever had to.
  Assert "orchestration earns a Domain Context, routed and with its sources named" {
    $dc = Join-Path $repo '.claude/contexts/orchestration.md'
    if (-not (Test-Path $dc)) { throw 'no Domain Context was created' }
    $c = Get-Content $dc -Raw
    if ($c -notmatch '(?m)^Sources:\s*\S') { throw 'the Domain Context names no sources' }
    # Whitespace-tolerant: the reasoning is prose and hard-wraps, so a literal
    # space between two words matches only until someone reflows the paragraph.
    if ($c -notmatch '(?is)more\s+specific\s+row\s+wins') { throw 'the placement table was not reckoned with' }
    if ((Get-Content (Join-Path $repo '.claude/contexts/map.md') -Raw) -notmatch 'orchestration\.md') {
      throw 'the Domain Context is unreachable — no routing row'
    }
    $true
  }

  # Moved, not copied. Anchored on the term rather than on the exact markup it
  # was written with: pasting `**Role:**` back into the cross-cutting file — the
  # colon inside the emphasis — left this green with the vocabulary in both.
  Assert "the cross-cutting file gave the terms up rather than sharing them" {
    $c     = Get-Content (Join-Path $repo '.claude/contexts/orchestration.md') -Raw
    $cross = Get-Content (Join-Path $repo '.claude/contexts/repository.md') -Raw
    foreach ($term in 'Orchestration', 'Orchestrator', 'Role', 'Brief', 'Change Record',
                      'Fan-out', 'Dispatched Set', 'Brokered Request', 'Collision') {
      $arrived = "(?m)^\*\*$([regex]::Escape($term))\*\*:"
      $anywhere = "(?m)^\*{1,2}$([regex]::Escape($term))\*{0,2}:?\*{0,2}\s*$"
      if ($c -notmatch $arrived)    { throw "$term did not arrive in the Domain Context" }
      if ($cross -match $anywhere)  { throw "$term is defined in both files" }
    }
    $true
  }

  # The honesty criterion. Recorded on the ticket rather than in Context: a
  # measurement of what past tickets touched is a finding, `/design` owns
  # graduating one, and a constraint a refactor removes is not stable. Both
  # review axes found it in Context on the first pass.
  Assert "the fan-out measurement is recorded on the ticket, with its real cause" {
    $t = Get-Content (Join-Path $repo '.claude/tickets/orchestration/issues/08-adopt-here.md') -Raw
    if ($t -notmatch '(?is)scripts/verify\.ps1') { throw 'the file every ticket wrote is not named' }
    # Anchored on the count, not on the sentence: `all seven` undercounted by
    # one — this ticket writes the file too — and a guard keyed to the wording
    # froze the error rather than catching it.
    if ($t -notmatch '(?i)\ball eight\b') { throw 'the measurement is missing, or counts the wrong number' }
    # Emphasis may fall anywhere across "only test runner"; the claim is the
    # sole-runner cause, not the markup it is written with.
    if ($t -notmatch '(?is)only\W{0,4}test runner') { throw 'the stated cause is the authoring rule, which does not explain ticket 01' }
    if ($t -notmatch '(?is)not that the axis is') { throw 'the claim is stronger than the evidence supports' }
    if ($t -notmatch '(?is)non-blocking is not non-overlapping') { throw 'the same bound on a dispatched set is unstated' }
    $true
  }

  Assert "the migration names the repository that predates orchestration" {
    $s = Get-Section (Get-MigrationText) 'A repository configured before orchestration existed'
    if ($s -notmatch '(?is)recognition is by content') { throw 'the row keys on presence rather than content' }
    if ($s -notmatch '(?is)sub-agents\.md.{0,80}absent') { throw 'the second half of the test is unstated' }
    if ($s -notmatch '(?is)belongs to the plugin') { throw 'the row does not say the roles are not installed' }
    $true
  }
}

# --- ticket parallel-tickets/01 — the specification declares the second axis ---

Describe-Ticket 'parallel-tickets/01' 'the specification declares the second axis' {

  $s20 = { Get-SpecSection 20 }

  # The table is the artifact that makes a rule uncrossable: prose can say two
  # axes differ while leaving a reader to guess which rule belongs where.
  Assert "the multi-agent section names both axes and separates them row by row" {
    $s = & $s20
    if ($s -notmatch '(?i)\*\*dispatched set\*\*') { throw 'the second axis is not named' }
    if ($s -notmatch '(?im)^\|\s*\|\s*Fan-out\s*\|\s*Dispatched set\s*\|') { throw 'the axes are not contrasted in a table' }
    # Labels alone left the cells blankable: `| unit |  |  |` passed. Each row
    # has to carry two sides, which is the only thing that makes it a contrast.
    # Read off the row's own line and check its cells, rather than matching a
    # pattern across the table: a character class excluding `|` still matches
    # newlines, so a gutted row found its pipes on the row below and passed.
    foreach ($row in 'unit', 'lands as', 'disjointness', 'review') {
      $line = @($s -split '\r?\n') | Where-Object { $_ -match "^\|\s*$row\s*\|" } | Select-Object -First 1
      if (-not $line) { throw "the table has no row for: $row" }
      $cells = @($line.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
      if ($cells.Count -lt 3) { throw "the $row row does not have two sides" }
      if (-not $cells[1] -or -not $cells[2]) { throw "the table does not contrast: $row" }
    }
    $true
  }

  # The inversion is the whole reason the axes are named apart, so it is
  # asserted as a contrast rather than as the presence of either half.
  Assert "the failure rule is stated for each axis, and they invert" {
    $s = & $s20
    # Anchored to whole cells, not substrings within them. Matching "contains
    # X" let the row be rewritten to say the opposite of itself while quoting
    # both phrases — "siblings land, never nothing integrates" passed.
    $row = [regex]::Match($s, '(?im)^\|\s*on one child failing\s*\|([^|]*)\|([^|]*)\|')
    if (-not $row.Success) { throw 'the failure row is missing' }
    $fanout, $set = $row.Groups[1].Value.Trim(), $row.Groups[2].Value.Trim()
    if ($fanout -notmatch '(?i)^nothing integrates$') { throw "the fan-out cell reads '$fanout'" }
    if ($set -notmatch '(?i)^siblings land;') { throw "the set cell reads '$set'" }
    if ($s -notmatch '(?is)stops the whole fan-out') { throw 'the portion rule was lost while adding the set rule' }
    $true
  }

  Assert "the parent holds every claim in a set, and a child still claims nothing" {
    $s = & $s20
    if ($s -notmatch '(?is)creates every branch in the set before dispatching') { throw 'the branches are not created up front' }
    if ($s -notmatch '(?is)child still claims nothing') { throw 'the prohibition it preserves is unstated' }
    if ($s -notmatch '(?is)computed rather than declared') { throw 'the set reads as a declaration, which would need a ticket section' }
    $true
  }

  Assert "a fan-out on a dispatched ticket is declined, not honoured recursively" {
    $s = & $s20
    if ($s -notmatch '(?is)built alone by its child, which records that it declined') { throw 'the decline is unstated or unrecorded' }
    if ($s -notmatch '(?is)one layer is one layer') { throw 'the reason is unstated' }
    $true
  }

  # A collision has no analogue in a fan-out, so the guard checks the thing that
  # makes it different — that edges never promised disjointness.
  Assert "a collision is the orchestrator's to resolve, by the repository's own mechanism" {
    $s = & $s20
    if ($s -notmatch '(?is)\*\*collision\*\*') { throw 'the case is not named' }
    if ($s -notmatch '(?is)an edge gates work and says nothing about files') { throw 'why edges do not prevent it is unstated' }
    if ($s -notmatch '(?is)resolving it belongs to the orchestrator') { throw 'resolution has no owner' }
    if ($s -notmatch '(?is)version-control model') { throw 'the mechanism is invented here rather than read' }
    $true
  }

  Assert "brokering is stated with its bound, and the menu is closed" {
    $s = & $s20
    if ($s -notmatch '(?is)brokers what a child may not do') { throw 'brokering is unstated' }
    if ($s -notmatch '(?is)at depth one, from the orchestrator') { throw 'the depth bound is not shown to survive' }
    # The menu's *contents* are the safety property; guarding the adjective let
    # a commit and a push be added to it while the sentence still said "closed".
    if ($s -notmatch '(?is)menu is closed') { throw 'the request channel is unbounded' }
    $menu = [regex]::Match($s, '(?is)\*\*The menu is closed\*\*[^
]*?—(.{0,200}?)—')
    if (-not $menu.Success) { throw 'the menu is named but never enumerated' }
    foreach ($extra in 'commit', 'push', 'claim', 'integrat', 'merge') {
      if ($menu.Groups[1].Value -match "(?i)$extra") { throw "the menu admits: $extra" }
    }
    if ($s -notmatch '(?is)refused without being weighed') { throw 'refusal reads as discretion' }
    $true
  }

  # ADR 0041's principle survives ADR 0049 amending its consequence, so both
  # halves are asserted together — the old sentence and the new outcome.
  Assert "brokering moves nothing about who answers, and the return gains a fourth outcome" {
    $s = & $s20
    if ($s -notmatch '(?is)records it and stops') { throw "ADR 0041's consequence was replaced rather than amended" }
    # `attributed` alone matched "unattributed", so the guard passed on the
    # exact inversion of the rule it was written for.
    if ($s -notmatch '(?is)travels \*\*attributed\*\*') { throw 'the outward obligation is unstated' }
    if ($s -notmatch '(?is)travels \*\*verbatim\*\*') { throw 'the inward obligation is unstated' }
    if ($s -notmatch '(?is)stops the child rather than reinterpreting') { throw 'an unrelayable answer has no stated outcome' }
    if ($s -notmatch '(?is)done, failed, stopped, and \*\*waiting\*\*') { throw 'the four outcomes are not named' }
    $true
  }

  Assert "every decision this effort records is cited from the section it amends" {
    $s = & $s20
    foreach ($adr in 46, 47, 48, 49) {
      if ($s -notmatch "ADR 00$adr") { throw "ADR 00$adr is not cited from section 20, which it amends" }
    }
    $true
  }
}

# --- ticket parallel-tickets/02 — the policy admits a whole-ticket child -------

Describe-Ticket 'parallel-tickets/02' 'the policy admits a whole-ticket child, and states the broker contract' {

  $policy = 'configure/policies/sub-agents.template.md'

  Assert "a brief may carry a portion or a whole ticket, and the unit says what is owned" {
    $c = Get-SkillFile $policy
    if ($c -notmatch '(?is)portion of one ticket or a whole ticket') { throw 'the two units are not named' }
    $row = [regex]::Match($c, '(?im)^\| what it owns \|([^|]*)\|')
    if (-not $row.Success) { throw 'the brief does not say what a child owns' }
    if ($row.Groups[1].Value -notmatch '(?i)portion') { throw 'the ownership row does not name the portion case' }
    if ($row.Groups[1].Value -notmatch '(?i)ticket')  { throw 'the ownership row does not name the ticket case' }
    if ($c -notmatch $rulePattern['a ticket child owns its ticket']) { throw 'the unit does not change what is owned' }
    if ($c -notmatch '(?is)nobody hands it a file list') { throw 'why a ticket child has no file list is unstated' }
    $true
  }

  Assert "a ticket child declines a declared fan-out and records the decline" {
    $c = Get-SkillFile $policy
    if ($c -notmatch '(?is)declines it and records the decline') { throw 'the decline is unstated or unrecorded' }
    if ($c -notmatch '(?is)rather than a judgement about the work') { throw 'the decline reads as a choice about the work' }
    $true
  }

  # The closure is the safety property, so the guard checks the property and
  # not the adjective: the table's rows are what "exactly two" means.
  Assert "the request menu is closed, enumerated, and reasoned" {
    $c = Get-SkillFile $policy
    if ($c -notmatch '(?is)exactly two things may be requested') { throw 'the menu is not bounded to two' }
    # Counted as *rows of the menu table*, not as occurrences of the two known
    # labels: matching the labels let a third row be added beside them, which
    # is the one edit that turns a closed menu into an open one.
    $table = [regex]::Match($c, '(?ms)^\| Request \| What comes back \|\r?\n\|[-\s|]+\r?\n((?:\|[^\r\n]*\r?\n)+)')
    if (-not $table.Success) { throw 'the menu is not enumerated as a table' }
    $rows = @($table.Groups[1].Value -split '\r?\n' | Where-Object { $_.Trim() })
    if ($rows.Count -ne 2) { throw "the menu enumerates $($rows.Count) entries, not 2" }
    if ($rows[0] -notmatch '(?i)capability that requires dispatch') { throw 'the first entry is not the dispatch capability' }
    if ($rows[1] -notmatch '(?i)question put to the human') { throw 'the second entry is not the human question' }
    if ($c -notmatch $rulePattern['the request menu is closed']) { throw 'nothing says what happens to a request outside it' }
    if ($c -notmatch '(?is)would make every prohibition above advisory') { throw 'the reason the menu is closed is unstated' }
    # Presence cannot tell a rule from its negation: "the menu is not closed"
    # satisfies every probe written for "the menu is closed".
    if ($c -match '(?is)menu is (not|no longer) closed|weighs? each request on its merits') {
      throw 'the menu is stated open'
    }
    # And a table cannot see prose. An extra request kind named anywhere else in
    # the policy widens the menu without touching the two rows.
    foreach ($extra in 'create its branch', 'commit the finished', 'on the child.{0,3}s behalf', 'push', 'claim') {
      if ($c -match "(?is)request[^.]{0,120}$extra|$extra[^.]{0,80}on request") {
        throw "the menu is widened in prose: $extra"
      }
    }
    $true
  }

  # ADR 0049 gives the party in the middle an obligation in each direction, and
  # the inward one is the load-bearing half: it is the one that fails silently.
  Assert "the human chain is stated with an obligation in each direction" {
    $c = Get-SkillFile $policy
    if ($c -notmatch '(?is)child → orchestrator → human → orchestrator → child') { throw 'the chain is not stated' }
    if ($c -notmatch $rulePattern['the question travels attributed']) { throw 'the outward obligation is unstated' }
    if ($c -notmatch $rulePattern['the answer travels verbatim']) { throw 'the inward obligation is unstated' }
    # "verbatim where practical, unless a summary is clearer" satisfies the
    # probe while granting exactly the discretion the rule exists to remove.
    if ($c -match '(?is)verbatim where|unless the orchestrator judges|where practical') {
      throw 'the inward obligation is qualified away'
    }
    if ($c -notmatch '(?is)fails \*{0,2}silently') { throw 'why a paraphrase is worse than a refusal is unstated' }
    if ($c -notmatch '(?is)stops the child') { throw 'an unrelayable answer has no stated outcome' }
    $true
  }

  Assert "a request spends the brief's cap, and adds no second budget" {
    $c = Get-SkillFile $policy
    if ($c -notmatch $rulePattern['a request spends the cap']) { throw 'a request costs nothing' }
    if ($c -match '(?is)(question|request)s?[^.]{0,80}(exempt|do(es)? not count|free of|outside the cap)') {
      throw 'a kind of request is exempted from the cap'
    }
    if ($c -notmatch '(?is)no second budget') { throw 'nothing rules out a separate request budget' }
    $true
  }

  # `waiting` against `stopped` is the distinction anything reading a return
  # has to make, so the guard asserts the distinction rather than the word.
  Assert "the return names four outcomes, and waiting is distinguishable from stopped" {
    $c = Get-SkillFile $policy
    foreach ($o in 'done', 'failed', 'stopped', 'waiting') {
      if ($c -notmatch "(?i)\*\*$o\*\*") { throw "the outcome is not named: $o" }
    }
    if ($c -notmatch $rulePattern['waiting is not an ending']) { throw 'waiting reads as an ending' }
    if ($c -notmatch '(?is)resuming a .{0,20}waiting.{0,20} child and re-dispatching') {
      throw 'nothing says why the two must be told apart'
    }
    $true
  }

  # The claim survives only because no shipped role can send: a role that could
  # would make child-to-child traffic possible and invisible.
  Assert "no shipped role can message anyone, which is what makes the chain the only path" {
    $offenders = @()
    foreach ($f in (Get-RoleFiles)) {
      $fm = Get-RoleFrontmatter $f
      if ($fm -match '(?im)^tools:.*\bSendMessage\b') { $offenders += $f.Name }
    }
    if ($offenders) { throw "roles that can message: $($offenders -join ', ')" }
    $true
  }

  Assert "a ticket child neither creates nor commits to its branch, nor reviews itself unasked" {
    $c = Get-SkillFile $policy
    if ($c -notmatch '(?is)neither creates nor commits to the branch') { throw 'the branch prohibitions are unstated' }
    if ($c -notmatch '(?is)parent created it') { throw 'who created the branch is unstated' }
    if ($c -notmatch '(?is)review dispatches, and dispatching is closed to it') { throw 'why it cannot review itself is unstated' }
    $true
  }

  # The amendment must not have restated what the policy already said once.
  Assert "the prohibitions it preserves are still stated exactly once" {
    $c = Get-SkillFile $policy
    # The single-home probes are deliberately loose — they answer "is this rule
    # stated here at all", which is what duplication detection needs. They are
    # the wrong instrument for preservation: the claims probe is satisfied by
    # "no claim of its own to widen" in the dispatch bullet, so the sentence it
    # exists for could be deleted with the guard green. Preservation checks the
    # sentence.
    foreach ($verb in 'claims nothing', 'commits nothing', 'pushes nothing', 'integrates nothing') {
      if ($c -notmatch "(?i)$verb") { throw "the amendment dropped: a child $verb" }
    }
    foreach ($rule in 'a child dispatches nobody', 'the consent boundary',
                      'a child writes no knowledge layer') {
      if ($c -notmatch $rulePattern[$rule]) { throw "the amendment dropped: $rule" }
    }
    if ($c -notmatch $rulePattern['the only parent-to-child channel']) { throw 'the brief is no longer the unasked-for channel' }
    if ($c -notmatch '(?is)only because the child asked') { throw 'the second parent-to-child path is unacknowledged' }
    $true
  }


}

# --- ticket parallel-tickets/03 — a ticket-builder role ships ------------------

Describe-Ticket 'parallel-tickets/03' 'a ticket-builder role ships' {

  $role = Join-Path $repo 'agents/ticket-builder.md'

  # Identity, the ignored frontmatter fields, the background tool set, the
  # dispatch denial and the flat layout are swept for *every* role by
  # orchestration/03. Repeating them here would be a second home for a check.
  # What is asserted below is only what is true of this role and no other.
  Assert "the role ships and is dispatched for a whole ticket, never a portion" {
    if (-not (Test-Path $role)) { throw 'the role does not ship' }
    $c = Get-Content $role -Raw
    if ($c -notmatch '(?im)^description:[^\r\n]*whole ticket') { throw 'the description does not say what unit it takes' }
    if ($c -notmatch '(?im)^description:[^\r\n]*never for a portion') { throw 'nothing stops it being dispatched for a portion' }
    $true
  }

  Assert "the ticket bounds it, and its acceptance criteria are what done means" {
    $c = Get-Content $role -Raw
    if ($c -notmatch '(?is)acceptance criteria are what \*{0,2}done\*{0,2} means') { throw 'done is not tied to the criteria' }
    if ($c -notmatch '(?is)the ticket bounds you') { throw 'nothing states what bounds this child' }
    # What it *owns* is the policy's sentence, and the role restated it word for
    # word under a paragraph claiming to repeat nothing. The role states the
    # bound; the policy states the ownership.
    if ($c -match '(?is)hands? (you|it) a file list') { throw "the role restates the policy's ownership sentence" }
    if ($c -notmatch '(?is)and \*{0,2}your record saying which, one by one') {
      throw 'where done is recorded is unstated'
    }
    if ($c -notmatch '(?is)reported as unmet, never quietly reinterpreted') {
      throw 'an unmet criterion has no stated outcome, which is where a build reports success it did not earn'
    }
    $true
  }

  # Criterion 25 asked the role to state the decline; criterion 22 forbids it
  # restating the policy, and orchestration/02 made the decline the policy's
  # rule. Both are satisfied by the role carrying the *obligation* — say in the
  # record that you declined — and pointing for the rule itself.
  Assert "a declaration it cannot run is followed by the policy and reported in the record" {
    $c = Get-Content $role -Raw
    if ($c -notmatch '(?is)you do not run it') { throw 'the role may run a fan-out it cannot dispatch' }
    if ($c -notmatch '(?is)do not work the portions yourself') { throw 'the role may work the portions by hand' }
    if ($c -notmatch '(?is)build the ticket whole') { throw 'what it does instead is unstated' }
    # "that you did" left the antecedent open — followed the policy, or
    # declined? The record has to name the decline itself.
    if ($c -notmatch '(?is)record that you declined') { throw 'the decline is not recorded' }
    if ($c -notmatch 'policies/sub-agents\.md') { throw 'the rule is restated rather than pointed at' }
    $true
  }

  Assert "it warns that siblings are other tickets, not other parts of this one" {
    $c = Get-Content $role -Raw
    if ($c -notmatch '(?is)build that ticket and nothing beside it') { throw 'the bound itself is unstated' }
    if ($c -match '(?is)(make it while you are there|fix it while|improve it in passing)') {
      throw 'the bound is stated and then licensed away'
    }
    if ($c -notmatch '(?is)siblings are other tickets') { throw 'the unit of its siblings is unstated' }
    if ($c -notmatch '(?is)gate none of each other, not because they touch nothing') {
      throw 'the role does not warn that ungated is not non-overlapping'
    }
    $true
  }
}

# Both review axes broke the first version of every assertion below the same
# way, and neither by deleting anything: they *added* a sentence. Every phrase
# the guard required stayed exactly where it was, and a clause underneath it
# reversed the rule — the named path widened into the frontier around it, the
# stated plan held for the human, the lone ticket dispatched after all. A
# presence check cannot see an addition, so the refusals below are scoped to the
# paragraph carrying the rule, where an addition has to land to do its damage.
function Get-Paragraph {
  param([string]$Content, [string]$AnchorPattern)
  foreach ($p in [regex]::Split($Content, '(?:\r?\n){2,}')) {
    if ($p -match $AnchorPattern) { return $p }
  }
  throw "no paragraph matching '$AnchorPattern'"
}

Describe-Ticket 'parallel-tickets/04' 'the build stage computes and states the set' {

  $mode = { Get-Subsection (Get-SkillFile 'implement/SKILL.md') 'invocation decides the mode' }
  $work = { Get-Subsection (Get-SkillFile 'implement/SKILL.md') 'Working a set' }

  # tenure/04 owns the single-ticket path — the frontier, the lowest-number rule,
  # one ticket per invocation — and still asserts it, which is what "unchanged"
  # means here. What this checks is the other half: that adding a second mode did
  # not quietly let the named one dispatch.
  Assert "an invocation naming a ticket builds that ticket, and dispatches nothing" {
    $p = Get-Paragraph (& $mode) '(?i)Named a ticket'
    if ($p -notmatch '(?is)named a ticket, the stage builds that one') { throw 'the named-ticket path is unstated' }
    if ($p -notmatch '(?is)nothing below dispatches anything') { throw 'a named ticket may still dispatch' }
    if ($p -notmatch '(?is)a named ticket is never joined by others') { throw 'nothing forbids the named path widening' }
    foreach ($licence in @(
      '(?i)\bwiden\w*'
      '(?i)one child (for )?each'
      '(?i)together with[^.]{0,60}(set|frontier|ticket)'
      '(?i)dispatch\w*[^.]{0,80}\b(each|those|them|the rest)\b'
    )) { if ($p -match $licence) { throw "the named-ticket path is widened anyway: $licence" } }
    $true
  }

  # The rule /implement has always held is that it does not choose. Reading
  # declared edges is not choosing, and that argument is the licence for the
  # whole mode — so the guard fails if the bound it comes with is gone.
  Assert "the set is computed from declared edges, and the edges are the only input" {
    $p = Get-Paragraph (& $mode) '(?i)Computing a set is not choosing one'
    if ($p -notmatch '(?is)computing a set is not choosing one') { throw 'computing is not distinguished from choosing' }
    if ($p -notmatch '(?is)never widened, never reordered') { throw 'the set has no bound' }
    if ($p -notmatch '(?is)no other property of a ticket is consulted') { throw 'something other than the edges may decide membership' }
    foreach ($licence in @(
      # Ungated is not the same as safe-alongside, and a stage allowed to judge
      # the difference is a stage inventing a decomposition.
      '(?i)\b(may|can|is free to)\b[^.]{0,60}(add|includ|join)'
      '(?i)(use judgement|obviously safe|clearly do not interact|plainly cannot)'
      # ADR 0048 rejects predicting overlap before dispatch outright, so file
      # reasoning appearing here is that decision being reopened in prose.
      '(?i)(same files?|file overlap|touch(es|ing)? the same)'
    )) { if ($p -match $licence) { throw "membership is decided by something other than the edges: $licence" } }
    $true
  }

  Assert "the plan is stated before anything is created, and names the tickets, the role, and the branch" {
    $s = & $mode
    if ($s -notmatch '(?is)state the plan before creating anything') { throw 'the plan is not stated first' }
    if ($s -match '(?is)plan[^.]{0,60}\b(after|once)\b[^.]{0,40}branch') { throw 'the plan may be stated after the branches exist' }
    $fence = [regex]::Match($s, '(?ms)^```\r?\n(.*?)^```')
    if (-not $fence.Success) { throw 'the plan has no shape a reader can copy' }
    $plan = $fence.Groups[1].Value
    foreach ($part in @(
      @{ p = '(?im)^\s*set from the frontier:'; what = 'which tickets' }
      @{ p = '(?im)^\s*role\s';                 what = 'which role' }
      @{ p = '(?im)^\s*branches\s';             what = 'the branch per ticket' }
    )) {
      if ($plan -notmatch $part.p) { throw "the stated plan does not name $($part.what)" }
    }
    if ($plan -notmatch '(?i)ticket-builder') { throw 'the role is named nowhere in the plan' }
    $true
  }

  # Stating and gating are one word apart and opposite, and the gate goes back in
  # as an addition rather than an edit — so the refusal is swept over the whole
  # subsection, wherever the sentence that reinstalls it lands.
  Assert "the plan does not stop for approval, and the stage says why not" {
    $s = & $mode
    if ($s -notmatch '(?is)stated, not gated') { throw 'the plan is not distinguished from a gate' }
    if ($s -notmatch '(?is)does not stop for approval') { throw 'the stage may wait for approval' }
    if ($s -notmatch '(?is)close-out below does not prompt') { throw 'why it need not be gated is neither stated nor reached' }
    # `.claude/rules/engineering.md` owns the reversibility argument and the
    # close-out already carries it for the commit. Restating it here was a second
    # home the sweep missed, because that home is keyed on a different phrase.
    if ($s -match '(?is)reversible in this clone') { throw 'the reversibility argument is restated rather than reached' }
    foreach ($gate in @(
      # Not `stop`: this subsection's own sentence is "does not stop for
      # approval", and a verb list that matched it would fire on the rule.
      '(?i)\b(hold|holds|halt|pause|wait)\w*[^.]{0,80}(confirm|approv|agree|sign-?off)'
      '(?i)(ask|prompt)\w*[^.]{0,60}(human|user)[^.]{0,60}(confirm|approv|agree)'
      '(?i)confirm the (plan|set)'
      '(?i)until the (human|user)'
    )) { if ($s -match $gate) { throw "the plan is stated and then gated anyway: $gate" } }
    $true
  }

  Assert "every branch in the set exists before the first child is dispatched" {
    $p = Get-Paragraph (& $mode) '(?i)Then create every branch'
    if ($p -notmatch '(?is)all of them, before the first child is dispatched') { throw 'branches may be created as children start' }
    if ($p -notmatch '(?is)the parent holds the whole set') { throw 'who holds the claims is unstated' }
    # One refusal, two failures: the child-side prohibition is the sub-agent
    # policy's and restating it here is a second home, while the inversion —
    # each child creating its own branch — needs the same words to say it.
    if ($p -match '(?is)(child|children)[^.]{0,60}creat\w*[^.]{0,40}branch') {
      throw "branch creation is either handed to the children or restated from the policy"
    }
    $true
  }

  # Fan-out is expensive is the constraint this inherits: a child costs a full
  # context, and with no sibling to run against there is nothing to buy with it.
  Assert "a set of one is built in the parent, without dispatching" {
    $p = Get-Paragraph (& $mode) '(?i)A set of one is a set'
    if ($p -notmatch '(?is)a set of one is a set, and the parent builds it') { throw 'a set of one has no stated handling' }
    if ($p -notmatch '(?is)spend a whole context') { throw 'the cost that makes a lone child wrong is unstated' }
    foreach ($licence in @(
      '(?i)a set of one is (still )?dispatched'
      '(?i)\b(through|via|by) a (single |lone )?child'
      '(?i)dispatch\w*[^.]{0,40}(anyway|even so|uniform)'
      '(?i)\bunless\b[^.]{0,80}dispatch'
    )) { if ($p -match $licence) { throw "a lone ticket is dispatched after all: $licence" } }
    $true
  }

  # No new ticket metadata: the antichain is already in `Blocked by`, and a
  # second declaration of the same fact goes stale against the first.
  Assert "the ticket format gains nothing — the set is read off the edges already there" {
    $s = & $mode
    if ($s -notmatch '(?i)`Blocked by`') { throw 'the set is not tied to the edge that already encodes it' }
    if ($s -notmatch '(?is)nothing is added to the ticket format') { throw 'the format is free to grow a section for this' }
    $headings = [regex]::Matches((Get-SkillFile 'configure/policies/tickets.template.md'), '(?im)^#{2,4}\s+(.+)$') |
      ForEach-Object { $_.Groups[1].Value }
    $added = @($headings | Where-Object { $_ -match '(?i)\b(set|antichain|dispatch\w*|parallel\w*)\b' })
    if ($added) { throw "the ticket format grew a section for the set: $($added -join ', ')" }
    $true
  }

  Assert "a set dispatches one child per ticket, and inherits no rule from the fan-out unexamined" {
    $s = & $work
    if ($s -notmatch '(?is)no rule crosses from there to here without being restated') {
      throw 'the fan-out rules are left applying to a set by default'
    }
    if ($s -notmatch '(?is)one child per ticket') { throw 'the unit of dispatch is unstated' }
    if ($s -match '(?is)one child per (declared )?(role|portion)') { throw 'a set is dispatched by portion after all' }
    if ($s -notmatch '(?is)in the role the plan named') { throw 'which role builds a member is unstated' }
    # The role is named once, in the plan. Naming it again here is the second
    # home, and the brief's parts belong to the policy exactly as they do for a
    # fan-out — pointing is the whole shape of this subsection.
    if ($s -match $rulePattern['the brief completeness rule']) { throw "the brief's parts are restated here" }
    if ($s -notmatch 'policies/sub-agents\.md') { throw 'the contract is restated rather than pointed at' }
    $true
  }
}

# Three rounds of review broke every guard in this effort the same way, and not
# once by deleting anything: a sentence appended to the rule's own paragraph,
# permitting exactly what the sentence above it forbids. Twice the answer was to
# blacklist the words the attack used, and twice the next round used different
# ones — the last of them unconditional and unhedged ("a failure ends the run
# before any sibling integrates"), which walks past a hedge list and a
# conditional pattern alike. Blacklisting is the losing half of this game.
#
# So the test is inverted. A rule's paragraph is the **whole** disposition of its
# act, and **every sentence in it** must be one the guard pinned. An addition
# reversing the rule is a sentence, so it fails — whatever words it chose,
# conditional or not, on whatever topic.
#
# The first version of this asked only that sentences *about the act* be pinned,
# with the act given as a pattern. That was still a guess, and it leaked twice in
# one run: "where two hunks disagree, take the later child's version" mentions no
# merge, no mechanism and no record, and reverses the rule it sits under. Any
# list of topic words is a list I have to have thought of. The sentence count is
# not.
#
# The cost is real and deliberate: adding a sentence to one of these paragraphs
# means adding its pattern here. A guard that has to be updated when its rule's
# paragraph grows is the mechanism working, not friction.
# `-Refused` is not redundant with the whitelist and the two catch different
# things. The whitelist reads whole sentences, so a reversal spliced *into* a
# pinned sentence — "the only correct base is that branch as it stood at
# dispatch, or any ancestor of it, which counts equally" — leaves that sentence
# still matching its pin and passes. A refusal is how an in-sentence reversal is
# caught, and dropping them when the whitelist arrived reopened exactly that.
function Assert-RuleParagraph {
  param([string]$Paragraph, [hashtable[]]$Pinned, [string]$What, [hashtable[]]$Refused)
  foreach ($pin in $Pinned) {
    if ($Paragraph -notmatch $pin.p) { throw $pin.why }
  }
  foreach ($no in $Refused) {
    if ($Paragraph -match $no.p) { throw $no.why }
  }
  # Backticked spans carry dotted paths, and a sentence split that trusted the
  # dots would end a sentence inside `.claude/policies/version-control.md`.
  $masked = [regex]::Replace($Paragraph, '`[^`]*`', { param($m) '#' * $m.Value.Length })
  foreach ($b in [regex]::Matches($masked, '[^.!?]*[.!?]+[`"*)\]]*\s*')) {
    $sentence = $Paragraph.Substring($b.Index, $b.Length)
    if ($sentence -notmatch '[A-Za-z]') { continue }
    $covered = $false
    foreach ($pin in $Pinned) { if ($sentence -match $pin.p) { $covered = $true; break } }
    if (-not $covered) { throw "$What gains an unpinned sentence: '$($sentence.Trim())'" }
  }
}

Describe-Ticket 'parallel-tickets/05' 'each ticket lands on its own branch, and collisions are resolved' {

  $work = { Get-Subsection (Get-SkillFile 'implement/SKILL.md') 'Working a set' }

  # orchestration/05 deferred which direction the base check runs, and
  # orchestration/06 did not take it. A set closes it by construction: the parent
  # chose the branch, so there is no ancestry to weigh.
  #
  # ADR 0047 says "as it stood at dispatch" and means it: this stage restacks, so
  # a check against the branch's present tip inverts into refusing a correct
  # child — the failure orchestration/05 recorded against the ancestry form,
  # reintroduced by dropping four words.
  Assert "a set child's base is checked for equality against the branch it was given" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)base is checked') @(
      @{ p = '(?is)equality, and never for ancestry'; why = 'which direction the base check runs is unstated' }
      @{ p = '(?is)the only correct base is \*{0,2}that branch as it stood at dispatch'
         why = 'what the base must equal is unstated' }
      @{ p = '(?is)nothing to weigh'; why = 'why a set has no ancestry question is unstated' }
      @{ p = '(?is)because the tip moves'; why = 'the moving tip is unexplained, so the qualifier reads as decoration' }
      @{ p = '(?is)the refusal names the same three things'; why = 'a refused base is reported without saying what was found' }
    ) 'the base check' @(
      # Not a bare `is`: this paragraph's own argument is "an ancestor of it *is*
      # a child that started somewhere else", and a verb list that broad fires on
      # the rule it guards.
      @{ p = '(?i)\bancestor of\b[^.]{0,60}\b(counts|suffices|accepted|acceptable|allowed|enough|fine)\b'
         why = 'ancestry is admitted beside equality' }
      @{ p = '(?i)(descend\w+|anywhere) (from|under)[^.]{0,40}(branch|claim)[^.]{0,40}(accepted|allowed|fine)'
         why = 'any descendant of the branch is accepted as a base' }
    )
    $true
  }

  # The bar a record has to meet is the policy's; when the check happens and what
  # it does with the answer is this stage's. `unowned` is the half that cannot
  # cross — a set makes no declaration for it to test.
  Assert "the record is checked against the diff first, and only one of the two mismatches crosses" {
    $p = Get-Paragraph (& $work) '(?i)before anything of its lands'
    Assert-RuleParagraph $p @(
      @{ p = '(?is)before anything of its lands'; why = 'the check may happen after the work has landed' }
      @{ p = '(?is)\bundeclared\b'; why = 'the mismatch that does carry over is unnamed' }
      @{ p = '(?is)unowned\*{0,2} tests a declaration a set never makes'
         why = 'why unowned cannot cross is unstated, which leaves it looking like an omission' }
      @{ p = '(?is)arrives instead as a collision'; why = 'what the missing check would have caught goes unrouted' }
    ) 'the record check'
    if ($p -match $rulePattern['the record reconciliation bar']) { throw "the policy's bar is restated rather than reached" }
    # The policy's own sentence about what a ticket child is handed. Restating it
    # here is the second home parallel-tickets/03 was caught making.
    if ($p -match '(?i)file list') { throw "the policy's ownership sentence is restated" }
    $true
  }

  # The policy routes this here by name — what an orchestrator does when
  # reconciliation fails belongs to the stage that dispatched. The fan-out
  # answers it and a set may not inherit that answer, so it answers separately.
  Assert "a record that fails the check stops that ticket and no other" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)fails the check') @(
      @{ p = '(?is)stops that ticket, and reaches no further'; why = 'a failed check has no stated consequence' }
      @{ p = '(?is)the other members are other tickets'; why = 'why the refusal does not spread is unstated' }
      @{ p = '(?is)the refusal is per ticket'; why = 'the per-ticket scope of the refusal is unstated' }
    ) 'the per-ticket refusal'
    $true
  }

  Assert "each ticket lands as one commit on its own branch, and nothing is squashed across children" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)lands as one commit') @(
      @{ p = '(?is)one commit, on the branch named for its ticket'; why = 'where a landed ticket goes is unstated' }
      @{ p = '(?is)nothing is squashed across children'; why = 'the set may be collapsed into one commit' }
      @{ p = '(?is)indistinguishable in history from one built alone'; why = 'what one-commit-per-ticket buys is unstated' }
    ) 'one commit per ticket' @(
      @{ p = '(?i)(squash|collapse|fold)\w*[^.]{0,80}(the set|across the set|together|into one|into a single)'
         why = 'the set is squashed across children after all' }
      @{ p = '(?i)one commit for the (whole )?set'; why = 'the set collapses into a single commit' }
    )
    $true
  }

  Assert "the set is restacked in ticket order, and whether there is anything to restack is read" {
    $p = Get-Paragraph (& $work) '(?i)restack the set'
    Assert-RuleParagraph $p @(
      @{ p = '(?is)restack the set in ticket order'; why = 'the order the set is restacked in is unstated' }
      @{ p = '(?is)siblings while they ran'; why = 'that the members were not a stack while they ran is unstated' }
      # Step 1 already made the reader take the version-control model. Naming the
      # policy a second time in the same file is a second home, not a pointer.
      @{ p = '(?is)version-control model step 1 already required reading'
         why = 'whether the repository stacks is assumed rather than reached' }
      @{ p = '(?is)where it does not, the branches were never stacked'
         why = 'the plain-git case is unstated, so the rule reads as universal' }
    ) 'the restack order'
    # Ticket order is what makes a stack readable as the plan that produced it,
    # and demoting it to a preference costs nothing to write. Both directions:
    # the qualifier follows the noun ("order need not matter") or precedes it
    # ("in whatever order they returned").
    if ($p -match '(?i)(order|sequence)[^.]{0,60}(does not matter|need not|optional)|(whatever|any|whichever)\s+(order|sequence)') {
      throw 'ticket order is stated and then made optional'
    }
    $true
  }

  # ADR 0048. The edges gate work and say nothing about files, so this is found
  # at integration by design — and resolved, because the children are gone and a
  # refusal hands the user two worktrees and a question.
  Assert "a collision is the orchestrator's to resolve, and it is resolved rather than refused" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)is a collision') @(
      @{ p = '(?is)two children writing one path is a collision, and the orchestrator resolves it'
         why = 'who resolves a collision is unstated' }
      @{ p = '(?is)an edge gates work, and says nothing about files'; why = 'why the edges did not prevent it is unstated' }
      @{ p = '(?is)resolved rather than refused'; why = 'the stage may hand a collision back instead' }
    ) 'the collision rule' @(
      @{ p = '(?i)(predict|detect|check for)\w*[^.]{0,60}(overlap|collision)[^.]{0,60}before'
         why = 'overlap is predicted before dispatch, which ADR 0048 rejected' }
      @{ p = '(?i)(refus|reject|hand back|stop)\w*[^.]{0,60}collision'; why = 'a collision is handed back rather than resolved' }
      @{ p = '(?i)the child(ren)? resolves? it'; why = 'resolution is handed to children that have finished' }
    )
    $true
  }

  Assert "the mechanism comes from the version-control policy, and the stage names none of its own" {
    $p = Get-Paragraph (& $work) '(?i)The mechanism is the repository'
    Assert-RuleParagraph $p @(
      @{ p = [regex]::Escape($vcPolicy); why = 'where the mechanism comes from is unstated' }
      @{ p = '(?is)this stage names no merge strategy'; why = 'the stage is free to name a merge strategy' }
      @{ p = '(?is)both change records'; why = 'what the orchestrator brings that a merge tool does not is unstated' }
    ) 'the no-strategy rule'
    if ($p -notmatch '(?is)two intents|reconciling two hunks') { throw 'why both records matter is unstated' }
    # A named strategy would be right on the repositories that matched it and
    # silently wrong on the rest, which is the failure the pointer avoids.
    foreach ($named in @('(?i)\bgit (merge|rebase|cherry-pick)\b', '(?i)\b(ours|theirs)\b', '(?i)`gt restack`')) {
      if ($p -match $named) { throw "the stage names a mechanism of its own: $named" }
    }
    $true
  }

  Assert "a conflict of intent is raised rather than resolved, by the route already there" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)intents conflict') @(
      @{ p = '(?is)this stage does not make it'; why = 'the stage may decide between two intents' }
      @{ p = '(?is)not a merge problem in disguise'; why = 'why a text merge cannot settle it is unstated' }
      @{ p = '(?is)route every decision this stage cannot make already takes'
         why = 'an intent conflict gets a route of its own rather than the existing one' }
    ) 'the intent-conflict rule' @(
      @{ p = '(?i)(pick|choose|prefer|adopt)\w*[^.]{0,60}(intent|reading|child|the (better|stronger|narrower|newer|more recent))'
         why = 'the stage picks between two intents' }
      @{ p = '(?i)resolve\w*[^.]{0,40}intent'; why = 'an intent conflict is resolved rather than raised' }
    )
    $true
  }
}

Describe-Ticket 'parallel-tickets/06' 'a failed sibling does not sink the set, and review reaches the child that asked' {

  $work = { Get-Subsection (Get-SkillFile 'implement/SKILL.md') 'Working a set' }
  $run  = { Get-Subsection (Get-SkillFile 'implement/SKILL.md') 'Running one' }

  # The inversion this ticket exists for. All-or-nothing is right for portions,
  # which are one ticket between them, and would otherwise discard four finished
  # tickets because a fifth unrelated one failed.
  Assert "a failed or stopped child leaves its siblings landed, and its worktree is kept" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)leaves its siblings landed') @(
      @{ p = '(?is)leaves its siblings landed'; why = 'a failure may still sink the set' }
      @{ p = '(?is)verifiable on its own'; why = 'why a set inverts the rule is unstated' }
      @{ p = '(?is)returns to the frontier'; why = 'the failed ticket has nowhere to go back to' }
      @{ p = '(?is)its worktree is kept'; why = 'the worktree is not kept, so a resumed session rebuilds' }
    ) 'the per-ticket failure rule' @(
      @{ p = '(?i)(stop|sink|discard|abandon|reset)\w*[^.]{0,60}(the whole set|every sibling|all of them|every branch)'
         why = "the fan-out's all-or-nothing rule crossed over" }
      @{ p = '(?i)nothing (of the set )?(is )?(integrat|land)'; why = 'nothing lands when one member fails' }
      @{ p = '(?i)worktree[^.]{0,40}(discard|delet|remov|clean)'; why = 'the failed worktree is thrown away' }
    )
    $true
  }

  # ADR 0049 adds `waiting` as a fourth return, and the policy is explicit that
  # resuming a waiting child and re-dispatching a stopped one are different acts.
  # The stage is the only reader of a return, so it is the only place that
  # difference can be honoured — and conflating the two frontiers a ticket
  # somebody is still holding.
  Assert "the four outcomes are dispositioned, and waiting moves nothing" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)four outcomes') @(
      @{ p = '(?is)only two move a ticket backwards'; why = 'how many outcomes end a ticket is unstated' }
      @{ p = '(?is)`?waiting`?\*{0,2} moves nothing at all'; why = 'waiting is collapsed into an ending' }
      @{ p = '(?is)read the fourth as an ending'; why = 'the cost of conflating waiting with stopped is unstated' }
    ) 'the four outcomes'
    $true
  }

  # A half-landed set is a state nothing else in this workflow produces, so there
  # is no convention a reader can fall back on to interpret silence.
  Assert "the run names which tickets landed and which did not, with a reason for each that did not" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)which of the set shipped') @(
      @{ p = '(?is)which of the set shipped and which did not'; why = 'the run need not say what landed' }
      @{ p = '(?is)why for each that did not'; why = 'a ticket may be reported missing with no reason' }
      @{ p = '(?is)true about the three and false about the run'; why = 'why a bare done is a lie is unstated' }
      # `reason` earns its place: "where the reason is obviously uninteresting,
      # leave it out" mentions nothing else in this list, and is the whole rule
      # undone.
    ) 'the reporting obligation'
    $true
  }

  # ADR 0049: the findings arrive "so it can fix them before its ticket lands".
  # Reviewing after the commit is what that decision exists to replace — the
  # child is finished by then and there is nobody left to act on a finding.
  Assert "a set child requests its own review, and the findings reach that child before it lands" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)requests its own review') @(
      @{ p = '(?is)requests its own review, and the findings come back to it'
         why = 'who asks for review and who receives it is unstated' }
      @{ p = '(?is)before that ticket lands'; why = 'review may happen after the ticket has landed, which ADR 0049 replaced' }
      # The depth bound and what a request costs are the policy's, and an earlier
      # version of this paragraph reproduced its closing clause word for word.
      @{ p = '(?is)the policy has that bound and what a request costs'
         why = 'the bound a child works under is restated rather than reached' }
      @{ p = '(?is)which fixes them and returns again'; why = 'what the child does with the findings is unstated' }
      @{ p = '(?is)author of a ticket it never claimed'; why = 'why the orchestrator may not apply them itself is unstated' }
      @{ p = '(?is)reviewing after the commit would be worse'; why = 'the ordering this replaces is unstated' }
    ) 'brokered review' @(
      # Indicative only. This paragraph's own argument is "this stage *applying*
      # them instead **would** make it the author of a ticket it never claimed",
      # and a participle in the list fires on the rule rather than its breach.
      @{ p = '(?i)(this stage|the orchestrator)[^.]{0,60}\b(applies|fixes|makes the correction|corrects|acts on)\b[^.]{0,40}(it|them|the finding)'
         why = 'the stage applies the findings instead of the child' }
      @{ p = '(?i)review[^.]{0,60}after (the set|everything|the commit) (has )?land'; why = 'review moves back to after the ticket lands' }
      @{ p = '(?i)at depth one'; why = "the policy's depth clause is restated here" }
    )    if ((Get-Paragraph (& $work) '(?i)requests its own review') -match '(?i)at depth one') {
      throw "the policy's depth clause is restated here"
    }
    $true
  }

  # The cap is what keeps a broker from becoming an unbounded channel: a child
  # that cannot converge ends rather than loops — and it ends as the failure
  # above, not as a state of its own.
  Assert "a child that exhausts its cap ends as a failed ticket rather than a loop" {
    $p = Get-Paragraph (& $work) '(?i)exhausts its cap'
    Assert-RuleParagraph $p @(
      @{ p = '(?is)ends as a failed ticket'; why = 'running out of cap has no stated end' }
      @{ p = '(?is)runs out rather than looping'; why = 'nothing stops a child asking forever' }
      @{ p = '(?is)rather than a state of its own'; why = 'exhaustion becomes a fifth outcome nobody handles' }
    ) 'the cap'
    if ($p -match $rulePattern['a request spends the cap']) { throw "the policy's cap rule is restated rather than reached" }
    $true
  }

  # Criterion: both rules coexist, and neither is stated twice. Asserted as
  # exclusion in both directions — a rule present in the other subsection is the
  # second home, whichever way round it happened. The set's side is checked by
  # subject rather than by the fan-out's wording, because a paraphrase of the
  # portion rule inside the set's subsection is the same defect.
  Assert "the portion review rule is unchanged, and neither axis states the other's" {
    $r = & $run
    $w = & $work
    if ($r -notmatch '(?is)`/review` runs once, on the integrated result') { throw "the fan-out's review rule is gone" }
    if ($r -notmatch '(?is)would miss the only thing a fan-out newly risks') { throw "the fan-out's reason for it is gone" }
    if ($w -match '(?is)review[^\r\n]{0,80}(runs? once|a single time|only once)|(?is)(once|a single time)[^\r\n]{0,60}(the integrated|every portion|all the portions)') {
      throw "the fan-out's review rule is restated in the set's subsection"
    }
    if ($r -match $rulePattern['a set child requests its own review']) { throw "the set's review rule is restated in the fan-out's subsection" }
    $true
  }

  Assert "what a child stopped on still reaches the human, brokered or not" {
    Assert-RuleParagraph (Get-Paragraph (& $work) '(?i)still reaches the human') @(
      @{ p = '(?is)still reaches the human'; why = 'a stopped question need not reach anybody' }
      @{ p = '(?is)resumed with the answer and the run continues'; why = 'a brokered answer never gets back to the child' }
      @{ p = '(?is)one it cannot carry travels in the report'; why = 'the unbrokerable case has no disposition' }
      @{ p = '(?is)that ticket returns to the frontier'; why = 'the ticket behind an unanswered question is stranded' }
      @{ p = '(?is)the human answers either way'; why = 'who answers is left open' }
    ) 'the route to the human' @(
      # The verb has to be this stage's own act on the question. Written loosely
      # it fired on "a question this stage can carry … the answer", which is the
      # rule rather than its breach.
      @{ p = '(?i)(this stage|the orchestrator)\s+(answers|supplies|decides|settles)\b[^.]{0,40}\b(it|the answer|the question|instead)\b'
         why = 'the stage answers for the human' }
      @{ p = '(?i)(decide|resolve|settle)\w*[^.]{0,40}on (the|a) child.s behalf'; why = "the stage decides on a child's behalf" }
    )
    $true
  }
}

Describe-Ticket 'parallel-tickets/07' 'adopt the second axis here' {

  $ticket = Join-Path $repo '.claude/tickets/parallel-tickets/issues/07-adopt-the-second-axis-here.md'

  # `orchestration/08` already asserts installed-equals-template on the body,
  # and `parallel-tickets/02` asserts the template carries the second axis.
  # Neither reads the installed file for that content, so a narrowing of either
  # would leave this criterion untested by a composition nobody re-checked.
  Assert "the amended policy is installed here, carrying the second axis and not only the first" {
    $p = Join-Path $repo '.claude/policies/sub-agents.md'
    if (-not (Test-Path $p)) { throw 'the policy is not installed' }
    $c = Get-Content $p -Raw
    if ($c -notmatch '(?is)portion of one ticket or a whole ticket') { throw 'the installed policy knows only the portion unit' }
    if ($c -notmatch '(?is)declines it and records the decline')     { throw 'the installed policy has no decline rule' }
    if ($c -notmatch '(?is)exactly two things may be requested')     { throw 'the installed policy has no closed request menu' }
    $true
  }

  # Same shape as orchestration/05's migration guard: by content, both halves,
  # and repairing rather than reporting — the half a migration row loses first.
  Assert "the migration recognises a first-axis repository by content, and repairs it" {
    $s = Get-Section (Get-MigrationText) 'first axis without the second'
    if ($s -notmatch '(?is)recognition is by content') { throw 'the row keys on presence rather than content' }
    if ($s -notmatch '(?is)the policy is present')     { throw 'the first half of the test is unstated' }
    if ($s -notmatch '(?is)no whole-ticket child|admits no whole-ticket child') { throw 'the second half of the test is unstated' }
    if ($s -notmatch '(?is)repairs rather than reports') { throw 'the row reports instead of repairing' }
    $true
  }

  # The decision is checked as a decision: the reason is stated where a reader
  # of the Domain Context finds it, and both halves are required. Either half
  # alone is an assertion of taste — mutual definition without the routing
  # argument does not explain why two files could not simply cross-reference.
  Assert "the second axis earns no Domain Context of its own, with the reason stated" {
    $c = Get-Content (Join-Path $repo '.claude/contexts/orchestration.md') -Raw
    if ($c -notmatch '(?is)\bBoth axes live in this file\b') { throw 'the decision is not stated as a boundary' }
    if ($c -notmatch '(?is)defined by what the other inverts') { throw 'the mutual-definition half of the reason is missing' }
    if ($c -notmatch '(?is)after routing has already run') { throw 'the routing half of the reason is missing' }
    $rows = [regex]::Matches((Get-Content (Join-Path $repo '.claude/contexts/map.md') -Raw), '(?im)^\|\s*\[([a-z-]+)\]')
    $axis = @($rows | Where-Object { $_.Groups[1].Value -match 'set|dispatch|fan-?out|parallel' })
    if ($axis.Count -gt 0) { throw "the map routes a second orchestration context: $($axis[0].Groups[1].Value)" }
    $true
  }

  # The map and the file it routes to disagreed on sources until this ticket,
  # and nothing would have caught it: every other guard reads one or the other.
  # Compared as sets, because the order in a table cell carries no meaning.
  Assert "the routing table and the Domain Context name the same sources" {
    $paths = {
      param($text)
      @([regex]::Matches($text, '`([^`]+)`') | ForEach-Object { $_.Groups[1].Value }) | Sort-Object -Unique
    }
    # Repointed by mechanics/12: the prose `Sources:` line became a declared
    # field, so the file's half is read out of frontmatter and carries no
    # backticks. The check itself is unchanged and is now nearly tautological —
    # the map is generated from this field — but it is what would catch a
    # hand-edited map, which is the failure it was written for.
    $dc = Get-Content (Join-Path $repo '.claude/contexts/orchestration.md') -Raw
    $line = [regex]::Match($dc, '(?im)^sources:\s*\[(.*?)\]\s*$')
    if (-not $line.Success) { throw 'the Domain Context declares no sources' }
    $row = [regex]::Match((Get-Content (Join-Path $repo '.claude/contexts/map.md') -Raw),
                          '(?im)^\|\s*\[orchestration\][^|]*\|[^|]*\|([^|]*)\|')
    if (-not $row.Success) { throw 'the map has no orchestration row' }
    $inFile = @($line.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) | Sort-Object -Unique
    $inMap  = & $paths $row.Groups[1].Value
    if ("$inFile" -ne "$inMap") {
      throw "sources disagree — file: $($inFile -join ', ') / map: $($inMap -join ', ')"
    }
    $true
  }

  # The acceptance asks for the chain *and* why it was one. Recording only the
  # shape reads as an apology; the reason is the part a later effort can use.
  Assert "the chain shape of this effort is recorded, with the reason it was a chain" {
    $c = Get-Content $ticket -Raw
    if ($c -notmatch '(?is)01\s*→\s*02\s*→\s*03\s*→\s*04\s*→\s*05\s*→\s*06\s*→\s*07') { throw 'the chain is not recorded' }
    if ($c -notmatch '(?is)(largest|maximum) set[^.]{0,60}\bone\b') { throw 'the set size the chain permitted is unstated' }
    # The criterion has two halves and the second is answerable by implication,
    # which is how it goes unanswered: a chain says none could run together only
    # to a reader who reasons it out.
    if ($c -notmatch '(?is)could have run together[^.]{0,40}\bnone\b') { throw 'which could have run together is left to inference' }
    if ($c -notmatch '(?is)genuine rather than conservative') { throw 'whether the edges were real is not settled' }
    if ($c -notmatch '(?is)creates the surface the next one edits') { throw 'the reason it was a chain is unstated' }
    $true
  }

  # The measured collision case, which is the criterion most likely to be met
  # by naming `verify.ps1` and stopping — the four-way overlap is the obvious
  # half, and the missing edge is the half that decides whether the optimistic
  # dispatch was the right trade.
  Assert "the measured collision case names the paths, and what the records would have had to carry" {
    $c = Get-Content $ticket -Raw
    # Scoped to the table's own first cell, not to the file. Every one of these
    # paths is also named in the prose around the table, so a whole-file match
    # stayed green with a row deleted — the guard was reading the argument
    # rather than the measurement it exists to check.
    $cells = @([regex]::Matches($c, '(?im)^\|\s*`([^`]+)`\s*\|') | ForEach-Object { $_.Groups[1].Value })
    foreach ($p in 'scripts/verify.ps1', 'skills/implement/SKILL.md',
                   'agents/researcher.md', 'agents/standards-reviewer.md') {
      if ($p -notin $cells) { throw "the collision table omits $p" }
    }
    if ($c -notmatch '(?is)appended a new block[^.]{0,80}edited an existing one') {
      throw 'what a record would have had to distinguish is unstated'
    }
    if ($c -notmatch '(?is)declares no edge on `?03`?, but edits two files') { throw 'the missing edge is not named' }
    if ($c -notmatch '(?is)missing edge[^.]{0,120}no amount of change-record detail repairs') {
      throw 'the limit of the change record is unstated'
    }
    $true
  }
}

# --- ticket worktrees/01 — the ignore rule covers child workspaces -----------

# The harness creates a worktree for every isolated child under
# `.claude/worktrees/`, so orchestration made a directory appear inside the
# protocol directory that nothing ignored. These guards read the shipped block
# rather than this repository's installed copy: adopting it here is 02's, and a
# guard that read the installed file would go green on the adoption while every
# repository AEP configures still had the defect.
Describe-Ticket 'worktrees/01' 'the ignore rule covers the harness''s child workspaces' {

  # Entries only — the comment names the path too, in prose, so a whole-block
  # match would stay green with the entry deleted and the paragraph left behind.
  # That is the failure mode `.claude/rules/skills.md` names: matching a phrase
  # travelling with the subject rather than the subject itself.
  $entries = {
    $block = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n(.*?)^```')
    if (-not $block.Success) { throw 'the .gitignore block is gone' }
    @($block.Groups[1].Value -split '\r?\n' |
      Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' } |
      ForEach-Object { $_.Trim() })
  }

  Assert "the shipped ignore block covers the harness's child workspaces" {
    $e = & $entries
    if ('/worktrees/' -notin $e -and 'worktrees/' -notin $e) {
      throw "a dispatched child's workspace is untracked in every configured repository: $($e -join ', ')"
    }
    $true
  }

  # Anchoring is not cosmetic here and the reason is this entry's own: a child's
  # workspace is a full checkout, so it contains its own `.claude/worktrees/`.
  # Unanchored, the pattern matches at every depth — which is the same argument
  # `/position/` was anchored for, reaching a case that actually nests.
  Assert "the entry is anchored, so it cannot match inside a child's own checkout" {
    $e = & $entries
    if ('worktrees/' -in $e) { throw 'unanchored — also matches .claude/worktrees/*/.claude/worktrees/' }
    if ('/worktrees/' -notin $e) { throw "the entry is not there to be anchored: $($e -join ', ')" }
    $true
  }

  # ADR 0012's finding, held against the second instance: a list is what the
  # file forgets. There are now two paths outside `position/` and both are the
  # harness's, so the comment has to state the shape they share — and stop
  # claiming `settings.local.json` is the only one, which is the sentence this
  # ticket falsified.
  Assert "the comment states the category the two harness paths share, not a list" {
    $block = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n(.*?)^```')
    if (-not $block.Success) { throw 'the .gitignore block is gone' }
    $b = $block.Groups[1].Value
    # Matched against the claim as it is actually worded — "the one per-clone
    # file that cannot be moved" — not against a paraphrase of it. A guard
    # written from the replacement's wording would have gone green on the
    # sentence still standing.
    if ($b -match '(?i)\bthe one\b[^.]{0,60}\bcannot be moved\b') { throw 'the comment still claims a single exception' }
    if ($b -notmatch '(?i)harness') { throw 'the comment never says whose the paths are' }
    if ($b -notmatch '(?i)wrong in another clone') { throw 'the membership test went with it' }
    $true
  }

  # Same shape as ADR 0045's guard, because it is the same amendment: a harness
  # path the workflow depends on, entering a layout that did not name it. Both
  # halves — §21 naming it, and saying whose it is. Naming it alone would put a
  # directory in the canonical tree that `/configure` is then expected to create.
  Assert "the specification's layout names the directory and marks it the harness's" {
    $s = Get-SpecSection 21
    if ($s -notmatch '(?m)^\s+worktrees/\s') { throw 'the specification layout omits it, so the tree comparison cannot see it' }
    if ($s -notmatch '(?im)^\s+worktrees/[^\r\n]*harness') { throw "the row never says the directory is the harness's" }
    $true
  }

  # ADR 0029's citation half, guarded as 0045's is. The version the amendment
  # moved to is recorded in the Decision, so a reader arriving at the ADR learns
  # which release carried it without reconstructing it from the log.
  Assert "the layout amendment is recorded as a Decision the shipped skill cites" {
    $adr = Join-Path $repo '.claude/decisions/0050-spec-21-names-the-harness-worktree-directory.md'
    if (-not (Test-Path $adr)) { throw 'no Decision records the amendment' }
    $c = Get-Content $adr -Raw
    if ($c -notmatch '(?i)§21') { throw 'the Decision does not name the section it amends' }
    # Pinned to the version this Decision moved the specification to, not read
    # off `specs.md`. Reading it live coupled a frozen record to a moving
    # number: the next bump falsified an ADR that had recorded the truth at the
    # time, leaving only two ways out, and one of them is editing frozen
    # reasoning. Found by the 1.9.0 bump, which failed this on 0050 having
    # correctly said 1.8.0.
    if ($c -notmatch [regex]::Escape('1.8.0')) { throw 'the Decision does not record the version it moved to' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    $true
  }

  # Found by the whole-diff knowledge check at commit, not by the plan: the
  # router states the same count the ignore file's comment did, so correcting
  # one and not the other would leave the shipped protocol file asserting a
  # single exception against an ignore file listing two.
  Assert "the shipped protocol file does not claim a single path outside position/" {
    $c = Get-SkillFile 'configure/protocol.template.md'
    if ($c -match '(?i)one file sits outside') { throw 'the router still counts one exception' }
    if ($c -notmatch '(?i)worktrees') { throw 'the router never names the second path' }
    $true
  }

  # Criterion 5's third clause, missed when 01 was built and caught by the
  # spec check at 02's commit. The row is what reaches a repository arriving
  # from a superseded layout, which the audit above does not cover: those two
  # are different paths in and both have to name the entry.
  Assert "the migration row names the covered path" {
    $c = Get-SkillFile 'configure/MIGRATION.md'
    $row = [regex]::Match($c, '(?m)^\|\s*`\.claude/\.gitignore`\s*\|([^|]*)\|')
    if (-not $row.Success) { throw 'the migration has no ignore-file row' }
    if ($row.Groups[1].Value -notmatch 'worktrees') { throw "the row rewrites the file without the entry: $($row.Groups[1].Value.Trim())" }
    $true
  }

  # The repair half, and the one the ticket calls the risk: a repository
  # configured before this rule never re-runs the generate branch on its own, so
  # the fix reaches it only if the audit does. Bound to the audit section rather
  # than the file — the generate step names the path too, and a file-wide match
  # would pass on that with the audit row absent.
  Assert "the audit repairs an ignore file that predates the rule, rather than reporting it" {
    $s = Get-AuditReach
    if ($s -notmatch '(?i)worktrees') { throw 'the audit never reaches an ignore file written before the rule' }
    if ($s -notmatch '(?is)worktrees[^\r\n]{0,200}(repair|heal|add)') { throw 'the audit reports it instead of repairing it' }
    $true
  }
}

# --- ticket worktrees/02 — adopt the covered ignore rule here -----------------

# 01's guards all read the shipped block, deliberately, so none of them says
# anything about this clone. These read the installed files — which is the whole
# of the difference between the two tickets.
Describe-Ticket 'worktrees/02' 'adopt the covered ignore rule here' {

  Assert "the installed ignore file matches the block this repository ships" {
    $p = Join-Path $repo '.claude/.gitignore'
    if (-not (Test-Path $p)) { throw 'there is no installed ignore file' }
    $block = [regex]::Match((Get-SkillFile 'configure/SKILL.md'), '(?ms)^```gitignore\r?\n(.*?)^```')
    if (-not $block.Success) { throw 'the shipped block is gone' }
    # Line endings only. The checkout is pinned to LF now, so this normalisation
    # is no longer what makes the comparison work — it is what keeps the
    # comparison from depending on that pin. A raw comparison would fail on
    # whichever ending it was not written for, which is the shape of green that
    # hides a real divergence.
    $norm = { param($t) ($t -replace '\r\n', "`n").TrimEnd() }
    if ((& $norm $block.Groups[1].Value) -ne (& $norm (Get-Content $p -Raw))) {
      throw 'the installed ignore file has diverged from the block AEP distributes'
    }
    $true
  }

  # The criterion asks git rather than the file, and that is the point: the
  # entry being present is what 01 asserts, and what this repository needs is
  # the *outcome*. A pattern can be present and not match — an unanchored one,
  # or one shadowed by an earlier negation — and only git knows.
  Assert "a path inside a child workspace is ignored in this clone, asked of git" {
    $probe = '.claude/worktrees/some-child/src/main.ts'
    & git -C $repo check-ignore -q $probe
    if ($LASTEXITCODE -ne 0) { throw "git does not ignore $probe — a dispatched child's checkout would be untracked here" }
    # Committed knowledge must stay visible, or the entry is over-broad —
    # and this half needs `--no-index` to be able to fire at all. `git
    # check-ignore` skips tracked paths, because ignore rules do not apply to
    # tracked content, so probing a committed file without it reports "not
    # ignored" no matter what the patterns say. Found by appending `policies/`
    # and watching the guard stay green twice.
    foreach ($visible in '.claude/policies', '.claude/policies/sub-agents.md') {
      & git -C $repo check-ignore -q --no-index $visible
      if ($LASTEXITCODE -eq 0) { throw "the entry is over-broad — it ignores committed knowledge at $visible" }
    }
    $true
  }

  # The router half, found by 01's whole-diff check and fixed only in the
  # shipped copy. Read here from the installed file for the reason the block
  # above gives: 01's guard cannot see this clone.
  Assert "the installed router does not claim a single path outside position/" {
    $c = Get-Content (Join-Path $repo '.claude/protocol.md') -Raw
    if ($c -match '(?i)one file sits outside') { throw 'the installed router still counts one exception' }
    if ($c -notmatch '(?i)worktrees') { throw 'the installed router never names the second path' }
    $true
  }
}

# --- ticket mechanics/01 — the marker records the tree it read drift against --

# Every assertion here is scoped to §19. The marker's vocabulary travels into
# §22 and into the protocol template, so a file-wide match would pass on text
# that says nothing about the rule this ticket changed.
#
# The negative guards below are written against the *subject* — the match
# condition, the licence, the writer — rather than against the sentences that
# were just written. A guard transcribed from new wording matches only that
# wording, and this file already records four occasions where that happened.
Describe-Ticket 'mechanics/01' 'the marker records the tree it read drift against' {

  $s19 = Get-SpecSection 19

  Assert "the section this ticket amends resolves, and to itself" {
    if ($s19 -notmatch '(?m)\A##[^\r\n]*Verification and healing') { throw 'section 19 resolved to the wrong heading' }
    $true
  }

  Assert "the marker records two facts, and the rule compares both" {
    if ($s19 -notmatch '(?is)\*\*The marker\.\*\*') { throw 'the marker paragraph is gone' }
    if ($s19 -notmatch '(?is)marker[^.]{0,200}(tree|fingerprint)') { throw 'the marker records no tree fact' }
    if ($s19 -notmatch '(?is)(both are compared|compares both|both facts are compared)') {
      throw 'nothing says both facts are compared'
    }
    $true
  }

  # The defect this replaces: trust conditioned on the tree's *state* rather
  # than on its identity. Matched by subject — any sentence that makes
  # cleanliness a condition of trusting or skipping — so a reintroduction
  # phrased as "carries no local changes" is caught with the original wording
  # gone. The fallback sentence legitimately reads the tree live, so sentences
  # about the absent-fact case are excluded rather than the word being banned.
  Assert "tree cleanliness is nowhere a condition of the match" {
    foreach ($sent in [regex]::Split($s19, '(?<=\.)\s+')) {
      if ($sent -match '(?i)(clean|unmodified|pristine|no (uncommitted|local|outstanding) changes)' -and
          $sent -match '(?i)(trusted|no reading|skip|match)' -and
          $sent -notmatch '(?i)(absent|unknown|falls back|fallback)') {
        throw "a clean-tree condition survives: $sent"
      }
    }
    $true
  }

  Assert "a match licenses skipping the drift reads, and says so as the bound" {
    if ($s19 -notmatch '(?is)match[^.]{0,120}(skip|may be skipped)[^.]{0,60}drift') {
      throw 'nothing ties a match to skipping the drift reads'
    }
    $true
  }

  # Presence of the affirmative is symmetric with its negation, so the licence
  # is checked by its refusal rather than by its claim: what must be present is
  # the sentence ruling out the *stronger* reading.
  Assert "a match is refused the claim that knowledge is correct" {
    if ($s19 -notmatch '(?is)(does\s+\*{0,2}not\*{0,2}|never)\s+mean[^.]{0,80}(correct|verified|true|right)') {
      throw 'nothing refuses the reading that a match means knowledge is correct'
    }
    $true
  }

  Assert "verification at use is stated as unaffected by the marker" {
    if ($s19 -notmatch '(?is)(verification at use|about to be relied on)[^.]{0,160}(unaffected|regardless|whether or not|whether the marker)') {
      throw 'nothing says verification at use is unaffected by a matching marker'
    }
    $true
  }

  Assert "the commit stage writes both facts, together" {
    if ($s19 -notmatch '(?is)commit stage[^.]{0,80}both') { throw 'the commit stage is not named as the writer of both' }
    $true
  }

  Assert "the re-stamp is conditional on dealing with the drift, not on reading it" {
    if ($s19 -notmatch '(?is)(re-stamp|restamp)[^.]{0,200}(tree)') { throw 'no re-stamp permission is stated' }
    if ($s19 -notmatch '(?is)(deals?|dealt|dealing) with what[^.]{0,60}found') { throw 'the permission is not conditioned on dealing with the drift' }
    if ($s19 -notmatch '(?is)conditional on the dealing') { throw 'the condition is not named as the dealing rather than the reading' }
    $true
  }

  # A rule and its negation are not interchangeable, and presence alone cannot
  # tell them apart — so the case that must be *refused* is asserted on its own.
  Assert "a stage that read drift and did nothing about it is refused the re-stamp" {
    if ($s19 -notmatch '(?is)neither healed nor discounted[^.]{0,80}(nothing|re-stamps nothing)') {
      throw 'nothing rules out re-stamping after a drift read that changed nothing'
    }
    $true
  }

  Assert "an absent tree fact is a defined state with a defined fallback" {
    if ($s19 -notmatch '(?is)absent tree fact[^.]{0,80}unknown') { throw 'an absent tree fact is not defined' }
    if ($s19 -notmatch '(?is)falls back') { throw 'no fallback is stated' }
    $true
  }

  Assert "a Decision records the narrowing, and why a second writer is safe under it" {
    $p = Join-Path $repo '.claude/decisions/0052-the-marker-records-the-tree-and-claims-only-that-drift-was-read.md'
    if (-not (Test-Path $p)) { throw 'the Decision is missing' }
    $c = Get-Content $p -Raw
    if ($c -notmatch '(?is)narrow') { throw 'the Decision does not record the narrowing' }
    if ($c -notmatch '(?is)Considered Options') { throw 'the Decision weighs no alternatives' }
    foreach ($alt in 'stash create', 'porcelain', 'dirty set') {
      if ($c -notmatch [regex]::Escape($alt)) { throw "the Decision does not record why '$alt' was rejected" }
    }
    $true
  }
}

# --- ticket mechanics/05 — a routing table is generated from declared fields --

# Split across the two sections that own the halves: §8 states the mechanism,
# §16 applies it to Decisions and adds supersession. Asserting either file-wide
# would pass on the other's text, and the whole claim of this ticket is that
# both sections now say it.
Describe-Ticket 'mechanics/05' 'a routing table is generated from declared fields' {

  $s8  = Get-SpecSection 8
  $s16 = Get-SpecSection 16

  Assert "the two sections this ticket amends resolve, and to themselves" {
    if ($s8  -notmatch '(?m)\A##[^\r\n]*Contexts')  { throw 'section 8 resolved to the wrong heading' }
    if ($s16 -notmatch '(?m)\A##[^\r\n]*Decisions') { throw 'section 16 resolved to the wrong heading' }
    $true
  }

  Assert "a routing table is generated rather than written, and names the two declared fields" {
    if ($s8 -notmatch '(?is)routing table is generated') { throw 'nothing says the table is generated' }
    if ($s8 -notmatch '(?is)load condition') { throw 'the load-condition field is unnamed' }
    if ($s8 -notmatch '(?is)\bsources\b') { throw 'the sources field is unnamed' }
    $true
  }

  # ADR 0002 turned on this distinction, and it is the one thing generation
  # cannot enforce — so the specification has to carry it explicitly. Matched by
  # subject: the load condition set against subject matter, in either order.
  Assert "the load condition is a trigger, and subject matter is refused" {
    if ($s8 -notmatch '(?is)(when to load)[^.]{0,120}(never|not)[^.]{0,120}(about|topic|subject)' -and
        $s8 -notmatch '(?is)(never|not)[^.]{0,120}(about|topic|subject)[^.]{0,120}(when to load)') {
      throw 'nothing sets the trigger against a description of subject matter'
    }
    $true
  }

  # The property, not the convenience. A generated table that were merely
  # tidier would not have justified the change.
  Assert "generation is justified by the drift it makes impossible, not by effort saved" {
    if ($s8 -notmatch '(?is)cannot (disagree|drift)') { throw 'the impossibility is not stated' }
    if ($s8 -notmatch '(?is)(not a second statement|does not arise)') {
      throw 'nothing says why it cannot drift, so the claim reads as an assertion'
    }
    $true
  }

  Assert "a generated file is not hand-edited, and the prohibition is enforced rather than requested" {
    if ($s8 -notmatch '(?is)never hand-edited') { throw 'hand-editing is not prohibited' }
    if ($s8 -notmatch '(?is)enforced[^.]{0,80}(regeneration|regenerat)') {
      throw 'the prohibition is stated without the thing that enforces it'
    }
    $true
  }

  Assert "Decisions are routed on the same mechanism, with the reason the cost is monotonic" {
    if ($s16 -notmatch '(?is)routed') { throw 'Decisions are not declared routed' }
    if ($s16 -notmatch '(?is)load condition') { throw 'a Decision declares no load condition' }
    if ($s16 -notmatch '(?is)monotonic|nothing ever shrinks') { throw 'the reason routing is needed is unstated' }
    $true
  }

  Assert "supersession is declared at both ends, and one-sidedness is a defect" {
    if ($s16 -notmatch '(?is)both ends') { throw 'supersession is not stated as two-ended' }
    if ($s16 -notmatch '(?is)(one end|at one end)[^.]{0,100}(defect|absent at the other)') {
      throw 'a one-sided claim is not called a defect'
    }
    $true
  }

  Assert "the freeze survives: only status moves after a Decision is committed" {
    if ($s16 -notmatch '(?is)status[^.]{0,120}(moves|move)') { throw 'the moving field is unnamed' }
    if ($s16 -notmatch '(?is)reasoning is frozen') { throw 'the freeze is no longer stated' }
    $true
  }

  Assert "a Decision records why declared fields are not the pattern ADR 0002 rejected" {
    $p = Join-Path $repo '.claude/decisions/0053-a-routing-table-is-generated-from-fields-the-routed-file-declares.md'
    if (-not (Test-Path $p)) { throw 'the Decision is missing' }
    $c = Get-Content $p -Raw
    if ($c -notmatch '(?is)0002') { throw 'the Decision never engages with ADR 0002' }
    if ($c -notmatch '(?is)trigger sentence') { throw 'the Decision does not identify what 0002 turned on' }
    if ($c -notmatch '(?is)Considered Options') { throw 'the Decision weighs no alternatives' }
    $true
  }
}

# --- ticket mechanics/09 — two homes for the dependency set, and which wins ---

# The containment assertion below is the one that does real work: the rest state
# the rule, and this one is the thing that would have caught the relationship
# going wrong while nobody had declared there was one.
#
# `(?m)$` cannot be used to bound a table row here. Under CRLF `[^\r\n]*` stops
# before the `\r` while `$` matches before the `\n` — the two positions differ by
# one character and every such match silently fails. Found by a row check that
# reported "no row" for all seven stages, on a checkout that was CRLF at the
# time. The pin makes that checkout LF and does not make this safe to undo: a
# pattern that only works under one ending is what `line-endings/01` removed.
Describe-Ticket 'mechanics/09' 'the stage-dependency set has two homes, and the table wins' {

  $s5  = Get-SpecSection 5
  $s11 = Get-SpecSection 11

  # The seven spine stages, which are what the table has rows for. Primitives
  # and on-ramps declare policies too and are deliberately not in it — a skill
  # is not a stage, and asserting over every skill would demand rows for files
  # the table has no business naming.
  $spine = @('configure', 'design', 'implement', 'review', 'research', 'prototype', 'commit')

  Assert "the two sections this ticket amends resolve, and to themselves" {
    if ($s5  -notmatch '(?m)\A##[^\r\n]*Protocol') { throw 'section 5 resolved to the wrong heading' }
    if ($s11 -notmatch '(?m)\A##[^\r\n]*Skills')   { throw 'section 11 resolved to the wrong heading' }
    $true
  }

  Assert "each home is named for what it alone can know" {
    if ($s5 -notmatch '(?is)cannot know[^.]{0,80}local') { throw 'section 5 does not say what a skill cannot know' }
    if ($s11 -notmatch '(?is)(default)[^.]{0,60}(instance|protocol table)') {
      throw 'section 11 does not name the pair as a default and an instance'
    }
    $true
  }

  Assert "the precedence is stated, and carries its reason rather than only its verdict" {
    if ($s5 -notmatch '(?is)table (governs|wins)') { throw 'no precedence is stated' }
    if ($s5 -notmatch '(?is)written where the repository is|table is written where') {
      throw 'the precedence is asserted without the reason it runs that way'
    }
    $true
  }

  Assert "the table is derived by the configuration stage, not authored" {
    if ($s5 -notmatch '(?is)derived by the configuration stage') { throw 'nothing says the table is derived' }
    if ($s5 -notmatch '(?is)plus whatever is local') { throw 'the local half of the derivation is unstated' }
    $true
  }

  # The tempting deletion, refused with the fact that refuses it. Without this
  # the next reader re-proposes dropping the table, since inside a session it
  # is always read after the skill that pointed at it.
  Assert "dropping the table is refused, and on the plugin-independence fact" {
    if ($s5 -notmatch '(?is)cannot be dropped') { throw 'nothing refuses dropping the table' }
    if ($s5 -notmatch '(?is)absent from the tree') { throw 'the refusal does not name why a skill is unreachable' }
    $true
  }

  # A second home is exactly what single-home forbids, so the exception has to
  # state its own bound or it becomes the precedent for any duplication.
  Assert "the exception states the asymmetry that bounds it, and refuses to generalise" {
    if ($s11 -notmatch '(?is)asymmetry is absent[^.]{0,120}(duplication|not a precedent)') {
      throw 'the two-home exception does not bound itself'
    }
    $true
  }

  Assert "every spine stage has exactly one row in the installed table" {
    $proto = Get-Content (Join-Path $repo '.claude/protocol.md') -Raw
    foreach ($s in $spine) {
      $rows = [regex]::Matches($proto, "(?m)^\|\s*``/$s``\s*\|")
      if ($rows.Count -ne 1) { throw "/$s has $($rows.Count) rows, not one" }
    }
    $true
  }

  # The containment assertion that stood here matched a prose `Policies:` line
  # in the skill body. `declared-fields/02` moved that fact into `metadata:` and
  # deleted the prose form from every skill, which left this iterating seven
  # stages, hitting its `continue` on all seven, and returning success — a green
  # result that measured nothing. It is deleted rather than ported because the
  # bidirectional check at "declares exactly what the routing table routes to it"
  # already does the same job against the field form, in both directions.

  Assert "a Decision records the pair, and why neither home could be deleted" {
    $p = Join-Path $repo '.claude/decisions/0054-the-stage-dependency-set-has-two-homes-and-the-protocol-table-wins.md'
    if (-not (Test-Path $p)) { throw 'the Decision is missing' }
    $c = Get-Content $p -Raw
    if ($c -notmatch '(?is)Considered Options') { throw 'the Decision weighs no alternatives' }
    if ($c -notmatch '(?is)Table canonical') { throw 'the Decision does not weigh deleting the skill line' }
    if ($c -notmatch '(?is)Skills canonical') { throw 'the Decision does not weigh deleting the table' }
    $true
  }
}

# --- ticket mechanics/10 — every shipped role declares its mode ---------------

# This ticket amends no specification section: §20 already says agents differ by
# mode among other things, so the roles declaring none were failing a statement
# that was already normative. Asserted below against that sentence, so a future
# edit that removes the obligation takes this ticket's justification with it
# rather than leaving five orphaned fields.
Describe-Ticket 'mechanics/10' 'every shipped role declares its mode' {

  $roleDir = Join-Path $repo 'agents'
  $roles = Get-ChildItem $roleDir -File -Filter *.md
  $modeDir = Join-Path $skills 'configure/modes'

  Assert "the specification already obliges an agent to have a mode" {
    $s20 = Get-SpecSection 20
    if ($s20 -notmatch '(?is)agents differ[^.]{0,60}mode') {
      throw 'section 20 no longer names mode as something an agent carries'
    }
    $true
  }

  Assert "every shipped role declares exactly one mode" {
    if ($roles.Count -lt 1) { throw 'no roles ship' }
    foreach ($r in $roles) {
      $c = Get-Content $r.FullName -Raw
      if (-not (Get-Frontmatter $c)) { throw "$($r.Name) has no frontmatter" }
      # ADR 0055 puts the same map on both shipped surfaces. Containment is
      # checked rather than mere presence, because a `mode:` indented under any
      # other key is not declared where the decision says — which is the failure
      # this same assertion shipped with on the skills surface and did not catch.
      if ($null -eq (Get-DeclaredMode $c)) { throw "$($r.Name) does not declare exactly one mode inside metadata" }
    }
    $true
  }

  Assert "every declared mode names a mode that ships" {
    foreach ($r in $roles) {
      $mode = Get-DeclaredMode (Get-Content $r.FullName -Raw)
      if ($null -eq $mode) { throw "$($r.Name) declares no mode inside metadata" }
      $p = Join-Path $modeDir "$mode.template.md"
      if (-not (Test-Path $p)) { throw "$($r.Name) declares mode '$mode', which ships no file" }
    }
    $true
  }

  Assert "every role reaches its mode by pointer, and names the mode only once" {
    foreach ($r in $roles) {
      $c = Get-Content $r.FullName -Raw
      $body = $c -replace '(?s)\A---\r?\n.*?\r?\n---', ''
      if ($body -notmatch '(?is)\.claude/modes/') { throw "$($r.Name) never points at the mode directory" }
      $mode = Get-DeclaredMode $c
      # An empty `$mode` would turn the search below into a different question
      # and pass quietly. Assertions run independently, so the one above having
      # already caught this is not something this one may lean on.
      if ($null -eq $mode) { throw "$($r.Name) declares no mode inside metadata" }
      if ($body -match "(?i)\bmode:\s*$mode\b") {
        throw "$($r.Name) names its mode a second time in the body"
      }
    }
    $true
  }

  # Restatement, matched by paraphrase rather than by quotation. Each mode's
  # most copyable content is its tradeoff, so the guard carries the tradeoff's
  # own noun out of the mode file and looks for it near a giving-up verb — a
  # role that wrote "you trade momentum for thoroughness" is caught with none
  # of the mode's wording present.
  Assert "no role restates its mode's tradeoff, in the mode's words or its own" {
    foreach ($r in $roles) {
      $c = Get-Content $r.FullName -Raw
      $mode = Get-DeclaredMode $c
      # Without this, an absent mode reaches `Join-Path` and the assertion fails
      # with a path error naming a file nobody wrote — the reader is sent looking
      # for a missing template instead of a role missing its declaration.
      if ($null -eq $mode) { throw "$($r.Name) declares no mode inside metadata" }
      $modeText = Get-Content (Join-Path $modeDir "$mode.template.md") -Raw
      $t = [regex]::Match($modeText, '(?im)^Gives up:\s*(\w+)')
      if (-not $t.Success) { throw "the $mode mode states no tradeoff to check against" }
      $noun = $t.Groups[1].Value
      if ($c -match '(?im)^Gives up:') { throw "$($r.Name) carries a tradeoff line of its own" }
      if ($c -match "(?i)(gives? up|give up|trade[sd]?|sacrific\w*|forgo\w*)[^.]{0,60}\b$noun\b" -or
          $c -match "(?i)\b$noun\b[^.]{0,60}(is given up|is traded|is sacrificed)") {
        throw "$($r.Name) restates the $mode mode's tradeoff ('$noun')"
      }
    }
    $true
  }
}

# --- ticket mechanics/11 — a consumed drift finding records where it healed ---

# The criterion this ticket exists for is "answering whether a finding is still
# waiting requires reading only that finding". That is asserted below as a
# property of the file rather than as a sentence in a policy — a policy can say
# it while every finding on disk fails to carry it.
Describe-Ticket 'mechanics/11' 'a consumed drift finding records where it was healed' {

  $ev = Get-SkillFile 'configure/policies/evidence.template.md'

  Assert "the evidence policy states that a finding records its consumption, and where" {
    if ($ev -notmatch '(?is)records its own consumption') { throw 'consumption is not declared' }
    if ($ev -notmatch '(?is)Consumed:') { throw 'the policy names no field to carry it' }
    if ($ev -notmatch '(?is)naming where the healing landed') { throw 'the field is not required to name the destination' }
    $true
  }

  Assert "the account stays frozen, and the line sits beside it rather than inside it" {
    if ($ev -notmatch '(?is)(account itself is frozen|account is frozen)') { throw 'the freeze is unstated' }
    if ($ev -notmatch '(?is)beside it rather than inside it') { throw 'nothing says the account is not edited' }
    $true
  }

  Assert "the mark lands in the same change as the healing, with the reason a later one differs" {
    if ($ev -notmatch '(?is)same change as the healing') { throw 'the timing is unstated' }
    if ($ev -notmatch '(?is)window where it reads as waiting') { throw 'the reason a later mark is not equivalent is unstated' }
    $true
  }

  # The rule and its inversion are different rules, and only one of them is
  # safe. Asserted on the refusal, because "mark it when you know" and "work
  # out whether it was healed and mark it" both read as present.
  Assert "an unestablished consumption is left unmarked, and inferring one is refused" {
    if ($ev -notmatch '(?is)cannot be established[^.]{0,80}unmarked') { throw 'the default is unstated' }
    if ($ev -notmatch '(?is)(inferring|infer)[^.]{0,80}(guess|prevent)') { throw 'inferring consumption is not refused' }
    $true
  }

  Assert "the design stage reads waiting off the finding rather than deriving it" {
    $d = Get-SkillFile 'design/SKILL.md'
    if ($d -notmatch '(?is)(read off the finding|never derived)') { throw 'nothing says waiting is read rather than derived' }
    # Points rather than restates: the policy owns what the line is, so the
    # discovery step naming it would be the second home the sweep exists to
    # catch. What must be here is the pointer and the cost it removes.
    if ($d -notmatch '(?is)evidence\.md') { throw 'the discovery step does not point at the policy that answers it' }
    if ($d -notmatch '(?is)cost that line removes') { throw 'the reason the read is cheap is unstated' }
    $true
  }

  # The property, asked of the directory. A finding is answerable on its own or
  # it is not, and that is a fact about the files rather than about the prose.
  Assert "every finding on disk answers 'still waiting?' from its own text" {
    $dir = Join-Path $repo '.claude/evidence/drift'
    if (-not (Test-Path $dir)) { return $true }
    foreach ($f in Get-ChildItem $dir -File -Filter *.md) {
      $c = Get-Content $f.FullName -Raw
      # Waiting is the absence of the line, so only a *claimed* consumption can
      # be malformed: a bare `Consumed:` naming nothing is worse than no line,
      # because it reads as answered.
      $m = [regex]::Match($c, '(?im)^Consumed:\s*([^\r\n]*)')
      if ($m.Success -and $m.Groups[1].Value.Trim().Length -lt 10) {
        throw "$($f.Name) claims consumption and names no destination"
      }
    }
    $true
  }

  Assert "the finding this effort's design encountered is marked, and names where it healed" {
    $p = Join-Path $repo '.claude/evidence/drift/2026-08-03-tracked-intent-rests-on-a-falsified-landing-fact.md'
    if (-not (Test-Path $p)) { throw 'the finding is missing' }
    $c = Get-Content $p -Raw
    $m = [regex]::Match($c, '(?im)^Consumed:\s*([^\r\n]*)')
    if (-not $m.Success) { throw 'the finding is still unmarked' }
    if ($m.Groups[1].Value -notmatch 'tracker\.md') { throw 'the mark does not name where the healing landed' }
    # The account is frozen, so what it recorded must survive the marking.
    if ($c -notmatch '(?is)## What was checked') { throw 'the account was edited rather than annotated' }
    $true
  }
}

# --- ticket mechanics/02 — the git guide carries the fingerprint recipe -------

# Four of this ticket's criteria are about what the recipe *does*, so they are
# run rather than read. The rest of this file asserts prose; a documented
# invocation that does not work is the one defect prose assertions cannot see.
Describe-Ticket 'mechanics/02' 'the git guide carries the tree-fingerprint recipe' {

  $g = Get-SkillFile 'configure/tools/git.md'

  # Hoisted so the behavioural assertions below all exercise the same thing the
  # guide documents. Transcribed from the guide's sh block; if the two drift,
  # the assertions stop testing the entry they belong to.
  $fingerprint = {
    $idx = & git -C $repo rev-parse --path-format=absolute --git-path index
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    Copy-Item $idx $tmp
    try {
      $env:GIT_INDEX_FILE = $tmp
      & git -C $repo add -A 2>&1 | Out-Null
      (& git -C $repo write-tree).Trim()
    } finally {
      $env:GIT_INDEX_FILE = $null
      Remove-Item $tmp -ErrorAction SilentlyContinue
    }
  }

  Assert "the guide has a fingerprint entry, reachable from the Marker" {
    if ($g -notmatch '(?im)^##\s+Fingerprint the working tree') { throw 'no fingerprint entry' }
    if ($g -notmatch '(?is)Marker''s second fact') { throw 'the entry does not tie itself to the Marker' }
    $true
  }

  Assert "the index path is asked for rather than assumed, with the invocation and the reason" {
    if ($g -notmatch '(?i)rev-parse --path-format=absolute --git-path index') { throw 'the invocation is missing' }
    if ($g -notmatch '(?is)worktree.{0,60}is a file') { throw 'the reason the path cannot be hardcoded is unstated' }
    $true
  }

  Assert "both shell forms ship, since the guide reaches repositories driven from either" {
    if ($g -notmatch '(?s)```sh\b') { throw 'no sh form' }
    if ($g -notmatch '(?s)```powershell\b') { throw 'no powershell form' }
    if ($g -notmatch '(?i)GIT_INDEX_FILE') { throw 'neither form sets the index override' }
    if ($g -notmatch '(?i)leaks into the next command') { throw 'the powershell form does not warn that the variable persists' }
    $true
  }

  Assert "the seeding is stated as the thing that makes the check affordable" {
    if ($g -notmatch '(?is)seeded from') { throw 'the seeding is not described' }
    if ($g -notmatch '(?is)stat cache') { throw 'the reason seeding matters is unstated' }
    if ($g -notmatch '(?is)re-hashe?s? every file') { throw 'the cost of not seeding is unstated' }
    $true
  }

  Assert "the coverage is stated: untracked in, ignored out, no clean-tree sentinel" {
    if ($g -notmatch '(?is)tracked and untracked') { throw 'untracked coverage is unstated' }
    if ($g -notmatch '(?is)ignored files? (are )?excluded|excluded because') { throw 'ignored exclusion is unstated' }
    if ($g -notmatch '(?is)no sentinel') { throw 'nothing rules out a clean-tree special case' }
    $true
  }

  # Rejections carry their reason, not their verdict: without it the cheaper
  # invocation gets substituted later by someone who never learned why it lost.
  Assert "both rejected forms are named with the reason each fails" {
    if ($g -notmatch '(?is)stash create[^.]{0,200}untracked') { throw 'the stash form is not rejected on untracked files' }
    if ($g -notmatch '(?is)there is no ``?-u``?') { throw 'the stash rejection cites no evidence' }
    if ($g -notmatch '(?is)files changed and never') { throw 'the status-digest rejection does not say what it misses' }
    $true
  }

  Assert "the recipe is deterministic against an unchanged tree" {
    $a = & $fingerprint
    $b = & $fingerprint
    if ($a -ne $b) { throw "two runs over one tree disagreed: $a vs $b" }
    if ($a -notmatch '^[0-9a-f]{40}$') { throw "not a tree object: $a" }
    $true
  }

  # Sensitivity and untracked coverage in one, and non-destructively: an added
  # untracked file is the case `git stash create` cannot see, so proving the
  # fingerprint moves for it is proving the rejection above was necessary.
  Assert "an untracked file moves the fingerprint, and removing it moves it back" {
    $probe = Join-Path $repo 'mechanics-fingerprint-probe.tmp'
    $before = & $fingerprint
    try {
      Set-Content $probe 'probe' -NoNewline
      $dirty = & $fingerprint
      if ($dirty -eq $before) { throw 'an untracked file left the fingerprint unchanged' }
    } finally {
      Remove-Item $probe -ErrorAction SilentlyContinue
    }
    $after = & $fingerprint
    if ($after -ne $before) { throw "the tree was restored and the fingerprint was not: $before vs $after" }
    $true
  }

  Assert "running it leaves the repository's own index byte-identical" {
    $idx = & git -C $repo rev-parse --path-format=absolute --git-path index
    $before = (Get-FileHash $idx -Algorithm SHA256).Hash
    & $fingerprint | Out-Null
    $after = (Get-FileHash $idx -Algorithm SHA256).Hash
    if ($before -ne $after) { throw 'the recipe wrote the real index' }
    $true
  }
}

# --- ticket mechanics/06 — decisions declare their fields ---------------------

Describe-Ticket 'mechanics/06' 'decisions declare status, supersession, and scope' {

  $d = Get-SkillFile 'configure/policies/decisions.template.md'

  Assert "every declared field is named, with what reads it" {
    foreach ($f in 'status', 'load-when', 'sources', 'supersedes', 'superseded-by') {
      if ($d -notmatch [regex]::Escape($f)) { throw "the $f field is unnamed" }
    }
    if ($d -notmatch '(?is)Read by') { throw 'the fields are listed without their readers' }
    $true
  }

  # The load-condition rule is the context format's single home, so this format
  # reaches it by pointer. Asserting the *statement* here would have required
  # the second home the `$rulePattern` sweep now forbids — found by the review
  # axis, after both policies had independently stated it.
  Assert "the routing mechanism is adopted by pointer, not restated" {
    if ($d -notmatch '(?is)\.claude/policies/context\.md') { throw 'the format does not point at the routing mechanism' }
    if ($d -notmatch '(?is)not repeated here|deliberately not repeated') { throw 'nothing says the rule is not restated here' }
    if ($d -notmatch '(?is)supersession pair below') { throw 'the format does not say what is its own rather than borrowed' }
    $true
  }

  Assert "supersession is written at both ends, in one change, and one-sidedness is a defect" {
    if ($d -notmatch '(?is)both ends') { throw 'supersession is not two-ended' }
    if ($d -notmatch '(?is)same change') { throw 'the timing is unstated' }
    if ($d -notmatch '(?is)absent at the other is a \*\*defect\*\*|is a \*\*defect\*\*') { throw 'a one-sided claim is not called a defect' }
    $true
  }

  # Presence is symmetric with its negation, so the half that actually goes
  # wrong is asserted on its own: writing the new end is the tempting one,
  # because that is the file already open.
  Assert "the tempting half is named, with the reader it strands" {
    if ($d -notmatch '(?is)only the new end is the tempting half|writing only the new end') {
      throw 'nothing identifies which end gets forgotten'
    }
    if ($d -notmatch '(?is)no way to learn it is dead') { throw 'the consequence for the stranded reader is unstated' }
    $true
  }

  Assert "the freeze survives, and says which fields still move" {
    if ($d -notmatch '(?is)reasoning is \*\*frozen\*\*') { throw 'the freeze is gone' }
    if ($d -notmatch '(?is)only ``?status``? and ``?superseded-by``? move') { throw 'the moving fields are not enumerated' }
    if ($d -notmatch '(?is)never the prose') { throw 'the prose is not protected' }
    $true
  }

  Assert "the preserve-the-number rule is unchanged, and stated exactly once" {
    $hits = [regex]::Matches($d, '(?i)preserve each ADR''s existing number')
    if ($hits.Count -ne 1) { throw "the numbering rule appears $($hits.Count) times, not once" }
    if ($d -notmatch '(?is)they resolve by number') { throw 'the reason renumbering breaks references is gone' }
    $true
  }

  Assert "the shipped template shows the fields it describes" {
    $tpl = [regex]::Match($d, '(?s)```md\r?\n(.*?)```')
    if (-not $tpl.Success) { throw 'the template block is missing' }
    foreach ($f in 'status:', 'load-when:', 'sources:', 'supersedes:', 'superseded-by:') {
      if ($tpl.Groups[1].Value -notmatch [regex]::Escape($f)) { throw "the template block omits $f" }
    }
    $true
  }
}

# --- ticket mechanics/07 — contexts declare their sources and load condition --

# Two criteria here are about build failures over data this repository does not
# carry yet — its contexts gain fields in `mechanics/12`. A guard written
# against that data would pass vacuously until then, which is the shape this
# repository has shipped four broken guards in. So the checks are written as
# validators and proved against synthetic input: they fail on a bad context now,
# with nothing on disk to depend on.
Describe-Ticket 'mechanics/07' 'contexts declare their sources and their load condition' {

  $c = Get-SkillFile 'configure/policies/context.template.md'

  $parseFields = {
    param([string]$Text)
    $fm = Get-Frontmatter $Text
    if ($null -eq $fm) { return $null }
    $lw = [regex]::Match($fm, '(?m)^load-when:\s*(.+?)\s*$')
    $sr = [regex]::Match($fm, '(?m)^sources:\s*\[(.*?)\]\s*$')
    if (-not $lw.Success -or -not $sr.Success) { return $null }
    @{
      LoadWhen = $lw.Groups[1].Value
      Sources  = @($sr.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }
  }

  Assert "the policy names the fields and says the table is generated from them" {
    if ($c -notmatch '(?is)generated from the fields each context declares') { throw 'the table is not declared generated' }
    if ($c -notmatch '(?i)load-when') { throw 'the load-when field is unnamed' }
    if ($c -notmatch '(?i)sources') { throw 'the sources field is unnamed' }
    if ($c -notmatch '(?is)never hand-edited') { throw 'hand-editing is not prohibited' }
    $true
  }

  Assert "generation is justified by the drift it makes impossible" {
    if ($c -notmatch '(?is)cannot disagree with its directory') { throw 'the impossibility is unstated' }
    if ($c -notmatch '(?is)not a second statement') { throw 'the reason is unstated, so the claim is an assertion' }
    if ($c -notmatch '(?is)replaces the audit') { throw 'nothing says the audit obligation is retired rather than supplemented' }
    $true
  }

  # The field moved; the meaning did not. Without this the next reader treats a
  # declared source as an inventory of what is there.
  Assert "a declared source is still a coordinate, and verify-before-use stays where it was" {
    if ($c -notmatch '(?is)navigation coordinate, never a claim') { throw 'the coordinate rule is gone' }
    if ($c -notmatch '(?is)moved where the pointer is written and nothing about what it means') {
      throw 'nothing says the field changed the location and not the meaning'
    }
    # Stated by pointer, not restated: the rule's home is the always-on tier.
    if ($c -match '(?is)verify (it|the pointer|every pointer) before (you )?(use|rely)') {
      throw 'the verify-before-use rule has acquired a second home here'
    }
    $true
  }

  # `-cmatch`, not `-match`. PowerShell's `-match` is case-insensitive, so the
  # capitalised prose form this checks for was matching the lowercase `sources:`
  # field that replaced it — the guard fired on exactly the thing it exists to
  # certify, and read as the format being unconverted.
  Assert "the domain example shows fields, and no prose source line survives" {
    if ($c -cmatch '(?m)^Sources:\s') { throw 'a prose Sources line survives in the format' }
    $ex = [regex]::Match($c, '(?s)# Database.*?```')
    if (-not $ex.Success) { throw 'the domain example is missing' }
    $true
  }

  Assert "every file under contexts still has exactly one row, repository.md included" {
    if ($c -notmatch '(?is)exactly one row, including ``?repository\.md``?') {
      throw 'the one-row-per-file rule no longer names the file that is always forgotten'
    }
    $true
  }

  # Proved against synthetic input rather than against the tree, so it is a
  # working check today and not one that starts working after mechanics/12.
  Assert "a context declaring no fields is rejected, and one declaring them is accepted" {
    $good = "---`nload-when: the request touches sessions or tokens`nsources: [src/auth/]`n---`n`n# Auth`n"
    $bad  = "# Auth`n`nSources: ``src/auth/```n"
    if ($null -eq (& $parseFields $good)) { throw 'a well-formed context was rejected' }
    if ($null -ne (& $parseFields $bad))  { throw 'a context with a prose source line was accepted' }
    $true
  }

  Assert "an unresolvable declared source is caught, and a resolvable one is not" {
    $resolves = { param($f) @($f.Sources | Where-Object { -not (Test-Path (Join-Path $repo $_)) }) }
    $ok  = & $parseFields "---`nload-when: x`nsources: [skills/, agents/]`n---`n# A`n"
    $bad = & $parseFields "---`nload-when: x`nsources: [src/nowhere/]`n---`n# A`n"
    if ((& $resolves $ok).Count -ne 0)  { throw 'a resolvable source was reported broken' }
    if ((& $resolves $bad).Count -eq 0) { throw 'a source pointing at nothing was accepted' }
    $true
  }
}

# --- ticket mechanics/03 — the protocol's marker check compares both halves ---

Describe-Ticket 'mechanics/03' 'the protocol template compares both marker facts' {

  $p = Get-SkillFile 'configure/protocol.template.md'
  # Get-Section supplies its own `^##` anchor, so the pattern is the fragment
  # that follows it — passing a full heading regex matches nothing and throws.
  $marker = Get-Section $p 'Trusting Context'

  Assert "the marker section resolves, and to itself" {
    if (-not $marker) { throw 'the marker section is gone' }
    if ($marker -notmatch '(?is)two facts') { throw 'the marker still holds one fact' }
    $true
  }

  Assert "the check compares both facts and states that no third condition exists" {
    if ($marker -notmatch '(?is)commit == HEAD\s+AND\s+marker\.json tree ==') { throw 'the rule block compares one fact' }
    if ($marker -notmatch '(?is)no third condition') { throw 'nothing rules out a further condition' }
    $true
  }

  # The whole file, not the section: a clean-tree condition reintroduced in the
  # report example is the same defect one line lower down, and that example was
  # where it actually survived the first edit.
  Assert "no clean-tree condition survives anywhere in the router" {
    foreach ($sent in [regex]::Split($p, '(?<=\.)\s+')) {
      if ($sent -match '(?i)(tree (is )?clean|clean tree|working tree carries no|no (uncommitted|local) changes)' -and
          $sent -match '(?i)(trusted|no reading|skip|match)' -and
          $sent -notmatch '(?i)(absent|unknown|falls back|same kind of value|no third condition)') {
        throw "a clean-tree condition survives: $sent"
      }
    }
    $true
  }

  Assert "the licence is bounded, and the stronger reading is refused by name" {
    if ($marker -notmatch '(?is)drift reads may be skipped|two drift reads may be skipped') { throw 'the licence is unstated' }
    if ($marker -notmatch '(?is)does\s+\*{0,2}not\*{0,2}\s+say any knowledge is correct') { throw 'the stronger reading is not refused' }
    if ($marker -notmatch '(?is)verification at use is unaffected') { throw 'verification at use is not held harmless' }
    $true
  }

  Assert "the re-stamp permission is stated with its condition and its refusal" {
    if ($marker -notmatch '(?is)re-stamp the tree fact alone') { throw 'no re-stamp permission' }
    if ($marker -notmatch '(?is)conditional on the dealing and never on the reading') { throw 'the condition is not the dealing' }
    if ($marker -notmatch '(?is)neither healed nor discounted[^.]{0,80}re-stamps nothing') { throw 'the refusal is unstated' }
    $true
  }

  Assert "an absent tree fact falls back rather than failing" {
    if ($marker -notmatch '(?is)no tree fact means the tree is unknown') { throw 'the absent case is undefined' }
    if ($marker -notmatch '(?is)read the tree live') { throw 'the fallback behaviour is unstated' }
    $true
  }

  # The recipe has one home, in the tool guide. A router that inlined it would
  # be the second home, and the one nobody updates when the invocation changes.
  Assert "the fingerprint invocation is reached by pointer and restated nowhere" {
    if ($marker -notmatch '(?is)\.claude/tools/git\.md') { throw 'the router does not point at the guide' }
    if ($p -match '(?i)git write-tree|GIT_INDEX_FILE') { throw 'the router inlines the fingerprint invocation' }
    $true
  }
}

# --- ticket mechanics/08 — the index is generated, and review routes through it -

# What remains here is the supersession graph, which is a property of the
# decisions *format* rather than of indexing, and is still proved against a
# fixture because a symmetric tree cannot demonstrate the asymmetry it catches.
#
# The renderer this block used to carry is gone: `declared-fields/05` moved
# index generation into `.claude/scripts/regenerate-indexes.ps1`, and ADR 0057 says a
# single deterministic script produces every index. A second renderer here,
# with its own copy of the header row, the ordering and the em-dash rule, was
# the shape that decision rejected — and its assertions were checking a
# renderer nothing ships.
Describe-Ticket 'mechanics/08' 'the decisions index is generated, and review routes through it' {

  $readFields = {
    param([string]$Text)
    $b = Get-Frontmatter $Text
    if ($null -eq $b) { return $null }
    $get = { param($n) $m = [regex]::Match($b, "(?m)^$n`:\s*(.*?)\s*$"); if ($m.Success) { $m.Groups[1].Value } else { $null } }
    $lw = & $get 'load-when'
    $st = & $get 'status'
    if (-not $lw -or -not $st) { return $null }
    $list = { param($n) $v = & $get $n; if ($null -eq $v) { @() } else { @($v.Trim('[', ']') -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) } }
    @{
      LoadWhen     = $lw
      Status       = $st
      Sources      = & $list 'sources'
      Supersedes   = & $list 'supersedes'
      SupersededBy = & $list 'superseded-by'
    }
  }

  # A fixture directory, built and torn down per run. Two ADRs, one superseding
  # the other, both ends declared — the shape the checks below are about.
  $mkFixture = {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $dir | Out-Null
    Set-Content (Join-Path $dir '0001-old.md') @"
---
status: superseded
load-when: the old approach is in question
sources: [skills/]
supersedes: []
superseded-by: [0002]
---

# Old
"@
    Set-Content (Join-Path $dir '0002-new.md') @"
---
status: accepted
load-when: the new approach is in question
sources: [agents/]
supersedes: [0001]
superseded-by: []
---

# New
"@
    $dir
  }

  $load = {
    param([string]$Dir)
    $docs = @{}
    foreach ($f in Get-ChildItem $Dir -File -Filter '*.md' | Where-Object { $_.Name -ne 'map.md' }) {
      $n = [regex]::Match($f.Name, '^(\d{4})-').Groups[1].Value
      if (-not $n) { throw "$($f.Name) is not numbered" }
      $d = & $readFields (Get-Content $f.FullName -Raw)
      if ($null -eq $d) { throw "$($f.Name) declares no fields" }
      $d.File = $f.Name
      $docs[$n] = $d
    }
    $docs
  }

  # Symmetry, both directions. Checking only one leaves the other half of the
  # graph unguarded, and the half that gets forgotten is the older file's.
  Assert "a one-sided supersession is caught, and names both files" {
    $check = {
      param($Docs)
      $bad = @()
      foreach ($k in $Docs.Keys) {
        foreach ($t in $Docs[$k].Supersedes) {
          if (-not $Docs.ContainsKey($t)) { $bad += "$k names $t, which is not here"; continue }
          if ($Docs[$t].SupersededBy -notcontains $k) { $bad += "$k supersedes $t and $t does not say so" }
        }
        foreach ($t in $Docs[$k].SupersededBy) {
          if (-not $Docs.ContainsKey($t)) { $bad += "$k names $t, which is not here"; continue }
          if ($Docs[$t].Supersedes -notcontains $k) { $bad += "$k is superseded by $t and $t does not say so" }
        }
      }
      $bad
    }
    $dir = & $mkFixture
    try {
      if ((& $check (& $load $dir)).Count -ne 0) { throw 'a symmetric graph was reported broken' }
      # Strip the old file's end only — the direction an author actually forgets.
      $old = Join-Path $dir '0001-old.md'
      Set-Content $old ((Get-Content $old -Raw) -replace 'superseded-by: \[0002\]', 'superseded-by: []')
      $bad = & $check (& $load $dir)
      if ($bad.Count -eq 0) { throw 'a one-sided supersession was accepted' }
      if (($bad -join ' ') -notmatch '0002' -or ($bad -join ' ') -notmatch '0001') {
        throw "the failure does not name both files: $($bad -join '; ')"
      }
    } finally { Remove-Item $dir -Recurse -Force }
    $true
  }

  # The shipped router only. The installed one keeps routing at the directory
  # until `mechanics/12` generates this repository's index — adopting the row
  # first would point the router at a file that does not exist, which is a
  # broken Source Pointer shipped to gain nothing. ADR 0025's ship-then-adopt
  # order is not a formality here; it is what keeps the pointer resolvable.
  # `mechanics/13` adopts it.
  Assert "the shipped review row routes through the index rather than the directory" {
    $f = Get-SkillFile 'configure/protocol.template.md'
    $row = [regex]::Match($f, '(?m)^\|\s*`/review`\s*\|([^\r\n]*)')
    if (-not $row.Success) { throw 'the review row is missing' }
    $v = $row.Groups[1].Value
    if ($v -notmatch 'decisions/map\.md') { throw 'the review row does not name the index' }
    if ($v -match '`\.claude/decisions/`') { throw 'the review row still names the whole directory' }
    $true
  }

  Assert "the decisions format shows the index it generates, with the status column" {
    $d = Get-SkillFile 'configure/policies/decisions.template.md'
    if ($d -notmatch '(?is)decisions/map\.md') { throw 'the index file is unnamed' }
    if ($d -notmatch '(?is)\|\s*ADR\s*\|\s*Load when\s*\|\s*Status\s*\|\s*Sources\s*\|') { throw 'the index shape is not shown' }
    if ($d -notmatch '(?is)opens only the ADRs it names') { throw 'nothing says a stage stops reading the directory whole' }
    $true
  }
}

# --- ticket mechanics/04 — /commit writes both, and the re-stamp has one home -

Describe-Ticket 'mechanics/04' 'the commit stage writes both facts, and a stage may re-stamp the tree' {

  $c = Get-SkillFile 'commit/SKILL.md'
  $p = Get-SkillFile 'configure/protocol.template.md'

  Assert "committing writes both facts, in one write" {
    if ($c -notmatch '(?is)Write \*\*both facts\*\*') { throw 'the commit stage still writes one fact' }
    if ($c -notmatch '(?is)"tree"') { throw 'the example marker carries no tree fact' }
    if ($c -notmatch '(?is)written \*\*together\*\*') { throw 'nothing says the pair is written together' }
    $true
  }

  # The failure a half-write produces is silent and downstream, so the reason is
  # carried rather than the instruction alone.
  Assert "a half-fresh pair is refused, with what it would cost" {
    if ($c -notmatch '(?is)stale tree beside it') { throw 'the half-write case is unnamed' }
    if ($c -notmatch '(?is)skip a drift read on the strength of it') { throw 'the consequence of a half-write is unstated' }
    $true
  }

  Assert "the report says which happened to the drift, not merely that it was read" {
    if ($p -notmatch '(?is)report says which happened to it') { throw 'the report obligation does not reach the disposal' }
    if ($p -notmatch '(?is)healed, or discounted') { throw 'the two dispositions are unnamed' }
    if ($p -notmatch '(?is)has not earned the re-stamp') { throw 'nothing ties the report to the permission' }
    $true
  }

  # The behavioural pair the ticket is actually about, asserted over the rule
  # rather than over a run: a matching tree skips the read, a changed one does
  # not. Both directions, because a rule that only ever skips is not a cache.
  Assert "an unchanged tree is read once and a changed one is read again" {
    $marker = Get-Section $p 'Trusting Context'
    if ($marker -notmatch '(?is)drift reads may be skipped') { throw 'a match does not skip the read' }
    if ($marker -notmatch '(?is)otherwise\s*\r?\n\s*→ read the drift') { throw 'a mismatch does not read the drift' }
    if ($marker -notmatch '(?is)dirty tree that has not changed since its drift was read matches') {
      throw 'the case the second fact exists for is unstated'
    }
    $true
  }

  # Single home is enforced by the repository's own sweep, which now carries an
  # entry for this permission; asserting it a second time here would be the
  # duplication that sweep exists to catch. What is left for this ticket is that
  # the permission is stated in the router at all — the sweep reports "stated
  # nowhere" and "restated in" alike, and only one of those is this ticket's.
  Assert "the permission is stated, and in the file that owns the Marker" {
    $homes = Get-SkillFiles |
      Where-Object { (Get-SkillText $_) -match '(?i)re-stamp the tree fact alone' } |
      ForEach-Object { $_.FullName.Substring($skills.Length + 1) -replace '\\', '/' }
    if ($homes -notcontains 'configure/protocol.template.md') {
      throw "the router does not state it; found in: $($homes -join ', ')"
    }
    $true
  }
}

# --- ticket mechanics/12 — this repository's knowledge declares its fields ----

# Unlike mechanics/07 and /08, these run against the real directories. That is
# the point of this ticket: the machinery those two proved on fixtures now has
# data, and a regression here is a knowledge file that stopped declaring fields
# rather than a checker that stopped working.
Describe-Ticket 'mechanics/12' 'this repository''s decisions and contexts declare their fields' {

  $readFields = {
    param([string]$Text)
    $b = Get-Frontmatter $Text
    if ($null -eq $b) { return $null }
    $get = { param($n) $m = [regex]::Match($b, "(?m)^$n`:\s*(.*?)\s*$"); if ($m.Success) { $m.Groups[1].Value } else { $null } }
    $lw = & $get 'load-when'
    if (-not $lw) { return $null }
    $list = { param($n) $v = & $get $n; if ($null -eq $v) { @() } else { @($v.Trim('[', ']') -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) } }
    @{ LoadWhen = $lw; Status = (& $get 'status'); Sources = (& $list 'sources')
       Supersedes = (& $list 'supersedes'); SupersededBy = (& $list 'superseded-by') }
  }
  $fmtSrc = { param($s) if ($s.Count) { ($s | ForEach-Object { "``$_``" }) -join ', ' } else { '—' } }

  $dDir = Join-Path $repo '.claude/decisions'
  $cDir = Join-Path $repo '.claude/contexts'
  $adrFiles = @(Get-ChildItem $dDir -File -Filter '*.md' | Where-Object { $_.Name -ne 'map.md' } | Sort-Object Name)
  $ctxFiles = @(Get-ChildItem $cDir -File -Filter '*.md' | Where-Object { $_.Name -ne 'map.md' })

  $adrs = @{}
  foreach ($f in $adrFiles) { $adrs[$f.Name.Substring(0, 4)] = (& $readFields (Get-Content $f.FullName -Raw)) }

  Assert "every Decision declares its fields, with its number and slug unchanged" {
    foreach ($f in $adrFiles) {
      if ($f.Name -notmatch '^\d{4}-[a-z0-9-]+\.md$') { throw "$($f.Name) was renamed out of the numbering convention" }
      if ($null -eq $adrs[$f.Name.Substring(0, 4)]) { throw "$($f.Name) declares no fields" }
    }
    if ($adrFiles.Count -lt 50) { throw "only $($adrFiles.Count) decisions found — the directory looks truncated" }
    $true
  }

  Assert "every Context declares its fields, and no prose source line survives" {
    foreach ($f in $ctxFiles) {
      $t = Get-Content $f.FullName -Raw
      if ($null -eq (& $readFields $t)) { throw "$($f.Name) declares no fields" }
      if ($t -cmatch '(?m)^Sources:\s') { throw "$($f.Name) still carries a prose Sources line" }
      if ($t -match '(?m)^Load when\b') { throw "$($f.Name) still carries a prose load condition" }
    }
    $true
  }

  Assert "every declared source resolves" {
    foreach ($set in @(@{ D = $dDir; F = $adrFiles }, @{ D = $cDir; F = $ctxFiles })) {
      foreach ($f in $set.F) {
        $d = & $readFields (Get-Content $f.FullName -Raw)
        foreach ($s in $d.Sources) {
          if (-not (Test-Path (Join-Path $repo $s))) { throw "$($f.Name) declares $s, which does not resolve" }
        }
      }
    }
    $true
  }

  # Regeneration, against the real directories. The renderers below are the ones
  # that wrote the files; if they drift apart, this fails rather than the map
  # going quietly stale.
  Assert "both indexes regenerate byte-identically" {
    $rows = foreach ($f in $adrFiles) {
      $d = $adrs[$f.Name.Substring(0, 4)]
      "| [$($f.Name.Substring(0,4))]($($f.Name)) | $($d.LoadWhen) | $($d.Status) | $(& $fmtSrc $d.Sources) |"
    }
    $want = ((@('# Decision map', '', '| ADR | Load when | Status | Sources |', '| --- | --- | --- | --- |') + $rows) -join "`n") + "`n"
    $have = (Get-Content (Join-Path $dDir 'map.md') -Raw) -replace "`r`n", "`n"
    if ($want -ne $have) { throw 'the decision index differs from a regeneration' }

    $ordered = @($ctxFiles | Where-Object { $_.Name -eq 'repository.md' }) +
               @($ctxFiles | Where-Object { $_.Name -ne 'repository.md' } | Sort-Object Name)
    $crows = foreach ($f in $ordered) {
      $d = & $readFields (Get-Content $f.FullName -Raw)
      "| [$([System.IO.Path]::GetFileNameWithoutExtension($f.Name))]($($f.Name)) | $($d.LoadWhen) | $(& $fmtSrc $d.Sources) |"
    }
    $cwant = ((@('# Context map', '', '| Context | Load when | Sources |', '| --- | --- | --- |') + $crows) -join "`n") + "`n"
    $chave = (Get-Content (Join-Path $cDir 'map.md') -Raw) -replace "`r`n", "`n"
    if ($cwant -ne $chave) { throw 'the context index differs from a regeneration' }
    $true
  }

  Assert "the supersession graph is symmetric in both directions" {
    $bad = @()
    foreach ($k in $adrs.Keys) {
      foreach ($t in $adrs[$k].Supersedes) {
        if (-not $adrs.ContainsKey($t)) { $bad += "$k names $t, which is not here"; continue }
        if ($adrs[$t].SupersededBy -notcontains $k) { $bad += "$k supersedes $t and $t does not say so" }
      }
      foreach ($t in $adrs[$k].SupersededBy) {
        if (-not $adrs.ContainsKey($t)) { $bad += "$k names $t, which is not here"; continue }
        if ($adrs[$t].Supersedes -notcontains $k) { $bad += "$k is superseded by $t and $t does not say so" }
      }
    }
    if ($bad.Count) { throw ($bad -join '; ') }
    $true
  }

  # The two claims that existed as `status:` lines before this migration. Named
  # explicitly so that dropping either shows up as this assertion rather than as
  # a symmetric-but-empty graph, which the check above would pass.
  Assert "the two pre-existing supersession claims are recorded at both ends" {
    foreach ($pair in @(@('0003', '0006'), @('0005', '0010'))) {
      $old, $new = $pair
      if ($adrs[$old].SupersededBy -notcontains $new) { throw "$old does not record $new" }
      if ($adrs[$new].Supersedes -notcontains $old) { throw "$new does not record $old" }
      if ($adrs[$old].Status -ne 'superseded') { throw "$old is not marked superseded" }
    }
    $true
  }

  # A load condition that describes a topic passes every check above. Nothing
  # mechanical separates a trigger from a subject, so this catches only the
  # coarsest tell — a condition that is a bare noun phrase with no verb at all.
  # The real check was reading all fifty-four; this stops the obvious relapse.
  Assert "no load condition is a bare topic" {
    foreach ($k in $adrs.Keys) {
      $w = $adrs[$k].LoadWhen
      if ($w -notmatch '\b(is|are|was|were|has|have|needs?|meets?|reaches?|touches?|conflicts?|disagrees?|differs?|moves?|stops?|fails?|omits?|ends?|declares?|writes?|reads?|wrote|found|being|about to|would|cannot|includes?)\b') {
        throw "$k reads as a topic rather than a trigger: '$w'"
      }
    }
    $true
  }

  Assert "the installed review row routes through the index that now exists" {
    $c = Get-Content (Join-Path $repo '.claude/protocol.md') -Raw
    $row = [regex]::Match($c, '(?m)^\|\s*`/review`\s*\|([^\r\n]*)')
    if (-not $row.Success) { throw 'the review row is missing' }
    if ($row.Groups[1].Value -notmatch 'decisions/map\.md') { throw 'the installed row does not name the index' }
    if (-not (Test-Path (Join-Path $dDir 'map.md'))) { throw 'the row names an index that does not exist' }
    $true
  }
}

# --- ticket mechanics/13 — adopt the remaining changed templates here ---------

# The installed-matches-template checks for this effort live here and nowhere
# else, the way `scaffolding/05` owns the ones for its own effort. A second copy
# in the ticket that *shipped* a template would fail for the whole window ADR
# 0025 deliberately opens between shipping and adopting.
Describe-Ticket 'mechanics/13' 'the changed templates are adopted here' {

  $stripComments = { param($t) ($t -replace '(?s)<!--.*?-->', '').Trim() -replace "`r`n", "`n" }

  foreach ($p in @('context', 'decisions')) {
    Assert "the installed $p policy matches the template it was copied from" {
      $t = & $stripComments (Get-SkillFile "configure/policies/$p.template.md")
      $i = & $stripComments (Get-Content (Join-Path $repo ".claude/policies/$p.md") -Raw)
      if ($t -ne $i) { throw 'the installed copy has diverged from its template' }
      $true
    }
  }

  Assert "the installed router matches the template it was copied from" {
    $t = & $stripComments (Get-SkillFile 'configure/protocol.template.md')
    $i = & $stripComments (Get-Content (Join-Path $repo '.claude/protocol.md') -Raw)
    if ($t -ne $i) { throw 'the installed router has diverged from its template' }
    $true
  }

  # The tool reference is *derived* rather than copied (ADR 0019), so this is
  # not a text comparison: what must carry over is the entry and the two things
  # about it that are not obvious from the commands.
  Assert "the derived git guide carries the fingerprint entry, intact" {
    $g = Get-Content (Join-Path $repo '.claude/tools/git.md') -Raw
    if ($g -notmatch '(?im)^##\s+Fingerprint the working tree') { throw 'the entry did not carry over' }
    if ($g -notmatch '(?i)stat cache') { throw 'the seeding rationale did not carry over' }
    if ($g -notmatch '(?is)there is no ``?-u``?') { throw 'the stash rejection did not carry over' }
    $true
  }

  Assert "every spine stage still has exactly one row, and the table lost nothing local" {
    $proto = Get-Content (Join-Path $repo '.claude/protocol.md') -Raw
    foreach ($s in @('configure', 'design', 'implement', 'review', 'research', 'prototype', 'commit')) {
      $rows = [regex]::Matches($proto, "(?m)^\|\s*``/$s``\s*\|")
      if ($rows.Count -ne 1) { throw "/$s has $($rows.Count) rows, not one" }
    }
    if ($proto -notmatch 'decisions/map\.md') { throw 'the review row lost its index routing in adoption' }
    $true
  }

  # Position is per-clone, so nothing committed may depend on it. The marker is
  # the one file this effort taught to hold more, which makes it the one worth
  # re-checking against that invariant.
  Assert "nothing committed depends on this clone's position state" {
    & git -C $repo check-ignore -q '.claude/position/marker.json'
    if ($LASTEXITCODE -ne 0) { throw 'the marker is not ignored — a clone would commit its own position' }
    $tracked = & git -C $repo ls-files '.claude/position/'
    if ($tracked) { throw "position state is tracked: $tracked" }
    $true
  }
}

# --- ticket mechanics/14 — the migration converts knowledge to declared fields -

Describe-Ticket 'mechanics/14' 'the migration converts a repository''s knowledge to declared fields' {

  # Spans both surfaces since changelog/01 moved the dated half out. The criterion
  # is that the conversion is described, which it still is — under its own heading.
  $m = Get-MigrationText

  Assert "the row exists, and recognition names both halves" {
    if ($m -notmatch '(?im)^##\s+Knowledge that predates declared fields') { throw 'no row for the old shape' }
    if ($m -notmatch '(?is)both halves') { throw 'recognition is not two-sided' }
    if ($m -notmatch '(?is)decisions/``? is populated|decisions/`` is populated|is populated') {
      throw 'the first half of recognition is unstated'
    }
    if ($m -notmatch '(?is)declare no frontmatter fields') { throw 'the second half of recognition is unstated' }
    $true
  }

  Assert "the existing table is the conversion's input rather than something discarded" {
    if ($m -notmatch '(?is)input, not its casualty') { throw 'the table is not named as the input' }
    if ($m -notmatch '(?is)carry each onto the file it describes') { throw 'nothing says the sentences move onto the files' }
    $true
  }

  # The failure this row can produce is invisible to every check the shape adds,
  # so the warning is the deliverable — not a nicety attached to it.
  Assert "the judgement is named, shown file by file, and its silent failure described" {
    if ($m -notmatch '(?is)judgement, and it is the one output nothing can check') { throw 'the judgement is not named' }
    if ($m -notmatch '(?is)file by file') { throw 'the row is not shown per file' }
    if ($m -notmatch '(?is)never as a count') { throw 'nothing rules out reporting it as a count' }
    if ($m -notmatch '(?is)passes every assertion') { throw 'the invisibility of the failure is unstated' }
    $true
  }

  Assert "prose supersession is reported rather than promoted, with the reason" {
    if ($m -notmatch '(?is)reported, never promoted') { throw 'prose supersession is not held back' }
    if ($m -notmatch '(?is)guess about what its author meant') { throw 'the reason is unstated' }
    # `\s+` rather than a literal space: these files are hard-wrapped, so any
    # multi-word pattern that assumes single spaces fails on the wrap point
    # rather than on the claim.
    if ($m -notmatch '(?is)partial supersession is not a\s+supersession') { throw 'the partial case is not distinguished' }
    $true
  }

  Assert "numbers and slugs are preserved by citation rather than by restatement" {
    if ($m -notmatch '(?is)Filenames and numbers do not move') { throw 'the preservation is unstated' }
    if ($m -notmatch '(?is)numbering section') { throw 'the rule is restated rather than cited' }
    $true
  }

  Assert "a repository already on declared fields is recognised as current" {
    if ($m -notmatch '(?is)already declaring fields is \*\*current\*\*') { throw 'the no-op case is unstated' }
    $true
  }
}

# --- ticket mechanics/15 — configure carries the rest, and names what needs nothing -

Describe-Ticket 'mechanics/15' 'configure carries the remaining mechanics, and names what needs nothing' {

  # Both moved: the three mechanics to the changelog under their own heading, and
  # the stage-table repair out of the audit list into the same place.
  $m = Get-MigrationText
  $s = Get-AuditReach

  # The whole point of this ticket: three cases that look alike and are not.
  # A page that described them in one register would invite a run to repair the
  # one that must only be reported.
  Assert "the three are labelled apart, not described alike" {
    if ($m -notmatch '(?is)\*\*not the same kind of work\*\*') { throw 'nothing warns they differ in kind' }
    if ($m -notmatch '(?is)is repaired') { throw 'the repaired case is unlabelled' }
    if ($m -notmatch '(?is)reported, never repaired') { throw 'the reported case is unlabelled' }
    if ($m -notmatch '(?is)needs no conversion') { throw 'the nothing-to-do case is unlabelled' }
    $true
  }

  Assert "the audit repairs the stage table, deriving it and preserving what is local" {
    if ($s -notmatch '(?is)stage table that predates the precedence rule') { throw 'the audit has no row for it' }
    if ($s -notmatch '(?is)preserve the repository-specific rows') { throw 'local rows are not protected' }
    $true
  }

  # Presence is symmetric with its negation: "add the missing guide" and
  # "surface the missing guide" both read as present. The refusal is asserted.
  Assert "a missing guide is surfaced and never added silently, with the reason" {
    if ($s -notmatch '(?is)surfaced in the plan, never added silently') { throw 'the refusal is unstated' }
    if ($s -notmatch '(?is)may have been deliberate') { throw 'the reason a silent add is wrong is unstated' }
    $true
  }

  Assert "unmarked drift findings stay unmarked, and the reason is what marking would require knowing" {
    if ($m -notmatch '(?is)Leave every unmarked\s*\r?\n?finding unmarked|leave every unmarked finding unmarked') {
      throw 'nothing says the findings are left alone'
    }
    if ($m -notmatch '(?is)question about knowledge elsewhere') { throw 'the reason is not what marking would require knowing' }
    if ($m -notmatch '(?is)safe direction') { throw 'the default is not justified as the safe one' }
    $true
  }

  Assert "the Marker needs nothing, says why, and configure declines to stamp it" {
    if ($m -notmatch '(?is)tree is unknown') { throw 'the fallback state is unnamed' }
    if ($m -notmatch '(?is)does \*\*not\*\* write a tree fact') { throw 'configure does not decline to stamp' }
    if ($m -notmatch '(?is)this stage did neither') { throw 'the reason it declines is unstated' }
    $true
  }

  Assert "the shipped roles are excluded by citation rather than by a fresh argument" {
    if ($m -notmatch '(?is)arrive with the plugin') { throw 'the roles case is unstated' }
    if ($m -notmatch '(?is)already recorded twice above') { throw 'the exclusion re-argues rather than cites' }
    $true
  }
}

# --- ticket mechanics/16 — a spent worktree is removed ------------------------

Describe-Ticket 'mechanics/16' 'a spent worktree is removed, and the orchestrator decides when' {

  $s = Get-SkillFile 'implement/SKILL.md'
  $g = Get-SkillFile 'configure/tools/git.md'

  # Spent is defined by an event — the work landing — not by elapsed time or by
  # the child exiting. A child exits on failure too, and that worktree is the
  # one case that must survive.
  Assert "spent is defined by the work landing, not by the child exiting" {
    if ($s -notmatch '(?is)spent when the work it held has landed') { throw 'no definition of spent' }
    if ($s -notmatch '(?is)recoverable from the branch') { throw 'nothing says why a spent worktree is safe to remove' }
    if ($s -match '(?is)spent (when|once)[^.]{0,60}(child (has )?exit|time|age|old)') {
      throw 'spent is defined by the child exiting or by age, which would reach the kept case'
    }
    $true
  }

  Assert "the determination is the orchestrator's, with why neither other party can make it" {
    if ($s -notmatch '(?is)determination is this stage''s and nobody else''s') { throw 'the owner is unnamed' }
    if ($s -notmatch '(?is)harness created the worktree and cannot tell') { throw 'the harness is not ruled out' }
    if ($s -notmatch '(?is)gone by the time the question becomes answerable') { throw 'the child is not ruled out' }
    $true
  }

  # The two rules must meet without overlapping: retention exists for the
  # resumable case, and a removal rule that reached it would delete the work
  # resumption depends on.
  Assert "retention survives, and the two rules are stated as not reaching each other" {
    if ($s -notmatch '(?is)its worktree is kept') { throw 'the set-axis retention rule is gone' }
    if ($s -notmatch '(?is)the worktree stays') { throw 'the exhausted-cap retention rule is gone' }
    if ($s -notmatch '(?is)neither reaches the other''s case') { throw 'the boundary between them is unstated' }
    $true
  }

  # Presence is symmetric with its negation — "force it when it refuses" reads
  # as present too — so the refusal is asserted as a reason rather than a note.
  Assert "removal is never forced, and the refusal is given as a second opinion" {
    if ($s -notmatch '(?is)Never force it') { throw 'forcing is not ruled out' }
    if ($s -notmatch '(?is)second opinion on this stage''s judgement') { throw 'the refusal is framed as an obstacle rather than a check' }
    if ($s -notmatch '(?is)destroys the evidence') { throw 'the cost of forcing is unstated' }
    $true
  }

  Assert "the rule is stated as holding for both axes" {
    if ($s -notmatch '(?is)holds for both axes') { throw 'the rule does not say it crosses the two axes' }
    $true
  }

  Assert "the git guide carries the invocations, and what prune does not do" {
    if ($g -notmatch '(?im)^##\s+Remove a spent worktree') { throw 'no worktree entry in the guide' }
    if ($g -notmatch '(?i)git worktree remove') { throw 'the removal invocation is missing' }
    if ($g -notmatch '(?i)git worktree list --porcelain') { throw 'the listing invocation is missing' }
    if ($g -notmatch '(?is)deletes no working directory') { throw 'prune is not distinguished from remove' }
    if ($g -notmatch '(?is)``?--force``? exists and is not used here') { throw 'the guide does not rule out forcing' }
    $true
  }

  # The guide states invocations; a reader who trusts one that does not run is
  # worse off than one who had none. Run against this repository.
  Assert "the documented invocations run as written" {
    $listed = & git -C $repo worktree list --porcelain
    if ($LASTEXITCODE -ne 0) { throw 'git worktree list --porcelain failed' }
    if (($listed -join "`n") -notmatch '(?m)^worktree ') { throw 'the porcelain listing has no worktree line' }
    & git -C $repo worktree prune -n | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'git worktree prune failed' }
    $true
  }

  Assert "the derived guide carries the entry too" {
    $i = Get-Content (Join-Path $repo '.claude/tools/git.md') -Raw
    if ($i -notmatch '(?im)^##\s+Remove a spent worktree') { throw 'the entry did not carry over' }
    if ($i -notmatch '(?is)deletes no working directory') { throw 'the prune distinction did not carry over' }
    $true
  }
}

# --- ticket declared-fields/01 — the posture is a field, under the sanctioned map -

# The nineteen names Claude Code accepts in SKILL.md frontmatter, read from the
# skills reference on 2026-08-05 and recorded in
# `.claude/evidence/research/2026-08-05-frontmatter-extension-points-for-skills-and-agents.md`.
# The harness's own instruction is "don't reuse frontmatter field names such as
# `paths` as keys" — and `paths` is live here, on `.claude/rules/`, so the
# collision this guards is the documented one rather than a hypothetical.
$reservedFrontmatterKeys = @(
  'name', 'description', 'when_to_use', 'argument-hint', 'arguments',
  'disable-model-invocation', 'user-invocable', 'allowed-tools', 'disallowed-tools',
  'model', 'effort', 'context', 'agent', 'background', 'hooks', 'paths', 'shell',
  'metadata', 'license', 'compatibility'
)

Describe-Ticket 'declared-fields/01' 'every skill declares its mode as a field, not a body line' {

  # Matched by its subject rather than by the wording introduced here —
  # `.claude/rules/skills.md` names a guard written from one's own new phrasing
  # as the recurring failure, because an older restatement elsewhere goes unseen.
  # No directory is exempted: `# Mode:` in the mode templates is a heading and
  # cannot match this anchor, so an exemption for it would be a branch that
  # never fires and therefore one no mutation could ever confirm.
  Assert "no skill states its mode as a prose line" {
    $offenders = @()
    foreach ($f in Get-SkillFiles) {
      if ((Get-SkillText $f) -match '(?m)^Mode:[ \t]*\S') {
        $offenders += $f.FullName.Substring($skills.Length).TrimStart('\', '/') -replace '\\', '/'
      }
    }
    if ($offenders) { throw "a mode is declared as prose in: $($offenders -join ', ')" }
    $true
  }

  # The harness "drops a value that isn't a map" silently, taking every field on
  # that skill with it. Nothing downstream would notice, which is why the shape
  # is asserted rather than trusted — silence is the failure mode.
  Assert "no skill's metadata is a scalar — the harness drops a non-map without saying so" {
    $offenders = @()
    foreach ($d in (Get-ChildItem $skills -Directory)) {
      $f = Join-Path $d.FullName 'SKILL.md'
      if (-not (Test-Path $f)) { continue }
      $fm = Get-Frontmatter (Get-Content $f -Raw)
      if (-not $fm) { continue }
      if ($fm -match '(?m)^metadata:[ \t]*\S') { $offenders += $d.Name }
    }
    if ($offenders) { throw "metadata carries a scalar in: $($offenders -join ', ')" }
    $true
  }

  Assert "no key inside metadata collides with a name the harness reserves" {
    $offenders = @()
    foreach ($d in (Get-ChildItem $skills -Directory)) {
      $f = Join-Path $d.FullName 'SKILL.md'
      if (-not (Test-Path $f)) { continue }
      $fm = Get-Frontmatter (Get-Content $f -Raw)
      if (-not $fm) { continue }
      $block = [regex]::Match($fm, '(?ms)^metadata:[ \t]*\r?$(.*?)(?=^\S|\z)')
      if (-not $block.Success) { continue }
      foreach ($k in [regex]::Matches($block.Groups[1].Value, '(?m)^[ \t]+([A-Za-z0-9_-]+):')) {
        if ($reservedFrontmatterKeys -contains $k.Groups[1].Value) {
          $offenders += "$($d.Name)/$($k.Groups[1].Value)"
        }
      }
    }
    if ($offenders) { throw "a reserved harness field name is reused as a metadata key: $($offenders -join ', ')" }
    $true
  }
}

Describe-Ticket 'declared-fields/03' 'dispatched roles declare their mode under the same map' {

  $roleFiles = @(Get-ChildItem (Join-Path $repo 'agents') -File -Filter *.md -ErrorAction SilentlyContinue)

  # The old form was a bare top-level key the subagent reference does not list.
  # Anchored at column zero so it cannot match the indented key that replaced it.
  Assert "no role declares its mode as a bare top-level key" {
    $offenders = @()
    foreach ($r in $roleFiles) {
      $fm = Get-Frontmatter (Get-Content $r.FullName -Raw)
      if (-not $fm) { continue }
      if ($fm -match '(?m)^mode:[ \t]*\S') { $offenders += $r.Name }
    }
    if ($offenders) { throw "mode sits at the top level in: $($offenders -join ', ')" }
    $true
  }

  # Same silent failure as on skills, and its own assertion rather than a widened
  # one for a reason that needs no claim about the harness: a sweep over
  # `skills/` never opens `agents/`, so passing there says nothing here.
  Assert "no role's metadata is a scalar" {
    $offenders = @()
    foreach ($r in $roleFiles) {
      $fm = Get-Frontmatter (Get-Content $r.FullName -Raw)
      if (-not $fm) { continue }
      if ($fm -match '(?m)^metadata:[ \t]*\S') { $offenders += $r.Name }
    }
    if ($offenders) { throw "metadata carries a scalar in: $($offenders -join ', ')" }
    $true
  }
}

Describe-Ticket 'declared-fields/02' 'every skill declares its guides as a field, not a body line' {

  # Anchored to the old form itself rather than to anything this ticket wrote,
  # for the reason `.claude/rules/skills.md` gives: a guard built from your own
  # new phrasing cannot see a restatement that predates it.
  Assert "no skill states its guides as a prose line" {
    $offenders = @()
    foreach ($f in Get-SkillFiles) {
      if ((Get-SkillText $f) -match '(?m)^Policies:[ \t]*\S') {
        $offenders += $f.FullName.Substring($skills.Length).TrimStart('\', '/') -replace '\\', '/'
      }
    }
    if ($offenders) { throw "guides are declared as prose in: $($offenders -join ', ')" }
    $true
  }

}

# --- ticket declared-fields/04 — a spec declares its status and its sources ---

# `.claude/policies/tracker.md` owns where a spec lives here: one under each
# effort, rather than the flat designs directory a configured repository gets.
# Read from that path alone — a sweep that tried both would find the empty one
# and report a clean pass over nothing.
function Get-SpecFiles {
  $efforts = Join-Path $repo '.claude/tickets'
  if (-not (Test-Path $efforts)) { return @() }
  @(Get-ChildItem $efforts -Directory |
      ForEach-Object { Join-Path $_.FullName 'spec.md' } |
      Where-Object { Test-Path $_ })
}

# Everything below the frontmatter. The prose form and the field form are the
# same word at the same column, so the two are told apart by position and not by
# capitalisation. Fenced regions are swept along with the rest, unlike
# `Get-Section`: a `Status:` line inside a fence is a spec displaying the retired
# form, and failing on one is the answer wanted here rather than the false
# positive it would be for a heading.
function Get-BodyBelowFrontmatter {
  param([string]$Content)
  if ($Content -match '(?s)\A---\r?\n.*?\r?\n---\r?\n(.*)\z') { return $Matches[1] }
  $Content
}

Describe-Ticket 'declared-fields/04' 'a spec declares its status and its sources as fields' {

  # Both copies of the spec format: the one AEP ships and the one this
  # repository runs on. Read as a pair so a template that moved without its
  # installed copy fails — the *template block* is what is compared, and the
  # prose around it diverges legitimately, since where a spec lives is this
  # repository's own fact and not one the shipped default can carry.
  $specFormatCopies = [ordered]@{
    'the shipped template' = { Get-SkillFile 'configure/policies/specs.template.md' }
    'this repository'      = { Get-Content (Join-Path $repo '.claude/policies/specs.md') -Raw }
  }

  # The fenced example under `## Template` is what an author copies, so it is
  # where the format states its shape. A rule in prose beside a template still
  # showing the old form is a rule that loses to the thing people paste.
  $templateBlock = {
    param([string]$Content)
    $m = [regex]::Match((Get-Section $Content 'Template'), '(?ms)^```markdown\r?\n(.*?)^```')
    if (-not $m.Success) { throw 'the format carries no template block' }
    $m.Groups[1].Value
  }

  Assert "the spec format's template declares status and sources as frontmatter fields" {
    foreach ($name in $specFormatCopies.Keys) {
      $fm = Get-Frontmatter (& $templateBlock (& $specFormatCopies[$name]))
      if (-not $fm) { throw "$name`: the spec template opens with no frontmatter" }
      foreach ($k in 'status', 'sources') {
        if ($fm -notmatch "(?m)^${k}:") { throw "$name`: the template declares no ${k} field" }
      }
    }
    $true
  }

  Assert "the spec format's template states neither status nor sources in the body" {
    foreach ($name in $specFormatCopies.Keys) {
      $body = Get-BodyBelowFrontmatter (& $templateBlock (& $specFormatCopies[$name]))
      $m = [regex]::Match($body, '(?im)^(Status|Sources):')
      if ($m.Success) { throw "$name`: the template still shows $($m.Groups[1].Value) as a body line" }
    }
    $true
  }

  Assert "no spec states its status or its sources as a prose line" {
    $offenders = @()
    foreach ($s in Get-SpecFiles) {
      $m = [regex]::Match((Get-BodyBelowFrontmatter (Get-Content $s -Raw)), '(?im)^(Status|Sources):')
      if ($m.Success) {
        $offenders += "$(Split-Path (Split-Path $s -Parent) -Leaf)/$($m.Groups[1].Value)"
      }
    }
    if ($offenders) { throw "declared as prose in: $($offenders -join ', ')" }
    $true
  }

  # The vocabulary is derived from the format's own enumeration line, never
  # listed here: a status set with two homes drifts at one of them, and the
  # format is the home. This repository's copy, because these are its specs.
  Assert "every spec declares a status the format defines" {
    $fmt = Get-Content (Join-Path $repo '.claude/policies/specs.md') -Raw
    $line = (($fmt -split '\r?\n') | Where-Object { $_ -match '`draft`' }) -join ' '
    if (-not $line) { throw 'the format carries no status vocabulary line' }
    $vocab = @([regex]::Matches($line, '`([a-z]+)') | ForEach-Object { $_.Groups[1].Value })
    $offenders = @()
    foreach ($s in Get-SpecFiles) {
      $effort = Split-Path (Split-Path $s -Parent) -Leaf
      $fm = Get-Frontmatter (Get-Content $s -Raw)
      if (-not $fm) { $offenders += "${effort}: no frontmatter"; continue }
      $m = [regex]::Match($fm, '(?m)^status:[ \t]*(\S+)')
      if (-not $m.Success) { $offenders += "${effort}: no status field"; continue }
      if ($vocab -notcontains $m.Groups[1].Value) { $offenders += "${effort}: $($m.Groups[1].Value)" }
    }
    if ($offenders) { throw "a status the format does not define: $($offenders -join ', ')" }
    $true
  }

  # Deleting a spec's whole `sources` block left the suite green until review
  # found it: only the *format* was checked, so a conversion that dropped every
  # list on its way through would have passed. The shape is asserted with the
  # presence, because `sources:` followed by nothing is YAML null rather than
  # the empty list a spec with nothing to point at is supposed to declare.
  Assert "every spec declares its sources, empty or not" {
    $offenders = @()
    foreach ($s in Get-SpecFiles) {
      $effort = Split-Path (Split-Path $s -Parent) -Leaf
      $fm = Get-Frontmatter (Get-Content $s -Raw)
      if (-not $fm) { $offenders += "${effort}: no frontmatter"; continue }
      $m = [regex]::Match($fm, '(?m)^sources:[ \t]*(\[\])?[ \t]*$')
      if (-not $m.Success) { $offenders += "${effort}: no sources field, or an inline list"; continue }
      if (-not $m.Groups[1].Success -and $fm -notmatch '(?ms)^sources:[ \t]*$\r?\n[ \t]+-[ \t]*\S') {
        $offenders += "${effort}: sources declares nothing and does not say so"
      }
    }
    if ($offenders) { throw ($offenders -join ', ') }
    $true
  }

  # Scoped to the *sentence that performs the write*, never the step. Both review
  # axes broke the first version of this, which asked only whether the word
  # `field` appeared somewhere in the step: reverting the imperative to the prose
  # form while leaving the neighbouring "Only the status field moves" untouched
  # kept every assertion green. A guard has to match its subject, and the subject
  # is the instruction, not the prose standing next to it.
  Assert "/commit sets the spec's status field, and no longer edits a line" {
    # The heading is dropped first — it says "Mark the spec implemented" and
    # would otherwise be read as an instruction with no mechanism named.
    $body = ((Get-SpecStep) -split '\r?\n', 2)[1]
    # Sentences end at a period followed by whitespace, so `.claude/policies/`
    # and `specs.md` do not split one.
    $writes = @(($body -split '(?<=\.)\s+') | Where-Object { $_ -match '\bimplemented\b' })
    if (-not $writes) { throw 'the step never says the spec is marked implemented' }
    foreach ($w in $writes) {
      $s = ($w -replace '\s+', ' ').Trim()
      if ($w -notmatch '(?i)frontmatter') { throw "the write does not name the frontmatter: $s" }
      if ($w -match '(?i)\bline\b') { throw "the write still describes a line: $s" }
    }
    $true
  }
}

# --- ticket declared-fields/05 — one regenerator, checked by comparison -------

$regenerator = Join-Path $repo '.claude/scripts/regenerate-indexes.ps1'

# A tree with just enough shape for the script: `.claude/<family>/` and nothing
# else. Built and torn down per assertion, because several of these deliberately
# corrupt what they are given and a shared one would leak that into its
# neighbours — which is how a suite starts depending on the order it runs in.
$mkIndexTree = {
  param([hashtable]$Files)
  $root = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
  foreach ($rel in $Files.Keys) {
    $path = Join-Path $root $rel
    New-Item -ItemType Directory -Path (Split-Path $path -Parent) -Force | Out-Null
    [System.IO.File]::WriteAllText($path, $Files[$rel])
  }
  $root
}

$runRegenerator = {
  param([string]$Root)
  $out = & pwsh -NoProfile -File $regenerator -Repo $Root 2>&1
  [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out | Out-String) }
}

Describe-Ticket 'declared-fields/05' 'one regenerator produces every index, and the suite compares' {

  Assert "the regenerator ships as a committed script" {
    if (-not (Test-Path $regenerator)) { throw '.claude/scripts/regenerate-indexes.ps1 is missing' }
    $true
  }

  # Run from a copy of the script alone, in a tree holding nothing but the two
  # indexed directories: no `skills/`, no repository, no git. The first version
  # of this grepped the source for three spellings the author had thought of,
  # which `.claude/rules/skills.md` names exactly — a guard matching your own
  # wording rather than its subject, and the subject here is reachability.
  Assert "the regenerator runs where the plugin and the repository are absent" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md' = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/decisions/0001-x.md'    = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
    }
    try {
      $alone = Join-Path $root 'regenerate-indexes.ps1'
      Copy-Item $regenerator $alone
      $out = & pwsh -NoProfile -File $alone -Repo $root 2>&1
      if ($LASTEXITCODE -ne 0) { throw "failed in isolation: $($out | Out-String)" }
      foreach ($family in 'contexts', 'decisions') {
        if (-not (Test-Path (Join-Path $root ".claude/$family/map.md"))) { throw "$family/map.md was not written" }
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # The block form specs use is refused, not read as empty. Read as empty it
  # renders a row saying the file points at nothing, which is a wrong answer
  # wearing a right one's shape — and no reader of the index could tell.
  Assert "a sources field the index cannot read is refused, and named" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md' = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/contexts/blocklist.md'  = "---`nload-when: the request touches auth`nsources:`n  - src/auth/`n  - src/session/`n---`n`n# Auth`n"
      '.claude/decisions/0001-x.md'    = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -eq 0) { throw 'a block list was silently read as no sources at all' }
      if ($r.Output -notmatch 'blocklist\.md') { throw "the failure does not name the file: $($r.Output)" }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  Assert "a file declaring no sources at all is refused, and named" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md' = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/contexts/nosources.md'  = "---`nload-when: the request touches auth`n---`n`n# Auth`n"
      '.claude/decisions/0001-x.md'    = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -eq 0) { throw 'a context with no sources field was indexed anyway' }
      if ($r.Output -notmatch 'nosources\.md') { throw "the failure does not name the file: $($r.Output)" }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # The acceptance test and the de-risking together: these two indexes are the
  # only ones with an answer already known to be right, and everything later in
  # this effort is generated by the same code path.
  Assert "regenerating reproduces both committed indexes byte for byte" {
    $root = & $mkIndexTree @{}
    try {
      foreach ($family in 'contexts', 'decisions') {
        Copy-Item (Join-Path $repo ".claude/$family") (Join-Path $root ".claude/$family") -Recurse
      }
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the regenerator failed: $($r.Output)" }
      foreach ($family in 'contexts', 'decisions') {
        $committed = [System.IO.File]::ReadAllBytes((Join-Path $repo ".claude/$family/map.md"))
        $produced = [System.IO.File]::ReadAllBytes((Join-Path $root ".claude/$family/map.md"))
        if ($committed.Length -ne $produced.Length) {
          throw "$family/map.md differs in length: committed $($committed.Length) B, regenerated $($produced.Length) B"
        }
        for ($i = 0; $i -lt $committed.Length; $i++) {
          if ($committed[$i] -ne $produced[$i]) { throw "$family/map.md differs at byte $i" }
        }
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # The writer's half. The *check* that a hand edit fails the build is the
  # byte-for-byte assertion above, confirmed by editing this repository's own
  # committed index and watching it fail; this one asserts the other direction,
  # that regenerating actually replaces what somebody typed rather than
  # appending to it or leaving it alone.
  Assert "regeneration replaces a hand edit rather than preserving it" {
    $root = & $mkIndexTree @{}
    try {
      foreach ($family in 'contexts', 'decisions') {
        Copy-Item (Join-Path $repo ".claude/$family") (Join-Path $root ".claude/$family") -Recurse
      }
      $map = Join-Path $root '.claude/decisions/map.md'
      $edited = (Get-Content $map -Raw) -replace 'accepted', 'accepted (still true)'
      [System.IO.File]::WriteAllText($map, $edited)
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the regenerator failed: $($r.Output)" }
      if ((Get-Content $map -Raw) -eq $edited) { throw 'a hand edit survived regeneration' }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # Not "is quietly left out": a context or decision missing from the index is
  # unreachable, and the silent version of that is found by whoever needed the
  # file rather than by the build.
  Assert "a file declaring no fields stops the regeneration, and is named" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md' = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/contexts/bare.md'       = "# Bare`n`nNo frontmatter at all.`n"
      '.claude/decisions/0001-x.md'    = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -eq 0) { throw 'a fieldless context was accepted into the index' }
      if ($r.Output -notmatch 'bare\.md') { throw "the failure does not name the file: $($r.Output)" }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # The branch no repository in this tree exercises. The label row carries the
  # directory name and two empty cells because nothing declares a value for
  # them — the format states that, and this is the only place it is executed.
  Assert "a Project Context renders as a labelled group with an empty label row" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md'      = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/contexts/web/routing.md'     = "---`nload-when: navigation or URL shape`nsources: [apps/web/src/routes/]`n---`n`n# Routing`n"
      '.claude/decisions/0001-x.md'         = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the regenerator failed: $($r.Output)" }
      # Carriage returns dropped before matching, for the reason `Get-Frontmatter`
      # gives: the script emits the checkout's own line ending, so `$` would sit
      # after a `\r` here and every anchored pattern below would fail on Windows
      # alone.
      $map = (Get-Content (Join-Path $root '.claude/contexts/map.md') -Raw) -replace "`r", ''
      if ($map -notmatch '(?m)^\| \*\*web\*\* \| \| \|$') { throw "no empty label row for the group: $map" }
      if ($map -notmatch '(?m)^\| \[web/routing\]\(web/routing\.md\) \| navigation or URL shape \| `apps/web/src/routes/` \|$') {
        throw "the member row is wrong: $map"
      }
      # The group follows the flat rows rather than sorting among them.
      if ([regex]::Match($map, '(?m)^\| \[repository\]').Index -gt [regex]::Match($map, '(?m)^\| \*\*web\*\*').Index) {
        throw 'the group precedes the flat contexts'
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  Assert "two runs over an unchanged tree produce identical output" {
    $root = & $mkIndexTree @{}
    try {
      foreach ($family in 'contexts', 'decisions') {
        Copy-Item (Join-Path $repo ".claude/$family") (Join-Path $root ".claude/$family") -Recurse
      }
      & $runRegenerator $root | Out-Null
      $first = foreach ($f in 'contexts', 'decisions') { Get-Content (Join-Path $root ".claude/$f/map.md") -Raw }
      & $runRegenerator $root | Out-Null
      $second = foreach ($f in 'contexts', 'decisions') { Get-Content (Join-Path $root ".claude/$f/map.md") -Raw }
      if (($first -join '') -cne ($second -join '')) { throw 'a second regeneration differed from the first' }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # Named for what it checks: the step's position against the one that makes the
  # commit. Staging has no heading of its own, so "before staging" is prose the
  # step carries and this is the orderable fact underneath it.
  Assert "/commit regenerates the indexes, and does it before the commit is made" {
    $c = Get-SkillFile 'commit/SKILL.md'
    if ($c -notmatch [regex]::Escape('.claude/scripts/regenerate-indexes.ps1')) {
      throw '/commit never invokes the regenerator'
    }
    $regen = [regex]::Match($c, '(?im)^#{2,}\s.*regenerate')
    $make = [regex]::Match($c, '(?im)^#{2,}\s.*make the commit')
    if (-not $regen.Success) { throw 'regenerating is not its own step' }
    if (-not $make.Success) { throw 'making the commit is not its own step' }
    if ($regen.Index -ge $make.Index) { throw 'the indexes are regenerated after the commit is made' }
    $true
  }
}

# --- ticket declared-fields/10 — a per-effort map moves into its effort -------

Describe-Ticket 'declared-fields/10' 'a per-effort map moves into its effort directory' {

  $mapFormats = [ordered]@{
    'the shipped template' = { Get-SkillFile 'configure/policies/maps.template.md' }
    'this repository'      = { Get-Content (Join-Path $repo '.claude/policies/maps.md') -Raw }
  }

  # Both copies, because ADR 0025 orders them. Asserted here rather than through
  # the `$legacy` sweep, which bans a path outright: this path was reassigned,
  # not retired, so the claim is about where the *map* goes and not about the
  # string appearing anywhere.
  Assert "neither map format puts the map at the shared path" {
    foreach ($name in $mapFormats.Keys) {
      $c = & $mapFormats[$name]
      if ($c -match '\.claude/tickets/map\.md') { throw "$name`: still names the shared path for the map" }
      if ($c -notmatch '\.claude/tickets/<effort>/map\.md') { throw "$name`: does not name the effort directory" }
    }
    $true
  }

  # The migration derives a map's destination from its own title, so the title
  # is load-bearing rather than decorative. Review changed it to `# Fog map` in
  # both copies and the whole suite stayed green, leaving the migration row's
  # destination underivable with nothing to say so.
  Assert "both map formats show a title that names the effort the map charts" {
    foreach ($name in $mapFormats.Keys) {
      if ((& $mapFormats[$name]) -notmatch '(?m)^#\s+map:\s*<effort name>') {
        throw "$name`: the template's title no longer names the effort"
      }
    }
    $true
  }

  # The layout is where the collision became possible: it named the spec and the
  # issues under each effort and named neither the map nor a repository-wide
  # index, so two artefacts could arrive at one path with nothing to contradict.
  # The subtree is bounded by indentation, not by the closing fence. Two earlier
  # versions of this failed differently and both passed: the first matched
  # `contexts/map.md`, and the second ran from `tickets/` to the fence and so
  # swallowed `position/` — review filed the shared index under the directory
  # `specs.md` itself calls never depended on, and all four assertions stayed
  # green. Ordering luck is not scope.
  Assert "the specification's layout names both the per-effort map and the shared index" {
    $layout = Get-Section (Get-Content (Join-Path $repo 'specs.md') -Raw) 'Repository layout'
    $lines = @(($layout -replace "`r", '') -split "`n")
    $start = ($lines | Select-String -Pattern '^(\s*)tickets/\s*$' | Select-Object -First 1)
    if (-not $start) { throw 'the layout has no tickets subtree' }
    $indent = $start.Matches[0].Groups[1].Value.Length
    $from = $lines.IndexOf($start.Line)
    $subtree = @()
    for ($i = $from + 1; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -match '^\s*$') { continue }
      $thisIndent = ([regex]::Match($lines[$i], '^\s*')).Value.Length
      if ($thisIndent -le $indent) { break }
      $subtree += $lines[$i]
    }
    $joined = $subtree -join "`n"
    if ($joined -notmatch '(?m)^\s+map\.md\s') { throw 'the tickets subtree does not name the shared index' }
    if ($joined -notmatch '(?m)^\s+<effort>/\s+.*map\.md') { throw 'the tickets subtree does not name the per-effort map' }
    $true
  }

  # Written while the path was empty, to prove there was nothing to migrate. It
  # is not empty now — `declared-fields/07` put the design index there, which is
  # what vacating it was for — so the claim is the one that still matters: no
  # *fog map* sits there. The two are told apart by their titles, which is also
  # what the migration row reads to find a map's effort.
  #
  # What this does *not* claim is that the migration row is exercised. There is
  # no migration fixture anywhere in this suite; the only enforcement any row has
  # is the prose regex in `$conversions`. That half of the ticket's acceptance is
  # unmet and recorded on the ticket rather than papered over here.
  Assert "no fog map sits at the vacated path — only the index it was vacated for" {
    $at = Join-Path $repo '.claude/tickets/map.md'
    if (-not (Test-Path $at)) { throw 'nothing is at the path — the design index that vacating it was for is missing' }
    $title = ((Get-Content $at -TotalCount 1) -replace "`r", '').Trim()
    if ($title -match '(?i)^#\s+map:') { throw "a fog map still sits at the vacated path: $title" }
    if ($title -ne '# Design map') { throw "an unexpected file sits at the vacated path: $title" }
    $true
  }
}

# --- ticket declared-fields/06 — five kinds, one index ------------------------

Describe-Ticket 'declared-fields/06' 'the five evidence kinds declare fields and share one index' {

  $evidenceMap = Join-Path $repo '.claude/evidence/map.md'

  $evidenceFormats = [ordered]@{
    'the shipped template' = { Get-SkillFile 'configure/policies/evidence.template.md' }
    'this repository'      = { Get-Content (Join-Path $repo '.claude/policies/evidence.md') -Raw }
  }

  # The fields are declared for the family, not for the kinds that happen to
  # have a directory today — a kind gains a directory when it gains a file, so
  # a format written only for the kinds present would be wrong on the next one.
  Assert "both evidence formats declare kind and falsifies as the family's fields" {
    foreach ($name in $evidenceFormats.Keys) {
      $c = & $evidenceFormats[$name]
      foreach ($field in 'kind', 'falsifies') {
        if ($c -notmatch "(?m)^\|\s*``$field``\s*\|") { throw "$name`: $field is not declared as a field" }
      }
    }
    $true
  }

  # ADR 0056's claim is the *width*: one index at the family root, spanning all
  # five, which is what makes `kind` a column rather than a restatement of the
  # path. An index beneath each kind would satisfy "declares fields" and defeat
  # the obligation the index exists to serve.
  Assert "the index spans every kind, at the family root" {
    if (-not (Test-Path $evidenceMap)) { throw '.claude/evidence/map.md is missing' }
    $m = (Get-Content $evidenceMap -Raw) -replace "`r", ''
    if ($m -notmatch '(?m)^\| Finding \| Kind \| Falsifies \|$') { throw 'the kind column is missing' }
    foreach ($dir in (Get-ChildItem (Join-Path $repo '.claude/evidence') -Directory)) {
      foreach ($f in (Get-ChildItem $dir.FullName -File -Filter '*.md' | Where-Object { $_.Name -ne 'map.md' })) {
        $link = "($($dir.Name)/$($f.Name))"
        if (-not $m.Contains($link)) { throw "no row for $($dir.Name)/$($f.Name)" }
      }
    }
    $true
  }

  Assert "the committed evidence index matches a regeneration, byte for byte" {
    $root = & $mkIndexTree @{}
    try {
      foreach ($family in 'contexts', 'decisions', 'evidence') {
        Copy-Item (Join-Path $repo ".claude/$family") (Join-Path $root ".claude/$family") -Recurse
      }
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the regenerator failed: $($r.Output)" }
      $committed = [System.IO.File]::ReadAllBytes($evidenceMap)
      $produced = [System.IO.File]::ReadAllBytes((Join-Path $root '.claude/evidence/map.md'))
      if ($committed.Length -ne $produced.Length) {
        throw "evidence/map.md differs in length: committed $($committed.Length) B, regenerated $($produced.Length) B"
      }
      for ($i = 0; $i -lt $committed.Length; $i++) {
        if ($committed[$i] -ne $produced[$i]) { throw "evidence/map.md differs at byte $i" }
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  Assert "a finding declaring no fields stops the regeneration, and is named" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md'    = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/decisions/0001-x.md'       = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
      '.claude/evidence/drift/bare.md'    = "# Bare`n`nNo frontmatter.`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -eq 0) { throw 'a fieldless finding was accepted into the index' }
      if ($r.Output -notmatch 'bare\.md') { throw "the failure does not name the file: $($r.Output)" }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # The kinds with no file have no directory, and the format says so. Asserted
  # because the easy mistake is to create all five while adding the index, which
  # would make every empty one a claim that the work behind it happened.
  Assert "a kind earns its directory when it has a file, and empty ones are not created" {
    $empty = @(Get-ChildItem (Join-Path $repo '.claude/evidence') -Directory |
      Where-Object { -not (Get-ChildItem $_.FullName -File -Filter '*.md' | Where-Object { $_.Name -ne 'map.md' }) })
    if ($empty) { throw "evidence directories with no finding in them: $($empty.Name -join ', ')" }
    foreach ($name in $evidenceFormats.Keys) {
      if ((& $evidenceFormats[$name]) -notmatch '(?i)earns its directory') {
        throw "$name`: the rule that a kind earns its directory is not stated"
      }
    }
    $true
  }

  # Anchored on the *path*, not on the sentence that used to contain it. The
  # first version matched the old prose's verb, and review rewrote the step to
  # read the whole directory in different words — this assertion and
  # `scaffolding/04` both stayed green. After this ticket the discovery step has
  # no reason to name the drift directory at all: it names the index.
  Assert "/design routes through the index rather than reading the drift directory" {
    $discover = Get-Section (Get-SkillFile 'design/SKILL.md') 'Discover'
    if ($discover -notmatch [regex]::Escape('.claude/evidence/map.md')) {
      throw 'the discovery step does not name the index'
    }
    if ($discover -match [regex]::Escape('.claude/evidence/drift/')) {
      throw 'the discovery step still names the drift directory'
    }
    $true
  }

  # ADR 0056's first rejected option, reintroducible with nothing failing until
  # now: review created `.claude/evidence/drift/map.md` by hand and the whole
  # suite passed. Both the regenerator and the assertions filter `map.md` out of
  # each kind, so a per-kind index is invisible to every check that walks them.
  Assert "no index sits beneath a kind — the family root is the only one" {
    $offenders = @(Get-ChildItem (Join-Path $repo '.claude/evidence') -Directory |
      Where-Object { Test-Path (Join-Path $_.FullName 'map.md') } |
      ForEach-Object { "$($_.Name)/map.md" })
    if ($offenders) { throw "an index beneath a kind: $($offenders -join ', ')" }
    $true
  }

  # The column ADR 0056 made load-bearing has to agree with the directory the
  # file sits in, or a row reads as one kind and links to another. Review
  # produced exactly that with a one-word edit and six assertions passed.
  Assert "a declared kind that disagrees with its directory stops the regeneration" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md'  = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/decisions/0001-x.md'     = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
      '.claude/evidence/research/f.md'  = "---`nkind: discussions`nfalsifies: []`n---`n`n# F`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -eq 0) { throw 'a finding indexed under a kind it does not sit in' }
      if ($r.Output -notmatch 'discussions') { throw "the failure does not name the disagreement: $($r.Output)" }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }
}

# --- ticket declared-fields/07 — designs gain a generated index ---------------

Describe-Ticket 'declared-fields/07' 'designs gain a generated index where the directory is flat' {

  $designMap = Join-Path $repo '.claude/tickets/map.md'

  # ADR 0059 gave this path to the design index once the per-effort map vacated
  # it. Both halves are asserted: the index is here, and the row for every
  # effort's spec is in it — a table with a header and no rows would satisfy a
  # presence check while indexing nothing.
  Assert "every effort's spec has a row, where the tracker policy puts specs" {
    if (-not (Test-Path $designMap)) { throw '.claude/tickets/map.md is missing' }
    $m = (Get-Content $designMap -Raw) -replace "`r", ''
    foreach ($effort in (Get-ChildItem (Join-Path $repo '.claude/tickets') -Directory)) {
      if (-not (Test-Path (Join-Path $effort.FullName 'spec.md'))) { continue }
      if (-not $m.Contains("($($effort.Name)/spec.md)")) { throw "no row for the $($effort.Name) effort" }
    }
    $true
  }

  Assert "the design index carries each spec's status" {
    $m = (Get-Content $designMap -Raw) -replace "`r", ''
    if ($m -notmatch '(?m)^\| Design \| Status \| Sources \|$') { throw 'the status column is missing' }
    foreach ($effort in (Get-ChildItem (Join-Path $repo '.claude/tickets') -Directory)) {
      $spec = Join-Path $effort.FullName 'spec.md'
      if (-not (Test-Path $spec)) { continue }
      $declared = [regex]::Match((Get-Frontmatter (Get-Content $spec -Raw)), '(?m)^status:[ \t]*(.+?)[ \t]*$').Groups[1].Value
      $row = [regex]::Match($m, "(?m)^\| \[$([regex]::Escape($effort.Name))\][^\r\n]*$").Value
      if ($row -notmatch [regex]::Escape($declared)) {
        throw "$($effort.Name) declares '$declared' and the index does not say so"
      }
    }
    $true
  }

  # The configured-repository path, which this tree does not have. The fixture's
  # first spec carries a comma *inside* one pointer — that comma is the whole
  # reason specs take block form, and the first attempt at this ticket deleted
  # the only assertion covering it, after which splitting entries on commas
  # passed everything. It is covered here, through the live path.
  Assert "a flat designs directory is indexed, and a comma inside a pointer survives" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md' = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/decisions/0001-x.md'    = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
      '.claude/designs/caching.md'     = "---`nstatus: accepted`nsources:`n  - specs.md §5, §8`n  - src/cache/`n---`n`n# feat(cache): add a layer`n"
      '.claude/designs/retries.md'     = "---`nstatus: implemented`nsources: []`n---`n`n# fix(http): retry`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the regenerator failed: $($r.Output)" }
      $m = (Get-Content (Join-Path $root '.claude/designs/map.md') -Raw) -replace "`r", ''
      if ($m -notmatch '(?m)^\| \[caching\]\(caching\.md\) \| accepted \| `specs\.md §5, §8`, `src/cache/` \|$') {
        throw "a comma inside one pointer was split, or the row is wrong: $m"
      }
      if ($m -notmatch '(?m)^\| \[retries\]\(retries\.md\) \| implemented \| — \|$') {
        throw "the empty-sources row is wrong: $m"
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # Both layouts at once is refused rather than silently preferred. The first
  # attempt preferred the flat one, so this repository was one `mkdir` away from
  # dropping every row and reporting it as a stale index.
  Assert "a tree holding both layouts is refused, and says which two" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md'   = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/decisions/0001-x.md'      = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
      '.claude/designs/caching.md'       = "---`nstatus: accepted`nsources: []`n---`n`n# feat(cache): a layer`n"
      '.claude/tickets/alpha/spec.md'    = "---`nstatus: accepted`nsources: []`n---`n`n# feat(alpha): a thing`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -eq 0) { throw 'both layouts were accepted and one was silently dropped' }
      if ($r.Output -notmatch 'designs' -or $r.Output -notmatch 'tickets') {
        throw "the refusal does not name both layouts: $($r.Output)"
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # The two refusals the first attempt wrote and covered with nothing. Review
  # mutated each to an empty list and all 1025 assertions stayed green — the
  # ticket's own checklist named this reintroduction and the rebuild repeated it.
  # One fixture each, because a single one would leave whichever refusal it did
  # not reach exactly as unheld as before.
  foreach ($case in @(
    @{ Name = 'declares sources as YAML null'; Body = "---`nstatus: accepted`nsources:`n---`n`n# feat(x): a thing`n" },
    @{ Name = 'omits sources entirely';        Body = "---`nstatus: accepted`n---`n`n# feat(x): a thing`n" }
  )) {
    Assert "a spec that $($case.Name) stops the regeneration, and is named" {
      $root = & $mkIndexTree @{
        '.claude/contexts/repository.md' = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
        '.claude/decisions/0001-x.md'    = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
        '.claude/designs/thin.md'        = $case.Body
      }
      try {
        $r = & $runRegenerator $root
        if ($r.ExitCode -eq 0) { throw "a spec that $($case.Name) was indexed as pointing at nothing" }
        if ($r.Output -notmatch 'thin') { throw "the failure does not name the file: $($r.Output)" }
      } finally { Remove-Item -LiteralPath $root -Recurse -Force }
      $true
    }
  }

  # The fixtures above and below hand-write frontmatter, so they prove the
  # regenerator and not the template. This pairs them: the keys a fixture
  # declares are read out of `specs.template.md`'s own example, so a template
  # whose shape drifted fails here instead of passing silently.
  Assert "the fixtures declare the keys the shipped template prescribes" {
    $block = [regex]::Match((Get-Section (Get-SkillFile 'configure/policies/specs.template.md') 'Template'),
                            '(?ms)^```markdown\r?\n(.*?)^```')
    if (-not $block.Success) { throw 'the template carries no example' }
    $fm = Get-Frontmatter $block.Groups[1].Value
    if (-not $fm) { throw 'the template example opens with no frontmatter' }
    $keys = @([regex]::Matches($fm, '(?m)^([a-z][a-z0-9-]*):') | ForEach-Object { $_.Groups[1].Value })
    foreach ($k in 'status', 'sources') {
      if ($keys -notcontains $k) { throw "the template no longer prescribes '$k', which every fixture here declares" }
    }
    $true
  }

  Assert "a spec declaring no status stops the regeneration, and is named" {
    $root = & $mkIndexTree @{
      '.claude/contexts/repository.md' = "---`nload-when: a term is in question`nsources: []`n---`n`n# R`n"
      '.claude/decisions/0001-x.md'    = "---`nstatus: accepted`nload-when: x`nsources: []`n---`n`n# X`n"
      '.claude/designs/nostatus.md'    = "---`nsources: []`n---`n`n# feat(x): a thing`n"
    }
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -eq 0) { throw 'a spec with no status was indexed anyway' }
      if ($r.Output -notmatch 'nostatus\.md') { throw "the failure does not name the file: $($r.Output)" }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  Assert "the committed design index matches a regeneration, byte for byte" {
    $root = & $mkIndexTree @{}
    try {
      foreach ($family in 'contexts', 'decisions', 'evidence', 'tickets') {
        Copy-Item (Join-Path $repo ".claude/$family") (Join-Path $root ".claude/$family") -Recurse
      }
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the regenerator failed: $($r.Output)" }
      $committed = [System.IO.File]::ReadAllBytes($designMap)
      $produced = [System.IO.File]::ReadAllBytes((Join-Path $root '.claude/tickets/map.md'))
      if ($committed.Length -ne $produced.Length) {
        throw "tickets/map.md differs in length: committed $($committed.Length) B, regenerated $($produced.Length) B"
      }
      for ($i = 0; $i -lt $committed.Length; $i++) {
        if ($committed[$i] -ne $produced[$i]) { throw "tickets/map.md differs at byte $i" }
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  Assert "the spec format states the index it generates, and that it is never hand-edited" {
    $copies = @{
      'the shipped template' = Get-SkillFile 'configure/policies/specs.template.md'
      'this repository'      = Get-Content (Join-Path $repo '.claude/policies/specs.md') -Raw
    }
    foreach ($name in $copies.Keys) {
      if ($copies[$name] -notmatch 'map\.md') { throw "$name`: the index is unnamed" }
      if ($copies[$name] -notmatch '(?i)never hand-edited') { throw "$name`: the index is not stated as never hand-edited" }
    }
    $true
  }
}

# --- ticket declared-fields/09 — a configured repository derives the script ---

Describe-Ticket 'declared-fields/09' 'a configured repository gets the regenerator, not a promise' {

  $page = 'configure/SCRIPTS.md'

  Assert "the derivation page ships, and /configure reaches it by pointer" {
    if (-not (Test-Path (Join-Path $skills $page))) { throw "skills/$page is missing" }
    if ((Get-SkillFile 'configure/SKILL.md') -notmatch [regex]::Escape('SCRIPTS.md')) {
      throw '/configure does not point at the derivation page'
    }
    $true
  }

  # The criterion is *every index the workflow generates*, not a list — the
  # ticket's own enumeration was written before the evidence index existed and
  # already names three of the four.
  #
  # Both directions, and both read from artefacts rather than from a literal
  # here. The first version derived the script's families from *doc comments*
  # while claiming to read the script, so a family added to `$families` was
  # invisible to it; and it checked page→script not at all, so a family the page
  # invented passed. Review found both.
  $emittedTitles = {
    # The `# <Family> map` heading each builder emits, which is the one place
    # the script states a family in a form the page must match.
    @([regex]::Matches((Get-Content $regenerator -Raw), "'(#\s+\w+\s+map)'") |
        ForEach-Object { $_.Groups[1].Value }) | Sort-Object -Unique
  }
  $pageTitles = {
    @([regex]::Matches((Get-SkillFile $page), '(?m)^(#\s+\w+\s+map)\s*$') |
        ForEach-Object { $_.Groups[1].Value }) | Sort-Object -Unique
  }

  Assert "the page specifies every index the regenerator emits, and no index it does not" {
    $emitted = @(& $emittedTitles)
    $documented = @(& $pageTitles)
    if (-not $emitted) { throw 'no index titles could be read from the regenerator' }
    $missing = @($emitted | Where-Object { $documented -notcontains $_ })
    if ($missing) { throw "the regenerator emits an index the page does not specify: $($missing -join ', ')" }
    $invented = @($documented | Where-Object { $emitted -notcontains $_ })
    if ($invented) { throw "the page specifies an index nothing produces: $($invented -join ', ')" }
    $true
  }

  # The two layouts differ in where the file lands, not only in what the rows
  # say — the first version of this page claimed the index sits "beside the
  # specs" either way, which ADR 0059 names as false under the effort layout and
  # which would have put the file one directory too deep in every repository
  # that uses it.
  Assert "the page states where the designs index lands under each layout" {
    $c = Get-SkillFile $page
    foreach ($path in '.claude/designs/map.md', '.claude/tickets/map.md') {
      if (-not $c.Contains($path)) { throw "the page does not say the index lands at $path" }
    }
    $true
  }

  # Byte-stability is the property the whole enforcement rests on, and it is the
  # one a derived script gets wrong invisibly. Deleting this section from the
  # page left every other assertion here green.
  Assert "the page states what makes the output byte-stable" {
    $c = Get-SkillFile $page
    foreach ($rule in 'line ending', 'byte-order mark', 'trailing newline') {
      if ($c -notmatch "(?i)$([regex]::Escape($rule))") { throw "the page does not state: $rule" }
    }
    $true
  }

  # Stated as behaviour rather than as code, because an implementation in another
  # language cannot inherit a refusal it can only read about in PowerShell.
  Assert "the page states the refusals, not only the happy path" {
    $c = Get-SkillFile $page
    foreach ($refusal in 'no frontmatter', 'absent', 'other shape', 'YAML null', 'disagrees with the directory') {
      if ($c -notmatch "(?i)$([regex]::Escape($refusal))") { throw "the page does not state the refusal: $refusal" }
    }
    if ($c -notmatch '(?i)names the file') { throw 'the page does not say a refusal names the file' }
    $true
  }

  # The one check whose answer was not produced by the thing being checked — so
  # both halves are read out of the page. The first version transcribed the
  # fixture's *input* into this assertion and only compared the output, which
  # meant editing the page's input, or deleting the whole fixture block, changed
  # nothing here. Review found both.
  Assert "the page's fixture is real: its own input produces its own claimed output" {
    $c = (Get-SkillFile $page) -replace "`r", ''

    # Input: the fenced block under the fixture heading, in which each file's
    # path is the line before its `---`.
    $fenced = [regex]::Match($c, '(?ms)Build this tree in a temporary directory:\r?\n\r?\n```\r?\n(.*?)^```')
    if (-not $fenced.Success) { throw 'the page carries no fixture tree' }
    $files = @{}
    foreach ($m in [regex]::Matches($fenced.Groups[1].Value, '(?ms)^(\S+\.md)\r?\n(---\r?\n.*?\r?\n---\r?\n\r?\n#[^\r\n]*)\r?\n')) {
      $files[$m.Groups[1].Value] = $m.Groups[2].Value + "`n"
    }
    if ($files.Count -lt 3) { throw "the fixture tree parsed as $($files.Count) files, expected at least 3" }

    $root = & $mkIndexTree $files
    try {
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the page's own fixture does not regenerate: $($r.Output)" }
      foreach ($family in 'contexts', 'decisions') {
        $produced = ((Get-Content (Join-Path $root ".claude/$family/map.md") -Raw) -replace "`r", '').TrimEnd("`n")
        if (-not $c.Contains($produced)) {
          throw "the page's claimed $family output is not what its own fixture produces:`n$produced"
        }
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # ADR 0060's consequence, and the one an author would most plausibly get wrong
  # by reaching for the mechanism `TOOLS.md` uses. There is nothing to compare
  # between a specification and an implementation of it.
  Assert "the page names behaviour as the enforcement, and refuses a text comparison" {
    $c = Get-SkillFile $page
    if ($c -notmatch '(?i)regenerat\w+ (each index )?and compar') { throw 'the page does not name regenerate-and-compare' }
    if ($c -notmatch '(?i)nothing to compare') { throw 'the page does not say why a text comparison does not apply' }
    $true
  }

  # No row, and said rather than left to a reader who would otherwise wonder
  # whether it was forgotten.
  Assert "the migration carries no row for the script, and /configure says why" {
    if ((Get-SkillFile 'configure/MIGRATION.md') -match '(?i)regenerate-indexes') {
      throw 'the migration converts a script no earlier version ever installed'
    }
    # Anchored to the subject — the migration file and the absent row — rather
    # than to the pronoun it originally matched, which broke the moment a second
    # script made "it" into "them". A guard written from its author's wording
    # tracks the wording, not the claim.
    if ((Get-SkillFile 'configure/SKILL.md') -notmatch '(?i)MIGRATION\.md[^\r\n]*no row') {
      throw '/configure does not say the migration carries no row for the derived scripts'
    }
    $true
  }
}

# --- ticket declared-fields/08 — a local ticket declares its lifecycle facts --

# Every ticket file this repository holds. The forge form is a different shape
# and is not swept: nothing here is a claim about issues on GitHub.
function Get-LocalTicketFile {
  $efforts = Join-Path $repo '.claude/tickets'
  if (-not (Test-Path $efforts)) { return @() }
  @(Get-ChildItem $efforts -Directory | ForEach-Object {
    $issues = Join-Path $_.FullName 'issues'
    if (Test-Path $issues) { Get-ChildItem $issues -File -Filter '*.md' }
  })
}

Describe-Ticket 'declared-fields/08' 'a local ticket declares its lifecycle facts as fields' {

  # Anchored on the retired forms themselves rather than on anything this ticket
  # wrote, for the reason `.claude/rules/skills.md` gives: a guard built from the
  # new phrasing cannot see a restatement that predates it.
  Assert "no ticket states a lifecycle fact as a prose line" {
    $offenders = @()
    foreach ($t in Get-LocalTicketFile) {
      $body = Get-BodyBelowFrontmatter (Get-Content $t.FullName -Raw)
      # Fenced blocks masked, as the H1 sweep beside this one does: a ticket
      # quoting the retired form inside an example is showing it, not using it,
      # and the two sweeps disagreeing would make one of them a false positive.
      $unfenced = [regex]::Replace($body, '(?ms)^```.*?^```', { param($f) ($f.Value -replace '[^\r\n]', '.') })
      $m = [regex]::Match($unfenced, '(?m)^(Status|Blocked by|Part of|Superseded by|Type):')
      if ($m.Success) { $offenders += "$($t.Name): $($m.Groups[1].Value)" }
    }
    if ($offenders) { throw "declared as prose in: $($offenders -join ', ')" }
    $true
  }

  # Nothing checked the title at all until review found the consequence: the
  # conversion left the id restated inside `title` on 22 files — `01 — feat(…)`
  # — in the same diff that wrote "the id is the filename, so it is not restated
  # inside". A field the format requires and nothing asserts is untested by
  # construction, and this is what that costs.
  Assert "every ticket declares a title, and never restates the id in it" {
    $offenders = @()
    foreach ($t in Get-LocalTicketFile) {
      $fm = Get-Frontmatter (Get-Content $t.FullName -Raw)
      if (-not $fm) { $offenders += "$($t.Name): no frontmatter"; continue }
      $m = [regex]::Match($fm, '(?m)^title:[ \t]*(\S.*)$')
      if (-not $m.Success) { $offenders += "$($t.Name): no title field"; continue }
      if ($m.Groups[1].Value -match '^\d{2}\s*[—-]') { $offenders += "$($t.Name): the id is restated in the title" }
    }
    if ($offenders) { throw ($offenders -join ', ') }
    $true
  }

  # ADR 0058 drops the heading, so a ticket opens at its first section. Scoped
  # below the frontmatter and outside fenced blocks — `tenure/15` shows a tool
  # guide's own `# ` heading inside an example, which is content, not a title.
  Assert "no ticket carries an H1 — the title is the field" {
    $offenders = @()
    foreach ($t in Get-LocalTicketFile) {
      $body = Get-BodyBelowFrontmatter (Get-Content $t.FullName -Raw)
      $unfenced = [regex]::Replace($body, '(?ms)^```.*?^```', { param($f) ($f.Value -replace '[^\r\n]', '.') })
      if ($unfenced -match '(?m)^#[ \t]') { $offenders += $t.Name }
    }
    if ($offenders) { throw "an H1 survives in: $($offenders -join ', ')" }
    $true
  }

  # The union in the tracker policy, not a narrowed set: the build lifecycle and
  # the triage roles both live in one field here, which that policy records as a
  # deliberate wrinkle. `superseded` joined the lifecycle in this ticket because
  # nine files already used it under ADR 0030 and nothing defined it (ADR 0008).
  Assert "every ticket declares a status the policies define" {
    # Both copies, because ADR 0025 makes the template the one that leads and
    # deleting the fifth state from it alone left the whole suite green.
    foreach ($copy in (Get-SkillFile 'configure/policies/tickets.template.md'),
                      (Get-Content (Join-Path $repo '.claude/policies/tickets.md') -Raw)) {
      if ($copy -notmatch '(?m)^superseded[ \t]') { throw 'a format copy does not define the superseded state' }
    }
    $lifecycle = @([regex]::Matches(
      (Get-Content (Join-Path $repo '.claude/policies/tickets.md') -Raw),
      # One space, not two: the block pads the shorter words to align, and
      # `superseded` is the longest, so requiring alignment would have excluded
      # exactly the state this ticket added.
      '(?m)^(open|blocked|resolved|obsolete|superseded)[ \t]') | ForEach-Object { $_.Groups[1].Value })
    if ($lifecycle.Count -lt 5) { throw "the lifecycle block defines only: $($lifecycle -join ', ')" }
    $roles = @([regex]::Matches(
      (Get-Content (Join-Path $repo '.claude/policies/tracker.md') -Raw),
      '(?m)^\|\s*`?([a-z-]+)`?\s*\|\s*`([a-z-]+)`\s*\|') | ForEach-Object { $_.Groups[2].Value })
    # The roles half is asserted non-empty rather than merely collected: no
    # ticket carries a triage role today, so a derivation that silently
    # collapsed to nothing would narrow the union invisibly.
    if ($roles.Count -lt 2) { throw "the tracker policy's role table yielded only: $($roles -join ', ')" }
    $vocabulary = @($lifecycle + $roles | Sort-Object -Unique)
    $offenders = @()
    foreach ($t in Get-LocalTicketFile) {
      $fm = Get-Frontmatter (Get-Content $t.FullName -Raw)
      if (-not $fm) { $offenders += "$($t.Name): no frontmatter"; continue }
      $m = [regex]::Match($fm, '(?m)^status:[ \t]*(\S+)')
      if (-not $m.Success) { $offenders += "$($t.Name): no status field"; continue }
      if ($vocabulary -notcontains $m.Groups[1].Value) { $offenders += "$($t.Name): $($m.Groups[1].Value)" }
    }
    if ($offenders) { throw "a status the policies do not define: $($offenders -join ', ')" }
    $true
  }

  # A list, so the `—` sentinel disappears rather than being parsed. `[]` is the
  # positive statement, which is why an absent field is refused rather than read
  # as unblocked — the two are the same fact and only one is checkable.
  Assert "every ticket declares blocked-by as a list, and the sentinel is gone" {
    $offenders = @()
    foreach ($t in Get-LocalTicketFile) {
      $fm = Get-Frontmatter (Get-Content $t.FullName -Raw)
      if (-not $fm) { $offenders += "$($t.Name): no frontmatter"; continue }
      if ($fm -notmatch '(?m)^blocked-by:[ \t]*\[[^\]]*\][ \t]*$') { $offenders += "$($t.Name): not an inline list" }
      if ($fm -match '(?m)^blocked-by:.*—') { $offenders += "$($t.Name): the em-dash sentinel survives" }
    }
    if ($offenders) { throw ($offenders -join ', ') }
    $true
  }

  # A superseded ticket forwards. Without this the state and its forwarding are
  # independent, and a reader of the index learns a ticket is dead without
  # learning what replaced it — which is the whole distinction from `obsolete`.
  Assert "a superseded ticket names what replaced it" {
    $offenders = @()
    foreach ($t in Get-LocalTicketFile) {
      $fm = Get-Frontmatter (Get-Content $t.FullName -Raw)
      if (-not $fm -or $fm -notmatch '(?m)^status:[ \t]*superseded[ \t]*$') { continue }
      if ($fm -notmatch '(?m)^superseded-by:[ \t]*\S') { $offenders += $t.Name }
    }
    if ($offenders) { throw "superseded without naming a replacement: $($offenders -join ', ')" }
    $true
  }

  # The asymmetry ADR 0058 decided, and the half most easily lost: a forge owns
  # the lifecycle natively, so frontmatter there would be a second home for what
  # the forge already knows. Both format copies, because ADR 0025 orders them.
  Assert "the ticket format keeps the forge form free of frontmatter" {
    $copies = @{
      'the shipped template' = Get-SkillFile 'configure/policies/tickets.template.md'
      'this repository'      = Get-Content (Join-Path $repo '.claude/policies/tickets.md') -Raw
    }
    foreach ($name in $copies.Keys) {
      $c = $copies[$name]
      # Scoped to the paragraph making the claim. File-wide, the reason check
      # passed on an unrelated "second home" elsewhere in the same policy —
      # a phrase travelling near the subject rather than stating it.
      $para = [regex]::Match(($c -replace "`r", ''), '(?m)^.*local[- ]markdown form.*$').Value
      if (-not $para) { throw "$name`: the fields are not scoped to the local form" }
      if ($para -notmatch '(?i)(second home|noise in its issue UI)') {
        throw "$name`: why the forge form stays as it is goes unsaid"
      }
      # File-wide, because review put the offending sentence one line below the
      # paragraph and it passed. Co-occurrence alone cannot be the test: the
      # paragraph that *forbids* forge frontmatter necessarily mentions both.
      # So every sentence naming the forge and frontmatter together must also
      # negate — a prohibition reads differently from a claim, and that is the
      # difference being checked.
      foreach ($sentence in (($c -replace "`r", '') -split '(?<=\.)\s+')) {
        if ($sentence -notmatch '(?i)GitHub|forge') { continue }
        if ($sentence -notmatch '(?i)frontmatter') { continue }
        if ($sentence -notmatch '(?i)\b(would be|never|not|no|rather than|instead)\b') {
          throw "$name`: the forge form is described as carrying frontmatter: $($sentence.Trim())"
        }
      }
    }
    $true
  }
}

# --- placement — everything AEP owns lives under .claude/ ---------------------

# No ticket, and that is the policy rather than an omission: this is a convention
# changed in conversation, which `.claude/policies/version-control.md` names as
# the second caller `/commit` serves — a branch and a commit like any other,
# carrying no `Refs:` because there is no ticket file to cite. The id below is
# therefore the change's name, not a ticket's.
Describe-Ticket 'placement' 'everything AEP owns lives under .claude/, and only CLAUDE.md at the root' {

  # Copied as-is, like the other two unconditional rules. Compared whole rather
  # than by a phrase: the point of an as-is copy is that there is no filling in,
  # and a phrase check would pass on an installed copy that had quietly diverged.
  Assert "the placement rule ships as a template and is installed unchanged" {
    $template = Get-SkillFile 'configure/placement.template.md'
    $installed = Get-Content (Join-Path $repo '.claude/rules/placement.md') -Raw
    if (($template -replace "`r", '') -cne ($installed -replace "`r", '')) {
      throw 'the installed rule and its template have diverged'
    }
    $true
  }

  # Anchored on the three nouns the rule is *about* rather than on the sentences
  # this pass happened to write, which review named as the shape that can only
  # detect a rewording of itself. Both homes, because the first version of this
  # rule named one — it said everything AEP owns is under `.claude/`, and its own
  # removal test then classified `skills/` and `agents/` as owing a move. This
  # repository would have loaded a rule its own tree violates, every turn.
  Assert "the rule names both homes and CLAUDE.md as the only entry outside them" {
    $c = Get-SkillFile 'configure/placement.template.md'
    # Not `$home` — PowerShell reserves it, and the failure reads as a variable
    # error rather than as the assertion this is.
    foreach ($place in 'plugin', '`\.claude/`') {
      if ($c -notmatch "(?i)$place") { throw "the rule does not name the $($place -replace '\\|`', '') home" }
    }
    if ($c -notmatch 'CLAUDE\.md') { throw 'the root entry is not named' }
    if ($c -notmatch '(?i)only entry|only .{0,30}outside|one exception') {
      throw 'the root entry is not stated as the only one'
    }
    $true
  }

  # The distinction the rule turns on, and the one a reader is most likely to get
  # wrong: a file is placed by whose process it serves, not by what it is.
  # `scripts/verify.ps1` stays where it is because it tests what this repository
  # builds — it would still have a reason to exist with AEP removed.
  Assert "the rule places a file by whose process it serves" {
    $c = Get-SkillFile 'configure/placement.template.md'
    if ($c -notmatch '(?i)whose process') { throw 'the test is not stated' }
    if ($c -notmatch '(?i)were AEP removed|if AEP were removed') { throw 'the removal question is not stated' }
    $true
  }

  Assert "AEP's own script lives under .claude/scripts/, not at the root" {
    if (-not (Test-Path (Join-Path $repo '.claude/scripts/regenerate-indexes.ps1'))) {
      throw 'the regenerator is not under .claude/scripts/'
    }
    if (Test-Path (Join-Path $repo 'scripts/regenerate-indexes.ps1')) {
      throw 'the regenerator is still at the root'
    }
    $true
  }

  # The regression guard. Each of these is a directory or file AEP installs, and
  # finding one at the root means a copy was created there rather than moved —
  # the failure this rule exists to make loud.
  Assert "no directory AEP owns has appeared at the repository root" {
    $owned = @('protocol.md', 'rules', 'contexts', 'decisions', 'policies',
               'modes', 'tools', 'evidence', 'tickets', 'designs', 'position')
    $offenders = @($owned | Where-Object { Test-Path (Join-Path $repo $_) })
    if ($offenders) { throw "AEP-owned entries at the root: $($offenders -join ', ')" }
    $true
  }
}

# --- ticket entry/01 — a request states where it enters -----------------------

Describe-Ticket 'entry/01' 'a request states where it enters, and planning is selectable' {

  # ADR 0025: the template moves before the installed copy, and both in the same
  # change. Compared on the rule rather than whole, unlike the placement rule
  # above — that one is copied as-is, while this repository's CLAUDE.md carries
  # sections the template never had, so a whole-file comparison would assert
  # something that was never true and would have to be relaxed on first run.
  Assert "the entry rule ships in the template and is installed here" {
    $pair = [ordered]@{
      'template'            = Get-SkillFile $claudeTemplate
      'installed CLAUDE.md' = Get-Content (Join-Path $repo 'CLAUDE.md') -Raw
    }
    foreach ($where in $pair.Keys) {
      if ($pair[$where] -notmatch '(?i)enters? that stage') { throw "the $where does not carry the entry rule" }
      if ($pair[$where] -notmatch '(?i)which stage it enters') { throw "the $where does not add the entry to the classification line" }
    }
    $true
  }

  # A rule that says "enter the right stage" and names none is advice. The mapping
  # is what makes it followable — and it belongs in the router rather than beside
  # the obligation, because it names commands and nothing in the always-on tier
  # may assume a command exists. That constraint is asserted by tenure/20 and
  # streamline/02; this asserts the table landed somewhere it is allowed to be.
  Assert "the router carries the table the entry rule states from" {
    foreach ($c in (Get-SkillFile 'configure/protocol.template.md'),
                   (Get-Content (Join-Path $repo '.claude/protocol.md') -Raw)) {
      foreach ($dest in '/implement', '/triage', '/design') {
        if ($c -notmatch [regex]::Escape($dest)) { throw "the table names no destination $dest" }
      }
      if ($c -notmatch '(?i)first match wins') { throw 'the table does not say how it is read' }
      if ($c -notmatch '(?i)read rather than judged') { throw 'the table does not say which rows are lookups' }
    }
    $true
  }

  # The always-on tier keeps the obligation and hands off the lookup. Asserted
  # from the other side too: a tier that named a destination would pass every
  # check above while breaking the no-command constraint, and the two failures
  # would be reported far from this ticket.
  Assert "the always-on tier states the obligation and names no destination" {
    $c = Get-SkillFile $claudeTemplate
    if ($c -notmatch '(?i)the router') { throw 'does not hand off to the router' }
    foreach ($dest in '/implement', '/triage', '/design') {
      if ($c -match [regex]::Escape($dest)) { throw "the always-on tier names $dest" }
    }
    $true
  }

  # A single-home guard is only worth having if it can fire. Asserted rather than
  # confirmed by hand once, because the hand check is not repeated when the rule
  # is later reworded: it must match the one home, and must *not* match the stage
  # that legitimately applies the rule two files away — which is exactly the
  # guard-that-cannot-discriminate shape `.claude/rules/skills.md` says to assume
  # you have just written.
  Assert "the entry-route guard tells its home from an application of it" {
    $pattern = $rulePattern['the entry-route rule']
    if ((Get-SkillFile $claudeTemplate) -notmatch $pattern) { throw 'does not match its own home' }
    if ((Get-SkillFile 'implement/SKILL.md') -match $pattern) { throw '/implement matches it, but applies the rule rather than restating it' }
    $true
  }

  # The round trip this ticket exists to remove: the build stage finds no ticket
  # and answers with the name of a command. Both sites — the untriaged issue, and
  # the invocation that carried a request rather than a ticket.
  Assert "/implement enters planning rather than naming it" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)enter\s+`?/design`?') { throw 'never states that it enters /design' }
    if ($c -match '(?i)route it to `/design`') { throw 'still hands the route back as an instruction to type' }
    $true
  }

  # The specification is amended in the same change as the framework (ADR 0029).
  Assert "the specification describes how the entry stage is determined" {
    $c = Get-Content (Join-Path $repo 'specs.md') -Raw
    if ($c -notmatch '(?i)entry stage is determined') { throw 'does not describe entry determination' }
    if ($c -notmatch '(?i)boot tier and nowhere else') { throw 'does not place the rule in the boot tier' }
    $true
  }

  # Until this ticket the axis test existed only as a comment beside the
  # invocation assertions — a home no reader deciding how to author a skill would
  # think to open. It has a real one now, and this checks the comment points
  # rather than keeping the second copy that made it drift-prone.
  Assert "the invocation-axis test is stated in context, not beside the assertions" {
    $ctx = Get-Content (Join-Path $repo '.claude/contexts/skill-authoring.md') -Raw
    if ($ctx -notmatch '(?i)fire from a description of the problem') { throw 'the context does not state the axis test' }
    $self = Get-Content (Join-Path $repo 'scripts/verify.ps1') -Raw
    if ($self -match '(?im)^\s*#.{0,90}the two that must fire from a description') {
      throw 'this suite still restates the axis test in a comment'
    }
    $true
  }
}

# --- ticket entry/02 — the build runs on to the next unblocked ticket ---------

Describe-Ticket 'entry/02' 'the build runs on to the next unblocked ticket' {

  # Continuation belongs to the set, not to a named ticket. Both directions are
  # asserted: a stage that continued after being handed one ticket would be
  # choosing work it was not given, which is the rule step 1 already carries.
  Assert "continuation belongs to the invocation that named nothing" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)next open, unblocked, unclaimed ticket') { throw 'never states that it takes the next ticket' }
    if ($c -notmatch '(?i)named a ticket, the run ends here') { throw 'does not end the run after a ticket it was handed' }
    $true
  }

  # The bound is ADR 0062's: the plan's own declared increments, and nothing this
  # stage invented. Each stop is asserted by name, because a list that lost one
  # would still read as a list — and the one most likely to go is the undeclared
  # decision, which is the oldest of them and the least specific to this ticket.
  Assert "continuation stops where the plan says a human is needed" {
    $c = Get-SkillFile 'implement/SKILL.md'
    foreach ($stop in 'HITL type', 'discovered undeclared', 'is blocked', 'fails', 'nothing unblocked remains') {
      if ($c -notmatch [regex]::Escape($stop)) { throw "the stop conditions omit: $stop" }
    }
    if ($c -notmatch '(?i)AFK increment does not stop it') { throw 'does not say an AFK increment carries on' }
    if ($c -notmatch '(?i)invents no bound of its own') { throw 'does not refuse a bound of its own' }
    $true
  }

  # The failure a continued run makes newly possible: verifying once and building
  # four tickets on that reading, which is the startup scan this workflow does not
  # have. Nothing else in the skill would catch it, because each ticket's own
  # section reads correctly in isolation.
  Assert "every ticket in a continued run opens with its own verification" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)verification report opens every ticket') { throw 'does not require a report per ticket' }
    $true
  }

  # A run that lands four of six and reports the fourth is true about the ticket
  # and false about the run. Nothing else in this workflow ends partially, so a
  # reader has no habit to fall back on.
  Assert "a continued run reports the run rather than its last ticket" {
    $c = Get-SkillFile 'implement/SKILL.md'
    if ($c -notmatch '(?i)report the run, not the last ticket') { throw 'does not require a run-level report' }
    if ($c -notmatch '(?i)why the run stopped') { throw 'does not require the stopping reason' }
    $true
  }

  # specs.md is normative and is amended in the same change (ADR 0029), and its
  # own evolution rule requires the amendment to be a Decision with a version bump.
  Assert "the specification carries continuation, its Decision, and a bumped version" {
    $c = Get-Content (Join-Path $repo 'specs.md') -Raw
    if ($c -notmatch '(?i)runs on past the one it delivered') { throw 'the spec does not describe continuation' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    # Was pinned to the release current when this ticket landed, which made every
    # later release fail here with a message about an amendment that was fine.
    # What the criterion actually wanted is that the spec is at a released
    # version, which is the manifest's — not a particular number.
    $running = (Get-Content (Join-Path $repo '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json).version
    if ($c -notmatch ('(?im)^\*\*Version:\*\*\s*' + [regex]::Escape($running) + '\s*$')) {
      throw "the version was not bumped for the amendment: spec disagrees with the manifest's $running"
    }
    $true
  }

  # Supersession is written at both ends or not at all (ADR-format rule). Neither
  # of this effort's ADRs supersedes anything, so what is checked is that they
  # declare the pair rather than omitting the fields.
  Assert "this effort's Decisions declare the routing and supersession fields" {
    foreach ($n in '0061-unplanned-work-enters-the-spine-from-the-boot-tier',
                   '0062-continuation-is-bounded-by-the-plans-declared-increments') {
      $p = Join-Path $repo ".claude/decisions/$n.md"
      if (-not (Test-Path $p)) { throw "missing: $n" }
      $fm = Get-Content $p -Raw
      foreach ($field in 'status', 'load-when', 'sources', 'supersedes', 'superseded-by') {
        if ($fm -notmatch "(?m)^$field\s*:") { throw "$n declares no $field" }
      }
    }
    $true
  }
}

# --- ticket axis/01 — work arriving from outside reaches its stage unasked ----

Describe-Ticket 'axis/01' 'work arriving from outside reaches its stage unasked' {

  foreach ($s in 'triage', 'survey') {
    Assert "/$s is model-invoked — it is reached by describing the problem" {
      if (Test-UserInvoked "$s/SKILL.md") { throw 'still withheld from selection' }
      $true
    }
  }

  # The guard whose absence made ADR 0063 necessary. The entry table and the
  # invocation axis were two expressions of one fact and nothing compared them,
  # so a row could name a destination the model is structurally unable to enter
  # — which is exactly what shipped. Read from the template, because that is the
  # copy every configured repository receives.
  Assert "every destination the entry table names is one the model may select" {
    $section = Get-Section (Get-SkillFile $protocolTemplate) 'Which stage a request enters'
    if (-not $section) { throw 'the entry table is gone' }
    $withheld = @()
    foreach ($line in [regex]::Matches($section, '(?m)^\|[^|\r\n]*\|([^|\r\n]*)\|\s*$')) {
      foreach ($d in [regex]::Matches($line.Groups[1].Value, '`/([a-z-]+)`')) {
        $name = $d.Groups[1].Value
        # A destination with no skill of that name is a different defect and is
        # reported as one, rather than passing because Test-UserInvoked said no.
        if (-not (Test-Path (Join-Path $skills "$name/SKILL.md"))) { $withheld += "$name (no such skill)" }
        elseif (Test-UserInvoked "$name/SKILL.md") { $withheld += $name }
      }
    }
    if ($withheld) { throw "named as a destination but unenterable: $(($withheld | Sort-Object -Unique) -join ', ')" }
    $true
  }

  Assert "the installed entry table names the same destinations as the shipped one" {
    $a = Get-Section (Get-SkillFile $protocolTemplate) 'Which stage a request enters'
    $b = Get-Section (Get-Content (Join-Path $repo '.claude/protocol.md') -Raw) 'Which stage a request enters'
    if (-not $b) { throw 'the installed copy has no entry table' }
    $names = { param($t) ,@([regex]::Matches($t, '`/([a-z-]+)`') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique) }
    if (((& $names $a) -join ',') -ne ((& $names $b) -join ',')) { throw 'the two tables route differently' }
    $true
  }

  # Triage declared a guide and had no row. The containment check that should
  # have caught it iterates the spine, and triage is not part of it — so the
  # declaration and the table drifted with nothing watching.
  Assert "the router's stage table carries a row for triage" {
    foreach ($t in @($protocolTemplate, $null)) {
      $text = if ($t) { Get-SkillFile $t } else { Get-Content (Join-Path $repo '.claude/protocol.md') -Raw }
      $section = Get-Section $text 'Which guides each stage reads'
      $row = [regex]::Match($section, '(?m)^\|\s*`/triage`\s*\|([^|\r\n]*)\|([^\r\n]*)\|\s*$')
      if (-not $row.Success) { throw "no /triage row in $(if ($t) { 'the template' } else { 'the installed copy' })" }
      if ($row.Groups[2].Value -notmatch 'tracker\.md') { throw 'the row omits the guide triage declares' }
    }
    $true
  }

  # For a model-invoked skill the description is the whole basis of selection,
  # and the two crossings sit next to stages that answer adjacent questions. A
  # description that says only when to fire will fire on the neighbour too.
  foreach ($s in 'triage', 'survey') {
    Assert "/$s says what it is not for, not only what it is for" {
      $d = [regex]::Match((Get-SkillFile "$s/SKILL.md"), '(?m)^description:\s*(.+)$')
      if (-not $d.Success) { throw 'no description' }
      if ($d.Groups[1].Value -notmatch '(?i)\bnot for\b') { throw 'the description states no exclusion' }
      if ($d.Groups[1].Value -notmatch '/design') { throw 'the neighbouring stage is not named' }
      $true
    }
  }

  Assert "a Decision records the reversal, its source, and the test that exempts the rest" {
    $p = Join-Path $repo '.claude/decisions/0063-two-on-ramps-cross-to-selection-and-the-exemption-is-one-test.md'
    if (-not (Test-Path $p)) { throw 'the Decision is missing' }
    $c = Get-Content $p -Raw
    if ($c -notmatch [regex]::Escape('.claude/tickets/entry/spec.md')) { throw 'it does not cite the spec line it reverses' }
    if ($c -notmatch '(?is)Considered Options') { throw 'it weighs no alternatives' }
    if ($c -notmatch '(?is)subject is not the repository') { throw 'the exemption is a list rather than a test' }
    $true
  }
}

# --- ticket axis/02 — the router explains the workflow instead of routing -----

Describe-Ticket 'axis/02' 'the router explains the workflow instead of routing to it' {

  $rt = Get-SkillFile 'help/SKILL.md'

  # The failure mode this crossing newly risks. "How does this work" and "how do
  # I use this" are one sentence apart, and the second is the only one it should
  # answer — a description that says when to fire and not when to stay out will
  # open an explanation of the workflow every time somebody asks about the code.
  Assert "/help's description excludes questions about the repository itself" {
    $d = [regex]::Match($rt, '(?m)^description:\s*(.+)$')
    if (-not $d.Success) { throw 'no description' }
    $v = $d.Groups[1].Value
    if ($v -notmatch '(?i)\bnot for\b') { throw 'no exclusion is stated' }
    if ($v -notmatch '(?i)(repositor|code|architecture)') { throw 'the exclusion does not name what it excludes' }
    $true
  }

  # The claim the boot tier took over. Left standing, the file tells a reader to
  # type the one command the entry rule exists to make unnecessary — and it said
  # exactly that until this ticket, having gone stale the day planning crossed.
  Assert "nothing in the router claims a stage is typed by habit" {
    if ($rt -match '(?i)typed by habit') {
      $line = @(($rt -split '\r?\n') | Where-Object { $_ -match '(?i)typed by habit' })
      foreach ($l in $line) {
        if ($l -match '(?i)/design|/help') { throw "a superseded claim survives: $($l.Trim())" }
      }
    }
    $true
  }

  Assert "the router states that describing the work reaches the stage" {
    # Bounded by the line rather than the sentence: a filename in the span ends
    # a `[^.]` window early, and the sentence this looks for cites `CLAUDE.md`.
    if ($rt -notmatch '(?i)\bdescrib\w+[^\r\n]{0,220}\b(enters|routes|reaches)\b') {
      throw 'the router never says work routes itself'
    }
    $true
  }

  # Named, and named with the test rather than as a pair — a list of two invites
  # a third that resembles them, and the whole point of ADR 0063's phrasing is
  # that an exemption can be failed rather than joined.
  Assert "the two skills that stay typed are named with the test that exempts them" {
    foreach ($s in '/configure', '/handoff') {
      if ($rt -notmatch [regex]::Escape($s)) { throw "$s is not named as typed" }
    }
    if ($rt -notmatch '(?is)subject is not the repository') { throw 'the exemption is a list, not a test' }
    $true
  }

  # The router indexes every skill, and two of them just moved across the axis.
  # An entry that still reads as "type this" for a skill the workflow now selects
  # is the same staleness this ticket removed from one line, surviving in another.
  Assert "no entry instructs the reader to type a skill the workflow now selects" {
    $selected = @('triage', 'survey', 'design')
    $entries = @(($rt -split '\r?\n') | Where-Object { $_ -match '^- \*\*' })
    foreach ($s in $selected) {
      $e = @($entries | Where-Object { $_ -match [regex]::Escape("/$s``") })
      foreach ($line in $e) {
        if ($line -match '(?i)\btype (it|this|/)') { throw "/$s's entry still tells the reader to type it" }
      }
    }
    $true
  }
}

# --- ticket axis/03 — the taxonomy names its categories, and a spent guard goes --

Describe-Ticket 'axis/03' 'the taxonomy names its third category, and a spent guard goes' {

  $ctx = Get-Content (Join-Path $repo '.claude/contexts/skill-authoring.md') -Raw

  foreach ($term in 'Spine', 'Primitive', 'On-ramp', 'Router') {
    Assert "the knowledge layer defines $term" {
      if ($ctx -notmatch "(?m)^\*\*$([regex]::Escape($term))\*\*:") { throw "$term is not defined" }
      $true
    }
  }

  # The check the missing definition made impossible. A category that exists only
  # in a ticket and a status file has nothing to be measured against, which is
  # how one of them came to answer the invocation question two different ways.
  Assert "every skill in the tree belongs to exactly one named category" {
    $named = @{}
    foreach ($term in 'Spine', 'Primitive', 'On-ramp', 'Router') {
      $def = [regex]::Match($ctx, "(?ms)^\*\*$([regex]::Escape($term))\*\*:\r?\n(.*?)(?=^_Avoid_)")
      if (-not $def.Success) { throw "$term has no body" }
      # The membership list is the first sentence; everything after it is
      # commentary that names other skills in passing. Reading the whole body
      # filed `/configure` under Primitive, off a clause about the directory
      # that replaced the `tools` primitive.
      $enumeration = ($def.Groups[1].Value -split '(?<=\.)[\s]', 2)[0]
      foreach ($m in [regex]::Matches($enumeration, '`/?([a-z][a-z-]+)`')) {
        $n = $m.Groups[1].Value
        if (Test-Path (Join-Path $skills "$n/SKILL.md")) {
          if ($named.ContainsKey($n)) { $named[$n] += ", $term" } else { $named[$n] = $term }
        }
      }
    }
    $all = @(Get-ChildItem $skills -Directory |
      Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } | ForEach-Object { $_.Name })
    $unfiled = @($all | Where-Object { -not $named.ContainsKey($_) })
    $twice = @($named.Keys | Where-Object { $named[$_] -match ',' } | ForEach-Object { "$_ ($($named[$_]))" })
    if ($unfiled) { throw "in no category: $($unfiled -join ', ')" }
    if ($twice) { throw "in two categories: $($twice -join '; ')" }
    $true
  }

  # `declared-fields/02` deleted the prose form from every skill and left the
  # containment assertion that read it in place, iterating seven stages, hitting
  # its `continue` on all seven and returning success. Anchored to that check by
  # name rather than to the pattern: one *live* guard still matches the prose
  # form deliberately, to keep it from coming back, and a pattern-wide ban would
  # delete the guard along with the corpse.
  Assert "the dead containment assertion is gone, and its live successor is not" {
    $self = Get-Content (Join-Path $repo 'scripts/verify.ps1') -Raw
    # Assembled at runtime from halves. A guard that searches this file for a
    # literal finds its own search string and passes forever — which is the same
    # class of silently-green check the deleted assertion was.
    $dead = 'the table carries at least ' + 'every policy'
    $live = 'declares exactly what the routing ' + 'table routes to it'
    if ($self -match [regex]::Escape($dead)) {
      throw 'the assertion that measured nothing is still here'
    }
    if ($self -notmatch [regex]::Escape($live)) {
      throw 'the successor that replaced it is gone too'
    }
    $true
  }

  Assert "streamline/08 is superseded with a reason, and not deleted" {
    $p = Join-Path $repo '.claude/tickets/streamline/issues/08-configure-writes-the-new-layout.md'
    if (-not (Test-Path $p)) { throw 'the ticket was deleted rather than marked' }
    $c = Get-Content $p -Raw
    if ($c -notmatch '(?m)^status:\s*superseded\s*$') { throw 'it is not marked superseded' }
    if ($c -notmatch '(?is)superseded by[^.]{0,80}layout') { throw 'no reason names what superseded it' }
    $true
  }

  # Named `axis` as the live effort when it was the live effort, which made the
  # next effort's first open ticket a failure. Liveness is a property of the
  # effort's spec, not a name — an open ticket under a spec that is not yet
  # `implemented` is work in progress; one under an implemented spec is the
  # stranded frontier entry this ticket existed to clear.
  Assert "no open ticket is stranded under an implemented spec" {
    $stale = @()
    foreach ($f in Get-ChildItem (Join-Path $repo '.claude/tickets') -Recurse -Filter '*.md') {
      if ($f.FullName -notmatch 'issues') { continue }
      if ((Get-Content $f.FullName -Raw) -notmatch '(?m)^status:\s*open\s*$') { continue }
      $spec = Join-Path $f.Directory.Parent.FullName 'spec.md'
      if (-not (Test-Path $spec)) { $stale += $f.Name; continue }
      if ((Get-Content $spec -Raw) -match '(?m)^status:\s*implemented\s*$') { $stale += $f.Name }
    }
    if ($stale) { throw "open under a finished effort: $($stale -join ', ')" }
    $true
  }
}

# --- ticket axis/04 — the protocol records the release it was written by ------

Describe-Ticket 'axis/04' 'the protocol records the release it was written by' {

  $hookDir = Join-Path $repo 'hooks'
  $script  = Join-Path $hookDir 'check-version.js'

  Assert "both protocol copies declare the release as a field" {
    foreach ($p in @((Join-Path $repo '.claude/protocol.md'), (Join-Path $skills 'configure/protocol.template.md'))) {
      $fm = Get-Frontmatter (Get-Content $p -Raw)
      if (-not $fm) { throw "$(Split-Path -Leaf $p) has no frontmatter" }
      if ($fm -notmatch '(?m)^aep-version:[ \t]*(\S+)[ \t]*$') { throw "$(Split-Path -Leaf $p) declares no aep-version" }
    }
    $true
  }

  # The three version literals are one fact. A release that moves the manifest
  # and not the template ships a plugin that stamps every repository it
  # configures with a release that is already behind — and the hook would then
  # warn about a repository it had just written.
  Assert "the manifest, the specification and the template agree on the release" {
    $manifest = (Get-Content (Join-Path $repo '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json).version
    $spec = [regex]::Match((Get-Content (Join-Path $repo 'specs.md') -Raw), '(?m)^\*\*Version:\*\*\s*(\S+)\s*$').Groups[1].Value
    $tpl = [regex]::Match((Get-Frontmatter (Get-SkillFile 'configure/protocol.template.md')), '(?m)^aep-version:[ \t]*(\S+)[ \t]*$').Groups[1].Value
    $seen = @($manifest, $spec, $tpl) | Sort-Object -Unique
    if ($seen.Count -ne 1) { throw "manifest $manifest, spec $spec, template $tpl" }
    $true
  }

  Assert "the hook is registered on SessionStart, in exec form" {
    $p = Join-Path $hookDir 'hooks.json'
    if (-not (Test-Path $p)) { throw 'hooks/hooks.json is missing' }
    $h = Get-Content $p -Raw | ConvertFrom-Json
    $entry = $h.hooks.SessionStart[0].hooks[0]
    if (-not $entry) { throw 'no SessionStart hook is registered' }
    # Exec form, and `node` specifically. Shell form resolves to `sh -c` on Unix
    # and Git Bash *or* PowerShell on Windows, so one script could not serve both.
    if ($entry.command -ne 'node') { throw "spawns '$($entry.command)', not node — shell form is not portable here" }
    if (-not $entry.args) { throw 'no args array, which makes this shell form' }
    if ($entry.args[0] -notmatch '\$\{CLAUDE_PLUGIN_ROOT\}') { throw 'the script path is not anchored to the plugin root' }
    $true
  }

  Assert "the hook ships inside the plugin and installs nothing into a repository" {
    if (-not (Test-Path $script)) { throw 'hooks/check-version.js is missing' }
    # ADR 0060: a configured repository must stay useful without the plugin, so
    # nothing may be copied in and nothing committed may point at the plugin.
    $proto = Get-Content (Join-Path $repo '.claude/protocol.md') -Raw
    if ($proto -match 'CLAUDE_PLUGIN_ROOT') { throw 'the installed protocol names a plugin path' }
    if (Test-Path (Join-Path $repo '.claude/scripts/check-version.js')) { throw 'the hook was installed into the repository' }
    $true
  }

  # Behaviour, run rather than read. Each branch is a real invocation against a
  # temporary tree, because the whole value of this hook is that it stays quiet —
  # and a check that only reads the source cannot tell silence from absence.
  Assert "the hook is silent when the releases match, and speaks when they differ" {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'node is not on PATH; the exec-form hook cannot run' }
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path (Join-Path $tmp '.claude') -Force | Out-Null
    try {
      $run = {
        param($declared)
        if ($null -eq $declared) { "# no frontmatter" | Set-Content (Join-Path $tmp '.claude/protocol.md') }
        else { "---`naep-version: $declared`n---`n" | Set-Content (Join-Path $tmp '.claude/protocol.md') }
        $env:CLAUDE_PLUGIN_ROOT = $repo
        $env:CLAUDE_PROJECT_DIR = $tmp
        $out = & node $script 2>&1 | Out-String
        $env:CLAUDE_PLUGIN_ROOT = $null
        $env:CLAUDE_PROJECT_DIR = $null
        $out.Trim()
      }
      $running = (Get-Content (Join-Path $repo '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json).version
      if ((& $run $running) -ne '') { throw 'it spoke when the releases matched' }
      if ((& $run $null) -ne '') { throw 'an undeclared release was treated as stale rather than unknown' }
      $stale = & $run '0.0.1'
      if ($stale -eq '') { throw 'it stayed silent on a stale repository' }
      if ($stale -notmatch 'SessionStart') { throw 'the output is not a SessionStart hook payload' }
      if ($stale -notmatch 'configure') { throw 'it does not name the command that repairs it' }
    } finally {
      Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
    $true
  }

  Assert "a Decision records why this is a hook rather than a step in a stage" {
    $p = Join-Path $repo '.claude/decisions/0064-the-release-check-is-a-hook-because-only-shipped-content-knows-the-release.md'
    if (-not (Test-Path $p)) { throw 'the Decision is missing' }
    $c = Get-Content $p -Raw
    if ($c -notmatch '(?is)Considered Options') { throw 'it weighs no alternatives' }
    if ($c -notmatch '(?is)single.home') { throw 'it does not state the reason a stage-level check was refused' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    $true
  }

  # `changelog/02` folded the standalone re-stamp bullet into the cursor step,
  # which reads the field, applies what is newer, and then advances it. Same
  # obligation, one bullet instead of two — so this asserts the obligation rather
  # than the word the bullet used to open with.
  Assert "the audit leaves the field at the release that ran it" {
    $c = Get-SkillFile 'configure/SKILL.md'
    if ($c -notmatch '(?is)aep-version') { throw 'the audit does not name the field' }
    if ($c -notmatch '(?i)set the field to the release running this audit') {
      throw 'the audit never advances the field'
    }
    $true
  }
}

# --- ticket changelog/01 — dated repairs move under the release that caused them --

# The shape of a dated repair, wherever it is written: prose that recognises a
# repository by what an *older release* left behind. Anchored on that phrasing
# rather than on the ten being moved, because a guard written from the ten goes
# green the moment an eleventh is added to the old place — which is exactly how
# the ten accumulated.
$datedRepair = '(?i)(predates?|installed before|configured before|configured while|converted before)'

Describe-Ticket 'changelog/01' 'dated repairs move under the release that caused them' {

  $log = Get-SkillFile 'configure/migration-changelog.md'

  Assert "the changelog ships beside the migration page" {
    if (-not (Test-Path (Join-Path $skills 'configure/migration-changelog.md'))) { throw 'it is missing' }
    $true
  }

  # Every repair that moved, found by a phrase from its own body rather than by
  # its old heading — a heading can be reworded in the move and the repair still
  # be there, and it is the repair that had to survive.
  $moved = @{
    'the ignore file'          = 'accumulating untracked child checkouts'
    'the framework name'       = '(?i)\*AI\* Engineering Protocol'
    'the stage table'          = 'surfaced in the plan, never added silently'
    'the Tenure rename'        = '(?i)`/tenure:` becomes `/aep:`'
    'the pre-modes protocol'   = '(?i)### Mode:'
    'orchestration absent'     = '(?i)sub-agents\.md` is absent'
    'the isolation setting'    = 'worktree\.baseRef'
    'the second axis'          = 'admits no whole-ticket child'
    'declared fields'          = 'hand-written routing table'
    'drift findings'           = 'Leave every unmarked'
  }
  foreach ($name in $moved.Keys) {
    Assert "the changelog carries the repair for $name" {
      if ($log -notmatch $moved[$name]) { throw 'the repair did not survive the move' }
      $true
    }
  }

  Assert "no dated repair is left in the audit list or the migration page" {
    $offenders = @()
    foreach ($f in 'configure/SKILL.md', 'configure/MIGRATION.md') {
      foreach ($line in ((Get-SkillFile $f) -split '\r?\n')) {
        # A line that *routes* to the changelog names the dated case in order to
        # delegate it, which is the opposite of holding it. Excluded by the
        # reference rather than by its wording, so rephrasing the bullet cannot
        # quietly re-exempt it.
        if ($line -match 'migration-changelog') { continue }
        if ($line -match '^\s*[-*#]' -and $line -match $datedRepair) {
          $offenders += "$f : $($line.Trim().Substring(0, [Math]::Min(64, $line.Trim().Length)))"
        }
      }
    }
    if ($offenders) { throw "dated repair outside the changelog — $($offenders -join ' | ')" }
    $true
  }

  Assert "every release in the changelog cites what its assignment was recovered from" {
    $releases = [regex]::Matches($log, '(?m)^##\s+(\d+\.\d+\.\d+)\s*$')
    if ($releases.Count -lt 6) { throw "only $($releases.Count) releases are recorded" }
    foreach ($r in $releases) {
      $body = $log.Substring($r.Index)
      $next = [regex]::Match($body.Substring(1), '(?m)^##\s')
      if ($next.Success) { $body = $body.Substring(0, $next.Index + 1) }
      # The recovery trail left this file with citations/01 — it named records
      # that resolve only in the repository that builds AEP, and this file is
      # read elsewhere. It moved to that repository's own ticket, which is
      # asserted there. What must still be here is where to look.
      if ($body -notmatch '(?i)\*\*Look at:\*\*') { throw "$($r.Groups[1].Value) does not say where to look" }
    }
    $true
  }

  Assert "the migration page states that catch-up moved, rather than losing it silently" {
    $m = Get-SkillFile 'configure/MIGRATION.md'
    if ($m -notmatch 'migration-changelog') { throw 'it does not point at where the repairs went' }
    if ($m -notmatch '(?i)does not catch a repository up on releases') { throw 'it does not state its own scope' }
    $true
  }
}

# --- ticket changelog/02 — the audit applies only what the repository lacks ---

Describe-Ticket 'changelog/02' 'the audit applies only the repairs a repository has not had' {

  $c = Get-SkillFile 'configure/SKILL.md'

  Assert "the audit reads the changelog from the release the repository declares" {
    if ($c -notmatch 'migration-changelog') { throw 'the audit never opens it' }
    if ($c -notmatch '(?i)aep-version') { throw 'the audit does not read the cursor' }
    if ($c -notmatch '(?i)newer than') { throw 'the audit does not bound what it considers' }
    $true
  }

  Assert "a repository declaring no release has every repair considered" {
    if ($c -notmatch '(?i)no version[^.]{0,90}all of them') { throw 'the absent-field case is not stated' }
    $true
  }

  # The cursor selects what is *considered*; content still selects what is *done*.
  # Without this the cursor reads as permission to act on a release number alone,
  # which would repair repositories that never had the shape.
  Assert "the cursor narrows what is considered, never what is verified" {
    if ($c -notmatch '(?i)recognises its shape by content') { throw 'the cursor is not bounded to selection' }
    $true
  }

  Assert "the audit says which releases it skipped" {
    if ($c -notmatch '(?i)which releases were skipped') { throw 'a partial audit is indistinguishable from a clean one' }
    $true
  }

  Assert "the audit leaves the cursor pointing at the release that ran it" {
    if ($c -notmatch '(?i)set the field to the release running this audit') { throw 'the cursor is never advanced' }
    $true
  }

  Assert "the running release has a changelog entry" {
    $running = (Get-Content (Join-Path $repo '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json).version
    $log = Get-SkillFile 'configure/migration-changelog.md'
    if ($log -notmatch ('(?m)^##\s+' + [regex]::Escape($running) + '\s*$')) {
      throw "no entry for $running — a release with no repair still says so"
    }
    $true
  }

  Assert "a Decision records the cursor and the two readings of an absent field" {
    $p = Join-Path $repo '.claude/decisions/0065-the-audit-is-bounded-by-a-version-cursor.md'
    if (-not (Test-Path $p)) { throw 'the Decision is missing' }
    $d = Get-Content $p -Raw
    if ($d -notmatch '(?is)Considered Options') { throw 'it weighs no alternatives' }
    if ($d -notmatch '(?is)opposite things to the two readers') { throw 'the asymmetry is not recorded' }
    if ($d -notmatch '(?is)cannot rot|frozen') { throw 'it does not say why a hand-written file is safe here' }
    $true
  }

  Assert "the specification carries the cursor and the standing-versus-dated split" {
    $s = Get-Content (Join-Path $repo 'specs.md') -Raw
    if ($s -notmatch '(?i)standing checks') { throw 'the split is not in the specification' }
    if ($s -notmatch '(?i)dated repairs') { throw 'the split names only one side' }
    # The 'and it cites the Decision' clause was removed by citations/01: a shipped
    # file may not name a record that resolves only here. The substance above is
    # what a reader in another repository needs, and it is still asserted.
    $true
  }
}

# --- ticket citations/01 — shipped text cites only what resolves where read ---

Describe-Ticket 'citations/01' 'shipped text cites only what resolves where it is read' {

  # Matched by *shape*, not by the sixty-six that were removed. A guard written
  # from the specific list goes green the moment a sixty-seventh is added, which
  # is how the sixty-six accumulated in the first place.
  #
  # Two look like hits and are not, so both are excluded by what makes them
  # resolve rather than by name: `.claude/policies/specs.md` is a guide every
  # configured repository has, and a bare section sign beside a shipped
  # filename points inside a file the reader is holding.
  Assert "no shipped file references a record that resolves only in this repository" {
    $offenders = @()
    foreach ($f in (Get-SkillFiles)) {
      $rel = ($f.FullName.Substring($skills.Length + 1) -replace '\\', '/')
      $i = 0
      foreach ($line in ((Get-Content $f.FullName -Raw) -split '\r?\n')) {
        $i++
        $probe = $line -replace '\.claude/policies/specs\.md', '' -replace '`specs\.md`\s*\|', '|'
        if ($probe -match 'ADR[s]? [0-9]{4}') { $offenders += "$rel`:$i (ADR)" }
        elseif ($probe -match '(^|[^/`])specs\.md') { $offenders += "$rel`:$i (specs.md)" }
      }
    }
    foreach ($a in (Get-ChildItem (Join-Path $repo 'agents') -Filter '*.md')) {
      $i = 0
      foreach ($line in ((Get-Content $a.FullName -Raw) -split '\r?\n')) {
        $i++
        if ($line -match 'ADR[s]? [0-9]{4}') { $offenders += "agents/$($a.Name):$i (ADR)" }
      }
    }
    if ($offenders) { throw "unfollowable where it is read: $($offenders -join ', ')" }
    $true
  }

  # Attribution is the one class of reference this effort must not touch, and it
  # is checked by `attribution/01` rather than here — that section pins the
  # vendored set by name and fails in both directions, where a count could only
  # ever fail in one. What belongs to *this* ticket is that its own sweep left
  # attribution alone, which is what the assertion below tests.
  Assert "the citation sweep did not reach attribution" {
    foreach ($f in @('grilling/SKILL.md', 'tdd/SKILL.md')) {
      if ((Get-SkillFile $f) -notmatch '(?i)vendored from \[mattpocock/skills\]') {
        throw "the sweep removed vendored attribution from $f"
      }
    }
    $true
  }

  Assert "references to installed paths are untouched, since those resolve" {
    $c = Get-SkillFile 'implement/SKILL.md'
    foreach ($p in '\.claude/policies/tickets\.md', '\.claude/tools/git\.md') {
      if ($c -notmatch $p) { throw "a resolvable reference was removed: $p" }
    }
    $true
  }

  Assert "the rule is stated once, on the surface it governs" {
    $r = Get-Content (Join-Path $repo '.claude/rules/skills.md') -Raw
    if ($r -notmatch '(?i)resolves where it is read') { throw 'the rule is not in the scoped rule file' }
    if ($r -notmatch '(?i)followability, not usefulness') { throw 'the rule is a list rather than a test' }
    $true
  }

  # This repository's own knowledge is the majority of the tree and is not
  # shipped. A sweep that reached it would delete a working citation, so the
  # boundary is asserted rather than trusted.
  Assert "this repository's own records keep their citations" {
    foreach ($d in '.claude/decisions', '.claude/tickets', '.claude/contexts') {
      $n = @(Get-ChildItem (Join-Path $repo $d) -Recurse -Filter '*.md' |
             Where-Object { (Get-Content $_.FullName -Raw) -match 'ADR [0-9]{4}' }).Count
      if ($n -lt 3) { throw "$d lost its citations — the sweep reached knowledge it does not govern" }
    }
    if ((Get-Content (Join-Path $repo 'specs.md') -Raw) -notmatch 'ADR [0-9]{4}') {
      throw 'the specification lost its citations'
    }
    $true
  }

  Assert "the release changelog's recovery trail moved to where it resolves" {
    if ((Get-SkillFile 'configure/migration-changelog.md') -match '(?i)recovered from') {
      throw 'the shipped file still carries the trail'
    }
    $t = Get-Content (Join-Path $repo '.claude/tickets/changelog/issues/01-dated-repairs-move-under-the-release-that-caused-them.md') -Raw
    if ($t -notmatch '(?i)recovered from') { throw 'the trail was dropped rather than moved' }
    if ($t -notmatch '1\.7\.0') { throw 'the trail is incomplete' }
    $true
  }
}

# --- ticket probe/01 — one bad file fails one section, not the run -----------

# This section reads `scripts/verify.ps1` rather than `./skills`, which is the
# third thing a section here can assert against and the rarest. It is deliberate:
# the claim is about the runner's own structure, and no other tree can carry it.
#
# Both assertions parse the script rather than matching text in it. A regex would
# find its own literal — the guard states the shape it requires, so the shape is
# present in the file whether or not the runner has it, and the guard passes
# forever. Parsing asks the question of one function instead of the file.
Describe-Ticket 'probe/01' 'one bad file fails one section, not the run' {

  # `Get-RepoText` is declared per section rather than beside the other helpers;
  # two other sections do the same and this follows them rather than hoisting a
  # third caller's worth of reach into the global scope.
  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  # Parsed once; both assertions below walk the same tree.
  function Get-SectionRunner {
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
      (Join-Path $repo 'scripts/verify.ps1'), [ref]$null, [ref]$errors)
    if ($errors) { throw "the script does not parse: $($errors[0].Message)" }
    $fn = $ast.Find({
      param($n)
      $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
      $n.Name -eq 'Describe-Ticket'
    }, $true)
    if (-not $fn) { throw 'no Describe-Ticket function to check' }
    $fn
  }

  Assert "the section runner catches what its body throws" {
    $fn = Get-SectionRunner
    $try = $fn.Find({
      param($n) $n -is [System.Management.Automation.Language.TryStatementAst]
    }, $true)
    if (-not $try) {
      throw 'Describe-Ticket invokes its body unguarded — one throw from a hoisted read ends the run'
    }
    # Catching and swallowing would be worse than not catching: the run would
    # finish green having skipped a section. The handler has to record a failure.
    $records = $try.CatchClauses | Where-Object {
      $_.Body.Extent.Text -match '\$script:Failures'
    }
    if (-not $records) { throw 'the section runner catches but records nothing — a skipped section would pass' }
    $true
  }

  Assert "an aborted section is distinguishable from one whose assertions failed" {
    $fn = Get-SectionRunner
    $try = $fn.Find({
      param($n) $n -is [System.Management.Automation.Language.TryStatementAst]
    }, $true)
    if (-not $try) { throw 'nothing is caught, so nothing is reported' }
    $handler = ($try.CatchClauses | ForEach-Object { $_.Body.Extent.Text }) -join "`n"
    # The failure line has to say the section stopped early. Without that, an
    # abort reads in the summary as one ordinary assertion failing, and the
    # assertions it took down with it are invisible.
    if ($handler -notmatch '(?i)abort') { throw 'the recorded failure does not say the section aborted' }
    # The exception's own message is the only thing that says which file or
    # heading was missing.
    if ($handler -notmatch '\$_\.Exception\.Message') { throw 'the reason is dropped' }
    $true
  }

  # Anchored to the two identifiers and the consequence, never to the wording
  # around them. The first draft of this guard pinned the word "outside" and
  # failed against a guide that said the same thing in different words — which
  # is the defect this effort exists to remove, caught on its own first guard.
  Assert "the tool guide says which throws are caught where" {
    $doc = Get-RepoText '.claude/tools/verify.md'
    # Both scopes named, or the guide describes one catcher and not a boundary.
    foreach ($scope in @('Assert', 'Describe-Ticket')) {
      if ($doc -notmatch [regex]::Escape($scope)) { throw "the guide does not name $scope as a scope that catches" }
    }
    if ($doc -notmatch '(?i)abort') { throw 'the guide does not describe a section aborting' }
    # The cost is the whole point of documenting the boundary: a throw caught at
    # section scope takes that section's other assertions with it. A guide that
    # names the two scopes without saying that has described a distinction with
    # no consequence attached.
    if ($doc -notmatch '(?i)remaining assertions|assertions .{0,20}do not run|rest of (the |that )?section') {
      throw 'the guide does not say a section-scoped catch costs the rest of the section'
    }
    $true
  }
}

# --- ticket probe/02 — every failing assertion says what was wrong -----------

# Reads `scripts/verify.ps1`, as probe/01 does and for the same reason: the claim
# is about the assertions themselves, and they exist in no other tree.
Describe-Ticket 'probe/02' 'every failing assertion says what was wrong' {

  Assert "no assertion can fail without saying what was wrong" {
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
      (Join-Path $repo 'scripts/verify.ps1'), [ref]$null, [ref]$errors)
    if ($errors) { throw "the script does not parse: $($errors[0].Message)" }

    # The condition is `Assert`'s second positional argument. Taken from the
    # parse rather than by matching text, so a condition spanning forty lines
    # counts once and a `throw` in a neighbouring assertion cannot be credited
    # to this one.
    $silent = foreach ($call in $ast.FindAll({
        param($n)
        $n -is [System.Management.Automation.Language.CommandAst] -and
        $n.GetCommandName() -eq 'Assert'
      }, $true)) {
      $condition = $call.CommandElements | Where-Object {
        $_ -is [System.Management.Automation.Language.ScriptBlockExpressionAst]
      } | Select-Object -First 1
      if (-not $condition) { continue }

      # Two shapes explain themselves, and only these two.
      #
      # A condition holding a `throw` says what was wrong on the path that
      # throws. A condition whose value is the literal `$true` cannot return
      # false at all, so its only failure is an exception — raised by a helper
      # like `Get-Section`, which carries its own message. The `| Out-Null;
      # $true` sections are that second shape and are sound; an earlier draft
      # of this guard called them silent and would have "repaired" three
      # assertions that already explained themselves perfectly.
      #
      # Everything else can hand `Assert` a bare $false, and a bare $false is a
      # failure with the assertion's own name and nothing else.
      if ($condition.FindAll({
          param($n) $n -is [System.Management.Automation.Language.ThrowStatementAst] }, $true)) { continue }

      $last = $condition.ScriptBlock.EndBlock.Statements[-1]
      if ($last.Extent.Text.Trim() -eq '$true') { continue }

      "line $($call.Extent.StartLineNumber): $($call.CommandElements[1].Extent.Text.Trim(""'""))"
    }

    if ($silent) {
      throw "$(@($silent).Count) assertion(s) fail with no detail — the first is $(@($silent)[0])"
    }
    $true
  }
}

# --- ticket attribution/01 — attribution follows the vendored set -------------

# The vendored set, pinned by name. It decides whether a licence notice is
# required on a file, which makes it a fact to check rather than a description to
# trust — and pinning is the only form that can fail in both directions.
#
# Inferring it instead, from the word each file happens to use, would let a file
# stop saying "vendored" and thereby exempt itself from needing to say anything.
$vendored = @(
  'codebase-design/SKILL.md'
  'domain-modeling/SKILL.md'
  'grilling/SKILL.md'
  'review/SMELLS.md'
  'tdd/SKILL.md'
)

# An attribution is a claim that THIS file's content came from upstream. A file
# that merely names the upstream project is not attributing: `commit/SKILL.md`
# says there is no equivalent there, and `configure/MIGRATION.md` names the
# migration it performs. Matching on the project name alone would catch both and
# force a licence notice onto files that borrowed nothing.
$attribution = '(?i)(vendored|derived) from \[mattpocock/skills\]'

Describe-Ticket 'attribution/01' 'attribution follows the vendored set' {

  # Declared per section, as the other callers of each do.
  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }
  $agents = Join-Path $repo 'agents'

  Assert "NOTICE still reproduces the upstream licence in full" {
    $n = Get-Content (Join-Path $repo 'NOTICE') -Raw
    foreach ($required in @('MIT License', 'Copyright \(c\) 2026 Matt Pocock', 'without restriction', 'THE SOFTWARE IS PROVIDED "AS IS"')) {
      if ($n -notmatch $required) { throw "NOTICE no longer carries: $required" }
    }
    $true
  }

  Assert "every vendored file attributes upstream" {
    $missing = @($vendored | Where-Object { (Get-SkillFile $_) -notmatch $attribution })
    if ($missing) { throw "vendored text with no attribution: $($missing -join ', ')" }
    $true
  }

  # The other direction, and the one that stops the set regrowing. Nineteen files
  # attributed upstream for a structure they borrowed rather than text they
  # copied — a licence obligation asserted where none exists, which misstates the
  # licence as surely as omitting a required one does.
  Assert "no file outside the vendored set attributes upstream" {
    $extra = @()
    foreach ($f in Get-SkillFiles) {
      $rel = $f.FullName.Substring($skills.Length).TrimStart('\', '/') -replace '\\', '/'
      if ($rel -in $vendored) { continue }
      if ((Get-SkillText $f) -match $attribution) { $extra += $rel }
    }
    foreach ($f in (Get-ChildItem $agents -File -Filter *.md -ErrorAction SilentlyContinue)) {
      if ((Get-Content $f.FullName -Raw) -match $attribution) { $extra += "agents/$($f.Name)" }
    }
    if ($extra) { throw "attributes upstream without vendoring it: $($extra -join ', ')" }
    $true
  }

  Assert "the rule states the vendored test, and states it once" {
    $r = Get-RepoText '.claude/rules/skills.md'
    if ($r -notmatch '(?i)vendored') { throw '.claude/rules/skills.md does not state the vendored test' }
    if ($r -notmatch '(?i)structure|shape') { throw 'the rule does not say what borrowing a shape does not require' }
    $ctx = Get-RepoText '.claude/contexts/repository.md'
    if ($ctx -notmatch '(?i)vendored') { throw '.claude/contexts/repository.md does not state the vendored test' }
    $true
  }

  # Scoped to the whole assertion, never to the line. The first draft matched
  # line by line and passed while the count guard it was written to catch was
  # still in the file — the counting and the word `mattpocock` sat on adjacent
  # lines, so no single line held both. A guard that cannot see across its own
  # subject is the failure this suite spent an effort removing.
  Assert "no assertion gates attribution on a count of files" {
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
      (Join-Path $repo 'scripts/verify.ps1'), [ref]$null, [ref]$errors)
    if ($errors) { throw "the script does not parse: $($errors[0].Message)" }
    foreach ($call in $ast.FindAll({ param($n)
        $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Assert' }, $true)) {
      $t = $call.Extent.Text
      if ($t -notmatch 'mattpocock') { continue }
      if ($t -match '-(lt|le|gt|ge)\s+\d+') {
        throw "attribution is gated on a count at line $($call.Extent.StartLineNumber): $($call.CommandElements[1].Extent.Text.Trim(""'""))"
      }
    }
    $true
  }
}

# --- ticket receipt/01 — the position report is specified as behaviour --------

Describe-Ticket 'receipt/01' 'the position report is specified, with a fixture' {

  $page = 'configure/SCRIPTS.md'
  $pageText = { (Get-SkillFile $page) -replace "`r", '' }

  # Every fenced block whose first line is the report's own heading. Both report
  # shapes and all three refusals are these; the discriminator below is the arrow,
  # which only a refusal carries.
  #
  # Scoped to one section rather than the page, because the fixture restates
  # these shapes as its expected output — an unscoped read counted a fixture case
  # as a fourth refusal, and would equally have let the fixture alone satisfy an
  # assertion about what the specification states.
  # What the position script's specification states, with its fixture excluded.
  # The fixture restates the report's shapes and vocabulary as expected output, so
  # a whole-page read lets the fixture satisfy an assertion about the contract —
  # the "reads it makes" guard passed with a read deleted for exactly that reason.
  $positionSpec = {
    $m = [regex]::Match((& $pageText), "(?ms)^## The position report\r?\n(.*?)^### The position report's fixture")
    if (-not $m.Success) { throw 'the page has no position specification ahead of its fixture' }
    $m.Groups[1].Value
  }

  $blocksUnder = {
    param($heading)
    $m = [regex]::Match((& $pageText), "(?ms)^### $([regex]::Escape($heading))\r?\n(.*?)(?=^#{1,3} |\z)")
    if (-not $m.Success) { throw "the page has no section headed '$heading'" }
    @([regex]::Matches($m.Groups[1].Value, '(?ms)^```\r?\n(Position\r?\n.*?)^```') |
        ForEach-Object { $_.Groups[1].Value })
  }

  Assert "the page specifies where each script it names is written" {
    $c = & $pageText
    foreach ($s in 'regenerate-indexes', 'report-position') {
      if ($c -notmatch [regex]::Escape(".claude/scripts/$s.")) {
        throw "the page does not say where $s is written"
      }
    }
    $true
  }

  # Single-home, checked by counting rather than by reading. A page covering two
  # scripts is where a shared rule most plausibly gets restated per script, and a
  # restated rule drifts at one of them — so the test is that it appears once,
  # not that a section with some particular name exists.
  Assert "an obligation shared by both scripts is stated once, not per script" {
    $c = & $pageText
    foreach ($rule in 'byte-order mark', 'one check whose answer was not produced') {
      $n = ([regex]::Matches($c, [regex]::Escape($rule))).Count
      if ($n -ne 1) { throw "'$rule' is stated $n times; a shared obligation is stated once" }
    }
    $true
  }

  Assert "the position report specifies the reads it makes" {
    $c = & $positionSpec
    foreach ($read in 'marker file', 'HEAD', 'ancestor', 'fingerprint', 'untracked') {
      if ($c -notmatch [regex]::Escape($read)) { throw "the page does not specify the read: $read" }
    }
    # The marker's path has one live home and this page is not it, so the reads
    # are specified by naming the file and pointing at the guide that holds the
    # invocations — a page restating the path is a second home for it.
    if ($c -notmatch [regex]::Escape('.claude/tools/git.md')) {
      throw 'the page does not point at the guide holding the invocations'
    }
    if ($c -match [regex]::Escape('.claude/position/marker.json')) {
      throw 'the page restates the marker path, which has its home in the tool guide'
    }
    # The whole value of the Marker is that a match licenses skipping the drift
    # reads. A specification that omits it derives a script costing more than the
    # reads it replaced.
    if ($c -notmatch '(?i)skipp?(ing|ed)') { throw 'the page does not say a match skips the drift reads' }
    $true
  }

  Assert "the report is specified for the matching case and the differing case" {
    $blocks = & $blocksUnder 'The report, exactly'
    if (-not ($blocks | Where-Object { $_ -match 'commit match' -and $_ -match 'tree match' })) {
      throw 'no specified report shows both identities matching'
    }
    $differing = @($blocks | Where-Object { $_ -match 'tree differs' -and $_ -match 'uncommitted' })
    if (-not $differing) { throw 'no specified report shows a differing tree with its drift paths' }
    # A count alone says something moved and never what, which is the read the
    # stage is about to need — so the differing shape has to carry paths.
    if ($differing[0] -notmatch '(?m)^\s{10,}\S+/') {
      throw 'the differing report states counts without listing the paths beneath them'
    }
    $true
  }

  # Each refusal has to say what it does *not* license. A refusal that reports
  # only what it found reads as a smaller problem than it is — the stage carries
  # on with knowledge nobody checked.
  Assert "all three refusals are specified, and none of them reports only what it found" {
    $refusals = @((& $blocksUnder 'The three refusals') | Where-Object { $_ -match '-> ' })
    if ($refusals.Count -ne 3) { throw "the page specifies $($refusals.Count) refusals, expected 3" }
    foreach ($r in $refusals) {
      if ($r -notmatch '(?i)unverified') {
        throw "a refusal does not say what it leaves unverified: $($r -replace '\s+', ' ')"
      }
    }
    $true
  }

  # Read from the shape the page publishes rather than from a list here, so a
  # field added to the page without a reader is caught by the same assertion that
  # catches one removed.
  Assert "the receipt declares exactly the fields something reads" {
    $c = & $pageText
    $json = @([regex]::Matches((& $positionSpec), '(?ms)^```json\r?\n(.*?)^```') |
        ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ -match '"mode"' })
    if ($json.Count -ne 1) { throw "the page carries $($json.Count) receipt shapes, expected 1" }
    $keys = @([regex]::Matches($json[0], '"(\w+)"\s*:') | ForEach-Object { $_.Groups[1].Value }) | Sort-Object
    $want = @('head', 'mode', 'run', 'tree')
    if (($keys -join ',') -ne ($want -join ',')) {
      throw "the receipt declares $($keys -join ', '); expected $($want -join ', ')"
    }
    # The live values, never the marker's — a receipt echoing the marker answers a
    # different question than the one the commit stage asks.
    if ($c -notmatch '(?i)observed') { throw 'the page does not say the receipt holds what was observed' }
    $true
  }

  Assert "the fallback is specified in both directions, and names the mode it ran in" {
    $c = & $positionSpec
    foreach ($mode in 'session', 'commit-only') {
      if ($c -notmatch [regex]::Escape($mode)) { throw "the page does not specify the mode: $mode" }
    }
    if ($c -notmatch '(?i)not (documented|stated)|observed rather than documented') {
      throw 'the page does not record that the run identity is undocumented'
    }
    # The mitigation is the whole reason the mode is a field. A fallback that
    # downgrades silently is the failure, not a lesser form of it.
    if ($c -notmatch '(?i)downgrade') { throw 'the page does not say an unstated downgrade is undetectable' }
    $true
  }

  Assert "the script's half is specified, and the stage's half is named as not its own" {
    $c = & $positionSpec
    if ($c -notmatch '(?i)judge?ment') { throw 'the page does not name the judgement half' }
    if ($c -notmatch '(?i)(never|not) the judge?ment half') {
      throw 'the page does not say the script leaves the judgement half alone'
    }
    foreach ($j in 'Source Pointer', 'route') {
      if ($c -notmatch [regex]::Escape($j)) { throw "the page does not name what the judgement half covers: $j" }
    }
    $true
  }

  # The fixture is the only check this script will ever have, so it has to reach
  # every branch the report specifies. Read from the fixture's own expected
  # outputs rather than from a count of cases, which a renamed case would break
  # and a missing branch would not.
  Assert "the fixture covers every branch the report specifies" {
    $c = & $pageText
    $fixture = [regex]::Match($c, '(?ms)^### The position report''s fixture\r?\n(.*?)^### ')
    if (-not $fixture.Success) { throw 'the page carries no position fixture' }
    $f = $fixture.Groups[1].Value
    # Every verdict and every refusal, because the fixture is this script's only
    # check — a branch it never reaches is a branch nothing checks at all. The
    # two present-but-unrelated refusals are listed separately from the absent
    # one: they are the pair a derivation most plausibly collapses into one.
    foreach ($branch in 'commit match', 'tree differs', 'absent', 'gone from this clone',
                        'not an ancestor', 'commit-only', 'session ') {
      if ($f -notmatch [regex]::Escape($branch)) { throw "the fixture never reaches: $branch" }
    }
    # An object name cannot be a literal here, so the expected output is stated
    # with substitutions — a fixture carrying a real sha would be one nobody else
    # could run.
    if ($f -notmatch '<head7>|<tree7>') { throw 'the fixture states object names as literals, which no second run reproduces' }
    $true
  }

  # Ticket 01 shipped the contract with no implementation beside it, because a
  # reference implementation becomes the de facto contract and ambiguities get
  # settled by reading code nobody promised to keep aligned. That was a property
  # of one ticket's diff and not of the tree — an effort is one commit here, so
  # ticket 02 amends this same commit and the implementation is in it. What
  # survives as a checkable property is the agreement below, in receipt/02.
}

# --- ticket receipt/02 — this repository derives the position script -----------

Describe-Ticket 'receipt/02' 'this repository derives the position script' {

  $page = 'configure/SCRIPTS.md'
  $script = Join-Path $repo '.claude/scripts/report-position.ps1'

  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  # Both halves are read out of the page. Transcribing the expected output into
  # this file would check the script against a copy nobody promised to keep
  # aligned with the contract — which is the horn the derive-don't-ship decision
  # rejected, reintroduced one level down in the suite.
  $fixtureSection = {
    $c = (Get-SkillFile $page) -replace "`r", ''
    $m = [regex]::Match($c, "(?ms)^### The position report's fixture\r?\n(.*?)(?=^### )")
    if (-not $m.Success) { throw 'the page carries no position fixture' }
    $m.Groups[1].Value
  }
  $expectedBlocks = {
    @([regex]::Matches((& $fixtureSection), '(?ms)^```\r?\n(Position\r?\n.*?)^```') |
        ForEach-Object { $_.Groups[1].Value.TrimEnd("`n") })
  }

  # A repository with one commit of one file, plus the fingerprint of its clean
  # tree — the two values every expected block is stated in terms of.
  $mkRepo = {
    $root = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
    $null = New-Item -ItemType Directory -Path $root
    $null = & git -C $root init -q 2>&1
    $null = & git -C $root config user.email 'fixture@example.invalid' 2>&1
    $null = & git -C $root config user.name 'Fixture' 2>&1
    Set-Content -Path (Join-Path $root 'seed.txt') -Value 'seed' -Encoding utf8NoBOM
    # Position is ignored, as it is in every configured repository. Without this
    # no case can pass: the script writes the receipt into that directory during
    # the run, so a tree counting it reports a fingerprint its own attestation
    # then invalidates, and the marker could never match the tree it came from.
    Set-Content -Path (Join-Path $root '.gitignore') -Value '.claude/position/' -Encoding utf8NoBOM
    $null = & git -C $root add seed.txt .gitignore 2>&1
    $null = & git -C $root commit -q -m 'seed' 2>&1
    $null = New-Item -ItemType Directory -Path (Join-Path $root '.claude/position') -Force
    $root
  }
  $fingerprint = {
    param($root)
    $idx = & git -C $root rev-parse --path-format=absolute --git-path index
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
    Copy-Item $idx $tmp
    try {
      $env:GIT_INDEX_FILE = $tmp
      $null = & git -C $root add -A 2>&1
      (& git -C $root write-tree).Trim()
    } finally { $env:GIT_INDEX_FILE = $null; Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
  }
  $run = {
    param($root, $runId)
    $had = $env:CLAUDE_CODE_SESSION_ID
    try {
      if ($runId) { $env:CLAUDE_CODE_SESSION_ID = $runId } else { $env:CLAUDE_CODE_SESSION_ID = $null }
      (& pwsh -NoProfile -File $script -Repo $root 2>&1 | Out-String) -replace "`r", '' -replace "`n+$", ''
    } finally { $env:CLAUDE_CODE_SESSION_ID = $had }
  }
  $writeMarker = {
    param($root, $commit, $tree)
    Set-Content -Path (Join-Path $root '.claude/position/marker.json') `
      -Value (@{ commit = $commit; tree = $tree } | ConvertTo-Json) -Encoding utf8NoBOM
  }

  Assert "the derived script exists where the page says it is written" {
    if (-not (Test-Path $script)) { throw '.claude/scripts/report-position.ps1 is missing' }
    $true
  }

  # The both-directions check the derive-don't-ship decision needs: a script the
  # page never specified is as wrong as a specified one nobody wrote, and only the
  # first of those looks like a passing build.
  Assert "every script the page specifies is derived, and no script is derived that it does not" {
    $c = Get-SkillFile $page
    $specified = @([regex]::Matches($c, '`\.claude/scripts/([a-z-]+)\.<ext>`') |
        ForEach-Object { $_.Groups[1].Value }) | Sort-Object -Unique
    if (-not $specified) { throw 'no script is specified by the page' }
    $derived = @(Get-ChildItem -Path (Join-Path $repo '.claude/scripts') -File |
        ForEach-Object { $_.BaseName }) | Sort-Object -Unique
    $missing = @($specified | Where-Object { $derived -notcontains $_ })
    if ($missing) { throw "the page specifies a script nothing derived: $($missing -join ', ')" }
    $extra = @($derived | Where-Object { $specified -notcontains $_ })
    if ($extra) { throw "a script is derived that the page does not specify: $($extra -join ', ')" }
    $true
  }

  Assert "every case the fixture states produces the page's exact expected output" {
    $blocks = & $expectedBlocks
    if ($blocks.Count -ne 5) { throw "the fixture states $($blocks.Count) expected outputs, expected 5" }
    $root = & $mkRepo
    try {
      $head = (& git -C $root rev-parse HEAD).Trim()
      $tree = & $fingerprint $root
      & $writeMarker $root $head $tree

      $subst = {
        param($b, $live)
        $b -replace '<head7>', $head.Substring(0, 7) -replace '<tree7>', $tree.Substring(0, 7) `
           -replace '<live7>', $live
      }

      # A — both identities match.
      $got = & $run $root $null
      $want = (& $subst $blocks[0] '').TrimEnd("`n")
      if ($got -ne $want) { throw "case A differs.`nexpected:`n$want`ngot:`n$got" }

      # B — one untracked file. The fingerprint must move, which is the whole
      # reason this case exists: a read blind to an untracked file is the defect
      # the tree fact was added to catch.
      Set-Content -Path (Join-Path $root 'a.txt') -Value 'a' -Encoding utf8NoBOM
      $live = (& $fingerprint $root).Substring(0, 7)
      if ($live -eq $tree.Substring(0, 7)) { throw 'the fingerprint did not move for an untracked file' }
      $got = & $run $root $null
      $want = (& $subst $blocks[1] $live).TrimEnd("`n")
      if ($got -ne $want) { throw "case B differs.`nexpected:`n$want`ngot:`n$got" }

      # C — no marker file.
      Remove-Item (Join-Path $root '.claude/position/marker.json') -Force
      $got = & $run $root $null
      $want = (& $subst $blocks[2] '').TrimEnd("`n")
      if ($got -ne $want) { throw "case C differs.`nexpected:`n$want`ngot:`n$got" }
      Remove-Item (Join-Path $root 'a.txt') -Force

      # E — a well-formed object name naming no object here.
      $gone = '0' * 40
      & $writeMarker $root $gone $tree
      $got = & $run $root $null
      $want = ((& $subst $blocks[3] '') -replace '<gone7>', $gone.Substring(0, 7)).TrimEnd("`n")
      if ($got -ne $want) { throw "case E differs.`nexpected:`n$want`ngot:`n$got" }

      # F — a commit that exists and is unrelated. Distinct from E in the
      # question asked and in what it leaves unverified, and the two are what a
      # derivation most plausibly collapses together.
      $null = & git -C $root switch -q -c sideline 2>&1
      Set-Content -Path (Join-Path $root 'side.txt') -Value 'side' -Encoding utf8NoBOM
      $null = & git -C $root add side.txt 2>&1
      $null = & git -C $root commit -q -m 'sideline' 2>&1
      $other = (& git -C $root rev-parse HEAD).Trim()
      $null = & git -C $root switch -q - 2>&1
      & $writeMarker $root $other $tree
      $got = & $run $root $null
      $want = ((& $subst $blocks[4] '') -replace '<other7>', $other.Substring(0, 7)).TrimEnd("`n")
      if ($got -ne $want) { throw "case F differs.`nexpected:`n$want`ngot:`n$got" }
    }
    finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
    $true
  }

  Assert "with the run identity present, only the mode line changes" {
    $wantLine = [regex]::Match((& $fixtureSection), '`(\s*mode\s+session [^`]+)`')
    if (-not $wantLine.Success) { throw 'the fixture does not state the mode line for a present identity' }
    $id = ($wantLine.Groups[1].Value -split '\s+')[-1]
    $root = & $mkRepo
    try {
      $head = (& git -C $root rev-parse HEAD).Trim()
      $tree = & $fingerprint $root
      & $writeMarker $root $head $tree
      $without = (& $run $root $null) -split "`n"
      $with = (& $run $root $id) -split "`n"
      if ($without.Count -ne $with.Count) { throw 'the identity changed more than the mode line' }
      for ($i = 0; $i -lt $without.Count - 1; $i++) {
        if ($without[$i] -ne $with[$i]) { throw "line $($i + 1) changed with the identity present: $($with[$i])" }
      }
      if ($with[-1].Trim() -ne $wantLine.Groups[1].Value.Trim()) {
        throw "the mode line reads '$($with[-1])'; the fixture states '$($wantLine.Groups[1].Value)'"
      }
    }
    finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
    $true
  }

  # The downgrade is the whole risk this design accepted, so the report saying
  # which mode it ran in is the mitigation and not a nicety. A run that attests on
  # the commit alone and does not say so is indistinguishable from the stronger one.
  Assert "every report states the mode it ran in, in both directions" {
    $root = & $mkRepo
    try {
      $head = (& git -C $root rev-parse HEAD).Trim()
      & $writeMarker $root $head (& $fingerprint $root)
      $weak = (& $run $root $null) -split "`n"
      if ($weak[-1] -notmatch 'commit-only') { throw "the weaker run does not name its mode: $($weak[-1])" }
      $strong = (& $run $root 'test-run-id') -split "`n"
      if ($strong[-1] -notmatch 'session') { throw "the stronger run does not name its mode: $($strong[-1])" }
    }
    finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
    $true
  }

  Assert "the receipt records what was observed, and which mode observed it" {
    $root = & $mkRepo
    try {
      $head = (& git -C $root rev-parse HEAD).Trim()
      $tree = & $fingerprint $root
      # The marker deliberately holds a tree that is not the live one. Writing a
      # marker that agrees with the tree makes the two indistinguishable, and a
      # receipt echoing the marker would pass — which is the whole distinction
      # this assertion exists to draw, and it was vacuous until the fire-check
      # perturbed the script to echo the marker and nothing went red.
      & $writeMarker $root $head 'a-tree-the-clone-does-not-have'
      $null = & $run $root 'test-run-id'
      $r = Get-Content (Join-Path $root '.claude/position/receipt.json') -Raw | ConvertFrom-Json
      if ($r.head -ne $head) { throw "the receipt holds head '$($r.head)', observed '$head'" }
      if ($r.tree -ne $tree) { throw "the receipt holds tree '$($r.tree)', observed '$tree'" }
      if ($r.run -ne 'test-run-id') { throw "the receipt holds run '$($r.run)'" }
      if ($r.mode -ne 'session') { throw "the receipt holds mode '$($r.mode)'" }

      # A refusal is a computed position whose answer is *unverified*, so it is
      # attested like any other — a clone with no marker must still be able to
      # commit, and a receipt withheld here would make that impossible.
      Remove-Item (Join-Path $root '.claude/position/marker.json') -Force
      Remove-Item (Join-Path $root '.claude/position/receipt.json') -Force
      $null = & $run $root $null
      $r = Get-Content (Join-Path $root '.claude/position/receipt.json') -Raw | ConvertFrom-Json
      if ($r.mode -ne 'commit-only') { throw "a refusal recorded mode '$($r.mode)'" }
      if ($null -ne $r.run) { throw 'a run without the identity recorded one anyway' }
      if ($r.head -ne $head) { throw 'a refusal did not record the position it observed' }
    }
    finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
    $true
  }

  # Found by the fixture and by nothing else: the refusal lines carried an arrow,
  # and a console codepage that is not UTF-8 delivered it as `?` in a report that
  # still read correctly. Written output is compared as bytes; emitted output goes
  # through whatever encoding the shell has, so the two obligations differ.
  Assert "what the script emits is ASCII, and the page says why" {
    $c = Get-SkillFile $page
    if ($c -notmatch '(?i)ASCII') { throw 'the page does not state that emitted output is ASCII' }
    $nonAscii = @((& $expectedBlocks) | Where-Object { $_ -match '[^\x00-\x7F]' })
    if ($nonAscii) { throw "a fixture's expected output is not ASCII: $($nonAscii[0])" }

    $root = & $mkRepo
    try {
      $head = (& git -C $root rev-parse HEAD).Trim()
      & $writeMarker $root $head 'not-the-live-tree'
      foreach ($out in @((& $run $root $null), (& $run $root 'test-run-id'))) {
        if ($out -match '[^\x00-\x7F]') {
          $bad = [regex]::Match($out, '[^\x00-\x7F]').Value
          throw ("the script emitted U+{0:X4}, which does not survive a non-UTF-8 console" -f [int][char]$bad)
        }
      }
      # And the refusal path, which is where the arrow lived.
      Remove-Item (Join-Path $root '.claude/position/marker.json') -Force
      $out = & $run $root $null
      if ($out -match '[^\x00-\x7F]') { throw 'a refusal emitted a character that is not ASCII' }
    }
    finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
    $true
  }

  Assert "the tool guide names the script for the composite read, and keeps the invocations" {
    $g = Get-RepoText '.claude/tools/git.md'
    if ($g -notmatch [regex]::Escape('.claude/scripts/report-position.ps1')) {
      throw 'the guide does not name the script'
    }
    # A reader without the script still needs these, and the script is derived
    # from a specification rather than copied — so naming it never replaces them.
    foreach ($read in 'cat-file -e', 'merge-base --is-ancestor', 'write-tree', 'rev-list --count') {
      if ($g -notmatch [regex]::Escape($read)) { throw "the guide dropped the invocation: $read" }
    }
    $true
  }
}

# --- ticket receipt/03 — configure derives every specified script --------------

Describe-Ticket 'receipt/03' 'configure derives every script the page specifies' {

  $page = 'configure/SCRIPTS.md'
  $skill = 'configure/SKILL.md'

  # Both directions, read from the artefacts rather than from a list here. A
  # stage that names its scripts individually is right until the page grows a
  # section, and what that produces is a configured repository whose commit gate
  # has no input — a failure that surfaces in a stage that cannot fix it.
  Assert "the stage derives from the page, and names no script the page does not specify" {
    $c = Get-SkillFile $skill
    $specified = @([regex]::Matches((Get-SkillFile $page), '`\.claude/scripts/([a-z-]+)\.<ext>`') |
        ForEach-Object { $_.Groups[1].Value }) | Sort-Object -Unique
    if (-not $specified) { throw 'no script is specified by the page' }
    $named = @([regex]::Matches($c, '\.claude/scripts/([a-z-]+)\.') |
        ForEach-Object { $_.Groups[1].Value }) | Sort-Object -Unique
    $invented = @($named | Where-Object { $specified -notcontains $_ })
    if ($invented) { throw "/configure names a script the page does not specify: $($invented -join ', ')" }
    # Naming the directory and the page is what makes the derivation total; a
    # stage naming one script by hand is the list this guard exists to refuse.
    if ($c -notmatch [regex]::Escape('.claude/scripts/')) { throw '/configure does not name the scripts directory' }
    if ($c -notmatch [regex]::Escape('SCRIPTS.md')) { throw '/configure does not point at the derivation page' }
    $true
  }

  Assert "a script that fails its own fixture stops the stage" {
    $c = Get-SkillFile $skill
    if ($c -notmatch '(?i)fixture') { throw '/configure does not mention the fixture' }
    if ($c -notmatch '(?i)stops this stage|stops the stage') {
      throw '/configure does not say a fixture mismatch stops it'
    }
    # Reported-and-passed is the failure mode, not silence: a stage that says
    # "the fixture did not match" and installs the script anyway has told the
    # truth and done the wrong thing.
    if ($c -notmatch '(?i)not reported and passed|rather than being reported and passed') {
      throw '/configure does not refuse the reported-and-passed path'
    }
    $true
  }

  Assert "the audit covers the scripts directory against the page, in both directions" {
    $audit = Get-Section (Get-SkillFile $skill) 'Audit, where AEP is already here'
    if ($audit -notmatch [regex]::Escape('.claude/scripts/')) {
      throw 'the audit branch never re-checks the scripts directory'
    }
    if ($audit -notmatch '(?i)both directions') {
      throw 'the audit does not state that the check runs in both directions'
    }
    if ($audit -notmatch '(?i)fixture') {
      throw 'the audit re-checks which scripts exist but never that they still derive correctly'
    }
    $true
  }

  # The category rule is what `0012` named the category for: a fourth Position
  # file would otherwise be a fourth exception for this stage to be told about,
  # and the one nobody remembers is the one that gets committed.
  Assert "the receipt is ignored by the category, with nothing naming it individually" {
    $ignore = Get-Content (Join-Path $repo '.claude/.gitignore') -Raw
    if ($ignore -match '(?i)receipt') { throw 'the ignore file names the receipt individually' }
    $covered = & git -C $repo check-ignore -q '.claude/position/receipt.json' 2>$null; $ok = ($LASTEXITCODE -eq 0)
    if (-not $ok) { throw 'the receipt is not ignored — a Position file would be committed' }
    if ((Get-SkillFile $skill) -notmatch '(?i)states the category, not a list') {
      throw '/configure does not require the ignore file to state the category'
    }
    $true
  }
}

# --- ticket receipt/04 — commit refuses an unattested position ----------------

Describe-Ticket 'receipt/04' 'commit refuses an unattested position, and the protocol stops overclaiming' {

  function Get-RepoText {
    param([string]$RelativePath)
    $p = Join-Path $repo $RelativePath
    if (-not (Test-Path $p)) { throw "$RelativePath is missing" }
    Get-Content $p -Raw
  }

  # Both ends: the shipped template is what every other repository is configured
  # from, and the installed copy is what this one reads. A correction to one is a
  # correction nobody else gets, or one this repository never applies.
  # Scoped to the section that makes the claim, not the file. Unscoped, the
  # receipt guard matched a sentence about verification at use that has sat
  # further up since the Marker gained its tree fact — so deleting the claim
  # being asserted left it green, which is the fifth guard in this effort found
  # reading a wider region than the claim it was making.
  $protocols = @{
    'skills/configure/protocol.template.md' = { Get-Section (Get-SkillFile 'configure/protocol.template.md') 'Reported, every time' }
    '.claude/protocol.md'                   = { Get-Section (Get-RepoText '.claude/protocol.md') 'Reported, every time' }
  }

  Assert "no protocol claims that reporting makes a lapse visible" {
    foreach ($name in $protocols.Keys) {
      $c = & $protocols[$name]
      if ($c -match '(?i)makes a lapse visible') {
        throw "$name still claims reporting makes a lapse visible — a well-formed report is producible without doing the work"
      }
      if ($c -match '(?i)the only evidence the discipline ran') {
        throw "$name still calls the report the only evidence the discipline ran"
      }
    }
    $true
  }

  Assert "every protocol separates the computed half from the judged half" {
    foreach ($name in $protocols.Keys) {
      $c = & $protocols[$name]
      if ($c -notmatch '(?i)judge?ment') { throw "$name does not name the judgement half" }
      if ($c -notmatch '(?i)no script can produce it|cannot be (mechanised|computed)') {
        throw "$name does not say the judgement half is beyond a script"
      }
      if ($c -notmatch '(?i)quotes? that output') {
        throw "$name does not say the stage quotes the computed output rather than composing one"
      }
    }
    $true
  }

  # The narrowing is the decision, not an omission from it. A guard whose claim is
  # read wider than it holds is the failure this repository has shipped more than
  # once, and this is the sentence that stops the Receipt being read that way.
  Assert "every protocol states what a receipt does not attest" {
    foreach ($name in $protocols.Keys) {
      $c = & $protocols[$name]
      if ($c -notmatch '(?i)receipt') { throw "$name never mentions the Receipt" }
      if ($c -notmatch '(?i)never that the stage read it|not that the stage') {
        throw "$name does not state that attestation stops at computation"
      }
      if ($c -notmatch '(?i)verification at use is (untouched|unaffected)') {
        throw "$name does not say verification at use is unaffected by the Receipt"
      }
    }
    $true
  }

  Assert "the commit stage refuses a position no receipt attests, recoverably" {
    $s = Get-Section (Get-SkillFile 'commit/SKILL.md') 'Confirm the stages ran'
    if ($s -notmatch '(?i)receipt') { throw 'the commit stage never reads the Receipt' }
    # Recoverable, because a skipped verification and a deleted Position directory
    # leave the same absence and only one is a defect.
    if ($s -notmatch '(?i)name the script|names? the script to run') {
      throw 'the refusal does not name the script to run'
    }
    if ($s -notmatch '(?i)recoverable') { throw 'the refusal is not stated as recoverable' }
    $true
  }

  Assert "the weaker attestation is accepted saying so, never passed as the stronger one" {
    $s = Get-Section (Get-SkillFile 'commit/SKILL.md') 'Confirm the stages ran'
    if ($s -notmatch '(?i)run identity') { throw 'the commit stage does not distinguish the two modes' }
    if ($s -notmatch '(?i)silent downgrade|passing it as though|as though it were the stronger') {
      throw 'the commit stage does not refuse to pass the weaker attestation as the stronger'
    }
    $true
  }

  Assert "the check reads state and re-executes nothing" {
    $s = Get-Section (Get-SkillFile 'commit/SKILL.md') 'Confirm the stages ran'
    if ($s -notmatch '(?i)none re-executes anything') { throw 'the stage no longer says it re-executes nothing' }
    if ($s -notmatch '(?i)nothing to recompute|recomputing would defeat') {
      throw 'the position question does not say why recomputing it here would answer about itself'
    }
    $true
  }

  # The examples are what a reader copies. One showing the two halves run together
  # teaches the shape this effort exists to take apart — and its computed half has
  # to be the script's real output, not a sketch of it.
  Assert "every stage's report example shows the computed half in the script's own shape" {
    foreach ($f in 'implement/SKILL.md', 'commit/SKILL.md') {
      $c = (Get-SkillFile $f) -replace "`r", ''
      $blocks = @([regex]::Matches($c, '(?ms)^```\r?\n(Position\r?\n.*?)^```') |
          ForEach-Object { $_.Groups[1].Value })
      if (-not $blocks) { throw "$f shows no position report" }
      foreach ($b in $blocks) {
        foreach ($label in 'marker', 'tree', 'drift', 'mode') {
          if ($b -notmatch "(?m)^  $label\s") { throw "$f's report example has no '$label' line" }
        }
        if ($b -match '(?m)^\s*→') { throw "$f's example uses an arrow the report no longer emits" }
      }
    }
    $true
  }
}

# --- ticket line-endings/01 — assertions do not depend on the checkout -------

# `Get-Frontmatter` strips carriage returns and says it is "the one place
# frontmatter is extracted". It was not — five other places extracted their own,
# and the two failure shapes are different from each other:
#
#   read the whole file and match the field against it, extracting nothing.
#     The `\r` sits between the value and the line end, `[ \t]*$` cannot consume
#     it, and the field reads as absent. This is the one that failed.
#
#   extract frontmatter with a private copy of the pattern that does not strip.
#     This one passed, and the reason is worth recording: both protocol files
#     declare a single field, so the closing `\r?\n---` consumed the only
#     carriage return there was. Declaring a second field would have broken it.
#
# One guard cannot cover both, because only the first has the read and the match
# in one statement — which is why the guard that catches it is scoped to a
# statement and the guard that catches the second is scoped to extraction. A
# single line-scoped guard was written first and caught only the failing shape;
# it is the guard-that-cannot-fire failure `.claude/rules/skills.md` describes,
# found by review rather than by the suite.
Describe-Ticket 'line-endings/01' 'assertions stop depending on the checkout''s line endings' {

  # The mechanism, proved rather than assumed. Multi-line frontmatter
  # deliberately: a single-line fixture passes even when the stripping is
  # removed, which is exactly how the second site above hid.
  Assert "the frontmatter reader returns every field from a CRLF file" {
    $crlf = "---`r`naep-version: 9.9.9`r`nstatus: accepted`r`n---`r`n`r`n# Body`r`n"
    $fm = Get-Frontmatter $crlf
    if ($null -eq $fm) { throw 'no frontmatter was found in a CRLF file' }
    if ($fm -match "`r") { throw 'the reader returned text still carrying a carriage return' }
    foreach ($pair in @(@('aep-version', '9.9.9'), @('status', 'accepted'))) {
      $m = [regex]::Match($fm, "(?m)^$($pair[0]):[ \t]*(\S+)[ \t]*$")
      if (-not $m.Success) { throw "$($pair[0]) read as absent from a CRLF file" }
      if ($m.Groups[1].Value -ne $pair[1]) { throw "$($pair[0]) read as '$($m.Groups[1].Value)'" }
    }
    $true
  }

  # The shape that failed. Scoped to a *statement* rather than a line, because
  # the read and the match are routinely spread over several: the first version
  # of this compared one line at a time and was blind to every multi-line form.
  #
  # Fragility is asked of the pattern rather than assumed from its spelling — an
  # anchor that can consume `\r` is safe however it is written, and one that
  # cannot is fragile however it is written. Safety is likewise asked of the
  # expression, not looked up in a list of helper names: the first version named
  # three readers and the suite has a dozen.
  Assert "no statement matches a frontmatter field against text it read raw" {
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
      (Join-Path $repo 'scripts/verify.ps1'), [ref]$null, [ref]$parseErrors)
    if ($parseErrors) { throw "the suite no longer parses: $($parseErrors[0].Message)" }

    # Fragile means the match *fails* when a carriage return is present — not
    # merely that it captures one. `(.+)$` and `\s*$` still match and are left
    # alone; a field read ending in a class that excludes `\r` does not match at
    # all, and that is the defect. The subject is therefore a frontmatter field
    # read specifically, which is also what keeps markdown tables and headings —
    # line-anchored, but not fields — out of this.
    $fragile = {
      param([string]$Pattern)
      if ($Pattern -notmatch '^\(\?[a-z]*m[a-z]*\)\^\[?[\w \\t\]+-]*[\w-]+:') { return $false }
      $bare = $Pattern -replace '\$[A-Za-z_{(]', ''
      if ($bare -notmatch '\$') { return $false }
      if ($bare -match '\\s\*\$') { return $false }
      $bare -notmatch '\(\.[+*]\)\$'
    }

    $offenders = @()
    foreach ($stmt in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.StatementAst] }, $true)) {
      $text = $stmt.Extent.Text
      if ($text -match 'Get-Frontmatter' -or $text -match '-replace\s*"`r"') { continue }
      if ($text -notmatch 'Get-Content[^\r\n]*-Raw|Get-SkillFile|Get-SkillText|Get-RepoText|ReadAllText') { continue }
      $patterns = $stmt.FindAll({
          param($n) $n -is [System.Management.Automation.Language.StringConstantExpressionAst]
        }, $true)
      foreach ($p in $patterns) {
        if (& $fragile $p.Value) {
          $offenders += "line $($stmt.Extent.StartLineNumber): $($p.Value)"
          break
        }
      }
    }
    if ($offenders) {
      throw "a field is read from unstripped text at $($offenders -join '; ') — extract through Get-Frontmatter"
    }
    $true
  }

  # The shape that hid. Its defining act is extracting frontmatter with a private
  # copy of the pattern, which no statement-scoped check can see — the extraction
  # and the field read are separate statements joined only by a variable.
  #
  # So this asks the narrower question that actually distinguishes it: who
  # extracts. The single home is allowed to; nothing else is, whether or not it
  # remembers to strip. That is what makes `Get-Frontmatter`'s own comment true
  # rather than aspirational.
  Assert "frontmatter is extracted in one place, and that place strips carriage returns" {
    $lines = Get-Content (Join-Path $repo 'scripts/verify.ps1')
    $extractors = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
      # The frontmatter-capturing shape specifically. A pattern that captures
      # what follows the closing delimiter is reading the body, which is a
      # different subject and is left alone.
      if ($lines[$i] -match '\\A---\\r\?\\n\(\.\*\\?\?\)') { $extractors += $i + 1 }
    }
    if ($extractors.Count -ne 1) {
      throw "frontmatter is extracted at lines $($extractors -join ', ') — it belongs in Get-Frontmatter alone"
    }
    $first = $extractors[0] - 1
    $last = [Math]::Min($first + 2, $lines.Count - 1)
    if (($lines[$first..$last] -join "`n") -notmatch '-replace\s*"`r"') {
      throw 'the one extractor no longer strips carriage returns'
    }
    $true
  }
}

# --- ticket line-endings/02 — the checkout pins its ending, the script emits it

# Every assertion here asks git, or runs the script and reads the bytes. None
# reads the attributes file's text, for the reason the `agentic/01` block gives
# about ignore rules: a pattern can be present and reach nothing — unanchored,
# or shadowed by a later line — and only git knows which ending a path gets.
#
# Paths go to `git check-attr` as arguments rather than down `--stdin`. A
# PowerShell pipe joins its input with the platform's ending, so a path arrives
# as `scripts/verify.ps1\r` and git answers about a file of that name; here `*`
# matches it anyway and the wrong answer is indistinguishable from the right
# one. Verified by running it — the trailing `\r` comes back quoted in git's
# own echo of the path.
Describe-Ticket 'line-endings/02' 'the checkout pins its line ending, and the regenerator emits it' {

  # Batched because the subject is *every* tracked file. A sample passes while a
  # pattern that reaches only part of the tree leaves the rest a function of
  # `core.autocrlf`, which is the divergence this ticket removes; 100 at a time
  # keeps the argument list well inside what a process can be handed.
  $eolValues = {
    $all = @(& git -C $repo ls-files)
    if ($all.Count -eq 0) { throw 'git reported no tracked files' }
    $seen = @{}
    for ($i = 0; $i -lt $all.Count; $i += 100) {
      $chunk = $all[$i..([Math]::Min($i + 99, $all.Count - 1))]
      foreach ($line in (& git -C $repo check-attr eol -- @chunk)) {
        if ($line -match ':\s*eol:\s*(\S+)\s*$') { $seen[$Matches[1]] = $true }
      }
    }
    $seen.Keys
  }

  # The outcome rather than the entry: what fails this is a tree where two
  # clones can hold different bytes for one commit, however that came about.
  # `unspecified` is the state before the pin existed, and one file left in it
  # is enough — that file is the one whose ending is still a local setting's.
  Assert "every tracked file has its working-tree ending pinned, asked of git" {
    $values = @(& $eolValues)
    if ($values -contains 'unspecified') {
      throw "the checkout's ending is unpinned for at least one tracked file — it is still a function of core.autocrlf there"
    }
    if ($values.Count -ne 1) {
      throw "the tree pins more than one ending: $($values -join ', ') — which files hold which becomes a fact somebody has to know"
    }
    $true
  }

  # ADR 0069 rejected pinning the generated indexes alone and pinning CRLF; what
  # neither of those turns on is *detection*, and forcing `text` is the way this
  # goes wrong silently. There is nothing binary tracked here today, so the
  # damage would land on whoever adds the first one — which is why this checks
  # the mechanism rather than counting the tree's current contents.
  Assert "the pin lets git decide what is text, so nothing binary is converted" {
    $probe = @('README.md', 'scripts/verify.ps1', '.claude/scripts/regenerate-indexes.ps1')
    foreach ($line in (& git -C $repo check-attr text -- @probe)) {
      if ($line -notmatch ':\s*text:\s*(\S+)\s*$') { throw "could not read the text attribute: $line" }
      if ($Matches[1] -ne 'auto') {
        throw "the text attribute is '$($Matches[1])', not auto — conversion no longer depends on git detecting text, so a binary file would be normalised"
      }
    }
    $true
  }

  # The agreement, which is the whole of the defect: `SCRIPTS.md` requires the
  # checkout's ending, and the script wrote the platform's because nothing made
  # the checkout's obtainable. So the pinned value is read from git rather than
  # written here — a literal would pass by matching itself while the two drifted
  # apart, and the two drifting apart is the failure.
  #
  # What this cannot see, stated rather than left to be discovered: where the
  # pin happens to name the running platform's own ending, the defect and the
  # correct answer produce identical bytes and no behavioural check can tell
  # them apart. It fires here, on Windows under an LF pin, which is the
  # configuration the defect was invisible in.
  Assert "the regenerator emits the ending the checkout pins, not the platform's" {
    $pinned = $null
    foreach ($line in (& git -C $repo check-attr eol -- '.claude/contexts/map.md')) {
      if ($line -match ':\s*eol:\s*(\S+)\s*$') { $pinned = $Matches[1] }
    }
    if (-not $pinned -or $pinned -eq 'unspecified') { throw 'the tree pins no ending to compare the script against' }

    $root = & $mkIndexTree @{}
    try {
      foreach ($family in 'contexts', 'decisions') {
        Copy-Item (Join-Path $repo ".claude/$family") (Join-Path $root ".claude/$family") -Recurse
      }
      $r = & $runRegenerator $root
      if ($r.ExitCode -ne 0) { throw "the regenerator failed: $($r.Output)" }
      foreach ($family in 'contexts', 'decisions') {
        $bytes = [System.IO.File]::ReadAllBytes((Join-Path $root ".claude/$family/map.md"))
        # Read as bytes, because every text reader in .NET hides the difference
        # this is looking for.
        $cr = 0x0D; $lf = 0x0A
        for ($i = 0; $i -lt $bytes.Length; $i++) {
          if ($bytes[$i] -eq $lf) {
            $precededByCr = ($i -gt 0 -and $bytes[$i - 1] -eq $cr)
            if ($pinned -eq 'lf' -and $precededByCr) {
              throw "$family/map.md was written CRLF at byte $i while the checkout pins lf — the byte comparison would report this as a stale index"
            }
            if ($pinned -eq 'crlf' -and -not $precededByCr) {
              throw "$family/map.md was written LF at byte $i while the checkout pins crlf — the byte comparison would report this as a stale index"
            }
          }
          if ($pinned -eq 'lf' -and $bytes[$i] -eq $cr) {
            throw "$family/map.md carries a carriage return at byte $i while the checkout pins lf"
          }
        }
      }
    } finally { Remove-Item -LiteralPath $root -Recurse -Force }
    $true
  }

  # The record, not the code. `declared-fields/05` filed this as a live cost of
  # the environment, and that framing is why nothing acted on it for several
  # releases — an environmental limitation has nobody to fix it. Anchored on the
  # false claim itself rather than on the wording that replaced it, so it fires
  # if the old framing comes back under any phrasing of the correction.
  Assert "the limitation recorded against the regenerator is closed, as a script defect" {
    $t = Get-Content (Join-Path $repo '.claude/tickets/declared-fields/issues/05-the-index-regenerator-and-its-comparison.md') -Raw
    if ($t -match '(?i)remains a live limitation') {
      throw 'the limitation is still recorded as live'
    }
    if ($t -notmatch '(?i)`?\.gitattributes`?') {
      throw 'the record does not name what closed it'
    }
    if ($t -notmatch '(?i)defect in (a|the) (derived )?script|script defect') {
      throw 'the record does not say it was a defect in the script rather than a cost of the environment'
    }
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
