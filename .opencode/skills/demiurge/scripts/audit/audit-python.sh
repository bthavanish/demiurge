#!/bin/bash
# audit-python.sh -- Python codebase audit script
# Checks: dead code, imports, type hints, complexity, security patterns
set -euo pipefail

DIR="${1:-.}"
FIND="find "$DIR" -name '*.py' -not -path '*/node_modules/*' -not -path '*/.venv/*' -not -path '*/venv/*' -not -path '*/__pycache__/*'"

echo "=== Python Audit: $DIR ==="
echo ""

# Dead code (unused imports)
echo "--- Unused Imports ---"
$FIND -exec grep -l "^import \|^from " {} \; | while read f; do
  python3 -c "
import ast, sys
try:
    tree = ast.parse(open('$f').read())
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
        print(f'$f: unused import: {u}')
except: pass
" 2>/dev/null
done

# Functions without type hints
echo ""
echo "--- Missing Type Hints ---"
$FIND -exec grep -n "def [a-zA-Z_]*(" {} \; | grep -v "->" | head -20

# TODO/FIXME/HACK markers
echo ""
echo "--- Debt Markers ---"
$FIND -exec grep -n "TODO\|FIXME\|HACK\|XXX\|ponytail:" {} \;

# Security patterns
echo ""
echo "--- Security Patterns ---"
$FIND -exec grep -n "eval(\|exec(\|subprocess.*shell=True\|os\.system(\|pickle\." {} \;

# Complexity
echo ""
echo "--- Long Functions (>50 lines) ---"
$FIND -exec python3 -c "
import ast
for fname in ['$f']:
    try:
        tree = ast.parse(open(fname).read())
        for node in ast.walk(tree):
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                end = getattr(node, 'end_lineno', node.lineno)
                length = end - node.lineno
                if length > 50:
                    print(f'{fname}:{node.lineno}: {node.name}() is {length} lines')
    except: pass
" 2>/dev/null;
done
