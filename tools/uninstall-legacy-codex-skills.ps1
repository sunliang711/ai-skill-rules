param(
    [switch]$Apply,
    [string]$LegacyDir = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir = Split-Path -Parent $ScriptDir
$SkillsDir = Join-Path $SrcDir "skills"

if (-not $LegacyDir) {
    $CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
    $LegacyDir = Join-Path $CodexHome "skills"
}

function Read-SkillName {
    param([string]$SkillFile)

    foreach ($line in Get-Content $SkillFile -Encoding UTF8) {
        if ($line -match '^name:\s*(.+?)\s*$') {
            return $Matches[1]
        }
    }
    return ""
}

function Normalize-DirectoryPath {
    param([string]$Path)

    $separators = [char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $trimmed = $Path.TrimEnd($separators)
    if (-not $trimmed) {
        return $Path
    }

    $root = [System.IO.Path]::GetPathRoot($Path)
    if ($root) {
        $trimmedRoot = $root.TrimEnd($separators)
        if ($trimmed -eq $trimmedRoot) {
            return $root
        }
    }

    return $trimmed
}

$LegacyDir = Normalize-DirectoryPath $LegacyDir

if (-not (Test-Path $SkillsDir)) {
    throw "source skills directory not found: $SkillsDir"
}

$legacyItem = Get-Item -LiteralPath $LegacyDir -Force -ErrorAction SilentlyContinue
if (-not $legacyItem) {
    Write-Host "Legacy Codex skills directory does not exist: $LegacyDir"
    exit 0
}

if ($legacyItem.LinkType) {
    throw "refuse to use symlink legacy skills directory: $LegacyDir"
}

$targets = New-Object System.Collections.Generic.List[string]

foreach ($skillDir in Get-ChildItem $SkillsDir -Directory | Sort-Object Name) {
    $target = Join-Path $LegacyDir $skillDir.Name
    if (-not (Test-Path $target)) {
        continue
    }

    $targetItem = Get-Item $target
    if ($targetItem.LinkType) {
        Write-Warning "skip symlink: $target"
        continue
    }

    $skillFile = Join-Path $target "SKILL.md"
    if (-not (Test-Path $skillFile)) {
        Write-Warning "skip because SKILL.md is missing: $target"
        continue
    }

    $targetSkillName = Read-SkillName $skillFile
    if ($targetSkillName -ne $skillDir.Name) {
        Write-Warning "skip because name mismatch: $target (name: $targetSkillName)"
        continue
    }

    $targets.Add($target) | Out-Null
}

if ($targets.Count -eq 0) {
    Write-Host "No ai-rules-skills entries found in: $LegacyDir"
    exit 0
}

if (-not $Apply) {
    Write-Host "Dry-run. Matched legacy skill directories:"
    $targets | ForEach-Object { Write-Host $_ }
    Write-Host ""
    Write-Host "Run with -Apply to delete these directories."
    exit 0
}

foreach ($target in $targets) {
    $fullTarget = [System.IO.Path]::GetFullPath($target)
    $fullLegacyDir = [System.IO.Path]::GetFullPath($LegacyDir)
    if (-not $fullTarget.StartsWith($fullLegacyDir + [System.IO.Path]::DirectorySeparatorChar)) {
        throw "refuse to delete path outside legacy skills dir: $target"
    }

    Write-Host "Removing: $target"
    Remove-Item $target -Recurse -Force
}

Write-Host "Done."
