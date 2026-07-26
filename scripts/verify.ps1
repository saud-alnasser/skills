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
}

# --- ticket 02 — verification at use, healing where the break is found --------

# The always-on half of the discipline. ADR 0007: a rule that must hold
# unconditionally has to live in CLAUDE.md, because a rule inside a skill only
# fires when that skill runs. /configure (ticket 08) installs this template.
$claudeTemplate = 'configure/CLAUDE.template.md'

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
  $singleHome = [ordered]@{
    'the Marker cache-validity rule'  = '(?i)marker.{0,80}(==|matches).{0,40}HEAD'
    'the compression test'            = '(?i)will this improve (a )?future engineering decision'
    'the never-invent-a-pointer rule' = '(?i)(never|not|rather than) invent(ing)?( a)? (replacement|path)'
    'the knowledge-layer table'       = '(?im)^\|\s*Codebase\s*\|'
  }
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

# --- summary -----------------------------------------------------------------

# A -Ticket that matches nothing must not read as a pass. Silently running zero
# assertions and exiting 0 is the one failure a CI job cannot notice.
if ($Ticket -and $script:Ran.Count -eq 0) {
  Write-Host ""
  Write-Host "no ticket '$Ticket' — nothing ran" -ForegroundColor Red
  Write-Host "known tickets: 01, 02, 03, 15 (two digits)" -ForegroundColor DarkGray
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
