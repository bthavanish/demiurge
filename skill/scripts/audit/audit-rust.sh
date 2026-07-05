#!/usr/bin/env bash
# audit-rust.sh -- Rust codebase audit script
# Checks: dead code, unwrap usage, complexity, clippy patterns
set -euo pipefail

DIR="${1:-.}"

# Find Rust source files excluding common non-project directories
find_rs_files() {
  find "$DIR" -name '*.rs' \
    -not -path '*/target/*' \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*'
}

echo "=== Rust Audit: $DIR ==="
echo ""

# unwrap() usage (should use ? or expect)
echo "--- unwrap() Usage ---"
find_rs_files -exec grep -n "\.unwrap()" {} + 2>/dev/null || true

# TODO markers
echo ""
echo "--- Debt Markers ---"
find_rs_files -exec grep -n "TODO\|FIXME\|HACK\|XXX" {} + 2>/dev/null || true

# Dead code
echo ""
echo "--- Dead Code Markers ---"
find_rs_files -exec grep -n "#\[allow(dead_code)\]\|#!\[allow(unused" {} + 2>/dev/null || true

# Unsafe blocks
echo ""
echo "--- Unsafe Blocks ---"
find_rs_files -exec grep -n "unsafe {" {} + 2>/dev/null || true

# Long functions
echo ""
echo "--- Long Functions (>80 lines) ---"
find_rs_files -exec awk '
/^fn |^pub fn |^pub async fn |^async fn /{fname=$0; start=NR}
/^}/{if(NR-start>80 && fname) print FILENAME":"start": function is "NR-start" lines"; fname=""}
' {} + 2>/dev/null || true

# Complex types
echo ""
echo "--- Complex Type Aliases ---"
find_rs_files -exec grep -n "type.*=.*<\|type.*=.*dyn\|type.*=.*impl" {} + 2>/dev/null || true

# Clippy-style patterns
echo ""
echo "--- Clippy Patterns ---"
find_rs_files -exec grep -n "\.clone()\|\.to_string()\|\.to_owned()\|Vec::new()\|Box::new(" {} + 2>/dev/null | head -20 || true
