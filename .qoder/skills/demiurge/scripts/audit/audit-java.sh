#!/bin/bash
# audit-java.sh -- Java codebase audit script
# Checks: dead code, complexity, security, design patterns
set -euo pipefail

DIR="${1:-.}"
FIND="find "$DIR" -name '*.java' -not -path '*/build/*' -not -path '*/target/*'"

echo "=== Java Audit: $DIR ==="
echo ""

# TODO markers
echo "--- Debt Markers ---"
$FIND -exec grep -n "// TODO\|// FIXME\|// HACK\|// XXX" {} \;

# Empty catch blocks
echo ""
echo "--- Empty Catch Blocks ---"
$FIND -exec grep -n -A1 "catch (" {} \; | grep -B1 "^\-\-$\|^[^-]*{}$\|^[^-]*}$" | grep -v "^--$"

# System.out.println (should use logger)
echo ""
echo "--- System.out Usage ---"
$FIND -exec grep -n "System\.out\.print\|System\.err\.print" {} \;

# Long methods
echo ""
echo "--- Long Methods (>80 lines) ---"
$FIND -exec awk '
/^(public|private|protected|static|final|abstract|synchronized|native|strictfp)*[[:space:]]*[a-zA-Z<>\[\]]+[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": method is "NR-start" lines"; fname=""}
' {} \;

# God classes (>500 lines)
echo ""
echo "--- Large Classes (>500 lines) ---"
$FIND -exec awk '
/^(public|abstract|final)?[[:space:]]*(class|interface|enum)[[:space:]]/{fname=$0; start=NR}
/^}/{if(NR-start>500 && fname) print FILENAME": class is "NR-start" lines"; fname=""}
' {} \;

# Security patterns
echo ""
echo "--- Security Patterns ---"
$FIND -exec grep -n "Runtime\.exec\|ProcessBuilder\|ObjectInputStream\|XMLReader\|DocumentBuilder" {} \;
