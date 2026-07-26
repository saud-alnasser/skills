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

# --- summary -----------------------------------------------------------------

# A -Ticket that matches nothing must not read as a pass. Silently running zero
# assertions and exiting 0 is the one failure a CI job cannot notice.
if ($Ticket -and $script:Ran.Count -eq 0) {
  Write-Host ""
  Write-Host "no ticket '$Ticket' — nothing ran" -ForegroundColor Red
  Write-Host "known tickets: 01, 02, 03, 04, 05, 06, 15 (two digits)" -ForegroundColor DarkGray
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
