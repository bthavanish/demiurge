#!/usr/bin/env bash
# audit-c.sh -- C codebase audit script
# Checks: dead code, includes, complexity, security patterns, memory
set -euo pipefail

DIR="${1:-.}"

# Find C source files excluding common non-project directories
find_c_files() {
  find "$DIR" \( -name '*.c' -o -name '*.h' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/build/*' \
    -not -path '*/vendor/*'
}

echo "=== C Audit: $DIR ==="
echo ""

# Unused includes (basic check)
echo "--- Potentially Unused Includes ---"
find_c_files -exec grep -n "^#include" {} + 2>/dev/null || true

# TODO markers
echo ""
echo "--- Debt Markers ---"
find_c_files -exec grep -n "TODO\|FIXME\|HACK\|XXX" {} + 2>/dev/null || true

# Security patterns
echo ""
echo "--- Security Patterns ---"
find_c_files -exec grep -n "gets(\|scanf(\|sprintf(\|strcpy(\|strcat(\|system(\|popen(\|exec[lv]p\?(" {} + 2>/dev/null || true

# Memory patterns
echo ""
echo "--- Memory Patterns ---"
find_c_files -exec grep -n "malloc(\|calloc(\|realloc(\|free(" {} + 2>/dev/null || true

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
find_c_files -exec awk '
/^((static|extern|inline|void|int|char|float|double|long|short|unsigned|struct|enum)[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} + 2>/dev/null || true

# Macros
echo ""
echo "--- Function-Like Macros ---"
find_c_files -exec grep -n "#define [A-Z_]*(" {} + 2>/dev/null || true
