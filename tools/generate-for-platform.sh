#!/usr/bin/env bash
# ==============================================================================
# generate-for-platform.sh
# Generate platform-specific AI rules from the ai-rules-skills repository.
#
# Supports: cursor / copilot / claude / codex / antigravity / gemini /
#           windsurf / aider / lingma / all
#
# Usage:
#   ./tools/generate-for-platform.sh <platform> <target-dir>
#   ./tools/generate-for-platform.sh all /path/to/my-project
# ==============================================================================

set -euo pipefail

# === Colors ===
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; GRAY='\033[0;37m'; NC='\033[0m'

# === Constants ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RULES_DIR="$SRC_DIR/rules"
SKILLS_DIR="$SRC_DIR/skills"
WORKFLOWS_DIR="$SRC_DIR/workflows"
AGENTS_MD="$SRC_DIR/AGENTS.md"

# === Help ===
show_help() {
    cat <<EOF

  ${CYAN}AI Rules Cross-Platform Generator${NC}
  ==================================

  Usage:
    ./generate-for-platform.sh <platform> <target-dir>

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
    all          Generate for all platforms

  Example:
    ./generate-for-platform.sh copilot /path/to/my-project
    ./generate-for-platform.sh all /path/to/my-project

EOF
}

# === Helpers ===
strip_frontmatter() {
    # Remove YAML frontmatter (---\n...\n---\n) from stdin
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

read_rule_content() {
    cat "$1" | strip_frontmatter
}

read_agents_md_generic() {
    cat "$AGENTS_MD" \
        | sed 's|\.cursor/rules/|.agents/rules/|g' \
        | sed 's|\.cursor/skills/|.agents/skills/|g' \
        | sed 's|\.mdc|.md|g'
}

read_agents_md_codex() {
    cat "$AGENTS_MD" \
        | sed 's|\.cursor/rules/|.codex/rules/|g' \
        | sed 's|\.cursor/skills/|.codex/skills/|g' \
        | sed 's|\.mdc|.md|g'
}

ensure_dir() {
    mkdir -p "$1"
}

# === Generators ===

generate_cursor() {
    echo -e "${YELLOW}[Cursor] Generating .cursor/rules/*.mdc + skills + workflows ...${NC}"

    local out_rules="$TARGET_DIR/.cursor/rules"
    ensure_dir "$out_rules"

    for rule in "$RULES_DIR"/*.mdc; do
        cp "$rule" "$out_rules/$(basename "$rule")"
    done

    # Copy skills
    if [ -d "$SKILLS_DIR" ]; then
        cp -r "$SKILLS_DIR" "$TARGET_DIR/.cursor/skills"
    fi

    # Copy workflows
    if [ -d "$WORKFLOWS_DIR" ]; then
        ensure_dir "$TARGET_DIR/.cursor/workflows"
        cp "$WORKFLOWS_DIR"/* "$TARGET_DIR/.cursor/workflows/"
    fi

    local count=$(ls -1 "$out_rules" | wc -l | tr -d ' ')
    echo -e "${GREEN}  -> $out_rules ($count files)${NC}"
}

generate_copilot() {
    echo -e "${YELLOW}[Copilot] Generating .github/copilot-instructions.md ...${NC}"

    local out_dir="$TARGET_DIR/.github"
    ensure_dir "$out_dir"
    local out_file="$out_dir/copilot-instructions.md"

    echo "<!-- Auto-generated from ai-rules-skills. DO NOT EDIT MANUALLY. -->" > "$out_file"
    echo "" >> "$out_file"
    echo "# Project AI Coding Standards" >> "$out_file"
    echo "" >> "$out_file"

    for rule in "$RULES_DIR"/*.mdc; do
        read_rule_content "$rule" >> "$out_file"
        echo "" >> "$out_file"
        echo "---" >> "$out_file"
        echo "" >> "$out_file"
    done

    local size=$(du -k "$out_file" | cut -f1)
    echo -e "${GREEN}  -> $out_file (${size}KB)${NC}"
}

generate_claude() {
    echo -e "${YELLOW}[Claude Code] Generating CLAUDE.md ...${NC}"

    local out_file="$TARGET_DIR/CLAUDE.md"

    cat > "$out_file" <<'HEADER'
<!-- Auto-generated from ai-rules-skills. DO NOT EDIT MANUALLY. -->

# Project AI Guidelines

> Detailed specs are in `.agents/rules/`. Please read them when encountering relevant scenarios.

HEADER

    # Embed global rules
    read_rule_content "$RULES_DIR/00-global.mdc" >> "$out_file"

    cat >> "$out_file" <<'REFS'

---

## Language-Specific Standards (Read As Needed)

| Scenario | File to Read |
|----------|-------------|
| Edit Java Code | `.agents/rules/01-java-backend.md` |
| Java Security | `.agents/rules/02-java-security.md` |
| Java Controller/API | `.agents/rules/03-java-api-design.md` |
| Edit Go Code | `.agents/rules/04-go-backend.md` |
| Go Security | `.agents/rules/05-go-security.md` |
| Go Handler/API | `.agents/rules/06-go-api-design.md` |
| Edit Rust Code | `.agents/rules/07-rust-backend.md` |
| Rust Security | `.agents/rules/08-rust-security.md` |
| Rust HTTP/API | `.agents/rules/09-rust-api-design.md` |
| Edit Python Code | `.agents/rules/10-python-backend.md` |
| Python Security | `.agents/rules/11-python-security.md` |
| Python HTTP/API | `.agents/rules/12-python-api-design.md` |
| Edit Shell Script | `.agents/rules/13-shell-scripting.md` |
| Shell Security | `.agents/rules/14-shell-security.md` |

## SOP Workflows (Read As Needed)

| Language | Skill Family |
|----------|-------------|
| Java | `.agents/skills/*-java/SKILL.md` |
| Go | `.agents/skills/*-go/SKILL.md` |
| Rust | `.agents/skills/*-rust/SKILL.md` |
| Python | `.agents/skills/*-python/SKILL.md` |
| Shell | `.agents/skills/*-shell/SKILL.md` |
REFS

    local size=$(du -k "$out_file" | cut -f1)
    echo -e "${GREEN}  -> $out_file (${size}KB)${NC}"
}

generate_codex() {
    echo -e "${YELLOW}[Codex] Generating AGENTS.md + .codex/rules/ + .codex/skills/ ...${NC}"

    local out_file="$TARGET_DIR/AGENTS.md"
    read_agents_md_codex > "$out_file"

    local out_rules="$TARGET_DIR/.codex/rules"
    ensure_dir "$out_rules"

    for rule in "$RULES_DIR"/*.mdc; do
        local base=$(basename "$rule" .mdc)
        read_rule_content "$rule" > "$out_rules/${base}.md"
    done

    if [ -d "$SKILLS_DIR" ]; then
        cp -r "$SKILLS_DIR" "$TARGET_DIR/.codex/skills"
    fi

    local count=$(ls -1 "$out_rules" | wc -l | tr -d ' ')
    echo -e "${GREEN}  -> $out_file + $out_rules ($count rules) + .codex/skills${NC}"
}

generate_antigravity() {
    echo -e "${YELLOW}[Antigravity] Generating AGENTS.md + .agents/ ...${NC}"

    # AGENTS.md
    local out_file="$TARGET_DIR/AGENTS.md"
    read_agents_md_generic > "$out_file"

    # Rules (strip cursor frontmatter)
    local out_rules="$TARGET_DIR/.agents/rules"
    ensure_dir "$out_rules"
    for rule in "$RULES_DIR"/*.mdc; do
        local base=$(basename "$rule" .mdc)
        read_rule_content "$rule" > "$out_rules/${base}.md"
    done

    # Skills (keep YAML frontmatter, Antigravity supports it)
    if [ -d "$SKILLS_DIR" ]; then
        cp -r "$SKILLS_DIR" "$TARGET_DIR/.agents/skills"
    fi

    # Workflows
    if [ -d "$WORKFLOWS_DIR" ]; then
        ensure_dir "$TARGET_DIR/.agents/workflows"
        cp "$WORKFLOWS_DIR"/* "$TARGET_DIR/.agents/workflows/"
    fi

    local rule_count=$(ls -1 "$out_rules" | wc -l | tr -d ' ')
    local skill_count=0
    if [ -d "$TARGET_DIR/.agents/skills" ]; then
        skill_count=$(ls -1d "$TARGET_DIR/.agents/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo -e "${GREEN}  -> AGENTS.md + $rule_count rules + $skill_count skills${NC}"
}

generate_gemini() {
    echo -e "${YELLOW}[Gemini CLI] Generating GEMINI.md ...${NC}"

    local out_file="$TARGET_DIR/GEMINI.md"

    echo "<!-- Auto-generated from ai-rules-skills. DO NOT EDIT MANUALLY. -->" > "$out_file"
    echo "" >> "$out_file"

    read_rule_content "$RULES_DIR/00-global.mdc" >> "$out_file"

    cat >> "$out_file" <<'SEC'

---

## Security Baselines Quick Reference

- NO HARDCODED SECRETS (passwords/keys/tokens). Use environment variables.
- SQL MUST BE PARAMETERIZED. String concatenation is forbidden.
- LOGS MUST NOT CONTAIN private keys, passwords, PINs, or full JWT tokens.
- AMOUNTS MUST BE BigDecimal (Java) / shopspring/decimal (Go). NEVER use float/double.
- JWT MUST USE RS256/ES256. HS256 is forbidden.
- TLS 1.2+ IS MANDATORY. Trust-all-certificates is forbidden.
- JSON MUST USE Jackson (Java) / encoding/json (Go). Fastjson is forbidden.

> See `.agents/rules/02-java-security.md` and `.agents/rules/05-go-security.md` for full specs.
SEC

    local size=$(du -k "$out_file" | cut -f1)
    echo -e "${GREEN}  -> $out_file (${size}KB)${NC}"
}

generate_windsurf() {
    echo -e "${YELLOW}[Windsurf] Generating .windsurfrules ...${NC}"

    local out_file="$TARGET_DIR/.windsurfrules"

    read_rule_content "$RULES_DIR/00-global.mdc" > "$out_file"

    cat >> "$out_file" <<'SEC'

---

# Security Baselines (Java & Go)

- No hardcoded secrets (pwd/keys/tokens)
- Parameterized SQL only (No concat)
- Sanitize logs (No sensitive info)
- Amounts must be BigDecimal/decimal
- JWT must be RS256/ES256
- Exception responses must not leak stack/SQL
- No fastjson
- TLS 1.2+ mandatory
SEC

    local char_count=$(wc -c < "$out_file" | tr -d ' ')
    if [ "$char_count" -gt 6000 ]; then
        echo -e "${YELLOW}  [WARN] Content ${char_count} chars > 6000, may be truncated by Windsurf${NC}"
    fi
    echo -e "${GREEN}  -> $out_file (${char_count} chars)${NC}"
}

generate_aider() {
    echo -e "${YELLOW}[Aider] Generating CONVENTIONS.md + .aider.conf.yml ...${NC}"

    local out_conv="$TARGET_DIR/CONVENTIONS.md"

    read_rule_content "$RULES_DIR/00-global.mdc" > "$out_conv"

    # Append security rules
    for sec_file in "02-java-security.mdc" "05-go-security.mdc"; do
        local path="$RULES_DIR/$sec_file"
        if [ -f "$path" ]; then
            echo "" >> "$out_conv"
            echo "---" >> "$out_conv"
            echo "" >> "$out_conv"
            read_rule_content "$path" >> "$out_conv"
        fi
    done

    # .aider.conf.yml
    local out_conf="$TARGET_DIR/.aider.conf.yml"
    cat > "$out_conf" <<'CONF'
# Auto-generated. Configures Aider to load project conventions.
read:
  - CONVENTIONS.md
CONF

    echo -e "${GREEN}  -> $out_conv + $out_conf${NC}"
}

generate_lingma() {
    echo -e "${YELLOW}[Tongyi Lingma] Generating .lingma/rules/ ...${NC}"

    local out_dir="$TARGET_DIR/.lingma/rules"
    ensure_dir "$out_dir"

    local count=0
    for rule in "$RULES_DIR"/*.mdc; do
        local base=$(basename "$rule" .mdc)
        local content
        content=$(read_rule_content "$rule")
        local char_count=${#content}

        if [ "$char_count" -gt 10000 ]; then
            echo -e "${YELLOW}  [WARN] ${base}.md (${char_count} chars) exceeds 10000 limit, writing as-is${NC}"
        fi

        echo "$content" > "$out_dir/${base}.md"
        count=$((count + 1))
    done

    echo -e "${GREEN}  -> $out_dir ($count files)${NC}"
}

# === Main ===
if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-Help" ]; then
    show_help
    exit 0
fi

PLATFORM="$1"
TARGET_DIR="${2%/}"  # Remove trailing slash

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}[ERROR] Target directory not found: $TARGET_DIR${NC}"
    exit 1
fi

if [ ! -d "$RULES_DIR" ]; then
    echo -e "${RED}[ERROR] Rules directory not found: $RULES_DIR${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  AI Rules Cross-Platform Generator${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GRAY}  Source:   $SRC_DIR${NC}"
echo -e "${GRAY}  Target:   $TARGET_DIR${NC}"
echo -e "${GRAY}  Platform: $PLATFORM${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if [ "$PLATFORM" = "all" ]; then
    PLATFORMS="cursor copilot claude codex antigravity gemini windsurf aider lingma"
else
    PLATFORMS="$PLATFORM"
fi

for p in $PLATFORMS; do
    case "$p" in
        cursor)       generate_cursor ;;
        copilot)      generate_copilot ;;
        claude)       generate_claude ;;
        codex)        generate_codex ;;
        antigravity)  generate_antigravity ;;
        gemini)       generate_gemini ;;
        windsurf)     generate_windsurf ;;
        aider)        generate_aider ;;
        lingma)       generate_lingma ;;
        *)
            echo -e "${RED}[ERROR] Unknown platform: $p${NC}"
            echo "Valid: cursor copilot claude codex antigravity gemini windsurf aider lingma all"
            exit 1
            ;;
    esac
    echo ""
done

echo -e "${GREEN}Done! Generated for: $PLATFORMS${NC}"
echo ""
