# C/C++ Security Review Bug Classes

Reference for C/C++ security audit bug classification. 47+ bug classes organized by cluster, applicable to native C/C++ application security reviews: memory safety, integer overflows, race conditions, type confusion, Linux/macOS daemons, Windows userspace services.

---

## Threat Model Approach

Before classifying bugs, establish the threat model:

| Threat Model | Scope | Impact |
|---|---|---|
| `REMOTE` | Network-accessible attack surface | Highest priority on network-facing code |
| `LOCAL_UNPRIVILEGED` | Local unprivileged user escalation | Focus on IPC, file parsing, privilege boundaries |
| `BOTH` | Combined remote + local | Full surface analysis |

---

## Bug Classes / Clusters

47 always-on bug classes. Up to 64 with all conditional clusters enabled.

---

### buffer-write-sinks

The consolidated cluster — all 13 passes run in one worker (never chunked). Sub-prompts are not re-read at runtime; the worker builds a shared Phase-A inventory once.

| ID | Bug Class | Description |
|----|-----------|-------------|
| BWS-01 | `writev-sink` | `writev`/`pwritev` scatter-gather without bounds validation |
| BWS-02 | `fwrite-sink` | `fwrite` with untrusted size/offset |
| BWS-03 | `memcpy-sink` | `memcpy`/`memmove` with attacker-controlled length |
| BWS-04 | `sprintf-sink` | `sprintf`/`snprintf` with unbounded format strings |
| BWS-05 | `strcpy-sink` | `strcpy`/`strncpy` without null termination guarantee |
| BWS-06 | `gets-sink` | `gets`/`getline` with unbounded buffer |
| BWS-07 | `read-sink` | POSIX `read` without size validation against buffer |
| BWS-08 | `recv-sink` | `recv`/`recvfrom`/`recvmsg` without length check |
| BWS-09 | `printf-sink` | `printf`/`fprintf` with attacker-controlled format |
| BWS-10 | `scanf-sink` | `scanf`/`fscanf` without width specifiers |
| BWS-11 | `syslog-sink` | `syslog` with format string from untrusted source |
| BWS-12 | `strncat-sink` | `strncat` with incorrect size calculation |
| BWS-13 | `snprintf-return` | Relying on `snprintf` return value without checking truncation |

---

### object-lifecycle

| ID | Bug Class | Description |
|----|-----------|-------------|
| OLC-01 | `use-after-free` | Accessing memory after `free()` |
| OLC-02 | `double-free` | Calling `free()` on already-freed memory |
| OLC-03 | `dangling-pointer` | Pointer outliving its referent (stack return, container reallocation) |
| OLC-04 | `uninitialized-read` | Reading uninitialized heap/stack memory |
| OLC-05 | `invalid-free` | `free()` on non-heap pointer or stack address |
| OLC-06 | `mismatched-alloc-free` | `malloc`/`new`/`new[]` paired with wrong deallocator |

---

### arithmetic-type

| ID | Bug Class | Description |
|----|-----------|-------------|
| ATR-01 | `signed-overflow` | Signed integer overflow (undefined behavior in C/C++) |
| ATR-02 | `unsigned-overflow` | Unsigned integer wraparound leading to logic error |
| ATR-03 | `integer-truncation` | Narrowing cast silently drops bits (e.g. `size_t` → `int`) |
| ATR-04 | `signedness-error` | Signed/unsigned comparison or implicit conversion |
| ATR-05 | `division-by-zero` | Division/modulo with unchecked zero divisor |
| ATR-06 | `shift-overflow` | Shift amount exceeds or equals type width |
| ATR-07 | `format-string-integer` | `%n` write via format string with untrusted integer |

---

### syscall-retval

| ID | Bug Class | Description |
|----|-----------|-------------|
| SRV-01 | `unchecked-return` | System call return value ignored (e.g. `write()`, `close()`) |
| SRV-02 | `short-read` | Partial read/write not handled correctly |
| SRV-03 | `errno-assumption` | Assuming errno is set without checking return |
| SRV-04 | `fd-leak` | File descriptor not closed on error path |
| SRV-05 | `signal-safety` | Signal handler calls non-async-signal-safe functions |

---

### concurrency

| ID | Bug Class | Description |
|----|-----------|-------------|
| CON-01 | `data-race` | Unsynchronized concurrent read/write to shared state |
| CON-02 | `atomicity-violation` | Non-atomic read-modify-write on shared variable |
| CON-03 | `deadlock` | Lock ordering violation (ABBA pattern) |
| CON-04 | `lock-ordering` | Inconsistent mutex acquisition order across call sites |
| CON-05 | `missing-lock` | Shared data accessed without holding its mutex |
| CON-06 | `signal-handler-race` | Signal handler modifies shared state without synchronization |

---

### ambient-state

| ID | Bug Class | Description |
|----|-----------|-------------|
| AMB-01 | `environment-injection` | Attacker-controlled environment variable (e.g. `LD_PRELOAD`) |
| AMB-02 | `cwd-relative-path` | Relative path traversal via `chdir`/`fopen` with CWD manipulation |
| AMB-03 | `tempfile-race` | TOCTOU on temporary file creation (`mktemp`, `tmpfile`) |
| AMB-04 | `umask-state` | Process umask affecting file permissions |
| AMB-05 | `uid-gid-mismatch` | Effective UID/GID differs from saved, exploited via fork |

---

### static-hygiene

| ID | Bug Class | Description |
|----|-----------|-------------|
| SH-01 | `mutable-static` | `static mut` accessed without synchronization |
| SH-02 | `static-init-order` | Static initialization order fiasco across translation units |
| SH-03 | `thread-local-leak` | Thread-local storage not cleaned up on thread exit |
| SH-04 | `global-buffer-alias` | Overlapping global buffers accessed concurrently |

---

### cpp-semantics

| ID | Bug Class | Description |
|----|-----------|-------------|
| CPP-01 | `object-slicing` | Derived object sliced when passed by value to base |
| CPP-02 | `vtable-attack` | Vtable pointer overwrite via buffer overflow |
| CPP-03 | `exception-safety` | Thrown exception bypasses cleanup (`noexcept` mismatch) |
| CPP-04 | `move-after-use` | Moved-from object used in undefined state |
| CPP-05 | `smart-ptr-cycle` | `shared_ptr` reference cycle causing leak |
| CPP-06 | `placement-new-alias` | Type punning via placement new without `std::bit_cast` |

---

### windows-specific (conditional)

| ID | Bug Class | Description |
|----|-----------|-------------|
| WIN-01 | `handle-leak` | Windows HANDLE not closed on error |
| WIN-02 | `privilege-escalation` | `AdjustTokenPrivileges` misuse |
| WIN-03 | `registry-injection` | Untrusted registry key read without validation |
| WIN-04 | `named-pipe-injection` | Named pipe path manipulation (UNC injection) |
| WIN-05 | `com-activation` | COM object creation with elevated privileges |
| WIN-06 | `service-persistence` | Unquoted service path allowing DLL hijack |

---

### Additional Clusters (when enabled)

| Cluster | Bug Classes | Trigger |
|---------|-------------|---------|
| `crypto-misuse` | Weak algorithm selection, key management errors, IV/nonce reuse | Always on for crypto code |
| `serialization` | Deserialization of untrusted data, type confusion, gadget chains | Always on |
| `file-parsing` | Parser buffer overflows, integer overflows in size fields | Always on for parsers |
| `privilege-boundary` | Confused deputy, IPC trust, capability leaks | Always on |

---

## Cross-Cutting Patterns

### Memory Corruption Detection

1. Trace all `malloc`/`calloc`/`realloc` → every dereference → every `free`
2. Check all pointer arithmetic against buffer bounds
3. Verify `strncpy` always null-terminates
4. Check `snprintf` return value for truncation

### Integer Overflow Detection

1. Identify all arithmetic on untrusted sizes before allocation
2. Check `size * count` before `malloc`
3. Verify cast chains preserve range
4. Check loop bounds with `int` vs `size_t` comparison

### Race Condition Detection

1. Identify all shared mutable state
2. Map lock/unlock pairs across threads
3. Check for TOCTOU on file paths, file descriptors
4. Verify signal handlers only call async-signal-safe functions

---

## Finding Classification

Each finding requires:

| Field | Description |
|-------|-------------|
| `bug_class` | One of the classes above |
| `location` | File:Line |
| `function` | Containing function |
| `confidence` | HIGH / MEDIUM / LOW |
| `title` | One-line description |
| `body` | Description, Code, Data flow, Impact, Recommendation |

Severity levels: CRITICAL (RCE, data corruption), HIGH (privilege escalation, info disclosure), MEDIUM (DoS, logic error), LOW (code quality, defense-in-depth).
