#!/bin/bash
# audit-github-actions.sh -- GitHub Actions security audit
# Detects: dangerous triggers, AI agent injection, secrets exposure,
# script injection, permission escalation, supply chain risks
set -euo pipefail

DIR="${1:-.}"
WORKFLOW_DIR="$DIR/.github/workflows"

echo "=== GitHub Actions Security Audit: $DIR ==="

if [ ! -d "$WORKFLOW_DIR" ]; then
  echo "No .github/workflows/ directory found"
  exit 0
fi

WORKFLOWS=$(find "$WORKFLOW_DIR" -name '*.yml' -o -name '*.yaml' | sort)
COUNT=$(echo "$WORKFLOWS" | grep -c . || true)
echo "Found $COUNT workflow files"

if [ "$COUNT" -eq 0 ]; then
  echo "No workflow files found"
  exit 0
fi

echo ""
echo "=== Dangerous Triggers ==="
echo "$WORKFLOWS" | while read f; do
  # pull_request_target: runs with secrets, triggered by external PRs
  if grep -q 'pull_request_target' "$f" 2>/dev/null; then
    echo "P0 $f: pull_request_target trigger (runs with secrets, external input)"
  fi
  # issue_comment: comment body is attacker-controlled
  if grep -q 'issue_comment' "$f" 2>/dev/null; then
    echo "P1 $f: issue_comment trigger (attacker-controlled comment body)"
  fi
  # issues: issue body/title is attacker-controlled
  if grep -q 'issues:' "$f" 2>/dev/null; then
    echo "P1 $f: issues trigger (attacker-controlled issue body/title)"
  fi
  # workflow_dispatch with inputs
  if grep -q 'workflow_dispatch:' "$f" 2>/dev/null; then
    echo "P2 $f: workflow_dispatch trigger (inputs are user-controlled)"
  fi
done

echo ""
echo "=== Secrets Exposure ==="
echo "$WORKFLOWS" | while read f; do
  # Secrets in env blocks that flow to AI/LLM prompts
  if grep -n 'secrets\.' "$f" 2>/dev/null | grep -v '^.*#'; then
    echo "P1 $f: secrets referenced in workflow (check for over-scoping)"
  fi
  # GITHUB_TOKEN with write permissions
  if grep -q 'contents: write\|pull-requests: write\|actions: write' "$f" 2>/dev/null; then
    echo "P2 $f: write permissions granted (check if necessary)"
  fi
done

echo ""
echo "=== Script Injection ==="
echo "$WORKFLOWS" | while read f; do
  # Direct expression injection in run: blocks
  grep -n 'run:.*\${{' "$f" 2>/dev/null | while read line; do
    echo "P0 $f: $line"
  done
  # Expression injection in shell variables
  grep -n 'echo.*\${{.*github\.event' "$f" 2>/dev/null | while read line; do
    echo "P0 $f: $line"
  done
done

echo ""
echo "=== AI Agent Actions ==="
echo "$WORKFLOWS" | while read f; do
  # Known AI agent actions
  grep -n 'claude-code-action\|run-gemini-cli\|gemini-cli-action\|codex-action\|ai-inference' "$f" 2>/dev/null | while read line; do
    echo "P1 $f: AI agent action detected - $line"
  done
  # Check for dangerous sandbox configs
  if grep -q 'danger-full-access\|Bash(\*)\|--yolo\|approval-mode=yolo' "$f" 2>/dev/null; then
    echo "P0 $f: dangerous sandbox/approval config detected"
  fi
  # Check for wildcard allowlists
  if grep -qE 'allow.*:.*\"\*\"|allowed_non_write_users:.*\"\*\"' "$f" 2>/dev/null; then
    echo "P1 $f: wildcard user allowlist detected"
  fi
done

echo ""
echo "=== Supply Chain ==="
echo "$WORKFLOWS" | while read f; do
  # Unpinned actions (no @sha or @vX)
  grep -n 'uses:' "$f" 2>/dev/null | grep -v '@sha-' | grep -v '@v[0-9]' | grep -v '^\s*#' | while read line; do
    echo "P2 $f: unpinned action reference - $line"
  done
  # Third-party actions
  grep -n 'uses:' "$f" 2>/dev/null | grep -v 'actions/\|github/\|checkout\|setup-\|upload-\|download-\|cache' | grep -v '^\s*#' | while read line; do
    echo "P2 $f: third-party action - $line"
  done
done

echo ""
echo "=== Permissions ==="
echo "$WORKFLOWS" | while read f; do
  # Missing permissions block (defaults to write-all)
  if ! grep -q 'permissions:' "$f" 2>/dev/null; then
    echo "P2 $f: no permissions block (defaults to write-all)"
  fi
  # Overly broad permissions
  if grep -q 'permissions:.*write-all\|permissions:.*all' "$f" 2>/dev/null; then
    echo "P1 $f: overly broad permissions (write-all or all)"
  fi
done

echo ""
echo "=== Audit complete ==="
