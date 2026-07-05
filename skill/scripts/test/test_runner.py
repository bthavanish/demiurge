#!/usr/bin/env python3
"""Cross-platform test runner.

Usage: test_runner.py [directory]
Detects languages and runs appropriate test frameworks.
Output: JSON to stdout, saved to /tmp/demiurge/test-runner.log
"""

import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

LOG_DIR = Path("/tmp/demiurge")
MAX_OUTPUT = 500


def check_available(cmd: str) -> bool:
    return shutil.which(cmd) is not None


def run_cmd(cmd: list[str], cwd: Path, timeout: int = 120) -> tuple[int, str, float]:
    """Run command, return (rc, output, duration_ms)."""
    start = time.monotonic()
    try:
        result = subprocess.run(
            cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout
        )
        elapsed = (time.monotonic() - start) * 1000
        return result.returncode, result.stdout + "\n" + result.stderr, elapsed
    except subprocess.TimeoutExpired:
        elapsed = (time.monotonic() - start) * 1000
        return -1, "TIMEOUT", elapsed
    except FileNotFoundError:
        return -1, f"Command not found: {cmd[0]}", 0
    except Exception as e:
        return -1, str(e), 0


def parse_int(pattern: str, text: str, default: int = 0) -> int:
    """Extract first integer matching regex pattern from text."""
    m = re.search(pattern, text)
    return int(m.group(1)) if m else default


def truncate(text: str, max_len: int = MAX_OUTPUT) -> str:
    return text[:max_len] + "..." if len(text) > max_len else text


def test_npm(target_dir: Path) -> dict | None:
    pkg = target_dir / "package.json"
    if not pkg.exists():
        return None
    try:
        data = json.loads(pkg.read_text())
    except Exception:
        return None
    if "test" not in data.get("scripts", {}):
        return None

    rc, output, dur = run_cmd(["npm", "test"], target_dir)
    status = "pass" if rc == 0 else "fail"
    passed = parse_int(r"passed[,: ]+(\d+)", output)
    failed = parse_int(r"failed[,: ]+(\d+)", output)
    total = passed + failed or parse_int(r"Tests:\s+(\d+)", output)

    return {
        "language": "javascript",
        "framework": "npm",
        "status": status,
        "tests": total,
        "passed": passed,
        "failed": failed,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_python(target_dir: Path) -> dict | None:
    has_test_config = any(
        (target_dir / f).exists()
        for f in ["pytest.ini", "setup.cfg", "pyproject.toml", "conftest.py"]
    ) or (target_dir / "tests").is_dir()

    if not has_test_config:
        return None

    # Try pytest first
    if check_available("pytest") or _python_module_available("pytest"):
        rc, output, dur = run_cmd(
            [sys.executable, "-m", "pytest", "--tb=short", "-q", str(target_dir)],
            target_dir
        )
        status = "pass" if rc == 0 else "fail"
        passed = parse_int(r"(\d+) passed", output)
        failed = parse_int(r"(\d+) failed", output)
        errors = parse_int(r"(\d+) error", output)
        total = passed + failed + errors

        return {
            "language": "python",
            "framework": "pytest",
            "status": status,
            "tests": total,
            "passed": passed,
            "failed": failed + errors,
            "duration": f"{dur:.0f}ms",
            "output": truncate(output),
        }

    # Fallback to unittest
    if check_available("python3"):
        rc, output, dur = run_cmd(
            [sys.executable, "-m", "unittest", "discover", "-s", str(target_dir)],
            target_dir
        )
        status = "pass" if rc == 0 else "fail"
        total = parse_int(r"Ran (\d+) tests", output)
        failed = parse_int(r"FAIL=(\d+)", output)

        return {
            "language": "python",
            "framework": "unittest",
            "status": status,
            "tests": total,
            "passed": total - failed,
            "failed": failed,
            "duration": f"{dur:.0f}ms",
            "output": truncate(output),
        }

    return None


def _python_module_available(mod: str) -> bool:
    try:
        subprocess.run(
            [sys.executable, "-m", mod, "--version"],
            capture_output=True, timeout=5
        )
        return True
    except Exception:
        return False


def test_go(target_dir: Path) -> dict | None:
    if not (target_dir / "go.mod").exists():
        return None
    if not check_available("go"):
        return None

    rc, output, dur = run_cmd(["go", "test", "./..."], target_dir)
    status = "pass" if rc == 0 else "fail"
    passed = len(re.findall(r"^ok\b", output, re.MULTILINE))
    failed = len(re.findall(r"^FAIL\b", output, re.MULTILINE))

    return {
        "language": "go",
        "framework": "go test",
        "status": status,
        "tests": passed + failed,
        "passed": passed,
        "failed": failed,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_rust(target_dir: Path) -> dict | None:
    if not (target_dir / "Cargo.toml").exists():
        return None
    if not check_available("cargo"):
        return None

    rc, output, dur = run_cmd(["cargo", "test"], target_dir)
    status = "pass" if rc == 0 else "fail"
    passed = parse_int(r"test result: ok\. (\d+) passed", output)
    failed = parse_int(r"(\d+) failed", output)

    return {
        "language": "rust",
        "framework": "cargo test",
        "status": status,
        "tests": passed + failed,
        "passed": passed,
        "failed": failed,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_cmake(target_dir: Path) -> dict | None:
    if not (target_dir / "CMakeLists.txt").exists():
        return None
    if not check_available("cmake"):
        return None

    build_dir = target_dir / "build"
    build_dir.mkdir(exist_ok=True)

    run_cmd(["cmake", ".."], build_dir)
    run_cmd(["cmake", "--build", "."], build_dir)
    rc, output, dur = run_cmd(["ctest", "--output-on-failure"], build_dir)

    status = "pass" if rc == 0 else "fail"
    passed = parse_int(r"(\d+) tests? passed", output)
    failed = parse_int(r"(\d+) tests? failed", output)

    return {
        "language": "c/c++",
        "framework": "cmake+ctest",
        "status": status,
        "tests": passed + failed,
        "passed": passed,
        "failed": failed,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_make(target_dir: Path) -> dict | None:
    makefile = target_dir / "Makefile"
    if not makefile.exists():
        return None
    if not check_available("make"):
        return None

    content = makefile.read_text(errors="ignore")
    if "test" not in content:
        return None

    rc, output, dur = run_cmd(["make", "test"], target_dir)
    status = "pass" if rc == 0 else "fail"

    return {
        "language": "c/c++",
        "framework": "make test",
        "status": status,
        "tests": 1 if status == "pass" else 0,
        "passed": 1 if status == "pass" else 0,
        "failed": 0 if status == "pass" else 1,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_java_maven(target_dir: Path) -> dict | None:
    if not (target_dir / "pom.xml").exists():
        return None
    if not check_available("mvn"):
        return None

    rc, output, dur = run_cmd(["mvn", "test", "-q"], target_dir)
    status = "pass" if rc == 0 else "fail"
    total = parse_int(r"Tests run: (\d+)", output)
    failed = parse_int(r"Failures: (\d+)", output)

    return {
        "language": "java",
        "framework": "maven",
        "status": status,
        "tests": total,
        "passed": total - failed,
        "failed": failed,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_java_gradle(target_dir: Path) -> dict | None:
    gradle_files = ["build.gradle", "build.gradle.kts"]
    if not any((target_dir / f).exists() for f in gradle_files):
        return None
    gradlew = target_dir / "gradlew"
    if not gradlew.exists() or not os.access(gradlew, os.X_OK):
        return None

    rc, output, dur = run_cmd([str(gradlew), "test"], target_dir)
    status = "pass" if rc == 0 else "fail"
    total = parse_int(r"(\d+) tests completed", output)
    failed = parse_int(r"(\d+) failed", output)

    return {
        "language": "java",
        "framework": "gradle",
        "status": status,
        "tests": total,
        "passed": total - failed,
        "failed": failed,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_ruby(target_dir: Path) -> dict | None:
    if not (target_dir / "Gemfile").exists() and not (target_dir / "Rakefile").exists():
        return None
    if not check_available("bundle"):
        return None

    gemfile = target_dir / "Gemfile"
    if gemfile.exists():
        content = gemfile.read_text(errors="ignore")
        if not re.search(r"minitest|rspec|test", content):
            return None

    rc, output, dur = run_cmd(["bundle", "exec", "rake", "test"], target_dir)
    status = "pass" if rc == 0 else "fail"
    total = parse_int(r"(\d+) tests, \d+ assertions", output)
    failed = parse_int(r"(\d+) failures", output)

    return {
        "language": "ruby",
        "framework": "rake",
        "status": status,
        "tests": total,
        "passed": total - failed,
        "failed": failed,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


def test_php(target_dir: Path) -> dict | None:
    phpunit_configs = ["phpunit.xml", "phpunit.xml.dist"]
    has_config = any((target_dir / f).exists() for f in phpunit_configs)
    has_composer = (target_dir / "composer.json").exists()
    if not has_config and not has_composer:
        return None

    phpunit_bin = target_dir / "vendor" / "bin" / "phpunit"
    if phpunit_bin.exists():
        cmd = [str(phpunit_bin)]
    elif check_available("phpunit"):
        cmd = ["phpunit"]
    else:
        return None

    rc, output, dur = run_cmd(cmd, target_dir)
    status = "pass" if rc == 0 else "fail"
    total = parse_int(r"Tests:\s+(\d+)", output)
    failed = parse_int(r"Failures:\s+(\d+)", output)
    errors = parse_int(r"Errors:\s+(\d+)", output)

    return {
        "language": "php",
        "framework": "phpunit",
        "status": status,
        "tests": total,
        "passed": total - failed - errors,
        "failed": failed + errors,
        "duration": f"{dur:.0f}ms",
        "output": truncate(output),
    }


TEST_RUNNERS = [
    test_npm,
    test_python,
    test_go,
    test_rust,
    test_cmake,
    test_make,
    test_java_maven,
    test_java_gradle,
    test_ruby,
    test_php,
]


def main():
    target_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")

    if not target_dir.is_dir():
        print(json.dumps({"error": f"Directory not found: {target_dir}"}), file=sys.stderr)
        sys.exit(1)

    target_dir = target_dir.resolve()

    results = []
    frameworks_found = []

    for runner in TEST_RUNNERS:
        try:
            result = runner(target_dir)
            if result is not None:
                results.append(result)
                frameworks_found.append(result["framework"])
        except Exception as e:
            print(f"  Warning: {runner.__name__} failed: {e}", file=sys.stderr)

    total_tests = sum(r["tests"] for r in results)
    total_passed = sum(r["passed"] for r in results)
    total_failed = sum(r["failed"] for r in results)

    report = {
        "directory": str(target_dir),
        "tests_run": results,
        "summary": {
            "total_tests": total_tests,
            "total_passed": total_passed,
            "total_failed": total_failed,
            "frameworks_found": frameworks_found,
        },
    }

    output = json.dumps(report, indent=2)
    print(output)

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    (LOG_DIR / "test-runner.log").write_text(output)


if __name__ == "__main__":
    main()
