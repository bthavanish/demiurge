# Audit Mode (Full Codebase)

Audit every file in the codebase. Generate a comprehensive report covering security, logic, dead code, style violations, and architecture issues.

## Workflow

1. **Discover the codebase.** Use Glob to find all source files. Identify languages, frameworks, and project structure.

2. **Scan each file.** Read every source file. Apply the checks below.

3. **Generate the report.** Use the report template at the end of this file.

4. **Prioritize findings.** Tag each finding with severity: P0 (critical), P1 (high), P2 (medium), P3 (low).

## Checks (apply to every file)

### Security
- Hard-coded secrets, tokens, passwords, API keys
- SQL injection vectors (string concatenation in queries)
- XSS vectors (unescaped user input in HTML/templates)
- Path traversal (unvalidated file paths from user input)
- Unsafe deserialization
- Missing input validation at trust boundaries
- Insecure cryptography (MD5, SHA1 for security, weak random)
- Race conditions in concurrent access
- Missing authentication/authorization checks

### Logic
- Null/undefined dereference without guards
- Off-by-one errors in loops or array access
- Unreachable code paths
- Missing error handling (swallowed exceptions, empty catch blocks)
- Incorrect boolean logic (De Morgan violations, truthiness traps)
- Type coercion bugs
- Integer overflow/underflow in languages where it matters
- Incorrect comparison operators (== vs ===, assignment in conditionals)

### Dead Code
- Unused imports, variables, functions, classes
- Commented-out code blocks
- Unreachable branches
- Deprecated functions still in use
- Redundant conditionals (always true/false)

### Style and Naming
- Single-letter variable names (except loop counters)
- Arbitrary names (data2, temp, flag, result)
- Inconsistent naming conventions within the same file
- Magic numbers without named constants
- Functions that do more than one thing (SRP violation)
- Deeply nested code (>3 levels of nesting)

### Architecture
- Circular dependencies between modules
- God objects or god functions (>100 lines)
- Tight coupling between unrelated modules
- Missing abstraction at trust boundaries
- Configuration values hardcoded that should be external

## Report Template

```markdown
# Codebase Audit Report

**Date:** [date]
**Files scanned:** [count]
**Languages:** [list]

## Summary

| Severity | Count |
|----------|-------|
| P0 (Critical) | [n] |
| P1 (High) | [n] |
| P2 (Medium) | [n] |
| P3 (Low) | [n] |

## Findings

### P0 - Critical

#### [Finding title]
- **File:** `path/to/file.ext:line`
- **Category:** Security | Logic | Dead Code | Style | Architecture
- **Issue:** [description]
- **Fix:** [concrete fix]

### P1 - High
[same format]

### P2 - Medium
[same format]

### P3 - Low
[same format]

## Recommendations

1. [Highest-impact fix]
2. [Second-highest]
3. [Third-highest]
```

## Rules

- Read every source file. Do not skip files based on assumptions.
- Report exact file paths and line numbers.
- Provide concrete fixes, not vague suggestions.
- Group related findings. Do not repeat the same issue across multiple entries when one fix addresses all instances.
- If the codebase is large (>200 files), prioritize: security first, then logic, then dead code, then style.
