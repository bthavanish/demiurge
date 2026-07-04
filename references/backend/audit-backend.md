# Audit Backend Mode

Audit backend and logic code. Security-oriented. Covers TypeScript, JavaScript, C, C++, Python, Rust, Go, Java, Kotlin, and other backend languages.

## Scope

Audit files that handle:
- Server-side logic, API routes, business logic
- Database queries and data access layers
- Authentication and authorization
- File system operations
- Network calls and external service integrations
- Configuration and environment handling
- CLI tools and scripts
- Core algorithms and data processing

Skip UI components, templates, stylesheets, and static assets.

## Workflow

1. **Discover backend files.** Glob for source files by language extension. Exclude frontend-specific files.

2. **Understand the architecture.** Identify entry points, data flow, trust boundaries, and external interfaces.

3. **Run checks.** Apply the checks below to every backend file.

4. **Generate report.** Use the report template.

## Checks

### Security (Priority)
- Hard-coded secrets (tokens, passwords, API keys, connection strings)
- SQL/NoSQL injection (string concatenation in queries)
- Command injection (user input in shell commands)
- Path traversal (unvalidated file paths from user input)
- Unsafe deserialization (pickle, yaml.load, JSON.parse on untrusted data)
- Missing input validation at API boundaries
- Insecure cryptography (MD5/SHA1 for security, weak random for tokens)
- SSRF (user-controlled URLs in server-side requests)
- CORS misconfiguration
- Missing rate limiting on sensitive endpoints
- Insecure session handling
- Missing CSRF protection
- JWT issues (none algorithm, weak secret, no expiration)
- File upload without validation (type, size, content)
- Logging sensitive data (passwords, tokens, PII)

### Error Handling
- Swallowed exceptions (empty catch/except blocks)
- Catch-all blocks that hide specific errors
- Missing error propagation at trust boundaries
- Generic error messages that leak implementation details
- Missing cleanup in error paths (resource leaks)
- Unhandled promise rejections
- Missing finally/defer/using for resource cleanup

### Type Safety
- Type assertions (`as` casts) that bypass the type system
- `any` types that hide type errors
- Missing null checks on nullable types
- Incorrect optional chaining that masks bugs
- Unsafe implicit type coercions

### Logic Correctness
- Null/undefined dereference without guards
- Off-by-one errors in loops or array access
- Race conditions in concurrent/async code
- Missing timeouts on network calls or locks
- Integer overflow/underflow
- Incorrect comparison operators
- Unreachable code paths
- Missing break in switch statements
- Mutation of shared state without synchronization

### Dead Code
- Unused imports, variables, functions, classes
- Commented-out code blocks
- Unreachable branches
- Deprecated functions still in use
- Redundant conditionals (always true/false)
- Empty functions or methods

### Performance
- N+1 query patterns
- Missing database indexes for queried fields
- Synchronous I/O in async contexts
- Unbounded data loading (missing pagination, limits)
- Inefficient algorithms (O(n^2) where O(n) suffices)
- Missing connection pooling
- Unnecessary serialization/deserialization

### Architecture
- Circular dependencies
- God functions (>100 lines)
- Missing abstraction at trust boundaries
- Business logic in API layer (or vice versa)
- Tight coupling between unrelated modules
- Configuration hardcoded that should be external

## Report Template

```markdown
# Backend Audit Report

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

## Security Score: [n]/10

## Findings

### P0 - Critical
[security vulnerabilities, data loss risks]

#### [Finding title]
- **File:** `path/to/file.ext:line`
- **Category:** Security | Error Handling | Type Safety | Logic | Dead Code | Performance | Architecture
- **Issue:** [description]
- **Attack vector:** [how this could be exploited] (for security findings)
- **Fix:** [concrete fix with code]

### P1 - High
[logic errors, missing validation, error handling gaps]

### P2 - Medium
[dead code, performance, style violations]

### P3 - Low
[naming, minor improvements]

## Recommendations

1. [Highest-impact fix]
2. [Second-highest]
3. [Third-highest]
```

## Rules

- Security findings are always P0 or P1. Never downgrade them.
- Report exact file paths and line numbers.
- For security issues, describe the attack vector.
- Provide concrete fixes with code snippets.
- If a function handles untrusted input, trace the full data flow from entry to usage.
- Check every external boundary: API endpoints, file reads, network calls, user input.
