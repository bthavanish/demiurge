#!/usr/bin/env bash
# audit-java.sh -- Java codebase audit script
# Checks: dead code, complexity, security, design patterns
set -euo pipefail

DIR="${1:-.}"

# Find Java source files excluding common non-project directories
find_java_files() {
  find "$DIR" -name '*.java' \
    -not -path '*/build/*' \
    -not -path '*/target/*' \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*'
}

echo "=== Java Audit: $DIR ==="
echo ""

# TODO markers
echo "--- Debt Markers ---"
find_java_files -exec grep -n "// TODO\|// FIXME\|// HACK\|// XXX" {} + 2>/dev/null || true

# Empty catch blocks
echo ""
echo "--- Empty Catch Blocks ---"
find_java_files -exec grep -n -A1 "catch (" {} + 2>/dev/null | grep -B1 "^\-\-$\|^[^-]*{}$\|^[^-]*}$" | grep -v "^--$" || true

# System.out.println (should use logger)
echo ""
echo "--- System.out Usage ---"
find_java_files -exec grep -n "System\.out\.print\|System\.err\.print" {} + 2>/dev/null || true

# Long methods
echo ""
echo "--- Long Methods (>80 lines) ---"
find_java_files -exec awk '
/^(public|private|protected|static|final|abstract|synchronized|native|strictfp)*[[:space:]]*[a-zA-Z<>\[\]]+[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": method is "NR-start" lines"; fname=""}
' {} + 2>/dev/null || true

# God classes (>500 lines)
echo ""
echo "--- Large Classes (>500 lines) ---"
find_java_files -exec awk '
/^(public|abstract|final)?[[:space:]]*(class|interface|enum)[[:space:]]/{fname=$0; start=NR}
/^}/{if(NR-start>500 && fname) print FILENAME": class is "NR-start" lines"; fname=""}
' {} + 2>/dev/null || true

# Security patterns
echo ""
echo "--- Security Patterns ---"
find_java_files -exec grep -n "Runtime\.exec\|ProcessBuilder\|ObjectInputStream\|XMLReader\|DocumentBuilder" {} + 2>/dev/null || true
