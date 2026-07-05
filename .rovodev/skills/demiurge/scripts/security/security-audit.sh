#!/bin/bash
# security-audit.sh -- Universal security audit
# Checks for common vulnerabilities across languages
set -euo pipefail

DIR="${1:-.}"
echo "=== Security Audit: $DIR ==="

# Secrets/credentials
echo "--- Secrets in Code ---"
grep -rn "password\s*=\s*['\"]\|secret\s*=\s*['\"]\|api_key\s*=\s*['\"]\|token\s*=\s*['\"]\|AWS_\|PRIVATE_KEY" "$DIR" --include='*.ts' --include='*.js' --include='*.py' --include='*.go' --include='*.rs' --include='*.java' --include='*.c' --include='*.cpp' --include='*.h' 2>/dev/null | grep -v "node_modules\|\.git\|test\|spec\|example" || echo "none found"

# Injection patterns
echo ""
echo "--- Injection Patterns ---"
grep -rn "eval(\|exec(\|execSync(\|system(\|popen(\|shell=True\|subprocess.*shell" "$DIR" --include='*.ts' --include='*.js' --include='*.py' --include='*.go' --include='*.java' --include='*.c' --include='*.cpp' 2>/dev/null | grep -v "node_modules\|\.git\|test\|spec" || echo "none found"

# Unsafe deserialization
echo ""
echo "--- Unsafe Deserialization ---"
grep -rn "pickle\|yaml.load(\|JSON.parse\|unserialize\|ObjectInputStream\|from_json" "$DIR" --include='*.ts' --include='*.js' --include='*.py' --include='*.go' --include='*.java' 2>/dev/null | grep -v "node_modules\|\.git\|test\|spec" || echo "none found"

# SQL injection
echo ""
echo "--- SQL Injection Risk ---"
grep -rn "query.*+\|f\".*SELECT\|f\".*INSERT\|f\".*UPDATE\|f\".*DELETE\|format.*SELECT" "$DIR" --include='*.ts' --include='*.js' --include='*.py' --include='*.go' --include='*.java' 2>/dev/null | grep -v "node_modules\|\.git\|test\|spec" || echo "none found"

# Hardcoded paths/URLs
echo ""
echo "--- Hardcoded Paths ---"
grep -rn "localhost:\|127\.0\.0\.1\|/home/\|/Users/\|C:\\\\" "$DIR" --include='*.ts' --include='*.js' --include='*.py' --include='*.go' --include='*.rs' --include='*.java' 2>/dev/null | grep -v "node_modules\|\.git\|test\|spec\|README" || echo "none found"

echo ""
echo "=== Security audit complete ==="
