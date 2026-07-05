# Rust Security Review Bug Classes

Reference for Rust security audit bug classification. 69 bug classes across all clusters when every conditional gate is enabled. 37 bug classes live in always-on clusters (35 always fire; 2 additionally carry `requires: has_unsafe`).

---

## Threat Model Approach

Establish threat model before classification:

| Threat Model | Scope | Impact |
|---|---|---|
| `REMOTE` | Network-accessible attack surface | Highest priority on network-facing code |
| `LOCAL_UNPRIVILEGED` | Local unprivileged user escalation | Focus on IPC, file parsing, privilege boundaries |
| `BOTH` | Combined remote + local | Full surface analysis |

### Capability Flags (determined during prerequisite analysis)

| Flag | Detection | Gated Clusters |
|------|-----------|-----------------|
| `has_unsafe` | `unsafe fn/impl/trait/blocks` present | memory-safety, layout-safety (partial) |
| `has_ffi` | `extern "C"`, `#[repr(C)]`, `CString`, `libc` | unsafe-boundary (always runs), ffi-cross-language |
| `has_concurrency` | `std::sync`, `tokio::sync`, atomics, `UnsafeCell`, `static mut` | concurrency-locking, concurrency-data-race |
| `has_async` | `async fn`, `.await`, `tokio`, `async-std` | async-runtime |
| `has_packed_repr` | `#[repr(packed)]` | layout-safety |
| `has_fs_io` | `PathBuf`, `Path`, `fs::`, `File::open` | input-os-safety (PATHJOIN, TOCTOU) |

---

## Bug Classes / Clusters

---

### unsafe-boundary

Consolidated cluster — one worker builds shared Phase-A inventory once, never chunked. Always runs regardless of `has_unsafe`.

| ID | Bug Class | Description |
|----|-----------|-------------|
| UB-01 | `safety-invariant-violation` | Unsafe block relies on invariants not maintained by caller |
| UB-02 | `missing-safety-comment` | Unsafe block without SAFETY comment explaining why sound |
| UB-03 | `unsafe-fn-delegation` | `unsafe fn` exposes raw pointer without documenting preconditions |
| UB-04 | `repr-transparent-misuse` | `#[repr(transparent)]` on type with padding or niche |
| UB-05 | `union-read-misaligned` | Reading union field at misaligned offset |
| UB-06 | `raw-pointer-deref` | `*const`/`*mut` dereference without null/bounds check |

---

### panic-dos

| ID | Bug Class | Description |
|----|-----------|-------------|
| PDOS-01 | `unwrap-panic` | `unwrap()`/`expect()` on user-controlled input |
| PDOS-02 | `index-panic` | Array/slice indexing without bounds check on untrusted index |
| PDOS-03 | `match-exhaust-panic` | Non-exhaustive match on untrusted enum (implicit panic) |
| PDOS-04 | `arithmetic-panic` | Division by zero, overflow in debug mode |
| PDOS-05 | `string-parse-panic` | `str::parse()` on untrusted string without `parse::<T>().is_ok()` guard |
| PDOS-06 | `slice-range-panic` | Unchecked slice indexing `[a..b]` where bounds come from input |
| PDOS-07 | `custom-panic` | `panic!()`/`unreachable!()` in reachable code path |

---

### recursion-dos

| ID | Bug Class | Description |
|----|-----------|-------------|
| RDOS-01 | `deep-recursion` | Unbounded recursion depth from untrusted input (stack overflow) |
| RDOS-02 | `recursive-descent-panic` | Recursive parser panics on malformed input (DoS) |
| RDOS-03 | `self-referential` | Self-referential data structure causing infinite recursion |

---

### error-handling

| ID | Bug Class | Description |
|----|-----------|-------------|
| EH-01 | `silent-error-ignore` | Error returned and discarded without logging |
| EH-02 | `error-message-leak` | Internal error details exposed to user (info disclosure) |
| EH-03 | `error-path-state-corruption` | State modified before error is returned (partial update) |
| EH-04 | `recovery-incorrect` | Error recovery logic creates inconsistent state |
| EH-05 | `panic-in-error-path` | Error handling code itself panics |

---

### logic-correctness

| ID | Bug Class | Description |
|----|-----------|-------------|
| LC-01 | `off-by-one` | Off-by-one in loop bounds, slice ranges, array indices |
| LC-02 | `logic-inversion` | AND/OR swap, negation error, wrong branch taken |
| LC-03 | `state-machine-violation` | State transition from invalid state |
| LC-04 | `missing-check` | Required validation check absent |
| LC-05 | `wrong-comparison` | `<` vs `<=`, `<` vs `>`, signed vs unsigned comparison |
| LC-06 | `dead-code` | Unreachable code hiding logic error |
| LC-07 | `adversarial-trait` | Adversarial trait implementation exploiting type system (requires `has_unsafe`) |
| LC-08 | `closure-panic` | Closure captures reference to stack; panic in closure leaves dangling (requires `has_unsafe`) |

---

### static-hygiene

| ID | Bug Class | Description |
|----|-----------|-------------|
| SH-01 | `mutable-static` | `static mut` accessed without synchronization |
| SH-02 | `lazy-init-race` | `lazy_static`/`once_cell` with non-atomic initialization |
| SH-03 | `thread-local-leak` | Thread-local storage not cleaned up on thread exit |
| SH-04 | `global-state-corruption` | Global state modified without atomicity guarantees |

---

### resource-handling

| ID | Bug Class | Description |
|----|-----------|-------------|
| RH-01 | `file-descriptor-leak` | `File`/`TcpStream` not explicitly dropped or closed |
| RH-02 | `lock-not-released` | Mutex/RwLock held across error path without RAII |
| RH-03 | `memory-unbounded-growth` | Collection grows without bound (unbounded Vec, HashMap) |
| RH-04 | `drop-panic` | `Drop` implementation panics during unwind |
| RH-05 | `resource-exhaustion` | Unbounded allocation or handle creation from untrusted input |

---

### info-disclosure

| ID | Bug Class | Description |
|----|-----------|-------------|
| ID-01 | `ptrexpose` | Raw pointer cast exposing internal data layout (always-on via info-disclosure cluster) |
| ID-02 | `error-info-leak` | Error messages contain internal paths, versions, or state |
| ID-03 | `timing-side-channel` | Non-constant-time comparison of secrets |
| ID-04 | `debug-print` | Debug output containing sensitive data in release builds |
| ID-05 | `logging-sensitive` | Sensitive data logged via `log`/`tracing` macros |

---

### memory-safety (requires `has_unsafe`)

| ID | Bug Class | Description |
|----|-----------|-------------|
| MS-01 | `use-after-free` | Use-after-free in `unsafe` block |
| MS-02 | `double-free` | Double free in `unsafe` block |
| MS-03 | `uninitialized-read` | Reading uninitialized memory via `unsafe` |
| MS-04 | `vec-set-len` | `Vec::set_len` creating uninitialized elements |
| MS-05 | `union-ub` | Union type punning creating undefined behavior |
| MS-06 | `aliasing-violation` | `&mut` aliasing violation in `unsafe` code |
| MS-07 | `buffer-overread` | Buffer overread via raw pointer arithmetic |

---

### concurrency-locking

Consolidated cluster — one worker, never chunked.

| ID | Bug Class | Description |
|----|-----------|-------------|
| CL-01 | `deadlock` | Lock ordering violation (ABBA pattern) across Mutex/RwLock |
| CL-02 | `poisoned-lock-unhandled` | Ignoring `PoisonError` when unwinding after panic |
| CL-03 | `lock-held-across-await` | Mutex held across `.await` point (async context) |
| CL-04 | `missing-lock` | Shared state accessed without holding its synchronization primitive |
| CL-05 | `recursive-lock` | Attempting to acquire already-held Mutex (deadlock) |

---

### concurrency-data-race

| ID | Bug Class | Description |
|----|-----------|-------------|
| CDR-01 | `data-race` | Unsynchronized concurrent read/write (requires `unsafe` or `UnsafeCell`) |
| CDR-02 | `atomic-ordering` | Incorrect `Ordering` on atomic load/store (e.g. `Relaxed` where `Acquire` needed) |
| CDR-03 | `atomicity-violation` | Non-atomic read-modify-write on shared atomic |
| CDR-04 | `send-sync-unsafe` | Unsafe `Send`/`Sync` impl on type that doesn't satisfy requirements |
| CDR-05 | `cell-interior-mutability` | `UnsafeCell`/`Cell`/`RefCell` data race from concurrent access |

---

### ffi-cross-language

| ID | Bug Class | Description |
|----|-----------|-------------|
| FFI-01 | `abi-mismatch` | Calling convention mismatch between Rust and C |
| FFI-02 | `string-null-termination` | CStr/CString without null terminator guarantee |
| FFI-03 | `callback-safety` | Callback function pointer passed to C without pinning |
| FFI-04 | `panic-across-ffi` | Panic unwinding across FFI boundary (undefined behavior) |
| FFI-05 | `lifetime-across-ffi` | Rust reference lifetime not matching C allocation lifetime |
| FFI-06 | `memory-layout` | `#[repr(C)]` layout mismatch with C counterpart |

---

### layout-safety (requires `has_packed_repr`)

| ID | Bug Class | Description |
|----|-----------|-------------|
| LS-01 | `packed-ref-misaligned` | Reference to field of packed struct creates misaligned pointer |
| LS-02 | `packed-field-temporary` | Temporary borrow of packed field causes unaligned access |
| LS-03 | `packed-layout-surprise` | Struct layout doesn't match expected C layout |

---

### input-os-safety (requires `has_fs_io`)

| ID | Bug Class | Description |
|----|-----------|-------------|
| IOS-01 | `pathjoin-traversal` | `PathBuf::join` with untrusted input creating path traversal |
| IOS-02 | `toctou-file` | TOCTOU race between `metadata()` check and `open()` |
| IOS-03 | `symlink-attack` | Symlink following without checking for symlinks |
| IOS-04 | `path-canonicalization` | Canonical path used for security check but not for access |

---

### async-runtime

| ID | Bug Class | Description |
|----|-----------|-------------|
| AR-01 | `blocking-in-async` | Blocking call inside async context (starves executor) |
| AR-02 | `spawn-leak` | Tokio task spawned without join handle, never cleaned up |
| AR-03 | `select-starvation` | `tokio::select!` bias causing branch starvation |
| AR-04 | `cancel-safety` | `.await` point not cancel-safe, state corrupted on drop |
| AR-05 | `deadlock-async` | Async mutex held across await point causing executor stall |

---

## Cross-Cutting Detection Patterns

### Unsafe Boundary Audit

1. Find every `unsafe` block
2. For each, verify SAFETY comment documents all invariants relied upon
3. Check that safe API callers maintain the required invariants
4. Verify `unsafe fn` docs list all preconditions

### Panic DoS Detection

1. Find all `.unwrap()`, `.expect()`, indexing operators on untrusted input
2. Trace panic paths to determine if user-controlled input can trigger
3. Check for `catch_unwind` at trust boundaries
4. Verify non-exhaustive enum matches handle all variants

### Concurrency Detection

1. Find all `Mutex`, `RwLock`, `Arc`, `Atomic*` usage
2. Map lock acquisition order across all call sites
3. Check for `.await` points while lock is held
4. Verify `Send`/`Sync` impls are sound

---

## Finding Classification

| Field | Description |
|-------|-------------|
| `bug_class` | One of the classes above |
| `location` | File:Line |
| `function` | Containing function |
| `confidence` | HIGH / MEDIUM / LOW |
| `title` | One-line description |
| `body` | Description, Code, Data flow, Impact, Recommendation |

Severity: CRITICAL (RCE, memory corruption in unsafe), HIGH (privilege escalation, data race), MEDIUM (panic DoS, logic error), LOW (code quality, defense-in-depth).
