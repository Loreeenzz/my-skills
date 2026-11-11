#!/usr/bin/env bash
set -e

# ==============================================================================
# my-skills installer, status checker & UI manifest syncer
# Symlinks skills to your global agent or local project directory
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
SYNC_SCRIPT="$SCRIPT_DIR/scripts/sync-ui.py"

show_help() {
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --all               Install to Antigravity + OpenCode globally and sync UI manifest"
  echo "  --global            Install globally to Antigravity (~/.gemini/config/skills) [default]"
  echo "  --opencode          Install globally to OpenCode (~/.config/opencode/skills)"
  echo "  --claude            Install globally to Claude Code (~/.claude/skills)"
  echo "  --cursor            Install globally to Cursor (~/.cursor/rules)"
  echo "  --project <DIR>     Install into a specific project (<DIR>/.agents/skills)"
  echo "  --sync-ui           Regenerate skills-manifest.json and update index.html"
  echo "  --status            Show active symlinks across all agent directories"
  echo "  --help              Show this help message"
  echo ""
}

link_skills_to_dir() {
  local target_dir="$1"
  local label="$2"
  echo "Target [$label]: $target_dir"
  mkdir -p "$target_dir"

  for skill in "$SKILLS_DIR"/*; do
    if [ -d "$skill" ]; then
      local skill_name
      skill_name="$(basename "$skill")"
      local dest="$target_dir/$skill_name"
      ln -sfn "$skill" "$dest"
      echo "  [✓] Linked skill: $skill_name -> $dest"
    fi
  done
}

sync_ui() {
  if [ -f "$SYNC_SCRIPT" ] && command -v python3 >/dev/null 2>&1; then
    echo "Syncing UI manifest..."
    python3 "$SYNC_SCRIPT"
  fi
}

show_status() {
  echo "=== Active Skill Symlinks Status ==="
  for dir in "$HOME/.gemini/config/skills" "$HOME/.config/opencode/skills" "$HOME/.claude/skills" "$HOME/.cursor/rules"; do
    echo ""
    echo "Directory: $dir"
    if [ -d "$dir" ]; then
      ls -la "$dir" | grep -E "\->" || echo "  (no symlinks)"
    else
      echo "  (not created)"
    fi
  done
}

case "$1" in
  --all)
    link_skills_to_dir "$HOME/.gemini/config/skills" "Antigravity Global"
    echo ""
    link_skills_to_dir "$HOME/.config/opencode/skills" "OpenCode Global"
    ln -sfn git-commit-message "$HOME/.config/opencode/skills/prospect-commit-message"
    echo "  [✓] Linked alias: prospect-commit-message -> git-commit-message"
    echo ""
    sync_ui
    ;;
  --opencode)
    link_skills_to_dir "$HOME/.config/opencode/skills" "OpenCode Global"
    ln -sfn git-commit-message "$HOME/.config/opencode/skills/prospect-commit-message"
    sync_ui
    ;;
  --claude)
    link_skills_to_dir "$HOME/.claude/skills" "Claude Code Global"
    sync_ui
    ;;
  --cursor)
    link_skills_to_dir "$HOME/.cursor/rules" "Cursor Global"
    sync_ui
    ;;
  --project)
    if [ -z "$2" ]; then
      echo "Error: --project requires a directory argument."
      exit 1
    fi
    PROJECT_ROOT="$2"
    TARGET_DIR="$PROJECT_ROOT/.agents/skills"
    link_skills_to_dir "$TARGET_DIR" "Project Workspace"
    if [[ "$PROJECT_ROOT" == *"prospect"* ]]; then
      if [ -d "$TARGET_DIR/git-commit-message" ]; then
        ln -sfn git-commit-message "$TARGET_DIR/prospect-commit-message"
        echo "  [✓] Linked backward-compat alias: prospect-commit-message -> git-commit-message"
      fi
      if [ -d "$PROJECT_ROOT/.opencode" ]; then
        ln -sfn ../.agents/skills "$PROJECT_ROOT/.opencode/skills"
        echo "  [✓] Linked OpenCode native path: .opencode/skills -> .agents/skills"
      fi
    fi
    sync_ui
    ;;
  --sync-ui)
    sync_ui
    ;;
  --status)
    show_status
    exit 0
    ;;
  --help)
    show_help
    exit 0
    ;;
  --global|"")
    link_skills_to_dir "$HOME/.gemini/config/skills" "Antigravity Global"
    sync_ui
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
esac

echo ""
echo "Done!"
