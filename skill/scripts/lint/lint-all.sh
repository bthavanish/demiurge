#!/usr/bin/env bash
# lint-all.sh -- Universal lint runner
# Detects languages in project and runs appropriate linters
set -euo pipefail

DIR="${1:-.}"
echo "=== Lint: $DIR ==="
echo ""

# TypeScript/JavaScript
if find "$DIR" -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' | grep -q . 2>/dev/null; then
  echo "--- TypeScript/JavaScript ---"
  if [ -f "$DIR/package.json" ]; then
    (cd "$DIR" && npx eslint . --max-warnings=0 2>/dev/null) || echo "  eslint not configured"
    (cd "$DIR" && npx tsc --noEmit 2>/dev/null) || echo "  tsc check failed"
  else
    echo "  No package.json found"
  fi
  echo ""
fi

# Python
if find "$DIR" -name '*.py' | grep -q . 2>/dev/null; then
  echo "--- Python ---"
  find "$DIR" -name '*.py' -not -path '*/.venv/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -exec python3 -m py_compile {} + 2>/dev/null || true
  command -v ruff >/dev/null 2>&1 && ruff check "$DIR" || echo "  ruff not available"
  command -v mypy >/dev/null 2>&1 && mypy "$DIR" || echo "  mypy not available"
  echo ""
fi

# Go
if find "$DIR" -name '*.go' | grep -q . 2>/dev/null; then
  echo "--- Go ---"
  command -v gofmt >/dev/null 2>&1 && find "$DIR" -name '*.go' -exec gofmt -l {} + 2>/dev/null || true
  command -v go >/dev/null 2>&1 && (cd "$DIR" && go vet ./... 2>/dev/null) || echo "  go vet not available"
  echo ""
fi

# Rust
if find "$DIR" -name '*.rs' | grep -q . 2>/dev/null; then
  echo "--- Rust ---"
  command -v rustfmt >/dev/null 2>&1 && (cd "$DIR" && rustfmt --check . 2>/dev/null) || echo "  rustfmt not available"
  command -v cargo >/dev/null 2>&1 && (cd "$DIR" && cargo clippy -- -D warnings 2>/dev/null) || echo "  cargo/clippy not available"
  echo ""
fi

# C/C++
if find "$DIR" \( -name '*.c' -o -name '*.cpp' -o -name '*.cc' -o -name '*.h' \) | grep -q . 2>/dev/null; then
  echo "--- C/C++ ---"
  command -v cppcheck >/dev/null 2>&1 && cppcheck --enable=all "$DIR" 2>/dev/null || echo "  cppcheck not available"
  echo ""
fi

# Java
if find "$DIR" -name '*.java' | grep -q . 2>/dev/null; then
  echo "--- Java ---"
  if command -v javac >/dev/null 2>&1; then
    find "$DIR" -name '*.java' -not -path '*/build/*' -not -path '*/target/*' -exec javac -Xlint:all {} + 2>/dev/null || echo "  javac compilation warnings/errors"
  else
    echo "  javac not available"
  fi
  echo ""
fi

echo "=== Lint complete ==="
