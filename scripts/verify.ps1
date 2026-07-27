<#
.SYNOPSIS
  Asserts the acceptance criteria of the Tenure build tickets against ./skills.

.DESCRIPTION
  Tenure ships as markdown, so there is no compiler to catch a broken build.
  This script is the substitute: every mechanically checkable acceptance
  criterion in .scratch/tenure/issues/ gets one assertion here, named after
  the ticket that demands it.

  A criterion that cannot be checked mechanically (does the grill actually
  grill?) is out of scope by design — those are settled by the Phase 2
  dogfood run, not by a script.

.PARAMETER Ticket
  Run only the assertions for one ticket, e.g. -Ticket 01. Omit to run all.

.EXAMPLE
  pwsh scripts/verify.ps1
  pwsh scripts/verify.ps1 -Ticket 03
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

function Describe-Ticket {
  param([string]$Id, [string]$Name, [scriptblock]$Body)
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

# --- ticket 01 — vendor the primitives ---------------------------------------

Describe-Ticket '01' 'vendor the primitives and rewrite their paths' {

  $primitives = @('grilling', 'tdd', 'codebase-design', 'domain-modeling')

  foreach ($p in $primitives) {
    Assert "$p is vendored into ./skills" {
      Test-Path (Join-Path $skills "$p/SKILL.md")
    }
  }

  # The headline criterion: no legacy path survives anywhere under ./skills.
  # `CONTEXT.md` is matched case-sensitively so Tenure's lowercase
  # `.claude/context.md` does not trip it.
  $legacy = @{
    'CONTEXT\.md'     = 'CONTEXT.md (use .claude/context.md)'
    'CONTEXT-MAP\.md' = 'CONTEXT-MAP.md (use the routing table)'
    'docs/adr/'       = 'docs/adr/ (use .claude/docs/decisions/)'
    '\.scratch/'      = '.scratch/ (use .claude/tickets/)'
  }
  foreach ($pattern in $legacy.Keys) {
    $label = $legacy[$pattern]
    Assert "no file under ./skills references $label" {
      $hits = Get-SkillFiles |
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
    $userInvoked = $primitives | Where-Object {
      $fm = Get-Frontmatter (Get-SkillFile "$_/SKILL.md")
      $fm -match 'disable-model-invocation:\s*true'
    }
    if ($userInvoked) { throw "user-invoked but must be reachable: $($userInvoked -join ', ')" }
    $true
  }
}

# --- ticket 15 — tool reference ----------------------------------------------

Describe-Ticket '15' 'tool reference — how to drive every tool the workflow touches' {

  # file → the binary its entries invoke. The file is named for the platform,
  # the commands are named for the executable, and they are not the same word.
  $tools = [ordered]@{
    'git'      = 'git'
    'github'   = 'gh'
    'gitlab'   = 'glab'
    'graphite' = 'gt'
  }

  Assert "the tools reference ships as a skill" {
    Test-Path (Join-Path $skills 'tools/SKILL.md')
  }

  Assert "tools is model-invoked — any skill can reach it" {
    $fm = Get-Frontmatter (Get-SkillFile 'tools/SKILL.md')
    if (-not $fm) { throw 'tools/SKILL.md has no frontmatter' }
    $fm -notmatch 'disable-model-invocation:\s*true'
  }

  foreach ($f in $tools.Keys) {
    Assert "$f.md ships with the reference" {
      Test-Path (Join-Path $skills "tools/$f.md")
    }
  }

  # "A URL with no trigger is decoration." Both halves, in every tool file.
  foreach ($f in $tools.Keys) {
    Assert "$f.md names its docs URL and the condition for fetching it" {
      $c = Get-SkillFile "tools/$f.md"
      if (-not $c) { throw "tools/$f.md is missing" }
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
      $lines = (Get-SkillFile "tools/$f.md") -split '\r?\n'
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
    $c = Get-SkillFile 'tools/gitlab.md'
    $c -match '(?i)not verified|without a `?glab`? on the machine'
  }

  Assert "git.md carries the operations Tenure depends on and gets wrong easily" {
    $c = Get-SkillFile 'tools/git.md'
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

  Assert "tier 2 is documented — /configure writes .claude/tools/ for the repo's own tooling" {
    $c = Get-SkillFile 'tools/SKILL.md'
    ($c -match '\.claude/tools/') -and ($c -match '/configure')
  }

  # The headline criterion. Every invocation a skill issues has to be an entry
  # somewhere in the reference — a skill that writes `gh issue develop` without
  # `gh.md` listing it has guessed.
  Assert "no skill issues a command for a tool with no entry" {
    # binary → the reference text that must list it
    $reference = @{}
    foreach ($f in $tools.Keys) { $reference[$tools[$f]] = Get-SkillFile "tools/$f.md" }
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
    $c = Get-SkillFile 'tools/git.md'
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
    $c = Get-SkillFile 'tools/git.md'
    if ($c -notmatch '(?m)^git bisect run') { throw 'bisect cannot be driven unattended' }
    if ($c -notmatch '(?m)^git bisect reset') { throw 'the reset is missing' }
    $c -match '(?i)detached HEAD|bisect state'
  }

  Assert "the review reads staged, unstaged, and untracked — not just the commit range" {
    $c = Get-SkillFile 'tools/git.md'
    if ($c -notmatch '(?m)^git diff HEAD\b') { throw 'staged changes are not read' }
    $c -match '(?m)^git ls-files --others --exclude-standard'
  }
}

# --- ticket 02 — verification at use, healing where the break is found --------

# The always-on half of the discipline. ADR 0007: a rule that must hold
# unconditionally has to live in CLAUDE.md, because a rule inside a skill only
# fires when that skill runs. /configure (ticket 08) installs this template.
$claudeTemplate = 'configure/CLAUDE.template.md'

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
  'the tools routing rule'             = "(?i)covers the workflow'?s own tools"
  'never guess an API'                 = '(?i)a CLI is an API'
  'conventions are defaults'           = '(?i)defaults? for when the repository is silent'
  'one concept per file'               = '(?i)one concept per file'
  'the test-layout rule'               = '(?i)unnecessary test structure'
  'self-explanatory code'              = '(?i)self-explanatory'
  'the compression test'               = '(?i)will this improve (a )?future engineering decision'
  'the knowledge-layer table'          = '(?im)^\|\s*Codebase\s*\|'
}

Describe-Ticket '02' 'verification at use, healing where the break is found' {

  Assert "the always-on rules ship as the CLAUDE.md template /configure installs" {
    Test-Path (Join-Path $skills $claudeTemplate)
  }

  Assert "CLAUDE.md stays an entrypoint, not a manual — under 200 lines" {
    $n = ((Get-SkillFile $claudeTemplate) -split '\r?\n').Count
    if ($n -ge 200) { throw "$n lines" }
    $true
  }

  Assert "the Marker rule states the trusted path — matching HEAD plus a clean tree costs no reading" {
    $c = Get-SkillFile $claudeTemplate
    if (-not $c) { throw 'template is missing' }
    ($c -match 'marker\.json') -and
    ($c -match '(?i)clean') -and
    ($c -match '(?i)HEAD')
  }

  Assert "the clean path costs one git check and no reading" {
    $c = Get-SkillFile $claudeTemplate
    $c -match '(?i)(no reading|without reading|read nothing)'
  }

  Assert "both drift sources are named, with the command that reads each" {
    $c = Get-SkillFile $claudeTemplate
    $missing = @()
    if ($c -notmatch 'git diff --name-only') { $missing += 'committed drift' }
    if ($c -notmatch 'git status --porcelain') { $missing += 'uncommitted drift' }
    if ($missing) { throw "unreadable: $($missing -join ', ')" }
    $true
  }

  Assert "the non-ancestor case is covered — a moved HEAD makes the diff meaningless" {
    $c = Get-SkillFile $claudeTemplate
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
    $c = Get-SkillFile $claudeTemplate
    ($c -match '/commit') -and ($c -match '(?i)nothing else (moves|advances)|only `?/commit`?')
  }

  Assert "the Marker is machine-local — a teammate's verification is not Claude's" {
    $c = Get-SkillFile $claudeTemplate
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

# --- ticket 03 — /design, the whole planning surface -------------------------

Describe-Ticket '03' 'the whole planning surface' {

  Assert "/design ships as a skill" {
    Test-Path (Join-Path $skills 'design/SKILL.md')
  }

  Assert "/design is user-invoked — planning starts because the user asked for it" {
    $fm = Get-Frontmatter (Get-SkillFile 'design/SKILL.md')
    if (-not $fm) { throw 'design/SKILL.md has no frontmatter' }
    $fm -match 'disable-model-invocation:\s*true'
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
    $lifecycle = @('open', 'claimed', 'blocked', 'resolved', 'obsolete')
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

# --- ticket 04 — /implement, build and record what moved ---------------------

Describe-Ticket '04' 'build, and record what moved' {

  Assert "/implement ships as a skill" {
    Test-Path (Join-Path $skills 'implement/SKILL.md')
  }

  # Spec, Scope: the spine is model-invoked. Not, as ticket 04 claims, so
  # /design can reach it — ticket 03 forbids exactly that. The router (10) is
  # the caller this is actually for.
  Assert "/implement is model-invoked — the spine is reachable" {
    $fm = Get-Frontmatter (Get-SkillFile 'implement/SKILL.md')
    if (-not $fm) { throw 'implement/SKILL.md has no frontmatter' }
    $fm -notmatch 'disable-model-invocation:\s*true'
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
    # frontier, and the next /implement claims it into the same wall.
    if ($c -notmatch '(?i)unclaim.{0,60}Status:\s*blocked') { throw 'the ticket is not left blocked on hand-back' }
    if ($c -match '(?i)unclaim.{0,60}Status:\s*open') { throw 'hand-back returns the ticket to the frontier' }
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

  # ADR 0007 places these in /implement and /code-review both — the skill that
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
  Assert "/code-review closes the work out before the commit question" {
    $c = Get-SkillFile 'implement/SKILL.md'
    $review = $c.IndexOf('/code-review')
    $ask = $c.IndexOf('commit and resolve this ticket')
    if ($review -lt 0) { throw '/code-review is never invoked' }
    if ($ask -lt 0) { throw 'the close-out question is never asked' }
    if ($review -gt $ask) { throw 'review comes after the commit question' }
    $c -match '(?i)/code-review.{0,40}before\*{0,2} the commit question'
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

# --- ticket 05 — /code-review, two axes --------------------------------------

Describe-Ticket '05' 'review axes for Tenure' {

  Assert "/code-review ships as a skill" {
    Test-Path (Join-Path $skills 'code-review/SKILL.md')
  }

  # Decision 13: the name is load-bearing. Shipping as `review` shadows the
  # built-in GitHub PR reviewer, which is a capability lost silently.
  Assert "it ships as /code-review, not /review — the built-in PR reviewer is preserved" {
    if (Test-Path (Join-Path $skills 'review')) { throw 'skills/review/ exists and shadows the built-in' }
    $fm = Get-Frontmatter (Get-SkillFile 'code-review/SKILL.md')
    if (-not $fm) { throw 'code-review/SKILL.md has no frontmatter' }
    $fm -match '(?m)^name:\s*code-review\s*$'
  }

  # Spec, Scope: model-invoked, because /implement closes out through it and
  # /commit confirms it ran.
  Assert "/code-review is model-invoked — /implement and /commit can reach it" {
    $fm = Get-Frontmatter (Get-SkillFile 'code-review/SKILL.md')
    $fm -notmatch 'disable-model-invocation:\s*true'
  }

  Assert "two axes — Spec and Standards" {
    $c = Get-SkillFile 'code-review/SKILL.md'
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
    $c = Get-SkillFile 'code-review/SKILL.md'
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
    $c = Get-SkillFile 'code-review/SKILL.md'
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
    $c = Get-SkillFile 'code-review/SKILL.md'
    $c -match '(?i)ownership boundar[a-z]+ in `?\.claude/context\.md'
  }

  Assert "architecture reaches abstraction the change did not require" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    $c -match '(?i)abstraction.{0,120}(did ?n.t|did not|does ?n.t|does not|no[t]? .{0,20}require|unnecessary)|(unnecessary|speculative).{0,40}abstraction'
  }

  # Headline acceptance criterion: "A diff contradicting an existing ADR is
  # surfaced explicitly, not silently accepted."
  Assert "a diff contradicting an ADR is surfaced explicitly, never silently accepted" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '\.claude/docs/decisions') { throw 'the decisions are never read' }
    $c -match '(?i)(contradict|conflict).{0,160}(surfac|report|explicit|say|flag)|(surfac|report|explicit|flag).{0,160}(contradict|conflict)'
  }

  # Decision 33. Without the third outcome the same finding is re-raised on
  # every future review, and the reader learns to skim.
  Assert "every finding is fixed, ticketed, or accepted-and-recorded" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    foreach ($outcome in @('fixed', 'ticketed', 'accepted')) {
      if ($c -notmatch "(?i)\b$outcome\b") { throw "the '$outcome' outcome is missing" }
    }
    $c -match '(?i)(re-?raise|raised again|every future review|again on every)'
  }

  # An acceptance goes to an ADR only when it passes the 3-of-3 test — and that
  # test has one home, in domain-modeling. Restating it here is the duplication
  # ADR 0007 exists to stop.
  Assert "an acceptance is recorded, and the ADR bar points at its one home" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)3-of-3') { throw 'the ADR bar is never named' }
    if ($c -match '(?i)hard to reverse') { throw 'the 3-of-3 test is restated instead of referenced' }
    $c -match '(?i)(ADR-FORMAT|domain-modeling)'
  }

  Assert "acceptance is the user's call, never the reviewer's" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    $c -match "(?i)accept.{0,80}(user's call|user decides|never the reviewer)|the user.{0,60}accept"
  }

  # Decision 21. A review is about a diff; once merged its subject is gone.
  Assert "reviews are never persisted, and no skill writes a reviews directory" {
    $c = Get-SkillFile 'code-review/SKILL.md'
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
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)\.claude/rules') { throw "this repo's own discovered standards are never read" }
    if ($c -notmatch '(?i)(cite|quote|name).{0,120}(standard|rule)') { throw 'a finding need not cite the standard it breaches' }
    $c -match '(?i)the repo(sitory)? (always )?(overrides|wins)|repo(sitory)?.{0,40}outrank'
  }

  # Progressive disclosure: the baseline is a dozen entries only the Standards
  # subagent needs, so it is a file that subagent opens — not context every
  # caller of /code-review pays for.
  Assert "the smell baseline is disclosed progressively, not inlined in SKILL.md" {
    $baseline = Get-SkillFile 'code-review/SMELLS.md'
    foreach ($smell in @('Feature Envy', 'Data Clumps', 'Primitive Obsession', 'Shotgun Surgery', 'Speculative Generality')) {
      if ($baseline -notmatch [regex]::Escape($smell)) { throw "the baseline is missing '$smell'" }
    }
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -match '(?i)feature envy') { throw 'the baseline is inlined in SKILL.md as well' }
    $c -match 'SMELLS\.md'
  }

  Assert "a baseline smell is a judgement call, never a hard violation" {
    $baseline = Get-SkillFile 'code-review/SMELLS.md'
    if ($baseline -notmatch '(?i)judgement call') { throw 'the baseline does not label itself a judgement call' }
    # The distinction has to reach the finding, not just the baseline file —
    # an unmarked finding reads as a standard to whoever receives it.
    $c = Get-SkillFile 'code-review/SKILL.md'
    $c -match '(?i)hard violation.{0,40}judgement call|judgement call.{0,40}hard violation'
  }

  # ADR 0007 places these two here by name: "comment and public-API rules in
  # /implement and /code-review". They are Tenure's own, applied even where the
  # repository documents neither — so they are not covered by the repo-first
  # ordering above, and nothing else in ./skills carries them.
  Assert "the comment and public-API rules ADR 0007 places here are carried" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)comments? explain \*{0,2}why') { throw 'the comment rule is missing' }
    if ($c -notmatch '(?i)public (interface|api)') { throw 'the public-API rule is missing' }
    $c -match '(?i)ADR 0007|0007'
  }

  # The primary caller reviews before committing (implement/SKILL.md §4), so
  # the whole change is uncommitted. A review that diffs only a commit range
  # sees nothing and reports a clean pass on it.
  Assert "the subject includes uncommitted work — /implement reviews before the commit" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)uncommitted') { throw 'uncommitted work is never reviewed' }
    if ($c -notmatch '(?i)untracked') { throw 'untracked files are never reviewed' }
    $c -match '(?i)(before|prior to) the commit|working tree, not just'
  }

  # A bad ref or an empty diff must fail before two subagents are spawned on
  # nothing — the failure is invisible once it is inside them.
  Assert "the fixed point is pinned and proven before any subagent is spawned" {
    $c = Get-SkillFile 'code-review/SKILL.md'
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
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)merge-?base') { throw 'the merge-base is never named' }
    $c -match 'tools/git\.md'
  }

  Assert "the two axes are reported separately, never merged or reranked" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    $c -match '(?i)(never|not|do not|don.t) (merge|rerank|re-rank)|(merge|rerank|re-rank).{0,60}(defeats|masks|is the)'
  }

  Assert "the Spec axis reaches missing requirements, scope creep, and wrong implementations" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)(missing|partial)') { throw 'missing requirements are not reached' }
    if ($c -notmatch '(?i)scope creep|was ?n.t asked for|not asked for') { throw 'scope creep is not reached' }
    $c -match '(?i)(implemented but|looks? implemented|wrong).{0,120}(wrong|incorrect|does not)|(wrong|incorrectly).{0,60}implement'
  }

  Assert "a missing spec is reported, never invented" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)no spec') { throw 'the missing-spec case is not handled' }
    $c -match '(?i)(never|do not|don.t) (invent|guess|reconstruct|infer)'
  }

  # Ticket 02 / CLAUDE.template.md: /code-review reads Context for boundaries
  # and Decisions for ADRs, so it is a skill that relies on Context and owes a
  # report. Silence is indistinguishable from the check never having run.
  Assert "/code-review opens with a verification report, because it relies on Context" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    if ($c -notmatch '(?i)verification report') { throw 'no verification report' }
    $c -match '(?ms)^```\s*$.*?Verification.*?^```\s*$'
  }

  # Ticket 02's placement rule, checked where a fourth file could restate it.
  # A paraphrase is duplication too — "when the Marker equals HEAD and the tree
  # is clean" restates CLAUDE.template.md's rule without repeating its symbols.
  Assert "/code-review does not restate the Marker rule" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    $c -notmatch '(?i)marker.{0,80}(==|matches|equals|is the same as).{0,40}HEAD'
  }

  # ADR 0001. Every skill derived from matt's says so.
  Assert "attribution to mattpocock survives" {
    $c = Get-SkillFile 'code-review/SKILL.md'
    $c -match '(?i)mattpocock/skills'
  }
}

# --- ticket 06 — /commit, the transaction boundary ---------------------------

Describe-Ticket '06' 'the transaction boundary' {

  Assert "/commit ships as a skill" {
    Test-Path (Join-Path $skills 'commit/SKILL.md')
  }

  # Spec, Scope: "/commit is model-invoked because /implement closes out
  # through it. Typed directly, it handles work with no ticket."
  Assert "/commit is model-invoked — /implement closes out through it" {
    $fm = Get-Frontmatter (Get-SkillFile 'commit/SKILL.md')
    if (-not $fm) { throw 'commit/SKILL.md has no frontmatter' }
    if ($fm -notmatch '(?m)^name:\s*commit\s*$') { throw 'the skill is not named commit' }
    $fm -notmatch 'disable-model-invocation:\s*true'
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
    if ($step -notmatch '(?i)/code-review') { throw 'the review question is missing' }
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
    if ($c -notmatch 'tools/git\.md') { throw 'tools/git.md is never referenced' }
    if ($c -match '(?m)^git status --porcelain') { throw 'the uncommitted drift read is restated' }
    if ($c -match '(?m)^git diff --name-only') { throw 'the Marker diff read is restated' }
    $c -notmatch '(?im)^\s*never\s+`?git commit -a'
  }
}

# --- ticket 07 — /research and /prototype, the evidence commands -------------

Describe-Ticket '07' 'vendor /research and /prototype' {

  foreach ($s in @('research', 'prototype')) {
    Assert "/$s ships as a skill" {
      Test-Path (Join-Path $skills "$s/SKILL.md")
    }

    # Acceptance: "Neither is user-invoked — /design must be able to reach both."
    Assert "/$s is model-invoked — /design reaches it at the Heavyweight gate" {
      $fm = Get-Frontmatter (Get-SkillFile "$s/SKILL.md")
      if (-not $fm) { throw "$s/SKILL.md has no frontmatter" }
      if ($fm -notmatch "(?m)^name:\s*$s\s*$") { throw "the skill is not named $s" }
      $fm -notmatch 'disable-model-invocation:\s*true'
    }
  }

  # --- /research -------------------------------------------------------------

  # Scoped to the step that writes it. "one small cited file" appears up in the
  # dispatch rationale, so a file-wide check stays green with the one-file rule
  # deleted from the place it governs.
  Assert "findings are written to .claude/docs/research/, as one cited file" {
    $c = Get-SkillFile 'research/SKILL.md'
    $step = [regex]::Match($c, '(?ims)^#{2,}[^\n]*write one cited file.*?(?=^#{2}\s|\z)').Value
    if (-not $step) { throw 'writing the findings is not its own step' }
    if ($step -notmatch '\.claude/docs/research/') { throw 'the findings location is wrong or missing' }
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
    if ($c -notmatch '\.claude/docs/research/') { throw 'the findings directory is never read back' }
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
  Assert "code lives in .claude/prototypes/, the write-up in .claude/docs/prototypes/" {
    $c = Get-SkillFile 'prototype/SKILL.md'
    $table = [regex]::Match($c, '(?ms)^\|\s*What\s*\|.*?(?=\r?\n\r?\n)').Value
    if (-not $table) { throw 'the two locations are not declared in one table' }
    if ($table -notmatch '`\.claude/prototypes/') { throw 'the code location is wrong or missing' }
    if ($table -notmatch '`\.claude/docs/prototypes/') { throw 'the write-up location is wrong or missing' }
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

# --- ticket 09 — the gap-fillers, and the tracker's one home -----------------

Describe-Ticket '09' 'vendor the gap-fillers' {

  $onramps = @('triage', 'diagnosing-bugs', 'handoff', 'resolving-merge-conflicts',
               'improve-codebase-architecture')

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
    'improve-codebase-architecture' = $true
    'diagnosing-bugs'               = $false
    'resolving-merge-conflicts'     = $false
  }
  foreach ($s in $axis.Keys) {
    $userInvoked = $axis[$s]
    Assert "$s is $(if ($userInvoked) { 'user' } else { 'model' })-invoked" {
      $fm = Get-Frontmatter (Get-SkillFile "$s/SKILL.md")
      if (-not $fm) { throw "$s/SKILL.md has no frontmatter" }
      $disabled = $fm -match 'disable-model-invocation:\s*true'
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
    if ($t -notmatch 'tools/github\.md') { throw 'the gh reference is missing or guessed' }
    # Ticket 09 says `tools/gh.md`; the file ticket 15 shipped is github.md.
    if ($t -match 'tools/gh\.md') { throw 'points at tools/gh.md, which does not exist' }
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
    $readers = @('triage/SKILL.md', 'implement/SKILL.md')
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
    if ($c -notmatch '\.claude/docs/out-of-scope/') { throw 'the location is not under .claude/docs/' }
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

  # --- improve-codebase-architecture -----------------------------------------

  # ADR 0011: /design is the whole planning surface. matt's runs its own
  # grilling and domain-modeling loop, which is exactly that surface rebuilt
  # inside a survey command.
  Assert "the chosen candidate goes to /design — the survey does not plan" {
    $c = Get-SkillFile 'improve-codebase-architecture/SKILL.md'
    # A step, not a mention. /design is named in the rationale either way, so a
    # presence check survives the hand-off step turning into a grill.
    if (-not [regex]::IsMatch($c, '(?im)^#{2,}[^\n]*(hand|pass)[a-z]* it to `?/design')) {
      throw 'handing the candidate to /design is not a step'
    }
    if ([regex]::IsMatch($c, '(?im)^#{2,}[^\n]*grill')) { throw 'the survey runs its own grill' }
    $c -match '(?i)(do not|don.t) grill here'
  }

  Assert "the architecture vocabulary comes from codebase-design, used exactly" {
    $c = Get-SkillFile 'improve-codebase-architecture/SKILL.md'
    if ($c -notmatch '(?i)codebase-design') { throw 'the vocabulary skill is not invoked' }
    # In the step that explores, where it is applied. Naming it in the
    # vocabulary list is not using it.
    $explore = [regex]::Match($c, '(?ims)^#{2,}[^\n]*explore.*?(?=^#{2}\s|\z)').Value
    if ($explore -notmatch '(?i)deletion test') { throw 'the deletion test is never applied' }
    $c -match '(?i)(exactly|don.t drift|do not drift)'
  }

  Assert "the report is written outside the repository" {
    $c = Get-SkillFile 'improve-codebase-architecture/SKILL.md'
    if (-not (Test-Path (Join-Path $skills 'improve-codebase-architecture/HTML-REPORT.md'))) {
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
    if (([regex]::Matches($c, 'tools/git\.md')).Count -lt 2) {
      throw 'only one step defers to the tool reference'
    }
    $true
  }
}

# --- ticket 13 — the engineering rules, distributed --------------------------

Describe-Ticket '13' 'distribute the engineering rules across the workflow' {

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
    @{ f = 'tools/SKILL.md';     rule = 'never guess an API'
       restatement = $rulePattern['never guess an API']
       route       = '(?i)`CLAUDE\.md` carries the rule' }
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

# --- summary -----------------------------------------------------------------

# A -Ticket that matches nothing must not read as a pass. Silently running zero
# assertions and exiting 0 is the one failure a CI job cannot notice.
if ($Ticket -and $script:Ran.Count -eq 0) {
  Write-Host ""
  Write-Host "no ticket '$Ticket' — nothing ran" -ForegroundColor Red
  Write-Host "known tickets: 01, 02, 03, 04, 05, 06, 07, 09, 13, 15 (two digits)" -ForegroundColor DarkGray
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
