# Code Review Reference

C/C++ and Rust bug classes, differential review, entry point analysis, false positive verification.

---

## C/C++ Bug Classes (47+)

### Buffer Write Sinks (13)

| ID | Class | Description |
|---|---|---|
| BWS-01 | `writev-sink` | `writev`/`pwritev` without bounds validation |
| BWS-03 | `memcpy-sink` | `memcpy`/`memmove` with attacker-controlled length |
| BWS-04 | `sprintf-sink` | `sprintf`/`snprintf` with unbounded format strings |
| BWS-05 | `strcpy-sink` | `strcpy`/`strncpy` without null termination guarantee |
| BWS-07 | `read-sink` | POSIX `read` without size validation |
| BWS-09 | `printf-sink` | `printf`/`fprintf` with attacker-controlled format |
| BWS-13 | `snprintf-return` | Relying on `snprintf` return without checking truncation |

### Object Lifecycle (6)

use-after-free, double-free, dangling-pointer, uninitialized-read, invalid-free, mismatched-alloc-free

### Arithmetic/Type (7)

signed-overflow, unsigned-overflow, integer-truncation, signedness-error, division-by-zero, shift-overflow, format-string-integer

### Syscall Retval (5)

unchecked-return, short-read, errno-assumption, fd-leak, signal-safety

### Concurrency (6)

data-race, atomicity-violation, deadlock, lock-ordering, missing-lock, signal-handler-race

### Ambient State (5)

environment-injection, cwd-relative-path, tempfile-race, umask-state, uid-gid-mismatch

### C++ Specific (6)

object-slicing, vtable-attack, exception-safety, move-after-use, smart-ptr-cycle, placement-new-alias

---

## Rust Bug Classes (69)

### Unsafe Boundary (always runs)

safety-invariant-violation, missing-safety-comment, unsafe-fn-delegation, repr-transparent-misuse, union-read-misaligned, raw-pointer-deref

### Panic DoS (7)

unwrap-panic, index-panic, match-exhaust-panic, arithmetic-panic, string-parse-panic, slice-range-panic, custom-panic

### Error Handling (5)

silent-error-ignore, error-message-leak, error-path-state-corruption, recovery-incorrect, panic-in-error-path

### Logic/Correctness (8)

off-by-one, logic-inversion, state-machine-violation, missing-check, wrong-comparison, dead-code, adversarial-trait, closure-panic

### Concurrency-Locking (5)

deadlock, poisoned-lock-unhandled, lock-held-across-await, missing-lock, recursive-lock

### Concurrency-Data-Race (5)

data-race, atomic-ordering, atomicity-violation, send-sync-unsafe, cell-interior-mutability

### FFI Cross-Language (6)

abi-mismatch, string-null-termination, callback-safety, panic-across-ffi, lifetime-across-ffi, memory-layout

### Async Runtime (5)

blocking-in-async, spawn-leak, select-starvation, cancel-safety, deadlock-async

### Memory Safety (requires `unsafe`) (7)

use-after-free, double-free, uninitialized-read, vec-set-len, union-ub, aliasing-violation, buffer-overread

---

## Differential Security Review

Security-focused code review for PRs, commits, and diffs.

### 7-Phase Workflow

1. **Pre-Analysis**: Build baseline understanding (invariants, trust boundaries, validation patterns, call graphs)
2. **Phase 0 Triage**: Extract changes, assess codebase size, risk-score each file
3. **Phase 1 Code Analysis**: Read both versions, analyze diff regions, git blame removed code
4. **Phase 2 Test Coverage**: NEW function + NO tests = elevate risk. MODIFIED validation + UNCHANGED tests = HIGH RISK
5. **Phase 3 Blast Radius**: 1-5 calls=LOW, 6-20=MEDIUM, 21-50=HIGH, 50+=CRITICAL
6. **Phase 4 Deep Context**: Map function flow, trace calls, identify invariants, Five Whys
7. **Phase 5 Adversarial**: Define attacker model, identify attack vectors, rate exploitability, build exploit scenario
8. **Phase 6 Report**: Executive summary, critical findings, test coverage, blast radius, recommendations

### Red Flags

- Removed code from "security", "CVE", or "fix" commits
- Access control modifiers removed
- Validation removed without replacement
- External calls added without checks
- High blast radius + HIGH risk change

---

## Entry Point Analysis

Identify all state-changing entry points in smart contract codebases.

### Excludes

View/pure functions (Solidity), `@view`/`@pure` (Vyper), functions without `mut` (Solana), non-entry `public fun` (Move), `get` methods (TON), `query` handlers (CosmWasm).

### Access Classifications

1. **Public (Unrestricted)** -- highest attack surface priority
2. **Role-Restricted** -- admin, owner, governance, guardian, operator, minter
3. **Contract-Only** -- callbacks, interface implementations, reply handlers

---

## False Positive Verification

### 6 Mandatory Gates

| Gate | Criterion |
|---|---|
| 1. Process | All phases completed with evidence |
| 2. Reachability | Attacker can reach and control data |
| 3. Real Impact | Leads to RCE, privesc, or info disclosure |
| 4. PoC Validation | PoC demonstrates attack path |
| 5. Math Bounds | Vulnerable condition is mathematically possible |
| 6. Environment | No environmental protections block exploitation |

### 13 FP Patterns

1. Trace full validation chain (don't analyze isolated snippets)
2. Identify defensive programming patterns (assertions vs vulnerabilities)
3. Confirm exploitable data paths (don't assume network data reaches operations)
4. Understand data source context (API returns vs compile-time constants vs network data)
5. Analyze bounds validation logic (mathematical relationships between checks and operations)
6. Verify TOCTOU claims (prove value can change between check and use)
7. Understand API contract and trust boundaries
8. Distinguish internal storage from external input
9. Don't confuse pattern recognition with vulnerability analysis
10. Verify concurrent access is actually possible
11. Assess real vs theoretical security impact
12. Understand defense-in-depth vs primary controls
13. Apply checklist rigorously, not superficially

### Bug-Class-Specific Checks

- **Memory Corruption**: language safety check first (safe Rust/Go = almost always FP)
- **Race Conditions**: what is actual race window? Can attacker widen it?
- **Integer Issues**: exact types/ranges at every computation point
- **Injection**: trace input from entry point to sink, check sanitization
