# my-skills

A centralized, version-controlled collection of custom AI agent skills and interactive web showcase compatible with **Google Antigravity**, **OpenCode**, **Claude Code**, and **Cursor**.

🌐 **Live Web Showcase:** [https://loreeenzz.github.io/my-skills/](https://loreeenzz.github.io/my-skills/)

## Repository Structure

```text
my-skills/
├── index.html                  # Interactive Dark-Mode Web Showcase (GitHub Pages)
├── skills-manifest.json        # Auto-generated full skill & reference manifest
├── install.sh                  # Multi-agent symlink & UI sync CLI
├── scripts/
│   └── sync-ui.py              # Auto-compiles skills/* into skills-manifest.json & index.html
├── skills/
│   ├── git-commit-message/
│   │   └── SKILL.md
│   ├── prospect-standards-implement/
│   │   └── SKILL.md
│   ├── prospect-standards-migrate/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── coverage.md
│   ├── prospect-standards-review/
│   │   └── SKILL.md
│   └── session-handoff/
│       └── SKILL.md
└── README.md
```

## Available Skills

- **`session-handoff`**: Manages session continuity across chats. Generates a structured `HANDOFF.md` before starting a fresh chat, or resumes work instantly without context rot.
- **`git-commit-message`**: Evaluates git changes and generates clean, concise Conventional Commit messages and bullet summaries (advisory only).
- **`prospect-standards-implement`**: Implements features and bug fixes against Prospect Analyzer architecture and coding standards (Angular 22 OnPush/Signals, FastAPI, BEM/Tailwind).
- **`prospect-standards-migrate`**: Fully migrates existing files to complete repository coding standards compliance (includes `references/coverage.md`).
- **`prospect-standards-review`**: Performs read-only code review verifying implementations against standards, accessibility, contracts, and tests.

## Installation & Syncing (`./install.sh`)

```bash
# Install to ALL global agents (Antigravity + OpenCode) & sync UI manifest
./install.sh --all

# Install only to Antigravity / Gemini (~/.gemini/config/skills)
./install.sh --global

# Install only to OpenCode (~/.config/opencode/skills)
./install.sh --opencode

# Install into a specific project workspace (<DIR>/.agents/skills)
./install.sh --project /path/to/your/project

# Check active symlinks across your machine
./install.sh --status

# Regenerate skills-manifest.json & update index.html after adding/editing skills
./install.sh --sync-ui
```
