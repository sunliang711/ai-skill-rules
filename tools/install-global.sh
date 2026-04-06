#!/usr/bin/env bash
# ==============================================================================
# install-global.sh
# Install ai-rules-skills into the global directories of Codex / Cursor /
# Claude Code.
#
# Supports:
#   codex / cursor / claude / claudecode / all
#
# Usage:
#   ./tools/install-global.sh codex
#   ./tools/install-global.sh cursor
#   ./tools/install-global.sh claudecode
#   ./tools/install-global.sh all
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RULES_DIR="$SRC_DIR/rules"
SKILLS_DIR="$SRC_DIR/skills"
WORKFLOWS_DIR="$SRC_DIR/workflows"

show_help() {
    cat <<EOF

  ${CYAN}AI Rules Global Installer${NC}
  =========================

  Usage:
    ./tools/install-global.sh <platform>

  Supported Platforms:
    codex         Install to \$CODEX_HOME or ~/.codex
    cursor        Install to ~/.cursor
    claude        Install to ~/.claude
    claudecode    Alias of claude
    all           Install to all supported global locations

  Optional Environment Variables:
    CODEX_HOME    Override Codex home directory
    CURSOR_HOME   Override Cursor home directory
    CLAUDE_HOME   Override Claude Code home directory

  Example:
    ./tools/install-global.sh codex
    ./tools/install-global.sh claudecode
    ./tools/install-global.sh all

EOF
}

ensure_dir() {
    mkdir -p "$1"
}

strip_frontmatter() {
    awk '
        {
            sub(/\r$/, "")
        }
        BEGIN {
            skip = 0
            found = 0
        }
        $0 == "---" {
            if (found == 0) {
                found = 1
                skip = 1
                next
            } else if (skip == 1) {
                skip = 0
                next
            }
        }
        skip == 0 {
            print
        }
    '
}

read_rule_markdown() {
    strip_frontmatter < "$1"
}

rewrite_content() {
    local rule_dir="$1"
    local rule_ext="$2"
    local skill_dir="$3"
    local workflow_dir="$4"

    RULE_DIR="$rule_dir" \
    RULE_EXT="$rule_ext" \
    SKILL_DIR="$skill_dir" \
    WORKFLOW_DIR="$workflow_dir" \
    perl -0pe '
        s{\.(?:cursor|agents|codex)/rules/([A-Za-z0-9._-]+)\.(?:mdc|md)}{$ENV{RULE_DIR}/$1.$ENV{RULE_EXT}}g;
        s{\brules/([A-Za-z0-9._-]+)\.mdc\b}{$ENV{RULE_DIR}/$1.$ENV{RULE_EXT}}g;
        s{\.(?:cursor|agents|codex)/skills/([A-Za-z0-9._-]+/SKILL\.md)}{$ENV{SKILL_DIR}/$1}g;
        s{\bskills/([A-Za-z0-9._-]+/SKILL\.md)\b}{$ENV{SKILL_DIR}/$1}g;
        s{\.(?:cursor|agents|codex)/workflows/([A-Za-z0-9._-]+\.md)}{$ENV{WORKFLOW_DIR}/$1}g;
        s{\bworkflows/([A-Za-z0-9._-]+\.md)\b}{$ENV{WORKFLOW_DIR}/$1}g;
    '
}

render_skill_file() {
    local src_file="$1"
    local dst_file="$2"
    local rule_dir="$3"
    local rule_ext="$4"
    local skill_dir="$5"
    local workflow_dir="$6"

    ensure_dir "$(dirname "$dst_file")"
    rewrite_content "$rule_dir" "$rule_ext" "$skill_dir" "$workflow_dir" < "$src_file" > "$dst_file"
}

render_workflow_file() {
    local src_file="$1"
    local dst_file="$2"
    local rule_dir="$3"
    local rule_ext="$4"
    local skill_dir="$5"
    local workflow_dir="$6"

    ensure_dir "$(dirname "$dst_file")"
    rewrite_content "$rule_dir" "$rule_ext" "$skill_dir" "$workflow_dir" < "$src_file" > "$dst_file"
}

upsert_managed_block() {
    local target_file="$1"
    local block_file="$2"
    local start_marker="$3"
    local end_marker="$4"
    local tmp_file

    tmp_file="$(mktemp)"

    if [ -f "$target_file" ] && grep -qF "$start_marker" "$target_file"; then
        awk \
            -v start="$start_marker" \
            -v end="$end_marker" \
            -v block_file="$block_file" '
                BEGIN {
                    while ((getline line < block_file) > 0) {
                        block = block line ORS
                    }
                    close(block_file)
                }
                {
                    if (index($0, start) > 0) {
                        if (!inserted) {
                            printf "%s", block
                            inserted = 1
                        }
                        skipping = 1
                        next
                    }
                    if (skipping && index($0, end) > 0) {
                        skipping = 0
                        next
                    }
                    if (!skipping) {
                        print
                    }
                }
            ' "$target_file" > "$tmp_file"
    else
        if [ -f "$target_file" ] && [ -s "$target_file" ]; then
            cat "$target_file" > "$tmp_file"
            printf '\n\n' >> "$tmp_file"
            cat "$block_file" >> "$tmp_file"
        else
            cat "$block_file" > "$tmp_file"
        fi
    fi

    mv "$tmp_file" "$target_file"
}

write_cursor_bootstrap_scripts() {
    local cursor_root="$1"
    local shell_file="$cursor_root/bootstrap-project.sh"
    local ps1_file="$cursor_root/bootstrap-project.ps1"

    cat > "$shell_file" <<EOF
#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$cursor_root"
TARGET_DIR="\${1:-\$(pwd)}"

mkdir -p "\$TARGET_DIR/.cursor/rules" "\$TARGET_DIR/.cursor/workflows"
cp "\$SOURCE_DIR/rules"/*.mdc "\$TARGET_DIR/.cursor/rules/"
cp "\$SOURCE_DIR/workflows"/*.md "\$TARGET_DIR/.cursor/workflows/"

echo "Synced global Cursor rules/workflows into: \$TARGET_DIR/.cursor"
echo "Tips:"
echo "- Global skills are already installed under ~/.cursor/skills-cursor"
echo "- If you want file-pattern auto activation, keep these files in the project .cursor directory"
EOF
    chmod +x "$shell_file"

    cat > "$ps1_file" <<EOF
param(
    [string]\$TargetDir = (Get-Location).Path
)

\$SourceDir = "$cursor_root"
\$RulesDir = Join-Path \$TargetDir ".cursor\\rules"
\$WorkflowsDir = Join-Path \$TargetDir ".cursor\\workflows"

New-Item -ItemType Directory -Force -Path \$RulesDir | Out-Null
New-Item -ItemType Directory -Force -Path \$WorkflowsDir | Out-Null

Copy-Item "\$SourceDir\\rules\\*.mdc" \$RulesDir -Force
Copy-Item "\$SourceDir\\workflows\\*.md" \$WorkflowsDir -Force

Write-Host "Synced global Cursor rules/workflows into: \$TargetDir/.cursor" -ForegroundColor Green
Write-Host "Tips:" -ForegroundColor Yellow
Write-Host "- Global skills are already installed under ~/.cursor/skills-cursor"
Write-Host "- If you want file-pattern auto activation, keep these files in the project .cursor directory"
EOF
}

install_codex() {
    local codex_home="${CODEX_HOME:-$HOME/.codex}"
    local install_root="$codex_home/ai-rules-skills"
    local rules_out="$install_root/rules"
    local workflows_out="$install_root/workflows"
    local skills_out="$codex_home/skills"
    local agents_file="$codex_home/AGENTS.md"
    local block_file

    echo -e "${YELLOW}[Codex] Installing to $codex_home ...${NC}"

    ensure_dir "$rules_out"
    ensure_dir "$workflows_out"
    ensure_dir "$skills_out"

    for rule in "$RULES_DIR"/*.mdc; do
        local base
        base="$(basename "$rule" .mdc)"
        read_rule_markdown "$rule" > "$rules_out/$base.md"
    done

    for workflow in "$WORKFLOWS_DIR"/*.md; do
        render_workflow_file \
            "$workflow" \
            "$workflows_out/$(basename "$workflow")" \
            "$rules_out" \
            "md" \
            "$skills_out" \
            "$workflows_out"
    done

    for skill_dir in "$SKILLS_DIR"/*; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        render_skill_file \
            "$skill_dir/SKILL.md" \
            "$skills_out/$skill_name/SKILL.md" \
            "$rules_out" \
            "md" \
            "$skills_out" \
            "$workflows_out"
    done

    block_file="$(mktemp)"
    cat > "$block_file" <<EOF
<!-- BEGIN ai-rules-skills -->
# ai-rules-skills 全局规范

本区块由 \`tools/install-global.sh\` 自动维护，请勿手工改动区块内部内容。
EOF
    cat "$rules_out/00-global.md" >> "$block_file"
    cat >> "$block_file" <<EOF

---

## 按场景读取的详细规则

- Java / Spring 开发：\`$rules_out/01-java-backend.md\`
- Java 安全：\`$rules_out/02-java-security.md\`
- Java API：\`$rules_out/03-java-api-design.md\`
- Go 后端开发：\`$rules_out/04-go-backend.md\`
- Go 安全：\`$rules_out/05-go-security.md\`
- Go API：\`$rules_out/06-go-api-design.md\`
- Rust 后端开发：\`$rules_out/07-rust-backend.md\`
- Rust 安全：\`$rules_out/08-rust-security.md\`
- Rust HTTP/API：\`$rules_out/09-rust-api-design.md\`
- Python 后端开发：\`$rules_out/10-python-backend.md\`
- Python 安全：\`$rules_out/11-python-security.md\`
- Python HTTP/API：\`$rules_out/12-python-api-design.md\`
- Shell 脚本：\`$rules_out/13-shell-scripting.md\`
- Shell 安全：\`$rules_out/14-shell-security.md\`

## 全局 Skills

- 全局 Skills 目录：\`$skills_out\`
- 已按语言提供 \`*-java\`、\`*-go\`、\`*-rust\`、\`*-python\`、\`*-shell\` 五组 Skill 家族
- 每组均包含：\`requirement-clarify\`、\`feature-dev\`、\`bug-fix\`、\`refactor\`、\`code-review\`、\`testing\`、\`deploy-doc\`、\`dev-review\`

## 参考工作流文档

- 功能开发：\`$workflows_out/feature-dev.md\`
- Bug 修复：\`$workflows_out/bug-fix.md\`
- 代码审查：\`$workflows_out/code-review.md\`
- 测试：\`$workflows_out/testing.md\`
- 部署文档：\`$workflows_out/deploy-doc.md\`
<!-- END ai-rules-skills -->
EOF

    upsert_managed_block "$agents_file" "$block_file" "<!-- BEGIN ai-rules-skills -->" "<!-- END ai-rules-skills -->"
    rm -f "$block_file"

    echo -e "${GREEN}  -> $agents_file${NC}"
    echo -e "${GREEN}  -> $rules_out${NC}"
    echo -e "${GREEN}  -> $skills_out${NC}"
}

install_claude() {
    local claude_home="${CLAUDE_HOME:-$HOME/.claude}"
    local install_root="$claude_home/ai-rules-skills"
    local rules_out="$install_root/rules"
    local skills_out="$install_root/skills"
    local workflows_out="$install_root/workflows"
    local commands_out="$claude_home/commands/ai-rules-skills"
    local claude_md="$claude_home/CLAUDE.md"
    local block_file

    echo -e "${YELLOW}[Claude Code] Installing to $claude_home ...${NC}"

    ensure_dir "$rules_out"
    ensure_dir "$skills_out"
    ensure_dir "$workflows_out"
    ensure_dir "$commands_out"

    for rule in "$RULES_DIR"/*.mdc; do
        local base
        base="$(basename "$rule" .mdc)"
        read_rule_markdown "$rule" > "$rules_out/$base.md"
    done

    for skill_dir in "$SKILLS_DIR"/*; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        render_skill_file \
            "$skill_dir/SKILL.md" \
            "$skills_out/$skill_name/SKILL.md" \
            "$rules_out" \
            "md" \
            "$skills_out" \
            "$workflows_out"

        cat > "$commands_out/$skill_name.md" <<EOF
---
description: 执行 $skill_name 全局 SOP
---

请严格按照 @$skills_out/$skill_name/SKILL.md 的流程处理当前任务。

如果用户在命令后补充了参数，请把这些参数视为本次任务的附加上下文：

\$ARGUMENTS
EOF
    done

    for workflow in "$WORKFLOWS_DIR"/*.md; do
        render_workflow_file \
            "$workflow" \
            "$workflows_out/$(basename "$workflow")" \
            "$rules_out" \
            "md" \
            "$skills_out" \
            "$workflows_out"
    done

    block_file="$(mktemp)"
    cat > "$block_file" <<EOF
<!-- BEGIN ai-rules-skills -->
# ai-rules-skills 全局记忆

本区块由 \`tools/install-global.sh\` 自动维护，请勿手工改动区块内部内容。

@${rules_out}/00-global.md

## 按需补充规则

- Java / Spring 开发：@${rules_out}/01-java-backend.md
- Java 安全：@${rules_out}/02-java-security.md
- Java API：@${rules_out}/03-java-api-design.md
- Go 后端开发：@${rules_out}/04-go-backend.md
- Go 安全：@${rules_out}/05-go-security.md
- Go API：@${rules_out}/06-go-api-design.md
- Rust 后端开发：@${rules_out}/07-rust-backend.md
- Rust 安全：@${rules_out}/08-rust-security.md
- Rust HTTP/API：@${rules_out}/09-rust-api-design.md
- Python 后端开发：@${rules_out}/10-python-backend.md
- Python 安全：@${rules_out}/11-python-security.md
- Python HTTP/API：@${rules_out}/12-python-api-design.md
- Shell 脚本：@${rules_out}/13-shell-scripting.md
- Shell 安全：@${rules_out}/14-shell-security.md

## 全局技能入口

- 通过 \`/help\` 查看命令，或直接使用：
- \`/feature-dev-java\`
- \`/bug-fix-java\`
- \`/code-review-java\`
- \`/feature-dev-go\`
- \`/bug-fix-go\`
- \`/code-review-go\`
- \`/feature-dev-rust\`
- \`/feature-dev-python\`
- \`/feature-dev-shell\`

## 参考文档

- 功能开发：@${workflows_out}/feature-dev.md
- Bug 修复：@${workflows_out}/bug-fix.md
- 代码审查：@${workflows_out}/code-review.md
- 测试：@${workflows_out}/testing.md
- 部署文档：@${workflows_out}/deploy-doc.md
<!-- END ai-rules-skills -->
EOF

    upsert_managed_block "$claude_md" "$block_file" "<!-- BEGIN ai-rules-skills -->" "<!-- END ai-rules-skills -->"
    rm -f "$block_file"

    echo -e "${GREEN}  -> $claude_md${NC}"
    echo -e "${GREEN}  -> $rules_out${NC}"
    echo -e "${GREEN}  -> $skills_out${NC}"
    echo -e "${GREEN}  -> $commands_out${NC}"
}

install_cursor() {
    local cursor_home="${CURSOR_HOME:-$HOME/.cursor}"
    local install_root="$cursor_home/ai-rules-skills"
    local rules_out="$install_root/rules"
    local workflows_out="$install_root/workflows"
    local skills_out="$cursor_home/skills-cursor"
    local user_rules_file="$install_root/user-rules.md"
    local readme_file="$install_root/README.md"

    echo -e "${YELLOW}[Cursor] Installing to $cursor_home ...${NC}"

    ensure_dir "$rules_out"
    ensure_dir "$workflows_out"
    ensure_dir "$skills_out"

    for rule in "$RULES_DIR"/*.mdc; do
        cp "$rule" "$rules_out/$(basename "$rule")"
    done

    for workflow in "$WORKFLOWS_DIR"/*.md; do
        render_workflow_file \
            "$workflow" \
            "$workflows_out/$(basename "$workflow")" \
            "$rules_out" \
            "mdc" \
            "$skills_out" \
            "$workflows_out"
    done

    for skill_dir in "$SKILLS_DIR"/*; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        render_skill_file \
            "$skill_dir/SKILL.md" \
            "$skills_out/$skill_name/SKILL.md" \
            "$rules_out" \
            "mdc" \
            "$skills_out" \
            "$workflows_out"
    done

    cat > "$user_rules_file" <<EOF
# Cursor User Rules 建议文本

> 说明：Cursor 官方稳定的全局入口是 User Rules，而文件级 \`.cursor/rules/*.mdc\` 仍然更适合项目内按 \`globs\` 自动激活。
EOF
    read_rule_markdown "$RULES_DIR/00-global.mdc" >> "$user_rules_file"
    cat >> "$user_rules_file" <<EOF

---

## 详细规则源

- Java / Spring 开发：\`$rules_out/01-java-backend.mdc\`
- Java 安全：\`$rules_out/02-java-security.mdc\`
- Java API：\`$rules_out/03-java-api-design.mdc\`
- Go 后端开发：\`$rules_out/04-go-backend.mdc\`
- Go 安全：\`$rules_out/05-go-security.mdc\`
- Go API：\`$rules_out/06-go-api-design.mdc\`
- Rust 后端开发：\`$rules_out/07-rust-backend.mdc\`
- Rust 安全：\`$rules_out/08-rust-security.mdc\`
- Rust HTTP/API：\`$rules_out/09-rust-api-design.mdc\`
- Python 后端开发：\`$rules_out/10-python-backend.mdc\`
- Python 安全：\`$rules_out/11-python-security.mdc\`
- Python HTTP/API：\`$rules_out/12-python-api-design.mdc\`
- Shell 脚本：\`$rules_out/13-shell-scripting.mdc\`
- Shell 安全：\`$rules_out/14-shell-security.mdc\`

## 使用建议

- 将本文件内容粘贴到 Cursor Settings -> Rules -> User Rules
- 若希望保留 \`globs\` 自动激活，请运行同目录下的 \`bootstrap-project.sh\` 或 \`bootstrap-project.ps1\`，把规则同步到具体项目的 \`.cursor/\` 目录
- 全局 Skills 已安装到 \`$skills_out\`
EOF

    cat > "$readme_file" <<EOF
# Cursor Global Install

本目录由 \`tools/install-global.sh\` 自动生成，用于给 Cursor 提供全局规则源与全局 Skills。

## 已安装内容

- 规则源：\`$rules_out\`
- 工作流参考：\`$workflows_out\`
- 全局 Skills：\`$skills_out\`
- User Rules 建议文本：\`$user_rules_file\`

## 注意事项

- Cursor 官方文档中稳定的全局规则入口是 User Rules
- \`.cursor/rules/*.mdc\` 的 \`globs\` 自动激活仍然是项目级能力
- 因此本安装方案采用“全局 Skills + 全局规则源 + 项目 bootstrap”模式
EOF

    write_cursor_bootstrap_scripts "$install_root"

    echo -e "${GREEN}  -> $rules_out${NC}"
    echo -e "${GREEN}  -> $skills_out${NC}"
    echo -e "${GREEN}  -> $install_root/bootstrap-project.sh${NC}"
    echo -e "${GREEN}  -> $user_rules_file${NC}"
}

normalize_platform() {
    case "$1" in
        claude|claude-code|claudecode)
            echo "claude"
            ;;
        codex|cursor|all)
            echo "$1"
            ;;
        *)
            echo ""
            ;;
    esac
}

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-Help" ]; then
    show_help
    exit 0
fi

PLATFORM="$(normalize_platform "$1")"

if [ -z "$PLATFORM" ]; then
    echo -e "${RED}[ERROR] Unknown platform: $1${NC}"
    echo "Valid: codex cursor claude claudecode all"
    exit 1
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  AI Rules Global Installer${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GRAY}  Source:   $SRC_DIR${NC}"
echo -e "${GRAY}  Platform: $PLATFORM${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if [ "$PLATFORM" = "all" ]; then
    PLATFORMS="codex cursor claude"
else
    PLATFORMS="$PLATFORM"
fi

for platform in $PLATFORMS; do
    case "$platform" in
        codex)
            install_codex
            ;;
        cursor)
            install_cursor
            ;;
        claude)
            install_claude
            ;;
    esac
    echo ""
done

echo -e "${GREEN}Done! Installed for: $PLATFORMS${NC}"
echo ""
