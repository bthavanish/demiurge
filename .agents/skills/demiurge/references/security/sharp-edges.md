# Sharp Edges Reference

Identifies error-prone APIs, dangerous configurations, and footgun designs that enable security mistakes.

## Core Principle

**The pit of success**: Secure usage should be the path of least resistance. If developers must understand cryptography or read documentation carefully to avoid vulnerabilities, the API has failed.

## Sharp Edge Categories

### 1. Algorithm/Mode Selection Footguns
APIs that let developers choose algorithms invite wrong choices.
- **JWT `"alg": "none"` attack** — attacker bypasses signature verification
- **Algorithm confusion (RS256→HS256)** — RSA public key used as HMAC secret
- **Detection:** Parameters named `algorithm`, `mode`, `cipher`, `hash_type`

### 2. Dangerous Defaults
Zero/empty/null values that disable security.
- `timeout=0` → infinite session? immediate expiry?
- Empty password/authentication bypass
- Boolean flags that disable security (`verify_ssl: false`)

### 3. Primitive vs. Semantic APIs
Raw bytes instead of meaningful types invite type confusion.
- Key/nonce/IV swaps compile fine when all are `[]byte`
- **Fix:** Distinct types for keys, nonces, ciphertexts

### 4. Configuration Cliffs
One wrong setting = catastrophic failure with no warning.
- Typos in YAML silently accepted (`verify_ssl: fasle`)
- Magic values (`max_retries: -1`)
- Conflicting settings accepted silently

### 5. Silent Failures
Errors that don't surface, or success that masks failure.
- `verify_signature` returns True when key is missing
- Empty catch blocks around security operations

### 6. Stringly-Typed Security
Security values as strings enable injection and confusion.
- Permissions as comma-separated strings: `"read,write,admin"`
- SQL built from string concatenation

## Cryptographic API Footguns

### Key/Nonce Confusion
```go
// All []byte — easy to swap without type errors
func Encrypt(plaintext, key, nonce []byte) []byte
// Fix: distinct types
type EncryptionKey [32]byte
type Nonce [24]byte
```

### Nonce Reuse
Generate nonces internally, return with ciphertext. Don't require developer to provide.

### Comparison Footguns
```python
if computed_mac == expected_mac:  # VULNERABLE: timing attack
if hmac.compare_digest(computed_mac, expected_mac):  # Safe
```

### KDF Misuse
```python
key = hashlib.sha256(password.encode()).digest()  # DANGEROUS: fast hash
key = hashlib.scrypt(password.encode(), salt=salt, n=2**14, r=8, p=1)  # CORRECT
```

## Configuration Patterns

### Zero/Empty/Null Semantics
- Reject numeric security params that are 0 or negative
- Reject empty passwords/keys
- Validate paths against traversal

### Boolean Traps
- Any boolean that disables security = dangerous
- Double negatives (`disable_auth: false`) = confusing
- String "false" is truthy in many languages

### Unvalidated Constructor Parameters
```php
// DANGEROUS: accepts any string
new ServerConfig(hashAlgo: 'md5');
// Fix: validate against allowlist at construction
```

## Authentication/Session Footguns

### Password Handling
- Use constant-time comparison for password/token checks
- Reject empty passwords explicitly
- Don't truncate passwords silently (bcrypt 72-byte limit)
- Uniform error messages (no user enumeration)

### Session Management
- Generate new session ID on authentication state change
- Use cryptographic randomness (`secrets.token_urlsafe`)
- Single-use, time-limited reset tokens
- Rate limiting on all auth endpoints

## Language-Specific Quick Reference

| Language | Primary Sharp Edges |
|----------|-------------------|
| C/C++ | Integer overflow UB, buffer overflows, format strings |
| Go | Silent int overflow, slice aliasing, interface nil, JSON case-insensitive |
| Rust | Debug/release overflow difference, unsafe blocks, mem::forget |
| Java | == vs equals, type erasure, serialization, swallowed exceptions |
| PHP | Type juggling (==), extract(), unserialize() |
| JS/TS | == coercion, prototype pollution, ReDoS, parseInt radix |
| Python | Mutable defaults, eval/exec, late binding, is vs == |
| Ruby | eval/send/constantize, YAML.load, mass assignment |
