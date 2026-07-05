# Zeroization Audit Reference

## Purpose
Detect missing zeroization of sensitive data and identify zeroization removed by compiler optimizations, with assembly-level analysis and control-flow verification.

## When to Use
- Auditing cryptographic implementations (keys, seeds, nonces, secrets)
- Reviewing authentication systems (passwords, tokens, session data)
- Analyzing code handling PII or sensitive credentials
- Verifying secure cleanup in security-critical codebases

## Finding Capabilities (11 Categories)

| Finding | Description | Evidence Required |
|---------|-------------|-------------------|
| `MISSING_SOURCE_ZEROIZE` | No zeroization in source | Source only |
| `PARTIAL_WIPE` | Incorrect size or incomplete wipe | Source only |
| `NOT_ON_ALL_PATHS` | Missing on some control-flow paths | Source (heuristic) |
| `SECRET_COPY` | Sensitive data copied without tracking | Source + MCP preferred |
| `INSECURE_HEAP_ALLOC` | Secret uses malloc vs secure_malloc | Source only |
| `OPTIMIZED_AWAY_ZEROIZE` | Compiler removed zeroization | IR diff required |
| `STACK_RETENTION` | Stack frame retains secrets after return | Assembly required |
| `REGISTER_SPILL` | Secrets spilled from registers to stack | Assembly required |
| `MISSING_ON_ERROR_PATH` | Error-handling paths lack cleanup | CFG or MCP required |
| `NOT_DOMINATING_EXITS` | Wipe doesn't dominate all exits | CFG or MCP required |
| `LOOP_UNROLLED_INCOMPLETE` | Unrolled loop wipe incomplete | Semantic IR required |

## Approved Wipe APIs

**C/C++:** `explicit_bzero`, `memset_s`, `SecureZeroMemory`, `OPENSSL_cleanse`, `sodium_memzero`, volatile wipe loops

**Rust:** `zeroize::Zeroize` trait, `Zeroizing<T>` wrapper, `ZeroizeOnDrop` derive

## Rust Zeroization Patterns

### Semantic Patterns
- **A1:** `#[derive(Copy)]` on sensitive type → every assignment duplicates secret, no Drop runs
- **A2:** No `Zeroize`, `ZeroizeOnDrop`, or `Drop` → heap bytes never zeroed
- **A3:** `Zeroize` impl without auto-trigger → `.zeroize()` never called on drop
- **A4:** `Drop` impl missing secret fields → partial wipe
- **A5:** `ZeroizeOnDrop` on struct with heap fields → Vec capacity tail not zeroed
- **A6:** `ManuallyDrop<T>` field → Drop never called automatically
- **A7:** `#[derive(Clone)]` on zeroizing type → untracked duplicates
- **A8:** `From<T>` to non-zeroizing type → secret escapes lifecycle
- **A9:** `ptr::write_bytes` without `compiler_fence` → DSE-vulnerable
- **A10:** `#[cfg(feature)]` wrapping Drop/Zeroize → compiled out when feature disabled
- **A11:** `#[derive(Debug)]` on sensitive type → prints secret bytes in logs
- **A12:** `#[derive(Serialize)]` on sensitive type → secret in serialized output

### Dangerous API Patterns
- **B1:** `mem::forget(secret)` → leaks without running destructor
- **B2:** `ManuallyDrop::new(secret)` → suppresses destructor
- **B3:** `Box::leak(secret)` → never dropped or zeroed
- **B4:** `mem::uninitialized()` → returns prior memory contents
- **B5:** `Box::into_raw(secret)` → Drop suppressed
- **B6:** `ptr::write_bytes` without volatile → eliminated by DSE
- **B7:** `mem::transmute` to non-zeroizing type → secret escapes
- **B8:** `mem::take(&mut secret)` → replaces with default, not zeroed
- **B9:** `slice::from_raw_parts` over secret buffer → aliased reference
- **B10:** `async fn` with secret across `.await` → Future cancellation leaks

### Compiler-Level Patterns
- **C-MIR1:** Closure captures sensitive local by value (MIR shows move)
- **C-MIR2:** Secret live across generator yield on error path
- **C-MIR3:** `drop_in_place` has no zeroize call
- **C-IR1:** DSE eliminates correct `zeroize()` call (O0=volatile stores, O2=0)
- **C-IR2:** Non-volatile `llvm.memset` on secret-sized range
- **C-IR3:** Secret alloca has `lifetime.end` without volatile store
- **C-IR4:** Secret alloca promoted to registers by SROA/mem2reg
- **C-ASM1:** Stack frame allocated, no zero-stores before `ret`
- **C-ASM2:** Callee-saved register spilled in sensitive function
- **C-ASM3:** Caller-saved register spilled in sensitive function
- **C-ASM4:** `drop_in_place` assembly has no zeroize/memset call

## Confidence Gating

**2+ independent signals** → `confirmed`. **1 signal** → `likely`. **0 strong signals** → `needs_review`.

**Hard evidence requirements (non-negotiable):**
- `OPTIMIZED_AWAY_ZEROIZE`: IR diff showing wipe at O0, absent at O1/O2
- `STACK_RETENTION`: Assembly showing secret bytes on stack at `ret`
- `REGISTER_SPILL`: Assembly showing spill instruction

## Fix Recommendations (order of preference)
1. `explicit_bzero` / `sodium_memzero` / `OPENSSL_cleanse` / `zeroize::Zeroize`
2. `memset_s` (C11)
3. Volatile wipe loop with compiler barrier
4. Backend-enforced zeroization

## Rationalizations to Reject
- "The compiler won't optimize this away" → Verify with IR/ASM evidence
- "This is in a hot path" → Benchmark first; don't trade security for performance
- "memset is sufficient" → Standard memset can be optimized away
- "We only handle this data briefly" → Duration is irrelevant; zeroize before scope ends
- "This isn't a real secret" → Treat as sensitive until explicitly excluded via config
