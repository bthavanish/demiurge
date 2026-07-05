#!/usr/bin/env bash
# audit-go.sh -- Go codebase audit script
# Checks: dead code, error handling, complexity, security patterns
set -euo pipefail

DIR="${1:-.}"

# Find Go source files excluding common non-project directories
find_go_files() {
  find "$DIR" -name '*.go' \
    -not -path '*/vendor/*' \
    -not -path '*/.git/*' \
    -not -path '*/build/*'
}

echo "=== Go Audit: $DIR ==="
echo ""

# Ignored errors (err assigned but not checked)
echo "--- Ignored Errors ---"
find_go_files -exec grep -n "_ = " {} + 2>/dev/null || true

# TODO markers
echo ""
echo "--- Debt Markers ---"
find_go_files -exec grep -n "TODO\|FIXME\|HACK\|XXX" {} + 2>/dev/null || true

# Panic usage
echo ""
echo "--- Panic Usage ---"
find_go_files -exec grep -n "panic(" {} + 2>/dev/null || true

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
find_go_files -exec awk '
/^func /{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} + 2>/dev/null || true

# Error wrapping
echo ""
echo "--- Unwrapped Errors ---"
find_go_files -exec grep -n 'return.*err$' {} + 2>/dev/null || true

# reflect usage
echo ""
echo "--- Reflect Usage ---"
find_go_files -exec grep -n 'reflect\.' {} + 2>/dev/null || true

# Security patterns
echo ""
echo "--- Security Patterns ---"
find_go_files -exec grep -n 'exec\.Command\|os\.Exec\|unsafe\.\|syscall\.' {} + 2>/dev/null || true
