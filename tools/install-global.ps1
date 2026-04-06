<#
.SYNOPSIS
    Install ai-rules-skills into the global directories of Codex / Cursor / Claude Code.

.DESCRIPTION
    Supports:
      codex / cursor / claude / claudecode / all

.EXAMPLE
    .\tools\install-global.ps1 -Platform codex
    .\tools\install-global.ps1 -Platform cursor
    .\tools\install-global.ps1 -Platform claudecode
    .\tools\install-global.ps1 -Platform all
#>

param(
    [string]$Platform,
    [string]$CodexHome = "",
    [string]$CursorHome = "",
    [string]$ClaudeHome = "",
    [switch]$Help
)

if ($Help -or -not $Platform) {
    Write-Host @"

  AI Rules Global Installer
  =========================

  Usage:
    .\tools\install-global.ps1 -Platform <platform>

  Supported Platforms:
    codex
    cursor
    claude
    claudecode
    all

  Optional Parameters:
    -CodexHome   Override Codex home directory
    -CursorHome  Override Cursor home directory
    -ClaudeHome  Override Claude Code home directory

"@ -ForegroundColor Cyan
    return
}

$ScriptDir = $PSScriptRoot
$SrcDir = Split-Path $ScriptDir -Parent
$RulesDir = Join-Path $SrcDir "rules"
$SkillsDir = Join-Path $SrcDir "skills"
$WorkflowsDir = Join-Path $SrcDir "workflows"

function Normalize-Platform {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "codex" { return "codex" }
        "cursor" { return "cursor" }
        "claude" { return "claude" }
        "claude-code" { return "claude" }
        "claudecode" { return "claude" }
        "all" { return "all" }
        default { return "" }
    }
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Strip-Frontmatter {
    param([string]$Content)
    if ($Content -match "(?s)^---\r?\n.*?\r?\n---\r?\n(.*)$") {
        return $Matches[1].TrimStart()
    }
    return $Content
}

function Read-RuleMarkdown {
    param([string]$FilePath)
    $raw = Get-Content $FilePath -Raw -Encoding UTF8
    return Strip-Frontmatter $raw
}

function Rewrite-Content {
    param(
        [string]$Content,
        [string]$RuleDir,
        [string]$RuleExt,
        [string]$SkillDir,
        [string]$WorkflowDir
    )

    $updated = $Content
    $updated = $updated -replace '\.(cursor|agents|codex)/rules/([A-Za-z0-9._-]+)\.(mdc|md)', ($RuleDir + '/$2.' + $RuleExt)
    $updated = $updated -replace '\brules/([A-Za-z0-9._-]+)\.mdc\b', ($RuleDir + '/$1.' + $RuleExt)
    $updated = $updated -replace '\.(cursor|agents|codex)/skills/([A-Za-z0-9._-]+/SKILL\.md)', ($SkillDir + '/$2')
    $updated = $updated -replace '\bskills/([A-Za-z0-9._-]+/SKILL\.md)\b', ($SkillDir + '/$1')
    $updated = $updated -replace '\.(cursor|agents|codex)/workflows/([A-Za-z0-9._-]+\.md)', ($WorkflowDir + '/$2')
    $updated = $updated -replace '\bworkflows/([A-Za-z0-9._-]+\.md)\b', ($WorkflowDir + '/$1')
    return $updated
}

function Render-SkillFile {
    param(
        [string]$SourceFile,
        [string]$TargetFile,
        [string]$RuleDir,
        [string]$RuleExt,
        [string]$SkillDir,
        [string]$WorkflowDir
    )

    Ensure-Dir (Split-Path $TargetFile -Parent)
    $raw = Get-Content $SourceFile -Raw -Encoding UTF8
    $rendered = Rewrite-Content -Content $raw -RuleDir $RuleDir -RuleExt $RuleExt -SkillDir $SkillDir -WorkflowDir $WorkflowDir
    $rendered | Set-Content $TargetFile -Encoding UTF8
}

function Render-WorkflowFile {
    param(
        [string]$SourceFile,
        [string]$TargetFile,
        [string]$RuleDir,
        [string]$RuleExt,
        [string]$SkillDir,
        [string]$WorkflowDir
    )

    Ensure-Dir (Split-Path $TargetFile -Parent)
    $raw = Get-Content $SourceFile -Raw -Encoding UTF8
    $rendered = Rewrite-Content -Content $raw -RuleDir $RuleDir -RuleExt $RuleExt -SkillDir $SkillDir -WorkflowDir $WorkflowDir
    $rendered | Set-Content $TargetFile -Encoding UTF8
}

function Upsert-ManagedBlock {
    param(
        [string]$TargetFile,
        [string]$Block,
        [string]$StartMarker,
        [string]$EndMarker
    )

    $existing = ""
    if (Test-Path $TargetFile) {
        $existing = Get-Content $TargetFile -Raw -Encoding UTF8
    }

    $pattern = [regex]::Escape($StartMarker) + ".*?" + [regex]::Escape($EndMarker)
    if ($existing -match $pattern) {
        $updated = [regex]::Replace($existing, $pattern, $Block, "Singleline")
    } elseif ([string]::IsNullOrWhiteSpace($existing)) {
        $updated = $Block
    } else {
        $updated = $existing.TrimEnd() + "`r`n`r`n" + $Block
    }

    $updated | Set-Content $TargetFile -Encoding UTF8
}

function Write-CursorBootstrapScripts {
    param([string]$CursorRoot)

    $shellFile = Join-Path $CursorRoot "bootstrap-project.sh"
    $ps1File = Join-Path $CursorRoot "bootstrap-project.ps1"

    @"
#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$CursorRoot"
TARGET_DIR="\${1:-\$(pwd)}"

mkdir -p "\$TARGET_DIR/.cursor/rules" "\$TARGET_DIR/.cursor/workflows"
cp "\$SOURCE_DIR/rules"/*.mdc "\$TARGET_DIR/.cursor/rules/"
cp "\$SOURCE_DIR/workflows"/*.md "\$TARGET_DIR/.cursor/workflows/"

echo "Synced global Cursor rules/workflows into: \$TARGET_DIR/.cursor"
echo "Tips:"
echo "- Global skills are already installed under ~/.cursor/skills-cursor"
echo "- If you want file-pattern auto activation, keep these files in the project .cursor directory"
"@ | Set-Content $shellFile -Encoding UTF8

    @"
param(
    [string]\$TargetDir = (Get-Location).Path
)

\$SourceDir = "$CursorRoot"
\$RulesDir = Join-Path \$TargetDir ".cursor\rules"
\$WorkflowsDir = Join-Path \$TargetDir ".cursor\workflows"

New-Item -ItemType Directory -Force -Path \$RulesDir | Out-Null
New-Item -ItemType Directory -Force -Path \$WorkflowsDir | Out-Null

Copy-Item "\$SourceDir\rules\*.mdc" \$RulesDir -Force
Copy-Item "\$SourceDir\workflows\*.md" \$WorkflowsDir -Force

Write-Host "Synced global Cursor rules/workflows into: \$TargetDir/.cursor" -ForegroundColor Green
Write-Host "Tips:" -ForegroundColor Yellow
Write-Host "- Global skills are already installed under ~/.cursor/skills-cursor"
Write-Host "- If you want file-pattern auto activation, keep these files in the project .cursor directory"
"@ | Set-Content $ps1File -Encoding UTF8
}

function Install-Codex {
    $HomeDir = if ($CodexHome) { $CodexHome } elseif ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
    $InstallRoot = Join-Path $HomeDir "ai-rules-skills"
    $RulesOut = Join-Path $InstallRoot "rules"
    $WorkflowsOut = Join-Path $InstallRoot "workflows"
    $SkillsOut = Join-Path $HomeDir "skills"
    $AgentsFile = Join-Path $HomeDir "AGENTS.md"

    Write-Host "[Codex] Installing to $HomeDir ..." -ForegroundColor Yellow

    Ensure-Dir $RulesOut
    Ensure-Dir $WorkflowsOut
    Ensure-Dir $SkillsOut

    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc" | Sort-Object Name) {
        $body = Read-RuleMarkdown $rule.FullName
        $target = Join-Path $RulesOut ($rule.BaseName + ".md")
        $body | Set-Content $target -Encoding UTF8
    }

    foreach ($workflow in Get-ChildItem "$WorkflowsDir\*.md" | Sort-Object Name) {
        $target = Join-Path $WorkflowsOut $workflow.Name
        Render-WorkflowFile -SourceFile $workflow.FullName -TargetFile $target -RuleDir $RulesOut -RuleExt "md" -SkillDir $SkillsOut -WorkflowDir $WorkflowsOut
    }

    foreach ($skillDir in Get-ChildItem $SkillsDir -Directory | Sort-Object Name) {
        $target = Join-Path (Join-Path $SkillsOut $skillDir.Name) "SKILL.md"
        Render-SkillFile -SourceFile (Join-Path $skillDir.FullName "SKILL.md") -TargetFile $target -RuleDir $RulesOut -RuleExt "md" -SkillDir $SkillsOut -WorkflowDir $WorkflowsOut
    }

    $block = @"
<!-- BEGIN ai-rules-skills -->
# ai-rules-skills 全局规范

本区块由 `tools/install-global.ps1` 自动维护，请勿手工改动区块内部内容。

$(Read-RuleMarkdown (Join-Path $RulesDir "00-global.mdc"))

---

## 按场景读取的详细规则

- Java / Spring 开发：`$RulesOut/01-java-backend.md`
- Java 安全：`$RulesOut/02-java-security.md`
- Java API：`$RulesOut/03-java-api-design.md`
- Go 后端开发：`$RulesOut/04-go-backend.md`
- Go 安全：`$RulesOut/05-go-security.md`
- Go API：`$RulesOut/06-go-api-design.md`
- Rust 后端开发：`$RulesOut/07-rust-backend.md`
- Rust 安全：`$RulesOut/08-rust-security.md`
- Rust HTTP/API：`$RulesOut/09-rust-api-design.md`
- Python 后端开发：`$RulesOut/10-python-backend.md`
- Python 安全：`$RulesOut/11-python-security.md`
- Python HTTP/API：`$RulesOut/12-python-api-design.md`
- Shell 脚本：`$RulesOut/13-shell-scripting.md`
- Shell 安全：`$RulesOut/14-shell-security.md`

## 全局 Skills

- 全局 Skills 目录：`$SkillsOut`
- 已按语言提供 `*-java`、`*-go`、`*-rust`、`*-python`、`*-shell` 五组 Skill 家族
- 每组均包含：`requirement-clarify`、`feature-dev`、`bug-fix`、`refactor`、`code-review`、`testing`、`deploy-doc`、`dev-review`

## 参考工作流文档

- 功能开发：`$WorkflowsOut/feature-dev.md`
- Bug 修复：`$WorkflowsOut/bug-fix.md`
- 代码审查：`$WorkflowsOut/code-review.md`
- 测试：`$WorkflowsOut/testing.md`
- 部署文档：`$WorkflowsOut/deploy-doc.md`
<!-- END ai-rules-skills -->
"@

    Upsert-ManagedBlock -TargetFile $AgentsFile -Block $block -StartMarker "<!-- BEGIN ai-rules-skills -->" -EndMarker "<!-- END ai-rules-skills -->"

    Write-Host "  -> $AgentsFile" -ForegroundColor Green
    Write-Host "  -> $RulesOut" -ForegroundColor Green
    Write-Host "  -> $SkillsOut" -ForegroundColor Green
}

function Install-Claude {
    $HomeDir = if ($ClaudeHome) { $ClaudeHome } elseif ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME ".claude" }
    $InstallRoot = Join-Path $HomeDir "ai-rules-skills"
    $RulesOut = Join-Path $InstallRoot "rules"
    $SkillsOut = Join-Path $InstallRoot "skills"
    $WorkflowsOut = Join-Path $InstallRoot "workflows"
    $CommandsOut = Join-Path (Join-Path $HomeDir "commands") "ai-rules-skills"
    $ClaudeMd = Join-Path $HomeDir "CLAUDE.md"

    Write-Host "[Claude Code] Installing to $HomeDir ..." -ForegroundColor Yellow

    Ensure-Dir $RulesOut
    Ensure-Dir $SkillsOut
    Ensure-Dir $WorkflowsOut
    Ensure-Dir $CommandsOut

    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc" | Sort-Object Name) {
        $body = Read-RuleMarkdown $rule.FullName
        $target = Join-Path $RulesOut ($rule.BaseName + ".md")
        $body | Set-Content $target -Encoding UTF8
    }

    foreach ($skillDir in Get-ChildItem $SkillsDir -Directory | Sort-Object Name) {
        $skillTarget = Join-Path (Join-Path $SkillsOut $skillDir.Name) "SKILL.md"
        Render-SkillFile -SourceFile (Join-Path $skillDir.FullName "SKILL.md") -TargetFile $skillTarget -RuleDir $RulesOut -RuleExt "md" -SkillDir $SkillsOut -WorkflowDir $WorkflowsOut

        @"
---
description: 执行 $($skillDir.Name) 全局 SOP
---

请严格按照 @$skillTarget 的流程处理当前任务。

如果用户在命令后补充了参数，请把这些参数视为本次任务的附加上下文：

`$ARGUMENTS
"@ | Set-Content (Join-Path $CommandsOut ($skillDir.Name + ".md")) -Encoding UTF8
    }

    foreach ($workflow in Get-ChildItem "$WorkflowsDir\*.md" | Sort-Object Name) {
        $target = Join-Path $WorkflowsOut $workflow.Name
        Render-WorkflowFile -SourceFile $workflow.FullName -TargetFile $target -RuleDir $RulesOut -RuleExt "md" -SkillDir $SkillsOut -WorkflowDir $WorkflowsOut
    }

    $block = @"
<!-- BEGIN ai-rules-skills -->
# ai-rules-skills 全局记忆

本区块由 `tools/install-global.ps1` 自动维护，请勿手工改动区块内部内容。

@$RulesOut/00-global.md

## 按需补充规则

- Java / Spring 开发：@$RulesOut/01-java-backend.md
- Java 安全：@$RulesOut/02-java-security.md
- Java API：@$RulesOut/03-java-api-design.md
- Go 后端开发：@$RulesOut/04-go-backend.md
- Go 安全：@$RulesOut/05-go-security.md
- Go API：@$RulesOut/06-go-api-design.md
- Rust 后端开发：@$RulesOut/07-rust-backend.md
- Rust 安全：@$RulesOut/08-rust-security.md
- Rust HTTP/API：@$RulesOut/09-rust-api-design.md
- Python 后端开发：@$RulesOut/10-python-backend.md
- Python 安全：@$RulesOut/11-python-security.md
- Python HTTP/API：@$RulesOut/12-python-api-design.md
- Shell 脚本：@$RulesOut/13-shell-scripting.md
- Shell 安全：@$RulesOut/14-shell-security.md

## 全局技能入口

- 通过 `/help` 查看命令，或直接使用：
- `/feature-dev-java`
- `/bug-fix-java`
- `/code-review-java`
- `/feature-dev-go`
- `/bug-fix-go`
- `/code-review-go`
- `/feature-dev-rust`
- `/feature-dev-python`
- `/feature-dev-shell`

## 参考文档

- 功能开发：@$WorkflowsOut/feature-dev.md
- Bug 修复：@$WorkflowsOut/bug-fix.md
- 代码审查：@$WorkflowsOut/code-review.md
- 测试：@$WorkflowsOut/testing.md
- 部署文档：@$WorkflowsOut/deploy-doc.md
<!-- END ai-rules-skills -->
"@

    Upsert-ManagedBlock -TargetFile $ClaudeMd -Block $block -StartMarker "<!-- BEGIN ai-rules-skills -->" -EndMarker "<!-- END ai-rules-skills -->"

    Write-Host "  -> $ClaudeMd" -ForegroundColor Green
    Write-Host "  -> $RulesOut" -ForegroundColor Green
    Write-Host "  -> $SkillsOut" -ForegroundColor Green
    Write-Host "  -> $CommandsOut" -ForegroundColor Green
}

function Install-Cursor {
    $HomeDir = if ($CursorHome) { $CursorHome } elseif ($env:CURSOR_HOME) { $env:CURSOR_HOME } else { Join-Path $HOME ".cursor" }
    $InstallRoot = Join-Path $HomeDir "ai-rules-skills"
    $RulesOut = Join-Path $InstallRoot "rules"
    $WorkflowsOut = Join-Path $InstallRoot "workflows"
    $SkillsOut = Join-Path $HomeDir "skills-cursor"
    $UserRulesFile = Join-Path $InstallRoot "user-rules.md"
    $ReadmeFile = Join-Path $InstallRoot "README.md"

    Write-Host "[Cursor] Installing to $HomeDir ..." -ForegroundColor Yellow

    Ensure-Dir $RulesOut
    Ensure-Dir $WorkflowsOut
    Ensure-Dir $SkillsOut

    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc" | Sort-Object Name) {
        Copy-Item $rule.FullName (Join-Path $RulesOut $rule.Name) -Force
    }

    foreach ($workflow in Get-ChildItem "$WorkflowsDir\*.md" | Sort-Object Name) {
        $target = Join-Path $WorkflowsOut $workflow.Name
        Render-WorkflowFile -SourceFile $workflow.FullName -TargetFile $target -RuleDir $RulesOut -RuleExt "mdc" -SkillDir $SkillsOut -WorkflowDir $WorkflowsOut
    }

    foreach ($skillDir in Get-ChildItem $SkillsDir -Directory | Sort-Object Name) {
        $skillTarget = Join-Path (Join-Path $SkillsOut $skillDir.Name) "SKILL.md"
        Render-SkillFile -SourceFile (Join-Path $skillDir.FullName "SKILL.md") -TargetFile $skillTarget -RuleDir $RulesOut -RuleExt "mdc" -SkillDir $SkillsOut -WorkflowDir $WorkflowsOut
    }

    @"
# Cursor User Rules 建议文本

> 说明：Cursor 官方稳定的全局入口是 User Rules，而文件级 `.cursor/rules/*.mdc` 仍然更适合项目内按 `globs` 自动激活。

$(Read-RuleMarkdown (Join-Path $RulesDir "00-global.mdc"))

---

## 详细规则源

- Java / Spring 开发：`$RulesOut/01-java-backend.mdc`
- Java 安全：`$RulesOut/02-java-security.mdc`
- Java API：`$RulesOut/03-java-api-design.mdc`
- Go 后端开发：`$RulesOut/04-go-backend.mdc`
- Go 安全：`$RulesOut/05-go-security.mdc`
- Go API：`$RulesOut/06-go-api-design.mdc`
- Rust 后端开发：`$RulesOut/07-rust-backend.mdc`
- Rust 安全：`$RulesOut/08-rust-security.mdc`
- Rust HTTP/API：`$RulesOut/09-rust-api-design.mdc`
- Python 后端开发：`$RulesOut/10-python-backend.mdc`
- Python 安全：`$RulesOut/11-python-security.mdc`
- Python HTTP/API：`$RulesOut/12-python-api-design.mdc`
- Shell 脚本：`$RulesOut/13-shell-scripting.mdc`
- Shell 安全：`$RulesOut/14-shell-security.mdc`

## 使用建议

- 将本文件内容粘贴到 Cursor Settings -> Rules -> User Rules
- 若希望保留 `globs` 自动激活，请运行同目录下的 `bootstrap-project.sh` 或 `bootstrap-project.ps1`，把规则同步到具体项目的 `.cursor/` 目录
- 全局 Skills 已安装到 `$SkillsOut`
"@ | Set-Content $UserRulesFile -Encoding UTF8

    @"
# Cursor Global Install

本目录由 `tools/install-global.ps1` 自动生成，用于给 Cursor 提供全局规则源与全局 Skills。

## 已安装内容

- 规则源：`$RulesOut`
- 工作流参考：`$WorkflowsOut`
- 全局 Skills：`$SkillsOut`
- User Rules 建议文本：`$UserRulesFile`

## 注意事项

- Cursor 官方文档中稳定的全局规则入口是 User Rules
- `.cursor/rules/*.mdc` 的 `globs` 自动激活仍然是项目级能力
- 因此本安装方案采用“全局 Skills + 全局规则源 + 项目 bootstrap”模式
"@ | Set-Content $ReadmeFile -Encoding UTF8

    Write-CursorBootstrapScripts -CursorRoot $InstallRoot

    Write-Host "  -> $RulesOut" -ForegroundColor Green
    Write-Host "  -> $SkillsOut" -ForegroundColor Green
    Write-Host "  -> $(Join-Path $InstallRoot 'bootstrap-project.sh')" -ForegroundColor Green
    Write-Host "  -> $UserRulesFile" -ForegroundColor Green
}

$NormalizedPlatform = Normalize-Platform $Platform
if (-not $NormalizedPlatform) {
    Write-Host "[ERROR] Unknown platform: $Platform" -ForegroundColor Red
    Write-Host "Valid: codex cursor claude claudecode all" -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI Rules Global Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Source:   $SrcDir" -ForegroundColor Gray
Write-Host "  Platform: $NormalizedPlatform" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$Platforms = if ($NormalizedPlatform -eq "all") {
    @("codex", "cursor", "claude")
} else {
    @($NormalizedPlatform)
}

foreach ($Item in $Platforms) {
    switch ($Item) {
        "codex" { Install-Codex }
        "cursor" { Install-Cursor }
        "claude" { Install-Claude }
    }
    Write-Host ""
}

Write-Host "Done! Installed for: $($Platforms -join ', ')" -ForegroundColor Green
Write-Host ""
