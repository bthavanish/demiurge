#!/usr/bin/env python3
"""Gather project information and output as JSON.

Usage: gather-info.py [directory]
Output: JSON to stdout, saved to /tmp/demiurge/gather-info.log
"""

import json
import os
import subprocess
import sys
import random
import string
from pathlib import Path
from collections import Counter

LOG_DIR = Path("/tmp/demiurge")

SKIP_DIRS = {
    "node_modules", ".git", "vendor", "target", "__pycache__",
    ".venv", "venv", "dist", "build", ".opencode", ".agents", ".claude",
    ".tox", ".mypy_cache", ".pytest_cache", "coverage", ".nyc_output",
}

EXT_TO_LANG = {
    "ts": "typescript", "tsx": "typescript", "mts": "typescript", "cts": "typescript",
    "js": "javascript", "jsx": "javascript", "mjs": "javascript", "cjs": "javascript",
    "vue": "vue", "svelte": "svelte",
    "py": "python", "pyi": "python", "pyw": "python",
    "go": "go",
    "rs": "rust",
    "c": "c", "h": "c", "cc": "cpp", "cpp": "cpp", "cxx": "cpp",
    "hpp": "cpp", "hxx": "cpp", "hh": "cpp",
    "java": "java",
    "sh": "shell", "bash": "shell", "zsh": "shell", "ksh": "shell",
    "yaml": "yaml", "yml": "yaml",
    "json": "json", "jsonc": "json", "jsonl": "json",
    "md": "markdown", "mdx": "markdown",
    "css": "css", "scss": "css", "sass": "css", "less": "css",
    "html": "html", "htm": "html", "xhtml": "html",
    "sql": "sql",
    "tf": "terraform", "hcl": "terraform", "tfvars": "terraform",
    "rb": "ruby",
    "php": "php",
    "swift": "swift",
    "kt": "kotlin", "kts": "kotlin",
    "scala": "scala",
    "lua": "lua",
    "r": "r", "R": "r",
    "pl": "perl", "pm": "perl",
    "ex": "elixir", "exs": "elixir",
    "erl": "erlang",
    "hs": "haskell",
    "clj": "clojure", "cljs": "clojure",
    "dart": "dart",
    "proto": "protobuf",
    "toml": "toml",
    "xml": "xml",
    "csv": "csv",
    "txt": "text",
}


def should_skip(path: Path) -> bool:
    return any(part in SKIP_DIRS for part in path.parts)


def human_size(size_bytes: int) -> str:
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if size_bytes < 1024:
            return f"{size_bytes:.1f}{unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f}PB"


def get_tree(root: Path, max_depth: int = 3) -> str:
    """Build a directory tree string up to max_depth levels."""
    lines = []
    base_depth = len(root.parts)

    for dirpath, dirnames, filenames in os.walk(root):
        depth = len(Path(dirpath).parts) - base_depth
        if depth >= max_depth:
            dirnames.clear()
            continue
        # Skip hidden and non-essential dirs
        dirnames[:] = sorted(
            d for d in dirnames
            if d not in SKIP_DIRS and not d.startswith(".")
        )
        indent = "  " * depth
        name = Path(dirpath).name + "/"
        if depth == 0:
            name = root.name + "/"
        lines.append(f"{indent}{name}")

    return "\n".join(lines[:100])


def get_git_info(project_dir: Path) -> dict:
    """Get git repository information."""
    git_dir = project_dir / ".git"
    if not git_dir.is_dir():
        return {"is_repo": False, "remote_uri": None, "branch": None, "initialized_by_us": False}

    info = {"is_repo": True, "remote_uri": None, "branch": None, "initialized_by_us": False}

    try:
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            cwd=project_dir, capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0:
            info["remote_uri"] = result.stdout.strip()
    except Exception:
        pass

    try:
        result = subprocess.run(
            ["git", "branch", "--show-current"],
            cwd=project_dir, capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0 and result.stdout.strip():
            info["branch"] = result.stdout.strip()
        else:
            result = subprocess.run(
                ["git", "rev-parse", "--short", "HEAD"],
                cwd=project_dir, capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0:
                info["branch"] = result.stdout.strip()
    except Exception:
        pass

    return info


def init_git(project_dir: Path) -> dict:
    """Initialize a git repo with a random name."""
    # Generate random name
    dict_path = Path("/usr/share/dict/words")
    if dict_path.exists():
        words = dict_path.read_text().splitlines()
        words = [w for w in words if w.isalpha() and len(w) > 3]
        if len(words) >= 2:
            name = "-".join(random.sample(words, 2)).lower()
        else:
            name = None
    else:
        name = None

    if not name:
        hex_str = "".join(random.choices(string.hexdigits[:16], k=8))
        name = f"project-{hex_str}"

    try:
        subprocess.run(
            ["git", "init", "-b", "main"],
            cwd=project_dir, capture_output=True, timeout=10
        )
        return {
            "is_repo": False,
            "remote_uri": None,
            "branch": "main",
            "initialized_by_us": True,
            "project_name": name,
        }
    except Exception:
        return {
            "is_repo": False,
            "remote_uri": None,
            "branch": None,
            "initialized_by_us": False,
            "project_name": name,
        }


def count_languages(project_dir: Path) -> dict:
    """Count files by language based on extension."""
    ext_counter: Counter = Counter()
    file_count = 0
    total_size = 0

    for root, dirs, files in os.walk(project_dir):
        root_path = Path(root)
        # Skip non-essential directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith(".")]

        for fname in files:
            fpath = root_path / fname
            if should_skip(fpath.relative_to(project_dir)):
                continue
            file_count += 1
            try:
                total_size += fpath.stat().st_size
            except OSError:
                pass
            ext = fpath.suffix.lstrip(".").lower()
            if ext in EXT_TO_LANG:
                ext_counter[EXT_TO_LANG[ext]] += 1

    # Also check for Dockerfiles
    for item in project_dir.rglob("Dockerfile*"):
        if not should_skip(item.relative_to(project_dir)):
            ext_counter["docker"] += 1

    return {
        "languages": dict(ext_counter.most_common()),
        "file_count": file_count,
        "total_size": human_size(total_size),
    }


def main():
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")

    if not target.is_dir():
        print(json.dumps({"error": f"Directory not found: {target}"}), file=sys.stderr)
        sys.exit(1)

    target = target.resolve()

    # Git info
    git_info = get_git_info(target)
    if not git_info["is_repo"]:
        git_info = init_git(target)

    # Language and file info
    lang_info = count_languages(target)

    # Directory tree
    tree = get_tree(target)

    result = {
        "directory": str(target),
        "tree": tree,
        "languages": lang_info["languages"],
        "git": git_info,
        "file_count": lang_info["file_count"],
        "total_size": lang_info["total_size"],
    }

    output = json.dumps(result, indent=2)
    print(output)

    # Save to log
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    (LOG_DIR / "gather-info.log").write_text(output)


if __name__ == "__main__":
    main()
