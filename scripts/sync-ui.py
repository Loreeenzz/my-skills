#!/usr/bin/env python3
"""
Scans all skills in skills/*, parses YAML frontmatter and companion files
(references/, scripts/, assets/), and generates skills-manifest.json
plus updates embedded fallback data in index.html so the UI works both via
file:// locally and hosted on GitHub Pages.
"""

import json
import os
import re
from datetime import datetime, timezone

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILLS_DIR = os.path.join(ROOT_DIR, "skills")
MANIFEST_PATH = os.path.join(ROOT_DIR, "skills-manifest.json")
INDEX_HTML_PATH = os.path.join(ROOT_DIR, "index.html")


def infer_category(name: str, description: str) -> str:
    lower = f"{name} {description}".lower()
    if "prospect" in lower or "angular" in lower or "fastapi" in lower:
        return "Prospect & Architecture"
    if "git" in lower or "commit" in lower or "branch" in lower or "pr" in lower:
        return "Git & Versioning"
    if "session" in lower or "handoff" in lower or "memory" in lower or "context" in lower:
        return "Session Continuity"
    return "General Workflow"


def parse_frontmatter(raw: str):
    match = re.match(r"^---\s*\n([\s\S]*?)\n---\s*\n?([\s\S]*)$", raw)
    if not match:
        return {}, raw.strip()
    fm_block, body = match.group(1), match.group(2).strip()
    meta = {}
    current_key = None
    for line in fm_block.splitlines():
        if re.match(r"^[a-zA-Z0-9_-]+:\s*", line):
            k, v = line.split(":", 1)
            k = k.strip()
            v = v.strip().strip('"').strip("'")
            if v in (">-", "|", ">"):
                meta[k] = ""
                current_key = k
            else:
                meta[k] = v
                current_key = k
        elif current_key and line.startswith("  "):
            meta[current_key] = (meta[current_key] + " " + line.strip()).strip()
    return meta, body


def collect_skill_files(skill_folder_path: str, skill_id: str):
    files = []
    for root, _, filenames in os.walk(skill_folder_path):
        for fname in sorted(filenames):
            if fname.startswith("."):
                continue
            full_path = os.path.join(root, fname)
            rel_path = os.path.relpath(full_path, skill_folder_path).replace("\\", "/")
            try:
                with open(full_path, "r", encoding="utf-8") as f:
                    content = f.read()
            except UnicodeDecodeError:
                content = "[Binary File]"
            lines = len(content.splitlines())
            size_bytes = os.path.getsize(full_path)
            files.append({
                "name": rel_path,
                "path": f"skills/{skill_id}/{rel_path}",
                "content": content,
                "lines": lines,
                "sizeBytes": size_bytes,
            })
    # Ensure SKILL.md is always first
    files.sort(key=lambda x: (0 if x["name"] == "SKILL.md" else 1, x["name"]))
    return files


def build_manifest():
    skills = []
    if not os.path.isdir(SKILLS_DIR):
        return []

    for folder in sorted(os.listdir(SKILLS_DIR)):
        folder_path = os.path.join(SKILLS_DIR, folder)
        skill_md_path = os.path.join(folder_path, "SKILL.md")
        if not os.path.isdir(folder_path) or not os.path.isfile(skill_md_path):
            continue

        with open(skill_md_path, "r", encoding="utf-8") as f:
            raw_skill = f.read()

        meta, body = parse_frontmatter(raw_skill)
        name = meta.get("name", folder)
        description = meta.get("description", "")
        category = meta.get("category", infer_category(name, description))

        files = collect_skill_files(folder_path, folder)
        total_lines = sum(f["lines"] for f in files)

        skills.append({
            "id": folder,
            "name": name,
            "category": category,
            "description": description,
            "body": body,
            "rawSkillMd": raw_skill,
            "totalLines": total_lines,
            "fileCount": len(files),
            "files": files,
        })

    manifest = {
        "generatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "repository": "https://github.com/Loreeenzz/my-skills",
        "skillCount": len(skills),
        "skills": skills,
    }

    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print(f"  [✓] Generated skills-manifest.json ({len(skills)} skills)")

    # Also inject into index.html between markers if index.html exists
    if os.path.isfile(INDEX_HTML_PATH):
        with open(INDEX_HTML_PATH, "r", encoding="utf-8") as f:
            html = f.read()
        marker_pattern = re.compile(
            r"(/\* __SKILLS_MANIFEST_START__ \*/).*?(/\* __SKILLS_MANIFEST_END__ \*/)",
            re.DOTALL,
        )
        if marker_pattern.search(html):
            inline_js = f"window.__SKILLS_MANIFEST__ = {json.dumps(manifest, ensure_ascii=False)};"
            new_html = marker_pattern.sub(r"\1\n    " + inline_js.replace("\\", "\\\\") + r"\n    \2", html)
            with open(INDEX_HTML_PATH, "w", encoding="utf-8") as f:
                f.write(new_html)
            print("  [✓] Synced embedded manifest inside index.html")


if __name__ == "__main__":
    build_manifest()
