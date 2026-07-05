#!/bin/bash
# audit-c.sh -- C codebase audit script
# Checks: dead code, includes, complexity, security patterns, memory
set -euo pipefail

DIR="${1:-.}"
FIND="find "$DIR" -name '*.c' -o -name '*.h' | grep -v '/node_modules/'"

echo "=== C Audit: $DIR ==="
echo ""

# Unused includes (basic check)
echo "--- Potentially Unused Includes ---"
$FIND -exec grep -n "^#include" {} \;

// TODO markers
echo ""
echo "--- Debt Markers ---"
$FIND -exec grep -n "TODO\|FIXME\|HACK\|XXX\|ponytail:" {} \;

# Security patterns
echo ""
echo "--- Security Patterns ---"
$FIND -exec grep -n "gets(\|scanf(\|sprintf(\|strcpy(\|strcat(\|system(\|popen(\|exec[lv]p\?(" {} \;

# Memory patterns
echo ""
echo "--- Memory Patterns ---"
$FIND -exec grep -n "malloc(\|calloc(\|realloc(\|free(" {} \;

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
$FIND -exec awk '
/^((static|extern|inline|void|int|char|float|double|long|short|unsigned|struct|enum)[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} \;

# Macros
echo ""
echo "--- Function-Like Macros ---"
$FIND -exec grep -n "#define [A-Z_]*(" {} \;
