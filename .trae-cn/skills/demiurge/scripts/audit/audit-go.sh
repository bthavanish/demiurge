#!/bin/bash
# audit-go.sh -- Go codebase audit script
# Checks: dead code, error handling, complexity, security patterns
set -euo pipefail

DIR="${1:-.}"
FIND="find "$DIR" -name '*.go' -not -path '*/vendor/*' -not -path '*/.git/*'"

echo "=== Go Audit: $DIR ==="
echo ""

# Ignored errors (err assigned but not checked)
echo "--- Ignored Errors ---"
$FIND -exec grep -n "_ = " {} \;

// TODO markers
echo ""
echo "--- Debt Markers ---"
$FIND -exec grep -n "TODO\|FIXME\|HACK\|XXX\|ponytail:" {} \;

# Panic usage
echo ""
echo "--- Panic Usage ---"
$FIND -exec grep -n "panic(" {} \;

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
$FIND -exec awk '
/^func /{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} \;

# Error wrapping
echo ""
echo "--- Unwrapped Errors ---"
$FIND -exec grep -n 'return.*err$' {} \;

# reflect usage
echo ""
echo "--- Reflect Usage ---"
$FIND -exec grep -n 'reflect\.' {} \;

# Security patterns
echo ""
echo "--- Security Patterns ---"
$FIND -exec grep -n 'exec\.Command\|os\.Exec\|unsafe\.\|syscall\.' {} \;
