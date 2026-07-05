#!/bin/bash
# audit-dependencies.sh -- Dependency security audit
# Checks for known CVEs, outdated packages, lockfile issues
set -euo pipefail

DIR="${1:-.}"

echo "=== Dependency Security Audit: $DIR ==="

# Node.js
if [ -f "$DIR/package.json" ]; then
  echo "--- npm/yarn/pnpm ---"
  cd "$DIR"
  if command -v npm >/dev/null 2>&1; then
    echo "npm audit:"
    npm audit --json 2>/dev/null | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    v=d.get('metadata',{}).get('vulnerabilities',{})
    if v.get('critical',0): print(f'  CRITICAL: {v[\"critical\"]} vulnerabilities')
    if v.get('high',0): print(f'  HIGH: {v[\"high\"]} vulnerabilities')
    if v.get('moderate',0): print(f'  MODERATE: {v[\"moderate\"]} vulnerabilities')
    if v.get('low',0): print(f'  LOW: {v[\"low\"]} vulnerabilities')
    if not any(v.get(k,0) for k in ['critical','high','moderate','low']): print('  No known vulnerabilities')
except: print('  Could not parse npm audit output')
" 2>/dev/null || echo "  npm audit failed"
  fi
  if command -v yarn >/dev/null 2>&1 && [ -f "$DIR/yarn.lock" ]; then
    echo "yarn audit:"
    yarn audit --json 2>/dev/null | head -5 || echo "  yarn audit failed"
  fi
fi

# Python
if [ -f "$DIR/requirements.txt" ] || [ -f "$DIR/setup.py" ] || [ -f "$DIR/pyproject.toml" ]; then
  echo "--- Python ---"
  if command -v pip-audit >/dev/null 2>&1; then
    cd "$DIR" && pip-audit 2>/dev/null || echo "  pip-audit failed"
  elif command -v safety >/dev/null 2>&1; then
    cd "$DIR" && safety check 2>/dev/null || echo "  safety check failed"
  else
    echo "  Install pip-audit or safety for dependency scanning"
  fi
fi

# Go
if [ -f "$DIR/go.mod" ]; then
  echo "--- Go ---"
  cd "$DIR" && go list -m -json all 2>/dev/null | python3 -c "
import json,sys
for line in sys.stdin.read().split('}\n{'):
    try:
        d=json.loads('{' + line.strip().strip('{}') + '}')
        if d.get('Update') and d['Update'].get('Version'):
            print(f'  {d[\"Path\"]}: {d[\"Version\"]} -> {d[\"Update\"][\"Version\"]}')
    except: pass
" 2>/dev/null || echo "  go list failed"
fi

# Rust
if [ -f "$DIR/Cargo.toml" ]; then
  echo "--- Rust ---"
  if command -v cargo-audit >/dev/null 2>&1; then
    cd "$DIR" && cargo audit 2>/dev/null || echo "  cargo audit failed"
  else
    echo "  Install cargo-audit for vulnerability scanning"
  fi
fi

# Java
if [ -f "$DIR/pom.xml" ] || [ -f "$DIR/build.gradle" ]; then
  echo "--- Java ---"
  if [ -f "$DIR/pom.xml" ]; then
    cd "$DIR" && mvn org.owasp:dependency-check-maven:check 2>/dev/null || echo "  OWASP dependency-check failed (install plugin)"
  fi
fi

# Docker
if [ -f "$DIR/Dockerfile" ]; then
  echo "--- Docker ---"
  grep -n "FROM " "$DIR/Dockerfile" | while read line; do
    if echo "$line" | grep -q ':latest\|^FROM [^:]*$'; then
      echo "P1 Dockerfile: unpinned base image - $line"
    fi
  done
fi

echo ""
echo "=== Dependency audit complete ==="
