#!/usr/bin/env python3
"""Unified cross-platform audit script.

Usage: audit.py [directory]
Detects languages by file extension, runs available linters, outputs JSON report.
Output: JSON to stdout, saved to /tmp/demiurge/audit.log
"""

import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path
from collections import Counter
from typing import Optional

LOG_DIR = Path("/tmp/demiurge")
TIMEOUT_SECS = 30
MAX_LINES = 200

SKIP_DIRS = {
    "node_modules", ".git", "vendor", "target", "__pycache__",
    ".venv", "venv", "dist", "build", ".opencode", ".agents", ".claude",
}

# Extension -> language mapping
EXT_TO_LANG: dict[str, str] = {}
_LANG_MAP = {
    "typescript": ["ts", "tsx", "mts", "cts"],
    "javascript": ["js", "jsx", "mjs", "cjs", "vue", "svelte"],
    "python": ["py", "pyi", "pyw"],
    "go": ["go"],
    "rust": ["rs"],
    "cpp": ["c", "h", "cc", "cpp", "cxx", "hpp", "hxx", "hh"],
    "java": ["java"],
    "shell": ["sh", "bash", "zsh", "ksh", "ash", "dash", "fish"],
    "yaml": ["yaml", "yml"],
    "json": ["json", "jsonc", "jsonl"],
    "markdown": ["md", "mdx", "markdown"],
    "css": ["css", "scss", "sass", "less"],
    "html": ["html", "htm", "xhtml"],
    "sql": ["sql"],
    "terraform": ["tf", "hcl", "tfvars"],
    "docker": [],  # detected by filename, not extension
}
for lang, exts in _LANG_MAP.items():
    for ext in exts:
        EXT_TO_LANG[ext] = lang

# Linter definitions: (language, linter_name, command, cwd_relative)
# command is a list of args; {dir} is replaced with target dir
LINTER_DEFS = [
    ("typescript", "eslint", ["eslint", "--no-error-on-unmatched-pattern", "--format", "compact", "."]),
    ("typescript", "biome", ["biome", "check", "."]),
    ("typescript", "oxlint", ["oxlint", "."]),
    ("python", "ruff", ["ruff", "check", "."]),
    ("python", "pylint", ["pylint", "--recursive=y", "."]),
    ("python", "flake8", ["flake8", "."]),
    ("go", "golangci-lint", ["golangci-lint", "run", "./..."]),
    ("go", "go-vet", ["go", "vet", "./..."]),
    ("rust", "clippy", ["cargo", "clippy", "--all-targets", "--all-features", "--", "-D", "warnings"]),
    ("rust", "rustfmt", ["cargo", "fmt", "--check"]),
    ("cpp", "cppcheck", ["cppcheck", "--enable=all", "--suppress=missingIncludeSystem", "."]),
    ("java", "checkstyle", ["checkstyle", "-c", "/sun_checks.xml", "."]),
    ("shell", "shellcheck", ["shellcheck"], True),  # special: needs file list
    ("yaml", "yamllint", ["yamllint", "."]),
    ("markdown", "markdownlint", ["markdownlint", "--disable", "MD013", "--", "."]),
    ("docker", "hadolint", ["hadolint"], True),  # special: needs file list
    ("css", "stylelint", ["stylelint", "."]),
    ("html", "htmlhint", ["htmlhint", "."]),
    ("sql", "sqlfluff", ["sqlfluff", "lint", "."]),
    ("terraform", "tflint", ["tflint", "--recursive"]),
]


def should_skip(path: Path) -> bool:
    return any(part in SKIP_DIRS for part in path.parts)


def detect_languages(target_dir: Path) -> tuple[dict[str, int], list[str]]:
    """Detect languages by counting file extensions. Returns (lang_counts, raw_exts)."""
    ext_counter: Counter = Counter()
    lang_counter: Counter = Counter()

    for root, dirs, files in os.walk(target_dir):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith(".")]
        for fname in files:
            ext = Path(fname).suffix.lstrip(".").lower()
            if ext:
                ext_counter[ext] += 1
                lang = EXT_TO_LANG.get(ext, "")
                if lang:
                    lang_counter[lang] += 1

    # Check for Dockerfiles
    for item in target_dir.rglob("Dockerfile*"):
        if not should_skip(item.relative_to(target_dir)):
            lang_counter["docker"] += 1

    return dict(lang_counter.most_common()), sorted(ext_counter.keys())


def check_available(cmd_name: str) -> bool:
    """Check if a command is available on PATH."""
    return shutil.which(cmd_name) is not None


def run_linter(cmd: list[str], target_dir: Path, timeout: int = TIMEOUT_SECS) -> tuple[int, str]:
    """Run a linter command and return (return_code, output)."""
    try:
        result = subprocess.run(
            cmd,
            cwd=target_dir,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        output = result.stdout + "\n" + result.stderr
        return result.returncode, output.strip()
    except subprocess.TimeoutExpired:
        return -1, "TIMEOUT"
    except FileNotFoundError:
        return -1, f"Command not found: {cmd[0]}"
    except Exception as e:
        return -1, str(e)


def truncate(text: str, max_lines: int = MAX_LINES) -> str:
    """Truncate output to max_lines."""
    lines = text.split("\n")
    if len(lines) <= max_lines:
        return text
    return "\n".join(lines[:max_lines]) + f"\n... (truncated, {len(lines)} lines total)"


def main():
    target_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")

    if not target_dir.is_dir():
        print(json.dumps({"error": f"Directory not found: {target_dir}"}), file=sys.stderr)
        sys.exit(1)

    target_dir = target_dir.resolve()

    # Phase 1: Detect languages and file extensions
    lang_counts, raw_exts = detect_languages(target_dir)
    detected_langs = sorted(lang_counts.keys())

    # Phase 2: Run linters for detected languages
    linters_run = []
    missing_linters = []
    total_issues = 0

    for lang in detected_langs:
        for def_lang, linter_name, cmd, *rest in LINTER_DEFS:
            if def_lang != lang:
                continue

            # Check if linter binary is available
            cmd_name = cmd[0]
            if not check_available(cmd_name):
                missing_linters.append(linter_name)
                continue

            print(f"  Running {linter_name} ({lang})...", file=sys.stderr)
            rc, output = run_linter(cmd, target_dir)

            # Parse issue count from output
            non_empty_lines = [l for l in output.split("\n") if l.strip()]
            issue_count = len(non_empty_lines) if rc != 0 else 0

            if rc == 0:
                status = "pass"
                issue_count = 0
            elif issue_count > 0:
                status = "fail"
            else:
                status = "warn"

            total_issues += issue_count
            truncated_output = truncate(output)

            linters_run.append({
                "language": lang,
                "linter": linter_name,
                "status": status,
                "issues": issue_count,
                "output": truncated_output,
            })

    # Phase 3: Assemble report
    report = {
        "directory": str(target_dir),
        "extensions_detected": raw_exts,
        "languages_detected": detected_langs,
        "language_file_counts": lang_counts,
        "linters_run": linters_run,
        "summary": {
            "total_issues": total_issues,
            "languages_scanned": len(detected_langs),
            "linters_available": len(linters_run),
            "linters_missing": sorted(set(missing_linters)),
        },
    }

    output = json.dumps(report, indent=2)
    print(output)

    # Save to log
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    (LOG_DIR / "audit.log").write_text(output)


if __name__ == "__main__":
    main()
