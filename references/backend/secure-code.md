# Secure Code Mode

Scan code for bugs, vulnerabilities, logic errors, and dead code. Fix everything. This mode combines the audit checks with immediate remediation.

## Workflow

1. **Discover code.** Find all source files in the project. Detect language(s).

2. **Load relevant references.** Based on detected languages and code type, load only the references that apply:

   | Code Type | Load These References |
   |-----------|----------------------|
   | **Any code** | `references/backend/secure-code.md` (this file), `references/backend/audit-backend.md` |
   | **C/C++ code** | `references/review/c-review-patterns.md`, `references/security/zeroization.md`, `references/security/timing-side-channels.md` |
   | **Rust code** | `references/review/rust-review-patterns.md`, `references/security/zeroization.md` |
   | **Smart contracts** | `references/security/smart-contract-vulnerabilities.md`, `references/review/entry-point-analysis.md` |
   | **DeFi/financial** | `references/domains/defi-dimensional-analysis.md` |
   | **Python code** | `references/tooling/modern-python.md` (tooling), `references/security/insecure-defaults.md` |
   | **Any code** | `references/security/sharp-edges.md` (footgun APIs), `references/security/insecure-defaults.md` |
   | **CI/CD workflows** | `references/standards/cicd-security.md` |
   | **Dependencies** | `references/security/supply-chain-risk.md` |
   | **Malware analysis** | `references/security/yara-detection.md` |
   | **Firebase/Android** | `references/domains/firebase-security.md` |
   | **Debug info** | `references/domains/dwarf-debug-info.md` |

3. **Scan.** Apply every check from the backend audit plus language-specific checks from loaded references.

4. **Fix.** For each finding, apply the fix directly. Do not just report -- fix.

5. **Verify.** Run lint, typecheck, or tests after fixing. Ensure the fix does not break anything.

6. **Report.** Summarize what was found and fixed.

## What This Mode Fixes

### Security Vulnerabilities
- Hard-coded secrets -> move to environment variables or config
- SQL injection -> parameterized queries
- XSS -> output encoding/escaping
- Path traversal -> validate and sanitize paths
- Unsafe deserialization -> safe alternatives
- Missing input validation -> add validation at boundaries
- Insecure crypto -> upgrade to secure algorithms (see `sharp-edges.md` for per-language footguns)
- SSRF -> validate and whitelist URLs
- Missing auth checks -> add authentication gates
- Race conditions -> proper locking or atomic operations
- CI/CD script injection -> sanitize `${{ github.event.* }}` in workflow files
- AI agent prompt injection -> do not pass attacker-controlled input to AI prompts
- Dependency CVEs -> upgrade or patch vulnerable packages (see `supply-chain-risk.md`)
- Timing side-channels -> constant-time operations for secrets (see `timing-side-channels.md`)
- Insecure defaults -> fail-secure patterns (see `insecure-defaults.md`)
- Missing zeroization -> zeroize sensitive data after use (see `zeroization.md`)
- Footgun APIs -> use safe alternatives (see `sharp-edges.md`)

### Language-Specific Checks

**C/C++** (see `c-review-patterns.md`):
- Buffer overflows, format strings, memcpy/strncpy misuse
- Use-after-free, double-free, NULL dereference, memory leaks
- Integer overflow, operator precedence, out-of-bounds access
- Race conditions, signal safety, TOCTOU
- Exploit mitigations (PIE, stack canaries, FORTIFY)

**Rust** (see `rust-review-patterns.md`):
- Unsafe boundary violations, transmute misuse, pointer casts
- Panic DoS on untrusted input, unwrap/expect on user data
- Recursion DoS, stack overflow from recursive types
- FFI safety (CString dangling, ABI mismatch)
- Data races, missing Send/Sync, static mut
- Async runtime misuse (blocking in async, cancellation-unsafe)

**Smart Contracts** (see `smart-contract-vulnerabilities.md`):
- Solana: arbitrary CPI, PDA validation, signer checks
- TON: integer-as-boolean, fake Jetton contracts
- Cairo: felt252 overflow, storage collision, L1 handler validation
- Cosmos: non-determinism, ABCI panics, IBC reentrancy
- Algorand: rekeying attacks, group transaction manipulation
- Substrate: arithmetic overflow, panic DoS, bad randomness

### Logic Errors
- Null dereference -> add guards or use optional chaining
- Off-by-one -> fix loop bounds
- Incorrect boolean logic -> rewrite conditions
- Type coercion bugs -> strict comparisons
- Missing error handling -> add proper error propagation
- Swallowed exceptions -> log and rethrow or handle
- Unreachable code -> remove
- Missing break in switch -> add break or fallthrough comment

### Dead Code
- Unused imports -> remove
- Unused variables -> remove
- Unused functions -> remove (check callers first)
- Commented-out code -> remove
- Unreachable branches -> remove
- Deprecated usage -> upgrade

### Code Quality
- Magic numbers -> named constants with provenance
- Single-letter names -> descriptive names
- Functions doing too many things -> split
- Deep nesting -> extract early returns or helper functions
- Inconsistent naming -> align with codebase convention
- Missing immutability -> make final/const where practical

## Fix Principles

- **Root cause, not symptom.** Grep every caller of a touched function. Fix once in the shared code.
- **Minimal diff.** Fix the bug with the smallest change that addresses the root cause.
- **Do not refactor unrelated code.** Stay focused on the finding. Refactoring is a separate task.
- **Preserve behavior.** The fix must not change observable behavior except to fix the bug.
- **Add a guard, not a comment.** If code is fragile, add a runtime check, not a comment saying "be careful."
- **Test the fix.** If there is a test runner, run it. If not, add one assert-based self-check for non-trivial fixes.

## Output

After fixing, output:

```
## Fixes Applied

| # | File | Issue | Fix |
|---|------|-------|-----|
| 1 | path/file:line | [issue] | [what was done] |
| 2 | ... | ... | ... |

## Skipped

[list of findings that were intentionally not fixed, with reasoning]
```

Code changes are applied directly to the files. No separate patch files.

## Rules

- Fix everything. Do not leave findings unfixed unless there is a clear reason (would break API, requires architectural change, user explicitly said not to).
- If a fix would require a large refactor, fix what you can and note the rest as "requires refactor."
- Never introduce new vulnerabilities while fixing existing ones.
- Run available tests/lint after fixing.
- Commit-style output: concise, what was done and why.
- Load only the references relevant to the detected code type. Do not load all references.
