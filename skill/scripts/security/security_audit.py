#!/usr/bin/env python3
"""Cross-platform security audit.

Usage: security_audit.py [directory]
Scans for secrets, injection, unsafe deserialization, SQL injection, hardcoded paths.
Output: JSON to stdout, saved to /tmp/demiurge/security-audit.log
"""

import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from collections import defaultdict

LOG_DIR = Path("/tmp/demiurge")

SKIP_DIRS = {
    "node_modules", ".git", "vendor", "target", "__pycache__",
    ".venv", "venv", "dist", "build", ".opencode", ".agents", ".claude",
}

CODE_EXTENSIONS = {
    ".py", ".js", ".ts", ".jsx", ".tsx", ".go", ".rs", ".java",
    ".rb", ".php", ".c", ".cpp", ".h", ".hpp", ".cs", ".swift",
    ".kt", ".scala", ".lua", ".r", ".pl", ".sh", ".bash",
}

# Patterns: (category, severity, name, regex)
PATTERNS = [
    # Secrets
    ("secrets", "P0", "password assignment",
     re.compile(r"(?i)(password|passwd|pwd)\s*[:=]\s*[\"'][^\"']+[\"']")),
    ("secrets", "P0", "hardcoded credential",
     re.compile(r"(?i)(api_key|apikey|secret_key|auth_token|access_token|private_key)\s*[:=]\s*[\"'][^\"']+[\"']")),
    ("secrets", "P1", "potential secret",
     re.compile(r"(?i)(secret|token)\s*[:=]\s*[\"'][^\"']{8,}[\"']")),

    # Injection
    ("injection", "P1", "code execution call",
     re.compile(r"(eval\s*\(|exec\s*\(|system\s*\(|os\.system\s*\(|subprocess\.\w+.*shell\s*=\s*True)")),
    ("injection", "P1", "shell=True",
     re.compile(r"shell\s*=\s*True")),

    # Unsafe deserialization
    ("deserialization", "P1", "unsafe deserialization",
     re.compile(r"(pickle\.loads?\(|yaml\.load\s*\(|unserialize\s*\(|ObjectInputStream|marshal\.loads?\()")),

    # SQL injection
    ("sql_injection", "P1", "string interpolation in query",
     re.compile(r"(?i)(SELECT|INSERT|UPDATE|DELETE|DROP).*(f[\"']|%s|\+\s*\+\s*|format\s*\()")),
    ("sql_injection", "P0", "formatted SQL query",
     re.compile(r"cursor\.execute\s*\(.*format\s*\(")),

    # Hardcoded paths
    ("hardcoded", "P3", "hardcoded path/host",
     re.compile(r"(localhost|127\.0\.0\.1|/home/[a-zA-Z]|C:\\\\Users|/Users/[a-zA-Z])")),
]


def should_skip(path: Path) -> bool:
    return any(part in SKIP_DIRS for part in path.parts)


def scan_code_files(target_dir: Path) -> list[Path]:
    """Find all code files to scan."""
    files = []
    for root, dirs, filenames in os.walk(target_dir):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith(".")]
        for fname in filenames:
            fpath = Path(root) / fname
            if fpath.suffix.lower() in CODE_EXTENSIONS:
                files.append(fpath)
    return files


def scan_secrets_injection_deser(target_dir: Path) -> list[dict]:
    """Scan code files for secrets, injection, and deserialization patterns."""
    findings = []
    files = scan_code_files(target_dir)

    for fpath in files:
        try:
            content = fpath.read_text(errors="ignore")
        except Exception:
            continue

        for lineno, line in enumerate(content.splitlines(), 1):
            for category, severity, name, pattern in PATTERNS:
                if pattern.search(line):
                    findings.append({
                        "category": category,
                        "severity": severity,
                        "file": str(fpath),
                        "line": lineno,
                        "pattern": name,
                        "snippet": line.strip()[:200],
                    })

    return findings


def run_dependency_audit(target_dir: Path) -> list[dict]:
    """Run dependency audits for detected ecosystems."""
    results = []

    # npm audit
    lockfiles = ["package-lock.json", "yarn.lock", "pnpm-lock.yaml"]
    if any((target_dir / f).exists() for f in lockfiles) and (target_dir / "package.json").exists():
        if shutil.which("npm"):
            try:
                result = subprocess.run(
                    ["npm", "audit", "--json"],
                    cwd=target_dir, capture_output=True, text=True, timeout=60
                )
                data = json.loads(result.stdout) if result.stdout else {}
                vulns = data.get("metadata", {}).get("vulnerabilities", {})
                critical = vulns.get("critical", 0)
                high = vulns.get("high", 0)
                moderate = vulns.get("moderate", 0)
                status = "vulnerable" if (critical + high) > 0 else "clean"
                results.append({
                    "ecosystem": "npm",
                    "status": status,
                    "critical": critical,
                    "high": high,
                    "moderate": moderate,
                })
            except Exception:
                pass

    # pip-audit
    py_files = ["requirements.txt", "Pipfile.lock", "pyproject.toml", "setup.py"]
    if any((target_dir / f).exists() for f in py_files):
        for tool in ["pip-audit", "safety"]:
            if shutil.which(tool):
                try:
                    cmd = [tool, "--format", "json"] if tool == "pip-audit" else [tool, "check", "--json"]
                    result = subprocess.run(
                        cmd, cwd=target_dir, capture_output=True, text=True, timeout=60
                    )
                    # Count vulnerabilities
                    vuln_count = result.stdout.count('"vuln_id"') + result.stdout.count('"vulnerability"')
                    status = "vulnerable" if vuln_count > 0 else "clean"
                    results.append({
                        "ecosystem": "pip",
                        "status": status,
                        "critical": 0,
                        "high": vuln_count,
                        "moderate": 0,
                    })
                    break
                except Exception:
                    pass

    # cargo audit
    if (target_dir / "Cargo.lock").exists() and shutil.which("cargo-audit"):
        try:
            result = subprocess.run(
                ["cargo", "audit", "--json"],
                cwd=target_dir, capture_output=True, text=True, timeout=60
            )
            vuln_count = result.stdout.count('"vulnerabilities"')
            status = "vulnerable" if vuln_count > 0 else "clean"
            results.append({
                "ecosystem": "cargo",
                "status": status,
                "critical": 0,
                "high": vuln_count,
                "moderate": 0,
            })
        except Exception:
            pass

    # govulncheck
    if (target_dir / "go.mod").exists() and shutil.which("govulncheck"):
        try:
            result = subprocess.run(
                ["govulncheck", "./..."],
                cwd=target_dir, capture_output=True, text=True, timeout=120
            )
            vuln_count = result.stdout.lower().count("vulnerability")
            status = "vulnerable" if vuln_count > 0 else "clean"
            results.append({
                "ecosystem": "go",
                "status": status,
                "critical": 0,
                "high": vuln_count,
                "moderate": 0,
            })
        except Exception:
            pass

    return results


def main():
    target_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")

    if not target_dir.is_dir():
        print(json.dumps({"error": f"Directory not found: {target_dir}"}), file=sys.stderr)
        sys.exit(1)

    target_dir = target_dir.resolve()

    # Scan for code-level findings
    findings = scan_secrets_injection_deser(target_dir)

    # Run dependency audits
    dep_audit = run_dependency_audit(target_dir)

    # Build summary
    by_severity = defaultdict(int)
    by_category = defaultdict(int)
    for f in findings:
        by_severity[f["severity"]] += 1
        by_category[f["category"]] += 1

    report = {
        "directory": str(target_dir),
        "findings": findings,
        "dependency_audit": dep_audit,
        "summary": {
            "total_findings": len(findings),
            "by_severity": dict(by_severity),
            "by_category": dict(by_category),
        },
    }

    output = json.dumps(report, indent=2)
    print(output)

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    (LOG_DIR / "security-audit.log").write_text(output)


if __name__ == "__main__":
    main()
