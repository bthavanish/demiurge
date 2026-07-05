#!/usr/bin/env bash
# audit-python.sh -- Python codebase audit script
# Checks: dead code, imports, type hints, complexity, security patterns
set -euo pipefail

DIR="${1:-.}"

# Find Python source files excluding common non-project directories
find_py_files() {
  find "$DIR" -name '*.py' \
    -not -path '*/node_modules/*' \
    -not -path '*/.venv/*' \
    -not -path '*/venv/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/.git/*' \
    -not -path '*/build/*'
}

echo "=== Python Audit: $DIR ==="
echo ""

# Dead code (unused imports)
echo "--- Unused Imports ---"
find_py_files -print0 | xargs -0 -I{} python3 -c "
import ast, sys
fname = sys.argv[1]
try:
    tree = ast.parse(open(fname).read())
    imports = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.append(alias.asname or alias.name)
        elif isinstance(node, ast.ImportFrom):
            for alias in node.names:
                imports.append(alias.asname or alias.name)
    names = [node.id for node in ast.walk(tree) if isinstance(node, ast.Name)]
    unused = [i for i in imports if i not in names and i != '*']
    for u in unused:
        print(f'{fname}: unused import: {u}')
except: pass
" {} 2>/dev/null || true

# Functions without type hints
echo ""
echo "--- Missing Type Hints ---"
find_py_files -exec grep -n "def [a-zA-Z_]*(" {} + 2>/dev/null | grep -v "->" | head -20 || true

# TODO/FIXME/HACK markers
echo ""
echo "--- Debt Markers ---"
find_py_files -exec grep -n "TODO\|FIXME\|HACK\|XXX" {} + 2>/dev/null || true

# Security patterns
echo ""
echo "--- Security Patterns ---"
find_py_files -exec grep -n "eval(\|exec(\|subprocess.*shell=True\|os\.system(\|pickle\." {} + 2>/dev/null || true

# Complexity
echo ""
echo "--- Long Functions (>50 lines) ---"
find_py_files -print0 | xargs -0 -I{} python3 -c "
import ast, sys
for fname in sys.argv[1:]:
    try:
        tree = ast.parse(open(fname).read())
        for node in ast.walk(tree):
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                end = getattr(node, 'end_lineno', node.lineno)
                length = end - node.lineno
                if length > 50:
                    print(f'{fname}:{node.lineno}: {node.name}() is {length} lines')
    except: pass
" {} 2>/dev/null || true
