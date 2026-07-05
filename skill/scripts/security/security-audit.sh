#!/usr/bin/env bash
# security-audit.sh -- Universal security audit
# Checks for common vulnerabilities across languages
set -euo pipefail

DIR="${1:-.}"
echo "=== Security Audit: $DIR ==="
echo ""

# Build find command with exclusions
find_code_files() {
  find "$DIR" \
    \( -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/build/*' \
    -not -path '*/target/*' \
    -not -path '*/vendor/*' \
    -not -path '*/.venv/*' \
    -not -path '*/venv/*' \
    -not -path '*/__pycache__/*'
}

# Secrets/credentials
echo "--- Secrets in Code ---"
find_code_files -exec grep -n "password\s*=\s*['\"]\|secret\s*=\s*['\"]\|api_key\s*=\s*['\"]\|token\s*=\s*['\"]\|AWS_\|PRIVATE_KEY" {} + 2>/dev/null | grep -vi "test\|spec\|example\|mock" || echo "  none found"

# Injection patterns
echo ""
echo "--- Injection Patterns ---"
find_code_files -exec grep -n "eval(\|exec(\|execSync(\|system(\|popen(\|shell=True\|subprocess.*shell" {} + 2>/dev/null | grep -vi "test\|spec" || echo "  none found"

# Unsafe deserialization
echo ""
echo "--- Unsafe Deserialization ---"
find_code_files -exec grep -n "pickle\|yaml.load(\|JSON.parse\|unserialize\|ObjectInputStream\|from_json" {} + 2>/dev/null | grep -vi "test\|spec" || echo "  none found"

# SQL injection
echo ""
echo "--- SQL Injection Risk ---"
find_code_files -exec grep -n "query.*+\|f\".*SELECT\|f\".*INSERT\|f\".*UPDATE\|f\".*DELETE\|format.*SELECT" {} + 2>/dev/null | grep -vi "test\|spec" || echo "  none found"

# Hardcoded paths/URLs
echo ""
echo "--- Hardcoded Paths ---"
find_code_files -exec grep -n "localhost:\|127\.0\.0\.1\|/home/\|/Users/\|C:\\\\" {} + 2>/dev/null | grep -vi "test\|spec\|README" || echo "  none found"

echo ""
echo "=== Security audit complete ==="
