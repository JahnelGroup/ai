#!/usr/bin/env bash

# =============================================================================
# install.sh - Cross-platform installer for shared Claude Code skills
# Symlinks each skill from repo/skills/ to ~/.claude/skills/<skill-name>/
# Non-destructive: skips conflicts, preserves local skills
# =============================================================================

set -euo pipefail

# ====================
# Configuration
# ====================
REPO_DIR="$(pwd)"
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

echo ""
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