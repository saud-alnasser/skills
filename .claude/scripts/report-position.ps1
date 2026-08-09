<#
.SYNOPSIS
  Reports where this clone stands, and writes the Receipt attesting that it did.

.DESCRIPTION
  Derived from the behavioural specification in the configure skill's scripts
  page. That page is the contract; this file is one implementation of it, and the
  suite holds the two together by running this against the page's fixture.

  Emits the *position* half of the verification report and never the judgement
  half. Which contexts a request routes to, whether a Source Pointer resolves, and
  whether a claim is contradicted by source cannot be computed — the stage prints
  those beneath this output.

  A refusal is a result, not an error: a clone with no marker still reports, still
  writes a receipt, and still exits zero. What it does not do is claim the
  position was verifiable.

.PARAMETER Repo
  Repository root — the directory holding `.claude/`. Defaults to this script's
  grandparent, since the script lives at `.claude/scripts/`, so it works from any
  working directory.

.OUTPUTS
  The report on standard output. The receipt is written beside the Marker.

.EXAMPLE
  pwsh -NoProfile -File .claude/scripts/report-position.ps1
#>
[CmdletBinding()]
param(
  [string]$Repo = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$positionDir = Join-Path $Repo '.claude/position'
$markerPath = Join-Path $positionDir 'marker.json'
$receiptPath = Join-Path $positionDir 'receipt.json'

# The run identity is observed rather than documented: it carries the right value
# in a tool call, but the reference names only the effort level as reaching one.
# So it is never required — absent, the receipt attests on the commit alone and
# the report says which mode it ran in. An unstated downgrade is undetectable,
# which is the whole reason this is a value rather than an inference.
$runId = $env:CLAUDE_CODE_SESSION_ID
$mode = if ($runId) { 'session' } else { 'commit-only' }
$modeLine = if ($runId) { "session $runId" } else { 'commit-only (run identity unavailable)' }

function Format-Line {
  param([string]$Label, [string]$Rest)
  '  ' + $Label.PadRight(6) + '  ' + $Rest
}

function Invoke-Git {
  param([Parameter(ValueFromRemainingArguments)][string[]]$Arguments)
  $out = & git -C $Repo @Arguments 2>$null
  [pscustomobject]@{ Ok = ($LASTEXITCODE -eq 0); Out = ($out | Out-String).Trim() }
}

function Get-TreeFingerprint {
  # A throwaway index seeded from the repository's own. Seeding is not tidiness:
  # a fresh index has no stat cache, so every file in the worktree would be
  # re-hashed on every stage and the check would cost more than the reads it
  # replaces. The real index is never written — the copy is what git is pointed at.
  $idx = (Invoke-Git 'rev-parse' '--path-format=absolute' '--git-path' 'index').Out
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
  Copy-Item $idx $tmp
  try {
    $env:GIT_INDEX_FILE = $tmp
    $null = Invoke-Git 'add' '-A'
    (Invoke-Git 'write-tree').Out
  }
  finally {
    $env:GIT_INDEX_FILE = $null
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  }
}

function Write-Receipt {
  param([string]$Head, [string]$Tree)
  if (-not (Test-Path $positionDir)) { $null = New-Item -ItemType Directory -Path $positionDir }
  # `head` and `tree` are what was observed, never what the marker said. The
  # commit stage asks whether a receipt attests the position that is live now, and
  # a receipt echoing the marker would answer a different question.
  $receipt = [ordered]@{ run = $runId; mode = $mode; head = $Head; tree = $Tree }
  if (-not $runId) { $receipt.run = $null }
  Set-Content -Path $receiptPath -Value ($receipt | ConvertTo-Json) -Encoding utf8NoBOM
}

function Write-Refusal {
  param([string]$MarkerLine, [string]$Consequence, [string]$Head, [string]$Tree)
  Write-Receipt -Head $Head -Tree $Tree
  @(
    'Position'
    (Format-Line 'marker' $MarkerLine)
    # ASCII, deliberately. Emitted output is captured through whatever console
    # encoding the shell has, and a non-ASCII character arrives as `?` under one
    # that is not UTF-8 — silently, in a report that still looks well-formed.
    "  -> $Consequence"
    (Format-Line 'mode' $modeLine)
  ) -join [Environment]::NewLine
}

$head = (Invoke-Git 'rev-parse' 'HEAD').Out
$live = Get-TreeFingerprint

if (-not (Test-Path $markerPath)) {
  Write-Refusal 'absent' 'nothing was verified in this clone; everything the request touches is unverified' $head $live
  exit 0
}

$marker = Get-Content $markerPath -Raw | ConvertFrom-Json
$markerCommit = $marker.commit
# A marker carrying no tree fact means the tree is unknown, which is not a fourth
# refusal — it falls to the differing branch, so the drift reads run. Unknown
# resolving to "read it" is the safe direction; the reverse would skip a read on
# the strength of a fact nobody recorded.
$markerTree = if ($marker.PSObject.Properties.Name -contains 'tree') { $marker.tree } else { '' }

if (-not (Invoke-Git 'cat-file' '-e' "$markerCommit^{commit}").Ok) {
  Write-Refusal "$($markerCommit.Substring(0,7))  gone from this clone" `
    'no diff is possible from it; everything the request touches is unverified' $head $live
  exit 0
}

if (-not (Invoke-Git 'merge-base' '--is-ancestor' $markerCommit 'HEAD').Ok) {
  Write-Refusal "$($markerCommit.Substring(0,7))  HEAD $($head.Substring(0,7))   not an ancestor" `
    'the diff between them is meaningless; everything the request touches is unverified' $head $live
  exit 0
}

$commitMatches = $markerCommit -eq $head
$treeMatches = $markerTree -eq $live

$commitVerdict = if ($commitMatches) { 'commit match' }
                 else { "$((Invoke-Git 'rev-list' '--count' "$markerCommit..HEAD").Out) commits ahead" }
$treeVerdict = if ($treeMatches) { 'tree match' } else { 'tree differs' }

$lines = @(
  'Position'
  (Format-Line 'marker' "$($markerCommit.Substring(0,7))  HEAD $($head.Substring(0,7))   $commitVerdict")
  (Format-Line 'tree' "$($markerTree.PadRight(7).Substring(0,7))  live $($live.Substring(0,7))   $treeVerdict")
)

if ($commitMatches -and $treeMatches) {
  $lines += Format-Line 'drift' 'reads skipped'
}
else {
  # Read only when an identity differs. A match licenses skipping these, and
  # skipping them is the entire point of the Marker.
  $committed = @((Invoke-Git 'diff' '--name-only' "$markerCommit..HEAD" '--' '.' ':(exclude).claude/').Out -split "`n" |
      Where-Object { $_.Trim() })
  $uncommitted = @((Invoke-Git 'status' '--porcelain' '--untracked-files=all').Out -split "`n" |
      Where-Object { $_.Trim() } | ForEach-Object { $_.Substring(3) })
  $lines += Format-Line 'drift' "$($committed.Count) committed, $($uncommitted.Count) uncommitted"
  # Never truncated: a capped list hides the one path that mattered and reports
  # the same shape as a complete one.
  foreach ($p in @($committed) + @($uncommitted)) { $lines += '            ' + $p.Trim() }
}

$lines += Format-Line 'mode' $modeLine

Write-Receipt -Head $head -Tree $live
$lines -join [Environment]::NewLine
