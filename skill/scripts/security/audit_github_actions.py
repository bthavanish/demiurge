#!/usr/bin/env python3
"""GitHub Actions security audit.

Usage: audit_github_actions.py [directory]
Detects dangerous triggers, AI agent injection, secrets exposure,
script injection, permission escalation, supply chain risks.
Output: JSON to stdout, saved to /tmp/demiurge/audit-github-actions.log
"""

import json
import re
import sys
from pathlib import Path
from collections import defaultdict

LOG_DIR = Path("/tmp/demiurge")

# Dangerous triggers
DANGEROUS_TRIGGERS = [
    ("pull_request_target", "P0", "runs with secrets, external input"),
    ("issue_comment", "P1", "attacker-controlled comment body"),
    ("issues", "P1", "attacker-controlled issue body/title"),
    ("workflow_dispatch", "P2", "inputs are user-controlled"),
    ("workflow_run", "P2", "previous workflow output may be attacker-controlled"),
]

# AI agent patterns
AI_AGENTS = [
    "claude-code-action", "run-gemini-cli", "gemini-cli-action",
    "codex-action", "ai-inference",
]

DANGEROUS_SANDBOX = [
    "danger-full-access", "Bash(\\*)", "--yolo", "approval-mode=yolo",
]


def audit_workflow(fpath: Path) -> list[dict]:
    """Audit a single workflow file."""
    findings = []
    try:
        content = fpath.read_text(errors="ignore")
    except Exception:
        return findings

    rel = str(fpath)

    # Dangerous triggers
    for trigger, severity, desc in DANGEROUS_TRIGGERS:
        if re.search(rf"^\s*{re.escape(trigger)}\s*:", content, re.MULTILINE):
            findings.append({
                "category": "dangerous_trigger",
                "severity": severity,
                "file": rel,
                "detail": f"{trigger} trigger ({desc})",
            })

    # Secrets exposure
    if re.search(r"secrets\.", content):
        findings.append({
            "category": "secrets_exposure",
            "severity": "P1",
            "file": rel,
            "detail": "secrets referenced (check for over-scoping)",
        })

    if re.search(r"contents:\s*write|pull-requests:\s*write|actions:\s*write", content):
        findings.append({
            "category": "permissions",
            "severity": "P2",
            "file": rel,
            "detail": "write permissions granted",
        })

    # Script injection - expression in run blocks
    for m in re.finditer(r"run:.*\$\{\{", content):
        line_no = content[:m.start()].count("\n") + 1
        findings.append({
            "category": "script_injection",
            "severity": "P0",
            "file": rel,
            "line": line_no,
            "detail": f"expression in run block: {m.group().strip()[:100]}",
        })

    # Expression injection via github.event in shell
    for m in re.finditer(r"echo.*\$\{\{.*github\.event", content):
        line_no = content[:m.start()].count("\n") + 1
        findings.append({
            "category": "script_injection",
            "severity": "P0",
            "file": rel,
            "line": line_no,
            "detail": f"event injection: {m.group().strip()[:100]}",
        })

    # AI agent actions
    for agent in AI_AGENTS:
        if agent in content:
            findings.append({
                "category": "ai_agent",
                "severity": "P1",
                "file": rel,
                "detail": f"AI agent action detected: {agent}",
            })

    # Dangerous sandbox configs
    for pattern in DANGEROUS_SANDBOX:
        if re.search(pattern, content):
            findings.append({
                "category": "ai_agent",
                "severity": "P0",
                "file": rel,
                "detail": f"dangerous sandbox config: {pattern}",
            })

    # Wildcard allowlists
    if re.search(r'allow.*:\s*"\*"|allowed_non_write_users:\s*"\*"', content):
        findings.append({
            "category": "ai_agent",
            "severity": "P1",
            "file": rel,
            "detail": "wildcard user allowlist detected",
        })

    # Unpinned actions
    for m in re.finditer(r"uses:\s*(\S+)", content):
        ref = m.group(1)
        if ref.startswith("#"):
            continue
        if not re.search(r"@(sha-[a-f0-9]+|v\d+)", ref):
            line_no = content[:m.start()].count("\n") + 1
            findings.append({
                "category": "supply_chain",
                "severity": "P2",
                "file": rel,
                "line": line_no,
                "detail": f"unpinned action: {ref}",
            })

    # Third-party actions (not from actions/ or github/)
    for m in re.finditer(r"uses:\s*(\S+)", content):
        ref = m.group(1)
        if ref.startswith("#"):
            continue
        if not re.match(r"(actions|github)/", ref):
            line_no = content[:m.start()].count("\n") + 1
            findings.append({
                "category": "supply_chain",
                "severity": "P2",
                "file": rel,
                "line": line_no,
                "detail": f"third-party action: {ref}",
            })

    # Missing permissions block
    if "permissions:" not in content:
        findings.append({
            "category": "permissions",
            "severity": "P2",
            "file": rel,
            "detail": "no permissions block (defaults to write-all)",
        })

    # Overly broad permissions
    if re.search(r"permissions:.*write-all|permissions:.*all", content):
        findings.append({
            "category": "permissions",
            "severity": "P1",
            "file": rel,
            "detail": "overly broad permissions (write-all or all)",
        })

    return findings


def main():
    target_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    workflow_dir = target_dir / ".github" / "workflows"

    if not workflow_dir.is_dir():
        report = {
            "directory": str(target_dir.resolve()),
            "workflows_found": 0,
            "findings": [],
            "summary": {"total_findings": 0},
        }
        output = json.dumps(report, indent=2)
        print(output)
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        (LOG_DIR / "audit-github-actions.log").write_text(output)
        return

    # Find all workflow files
    workflow_files = sorted(
        list(workflow_dir.glob("*.yml")) + list(workflow_dir.glob("*.yaml"))
    )

    all_findings = []
    for wf in workflow_files:
        all_findings.extend(audit_workflow(wf))

    by_severity = defaultdict(int)
    by_category = defaultdict(int)
    for f in all_findings:
        by_severity[f["severity"]] += 1
        by_category[f["category"]] += 1

    report = {
        "directory": str(target_dir.resolve()),
        "workflows_found": len(workflow_files),
        "workflow_files": [str(f.relative_to(target_dir)) for f in workflow_files],
        "findings": all_findings,
        "summary": {
            "total_findings": len(all_findings),
            "by_severity": dict(by_severity),
            "by_category": dict(by_category),
        },
    }

    output = json.dumps(report, indent=2)
    print(output)

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    (LOG_DIR / "audit-github-actions.log").write_text(output)


if __name__ == "__main__":
    main()
