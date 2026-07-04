#!/bin/bash
# audit-rust.sh -- Rust codebase audit script
# Checks: dead code, unwrap usage, complexity, clippy patterns
set -euo pipefail

DIR="${1:-.}"
FIND="find "$DIR" -name '*.rs' -not -path '*/target/*'"

echo "=== Rust Audit: $DIR ==="
echo ""

# unwrap() usage (should use ? or expect)
echo "--- unwrap() Usage ---"
$FIND -exec grep -n "\.unwrap()" {} \;

// TODO markers
echo ""
echo "--- Debt Markers ---"
$FIND -exec grep -n "TODO\|FIXME\|HACK\|XXX\|ponytail:" {} \;

# Dead code
echo ""
echo "--- Dead Code Markers ---"
$FIND -exec grep -n "#\[allow(dead_code)\]\|#!\[allow(unused" {} \;

# Unsafe blocks
echo ""
echo "--- Unsafe Blocks ---"
$FIND -exec grep -n "unsafe {" {} \;

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
$FIND -exec awk '
/^fn |^pub fn |^pub async fn |^async fn /{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} \;

# Complex types
echo ""
echo "--- Complex Type Aliases ---"
$FIND -exec grep -n "type.*=.*<\|type.*=.*dyn\|type.*=.*impl" {} \;

# Clippy-style patterns
echo ""
echo "--- Clippy Patterns ---"
$FIND -exec grep -n "\.clone()\|\.to_string()\|\.to_owned()\|Vec::new()\|Box::new(" {} \; | head -20
