# Security Reference

Sharp edges, insecure defaults, timing side-channels, zeroization, supply chain, smart contracts, YARA detection.

---

## Sharp Edges

Error-prone APIs, dangerous configurations, and footgun designs.

**Core principle:** Secure usage should be the path of least resistance. If developers must read documentation carefully to avoid vulnerabilities, the API has failed.

### Categories

- **Algorithm/mode selection footguns** -- APIs letting devs choose algorithms invite wrong choices. Detection: parameters named `algorithm`, `mode`, `cipher`.
- **Dangerous defaults** -- Zero/empty/null values that disable security. `timeout=0`, empty password, `verify_ssl: false`.
- **Primitive vs semantic APIs** -- Raw bytes instead of meaningful types invite type confusion. Key/nonce/IV swaps compile fine when all are `[]byte`.
- **Configuration cliffs** -- One wrong setting = catastrophic failure with no warning. Typos silently accepted, magic values.
- **Silent failures** -- Errors that don't surface, or success that masks failure.
- **Stringly-typed security** -- Permissions as comma-separated strings, SQL from concatenation.

### Cryptographic Footguns

- **Key/nonce confusion**: use distinct types for keys, nonces, ciphertexts.
- **Nonce reuse**: generate nonces internally, return with ciphertext.
- **Comparison footguns**: use `hmac.compare_digest()`, not `==`.
- **KDF misuse**: use scrypt/argon2, not raw sha256 on passwords.

### Language-Specific Quick Reference

| Language | Primary Sharp Edges |
|---|---|
| C/C++ | Integer overflow UB, buffer overflows, format strings |
| Go | Silent int overflow, slice aliasing, interface nil |
| Rust | Debug/release overflow difference, unsafe blocks |
| Java | == vs equals, type erasure, serialization |
| PHP | Type juggling, extract(), unserialize() |
| JS/TS | == coercion, prototype pollution, ReDoS |
| Python | Mutable defaults, eval/exec, late binding |
| Ruby | eval/send/constantize, YAML.load |

---

## Insecure Defaults

Finds **fail-open** vulnerabilities where apps run insecurely with missing configuration.

- **Fail-open (CRITICAL):** `SECRET = env.get('KEY') or 'default'` -- app runs with weak secret
- **Fail-secure (SAFE):** `SECRET = env['KEY']` -- app crashes if missing

### Categories

- **Fallback secrets**: `os.environ.get('SECRET_KEY', 'dev-secret-key-123')`
- **Default credentials**: hardcoded admin accounts created on first run
- **Fail-open security**: `REQUIRE_AUTH = env.get(X, 'false')` -- default is no auth
- **Weak crypto**: MD5 for passwords, DES encryption
- **Permissive access**: CORS `*`, permissions `0o666`, S3 `public-read` by default
- **Debug features**: stack traces in API responses, GraphQL introspection enabled

### Rationalizations to Reject

- "It's just a development default" -- if it reaches production code, it's a finding
- "The production config overrides it" -- verify prod config exists; code-level vulnerability remains
- "It's behind authentication" -- defense in depth; compromised session still exploits

---

## Timing Side-Channel Analysis

### By Language Type

**Compiled (C, C++, Go, Rust):** Analyze native assembly for variable-time CPU instructions.
- x86_64 dangerous: DIV, IDIV, DIVSS, DIVSD, SQRTSS, SQRTSD
- ARM64 dangerous: UDIV, SDIV, FDIV, FSQRT
- Safe: Barrett reduction, constant-time selection, `CRYPTO_memcmp`/`subtle.ConstantTimeCompare`

**VM-compiled (Java, C#):** Analyze bytecode. JIT may introduce leaks not visible in bytecode.
- JVM dangerous: `idiv`, `ldiv`, `irem`, `lrem`, `ifeq`, `ifne`
- Safe: `MessageDigest.isEqual`, `CryptographicOperations.FixedTimeEquals`

**Interpreted (JS, Python):** Analyze bytecode (V8/CPython). Source-level pattern matching as fallback.
- V8 dangerous: `Div`, `Mod`, `DivSmi`, `ModSmi`
- Safe: `crypto.timingSafeEqual`, `hmac.compare_digest`

### Common Mistakes

1. Testing only one optimization level -- compilers make different decisions at O0 vs O3
2. Trusting high-level APIs -- `Arrays.equals()`, `SequenceEqual()`, `==` are NOT constant-time
3. Ignoring JIT behavior -- bytecode analysis is necessary but not sufficient

---

## Zeroization Audit

Detect missing zeroization of sensitive data and compiler-optimized-away zeroization.

### Finding Categories (11)

| Finding | Evidence Required |
|---|---|
| `MISSING_SOURCE_ZEROIZE` | Source only |
| `PARTIAL_WIPE` | Source only |
| `NOT_ON_ALL_PATHS` | Source (heuristic) |
| `SECRET_COPY` | Source + MCP preferred |
| `OPTIMIZED_AWAY_ZEROIZE` | IR diff required |
| `STACK_RETENTION` | Assembly required |
| `REGISTER_SPILL` | Assembly required |

### Approved Wipe APIs

**C/C++:** `explicit_bzero`, `memset_s`, `SecureZeroMemory`, `OPENSSL_cleanse`, `sodium_memzero`

**Rust:** `zeroize::Zeroize` trait, `Zeroizing<T>` wrapper, `ZeroizeOnDrop` derive

### Confidence Gating

2+ independent signals = `confirmed`. 1 signal = `likely`. 0 strong signals = `needs_review`.

---

## Supply Chain Risk

A dependency is high-risk if it has ANY of: single maintainer, unmaintained, low popularity, high-risk features (FFI, deserialization), past CVEs, no security contact.

### Workflow

1. Evaluate each dependency against risk criteria
2. Use `gh` for exact data (stars, issues, maintainers)
3. Suggest alternatives for high-risk dependencies

---

## Smart Contract Vulnerabilities

### Solana

- **Arbitrary CPI**: validate all CPI program IDs. Anchor: use `Program<'info, T>`.
- **Improper PDA Validation**: use `find_program_address()` for canonical bump.
- **Missing ownership/signer check**: check `account.owner` and `account.is_signer`.

### TON (FunC)

- **Integer as boolean**: FunC uses -1 for true, 0 for false. Return -1, not 1.
- **Fake Jetton contract**: validate sender address is expected Jetton wallet.
- **Forward TON without gas check**: validate `msg_value >= tx_fee + forward_ton_amount`.

### Cairo (StarkNet)

- **felt252 overflow/underflow**: use `u128`/`u256` types or explicit bounds checks.
- **L1 to L2 address conversion**: validate `0 < address < STARKNET_FIELD_PRIME`.
- **Signature replay**: include nonce and domain separator.

### Cosmos SDK

- **Non-determinism**: no `range` over maps, goroutines, `rand`, `time.Now()`.
- **Slow ABCI methods**: bounded computational complexity per block.
- **Missing error handler**: ALL keeper method calls must check error return values.

### Algorand

- **Rekeying attack**: validate `Txn.rekey_to() == Global.zero_address()`.
- **Closing account/asset**: validate close-to is zero address.
- **Access controls**: `UpdateApplication`/`DeleteApplication` must check creator/admin.

### Substrate/FRAME

- **Arithmetic overflow**: use `checked_*`, `saturating_*`, or `overflowing_*`.
- **Don't panic**: no `unwrap()`, `expect()`, array indexing without bounds check.
- **Verify first, write last**: all validation BEFORE storage writes.

### Token Integration (ERC20/ERC721)

Check for: missing return values (USDT), fee-on-transfer, rebasing tokens, ERC777 hooks, blocklists, approval race conditions. Use `SafeERC20` wrapper.

---

## YARA Rule Authoring

### Core Principles

1. Strings must generate good atoms (4-byte subsequences)
2. Target specific families, not categories
3. Test against goodware before deployment
4. Short-circuit with cheap checks first

### String Quality Tiers

- **Gold**: mutex names, stack strings, PDB paths
- **Silver**: C2 paths, config markers, custom protocol headers
- **Bronze**: unique error messages, campaign IDs
- **Reject**: API names, common paths, format strings, common libraries

### Performance

Order conditions cheapest to most expensive: filesize, magic bytes, string matches, module checks.

### Naming

`{CATEGORY}_{PLATFORM}_{FAMILY}_{VARIANT}_{DATE}` -- e.g., `MAL_Win_Emotet_Loader_Jan25`

### Testing

- `yr check` passes (syntax)
- Matches all target samples (positive)
- Zero matches on goodware corpus (negative)
- Performance <1s per file average
