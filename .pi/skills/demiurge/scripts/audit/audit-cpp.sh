#!/bin/bash
# audit-cpp.sh -- C++ codebase audit script
# Checks: dead code, includes, complexity, memory, security
set -euo pipefail

DIR="${1:-.}"
FIND="find "$DIR" \( -name '*.cpp' -o -name '*.cc' -o -name '*.cxx' -o -name '*.hpp' -o -name '*.h' \) -not -path '*/build/*' -not -path '*/node_modules/*'"

echo "=== C++ Audit: $DIR ==="
echo ""

# TODO markers
echo "--- Debt Markers ---"
$FIND -exec grep -n "TODO\|FIXME\|HACK\|XXX\|ponytail:" {} \;

# Raw pointer usage (prefer smart pointers)
echo ""
echo "--- Raw Pointer Usage ---"
$FIND -exec grep -n "[a-zA-Z_]\*\s\+[a-zA-Z_].*=" {} \; | grep -v "//\|/\*\|^\s*\*" | head -20

# Memory management
echo ""
echo "--- Manual Memory Management ---"
$FIND -exec grep -n "new \|delete \|malloc(\|calloc(\|free(" {} \;

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
$FIND -exec awk '
/^[a-zA-Z_][a-zA-Z0-9_:<>]*[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} \;

# Using namespace std
echo ""
echo "--- Using Namespace ---"
$FIND -exec grep -n "using namespace" {} \;

# C-style casts
echo ""
echo "--- C-Style Casts ---"
$FIND -exec grep -n "(int)\|(char\*)\|(void\*)\|(double)" {} \;

# Security patterns
echo ""
echo "--- Security Patterns ---"
$FIND -exec grep -n "gets(\|scanf(\|sprintf(\|strcpy(\|strcat(" {} \;
