#!/usr/bin/env bash

# =============================================================================
# install.sh - Cross-platform installer for shared AI agent configs
# Usage: ./install.sh <cursor|claude>
# Symlinks each skill from repo/skills/ to the appropriate target directory
# Bootstraps ~/.config/work-log/ from example files
# Non-destructive: skips conflicts, preserves existing files
# =============================================================================

set -euo pipefail

# ====================
# Parameter validation
# ====================
PLATFORM="${1:-}"

if [[ -z "$PLATFORM" ]]; then
  echo "Error: You must specify a platform."
  echo "Usage: ./install.sh <cursor|claude>"
  exit 1
fi

case "$PLATFORM" in
  cursor)
    TARGET_DIR="$HOME/.cursor/skills"
    DISPLAY_NAME="Cursor"
    ;;
  claude)
    TARGET_DIR="$HOME/.claude/skills"
    DISPLAY_NAME="Claude Code"
    ;;
  *)
    echo "Error: Invalid platform '$PLATFORM'."
    echo "Usage: ./install.sh <cursor|claude>"
    exit 1
    ;;
esac

# ====================
# Configuration
# ====================
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_SKILLS_DIR="$REPO_DIR/skills"

if [ ! -d "$SHARED_SKILLS_DIR" ]; then
  echo "Error: No 'skills/' directory found in repo root."
  echo "Expected structure: repo/skills/<skill-name>/SKILL.md (and other files)"
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "============================================================="
echo "Shared $DISPLAY_NAME Skills Installer (cross-platform)"
echo "Repo:          $REPO_DIR"
echo "Shared skills: $SHARED_SKILLS_DIR"
echo "Target dir:    $TARGET_DIR"
echo "============================================================="
echo "This will symlink individual skills to top-level $TARGET_DIR/"
echo "($DISPLAY_NAME requires top-level skill folders; nested ones are ignored)"
echo ""

# ====================
# OS Detection Helpers
# ====================
is_windows() {
  [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win"* || "$(uname -s)" =~ [Mm][Ii][Nn][GgWw] ]]
}

to_win_path() {
  local path="$1"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$path"
  else
    # Naive fallback conversion (assumes common paths)
    echo "$path" | sed 's|^/c/|C:\\|; s|^/d/|D:\\|; s|/|\\|g; s|^/|C:\\|'
  fi
}

# ====================
# Main: Symlink each skill
# ====================
echo "Scanning shared skills and creating symlinks (only if missing)..."

shopt -s nullglob  # Don't loop if no dirs
for skill_path in "$SHARED_SKILLS_DIR"/*; do
  if [ -d "$skill_path" ]; then
    skill_name=$(basename "$skill_path")
    target="$TARGET_DIR/$skill_name"

    echo -n "  $skill_name ... "

    if [ -e "$target" ]; then
      if [ -L "$target" ]; then
        current=$(readlink "$target" 2>/dev/null || realpath "$target" 2>/dev/null)
        if [[ "$current" == "$skill_path" || "$current" == "$skill_path/" ]]; then
          echo "[skip] already symlinked to this repo"
          continue
        else
          echo "[warn] symlink exists but points elsewhere → skipping"
          continue
        fi
      else
        echo "[warn] real directory/file exists → skipping (manual conflict)"
        continue
      fi
    fi

    # Create symlink
    if is_windows; then
      WIN_TARGET=$(to_win_path "$skill_path")
      WIN_LINK=$(to_win_path "$target")
      if cmd //c mklink /D "$WIN_LINK" "$WIN_TARGET" > /dev/null 2>&1; then
        echo "[link] created (Windows junction)"
      else
        echo "[fail] mklink failed — run as Administrator or enable Developer Mode (Settings → Update & Security → For developers)"
      fi
    else
      # Linux/macOS
      if ln -s "$skill_path" "$target"; then
        echo "[link] created"
      else
        echo "[fail] ln -s failed"
      fi
    fi
  fi
done

# ====================
# Work Log: bootstrap ~/.config/work-log/
# ====================
WORK_LOG_SRC="$REPO_DIR/work-log"
WORK_LOG_DIR="$HOME/.config/work-log"

if [ -d "$WORK_LOG_SRC" ]; then
  echo "Setting up work log at $WORK_LOG_DIR ..."
  mkdir -p "$WORK_LOG_DIR"

  for example_file in "$WORK_LOG_SRC"/*.example; do
    [ -f "$example_file" ] || continue
    base=$(basename "$example_file" .example)
    target="$WORK_LOG_DIR/$base"

    echo -n "  $base ... "
    if [ -e "$target" ]; then
      echo "[skip] already exists"
    else
      cp "$example_file" "$target"
      echo "[created]"
    fi
  done
  echo ""
fi

# ====================
# Rules: install for the selected platform
# ====================
RULES_SRC="$REPO_DIR/rules"

if [ -d "$RULES_SRC" ]; then
  rule_files=("$RULES_SRC"/*.md)
  if [ ${#rule_files[@]} -gt 0 ]; then
    echo "============================================================="
    echo "Installing always-on agent rules for $DISPLAY_NAME:"
    for rf in "${rule_files[@]}"; do
      echo "  • $(basename "$rf" .md)"
    done
    echo ""

    if [[ "$PLATFORM" == "cursor" ]]; then
      echo -n "Install rules into ~/.cursor/rules/? [y/N] "
      read -r answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        mkdir -p "$HOME/.cursor/rules"
        for rf in "${rule_files[@]}"; do
          name=$(basename "$rf" .md)
          target="$HOME/.cursor/rules/${name}.mdc"
          echo -n "  ${name}.mdc ... "
          if [ -e "$target" ]; then
            echo "[skip] already exists"
          else
            cp "$rf" "$target"
            echo "[created]"
          fi
        done
      else
        echo "  Skipped rules."
      fi
    else
      echo -n "Append rules to ~/.claude/CLAUDE.md? [y/N] "
      read -r answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        claude_md="$HOME/.claude/CLAUDE.md"
        mkdir -p "$HOME/.claude"
        for rf in "${rule_files[@]}"; do
          name=$(basename "$rf" .md)
          start_marker="<!-- jg-ai-rule: $name -->"
          end_marker="<!-- /jg-ai-rule: $name -->"
          content=$(awk 'NR==1 && /^---$/{in_fm=1; next} in_fm && /^---$/{in_fm=0; next} !in_fm' "$rf")

          echo -n "  $name ... "
          if [ -f "$claude_md" ] && grep -qF "$start_marker" "$claude_md" 2>/dev/null; then
            # Replace existing block between markers
            sed -i '' "/$start_marker/,/$end_marker/c\\
$start_marker\\
$content\\
$end_marker" "$claude_md"
            echo "[updated]"
          else
            {
              [ -s "$claude_md" ] && echo ""
              echo "$start_marker"
              echo "$content"
              echo "$end_marker"
            } >> "$claude_md"
            echo "[appended]"
          fi
        done
      else
        echo "  Skipped rules."
      fi
    fi
    echo ""
  fi
fi

echo "============================================================="
echo "Installation complete for $DISPLAY_NAME!"
echo ""
echo "Next steps:"
echo "  1. Restart your $DISPLAY_NAME session (or reload skills if supported)"
echo "  2. Verify skills are available in $DISPLAY_NAME"
echo ""
echo "To update later:"
echo "  cd $REPO_DIR && ./update.sh $PLATFORM"
echo ""
echo "Notes:"
echo "  • Existing local skills in $TARGET_DIR are untouched"
echo "  • If name conflicts occur, rename in repo or remove local one"
echo "  • Windows: First run may need elevated Git Bash/PowerShell"
echo "============================================================="
