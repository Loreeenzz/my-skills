#!/usr/bin/env bash
set -e

# ==============================================================================
# my-skills installer / sync script
# Symlinks skills to your global agent or local project directory
# Supported targets:
#   - antigravity / gemini / opencode: ~/.gemini/config/skills or <project>/.agents/skills
#   - claude: ~/.claude/skills
#   - cursor: ~/.cursor/rules
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

show_help() {
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --global            Install globally to ~/.gemini/config/skills (default)"
  echo "  --project <DIR>     Install into a specific project (e.g., <DIR>/.agents/skills)"
  echo "  --claude            Install globally to Claude Code (~/.claude/skills)"
  echo "  --cursor            Install globally to Cursor (~/.cursor/rules)"
  echo "  --help              Show this help message"
  echo ""
}

TARGET_DIR=""
PROJECT_ROOT=""

case "$1" in
  --project)
    if [ -z "$2" ]; then
      echo "Error: --project requires a directory argument."
      exit 1
    fi
    PROJECT_ROOT="$2"
    TARGET_DIR="$2/.agents/skills"
    ;;
  --claude)
    TARGET_DIR="$HOME/.claude/skills"
    ;;
  --cursor)
    TARGET_DIR="$HOME/.cursor/rules"
    ;;
  --help)
    show_help
    exit 0
    ;;
  --global|"")
    TARGET_DIR="$HOME/.gemini/config/skills"
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
esac

echo "Target directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

for skill in "$SKILLS_DIR"/*; do
  if [ -d "$skill" ]; then
    skill_name="$(basename "$skill")"
    dest="$TARGET_DIR/$skill_name"
    ln -sfn "$skill" "$dest"
    echo "  [✓] Linked skill: $skill_name -> $dest"
  fi
done

# If installing into prospect, maintain backward compatibility alias for verify-ai-setup
if [ -n "$PROJECT_ROOT" ] && [[ "$PROJECT_ROOT" == *"prospect"* ]]; then
  if [ -d "$TARGET_DIR/git-commit-message" ] && [ ! -e "$TARGET_DIR/prospect-commit-message" ]; then
    ln -sfn git-commit-message "$TARGET_DIR/prospect-commit-message"
    echo "  [✓] Linked backward-compat alias: prospect-commit-message -> git-commit-message"
  fi
fi

echo ""
echo "Installation complete!"
