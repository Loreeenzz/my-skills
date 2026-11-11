# my-skills

A centralized, version-controlled collection of custom AI agent skills compatible with **Google Antigravity**, **Claude Code**, **OpenCode**, and **Cursor**.

## Repository Structure

```text
my-skills/
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
├── install.sh
└── README.md
```

## Available Skills

- **`session-handoff`**: Manages session continuity across chats. Generates a structured `HANDOFF.md` before starting a fresh chat, or resumes work instantly without context rot.
- **`git-commit-message`**: Evaluates git changes and generates clean, concise Conventional Commit messages and bullet summaries (advisory only).
- **`prospect-standards-implement`**: Implements features and bug fixes against Prospect Analyzer architecture and coding standards (Angular 22 OnPush/Signals, FastAPI, BEM/Tailwind).
- **`prospect-standards-migrate`**: Fully migrates existing files to complete repository coding standards compliance.
- **`prospect-standards-review`**: Performs read-only code review verifying implementations against standards, accessibility, contracts, and tests.

## Installation & Syncing

### 1. Global Installation (Antigravity / Gemini)
Symlink all skills to your user configuration (`~/.gemini/config/skills`):
```bash
./install.sh
# or explicitly:
./install.sh --global
```

### 2. Project-Specific Installation
Symlink into any project repository so your workspace agent picks it up under `<project>/.agents/skills`:
```bash
./install.sh --project /path/to/your/project
```

### 3. Claude Code & Cursor
```bash
# Claude Code:
./install.sh --claude

# Cursor:
./install.sh --cursor
```

## Adding New Skills

1. Create a new directory inside `skills/<skill-name>/`
2. Add a `SKILL.md` file with the standard YAML frontmatter:
   ```markdown
   ---
   name: <skill-name>
   description: <one-line trigger summary for progressive disclosure>
   ---

   # Skill Title
   Instructions and workflows...
   ```
3. Run `./install.sh` to update your links.
4. Commit and push to GitHub!
