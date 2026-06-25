#!/usr/bin/env bash
# ==============================================================================
# uninstall-legacy-codex-skills.sh
# Remove ai-rules-skills entries from the old Codex skills location.
#
# Default mode is dry-run. Pass --apply to delete matching legacy skill folders.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$SRC_DIR/skills"
LEGACY_SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
APPLY=0

show_help() {
    cat <<EOF
Usage:
  ./tools/uninstall-legacy-codex-skills.sh [--apply] [--legacy-dir <path>]

Options:
  --apply              Delete matched legacy skill directories.
  --legacy-dir <path>  Override legacy skills directory. Default: \$CODEX_HOME/skills or ~/.codex/skills.
  -h, --help           Show this help.

Default behavior is dry-run.
EOF
}

log() {
    printf '%s\n' "$*"
}

warn() {
    printf 'WARN: %s\n' "$*" >&2
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

read_skill_name() {
    local skill_file="$1"

    awk -F ':' '
        $1 == "name" {
            value = $0
            sub(/^name:[[:space:]]*/, "", value)
            sub(/\r$/, "", value)
            print value
            exit
        }
    ' "$skill_file"
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --apply)
                APPLY=1
                shift
                ;;
            --legacy-dir)
                [ "$#" -ge 2 ] || die "--legacy-dir requires a path"
                LEGACY_SKILLS_DIR="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                die "unknown argument: $1"
                ;;
        esac
    done
}

normalize_legacy_dir() {
    while [ "$LEGACY_SKILLS_DIR" != "/" ] && [ "${LEGACY_SKILLS_DIR%/}" != "$LEGACY_SKILLS_DIR" ]; do
        LEGACY_SKILLS_DIR="${LEGACY_SKILLS_DIR%/}"
    done
}

collect_targets() {
    local skill_dir skill_name target target_skill_name

    for skill_dir in "$SKILLS_DIR"/*; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        target="$LEGACY_SKILLS_DIR/$skill_name"

        [ -e "$target" ] || continue

        if [ -L "$target" ]; then
            warn "skip symlink: $target"
            continue
        fi

        if [ ! -f "$target/SKILL.md" ]; then
            warn "skip because SKILL.md is missing: $target"
            continue
        fi

        target_skill_name="$(read_skill_name "$target/SKILL.md")"
        if [ "$target_skill_name" != "$skill_name" ]; then
            warn "skip because name mismatch: $target (name: $target_skill_name)"
            continue
        fi

        printf '%s\n' "$target"
    done
}

remove_targets() {
    local target

    while IFS= read -r target; do
        [ -n "$target" ] || continue
        case "$target" in
            "$LEGACY_SKILLS_DIR"/*) ;;
            *) die "refuse to delete path outside legacy skills dir: $target" ;;
        esac

        log "Removing: $target"
        rm -rf -- "$target"
    done
}

main() {
    local targets

    parse_args "$@"
    normalize_legacy_dir

    [ -d "$SKILLS_DIR" ] || die "source skills directory not found: $SKILLS_DIR"

    if [ -L "$LEGACY_SKILLS_DIR" ]; then
        die "refuse to use symlink legacy skills directory: $LEGACY_SKILLS_DIR"
    fi

    if [ ! -d "$LEGACY_SKILLS_DIR" ]; then
        log "Legacy Codex skills directory does not exist: $LEGACY_SKILLS_DIR"
        exit 0
    fi

    targets="$(collect_targets)"
    if [ -z "$targets" ]; then
        log "No ai-rules-skills entries found in: $LEGACY_SKILLS_DIR"
        exit 0
    fi

    if [ "$APPLY" -eq 0 ]; then
        log "Dry-run. Matched legacy skill directories:"
        printf '%s\n' "$targets"
        log ""
        log "Run with --apply to delete these directories."
        exit 0
    fi

    printf '%s\n' "$targets" | remove_targets
    log "Done."
}

main "$@"
