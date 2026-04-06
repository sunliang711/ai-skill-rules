<#
.SYNOPSIS
    Generate platform-specific AI rules formats from the ai-rules-skills repository.

.DESCRIPTION
    Supports 9 major AI coding tools: cursor / copilot / claude / codex / antigravity / gemini / windsurf / aider / lingma

.PARAMETER Platform
    Target platform. Valid values: cursor, copilot, claude, codex, antigravity, gemini, windsurf, aider, lingma, all

.PARAMETER TargetDir
    The root directory of the target project to output the generated rules to.

.PARAMETER Help
    Show help information.

.EXAMPLE
    .\generate-for-platform.ps1 -Platform copilot -TargetDir "D:\my-project"
    .\generate-for-platform.ps1 -Platform all -TargetDir "D:\my-project"
#>

param(
    [ValidateSet("cursor","copilot","claude","codex","antigravity","gemini","windsurf","aider","lingma","all")]
    [string]$Platform,
    [string]$TargetDir,
    [switch]$Help
)

# === Help Message ===
if ($Help -or -not $Platform -or -not $TargetDir) {
    Write-Host @"

  AI Rules Cross-Platform Generator
  ==================================

  Usage:
    .\generate-for-platform.ps1 -Platform <Platform> -TargetDir <TargetDirectory>

  Supported Platforms:
    cursor       Cursor IDE (.cursor/rules/*.mdc + skills + workflows)
    copilot      GitHub Copilot (.github/copilot-instructions.md)
    claude       Claude Code (CLAUDE.md)
    codex        OpenAI Codex (AGENTS.md)
    antigravity  Google Antigravity (AGENTS.md + .agents/)
    gemini       Gemini CLI / Code Assist (GEMINI.md)
    windsurf     Windsurf (.windsurfrules)
    aider        Aider (CONVENTIONS.md + .aider.conf.yml)
    lingma       Tongyi Lingma (.lingma/rules/)
    all          Generate format for all of the above

  Example:
    .\generate-for-platform.ps1 -Platform copilot -TargetDir "D:\my-project"

"@ -ForegroundColor Cyan
    return
}

# === Constants ===
$SrcDir = Split-Path $PSScriptRoot -Parent   # ai-rules-skills root
$RulesDir = Join-Path $SrcDir "rules"
$SkillsDir = Join-Path $SrcDir "skills"
$WorkflowsDir = Join-Path $SrcDir "workflows"
$AgentsMd = Join-Path $SrcDir "AGENTS.md"

# Cursor frontmatter metadata
$CursorMeta = @{
    "00-global"         = @{ desc = "Global Mandatory Standards"; always = "true"; globs = $null }
    "01-java-backend"   = @{ desc = "Java/Spring Backend Standards"; always = "false"; globs = '"**/*.java"' }
    "02-java-security"  = @{ desc = "Java/Spring Security Baselines"; always = "false"; globs = '"**/*.java, **/*.yml, **/*.yaml, **/*.properties"' }
    "03-java-api-design" = @{ desc = "Java/Spring API Design Standards"; always = "false"; globs = '"**/controller/**/*.java, **/web/**/*.java"' }
    "04-go-backend"     = @{ desc = "Go Backend Standards"; always = "false"; globs = '"**/*.go"' }
    "05-go-security"    = @{ desc = "Go Security Baselines"; always = "false"; globs = '"**/*.go, **/*.toml, **/.env, **/.env.example, **/Dockerfile"' }
    "06-go-api-design"  = @{ desc = "Go API Design Standards"; always = "false"; globs = '"**/handler/**/*.go, **/router/**/*.go, **/transport/http/**/*.go, **/*handler*.go"' }
}

# === Helper Functions ===
function Strip-Frontmatter {
    param([string]$Content)
    if ($Content -match "(?s)^---\r?\n.*?\r?\n---\r?\n(.*)$") {
        return $Matches[1].TrimStart()
    }
    return $Content
}

function Read-RuleContent {
    param([string]$FilePath)
    $raw = Get-Content $FilePath -Raw -Encoding UTF8
    return Strip-Frontmatter $raw
}

function Read-AgentsMd-Generic {
    # Read AGENTS.md and replace Cursor-specific paths with generic ones
    $content = Get-Content $AgentsMd -Raw -Encoding UTF8
    $content = $content -replace '\.cursor/rules/', '.agents/rules/'
    $content = $content -replace '\.cursor/skills/', '.agents/skills/'
    $content = $content -replace '\.mdc', '.md'
    return $content
}

function Read-AgentsMd-Codex {
    # Read AGENTS.md and replace Cursor-specific paths with Codex-specific paths
    $content = Get-Content $AgentsMd -Raw -Encoding UTF8
    $content = $content -replace '\.cursor/rules/', '.codex/rules/'
    $content = $content -replace '\.cursor/skills/', '.codex/skills/'
    $content = $content -replace '\.mdc', '.md'
    return $content
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# === Generators ===

function Generate-Cursor {
    Write-Host "[Cursor] Generating .cursor/rules/*.mdc + skills + workflows ..." -ForegroundColor Yellow

    $outRules = Join-Path $TargetDir ".cursor\rules"
    Ensure-Dir $outRules

    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc") {
        Copy-Item $rule.FullName (Join-Path $outRules $rule.Name) -Force
    }

    # Copy skills
    $outSkills = Join-Path $TargetDir ".cursor\skills"
    if (Test-Path $SkillsDir) {
        Copy-Item $SkillsDir $outSkills -Recurse -Force
    }

    # Copy workflows
    $outWorkflows = Join-Path $TargetDir ".cursor\workflows"
    if (Test-Path $WorkflowsDir) {
        Ensure-Dir $outWorkflows
        Copy-Item "$WorkflowsDir\*" $outWorkflows -Force
    }

    Write-Host "  -> $outRules ($((Get-ChildItem $outRules).Count) files)" -ForegroundColor Green
}

function Generate-Copilot {
    Write-Host "[Copilot] Generating .github/copilot-instructions.md ..." -ForegroundColor Yellow

    $outDir = Join-Path $TargetDir ".github"
    Ensure-Dir $outDir
    $outFile = Join-Path $outDir "copilot-instructions.md"

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("<!-- Auto-generated from ai-rules-skills. DO NOT EDIT MANUALLY. -->")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("# Project AI Coding Standards")
    [void]$sb.AppendLine("")

    # Merge all rules (strip frontmatter)
    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc" | Sort-Object Name) {
        $body = Read-RuleContent $rule.FullName
        [void]$sb.AppendLine($body)
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("")
    }

    $sb.ToString() | Set-Content $outFile -Encoding UTF8
    Write-Host "  -> $outFile ($([math]::Round((Get-Item $outFile).Length / 1KB, 1)) KB)" -ForegroundColor Green
}

function Generate-Claude {
    Write-Host "[Claude Code] Generating CLAUDE.md ..." -ForegroundColor Yellow

    $outFile = Join-Path $TargetDir "CLAUDE.md"
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("<!-- Auto-generated from ai-rules-skills. DO NOT EDIT MANUALLY. -->")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("# Project AI Guidelines")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("> Detailed specs are in `.agents/rules/`. Please read them when encountering relevant scenarios.")
    [void]$sb.AppendLine("")

    # Full embedding of global rules
    $global = Read-RuleContent (Join-Path $RulesDir "00-global.mdc")
    [void]$sb.AppendLine($global)
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")

    # Other rules exist as abstract references
    [void]$sb.AppendLine("## Language-Specific Standards (Read As Needed)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Scenario | File to Read |")
    [void]$sb.AppendLine("|----------|-------------|")
    [void]$sb.AppendLine("| Edit Java Code | `.agents/rules/01-java-backend.md` |")
    [void]$sb.AppendLine("| Java Security | `.agents/rules/02-java-security.md` |")
    [void]$sb.AppendLine("| Java Controller/API | `.agents/rules/03-java-api-design.md` |")
    [void]$sb.AppendLine("| Edit Go Code | `.agents/rules/04-go-backend.md` |")
    [void]$sb.AppendLine("| Go Security | `.agents/rules/05-go-security.md` |")
    [void]$sb.AppendLine("| Go Handler/API | `.agents/rules/06-go-api-design.md` |")
    [void]$sb.AppendLine("| Edit Rust Code | `.agents/rules/07-rust-backend.md` |")
    [void]$sb.AppendLine("| Rust Security | `.agents/rules/08-rust-security.md` |")
    [void]$sb.AppendLine("| Rust HTTP/API | `.agents/rules/09-rust-api-design.md` |")
    [void]$sb.AppendLine("| Edit Python Code | `.agents/rules/10-python-backend.md` |")
    [void]$sb.AppendLine("| Python Security | `.agents/rules/11-python-security.md` |")
    [void]$sb.AppendLine("| Python HTTP/API | `.agents/rules/12-python-api-design.md` |")
    [void]$sb.AppendLine("| Edit Shell Script | `.agents/rules/13-shell-scripting.md` |")
    [void]$sb.AppendLine("| Shell Security | `.agents/rules/14-shell-security.md` |")
    [void]$sb.AppendLine("")

    # SOP references
    [void]$sb.AppendLine("## SOP Workflows (Read As Needed)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Language | Skill Family |")
    [void]$sb.AppendLine("|----------|-------------|")
    [void]$sb.AppendLine("| Java | `.agents/skills/*-java/SKILL.md` |")
    [void]$sb.AppendLine("| Go | `.agents/skills/*-go/SKILL.md` |")
    [void]$sb.AppendLine("| Rust | `.agents/skills/*-rust/SKILL.md` |")
    [void]$sb.AppendLine("| Python | `.agents/skills/*-python/SKILL.md` |")
    [void]$sb.AppendLine("| Shell | `.agents/skills/*-shell/SKILL.md` |")

    $sb.ToString() | Set-Content $outFile -Encoding UTF8
    Write-Host "  -> $outFile ($([math]::Round((Get-Item $outFile).Length / 1KB, 1)) KB)" -ForegroundColor Green
}

function Generate-Codex {
    Write-Host "[Codex] Generating AGENTS.md + .codex/rules/ + .codex/skills/ ..." -ForegroundColor Yellow

    $outFile = Join-Path $TargetDir "AGENTS.md"
    $content = Read-AgentsMd-Codex

    # Copy rule files (strip cursor frontmatter, use .md)
    $outRules = Join-Path $TargetDir ".codex\rules"
    Ensure-Dir $outRules

    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc" | Sort-Object Name) {
        $body = Read-RuleContent $rule.FullName
        $mdName = $rule.BaseName + ".md"
        $body | Set-Content (Join-Path $outRules $mdName) -Encoding UTF8
    }

    # Skills
    $outSkills = Join-Path $TargetDir ".codex\skills"
    if (Test-Path $SkillsDir) {
        Copy-Item $SkillsDir $outSkills -Recurse -Force
    }

    $content | Set-Content $outFile -Encoding UTF8
    Write-Host "  -> $outFile + $outRules ($(( Get-ChildItem $outRules).Count) rules) + .codex\skills" -ForegroundColor Green
}

function Generate-Antigravity {
    Write-Host "[Antigravity] Generating AGENTS.md + .agents/ ..." -ForegroundColor Yellow

    # AGENTS.md
    $outFile = Join-Path $TargetDir "AGENTS.md"
    $content = Read-AgentsMd-Generic
    $content | Set-Content $outFile -Encoding UTF8

    # Rule files
    $outRules = Join-Path $TargetDir ".agents\rules"
    Ensure-Dir $outRules
    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc" | Sort-Object Name) {
        $body = Read-RuleContent $rule.FullName
        $mdName = $rule.BaseName + ".md"
        $body | Set-Content (Join-Path $outRules $mdName) -Encoding UTF8
    }

    # Skills (Keep YAML frontmatter)
    $outSkills = Join-Path $TargetDir ".agents\skills"
    if (Test-Path $SkillsDir) {
        Copy-Item $SkillsDir $outSkills -Recurse -Force
    }

    # Workflows
    $outWorkflows = Join-Path $TargetDir ".agents\workflows"
    if (Test-Path $WorkflowsDir) {
        Ensure-Dir $outWorkflows
        Copy-Item "$WorkflowsDir\*" $outWorkflows -Force
    }

    $skillCount = if (Test-Path $outSkills) { (Get-ChildItem $outSkills -Directory).Count } else { 0 }
    Write-Host "  -> AGENTS.md + $((Get-ChildItem $outRules).Count) rules + $skillCount skills" -ForegroundColor Green
}

function Generate-Gemini {
    Write-Host "[Gemini CLI] Generating GEMINI.md ..." -ForegroundColor Yellow

    $outFile = Join-Path $TargetDir "GEMINI.md"
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("<!-- Auto-generated from ai-rules-skills. DO NOT EDIT MANUALLY. -->")
    [void]$sb.AppendLine("")

    $global = Read-RuleContent (Join-Path $RulesDir "00-global.mdc")
    [void]$sb.AppendLine($global)
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")

    # Security baseline summaries
    [void]$sb.AppendLine("## Security Baselines Quick Reference")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("- NO HARDCODED SECRETS (passwords/keys/tokens). Use environment variables.")
    [void]$sb.AppendLine("- SQL MUST BE PARAMETERIZED. String concatenation is forbidden.")
    [void]$sb.AppendLine("- LOGS MUST NOT CONTAIN private keys, passwords, PINs, or full JWT tokens.")
    [void]$sb.AppendLine("- AMOUNTS MUST BE BigDecimal (Java) / shopspring/decimal (Go). NEVER use float/double.")
    [void]$sb.AppendLine("- JWT MUST USE RS256/ES256. HS256 is forbidden.")
    [void]$sb.AppendLine("- TLS 1.2+ IS MANDATORY. Trust-all-certificates is forbidden.")
    [void]$sb.AppendLine("- JSON MUST USE Jackson (Java) / encoding/json (Go). Fastjson is forbidden.")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("> See `.agents/rules/02-java-security.md` and `.agents/rules/05-go-security.md` for full specs.")

    $sb.ToString() | Set-Content $outFile -Encoding UTF8
    Write-Host "  -> $outFile ($([math]::Round((Get-Item $outFile).Length / 1KB, 1)) KB)" -ForegroundColor Green
}

function Generate-Windsurf {
    Write-Host "[Windsurf] Generating .windsurfrules ..." -ForegroundColor Yellow

    $outFile = Join-Path $TargetDir ".windsurfrules"
    $sb = [System.Text.StringBuilder]::new()

    # Global Rules
    $global = Read-RuleContent (Join-Path $RulesDir "00-global.mdc")
    [void]$sb.AppendLine($global)
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")

    # Security Baselines
    [void]$sb.AppendLine("# Security Baselines (Java & Go)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("- No hardcoded secrets (pwd/keys/tokens)")
    [void]$sb.AppendLine("- Parameterized SQL only (No concat)")
    [void]$sb.AppendLine("- Sanitize logs (No sensitive info)")
    [void]$sb.AppendLine("- Amounts must be BigDecimal/decimal")
    [void]$sb.AppendLine("- JWT must be RS256/ES256")
    [void]$sb.AppendLine("- Exception responses must not leak stack/SQL")
    [void]$sb.AppendLine("- No fastjson")
    [void]$sb.AppendLine("- TLS 1.2+ mandatory")

    $result = $sb.ToString()

    # Character limits check for windsurf
    if ($result.Length -gt 6000) {
        Write-Host "  [WARN] Content $($result.Length) chars > 6000, truncating..." -ForegroundColor DarkYellow
        $result = $result.Substring(0, 5900) + "`n`n<!-- Truncated. See .agents/rules/ for full rules. -->"
    }

    $result | Set-Content $outFile -Encoding UTF8
    Write-Host "  -> $outFile ($($result.Length) chars)" -ForegroundColor Green
}

function Generate-Aider {
    Write-Host "[Aider] Generating CONVENTIONS.md + .aider.conf.yml ..." -ForegroundColor Yellow

    # CONVENTIONS.md = Global + Security rules
    $outConv = Join-Path $TargetDir "CONVENTIONS.md"
    $sb = [System.Text.StringBuilder]::new()

    $global = Read-RuleContent (Join-Path $RulesDir "00-global.mdc")
    [void]$sb.AppendLine($global)

    # Embed security rules
    foreach ($secFile in @("02-java-security.mdc", "05-go-security.mdc")) {
        $path = Join-Path $RulesDir $secFile
        if (Test-Path $path) {
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("---")
            [void]$sb.AppendLine("")
            $body = Read-RuleContent $path
            [void]$sb.AppendLine($body)
        }
    }

    $sb.ToString() | Set-Content $outConv -Encoding UTF8

    # .aider.conf.yml
    $outConf = Join-Path $TargetDir ".aider.conf.yml"
    $confContent = @"
# Auto-generated. Configures Aider to load project conventions.
read:
  - CONVENTIONS.md
"@
    $confContent | Set-Content $outConf -Encoding UTF8

    Write-Host "  -> $outConv + $outConf" -ForegroundColor Green
}

function Generate-Lingma {
    Write-Host "[Tongyi Lingma] Generating .lingma/rules/ ..." -ForegroundColor Yellow

    $outDir = Join-Path $TargetDir ".lingma\rules"
    Ensure-Dir $outDir

    $count = 0
    foreach ($rule in Get-ChildItem "$RulesDir\*.mdc" | Sort-Object Name) {
        $body = Read-RuleContent $rule.FullName
        $mdName = $rule.BaseName + ".md"

        # Check character limits (10000 chars per file limit for Lingma)
        if ($body.Length -gt 10000) {
            Write-Host "  [WARN] $mdName ($($body.Length) chars) exceeds 10000 limit, splitting..." -ForegroundColor DarkYellow
            # Split by markdown headers
            $sections = $body -split "(?m)^## "
            $partNum = 1
            $currentPart = ""
            foreach ($sec in $sections) {
                if (-not $sec.Trim()) { continue }
                $secContent = "## $sec"
                if (($currentPart + $secContent).Length -gt 9500) {
                    if ($currentPart) {
                        $partName = "$($rule.BaseName)-part$partNum.md"
                        $currentPart | Set-Content (Join-Path $outDir $partName) -Encoding UTF8
                        $partNum++
                        $count++
                    }
                    $currentPart = $secContent
                } else {
                    $currentPart += "`n`n$secContent"
                }
            }
            if ($currentPart) {
                $partName = "$($rule.BaseName)-part$partNum.md"
                $currentPart | Set-Content (Join-Path $outDir $partName) -Encoding UTF8
                $count++
            }
        } else {
            $body | Set-Content (Join-Path $outDir $mdName) -Encoding UTF8
            $count++
        }
    }

    Write-Host "  -> $outDir ($count files)" -ForegroundColor Green
}

# === Main Logic ===
$TargetDir = $TargetDir.TrimEnd('\', '/')

if (-not (Test-Path $TargetDir)) {
    Write-Host "[ERROR] Target directory not found: $TargetDir" -ForegroundColor Red
    return
}

if (-not (Test-Path $RulesDir)) {
    Write-Host "[ERROR] Rules directory not found: $RulesDir" -ForegroundColor Red
    return
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI Rules Cross-Platform Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Source:  $SrcDir" -ForegroundColor Gray
Write-Host "  Target:  $TargetDir" -ForegroundColor Gray
Write-Host "  Platform: $Platform" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$platforms = if ($Platform -eq "all") {
    @("cursor","copilot","claude","codex","antigravity","gemini","windsurf","aider","lingma")
} else {
    @($Platform)
}

foreach ($p in $platforms) {
    switch ($p) {
        "cursor"       { Generate-Cursor }
        "copilot"      { Generate-Copilot }
        "claude"       { Generate-Claude }
        "codex"        { Generate-Codex }
        "antigravity"  { Generate-Antigravity }
        "gemini"       { Generate-Gemini }
        "windsurf"     { Generate-Windsurf }
        "aider"        { Generate-Aider }
        "lingma"       { Generate-Lingma }
    }
    Write-Host ""
}

Write-Host "Done! Generated for: $($platforms -join ', ')" -ForegroundColor Green
Write-Host ""
