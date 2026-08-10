<#
.SYNOPSIS
  Regenerates every generated index from the fields the indexed files declare.

.DESCRIPTION
  Produces `.claude/contexts/map.md` and `.claude/decisions/map.md` from the
  frontmatter of the files each directory holds. An index is a total function of
  its directory: it is never hand-edited, and the suite enforces that by running
  this script and comparing (ADR 0057).

  A file under an indexed directory that declares no fields is an error naming
  that file, not a row quietly left out. A missing row makes a context or a
  decision unreachable, and the silent version of that is discovered by whoever
  needed the file rather than by the build.

.PARAMETER Repo
  Repository root — the directory holding `.claude/`. Defaults to this script's
  grandparent, since the script lives at `.claude/scripts/`, so it works from any
  working directory.

.OUTPUTS
  Nothing. Each index is written to its own directory and the path reported.

  There is deliberately no print-to-stdout mode. The suite checks this script by
  running it against a copy of the tree and comparing the files it wrote, which
  exercises the same path `/commit` takes; a second output mode would be a
  surface nothing runs, checked by a comparison that proves nothing about the
  one that does.

.EXAMPLE
  pwsh -NoProfile -File .claude/scripts/regenerate-indexes.ps1
  Rewrites every index in place.

.EXAMPLE
  pwsh -NoProfile -File .claude/scripts/regenerate-indexes.ps1 -Repo /tmp/fixture
  Rewrites the indexes of some other tree — how the suite exercises this.
#>
[CmdletBinding()]
param(
  [string]$Repo = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# The checkout's own ending, which this repository pins: `.gitattributes` sets
# `eol=lf`, and that overrides every clone's `core.autocrlf`, so LF is what git
# put on disk here whatever the platform and whatever the local setting says.
# Byte-for-byte comparison is against what git put on disk, which is why this
# tracks the pin rather than the platform.
#
# The platform's ending was here before the pin existed, and was correct under
# exactly one configuration — `autocrlf=true` on Windows. Under `autocrlf=input`
# the checkout held LF while this wrote CRLF, and the comparison failed *as a
# stale index* rather than as the line-ending disagreement it was. ADR 0069 has
# why the pin was chosen over teaching this script to detect the ending.
$script:NL = "`n"

# `map.md` is the output, so it is never also an input. Without this the first
# regeneration after the first regeneration would index the index.
function Get-IndexedFile {
  param([string]$Directory)
  if (-not (Test-Path $Directory)) { throw "no such directory: $Directory" }
  @(Get-ChildItem $Directory -File -Filter '*.md' |
      Where-Object { $_.Name -ne 'map.md' } |
      Sort-Object Name)
}

# One frontmatter block, as a name→value map. Values stay strings; a list is
# split by the caller that knows the field is one, because `sources` and
# `load-when` want opposite treatment and only the caller can tell them apart.
# The frontmatter as text. Split out because a block list's entries are not
# `key: value` lines and so are invisible to the map below by construction —
# one caller needs the text underneath, and a second copy of this regex is a
# second thing to keep in step.
function Get-FrontmatterBlock {
  param([string]$Text)
  $m = [regex]::Match($Text, '(?s)\A---\r?\n(.*?)\r?\n---')
  if (-not $m.Success) { return $null }
  $m.Groups[1].Value -replace "`r", ''
}

function Get-DeclaredField {
  param([string]$Text)
  $block = Get-FrontmatterBlock $Text
  if ($null -eq $block) { return $null }
  $fields = @{}
  foreach ($line in [regex]::Matches($block, '(?m)^([a-z][a-z0-9-]*):[ \t]*(.*?)[ \t]*$')) {
    $fields[$line.Groups[1].Value] = $line.Groups[2].Value
  }
  if ($fields.Count -eq 0) { return $null }
  $fields
}

# An inline `[a, b]` list, and nothing else. A block list is the shape specs use
# and is outside what the two indexed families declare, so it is refused rather
# than read as empty: the empty reading renders a row claiming the file points at
# nothing, which is a wrong answer that looks like a right one. `[]` is how a file
# says it points at nothing, and it survives this.
#
# Both refusals live here rather than being split with `Read-IndexedDocument`'s
# required-field list — while they were split, a mutation removing either left the
# other refusing the same file, so neither could be shown to do anything.
#
# $Subject names the file and the field: a refusal that says only which field was
# wrong sends the reader through a directory looking for it. $Value is untyped
# because `[string]` coerces $null to the empty string, collapsing "absent" into
# "block list" and making the first refusal unreachable — a mutation removing it
# changed nothing, which is how that dead branch was found.
function Split-DeclaredList {
  param([string]$Subject, $Value)
  if ($null -eq $Value) { throw "$Subject is not declared" }
  if ($Value -notmatch '^\[.*\]$') { throw "$Subject is not an inline list: '$Value'" }
  @($Value.Trim('[', ']') -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

# A YAML block list: the key alone on its line, then indented `- entry` lines.
# Specs take this form rather than the inline one because a single pointer can
# contain a comma — `specs.md §5, §8` is one entry — which inline form splits
# silently. That comma is the entire reason this exists, which is why the fixture
# that exercises it carries one.
#
# Two refusals, each with its own fixture in `declared-fields/07` — the first
# attempt at this ticket wrote both and covered neither, and a mutation turning
# either into an empty list left all 1025 assertions green. Read as empty, both
# render a spec as pointing nowhere, which is a wrong answer no reader of the
# index could tell from a right one:
#
#   `sources` absent entirely        — the file never declared it
#   `sources:` with nothing under it — YAML null, not an empty list; `[]` is that
function Split-DeclaredBlockList {
  param([string]$Subject, [string]$Frontmatter, [string]$Name)
  $head = [regex]::Match($Frontmatter, "(?m)^${Name}:[ \t]*(\[\])?[ \t]*$")
  if (-not $head.Success) { throw "$Subject is not declared" }
  if ($head.Groups[1].Success) { return @() }
  $body = [regex]::Match($Frontmatter, "(?ms)^${Name}:[ \t]*$\r?\n((?:[ \t]+-[^\r\n]*(?:\r?\n|\z))+)")
  if (-not $body.Success) { throw "$Subject declares nothing and does not say so" }
  @([regex]::Matches($body.Groups[1].Value, '(?m)^[ \t]+-[ \t]*(.+?)[ \t]*$') |
      ForEach-Object { $_.Groups[1].Value })
}

# Backticked and comma-joined, or an em dash. The dash is what the committed
# indexes use for "points at nothing", and an empty cell would read as a column
# nobody filled in rather than as a fact.
function Format-SourceCell {
  param([string[]]$Sources)
  if (-not $Sources -or $Sources.Count -eq 0) { return [char]0x2014 }
  ($Sources | ForEach-Object { '`' + $_ + '`' }) -join ', '
}

# $Text is the file already read, for the one caller that needs the body as well
# as the fields. Without it that caller reads every finding twice — the defect
# `New-DesignIndex` records having fixed, reintroduced one family along.
function Read-IndexedDocument {
  param([System.IO.FileInfo]$File, [string[]]$Required, [string]$Text)
  if (-not $Text) { $Text = Get-Content $File.FullName -Raw }
  $fields = Get-DeclaredField $Text
  if ($null -eq $fields) { throw "$($File.Name) declares no fields" }
  foreach ($r in $Required) {
    if (-not $fields.ContainsKey($r)) { throw "$($File.Name) declares no $r field" }
  }
  $fields
}

<#
.SYNOPSIS
  The decision index: one row per ADR, in numeric order.
#>
function New-DecisionIndex {
  param([string]$Directory)
  $rows = foreach ($f in Get-IndexedFile $Directory) {
    $id = [regex]::Match($f.Name, '^(\d{4})-').Groups[1].Value
    if (-not $id) { throw "$($f.Name) is not numbered" }
    $d = Read-IndexedDocument -File $f -Required @('load-when', 'status')
    $src = Format-SourceCell (Split-DeclaredList "$($f.Name): sources" $d['sources'])
    [pscustomobject]@{ Id = $id; Line = "| [$id]($($f.Name)) | $($d['load-when']) | $($d['status']) | $src |" }
  }
  $lines = @('# Decision map', '', '| ADR | Load when | Status | Sources |', '| --- | --- | --- | --- |')
  $lines += @($rows | Sort-Object Id | ForEach-Object { $_.Line })
  ($lines -join $script:NL) + $script:NL
}

<#
.SYNOPSIS
  The context index. Row order and the shape of a Project Context's label row
  are the format's, in `.claude/policies/context.md` — stated there and not
  restated here, so rewording the rule does not need a coordinated edit to a
  comment nobody would think to look for.
#>
function New-ContextIndex {
  param([string]$Directory)

  $row = {
    param([System.IO.FileInfo]$File, [string]$Label, [string]$Target)
    $d = Read-IndexedDocument -File $File -Required @('load-when')
    $src = Format-SourceCell (Split-DeclaredList "$($File.Name): sources" $d['sources'])
    "| [$Label]($Target) | $($d['load-when']) | $src |"
  }

  $flat = Get-IndexedFile $Directory
  $repository = @($flat | Where-Object { $_.Name -eq 'repository.md' })
  $others = @($flat | Where-Object { $_.Name -ne 'repository.md' })

  $lines = @('# Context map', '', '| Context | Load when | Sources |', '| --- | --- | --- |')
  foreach ($f in ($repository + $others)) {
    $lines += & $row $f ($f.BaseName) $f.Name
  }

  foreach ($dir in @(Get-ChildItem $Directory -Directory | Sort-Object Name)) {
    $lines += "| **$($dir.Name)** | | |"
    foreach ($f in Get-IndexedFile $dir.FullName) {
      $lines += & $row $f "$($dir.Name)/$($f.BaseName)" "$($dir.Name)/$($f.Name)"
    }
  }

  ($lines -join $script:NL) + $script:NL
}

# The finding's own consumption mark, taken from the body rather than from
# frontmatter — the one value any index reads from outside the fields. The mark
# is where a finding already records its healing, so a declared field mirroring
# it would be a second home for one fact, free to disagree with the first.
#
# A mark naming nothing is not an answer, so it reads as waiting exactly as an
# absent one does. Unknown resolving to *unhealed* is the safe direction: the
# opposite retires evidence nobody acted on, which is the guess the format
# exists to prevent.
function Test-ConsumptionMark {
  param([string]$Text)
  [regex]::IsMatch($Text, '(?m)^Consumed:[ \t]*\S')
}

# What a finding falsifies, and whether that has been healed. Three states and
# three renderings, because the reader's question — is anything still waiting? —
# has to be answerable from this column without opening a file. A finding
# declaring `[]` keeps the bare em dash: it named nothing to heal, so neither
# state applies to it.
function Format-FalsifiesCell {
  param([string[]]$Falsifies, [bool]$Consumed)
  if (-not $Falsifies -or $Falsifies.Count -eq 0) { return [char]0x2014 }
  $state = if ($Consumed) { 'consumed' } else { 'waiting' }
  "$state $([char]0x2014) $(Format-SourceCell $Falsifies)"
}

<#
.SYNOPSIS
  The evidence index: one row per finding, spanning every kind.

.DESCRIPTION
  One index at the family root rather than one beneath each kind (ADR 0056),
  because the obligation it serves — read the directory before producing more —
  is cross-kind. Rows are in filename order, which is date order, with `kind`
  breaking a tie: chronology is what a reader of accumulated evidence wants
  first, and grouping by kind would make that column decorative.

  Takes the findings already located, because a kind only has a directory once
  it has a file and finding them is a walk rather than a listing.

  The falsifies cell carries the finding's consumption state, so a finding still
  waiting to be healed is visible from the index without opening it. The state is
  read off that finding's own mark and never inferred from the knowledge it
  falsified — deciding consumption stays a reader's act, and this index only
  reports what the file already says.
#>
function New-EvidenceIndex {
  param([object[]]$Findings)
  # Sorted on the directory, which is the tie-break: two findings dated the same
  # day are ordered by the kind they sit under. The declared field cannot serve
  # here — it is the thing being checked one line down, not a thing to trust.
  $rows = foreach ($f in ($Findings | Sort-Object Name, Kind)) {
    # `falsifies` is deliberately not in the required list: `Split-DeclaredList`
    # already refuses an absent one below, and while both checked it a mutation
    # removing either left the other refusing the same file — the redundancy
    # `declared-fields/05` found and resolved the same way.
    $text = Get-Content $f.Path -Raw
    $d = Read-IndexedDocument -File (Get-Item $f.Path) -Required @('kind') -Text $text
    # A declared kind that disagrees with the directory would put the row under
    # one kind and its link under another, silently — and the column ADR 0056
    # made load-bearing would be the half that lies.
    if ($d['kind'] -ne $f.Kind) {
      throw "$($f.Name).md declares kind '$($d['kind'])' and sits in '$($f.Kind)'"
    }
    $falsifies = Split-DeclaredList "$($f.Name): falsifies" $d['falsifies']
    $cell = Format-FalsifiesCell $falsifies (Test-ConsumptionMark $text)
    "| [$($f.Name)]($($f.Kind)/$($f.Name).md) | $($d['kind']) | $cell |"
  }
  $lines = @('# Evidence map', '', '| Finding | Kind | Falsifies |', '| --- | --- | --- |')
  $lines += @($rows)
  ($lines -join $script:NL) + $script:NL
}

# Every finding under every kind that has a directory. Kinds are walked rather
# than listed because the set of directories is the answer, not an input: a kind
# earns its directory when it has a file, so a fixed list would be wrong in both
# directions — naming one that does not exist, and missing one added later.
function Get-EvidenceFinding {
  param([string]$Root)
  $family = Join-Path $Root '.claude/evidence'
  if (-not (Test-Path $family)) { return @() }
  @(Get-ChildItem $family -Directory | Sort-Object Name | ForEach-Object {
    $kind = $_.Name
    Get-IndexedFile $_.FullName | ForEach-Object {
      [pscustomobject]@{ Name = $_.BaseName; Kind = $kind; Path = $_.FullName }
    }
  })
}

<#
.SYNOPSIS
  The design index: one row per spec, carrying the status that says which is live.

.DESCRIPTION
  Takes the specs already located, because they live in two shapes and finding
  them is the caller's job: flat in the designs directory, or one per effort
  beside the tickets it governs. The rows are identical either way — a second
  format for the repository that builds the framework is the drift this whole
  effort removes.

  `status` is required rather than optional: it is the column the index exists
  for, and a spec without one would render a blank cell answering the reader's
  first question with nothing.

  Row order comes from the caller, which produced the specs in name order
  already. Sorting again here was dead code the first time and is not repeated.
#>
function New-DesignIndex {
  param([object[]]$Specs)
  $rows = foreach ($s in $Specs) {
    # Read once. The frontmatter feeds both the flat field map and the block
    # list, and re-reading for the second was a second trip to disk per spec.
    $text = Get-Content $s.Path -Raw
    $block = Get-FrontmatterBlock $text
    # Named by target rather than label: the two layouts spell the file
    # differently — `<effort>/spec.md` against a flat `<slug>.md` — and a
    # refusal naming the wrong one sends the reader looking for a path that
    # does not exist in their tree.
    if ($null -eq $block) { throw "$($s.Target) declares no fields" }
    $d = Get-DeclaredField $text
    if (-not $d.ContainsKey('status')) { throw "$($s.Target) declares no status field" }
    $sources = Split-DeclaredBlockList "$($s.Label): sources" $block 'sources'
    "| [$($s.Label)]($($s.Target)) | $($d['status']) | $(Format-SourceCell $sources) |"
  }
  $lines = @('# Design map', '', '| Design | Status | Sources |', '| --- | --- | --- |')
  $lines += @($rows)
  ($lines -join $script:NL) + $script:NL
}

# Where the specs are is discovered from the tree, because the two layouts are
# structurally different rather than differently configured: a flat directory of
# specs, or one spec inside each effort. A repository holding both is refused
# rather than silently preferred — a preference would drop every row of the
# other layout and report it as a stale index.
function Get-DesignIndexTarget {
  param([string]$Root)
  $flat = Join-Path $Root '.claude/designs'
  $efforts = Join-Path $Root '.claude/tickets'

  $flatSpecs = @()
  if (Test-Path $flat) {
    $flatSpecs = @(Get-IndexedFile $flat | ForEach-Object {
      [pscustomobject]@{ Label = $_.BaseName; Target = $_.Name; Path = $_.FullName }
    })
  }

  $effortSpecs = @()
  if (Test-Path $efforts) {
    $effortSpecs = @(Get-ChildItem $efforts -Directory | Sort-Object Name | ForEach-Object {
      $spec = Join-Path $_.FullName 'spec.md'
      if (Test-Path $spec) {
        [pscustomobject]@{ Label = $_.Name; Target = "$($_.Name)/spec.md"; Path = $spec }
      }
    })
  }

  if ($flatSpecs.Count -and $effortSpecs.Count) {
    throw "specs exist both flat in .claude/designs/ and under .claude/tickets/<effort>/ — one layout or the other, not both"
  }
  if ($flatSpecs.Count) { return @{ Directory = $flat; Specs = $flatSpecs } }
  if ($effortSpecs.Count) { return @{ Directory = $efforts; Specs = $effortSpecs } }
  $null
}

# One directory per family, named once. Stating it twice — as a path and again
# inside the builder that reads it — is how the read and the write drift apart
# on an edit that touches only one of them.
$families = [ordered]@{
  contexts  = ${function:New-ContextIndex}
  decisions = ${function:New-DecisionIndex}
}

$written = @()
foreach ($name in $families.Keys) {
  $directory = Join-Path $Repo ".claude/$name"
  $written += @{ Target = (Join-Path $directory 'map.md'); Text = (& $families[$name] $directory) }
}

# Evidence is the one family whose members are not the directory's own files, so
# it is located rather than listed. No findings means no index — a table with a
# header and no rows is a claim that the directory was read.
# Wrapped, because a function returning an empty array assigns as $null and
# strict mode then refuses `.Count` — the failure reads as a missing property
# rather than as the empty family it is.
$findings = @(Get-EvidenceFinding $Repo)
if ($findings.Count) {
  $written += @{
    Target = (Join-Path $Repo '.claude/evidence/map.md')
    Text   = (New-EvidenceIndex $findings)
  }
}

$designs = Get-DesignIndexTarget $Repo
if ($designs) {
  $written += @{
    Target = (Join-Path $designs.Directory 'map.md')
    Text   = (New-DesignIndex $designs.Specs)
  }
}

foreach ($index in $written) {
  # `WriteAllText` rather than `Set-Content`, which appends its own line ending
  # to the string it is handed — the trailing newline is already in the output
  # and a second one is a byte of drift on every run.
  [System.IO.File]::WriteAllText($index.Target, $index.Text, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host "regenerated $($index.Target)"
}
