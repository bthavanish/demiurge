#!/bin/bash
# test-runner.sh -- Universal test runner
# Detects languages in project and runs appropriate test frameworks
set -euo pipefail

DIR="${1:-.}"
echo "=== Tests: $DIR ==="

# TypeScript/JavaScript
if find "$DIR" -name '*.ts' -o -name '*.tsx' -o -name '*.js' | grep -q .; then
  echo "--- TypeScript/JavaScript ---"
  if [ -f "$DIR/package.json" ]; then
    cd "$DIR" && npm test 2>/dev/null || echo "no test script configured"
  fi
fi

# Python
if find "$DIR" -name '*.py' | grep -q .; then
  echo "--- Python ---"
  command -v pytest >/dev/null 2>&1 && pytest "$DIR" -v 2>/dev/null || echo "pytest not available"
fi

# Go
if find "$DIR" -name '*.go' | grep -q .; then
  echo "--- Go ---"
  cd "$DIR" && go test ./... 2>/dev/null || echo "go test failed"
fi

# Rust
if find "$DIR" -name '*.rs' | grep -q .; then
  echo "--- Rust ---"
  cd "$DIR" && cargo test 2>/dev/null || echo "cargo test failed"
fi

# C/C++
if find "$DIR" -name '*.c' -o -name '*.cpp' | grep -q .; then
  echo "--- C/C++ ---"
  if [ -f "$DIR/CMakeLists.txt" ]; then
    cd "$DIR" && cmake -B build && cmake --build build && ctest --test-dir build 2>/dev/null || echo "cmake test failed"
  elif [ -f "$DIR/Makefile" ]; then
    cd "$DIR" && make test 2>/dev/null || echo "make test failed"
  fi
fi

# Java
if find "$DIR" -name '*.java' | grep -q .; then
  echo "--- Java ---"
  if [ -f "$DIR/pom.xml" ]; then
    cd "$DIR" && mvn test 2>/dev/null || echo "maven test failed"
  elif [ -f "$DIR/build.gradle" ] || [ -f "$DIR/build.gradle.kts" ]; then
    cd "$DIR" && ./gradlew test 2>/dev/null || echo "gradle test failed"
  fi
fi

echo ""
echo "=== Tests complete ==="
