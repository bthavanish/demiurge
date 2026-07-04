# Timing Side-Channel Analysis Reference

## Three Analysis Approaches

### Compiled Languages (C, C++, Go, Rust)
Analyze native assembly. Scan for variable-time CPU instructions.

**Dangerous instructions by architecture:**
- x86_64: DIV, IDIV, DIVSS, DIVSD, SQRTSS, SQRTSD
- ARM64: UDIV, SDIV, FDIV, FSQRT
- RISC-V: DIV, DIVU, REM, REMU, FDIV.S, FDIV.D, FSQRT

**Safe patterns:**
```c
// Replace division with Barrett reduction
uint32_t q = (uint32_t)(((uint64_t)a * mu) >> 32);

// Replace branches with constant-time selection
uint32_t mask = -(uint32_t)(secret != 0);
result = (a & mask) | (b & ~mask);

// Replace memcmp with constant-time comparison
CRYPTO_memcmp(a, b, len);  // OpenSSL
subtle.ConstantTimeCompare(a, b);  // Go
```

### VM-Compiled Languages (Java, C#)
Analyze bytecode (JVM/CIL). JIT may introduce leaks not visible in bytecode.

**Dangerous JVM bytecodes:** `idiv`, `ldiv`, `irem`, `lrem`, `ifeq`, `ifne`, `if_icmp*`
**Dangerous CIL bytecodes:** `div`, `div.un`, `rem`, `rem.un`, `beq`, `bne`, `blt`, `bgt`

**Safe patterns:**
```java
// Java: Use MessageDigest.isEqual for constant-time comparison
MessageDigest.isEqual(computed, expected);

// Java: Use SecureRandom, not Random
SecureRandom secureRand = new SecureRandom();
```

```csharp
// C#: Use CryptographicOperations.FixedTimeEquals
CryptographicOperations.FixedTimeEquals(computed, expected);

// C#: Use RandomNumberGenerator
RandomNumberGenerator.GetInt32(int.MaxValue);
```

### Interpreted Languages (JavaScript, Python)
Analyze bytecode (V8/CPython). Source-level pattern matching as fallback.

**Dangerous V8 bytecodes:** `Div`, `Mod`, `DivSmi`, `ModSmi`
**Dangerous CPython bytecodes:** `BINARY_TRUE_DIVIDE`, `BINARY_FLOOR_DIVIDE`, `BINARY_MODULO`, `BINARY_OP` (oparg 11/12/6)

**Safe patterns:**
```javascript
// JS: Use crypto.timingSafeEqual
crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b));

// JS: Use crypto.randomBytes
crypto.randomBytes(16).toString('hex');
```

```python
# Python: Use hmac.compare_digest
hmac.compare_digest(user_token, stored_token)

# Python: Use secrets module
secrets.token_bytes(16)
secrets.randbelow(len(items))
```

## Common Mistakes

1. Testing only one optimization level — compilers make different decisions at O0 vs O3
2. Testing only one architecture — ARM and x86 have different division behavior
3. Trusting high-level APIs — `Arrays.equals()`, `SequenceEqual()`, `==` are NOT constant-time
4. Ignoring JIT behavior — bytecode analysis is necessary but not sufficient
5. BigInteger operations — both Java and .NET BigInteger may leak timing

## CI Integration

```bash
# Compiled
uv run ct_analyzer/analyzer.py --json src/crypto/*.c

# VM-compiled
uv run ct_analyzer/analyzer.py --json CryptoUtils.java

# Interpreted
uv run ct_analyzer/analyzer.py --json crypto.py
```
