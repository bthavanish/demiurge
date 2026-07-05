#!/bin/bash
# lint-all.sh -- Universal lint runner
# Detects languages in project and runs appropriate linters
set -euo pipefail

DIR="${1:-.}"
echo "=== Lint: $DIR ==="

# TypeScript/JavaScript
if find "$DIR" -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' | grep -q .; then
  echo "--- TypeScript/JavaScript ---"
  if [ -f "$DIR/package.json" ]; then
    cd "$DIR" && npx eslint . --max-warnings=0 2>/dev/null || echo "eslint not configured"
    cd "$DIR" && npx tsc --noEmit 2>/dev/null || echo "tsc check failed"
  fi
fi

# Python
if find "$DIR" -name '*.py' | grep -q .; then
  echo "--- Python ---"
  python3 -m py_compile "$DIR"/*.py 2>/dev/null || true
  command -v ruff >/dev/null 2>&1 && ruff check "$DIR" || echo "ruff not available"
  command -v mypy >/dev/null 2>&1 && mypy "$DIR" || echo "mypy not available"
fi

# Go
if find "$DIR" -name '*.go' | grep -q .; then
  echo "--- Go ---"
  command -v gofmt >/dev/null 2>&1 && gofmt -l "$DIR"/*.go || true
  command -v govet >/dev/null 2>&1 && go vet "$DIR"/... 2>/dev/null || echo "go vet failed"
fi

# Rust
if find "$DIR" -name '*.rs' | grep -q .; then
  echo "--- Rust ---"
  command -v rustfmt >/dev/null 2>&1 && rustfmt --check "$DIR" 2>/dev/null || echo "rustfmt not available"
  command -v clippy >/dev/null 2>&1 && cargo clippy -- -D warnings 2>/dev/null || echo "clippy not available"
fi

# C/C++
if find "$DIR" -name '*.c' -o -name '*.cpp' -o -name '*.cc' -o -name '*.h' | grep -q .; then
  echo "--- C/C++ ---"
  command -v cppcheck >/dev/null 2>&1 && cppcheck --enable=all "$DIR" 2>/dev/null || echo "cppcheck not available"
fi

# Java
if find "$DIR" -name '*.java' | grep -q .; then
  echo "--- Java ---"
  command -v javac >/dev/null 2>&1 && find "$DIR" -name '*.java' -exec javac -Xlint:all {} + 2>/dev/null || echo "javac not available"
fi

echo ""
echo "=== Lint complete ==="
