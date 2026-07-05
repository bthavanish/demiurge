#!/usr/bin/env bash
# audit-cpp.sh -- C++ codebase audit script
# Checks: dead code, includes, complexity, memory, security
set -euo pipefail

DIR="${1:-.}"

# Find C++ source files excluding common non-project directories
find_cpp_files() {
  find "$DIR" \( -name '*.cpp' -o -name '*.cc' -o -name '*.cxx' -o -name '*.hpp' -o -name '*.h' \) \
    -not -path '*/build/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/vendor/*'
}

echo "=== C++ Audit: $DIR ==="
echo ""

# TODO markers
echo "--- Debt Markers ---"
find_cpp_files -exec grep -n "TODO\|FIXME\|HACK\|XXX" {} + 2>/dev/null || true

# Raw pointer usage (prefer smart pointers)
echo ""
echo "--- Raw Pointer Usage ---"
find_cpp_files -exec grep -n "[a-zA-Z_]\*\s\+[a-zA-Z_].*=" {} + 2>/dev/null | grep -v "//\|/\*\|^\s*\*" | head -20 || true

# Memory management
echo ""
echo "--- Manual Memory Management ---"
find_cpp_files -exec grep -n "new \|delete \|malloc(\|calloc(\|free(" {} + 2>/dev/null || true

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
find_cpp_files -exec awk '
/^[a-zA-Z_][a-zA-Z0-9_:<>]*[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} + 2>/dev/null || true

# Using namespace std
echo ""
echo "--- Using Namespace ---"
find_cpp_files -exec grep -n "using namespace" {} + 2>/dev/null || true

# C-style casts
echo ""
echo "--- C-Style Casts ---"
find_cpp_files -exec grep -n "(int)\|(char\*)\|(void\*)\|(double)" {} + 2>/dev/null || true

# Security patterns
echo ""
echo "--- Security Patterns ---"
find_cpp_files -exec grep -n "gets(\|scanf(\|sprintf(\|strcpy(\|strcat(" {} + 2>/dev/null || true
