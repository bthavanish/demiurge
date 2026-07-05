# macOS Seatbelt Sandbox Profiling Reference

Generate minimally-permissioned allowlist-based Seatbelt sandbox configurations for macOS applications.

## 4-Step Methodology

### Step 1: Identify Application Requirements

Determine what the application needs across resource categories:

| Category | Operations | Common Use Cases |
|----------|------------|------------------|
| **File Read** | `file-read-data`, `file-read-metadata`, `file-read-xattr`, `file-test-existence`, `file-map-executable` | Reading source files, configs, libraries |
| **File Write** | `file-write-data`, `file-write-create`, `file-write-unlink`, `file-write-mode`, `file-write-xattr`, `file-clone`, `file-link` | Output files, caches, temp files |
| **Network** | `network-bind`, `network-inbound`, `network-outbound` | Servers, API calls, package downloads |
| **Process** | `process-fork`, `process-exec`, `process-exec-interpreter`, `process-info*`, `process-codesigning*` | Spawning child processes, scripts |
| **Mach IPC** | `mach-lookup`, `mach-register`, `mach-bootstrap`, `mach-task-name` | System services, XPC, notifications |
| **POSIX IPC** | `ipc-posix-shm*`, `ipc-posix-sem*` | Shared memory, semaphores |
| **Sysctl** | `sysctl-read`, `sysctl-write` | Reading system info (CPU, memory) |
| **IOKit** | `iokit-open`, `iokit-get-properties`, `iokit-set-properties` | Hardware access, device drivers |
| **Signals** | `signal` | Signal handling between processes |
| **Pseudo-TTY** | `pseudo-tty` | Terminal emulation |
| **System** | `system-fsctl`, `system-socket`, `system-audit`, `system-info` | Low-level system calls |
| **User Prefs** | `user-preference-read`, `user-preference-write` | Reading/writing user defaults |
| **Notifications** | `darwin-notification-post`, `distributed-notification-post` | System notifications |
| **AppleEvents** | `appleevent-send` | Inter-app communication (AppleScript) |
| **Camera/Mic** | `device-camera`, `device-microphone` | Media capture |
| **Dynamic Code** | `dynamic-code-generation` | JIT compilation |
| **NVRAM** | `nvram-get`, `nvram-set`, `nvram-delete` | Firmware variables |

For multi-subcommand applications, profile each subcommand separately with distinct sandbox configurations.

### Step 2: Start with Minimal Profile

Begin with deny-all and essential process operations:

```scheme
(version 1)
(deny default)

;; Essential for any process
(allow process-exec*)
(allow process-fork)
(allow sysctl-read)

;; Metadata access (stat, readdir) - doesn't expose file contents
(allow file-read-metadata)
```

### Step 3: Add File Read Access (Allowlist)

Use `file-read-data` (not `file-read*`) for allowlist-based reads:

```scheme
(allow file-read-data
    ;; System paths (required for most runtimes)
    (subpath "/usr")
    (subpath "/bin")
    (subpath "/sbin")
    (subpath "/System")
    (subpath "/Library")
    (subpath "/opt")                    ;; Homebrew
    (subpath "/private/var")
    (subpath "/private/etc")
    (subpath "/private/tmp")
    (subpath "/dev")

    ;; Root symlinks for path resolution
    (literal "/")
    (literal "/var")
    (literal "/etc")
    (literal "/tmp")
    (literal "/private")

    ;; Application-specific config (customize as needed)
    (regex (string-append "^" (regex-quote (param "HOME")) "/\\.myapp(/.*)?$"))

    ;; Working directory
    (subpath (param "WORKING_DIR")))
```

**Why `file-read-data` instead of `file-read*`?**
- `file-read*` allows ALL file read operations from any path
- `file-read-data` only allows reading file contents from listed paths
- Combined with `file-read-metadata`, gives stat/readdir anywhere but no content access outside allowlist

### Step 4: Add File Write Access (Restricted)

```scheme
(allow file-write*
    ;; Working directory only
    (subpath (param "WORKING_DIR"))

    ;; Temp directories
    (subpath "/private/tmp")
    (subpath "/tmp")
    (subpath "/private/var/folders")

    ;; Device files for output
    (literal "/dev/null")
    (literal "/dev/tty"))
```

## Default-Deny Principle

Start with `(deny default)` and explicitly allow only what's needed. This ensures:
- Unknown operations are blocked by default
- New system calls don't automatically gain access
- Security is maintained even if the application behavior changes

## 18+ Resource Categories

See Step 1 table above for complete list of resource categories with their operations and common use cases.

## Network Levels

Three levels of network access:

```scheme
;; OPTION 1: Block all network (most restrictive - use for build tools)
(deny network*)

;; OPTION 2: Localhost only (use for dev servers, local services)
(allow network-bind (local tcp "*:*"))
(allow network-inbound (local tcp "*:*"))
(allow network-outbound
    (literal "/private/var/run/mDNSResponder")  ;; DNS resolution
    (remote ip "localhost:*"))                   ;; localhost only

;; OPTION 3: Allow all network (least restrictive - avoid if possible)
(allow network*)
```

**Network filter syntax:**
- `(local tcp "*:*")` - any local TCP port
- `(local tcp "*:8080")` - specific local port
- `(remote ip "localhost:*")` - outbound to localhost only
- `(remote tcp)` - outbound TCP to any host
- `(literal "/private/var/run/mDNSResponder")` - Unix socket for DNS

## Iterative Testing

After generating or editing the Seatbelt profile, test functionality iteratively:

```bash
# Test basic execution
sandbox-exec -f profile.sb -D WORKING_DIR=/path -D HOME=$HOME /bin/echo "test"

# Test the actual application
sandbox-exec -f profile.sb -D WORKING_DIR=/path -D HOME=$HOME \
  /path/to/application --args

# Test security restrictions
sandbox-exec -f profile.sb -D WORKING_DIR=/tmp -D HOME=$HOME \
  cat ~/.ssh/id_rsa
# Expected: Operation not permitted
```

**Common failure modes:**

| Symptom | Cause | Fix |
|---------|-------|-----|
| Exit code 134 (SIGABRT) | Sandbox violation | Check which operation is blocked |
| Exit code 65 + syntax error | Invalid profile syntax | Check Seatbelt syntax |
| `ENOENT` for existing files | Missing `file-read-metadata` | Add `(allow file-read-metadata)` |
| Process hangs | Missing IPC permissions | Add `(allow mach-lookup)` if needed |

## Seatbelt Syntax Reference

### Path Filters
```scheme
(subpath "/path")           ;; /path and all descendants
(literal "/path/file")      ;; Exact path only
(regex "^/path/.*\\.js$")   ;; Regex match
```

### Parameter Substitution
```scheme
(param "WORKING_DIR")                                    ;; Direct use
(subpath (param "WORKING_DIR"))                          ;; In subpath
(string-append (param "HOME") "/.config")                ;; Concatenation
(regex-quote (param "HOME"))                             ;; Escape for regex
```

### Operations

**File operations:**
```scheme
(allow file-read-data ...)          ;; Read file contents
(allow file-read-metadata)          ;; stat, lstat, readdir (no contents)
(allow file-read-xattr ...)         ;; Read extended attributes
(allow file-test-existence ...)     ;; Check if file exists
(allow file-map-executable ...)     ;; mmap executable (dylibs)
(allow file-write-data ...)         ;; Write to existing files
(allow file-write-create ...)       ;; Create new files
(allow file-write-unlink ...)       ;; Delete files
(allow file-write* ...)             ;; All write operations
(allow file-read* ...)              ;; All read operations (use sparingly)
```

**Process operations:**
```scheme
(allow process-exec* ...)           ;; Execute binaries
(allow process-fork)                ;; Fork child processes
(allow process-info-pidinfo)        ;; Query process info
(allow signal)                      ;; Send/receive signals
```

**Network operations:**
```scheme
(allow network-bind (local tcp "*:*"))              ;; Bind to any local TCP port
(allow network-bind (local tcp "*:8080"))           ;; Bind to specific port
(allow network-inbound (local tcp "*:*"))           ;; Accept TCP connections
(allow network-outbound (remote ip "localhost:*"))  ;; Outbound to localhost only
(allow network-outbound (remote tcp))               ;; Outbound TCP to any host
(allow network-outbound
    (literal "/private/var/run/mDNSResponder"))     ;; DNS via Unix socket
(allow network*)                                    ;; All network (use sparingly)
(deny network*)                                     ;; Block all network
```

**IPC operations:**
```scheme
(allow mach-lookup ...)             ;; Mach IPC lookups
(allow mach-register ...)           ;; Register Mach services
(allow ipc-posix-shm* ...)          ;; POSIX shared memory
(allow ipc-posix-sem* ...)          ;; POSIX semaphores
```

**System operations:**
```scheme
(allow sysctl-read)                 ;; Read system info
(allow sysctl-write ...)            ;; Modify sysctl (rare)
(allow iokit-open ...)              ;; IOKit device access
(allow pseudo-tty)                  ;; Terminal emulation
(allow dynamic-code-generation)     ;; JIT compilation
(allow user-preference-read ...)    ;; Read user defaults
```

## Known Limitations

1. **Deprecated but functional**: Apple deprecated sandbox-exec but it works through macOS 14+
2. **Temp directory access often required**: Many applications need `/tmp` and `/var/folders`

## Example: Generic CLI Application

```scheme
(version 1)
(deny default)

;; Process
(allow process-exec*)
(allow process-fork)
(allow sysctl-read)

;; File metadata (path resolution)
(allow file-read-metadata)

;; File reads (allowlist)
(allow file-read-data
    (literal "/") (literal "/var") (literal "/etc") (literal "/tmp") (literal "/private")
    (subpath "/usr") (subpath "/bin") (subpath "/sbin") (subpath "/opt")
    (subpath "/System") (subpath "/Library") (subpath "/dev")
    (subpath "/private/var") (subpath "/private/etc") (subpath "/private/tmp")
    (subpath (param "WORKING_DIR")))

;; File writes (restricted)
(allow file-write*
    (subpath (param "WORKING_DIR"))
    (subpath "/private/tmp") (subpath "/tmp") (subpath "/private/var/folders")
    (literal "/dev/null") (literal "/dev/tty"))

;; Network disabled
(deny network*)
```

**Usage:**
```bash
sandbox-exec -f profile.sb \
  -D WORKING_DIR=/path/to/project \
  -D HOME=$HOME \
  /path/to/application
```

## References

- [Apple Sandbox Guide (reverse-engineered)](https://reverse.put.as/wp-content/uploads/2011/09/Apple-Sandbox-Guide-v1.0.pdf)
- [sandbox-exec man page](https://keith.github.io/xcode-man-pages/sandbox-exec.1.html)
