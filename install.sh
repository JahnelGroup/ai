#!/usr/bin/env bash

# =============================================================================
# install.sh - Cross-platform installer for shared AI agent configs
# Symlinks each skill from repo/skills/ to ~/.claude/skills/<skill-name>/
# Bootstraps ~/.config/work-log/ from example files
# Non-destructive: skips conflicts, preserves existing files
# =============================================================================

set -euo pipefail

# ====================
# Configuration
# ====================
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_SKILLS_DIR="$REPO_DIR/skills"
TARGET_DIR="$HOME/.claude/skills"

if [ ! -d "$SHARED_SKILLS_DIR" ]; then
  echo "Error: No 'skills/' directory found in repo root."
  echo "Expected structure: repo/skills/<skill-name>/SKILL.md (and other files)"
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "============================================================="
echo "Shared Claude Skills Installer (cross-platform)"
echo "Repo:          $REPO_DIR"
echo "Shared skills: $SHARED_SKILLS_DIR"
echo "Target dir:    $TARGET_DIR"
echo "============================================================="
echo "This will symlink individual skills to top-level $TARGET_DIR/"
echo "(Claude Code requires top-level skill folders; nested ones are ignored)"
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
# Rules: prompt to install into Cursor and/or Claude Code
# ====================
RULES_SRC="$REPO_DIR/rules"

if [ -d "$RULES_SRC" ]; then
  rule_files=("$RULES_SRC"/*.md)
  if [ ${#rule_files[@]} -gt 0 ]; then
    echo "============================================================="
    echo "This repo includes always-on agent rules:"
    for rf in "${rule_files[@]}"; do
      echo "  • $(basename "$rf" .md)"
    done
    echo ""

    # --- Cursor ---
    echo -n "Install rules into ~/.cursor/rules/ (for Cursor)? [y/N] "
    read -r cursor_answer
    if [[ "$cursor_answer" =~ ^[Yy]$ ]]; then
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
      echo "  Skipped Cursor rules."
    fi
    echo ""

    # --- Claude Code ---
    echo -n "Append rules to ~/.claude/CLAUDE.md (for Claude Code)? [y/N] "
    read -r claude_answer
    if [[ "$claude_answer" =~ ^[Yy]$ ]]; then
      claude_md="$HOME/.claude/CLAUDE.md"
      mkdir -p "$HOME/.claude"
      for rf in "${rule_files[@]}"; do
        name=$(basename "$rf" .md)
        # Strip YAML frontmatter before appending
        content=$(sed '/^---$/,/^---$/d' "$rf")
        if [ -f "$claude_md" ] && grep -qF "$(head -1 <<< "$content")" "$claude_md" 2>/dev/null; then
          echo "  $name ... [skip] already present in CLAUDE.md"
        else
          {
            [ -s "$claude_md" ] && echo ""
            echo "$content"
          } >> "$claude_md"
          echo "  $name ... [appended]"
        fi
      done
    else
      echo "  Skipped Claude Code rules."
    fi
    echo ""
  fi
fi

echo "============================================================="
echo "Installation/update complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code session (or reload skills if supported)"
echo "  2. Test: Ask Claude '/skills' or 'list available skills'"
echo "     → You should see your shared skills listed"
echo ""
echo "To update later:"
echo "  cd $REPO_DIR && git pull && ./install.sh"
echo ""
echo "Notes:"
echo "  • Existing local skills in $TARGET_DIR are untouched"
echo "  • If name conflicts occur, rename in repo or remove local one"
echo "  • Windows: First run may need elevated Git Bash/PowerShell"
echo "  • Recursive/nested discovery is NOT supported yet (open Anthropic issues #18192, #20755, etc.)"
echo "============================================================="